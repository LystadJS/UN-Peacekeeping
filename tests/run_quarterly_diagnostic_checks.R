# Independent accounting of saved diagnostic output, without refitting models.
.libPaths(c(".local_library", .libPaths()))
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
counts <- read.csv("data/quarterly_diagnostic_counts.csv")
dependence <- read.csv("data/quarterly_diagnostic_dependence.csv")
influence <- read.csv("data/quarterly_influence_results.csv")
pearson_report <- read.csv("data/quarterly_diagnostic_pearson.csv")
stopifnot(nrow(influence) == 34L, sum(influence$model == "history") == 17L,
  all(influence$retained_rows[influence$kind == "locality"] == 256L),
  all(influence$retained_rows[influence$kind == "year"] == 252L))
for (model in c("baseline", "history")) {
  saved <- readRDS(file.path("outputs/quarterly_diagnostics", paste0(model, "_diagnostic_draws.rds")))
  fit <- readRDS(file.path("outputs/quarterly_pilot/empirical", paste0(model, "_model.rds")))
  pearson_residual <- as.numeric(residuals(fit, type = "pearson"))
  stopifnot(max(abs(pearson_residual - (panel$recorded_events - saved$fitted_mean) /
    sqrt(saved$fitted_mean + saved$fitted_mean^2 / saved$size))) < 1e-10)
  reported <- counts[counts$model == model, ]
  expected <- c(mean(panel$recorded_events == 0), sum(panel$recorded_events),
    max(panel$recorded_events), unname(quantile(panel$recorded_events, .95, type = 8)),
    sum(panel$recorded_events >= 20))
  stopifnot(max(abs(reported$observed - expected)) < 1e-10,
    ncol(saved$simulated_count_metrics) == 2000L,
    ncol(saved$observed_residuals) == 200L,
    all(is.finite(saved$observed_residuals)))
  for (index in seq_len(nrow(reported))) {
    stopifnot(abs(reported$reference_lower[index] - quantile(saved$simulated_count_metrics[index, ], .025)) < 1e-10,
      abs(reported$reference_upper[index] - quantile(saved$simulated_count_metrics[index, ], .975)) < 1e-10)
  }
  # Recreate temporal pairs by splitting and sorting, independent of match keys.
  for (lag in c(1L, 2L, 4L)) {
    leading <- trailing <- numeric()
    pearson_leading <- pearson_trailing <- numeric()
    for (id in unique(panel$locality_id)) {
      rows <- which(panel$locality_id == id)
      rows <- rows[order(panel$time_index[rows])]
      stopifnot(identical(panel$time_index[rows], 1:32))
      residual <- saved$observed_residuals[rows, 1]
      leading <- c(leading, tail(residual, -lag))
      trailing <- c(trailing, head(residual, -lag))
      pearson_leading <- c(pearson_leading, tail(pearson_residual[rows], -lag))
      pearson_trailing <- c(pearson_trailing, head(pearson_residual[rows], -lag))
    }
    stopifnot(length(leading) == 9L * (32L - lag),
      abs(cor(leading, trailing) - saved$observed_dependence[paste0("lag_", lag), 1]) < 1e-12)
    pearson_expected <- pearson_report$correlation[pearson_report$model == model &
      pearson_report$lag_quarters == lag]
    stopifnot(abs(cor(pearson_leading, pearson_trailing) - pearson_expected) < 1e-10)
  }
  # Matrix multiplication separately verifies the Moran double-sum formula.
  weights <- as.matrix(read.csv("outputs/quarterly_diagnostics/spatial_weights.csv", row.names = 1))
  stopifnot(all(diag(weights) == 0), identical(weights, t(weights)), all(rowSums(weights) >= 2))
  moran <- vapply(1:32, function(time) {
    rows <- which(panel$time_index == time)
    rows <- rows[match(rownames(weights), panel$locality_id[rows])]
    centered <- saved$observed_residuals[rows, 1] - mean(saved$observed_residuals[rows, 1])
    as.numeric(length(rows) / sum(weights) * t(centered) %*% weights %*% centered / crossprod(centered))
  }, numeric(1))
  stopifnot(abs(mean(moran) - saved$observed_dependence["mean_quarterly_moran", 1]) < 1e-12)
}
# Check every retained coefficient and interval against the saved fit object.
history <- subset(influence, model == "history")
for (index in seq_len(nrow(history))) {
  row <- history[index, ]
  fit <- readRDS(file.path("outputs/quarterly_diagnostics",
    paste0("influence_history_", row$kind, "_", row$omitted, ".rds")))
  coefficients <- summary(fit)$coefficients$cond["strength_within", ]
  stopifnot(abs(row$estimate - coefficients[1]) < 1e-10,
    abs(row$standard_error - coefficients[2]) < 1e-10,
    abs(row$lower_95 - (coefficients[1] - qnorm(.975) * coefficients[2])) < 1e-10,
    abs(row$upper_95 - (coefficients[1] + qnorm(.975) * coefficients[2])) < 1e-10)
}
cat("Conditional count summaries, temporal pairs, spatial weights/Moran, 34 deletion denominators and 17 history intervals verified.\n")
