# Construct recorded-outcome/history panels without fitting empirical models.
# All row-level outputs remain local under the repository's ignored outputs/.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
output_directory <- "outputs/quarterly_pilot/panel"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
write_panel_output <- function(data, name) {
  write.csv(as.data.frame(data), file.path(output_directory, paste0(name, ".csv")),
            row.names = FALSE, na = "")
}
quarter_index <- function(date) {
  as.integer(format(date, "%Y")) * 4L + (as.integer(format(date, "%m")) - 1L) %/% 3L
}

# Use audited fixed-geography assignments; reapply the SAME precision rule to
# 2014 history rather than treating the audit's pre-period label as inclusion.
ledger <- read.csv("outputs/week_1/audit_aggregated/event_ledger.csv",
                   stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(ledger$id), nrow(ledger) == 5511L)
source_events <- readr::read_csv("data/interim/ucdp/GEDEvent_v26_1.csv",
                               show_col_types = FALSE)
stopifnot(!anyDuplicated(source_events$id))
events <- ledger |>
  left_join(source_events |> select(id, deaths_civilians, source_article, country_id),
            by = "id", relationship = "one-to-one") |>
  mutate(start_date = as.Date(start_date), end_date = as.Date(end_date),
    same_month = format(start_date, "%Y-%m") == format(end_date, "%Y-%m"),
    source_quarter = quarter_index(start_date),
    inclusion_reason = case_when(
      type_of_violence != 3 ~ "other_violence_type",
      !valid_coordinates ~ "invalid_coordinate",
      !valid_dates ~ "invalid_date",
      match_count > 1 ~ "multiple_polygon_matches",
      match_count == 0 ~ "outside_target_or_unmatched",
      where_prec != 1 ~ "location_precision_not_exact",
      !same_month ~ "cross_month_date_interval",
      year < 2016 ~ "eligible_prehistory",
      TRUE ~ "eligible_outcome"))
stopifnot(nrow(events) == nrow(ledger), all(events$country_id == 490),
          !anyNA(events$deaths_civilians))
eligible <- events |> filter(inclusion_reason %in% c("eligible_prehistory", "eligible_outcome"))
write_panel_output(events |> select(id, locality_id, year, start_date, end_date,
  source_quarter, where_prec, match_count, deaths_civilians, inclusion_reason), "event_lineage")
write_panel_output(events |> count(year, inclusion_reason, name = "records"), "event_flow")

localities <- read.csv("outputs/week_1/audit_aggregated/locality_inventory.csv")
event_totals <- eligible |> group_by(locality_id, source_quarter) |>
  summarise(recorded_events = n(), civilian_fatalities = sum(deaths_civilians), .groups = "drop")
# A zero here means no eligible GED record under the prespecified filter. It is
# not evidence of no underlying violence or complete local reporting.
history_grid <- crossing(locality_id = localities$locality_id,
                         source_quarter = seq.int(2014L * 4L, 2023L * 4L + 3L)) |>
  left_join(event_totals, by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  mutate(recorded_events = coalesce(recorded_events, 0L),
         civilian_fatalities = coalesce(civilian_fatalities, 0),
         year = source_quarter %/% 4L, quarter = source_quarter %% 4L + 1L)

# Count observed positive-quarter runs. Runs already active in the first available
# quarter have an unknown starting date. Preserve that censoring until a zero.
make_history <- function(local_data) {
  local_data <- arrange(local_data, source_quarter)
  spell <- integer(nrow(local_data))
  censored <- logical(nrow(local_data))
  for (index in seq_len(nrow(local_data))) {
    if (local_data$recorded_events[index] > 0L) {
      spell[index] <- if (index == 1L) 1L else spell[index - 1L] + 1L
      censored[index] <- if (index == 1L) TRUE else censored[index - 1L]
    }
  }
  local_data$events_lag <- lag(local_data$recorded_events)
  local_data$log1p_events_lag <- log1p(local_data$events_lag)
  local_data$violent_spell_lag_observed <- lag(spell)
  local_data$violent_spell_left_censored <- lag(censored)
  # Fail closed: unknown full duration is NA, with the observed lower bound saved.
  local_data$violent_spell_lag <- ifelse(local_data$violent_spell_left_censored,
                                        NA_integer_, local_data$violent_spell_lag_observed)
  local_data$history_outcome_quarter <- lag(local_data$source_quarter)
  local_data
}
history_grid <- history_grid |> group_by(locality_id) |>
  group_modify(~ make_history(.x)) |> ungroup()

# Earlier deployment history must include 2015 Q3 for the 2016 Q1 lag-2 field.
# Rebuild from source-row provenance rather than inventing the first lag-2 value.
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv",
                    stringsAsFactors = FALSE)
original_deployment <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
lineage$military_strength <- suppressWarnings(as.numeric(lineage$no.troops)) -
  suppressWarnings(as.numeric(original_deployment$fpu.no[lineage$source_row]))
monthly_strength <- lineage |> filter(nzchar(locality_id)) |>
  mutate(period = as.Date(period)) |> group_by(locality_id, period) |>
  summarise(strength = if (anyNA(military_strength)) NA_real_ else sum(military_strength),
    max_age = max(map_age), .groups = "drop")
monthly_grid <- crossing(locality_id = localities$locality_id,
  period = seq(as.Date("2014-01-01"), as.Date("2023-12-01"), by = "month")) |>
  left_join(monthly_strength, by = c("locality_id", "period"), relationship = "one-to-one") |>
  mutate(source_quarter = quarter_index(period),
         usable = is.finite(strength) & strength >= 0 & !is.na(max_age) & max_age >= 0 & max_age <= 5)
quarterly_strength <- monthly_grid |> group_by(locality_id, source_quarter) |>
  summarise(strength_rebuilt = if (n() == 3L && all(usable)) mean(strength) / 1000 else NA_real_,
            .groups = "drop") |>
  arrange(locality_id, source_quarter) |> group_by(locality_id) |>
  mutate(strength_lag_rebuilt = lag(strength_rebuilt),
         strength_lag2 = lag(strength_rebuilt, 2L)) |> ungroup()
history_grid <- history_grid |>
  left_join(quarterly_strength, by = c("locality_id", "source_quarter"), relationship = "one-to-one")
write_panel_output(history_grid, "history_grid_2014_2023")

# Preserve the previously audited complete-history exposure selection and
# descriptive centering. Do not recompute means with held-out future outcomes.
exposure <- read.csv("outputs/quarterly_pilot/exposure_audit.csv", stringsAsFactors = FALSE) |>
  mutate(season = factor(season, levels = 1:4))
panel_all <- exposure |> left_join(
  history_grid |> filter(year >= 2016) |> select(-strength_rebuilt),
  by = c("locality_id", "year", "quarter"), relationship = "one-to-one") |>
  mutate(history_complete = !is.na(events_lag) & !is.na(violent_spell_lag) & !is.na(strength_lag2),
    core_sample = complete_locality,
    history_sample_candidate = complete_locality & history_complete,
    outcome_zero_definition = "No retained GED record; reporting completeness not established")
stopifnot(nrow(panel_all) == 608L, !anyDuplicated(panel_all[c("locality_id", "year", "quarter")]),
  all(is.na(panel_all$strength_lag) == is.na(panel_all$strength_lag_rebuilt)),
  all(abs(panel_all$strength_lag - panel_all$strength_lag_rebuilt) < 1e-10, na.rm = TRUE),
  sum(panel_all$recorded_events) == sum(events$inclusion_reason == "eligible_outcome"))
panel_core <- panel_all |> filter(core_sample)
stopifnot(nrow(panel_core) == 288L, n_distinct(panel_core$locality_id) == 9L)
write_panel_output(panel_all, "quarterly_panel_all_localities")
write_panel_output(panel_core, "quarterly_panel_complete_exposure")
saveRDS(panel_all, file.path(output_directory, "quarterly_panel_all_localities.rds"))
saveRDS(panel_core, file.path(output_directory, "quarterly_panel_complete_exposure.rds"))

# Initial outcomes are real preperiod observations, not the zero initial state
# used by a favorable simulation. Export them explicitly for initial-condition work.
initial_conditions <- history_grid |> filter(year == 2015, quarter == 4) |>
  select(locality_id, initial_recorded_events = recorded_events,
         initial_civilian_fatalities = civilian_fatalities,
         initial_strength = strength_rebuilt)
initial_conditions <- initial_conditions |> left_join(
  panel_all |> filter(year == 2016, quarter == 1) |>
    select(locality_id, initial_spell = violent_spell_lag,
           initial_spell_left_censored = violent_spell_left_censored),
  by = "locality_id", relationship = "one-to-one")
write_panel_output(initial_conditions, "initial_conditions_2015_q4")
write_panel_output(panel_all |> group_by(locality_id, locality, province) |>
  summarise(quarters = n(), core_sample = all(core_sample),
    recorded_events = sum(recorded_events), civilian_fatalities = sum(civilian_fatalities),
    censored_spell_quarters = sum(violent_spell_left_censored),
    missing_lag2_strength = sum(is.na(strength_lag2)),
    history_candidate_quarters = sum(history_sample_candidate), .groups = "drop"), "locality_summary")

# Deterministic representative trace sample: inspect source data and panel output
# together. This is a sample audit, not independent verification of news reports.
trace_sample <- eligible |> filter(inclusion_reason == "eligible_outcome") |>
  arrange(id) |> slice(unique(round(seq(1, n(), length.out = 6)))) |>
  select(id, locality_id, start_date, end_date, source_quarter, deaths_civilians, source_article) |>
  left_join(panel_all |> select(locality_id, source_quarter, year, quarter,
    panel_events = recorded_events, panel_civilian_fatalities = civilian_fatalities),
    by = c("locality_id", "source_quarter"), relationship = "many-to-one")
write_panel_output(trace_sample, "source_trace_sample")
summary <- data.frame(
  measure = c("all_locality_quarters", "core_locality_quarters", "all_recorded_events", "core_recorded_events",
              "all_civilian_fatalities", "core_civilian_fatalities", "core_censored_spell_quarters",
              "core_missing_lag2_strength", "core_history_candidate_quarters"),
  value = c(nrow(panel_all), nrow(panel_core), sum(panel_all$recorded_events), sum(panel_core$recorded_events),
    sum(panel_all$civilian_fatalities), sum(panel_core$civilian_fatalities),
    sum(panel_core$violent_spell_left_censored), sum(is.na(panel_core$strength_lag2)),
    sum(panel_core$history_sample_candidate)))
write_panel_output(summary, "panel_summary")
capture.output(sessionInfo(), file = file.path(output_directory, "session_info.txt"))
print(summary)
print(trace_sample |> select(-source_article))
