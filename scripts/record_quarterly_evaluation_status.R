# Completion records describe work performed, not universal model adequacy.
.libPaths(c(".local_library", .libPaths()))
diagnostics <- read.csv("data/quarterly_diagnostic_dependence.csv")
influence <- read.csv("data/quarterly_influence_results.csv")
prediction <- read.csv("data/quarterly_prediction_fits.csv")
comparison <- read.csv("data/quarterly_prediction_comparison.csv")
specifications <- read.csv("data/quarterly_sensitivity_specifications.csv")
linear_checks <- read.csv("data/quarterly_sensitivity_reporting_checks.csv")
nonlinear <- read.csv("data/quarterly_sensitivity_logistic_reporting.csv")
joint <- read.csv("data/quarterly_sensitivity_joint_reporting.csv")
stopifnot(nrow(diagnostics) == 8L, nrow(influence) == 34L,
  nrow(prediction) == 40L, nrow(comparison) == 1L,
  nrow(specifications) == 11L, nrow(linear_checks) == 3L,
  nrow(nonlinear) == 21L, nrow(joint) == 9L,
  !anyDuplicated(influence[c("model", "kind", "omitted")]),
  !anyDuplicated(prediction[c("model", "test_index")]))
status <- jsonlite::fromJSON("data/pilot_validation_status.json")
status$empirical_diagnostics_complete <- TRUE
status$influence_checks_complete <- TRUE
status$measurement_sensitivity_complete <- TRUE
status$reporting_sensitivity_complete <- TRUE
status$predictive_validation_complete <- TRUE
status$evaluation_assessment <- "completed_with_caveats"
status$influence_attempted_fits <- nrow(influence)
status$influence_usable_fits <- sum(influence$usable)
status$predictive_attempted_fits <- nrow(prediction)
status$predictive_usable_fits <- sum(prediction$usable)
status$sensitivity_attempted_fits <- nrow(specifications) + nrow(linear_checks) + nrow(nonlinear) + nrow(joint)
status$sensitivity_usable_fits <- sum(specifications$usable) + sum(linear_checks$usable) +
  sum(nonlinear$usable) + sum(joint$usable)
status$history_temporal_residual_warning <- any(diagnostics$outside_reference &
  diagnostics$model == "history" & grepl("^lag_", diagnostics$metric))
status$paired_forecasts <- comparison$paired_predictions
status$mean_history_log_score_gain <- comparison$mean_log_score_difference
status$operational_forecast_validated <- FALSE
status$causal_effect_identified <- FALSE
status$prediction_scope <- "Retrospective selected nine-locality sample; conditional plug-in NB2 count distributions"
status$empirical_status <- paste("Requested residual/influence/sensitivity/predictive evaluation complete;",
  "temporal structure, concentrated predictive gains, uncertain deployment timing and reporting assumptions remain.")
status_json <- jsonlite::toJSON(status, pretty = TRUE, auto_unbox = TRUE,
                              null = "null", digits = 10)
# Binary writing preserves LF line endings for the tracked JSON on Windows.
writeBin(charToRaw(paste0(status_json, "\n")), "data/pilot_validation_status.json")
cat("Evaluation completion recorded with explicit unresolved limitations.\n")
