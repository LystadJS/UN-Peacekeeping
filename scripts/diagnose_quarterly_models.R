# Conditional residual diagnostics and case-deletion influence; no specification search.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(ggplot2)
library(sf)
source("R/diagnostic_helpers.R")
output_directory <- "outputs/quarterly_diagnostics"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
stopifnot(nrow(panel) == 288L, !anyDuplicated(panel[c("locality_id", "time_index")]))
locality_ids <- sort(unique(panel$locality_id))

# Rebuild the exact audited composites; preserve originals and avoid geometry repair.
boundaries <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE) |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm)
crosswalk <- read.csv("config/city_aggregation.csv")
boundaries <- boundaries |> left_join(crosswalk, by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id), locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = "drop") |>
  filter(locality_id %in% locality_ids) |> arrange(locality_id)
stopifnot(identical(boundaries$locality_id, locality_ids), all(st_is_valid(boundaries)))
centroids <- st_centroid(st_geometry(st_transform(boundaries, 6933)))
distances <- as.matrix(st_distance(centroids))
diag(distances) <- Inf
weights <- matrix(0, length(locality_ids), length(locality_ids),
                  dimnames = list(locality_ids, locality_ids))
for (index in seq_along(locality_ids)) weights[index, order(distances[index, ])[1:2]] <- 1
weights <- 1L * ((weights + t(weights)) > 0)
stopifnot(all(diag(weights) == 0), all(rowSums(weights) >= 2), identical(weights, t(weights)))
write.csv(weights, file.path(output_directory, "spatial_weights.csv"))
write.csv(data.frame(locality_id = locality_ids, st_coordinates(centroids)),
          file.path(output_directory, "centroids_epsg6933.csv"), row.names = FALSE)

count_summaries <- list()
dependence_summaries <- list()
locality_summaries <- list()
pearson_summaries <- list()
simulation_replicates <- 2000L
observed_jitters <- 200L
for (model_index in seq_along(c("baseline", "history"))) {
  model_name <- c("baseline", "history")[model_index]
  fit <- readRDS(file.path("outputs/quarterly_pilot/empirical", paste0(model_name, "_model.rds")))
  fitted_mean <- as.numeric(predict(fit, type = "response"))
  size <- as.numeric(sigma(fit))
  stopifnot(length(fitted_mean) == nrow(panel), all(is.finite(fitted_mean)), size > 0)
  set.seed(2026110601L + model_index)
  observed_residuals <- replicate(observed_jitters,
    randomized_quantile_residual(panel$recorded_events, fitted_mean, size))
  residual_statistics <- function(residual) c(
    lag_1 = lagged_residual_correlation(residual, panel, 1L),
    lag_2 = lagged_residual_correlation(residual, panel, 2L),
    lag_4 = lagged_residual_correlation(residual, panel, 4L),
    mean_quarterly_moran = mean(quarterly_moran(residual, panel, weights, locality_ids)))
  observed_dependence <- apply(observed_residuals, 2, residual_statistics)
  # Auxiliary deterministic check added after the initial jitter-based checks;
  # it does not replace their reference envelopes or alter the model.
  pearson <- (panel$recorded_events - fitted_mean) /
    sqrt(fitted_mean + fitted_mean^2 / size)
  pearson_summaries[[model_index]] <- data.frame(model = model_name,
    lag_quarters = c(1L, 2L, 4L), correlation = vapply(c(1L, 2L, 4L), function(lag)
      lagged_residual_correlation(pearson, panel, lag), numeric(1)))
  quarter_moran <- apply(observed_residuals, 2, function(residual)
    quarterly_moran(residual, panel, weights, locality_ids))
  write.csv(data.frame(time_index = 1:32,
    median_moran = apply(quarter_moran, 1, median),
    jitter_lower = apply(quarter_moran, 1, quantile, .025),
    jitter_upper = apply(quarter_moran, 1, quantile, .975)),
    file.path(output_directory, paste0(model_name, "_quarterly_moran.csv")), row.names = FALSE)
  simulated_count_metrics <- matrix(NA_real_, 5, simulation_replicates)
  simulated_dependence <- matrix(NA_real_, 4, simulation_replicates)
  for (replication in seq_len(simulation_replicates)) {
    # Fitted random effects and observed history covariates remain fixed.
    counts <- rnbinom(nrow(panel), mu = fitted_mean, size = size)
    simulated_count_metrics[, replication] <- count_diagnostic_statistics(counts)
    simulated_dependence[, replication] <- residual_statistics(
      randomized_quantile_residual(counts, fitted_mean, size))
  }
  observed_metrics <- count_diagnostic_statistics(panel$recorded_events)
  for (index in seq_along(observed_metrics)) {
    count_summaries[[length(count_summaries) + 1L]] <- cbind(
      data.frame(model = model_name, metric = names(observed_metrics)[index],
                 reference_replicates = simulation_replicates),
      reference_summary(observed_metrics[index], simulated_count_metrics[index, ]))
  }
  for (index in seq_len(nrow(observed_dependence))) {
    dependence_summaries[[length(dependence_summaries) + 1L]] <- cbind(
      data.frame(model = model_name, metric = rownames(observed_dependence)[index],
        observed_jitter_lower = quantile(observed_dependence[index, ], .025),
        observed_jitter_upper = quantile(observed_dependence[index, ], .975),
        reference_replicates = simulation_replicates),
      reference_summary(median(observed_dependence[index, ]), simulated_dependence[index, ]))
  }
  for (id in locality_ids) {
    rows <- which(panel$locality_id == id)
    correlations <- apply(observed_residuals[rows, , drop = FALSE], 2, function(x)
      cor(head(x, -1L), tail(x, -1L)))
    locality_summaries[[length(locality_summaries) + 1L]] <- data.frame(
      model = model_name, locality_id = id, locality = panel$locality[rows[1]],
      median_lag_1 = median(correlations), jitter_lower = quantile(correlations, .025),
      jitter_upper = quantile(correlations, .975), quarters = length(rows))
  }
  saveRDS(list(model = model_name, fitted_mean = fitted_mean, size = size,
    observed_residuals = observed_residuals, observed_dependence = observed_dependence,
    simulated_count_metrics = simulated_count_metrics, simulated_dependence = simulated_dependence,
    panel_keys = panel[c("locality_id", "time_index")]),
    file.path(output_directory, paste0(model_name, "_diagnostic_draws.rds")))
}
count_summary <- bind_rows(count_summaries) |> mutate(
  outside_reference = observed < reference_lower | observed > reference_upper)
dependence_summary <- bind_rows(dependence_summaries) |> mutate(
  outside_reference = observed < reference_lower | observed > reference_upper)
write.csv(count_summary, "data/quarterly_diagnostic_counts.csv", row.names = FALSE)
write.csv(dependence_summary, "data/quarterly_diagnostic_dependence.csv", row.names = FALSE)
write.csv(bind_rows(locality_summaries), "data/quarterly_diagnostic_locality_acf.csv", row.names = FALSE)
write.csv(bind_rows(pearson_summaries), "data/quarterly_diagnostic_pearson.csv", row.names = FALSE)

# Case deletion keeps the original strength centering and prior histories.
# Changing those simultaneously would confound data influence with a redefinition.
formulas <- readRDS("outputs/quarterly_pilot/empirical/model_formulas.rds")
full_history <- read.csv("outputs/quarterly_pilot/empirical/history_coefficients.csv")
full_slope <- subset(full_history, term == "strength_within")
deletions <- bind_rows(
  data.frame(kind = "locality", omitted = locality_ids),
  data.frame(kind = "year", omitted = as.character(sort(unique(panel$year)))))
influence_records <- list()
for (model_name in names(formulas)) for (index in seq_len(nrow(deletions))) {
  deletion <- deletions[index, ]
  retained <- if (deletion$kind == "locality") panel$locality_id != deletion$omitted else
    panel$year != as.integer(deletion$omitted)
  sample <- droplevels(panel[retained, ])
  warning_messages <- character()
  started <- proc.time()[[3]]
  fitted <- tryCatch(withCallingHandlers(
    glmmTMB::glmmTMB(formulas[[model_name]], family = glmmTMB::nbinom2(), data = sample),
    warning = function(w) {warning_messages <<- c(warning_messages, conditionMessage(w));
      invokeRestart("muffleWarning")}), error = function(error) error)
  record <- data.frame(model = model_name, kind = deletion$kind, omitted = deletion$omitted,
    retained_rows = nrow(sample), retained_localities = length(unique(sample$locality_id)),
    usable = FALSE, convergence = NA_integer_, positive_hessian = FALSE,
    estimate = NA_real_, standard_error = NA_real_, lower_95 = NA_real_, upper_95 = NA_real_,
    change_from_full = NA_real_, change_in_full_se = NA_real_, seconds = proc.time()[[3]] - started,
    messages = paste(unique(warning_messages), collapse = " | "))
  if (inherits(fitted, "error")) record$messages <- paste(record$messages, conditionMessage(fitted)) else {
    coefficients <- summary(fitted)$coefficients$cond
    record$convergence <- fitted$fit$convergence
    record$positive_hessian <- isTRUE(fitted$sdr$pdHess)
    record$usable <- record$convergence == 0 && record$positive_hessian &&
      all(is.finite(coefficients[, 1:2])) && all(coefficients[, 2] > 0)
    if (model_name == "history") {
      record$estimate <- coefficients["strength_within", "Estimate"]
      record$standard_error <- coefficients["strength_within", "Std. Error"]
      record$lower_95 <- record$estimate - qnorm(.975) * record$standard_error
      record$upper_95 <- record$estimate + qnorm(.975) * record$standard_error
      record$change_from_full <- record$estimate - full_slope$estimate
      record$change_in_full_se <- record$change_from_full / full_slope$standard_error
    }
    saveRDS(fitted, file.path(output_directory,
      paste0("influence_", model_name, "_", deletion$kind, "_", deletion$omitted, ".rds")))
  }
  influence_records[[length(influence_records) + 1L]] <- record
}
influence <- bind_rows(influence_records)
write.csv(influence, "data/quarterly_influence_results.csv", row.names = FALSE)

# Display reference envelopes as conditional checks, not parameter intervals.
dependence_plot <- ggplot(dependence_summary, aes(model, observed)) +
  geom_linerange(aes(ymin = reference_lower, ymax = reference_upper), colour = "#b0b0b0", linewidth = 5) +
  geom_linerange(aes(ymin = observed_jitter_lower, ymax = observed_jitter_upper), colour = "#326681", linewidth = .7) +
  geom_point(colour = "#214F6B", size = 2.5) + facet_wrap(~metric, scales = "free_y", ncol = 2,
    labeller = as_labeller(c(lag_1 = "Lag 1 quarter", lag_2 = "Lag 2 quarters",
      lag_4 = "Lag 4 quarters", mean_quarterly_moran = "Mean quarterly Moran statistic"))) +
  labs(title = "Quarterly residual dependence", subtitle = "Nine localities; 288 quarters; 2016-2023",
    x = NULL, y = "Residual statistic",
    caption = "Points: median over 200 residual randomizations; blue intervals: randomization range (2.5%-97.5%).\nGray bands: 95% reference envelopes from 2,000 fixed-parameter conditional count replicates.\nThese are descriptive checks, not calibrated hypothesis tests; mean Moran statistic uses the prespecified two-nearest-centroid network.") +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0))
history_influence <- influence |> filter(model == "history") |> left_join(
  panel |> distinct(locality_id, locality), by = c("omitted" = "locality_id")) |>
  mutate(label = ifelse(kind == "locality", locality, omitted), label = factor(label, levels = rev(unique(label))))
influence_plot <- ggplot(history_influence, aes(estimate, label)) +
  geom_vline(xintercept = 0, colour = "gray60", linetype = 2) +
  geom_vline(xintercept = full_slope$estimate, colour = "#b05d30", linetype = 3) +
  geom_errorbar(aes(xmin = lower_95, xmax = upper_95), orientation = "y", width = .2, colour = "#326681") +
  geom_point(aes(shape = usable), colour = "#214F6B", size = 2) +
  facet_grid(kind ~ ., scales = "free_y", space = "free_y") +
  labs(title = "Common-strength association after case deletion", x = "Log-count coefficient per 1,000 listed personnel", y = NULL,
    caption = "One locality or year omitted per fit; original exposure centering and prior histories retained.\nIntervals are model-based 95% Wald intervals; dotted orange line is the full-data estimate.\nCase deletion diagnoses sensitivity, not an alternative selected primary sample.") +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0), legend.position = "bottom")
for (extension in c("png", "pdf")) {
  ggsave(file.path(output_directory, paste0("residual_dependence.", extension)), dependence_plot, width = 11, height = 8, dpi = 160)
  ggsave(file.path(output_directory, paste0("case_deletion.", extension)), influence_plot, width = 11, height = 10, dpi = 160)
}
capture.output(sessionInfo(), file = file.path(output_directory, "session_info.txt"))
print(count_summary)
print(dependence_summary)
print(influence |> filter(model == "history") |> select(kind, omitted, usable, estimate, lower_95, upper_95, change_in_full_se))
