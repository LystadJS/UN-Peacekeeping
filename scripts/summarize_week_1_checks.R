.libPaths(c(".local_library", .libPaths()))
library(dplyr)
directory <- "outputs/week_1/audit_aggregated"
read_audit <- function(name) read.csv(file.path(directory,paste0(name,".csv")))
print(read_audit("event_flow"))
print(read_audit("join_audit"))
print(read_audit("locality_variation"))
crosswalk <- read_audit("boundary_crosswalk_area")
print(crosswalk |> group_by(vintage,source_id) |> summarise(max_share=max(source_area_share),.groups="drop") |>
        group_by(vintage) |> summarise(source_units=n(), near_complete=sum(max_share>.999),min_share=min(max_share)))
schedule <- read_audit("map_schedule") |> filter(map_date >= "2015-01-01")
print(summary(schedule$gap_months))
print(table(read_audit("alternative_boundary_event_assignment")$alternative_match_count))
print(read_audit("named_target_unmatched_events") |> select(id,adm_1,adm_2,where_coordinates,longitude,latitude,match_count))
