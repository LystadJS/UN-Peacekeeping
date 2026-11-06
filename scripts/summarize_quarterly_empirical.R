# Export aggregate model summaries only; row-level data and fitted objects stay local.
.libPaths(c(".local_library", .libPaths()))
directory <- "outputs/quarterly_pilot/empirical"
models <- c("baseline", "history")
diagnostics <- do.call(rbind, lapply(models, function(model) {
  read.csv(file.path(directory, paste0(model, "_diagnostics.csv")))
}))
coefficients <- do.call(rbind, lapply(models, function(model) {
  result <- read.csv(file.path(directory, paste0(model, "_coefficients.csv")))
  result$model <- model
  result
}))
stopifnot(nrow(diagnostics) == 2L, all(diagnostics$rows == 288L))
write.csv(diagnostics, "data/quarterly_empirical_diagnostics.csv", row.names = FALSE)
write.csv(coefficients, "data/quarterly_empirical_coefficients.csv", row.names = FALSE)
strength <- subset(coefficients, model == "history" & term == "strength_within")
stopifnot(nrow(strength) == 1L)
print(strength)
print(exp(strength[c("estimate", "lower_95", "upper_95")]))
status <- jsonlite::fromJSON("data/pilot_validation_status.json")
status$empirical_models_fitted <- TRUE
status$empirical_fits_numerically_usable <- all(diagnostics$usable)
status$empirical_diagnostics_complete <- FALSE
status$predictive_validation_complete <- FALSE
status$empirical_status <- "Baseline/history fitted under documented measurement assumptions; full diagnostics, influence, sensitivity and predictive validation pending"
jsonlite::write_json(status, "data/pilot_validation_status.json", pretty = TRUE,
                    auto_unbox = TRUE, null = "null")
