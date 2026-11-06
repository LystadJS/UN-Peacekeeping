# Provisional choices: freeze only after the feasibility audit.
analysis_config <- list(
  start_month = as.Date("2016-01-01"),
  end_month = as.Date("2023-12-01"),
  provinces = c("Nord-Kivu", "Sud-Kivu", "Ituri"),
  boundary_version = "SALB_2018_city_territory_composites",
  deployment_measure = "listed_military_strength_per_1000",
  period = "quarter",
  deployment_lag_quarters = 1L,
  outcome = "recorded_one_sided_events",
  core_simulation_validated = TRUE, # Only the fixed-design quarterly core, not history extensions.
  history_simulation_validated = TRUE, # Limited prespecified dynamic scenarios; see results.
  empirical_ready = TRUE, # Bounded baseline/history fits only; JSON status governs entry point.
  seed = 20261105L
)
