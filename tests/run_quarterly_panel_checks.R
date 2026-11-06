# Independent checks of saved panel outputs; no empirical model is fitted.
directory <- "outputs/quarterly_pilot/panel/"
all_panel <- readRDS(paste0(directory, "quarterly_panel_all_localities.rds"))
core_panel <- readRDS(paste0(directory, "quarterly_panel_complete_exposure.rds"))
history <- read.csv(paste0(directory, "history_grid_2014_2023.csv"))
lineage <- read.csv(paste0(directory, "event_lineage.csv"))
retained <- subset(lineage, inclusion_reason == "eligible_outcome")
stopifnot(nrow(all_panel) == 19L * 32L, nrow(core_panel) == 9L * 32L,
          is.factor(core_panel$season), identical(levels(core_panel$season), as.character(1:4)),
          !anyDuplicated(all_panel[c("locality_id", "year", "quarter")]),
          !anyDuplicated(lineage$id), nrow(lineage) == 5511L,
          sum(all_panel$recorded_events) == nrow(retained),
          all(core_panel$history_complete),
          all(core_panel$history_outcome_quarter < core_panel$source_quarter),
          all(is.na(all_panel$strength_lag) == is.na(all_panel$strength_lag_rebuilt)))

# Recompute counts and fatalities from event IDs, independently of dplyr joins.
expected_counts <- aggregate(id ~ locality_id + source_quarter, retained, length)
expected_fatalities <- aggregate(deaths_civilians ~ locality_id + source_quarter, retained, sum)
comparison <- merge(all_panel, expected_counts, by = c("locality_id", "source_quarter"), all.x = TRUE)
comparison$id[is.na(comparison$id)] <- 0L
comparison <- merge(comparison, expected_fatalities,
                    by = c("locality_id", "source_quarter"), all.x = TRUE)
comparison$deaths_civilians[is.na(comparison$deaths_civilians)] <- 0
stopifnot(nrow(comparison) == nrow(all_panel),
          all(comparison$id == comparison$recorded_events),
          all(comparison$deaths_civilians == comparison$civilian_fatalities))

# Check lag alignment and spell censoring directly against preceding source rows.
for (locality in unique(history$locality_id)) {
  rows <- history[history$locality_id == locality, ]
  rows <- rows[order(rows$source_quarter), ]
  stopifnot(all(diff(rows$source_quarter) == 1L),
            identical(rows$events_lag[-1], head(rows$recorded_events, -1L)))
  for (index in 2:nrow(rows)) {
    prior <- rows$recorded_events[seq_len(index - 1L)]
    zero_positions <- which(prior == 0)
    censored <- length(zero_positions) == 0L
    expected_run <- if (censored) length(prior) else length(prior) - max(zero_positions)
    stopifnot(rows$violent_spell_lag_observed[index] == expected_run,
              rows$violent_spell_left_censored[index] == censored)
    if (censored) stopifnot(is.na(rows$violent_spell_lag[index]))
    else stopifnot(rows$violent_spell_lag[index] == expected_run)
  }
}
cat("Quarterly outcome totals, fatalities, keys, prehistory lags and spell-censoring checks passed.\n")
