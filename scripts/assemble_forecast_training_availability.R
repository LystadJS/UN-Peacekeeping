# Join the reconstructed event histories to the archived deployment prefix.
# Jointly populated fields are not a certified complete forecast information set:
# event CSV byte identity and fixed historical geography remain qualified.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
events <- read.csv("outputs/forecast_training/training_history_grid.csv") |>
  filter(year >= 2016, complete_occurrence_quarter)
deployment <- read.csv("outputs/forecast_origin/coding/historical_training_strength.csv")
joined <- events |>
  left_join(deployment |> select(locality_id, source_quarter,
    archived_strength_lag, archived_strength_lag2),
    by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  mutate(event_history_populated = complete.cases(recorded_events, events_lag, violent_spell_lag),
    deployment_history_populated = complete.cases(archived_strength_lag, archived_strength_lag2),
    jointly_populated = event_history_populated & deployment_history_populated)
stopifnot(nrow(joined) == 570L, !anyDuplicated(joined[c("locality_id", "source_quarter")]))
write.csv(joined, "outputs/forecast_training/joint_training_history.csv", row.names = FALSE, na = "")
quarter_label <- function(index) paste0(index %/% 4L, "Q", index %% 4L + 1L)
coverage <- joined |> group_by(locality_id, locality, current_core) |>
  summarise(complete_event_outcome_quarters = n(),
    event_history_populated_rows = sum(event_history_populated),
    both_deployment_lags_populated_rows = sum(deployment_history_populated),
    jointly_populated_rows = sum(jointly_populated),
    first_joint_quarter = if (any(jointly_populated)) quarter_label(min(source_quarter[jointly_populated])) else NA_character_,
    last_joint_quarter = if (any(jointly_populated)) quarter_label(max(source_quarter[jointly_populated])) else NA_character_,
    full_30_quarter_centering_available = all(!is.na(archived_strength_lag)),
    .groups = "drop")
stopifnot(nrow(coverage) == 19L, !any(coverage$full_30_quarter_centering_available),
  all(is.na(joined$archived_strength_lag[joined$source_quarter > 2020L * 4L])))
write.csv(coverage, "data/forecast_training_joint_coverage.csv", row.names = FALSE, na = "")
print(coverage |> group_by(current_core) |>
  summarise(rows = sum(complete_event_outcome_quarters), jointly_populated = sum(jointly_populated_rows)))
cat("Partial joint training histories assembled; no model fit or missing-value imputation.\n")
