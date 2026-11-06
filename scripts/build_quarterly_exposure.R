# Build deployment-only design information. No violence model is fitted here.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
dir.create("outputs/quarterly_pilot", recursive=TRUE, showWarnings=FALSE)
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv", stringsAsFactors=FALSE)
original <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
lineage$fpu_number <- suppressWarnings(as.numeric(original$fpu.no[lineage$source_row]))
lineage$strength <- suppressWarnings(as.numeric(lineage$no.troops)) - lineage$fpu_number
lineage <- lineage |> filter(nzchar(locality_id)) |> mutate(period=as.Date(period))
monthly <- lineage |> group_by(locality_id,period) |>
  summarise(strength=if(any(is.na(strength))) NA_real_ else sum(strength),
    max_age=max(map_age), sources=paste(sort(unique(paste(source,map_date))),collapse=";"),.groups="drop")
localities <- read.csv("outputs/week_1/audit_aggregated/locality_inventory.csv")
grid <- crossing(locality_id=localities$locality_id,
                 period=seq(as.Date("2015-10-01"),as.Date("2023-12-01"),by="month")) |>
  left_join(monthly,by=c("locality_id","period"),relationship="one-to-one") |>
  mutate(year=as.integer(format(period,"%Y")),quarter=(as.integer(format(period,"%m"))-1L)%/%3L+1L,
         acceptable=!is.na(strength)&!is.na(max_age)&max_age<=5)
quarters <- grid |> group_by(locality_id,year,quarter) |>
  summarise(known_months=sum(acceptable),strength=if(all(acceptable)) mean(strength)/1000 else NA_real_,
    source_maps=paste(unique(na.omit(sources)),collapse=";"),.groups="drop") |>
  arrange(locality_id,year,quarter) |> group_by(locality_id) |>
  mutate(strength_lag=lag(strength),exposure_sources=lag(source_maps)) |>
  filter(year>=2016) |> mutate(complete_locality=all(!is.na(strength_lag)),
    strength_between=mean(strength_lag,na.rm=TRUE),strength_within=strength_lag-strength_between) |>
  ungroup() |> left_join(localities,by="locality_id",relationship="many-to-one") |>
  mutate(time_index=(year-2016L)*4L+quarter,season=factor(quarter))
stopifnot(nrow(quarters)==19*32,!anyDuplicated(quarters[c("locality_id","year","quarter")]))
write.csv(quarters,"outputs/quarterly_pilot/exposure_audit.csv",row.names=FALSE,na="")
design <- quarters |> filter(complete_locality)
saveRDS(design,"outputs/quarterly_pilot/exposure_design.rds")
write.csv(quarters |> group_by(locality_id,locality) |> summarise(eligible_quarters=sum(!is.na(strength_lag)),
  complete_locality=all(complete_locality),distinct_strengths=n_distinct(strength_lag,na.rm=TRUE),.groups="drop"),
  "outputs/quarterly_pilot/exposure_coverage.csv",row.names=FALSE)
print(count(design,locality,province))
