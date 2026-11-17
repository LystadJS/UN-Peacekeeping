# Reconstruct the prospective 2027 Q1 information freeze using the same strict geography,
# occurrence windows and two-quarter indexing as the initial pilot.
.libPaths(c(".local_library", .libPaths()))
library(readr)
library(readxl)
library(dplyr)
library(tidyr)
library(sf)
out <- "outputs/prospective_2027_q1"
raw_dir <- file.path(out, "raw")
dir.create(out, recursive=TRUE, showWarnings=FALSE)
needed <- c("id","country_id","type_of_violence","where_prec","latitude","longitude",
            "date_start","date_end","source_date","deaths_civilians")
paths <- c(annual26="data/interim/ucdp/GEDEvent_v26_1.csv",
 candidate26="data/raw/ucdp/candidate_availability_20261116/GEDEvent_v26_01_26_09.csv")
read_source <- function(path) {
 if (grepl("xlsx$",path)) {
   x <- read_excel(path, guess_max = 100000) |> select(all_of(needed))
   # Mixed text/date columns lose date typing under a single character type.
   # Re-read just source_date cell-by-cell; readxl respects workbook date epoch.
   nm <- names(read_excel(path, n_max = 0))
   types <- rep("skip", length(nm)); types[nm == "id"] <- "numeric"
   types[nm == "source_date"] <- "list"
   cells <- read_excel(path, col_types = types)
   stopifnot(identical(x$id, cells$id))
   converted <- vapply(cells$source_date, function(z)
     if(inherits(z, "POSIXt") && !is.na(z)) format(z,"%Y-%m-%d") else NA_character_,character(1))
   conversion <- tibble(id=x$id, raw_value=x$source_date, typed_date=converted) |>
     filter(!is.na(typed_date),raw_value!=typed_date)
   write_csv(conversion,file.path(out,paste0(basename(path),"_date_conversions.csv")))
   x$source_date <- coalesce(converted,x$source_date)
 } else {
   x <- read_csv(path, col_select = all_of(needed), show_col_types = FALSE,
     col_types = cols(.default = col_character(), id = col_double(), country_id = col_double(),
      type_of_violence = col_double(), where_prec = col_double(), latitude = col_double(),
      longitude = col_double(), deaths_civilians = col_double()))
   stopifnot(nrow(problems(x)) == 0)
 }
 stopifnot(!anyNA(x$id), !anyDuplicated(x$id))
 x |> filter(country_id == 490) |>
   mutate(start_date = as.Date(date_start), end_date = as.Date(date_end)) |>
   select(-date_start,-date_end)
}
sources <- lapply(paths, read_source)
boundaries <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE) |>
 filter(adm1nm %in% c("Nord-Kivu","Sud-Kivu","Ituri")) |>
 transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
 left_join(read_csv("config/city_aggregation.csv",show_col_types=FALSE),by="locality_id",
           relationship="many-to-one") |>
 mutate(locality_id=coalesce(composite_id,locality_id),locality=coalesce(composite_name,locality)) |>
 group_by(locality_id,locality,province) |> summarise(.groups="drop")
stopifnot(nrow(boundaries)==19,all(st_is_valid(boundaries)))
# Apply point-in-polygon to each vintage's own coordinates, not final GED IDs.
located <- lapply(sources, function(x) {
 x <- x |> mutate(valid_coordinates=is.finite(longitude)&is.finite(latitude)&
    abs(longitude)<=180&abs(latitude)<=90, match_count=0L, locality_id=NA_character_)
 valid <- which(x$valid_coordinates)
 matches <- st_intersects(st_as_sf(x[valid,],coords=c("longitude","latitude"),crs=4326),boundaries)
 x$match_count[valid] <- lengths(matches)
 x$locality_id[valid] <- vapply(matches,function(z)if(length(z)==1)boundaries$locality_id[z] else NA_character_,character(1))
 x
})
spec <- tibble(origin="2027-01-01",target=8108L,annual="annual26",candidate="candidate26",
 annual_end=as.Date("2025-12-31"),candidate_start=as.Date("2026-01-01"),
 candidate_end=as.Date("2026-09-30"))
ledgers <- list(); checks <- list(); source_dates <- list()
for (i in seq_len(nrow(spec))) {
 s <- spec[i,]; origin_dir <- file.path(out,s$origin)
 dir.create(origin_dir,showWarnings=FALSE)
 ledger <- bind_rows(
  located[[s$annual]] |> mutate(release=s$annual,first=as.Date("2014-01-01"),last=s$annual_end),
  located[[s$candidate]] |> mutate(release=s$candidate,first=s$candidate_start,last=s$candidate_end)) |>
  mutate(reason=case_when(
   is.na(start_date)|is.na(end_date)|start_date>end_date~"invalid_dates",
   start_date<first|end_date>last~"outside_occurrence_window",
   type_of_violence!=3~"other_violence_type",
   !valid_coordinates~"invalid_coordinates",match_count!=1~"not_uniquely_assigned",
   is.na(where_prec)|where_prec!=1~"location_precision_not_exact",
   format(start_date,"%Y-%m")!=format(end_date,"%Y-%m")~"cross_month_date_interval",
   TRUE~"eligible"))
 eligible <- filter(ledger,reason=="eligible")
 stopifnot(!anyDuplicated(eligible$id),!anyNA(eligible$deaths_civilians))
 # Source dates are a warning about retrospective file content, not release dates.
 dates <- eligible |> select(id,source_date) |> separate_rows(source_date,sep=";") |>
  mutate(token=trimws(source_date),
   missing=is.na(token)|token==""|token=="1753-01-01",
   parsed=as.Date(ifelse(missing,NA_character_,token),format="%Y-%m-%d"),
   invalid=!missing&(is.na(parsed)|format(parsed,"%Y-%m-%d")!=token))
 write_csv(filter(dates,invalid),file.path(origin_dir,"invalid_source_date_tokens.csv"))
 date_status <- dates |> group_by(id) |> summarise(
   no_date=all(is.na(parsed)), invalid_token=any(invalid), any_post_origin=any(parsed>=as.Date("2026-11-16"),na.rm=TRUE),
   all_post_origin=any(!is.na(parsed))&&all(parsed>=as.Date("2026-11-16"),na.rm=TRUE),.groups="drop")
 write_csv(date_status,file.path(origin_dir,"source_date_audit.csv"))
 counts <- eligible |> mutate(source_quarter=as.integer(format(start_date,"%Y"))*4L+
                  (as.integer(format(start_date,"%m"))-1L)%/%3L) |>
   count(locality_id,source_quarter,name="recorded_events")
 panel <- crossing(locality_id=boundaries$locality_id,source_quarter=8056L:s$target) |>
  left_join(counts,by=c("locality_id","source_quarter")) |>
  mutate(recorded_events=if_else(source_quarter<=s$target-2L,
                         replace_na(recorded_events,0L),NA_integer_)) |>
  arrange(locality_id,source_quarter) |> group_by(locality_id) |>
  mutate(immediate_count=lag(recorded_events),
   lag2_count=lag(recorded_events,2),lag2_active=as.integer(lag2_count>0),
   lag2_recent_total=lag(recorded_events,2)+lag(recorded_events,3)+lag(recorded_events,4)+lag(recorded_events,5),
   latest_predictor_quarter=source_quarter-2L) |> ungroup() |>
  left_join(st_drop_geometry(boundaries),by="locality_id") |>
  mutate(time_index=source_quarter-8063L,input_complete=!is.na(lag2_recent_total))
 train <- filter(panel,source_quarter>=8064L,source_quarter<=s$target-2L)
 target <- filter(panel,source_quarter==s$target)
 stopifnot(nrow(target)==19,all(is.na(target$recorded_events)),all(is.na(target$immediate_count)),
  all(target$input_complete),all(train$input_complete),!anyNA(train$recorded_events),
  nrow(train)==19*(s$target-2L-8063L))
 write_csv(train,file.path(origin_dir,"training_rows.csv"))
 write_csv(target,file.path(origin_dir,"origin_features.csv"))
 write_csv(ledger,file.path(origin_dir,"event_ledger.csv"))
 source_dates[[i]] <- tibble(origin=s$origin,no_date=sum(date_status$no_date),
   invalid_tokens=sum(date_status$invalid_token),any_post_origin=sum(date_status$any_post_origin),all_post_origin=sum(date_status$all_post_origin))
 checks[[i]] <- tibble(origin=s$origin,training_n=nrow(train),target_n=nrow(target),
  admitted_events=nrow(eligible),raw_shared_ids=length(intersect(sources[[s$annual]]$id,sources[[s$candidate]]$id)),
  admitted_duplicate_ids=0L,target_unknown=TRUE,intervening_unknown=TRUE,
  geographic_units=19L)
}
write_csv(bind_rows(checks),file.path(out,"reconstruction_checks.csv"))
write_csv(bind_rows(source_dates),file.path(out,"source_date_summary.csv"))
write_csv(tibble(path=unname(paths),
 sha256=vapply(paths,function(p)digest::digest(file=p,algo="sha256"),character(1))),
 file.path(out,"input_hashes.csv"))
print(bind_rows(checks)); print(bind_rows(source_dates))



