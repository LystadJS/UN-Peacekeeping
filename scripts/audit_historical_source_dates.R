# Audit publication-date clues without treating them as GED release dates.
# This is a read-only follow-up to the frozen model inputs: no fits or panel changes.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
events <- readr::read_csv("data/interim/ucdp/GEDEvent_v26_1.csv", show_col_types = FALSE)
lineage <- read.csv("outputs/quarterly_pilot/panel/event_lineage.csv")
exposure <- read.csv("outputs/quarterly_pilot/exposure_audit.csv")
core_ids <- sort(unique(exposure$locality_id[exposure$complete_locality]))
retained <- lineage |> filter(inclusion_reason == "eligible_outcome", locality_id %in% core_ids) |>
  left_join(events |> select(id, source_date), by = "id", relationship = "one-to-one")
stopifnot(nrow(retained) == 1248L, !anyDuplicated(retained$id))

# Every semicolon-separated token is retained for validation. The historical
# sentinel is missing information, not evidence of an eighteenth-century report.
tokens <- retained |> select(id, source_date) |>
  separate_rows(source_date, sep = ";") |>
  mutate(source_date = trimws(source_date),
    missing_token = is.na(source_date) | source_date == "" | source_date == "1753-01-01",
    parsed_date = as.Date(ifelse(missing_token, NA_character_, source_date), format = "%Y-%m-%d"),
    invalid_token = !missing_token & (is.na(parsed_date) |
      format(parsed_date, "%Y-%m-%d") != source_date))
stopifnot(!any(tokens$invalid_token))
date_bounds <- tokens |> group_by(id) |>
  summarise(valid_dates = sum(!is.na(parsed_date)), missing_tokens = sum(missing_token),
    earliest = if (all(is.na(parsed_date))) as.Date(NA) else min(parsed_date, na.rm = TRUE),
    latest = if (all(is.na(parsed_date))) as.Date(NA) else max(parsed_date, na.rm = TRUE),
    .groups = "drop")
audited <- retained |> left_join(date_bounds, by = "id", relationship = "one-to-one") |>
  mutate(next_quarter = source_quarter + 1L,
    next_quarter_start = as.Date(sprintf("%04d-%02d-01", next_quarter %/% 4L,
      (next_quarter %% 4L) * 3L + 1L)),
    earliest_after_origin = earliest > next_quarter_start,
    latest_after_origin = latest > next_quarter_start,
    earliest_on_origin = earliest == next_quarter_start,
    latest_on_origin = latest == next_quarter_start)

# The forecast-origin subset is the immediately preceding quarter for the 20
# existing forecasts (2018 Q4 through 2023 Q3). Earlier history can also be revised;
# this limited diagnostic does not certify the complete historical feature set.
summarize_dates <- function(rows, population) {
  data.frame(population = population, events = nrow(rows),
    events_with_valid_dates = sum(rows$valid_dates > 0),
    events_with_missing_tokens = sum(rows$missing_tokens > 0),
    events_without_valid_dates = sum(rows$valid_dates == 0),
    earliest_strictly_after_next_quarter_start = sum(rows$earliest_after_origin, na.rm = TRUE),
    latest_strictly_after_next_quarter_start = sum(rows$latest_after_origin, na.rm = TRUE),
    earliest_on_next_quarter_start = sum(rows$earliest_on_origin, na.rm = TRUE),
    latest_on_next_quarter_start = sum(rows$latest_on_origin, na.rm = TRUE))
}
summary <- bind_rows(summarize_dates(audited, "all_retained_2016_2023"),
  summarize_dates(filter(audited, source_quarter >= 2018L * 4L + 3L,
    source_quarter <= 2023L * 4L + 2L), "immediate_history_of_20_forecast_folds"))
write.csv(summary, "data/historical_source_date_audit.csv", row.names = FALSE)

# Compare the historical full-window sample with a precisely stated alternative:
# uninterrupted nonmissing prior-quarter strength from 2016 Q1 through training end.
# The alternative still uses today's released values, not historical release vintages.
eligibility <- bind_rows(lapply(13:32, function(test_index) {
  previous <- exposure |> filter(time_index < test_index) |> group_by(locality_id) |>
    summarise(past_complete = all(!is.na(strength_lag)), .groups = "drop")
  past_ids <- sort(previous$locality_id[previous$past_complete])
  data.frame(test_index = test_index, training_quarters = test_index - 1L,
    past_complete_localities = length(past_ids), full_window_localities = length(core_ids),
    identical_locality_sets = identical(past_ids, core_ids))
}))
stopifnot(nrow(eligibility) == 20L, all(eligibility$identical_locality_sets))
write.csv(eligibility, "data/historical_eligibility_audit.csv", row.names = FALSE)
print(summary)
cat("All 20 retrospective past-only eligibility sets match the nine-locality sample.\n")
