# Record validation evidence without automatically authorizing empirical fitting.
# Missing, incomplete, or failed required scenarios leave the gate closed.
.libPaths(c(".local_library", .libPaths()))
status <- jsonlite::fromJSON("data/pilot_validation_status.json")
ordinary_path <- "data/dynamic_quarterly_simulation_summary.csv"
null_path <- "outputs/dynamic_quarterly_null_disjoint/simulation_summary.csv"
status$quarterly_panel_accounting <- "passed"
status$quarterly_panel_rows <- 608L
status$core_panel_rows <- 288L
status$core_recorded_events <- 1248L
status$maximum_map_age_months <- 5L
status$complete_localities_at_three_month_limit <- 0L
status$history_extension_validated <- FALSE
status$history_gate <- "incomplete"
if (file.exists(ordinary_path) && file.exists(null_path)) {
  ordinary <- read.csv(ordinary_path)
  matched_null <- read.csv(null_path)
  required <- ordinary[ordinary$estimator == "ordinary_history" &
    ordinary$scenario %in% c("favorable", "null", "stationary_initial"), ]
  required <- rbind(required, matched_null)
  complete <- nrow(required) == 4L &&
    setequal(required$scenario, c("favorable", "null", "stationary_initial",
                                  "correlated_prehistory_null")) &&
    all(required$attempts == 200L) &&
    all(required$estimator == "ordinary_history") &&
    all(is.finite(as.matrix(required[c("attempts", "n_usable", "fit_rate",
      "bias", "coverage", "coverage_mcse", "directional_error")]))) &&
    all(required$n_usable >= 0 & required$n_usable <= required$attempts) &&
    all(abs(required$fit_rate - required$n_usable / required$attempts) < 1e-10) &&
    all(required$coverage >= 0 & required$coverage <= 1) &&
    all(required$directional_error >= 0 & required$directional_error <= 1) &&
    all(required$coverage_mcse >= 0)
  # Recalculate thresholds instead of trusting a stored gate label.
  passed <- with(required, fit_rate >= .95 & abs(bias) <= .05 &
    coverage >= .90 & coverage_mcse <= .02 &
    (!(scenario %in% c("null", "correlated_prehistory_null")) |
       directional_error <= .10))
  status$dynamic_attempted_fits <- sum(ordinary$attempts) + sum(matched_null$attempts)
  status$dynamic_usable_fits <- sum(ordinary$n_usable) + sum(matched_null$n_usable)
  status$history_extension_validated <- complete && isTRUE(all(passed))
  status$history_gate <- if (!complete) "incomplete" else if (isTRUE(all(passed))) "passed" else "failed"
  status$history_gate_failed_scenarios <- required$scenario[is.na(passed) | !passed]
}
# Never erase the historical fact that empirical fitting occurred, if a later
# validation refresh is run after that separately recorded decision.
status$empirical_models_fitted <- isTRUE(status$empirical_models_fitted)
status$empirical_ready <- FALSE
status$empirical_status <- "Separate documented empirical protocol and measurement decision required; no automatic gate override"
jsonlite::write_json(status, "data/pilot_validation_status.json", pretty = TRUE,
                    auto_unbox = TRUE, null = "null")
print(status)
