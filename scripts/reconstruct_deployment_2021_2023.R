# Reconcile every current map-site row against explicit historical-map readings.
# The current catalog defines a comparison denominator, NOT historical coverage.
# No current strength, absence, or coordinate vintage is certified by this join.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(sf)
out <- 'outputs/deployment_2021_2023'
dir.create(out, recursive=TRUE, showWarnings=FALSE)
old <- read.csv('data/post2019_map_coding_transcription.csv') |> filter(revision>=40)
y2023 <- read.csv('data/forecast_origin_coding_transcription.csv') |>
  mutate(coding_status='sized_components_read')
added <- read.csv('data/deployment_2021_2023_added_transcription.csv')
readings <- bind_rows(old, y2023, added) |>
  mutate(location=if_else(location=='Himbe','Himbi',location),
    sized_military=650*military_battalions+150*military_companies+35*military_platoons,
    sized_fpu=150*fpu_companies)
stopifnot(!anyDuplicated(readings[c('revision','location')]))
sources <- read.csv('data/post2019_map_coding_sources.csv') |> filter(revision>=40) |>
  transmute(revision, reference_month=as.Date(paste0(map_title_month,'-01')),
    dated_evidence_day=as.Date(english_production_date), availability_status,path,bytes,sha256)
sources_2023 <- read.csv('data/forecast_origin_deployment_sources.csv') |>
  transmute(revision=as.numeric(sub('.*Rev. ','',source)),reference_month=as.Date(reference_month),
    dated_evidence_day=as.Date(english_processing_date),
    availability_status='dated_official_report_before_cutoff',path=local_path,bytes,sha256)
sources <- bind_rows(sources,sources_2023)
for(i in seq_len(nrow(sources))) stopifnot(file.info(sources$path[i])$size==sources$bytes[i],
  digest::digest(readBin(sources$path[i],'raw',n=sources$bytes[i]),algo='sha256',serialize=FALSE)==sources$sha256[i])
# Reconstruct the same fixed research geography only for comparison. Its exact
# historical digital availability and all point geocoding vintages remain open.
boundaries <- st_read('data/raw/boundaries/salb_2018.geojson',quiet=TRUE) |>
  filter(adm1nm %in% c('Nord-Kivu','Sud-Kivu','Ituri')) |>
  transmute(locality_id=adm2cd,locality=adm2nm,province=adm1nm) |>
  left_join(read.csv('config/city_aggregation.csv'),by='locality_id',relationship='many-to-one') |>
  mutate(locality_id=coalesce(composite_id,locality_id),locality=coalesce(composite_name,locality)) |>
  group_by(locality_id,locality,province) |> summarise(.groups='drop')
modern <- readRDS('data/raw/geo_pko/2.3/location_map.rds') |> ungroup() |>
  filter(mission=='MONUSCO',year %in% 2021:2023) |>
  mutate(revision=as.numeric(sub('.*[Rr]ev[.] *','',source))) |>
  filter(revision %in% sources$revision) |>
  mutate(location=if_else(location=='Himbe','Himbi',location),
    modern_military=as.numeric(no.troops)-as.numeric(fpu.no),modern_fpu=as.numeric(fpu.no))
stopifnot(!anyDuplicated(modern[c('revision','location')]))
match <- st_intersects(st_as_sf(modern,coords=c('longitude','latitude'),crs=4326),boundaries)
stopifnot(all(lengths(match)<=1L))
modern$catalog_present <- TRUE
modern$locality_id <- vapply(match,function(x) if(length(x)==1L) boundaries$locality_id[x] else NA_character_,character(1))
census <- modern |> select(revision,location,locality_id,latitude,longitude,geosplit,modern_military,modern_fpu,catalog_present) |>
  full_join(readings,by=c('revision','location'),relationship='one-to-one') |>
  left_join(sources,by='revision',relationship='many-to-one') |>
  mutate(review_status=case_when(is.na(coding_status)~'not_yet_transcribed',
    coding_status=='site_not_named'~'named_site_unresolved',TRUE~'transcribed_components'),
    difference=sized_military-modern_military,
    historically_available_complete_strength=NA_real_)
write.csv(census,file.path(out,'all_site_reconciliation.csv'),row.names=FALSE,na='')
write.csv(census |> group_by(revision,reference_month,availability_status) |>
  summarise(current_catalog_sites=sum(catalog_present %in% TRUE),
    transcribed_numeric_sites=sum(!is.na(sized_military)),
    current_sites_without_numeric_reading=sum(catalog_present %in% TRUE & is.na(sized_military)),
    component_differences=sum(difference!=0,na.rm=TRUE),.groups='drop'),
  'data/deployment_2021_2023_map_coverage.csv',row.names=FALSE,na='')
# Every locality-map cell is explicit. A complete match to the current catalog
# still cannot certify that the map/catalog covered every historical unit.
local <- census |> filter(!is.na(locality_id)) |> group_by(locality_id,revision) |>
  summarise(current_catalog_sites=n(),numeric_readings=sum(!is.na(sized_military)),
    any_unsized=any(unsized_military_present %in% TRUE),
    read_component_sum=if(any(!is.na(sized_military))) sum(sized_military,na.rm=TRUE) else NA_real_,
    all_current_sites_read=all(!is.na(sized_military)),.groups='drop')
local <- crossing(st_drop_geometry(boundaries),revision=sources$revision) |>
  left_join(local,by=c('locality_id','revision'),relationship='one-to-one') |>
  left_join(sources |> select(-path,-bytes,-sha256),by='revision',relationship='many-to-one') |>
  mutate(current_catalog_sites=replace_na(current_catalog_sites,0L),numeric_readings=replace_na(numeric_readings,0L),
    all_current_sites_read=replace_na(all_current_sites_read,FALSE),
    complete_historical_coded_strength=NA_real_,
    unresolved_reason=if_else(current_catalog_sites==0L,'unlisted_absence_unverified','historical_site_census_and_coding_not_complete'))
write.csv(local,file.path(out,'locality_map_history.csv'),row.names=FALSE,na='')
write.csv(local |> group_by(locality_id,locality,province) |>
  summarise(map_observations=n(),maps_with_numeric_components=sum(numeric_readings>0),
    maps_all_current_catalog_sites_read=sum(all_current_sites_read),
    complete_historical_strength_observations=sum(!is.na(complete_historical_coded_strength)),.groups='drop'),
  'data/deployment_2021_2023_locality_coverage.csv',row.names=FALSE)
# Keep the entire requested monthly grid, rather than dropping unavailable cells.
# Latest dated evidence is a source pointer only: no monthly numeric carry-forward
# is justified by a partial site census, and November2023 maps are excluded.
months <- seq(as.Date('2021-01-01'),as.Date('2023-09-01'),by='month')
monthly <- crossing(st_drop_geometry(boundaries),period=months) |>
  mutate(complete_historical_coded_strength=NA_real_,
    gap_reason='incomplete_map_site_census_and_unverified_absence_or_timing')
write.csv(monthly,file.path(out,'monthly_history_gaps.csv'),row.names=FALSE,na='')
stopifnot(nrow(local)==228L,nrow(monthly)==627L,all(is.na(monthly$complete_historical_coded_strength)),
  max(sources$reference_month)==as.Date('2023-08-01'))
print(census |> filter(!is.na(difference),difference!=0) |> select(revision,location,sized_military,modern_military,difference))
cat('Full comparison census and explicit incomplete monthly history saved; no new empirical fit.\n')
# A separate retrospective release comparison, never an as-of information set.
# No recovered evidence authenticates 2.2 before the cutoff; a later page advertises it.
release <- read.csv('data/deployment_release_evidence.csv') |> filter(evidence_id=='official_2_2_rds')
stopifnot(nrow(release)==1L,file.info(release$path)$size==release$bytes,digest::digest(readBin(release$path,'raw',n=release$bytes),algo='sha256',serialize=FALSE)==release$sha256)
make_retrospective <- function(path,label,end_month) {
  x <- readRDS(path) |> ungroup() |> filter(mission=='MONUSCO',year>=2020,year<=2023) |>
    mutate(map_date=as.Date(sprintf('%04d-%02d-01',year,month)),
      revision=as.numeric(sub(' .*$', '', sub('.*[Rr]ev[.] *','',source))),
      military=as.numeric(no.troops)-as.numeric(fpu.no)) |> filter(map_date<=end_month) |>
    group_by(map_date) |> filter(revision==max(revision)) |> ungroup()
  hits <- st_intersects(st_as_sf(x,coords=c('longitude','latitude'),crs=4326),boundaries)
  stopifnot(all(lengths(hits)<=1L))
  x$locality_id <- vapply(hits,function(j) if(length(j)==1L) boundaries$locality_id[j] else NA_character_,character(1))
  stopifnot(!anyDuplicated(x[c('map_date','location','latitude','longitude')]))
  bind_rows(lapply(months,function(m) {
    period <- as.Date(m,origin='1970-01-01')
    available <- x$map_date[x$map_date<=period]
    latest <- if(length(available)) max(available) else as.Date(NA)
    z <- x |> filter(map_date==latest,!is.na(locality_id)) |> group_by(locality_id) |>
      summarise(listed_sites=n(),strength=if(anyNA(military)) NA_real_ else sum(military),.groups='drop')
    age <- if(!is.na(latest)) (as.integer(format(period,'%Y'))-as.integer(format(latest,'%Y')))*12L+
      as.integer(format(period,'%m'))-as.integer(format(latest,'%m')) else NA_integer_
    st_drop_geometry(boundaries) |> left_join(z,by='locality_id',relationship='one-to-one') |>
      mutate(period=period,release=label,source_map_date=latest,map_age_months=age,
        retrospective_strength=if_else(period<=end_month&age<=5L&!is.na(listed_sites),strength,NA_real_),
        status=case_when(period>end_month~'outside_release_period',is.na(listed_sites)~'unlisted_unknown',age>5L~'stale_map',is.na(strength)~'unknown_numeric',TRUE~'retrospective_listed_coding'),
        certified_available_at_origin=FALSE) |> select(-strength)
  }))
}
retrospective <- bind_rows(make_retrospective(release$path,'2.2',as.Date('2022-12-01')),
  make_retrospective('data/raw/geo_pko/2.3/location_map.rds','2.3',as.Date('2023-09-01')))
write.csv(retrospective,file.path(out,'retrospective_monthly_strength.csv'),row.names=FALSE,na='')
comparison <- retrospective |> select(locality_id,locality,period,release,retrospective_strength) |>
  pivot_wider(names_from=release,values_from=retrospective_strength,names_prefix='release_') |>
  mutate(difference=release_2.2-release_2.3)
write.csv(comparison,file.path(out,'retrospective_release_comparison.csv'),row.names=FALSE,na='')
write.csv(retrospective |> mutate(year=as.integer(format(period,'%Y'))) |>
  group_by(release,year) |> summarise(locality_months=n(),numeric_rows=sum(!is.na(retrospective_strength)),
    unavailable_rows=sum(is.na(retrospective_strength)),as_of_certified_rows=sum(certified_available_at_origin),.groups='drop'),
  'data/deployment_2021_2023_retrospective_coverage.csv',row.names=FALSE)
write.csv(census |> filter(!is.na(difference),difference!=0) |>
  select(revision,location,locality_id,sized_military,modern_military,difference,visual_note),
  'data/deployment_2021_2023_component_differences.csv',row.names=FALSE)
cat('Retrospective release histories saved separately; all as-of certification flags remain false.\n')
