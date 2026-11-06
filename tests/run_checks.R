# Lightweight checks of mechanisms and time alignment, requiring no test framework.
source("R/simulate_panel.R")
source("R/model_specifications.R")
first_run <- simulate_panel(seed = 12, n_localities = 12, n_months = 24)
second_run <- simulate_panel(seed = 12, n_localities = 12, n_months = 24)
stopifnot(identical(first_run, second_run))
panel <- first_run$panel
stopifnot(nrow(panel) == 12 * 24,
          !anyDuplicated(panel[c("locality_id", "month_index")]),
          all(panel$recorded_events <= panel$true_events),
          all(panel$recorded_events >= 0),
          all(panel$recording_probability > 0 & panel$recording_probability <= 1),
          length(unique(panel$true_local_slope)) == 1,
          all(abs(tapply(panel$presence_within, panel$locality_id, mean)) < 1e-12))

for (locality in unique(panel$locality_id)) {
  local_panel <- panel[panel$locality_id == locality, ]
  stopifnot(identical(local_panel$events_lag[-1], head(local_panel$recorded_events, -1)),
            identical(local_panel$presence_lag2[-1], head(local_panel$presence_lag, -1)))
}

stress_run <- simulate_panel(seed = 12, selection = TRUE,
                             differential_recording = TRUE, heterogeneity = TRUE)
stopifnot(sd(stress_run$panel$true_local_slope) > 0,
          sd(stress_run$panel$recording_probability) > 0,
          all(stress_run$panel$recorded_events <= stress_run$panel$true_events),
          length(model_formulas) == 3)
cat("Synthetic reproducibility, count bounds, centering, lag alignment and mechanism checks passed.\n")
