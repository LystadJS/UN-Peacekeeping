# Provisional choices: freeze only after the feasibility audit.
analysis_config <- list(
  start_month = as.Date("2015-01-01"),
  end_month = as.Date("2023-12-01"),
  provinces = NULL, # Define eastern DRC explicitly before filtering.
  boundary_version = NULL, # Select stable geography and retain crosswalks.
  deployment_measure = "binary_presence", # Strength is a sensitivity candidate.
  deployment_lag_months = 1L,
  outcome = "recorded_one_sided_events",
  empirical_ready = FALSE,
  seed = 20261105L
)
