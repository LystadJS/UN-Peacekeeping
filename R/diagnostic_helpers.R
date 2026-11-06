# Small, explicit helpers for conditional count diagnostics. None refits a model.
randomized_quantile_residual <- function(count, mean, size) {
  lower <- pnbinom(count - 1, mu = mean, size = size)
  upper <- pnbinom(count, mu = mean, size = size)
  probability <- lower + runif(length(count)) * (upper - lower)
  # Bound only numerical endpoints before the normal quantile transformation.
  qnorm(pmin(1 - 1e-12, pmax(1e-12, probability)))
}

lagged_residual_correlation <- function(residual, panel, lag_quarters) {
  previous <- match(paste(panel$locality_id, panel$time_index - lag_quarters),
                    paste(panel$locality_id, panel$time_index))
  available <- !is.na(previous)
  cor(residual[available], residual[previous[available]])
}

quarterly_moran <- function(residual, panel, weights, locality_ids) {
  vapply(sort(unique(panel$time_index)), function(time) {
    rows <- which(panel$time_index == time)
    ordered <- rows[match(locality_ids, panel$locality_id[rows])]
    centered <- residual[ordered] - mean(residual[ordered])
    length(centered) / sum(weights) *
      sum(weights * outer(centered, centered)) / sum(centered^2)
  }, numeric(1))
}

count_diagnostic_statistics <- function(count) {
  c(zero_fraction = mean(count == 0), total_events = sum(count),
    maximum_events = max(count), quantile_95 = unname(quantile(count, .95, type = 8)),
    quarters_at_least_20 = sum(count >= 20))
}

reference_summary <- function(observed, reference) {
  data.frame(observed = observed, reference_median = median(reference),
    reference_lower = unname(quantile(reference, .025)),
    reference_upper = unname(quantile(reference, .975)))
}
