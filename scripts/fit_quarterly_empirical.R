# Conditional empirical fitting entry point. Preparing this script does not
# authorize execution: both explicit status flags must already be true.
.libPaths(c(".local_library", .libPaths()))
status_path <- "data/pilot_validation_status.json"
status <- jsonlite::fromJSON(status_path)
if (!isTRUE(status$history_extension_validated) || !isTRUE(status$empirical_ready)) {
  stop("Empirical gate closed: history_extension_validated AND empirical_ready must both be TRUE.")
}
library(glmmTMB)
panel_path <- "outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds"
panel <- readRDS(panel_path)
stopifnot(nrow(panel) == 288L, length(unique(panel$locality_id)) == 9L,
  !anyDuplicated(panel[c("locality_id", "year", "quarter")]),
  all(panel$core_sample), all(panel$history_complete),
  !any(panel$violent_spell_left_censored), is.factor(panel$season))

# Ordinary history formula matches R/dynamic_quarterly_simulation.R exactly.
# No initial-condition adjustment is silently substituted: its empirical fixed
# matrix is rank deficient, and it is not the ordinary estimator being gated.
formulas <- list(
  baseline = recorded_events ~ time_index + season + province + (1|locality_id),
  history = recorded_events ~ strength_within + strength_between +
    time_index + season + province + log1p(events_lag) + violent_spell_lag +
    strength_lag2 + (1|locality_id))
fixed_formula <- ~ strength_within + strength_between + time_index + season +
  province + log1p(events_lag) + violent_spell_lag + strength_lag2
design <- model.matrix(fixed_formula, panel)
stopifnot(all(is.finite(design)), qr(design)$rank == ncol(design))
output_directory <- "outputs/quarterly_pilot/empirical"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
# Preserve the gate and data fingerprint used by this run. This script never
# rewrites validation status or promotes a fit to a validated forecast.
file.copy(status_path, file.path(output_directory, "gate_at_fit.json"), overwrite = TRUE)
panel_hash <- digest::digest(readBin(panel_path, "raw", n = file.info(panel_path)$size),
                             algo = "sha256", serialize = FALSE)
writeLines(paste(panel_path, panel_hash),
  file.path(output_directory, "panel_sha256.txt"))
saveRDS(formulas, file.path(output_directory, "model_formulas.rds"))
for (model_name in names(formulas)) {
  warnings_seen <- character()
  started <- proc.time()[[3]]
  fit <- tryCatch(withCallingHandlers(
    glmmTMB(formulas[[model_name]], family = nbinom2(), data = panel),
    warning = function(w) {
      warnings_seen <<- c(warnings_seen, conditionMessage(w))
      invokeRestart("muffleWarning")
    }), error = function(e) e)
  diagnostics <- data.frame(model = model_name, rows = nrow(panel),
    convergence = NA_integer_, positive_definite_hessian = FALSE,
    usable = FALSE, nb2_dispersion = NA_real_, pearson_sum_per_residual_df = NA_real_,
    observed_zero_fraction = mean(panel$recorded_events == 0),
    conditional_expected_zero_fraction = NA_real_,
    seconds = proc.time()[[3]] - started,
    messages = paste(unique(warnings_seen), collapse = " | "))
  if (inherits(fit, "error")) {
    diagnostics$messages <- paste(diagnostics$messages, conditionMessage(fit), sep = " | ")
  } else {
    saveRDS(fit, file.path(output_directory, paste0(model_name, "_model.rds")))
    diagnostics$convergence <- fit$fit$convergence
    diagnostics$positive_definite_hessian <- isTRUE(fit$sdr$pdHess)
    coefficient_matrix <- summary(fit)$coefficients$cond
    coefficients <- data.frame(term = rownames(coefficient_matrix),
      estimate = coefficient_matrix[, "Estimate"],
      standard_error = coefficient_matrix[, "Std. Error"], row.names = NULL)
    coefficients$lower_95 <- coefficients$estimate - qnorm(.975) * coefficients$standard_error
    coefficients$upper_95 <- coefficients$estimate + qnorm(.975) * coefficients$standard_error
    # Wald intervals remain conditional model summaries, not causal intervals.
    diagnostics$usable <- diagnostics$convergence == 0 && diagnostics$positive_definite_hessian &&
      all(is.finite(as.matrix(coefficients[-1]))) && all(coefficients$standard_error > 0)
    coefficients$fit_usable <- diagnostics$usable
    write.csv(coefficients, file.path(output_directory, paste0(model_name, "_coefficients.csv")), row.names = FALSE)
    diagnostics$nb2_dispersion <- sigma(fit)
    diagnostics$pearson_sum_per_residual_df <- sum(residuals(fit, type = "pearson")^2) / df.residual(fit)
    conditional_mean <- predict(fit, type = "response")
    diagnostics$conditional_expected_zero_fraction <- mean(
      dnbinom(0, mu = conditional_mean, size = sigma(fit)))
  }
  write.csv(diagnostics, file.path(output_directory, paste0(model_name, "_diagnostics.csv")), row.names = FALSE)
}
capture.output(sessionInfo(), file = file.path(output_directory, "session_info.txt"))
