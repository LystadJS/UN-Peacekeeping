# Refit only the prespecified common-slope estimator on separately versioned
# measurement scenarios. Original data, fitted models and diagnostics are read
# for comparison and are never overwritten by this script.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(glmmTMB)
source("R/diagnostic_helpers.R")

protocol_path <- "docs/corrected_panel_sensitivity_protocol.md"
stopifnot(file.exists(protocol_path))
output_directory <- "outputs/corrected_panel_sensitivity/models"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
panel_paths <- c(
  original = "outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds",
  supported_corrections = "outputs/corrected_panel_sensitivity/supported_corrections/quarterly_panel_complete_exposure.rds",
  mavivi_plus_150 = "outputs/corrected_panel_sensitivity/mavivi_plus_150/quarterly_panel_complete_exposure.rds")
stopifnot(all(file.exists(panel_paths)))
panels <- lapply(panel_paths, readRDS)
original <- panels$original
stable_fields <- c("locality_id", "locality", "year", "quarter", "source_quarter",
  "time_index", "season", "province", "recorded_events", "events_lag",
  "violent_spell_lag", "core_sample", "history_complete")
for (panel in panels) {
  stopifnot(nrow(panel) == 288L, n_distinct(panel$locality_id) == 9L,
    !anyDuplicated(panel[c("locality_id", "source_quarter")]),
    identical(as.data.frame(panel[stable_fields]), as.data.frame(original[stable_fields])),
    all(panel$core_sample), all(panel$history_complete), is.factor(panel$season))
}

# Exactly the frozen empirical specification and default glmmTMB settings.
# No interactions, initial-condition estimator, varying slopes or model search.
formulas <- list(
  baseline = recorded_events ~ time_index + season + province + (1 | locality_id),
  history = recorded_events ~ strength_within + strength_between + time_index +
    season + province + log1p(events_lag) + violent_spell_lag + strength_lag2 +
    (1 | locality_id))
fixed_formulas <- list(
  baseline = ~ time_index + season + province,
  history = ~ strength_within + strength_between + time_index + season + province +
    log1p(events_lag) + violent_spell_lag + strength_lag2)
saveRDS(formulas, file.path(output_directory, "model_formulas.rds"))
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
  algo = "sha256", serialize = FALSE)
input_paths <- c(unname(panel_paths), protocol_path)
write.csv(data.frame(path = input_paths, sha256 = vapply(input_paths, hash_file, character(1))),
  file.path(output_directory, "input_manifest.csv"), row.names = FALSE)

# A single fitting function retains failed fits and warnings in the audit. Wald
# intervals are conditional model summaries, not causal confidence statements.
fit_one <- function(panel, scenario, model_name, file_label) {
  design <- model.matrix(fixed_formulas[[model_name]], panel)
  record <- data.frame(scenario = scenario, model = model_name, rows = nrow(panel),
    localities = n_distinct(panel$locality_id), event_total = sum(panel$recorded_events),
    design_rank = qr(design)$rank, design_columns = ncol(design),
    convergence = NA_integer_, positive_definite_hessian = FALSE, usable = FALSE,
    estimate = NA_real_, standard_error = NA_real_, lower_95 = NA_real_, upper_95 = NA_real_,
    nb2_dispersion = NA_real_, random_intercept_sd = NA_real_,
    pearson_sum_per_residual_df = NA_real_, pearson_lag_1 = NA_real_,
    pearson_lag_2 = NA_real_, pearson_lag_4 = NA_real_,
    observed_zero_fraction = mean(panel$recorded_events == 0),
    conditional_expected_zero_fraction = NA_real_, seconds = NA_real_, messages = "")
  if (nrow(design) != nrow(panel) || any(!is.finite(design)) ||
      record$design_rank != record$design_columns) {
    record$messages <- "Incomplete or rank-deficient design; fit not attempted"
    return(list(record = record, coefficients = NULL, predictions = NULL))
  }
  warnings_seen <- character()
  started <- proc.time()[[3]]
  fit <- tryCatch(withCallingHandlers(
    glmmTMB(formulas[[model_name]], family = nbinom2(), data = panel),
    warning = function(w) {
      warnings_seen <<- c(warnings_seen, conditionMessage(w))
      invokeRestart("muffleWarning")
    }), error = function(e) e)
  record$seconds <- proc.time()[[3]] - started
  record$messages <- paste(unique(warnings_seen), collapse = " | ")
  if (inherits(fit, "error")) {
    record$messages <- paste(record$messages, conditionMessage(fit), sep = " | ")
    return(list(record = record, coefficients = NULL, predictions = NULL))
  }
  saveRDS(fit, file.path(output_directory, paste0(file_label, "_model.rds")))
  coefficient_matrix <- summary(fit)$coefficients$cond
  coefficients <- data.frame(scenario = scenario, model = model_name,
    term = rownames(coefficient_matrix), estimate = coefficient_matrix[, "Estimate"],
    standard_error = coefficient_matrix[, "Std. Error"], row.names = NULL) |>
    mutate(lower_95 = estimate - qnorm(.975) * standard_error,
      upper_95 = estimate + qnorm(.975) * standard_error)
  record$convergence <- fit$fit$convergence
  record$positive_definite_hessian <- isTRUE(fit$sdr$pdHess)
  record$usable <- record$convergence == 0 && record$positive_definite_hessian &&
    all(is.finite(coefficient_matrix[, 1:2])) && all(coefficient_matrix[, 2] > 0)
  coefficients$fit_usable <- record$usable
  if (model_name == "history") {
    slope <- coefficients[coefficients$term == "strength_within", ]
    record[c("estimate", "standard_error", "lower_95", "upper_95")] <-
      slope[c("estimate", "standard_error", "lower_95", "upper_95")]
  }
  record$nb2_dispersion <- sigma(fit)
  record$random_intercept_sd <- unname(attr(VarCorr(fit)$cond$locality_id, "stddev")[1])
  mean <- as.numeric(predict(fit, type = "response"))
  pearson <- (panel$recorded_events - mean) /
    sqrt(mean + mean^2 / record$nb2_dispersion)
  record$pearson_sum_per_residual_df <- sum(pearson^2) / df.residual(fit)
  record$pearson_lag_1 <- lagged_residual_correlation(pearson, panel, 1L)
  record$pearson_lag_2 <- lagged_residual_correlation(pearson, panel, 2L)
  record$pearson_lag_4 <- lagged_residual_correlation(pearson, panel, 4L)
  record$conditional_expected_zero_fraction <- mean(dnbinom(0, mu = mean,
    size = record$nb2_dispersion))
  predictions <- data.frame(scenario = scenario, model = model_name,
    locality_id = panel$locality_id, locality = panel$locality,
    source_quarter = panel$source_quarter, observed_count = panel$recorded_events,
    conditional_mean = mean, fit_usable = record$usable)
  list(record = record, coefficients = coefficients, predictions = predictions)
}

# Baseline predictors and outcomes are identical across all scenarios, checked
# above; fit it once. Refit the reference history rather than relying solely on
# an old saved coefficient, and compare it to the frozen result afterwards.
fits <- list(fit_one(original, "original", "baseline", "original_baseline"))
for (scenario in names(panels)) fits[[length(fits) + 1L]] <-
  fit_one(panels[[scenario]], scenario, "history", paste0(scenario, "_history"))
diagnostics <- bind_rows(lapply(fits, `[[`, "record"))
coefficients <- bind_rows(lapply(fits, `[[`, "coefficients"))
predictions <- bind_rows(lapply(fits, `[[`, "predictions"))
write.csv(diagnostics, "data/corrected_panel_model_diagnostics.csv", row.names = FALSE)
write.csv(coefficients, "data/corrected_panel_coefficients.csv", row.names = FALSE)
write.csv(predictions, file.path(output_directory, "conditional_predictions.csv"), row.names = FALSE)

# Check every fixed estimate and standard error in both reference fits, not only
# the deployment slope. Baseline agreement also verifies the shared comparison.
for (model_name in names(formulas)) {
  recovered <- coefficients |> filter(scenario == "original", model == model_name)
  frozen_coefficients <- read.csv(file.path("outputs/quarterly_pilot/empirical",
    paste0(model_name, "_coefficients.csv")))
  matched <- match(frozen_coefficients$term, recovered$term)
  stopifnot(nrow(recovered) == nrow(frozen_coefficients), !anyNA(matched),
    max(abs(recovered$estimate[matched] - frozen_coefficients$estimate)) < 1e-6,
    max(abs(recovered$standard_error[matched] - frozen_coefficients$standard_error)) < 1e-6)
}
reference <- filter(coefficients, scenario == "original", model == "history", term == "strength_within")
frozen <- read.csv("outputs/quarterly_pilot/empirical/history_coefficients.csv") |>
  filter(term == "strength_within")
stopifnot(nrow(reference) == 1L, nrow(frozen) == 1L,
  abs(reference$estimate - frozen$estimate) < 1e-6,
  abs(reference$standard_error - frozen$standard_error) < 1e-6)
comparison <- diagnostics |> filter(model == "history") |>
  mutate(reference_estimate = reference$estimate,
    change_from_original = estimate - reference$estimate,
    change_in_original_se = change_from_original / reference$standard_error,
    ratio_per_1000 = exp(estimate), ratio_lower_95 = exp(lower_95),
    ratio_upper_95 = exp(upper_95), interval_contains_zero = lower_95 <= 0 & upper_95 >= 0)
write.csv(comparison, "data/corrected_panel_model_comparison.csv", row.names = FALSE)

# Descriptive fitted-mean changes are not held-out predictive validation. No
# forecast log score or coverage claim is manufactured from these in-sample rows.
reference_predictions <- predictions |> filter(scenario == "original", model == "history") |>
  select(locality_id, source_quarter, original_conditional_mean = conditional_mean)
prediction_comparison <- predictions |> filter(model == "history") |>
  left_join(reference_predictions, by = c("locality_id", "source_quarter"),
    relationship = "many-to-one") |>
  group_by(scenario) |>
  summarise(rows = n(), mean_absolute_change = mean(abs(conditional_mean - original_conditional_mean)),
    maximum_absolute_change = max(abs(conditional_mean - original_conditional_mean)),
    summed_conditional_mean = sum(conditional_mean), .groups = "drop") |>
  mutate(interpretation = "in_sample_conditional_mean_change_not_forecast_validation")
write.csv(prediction_comparison, "data/corrected_panel_fitted_mean_changes.csv", row.names = FALSE)

# Case deletion keeps each corrected full-panel centering and prior histories,
# exactly as in the original influence workflow. This diagnoses sensitivity;
# no locality is removed from the reported primary sample based on these fits.
supported <- panels$supported_corrections
full_supported <- filter(comparison, scenario == "supported_corrections")
deletions <- lapply(sort(unique(supported$locality_id)), function(id) {
  sample <- droplevels(supported[supported$locality_id != id, ])
  fit <- fit_one(sample, "supported_corrections", "history", paste0("omit_", id))
  fit$record |> mutate(omitted = id, kind = "locality",
    change_from_full = estimate - full_supported$estimate,
    change_in_full_se = change_from_full / full_supported$standard_error)
}) |> bind_rows()
original_deletions <- read.csv("data/quarterly_influence_results.csv") |>
  filter(model == "history", kind == "locality") |>
  select(omitted, original_deletion_estimate = estimate,
    original_deletion_lower_95 = lower_95, original_deletion_upper_95 = upper_95)
deletions <- deletions |> left_join(original_deletions, by = "omitted",
  relationship = "one-to-one") |>
  mutate(change_from_original_deletion = estimate - original_deletion_estimate,
    interval_contains_zero = lower_95 <= 0 & upper_95 >= 0)
write.csv(deletions, "data/corrected_panel_locality_influence.csv", row.names = FALSE)
capture.output(sessionInfo(), file = file.path(output_directory, "session_info.txt"))
print(comparison |> select(scenario, usable, estimate, lower_95, upper_95, change_from_original))
print(deletions |> select(omitted, usable, estimate, lower_95, upper_95))
cat("Corrected-panel fits saved separately; no original result or historical availability flag changed.\n")
