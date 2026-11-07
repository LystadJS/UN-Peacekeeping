# Update joint coverage using the recovered pre-cutoff Geo-PKO 2.1 provider file.
# Keep the older 2.0 reconstruction intact as a separately reproducible comparison.
# Selected map-site components are never substituted for full locality exposure.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
events <- read.csv("outputs/forecast_training/training_history_grid.csv") |>
  filter(year >= 2016, complete_occurrence_quarter)
deployment <- read.csv("outputs/post2019_deployment/historical_training_strength.csv")
joined <- events |>
  left_join(deployment |> select(locality_id, source_quarter,
    archived_strength_lag, archived_strength_lag2),
    by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  mutate(event_history_populated = complete.cases(recorded_events, events_lag, violent_spell_lag),
    deployment_history_populated = complete.cases(archived_strength_lag, archived_strength_lag2),
    jointly_populated = event_history_populated & deployment_history_populated)
stopifnot(nrow(joined) == 570L, !anyDuplicated(joined[c("locality_id", "source_quarter")]))
write.csv(joined, "outputs/post2019_deployment/joint_training_history.csv", row.names = FALSE, na = "")
quarter_label <- function(index) paste0(index %/% 4L, "Q", index %% 4L + 1L)
coverage <- joined |> group_by(locality_id, locality, current_core) |>
  summarise(complete_event_outcome_quarters = n(),
    jointly_populated_rows = sum(jointly_populated),
    first_joint_quarter = if (any(jointly_populated)) quarter_label(min(source_quarter[jointly_populated])) else NA_character_,
    last_joint_quarter = if (any(jointly_populated)) quarter_label(max(source_quarter[jointly_populated])) else NA_character_,
    full_30_quarter_centering_available = all(!is.na(archived_strength_lag)),
    .groups = "drop")
older <- read.csv("data/forecast_training_joint_coverage.csv") |>
  select(locality_id, older_2_0_jointly_populated_rows = jointly_populated_rows)
coverage <- coverage |> left_join(older, by = "locality_id", relationship = "one-to-one") |>
  mutate(additional_joint_rows = jointly_populated_rows - older_2_0_jointly_populated_rows)
stopifnot(nrow(coverage) == 19L, !any(coverage$full_30_quarter_centering_available),
  all(coverage$additional_joint_rows >= 0L),
  all(is.na(joined$archived_strength_lag[joined$source_quarter > 2021L * 4L])))
write.csv(coverage, "data/post2019_deployment_joint_coverage.csv", row.names = FALSE, na = "")
print(coverage |> group_by(current_core) |>
  summarise(jointly_populated = sum(jointly_populated_rows), additional = sum(additional_joint_rows)))
cat("Joint training coverage extended without fitting or filling unavailable quarters.\n")
