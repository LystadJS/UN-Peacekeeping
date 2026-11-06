# Independent checks of saved evaluation artifacts; no refitting or shared helpers.
.libPaths(c(".local_library", .libPaths()))
library(glmmTMB)
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
manifest <- read.csv("data/quarterly_evaluation_input_manifest.csv")
for (index in seq_len(nrow(manifest))) {
  path <- manifest$path[index]
  actual <- digest::digest(readBin(path, "raw", n = file.info(path)$size),
                            algo = "sha256", serialize = FALSE)
  stopifnot(identical(actual, manifest$sha256[index]))
}

# Reconstruct held-out conditional means directly from fixed-effect design
# matrices and saved locality intercepts, without using the forecasting helper.
predictions <- read.csv("outputs/quarterly_prediction/predictions.csv")
fits <- read.csv("data/quarterly_prediction_fits.csv")
stopifnot(nrow(fits) == 40L, all(fits$usable), nrow(predictions) == 360L,
  !anyDuplicated(predictions[c("model", "locality_id", "test_index")]))
for (test_index in 13:32) for (model in c("baseline", "history")) {
  fit <- readRDS(sprintf("outputs/quarterly_prediction/%s_fold_%02d.rds", model, test_index))
  train <- panel[panel$time_index < test_index, ]
  test <- panel[panel$time_index == test_index, ]
  means <- tapply(train$strength_lag, train$locality_id, mean)
  test$strength_between <- unname(means[test$locality_id])
  test$strength_within <- test$strength_lag - test$strength_between
  fixed_formula <- if (model == "baseline") ~ time_index + season + province else
    ~ strength_within + strength_between + time_index + season + province +
      log1p(events_lag) + violent_spell_lag + strength_lag2
  design <- model.matrix(fixed_formula, test)
  coefficients <- fixef(fit)$cond
  intercepts <- ranef(fit)$cond$locality_id
  expected_mean <- exp(as.vector(design[, names(coefficients), drop = FALSE] %*% coefficients) +
    intercepts[match(test$locality_id, rownames(intercepts)), "(Intercept)"])
  rows <- predictions[predictions$model == model & predictions$test_index == test_index, ]
  rows <- rows[match(test$locality_id, rows$locality_id), ]
  stopifnot(nrow(fit$frame) == nrow(train),
    identical(as.numeric(fit$frame$recorded_events), as.numeric(train$recorded_events)),
    max(fit$frame$time_index) == test_index - 1L,
    max(abs(expected_mean - rows$predicted_mean)) < 1e-7,
    max(abs(rows$strength_between - test$strength_between)) < 1e-10)
  if (model == "history") {
    expected_train_mean <- unname(means[train$locality_id])
    stopifnot(max(abs(fit$frame$strength_between - expected_train_mean)) < 1e-10)
  }
  # Use the NB2 probability formula rather than copying dnbinom from the runner.
  y <- rows$recorded_events
  mu <- rows$predicted_mean
  size <- sigma(fit)
  log_probability <- lgamma(y + size) - lgamma(size) - lgamma(y + 1) +
    size * log(size / (size + mu)) + y * log(mu / (size + mu))
  stopifnot(max(abs(log_probability - rows$log_score)) < 1e-8,
    all(rows$covered_95 == (y >= rows$lower_95 & y <= rows$upper_95)),
    all(rows$covered_80 == (y >= rows$lower_80 & y <= rows$upper_80)))
}
summary <- read.csv("data/quarterly_prediction_summary.csv")
for (index in seq_len(nrow(summary))) {
  row <- summary[index, ]
  subset <- predictions[predictions$model == row$model, ]
  if (row$subset == "high_violence") subset <- subset[subset$high_violence, ]
  stopifnot(nrow(subset) == row$predictions,
    abs(mean(subset$log_score) - row$mean_log_score) < 1e-10,
    abs(mean(subset$covered_95) - row$coverage_95) < 1e-10,
    abs(mean(subset$absolute_error) - row$mean_absolute_error) < 1e-10)
}
cat("Primary inputs unchanged; all 40 fitted training samples and 360 saved predictive means/scores independently checked.\n")

# Check the 17 history influence summaries directly against their fitted objects.
influence <- read.csv("data/quarterly_influence_results.csv")
stopifnot(nrow(influence) == 34L, all(influence$usable))
for (index in which(influence$model == "history")) {
  row <- influence[index, ]
  path <- sprintf("outputs/quarterly_diagnostics/influence_history_%s_%s.rds", row$kind, row$omitted)
  fit <- readRDS(path)
  coefficient <- summary(fit)$coefficients$cond["strength_within", ]
  stopifnot(nrow(fit$frame) == row$retained_rows,
    abs(coefficient["Estimate"] - row$estimate) < 1e-10,
    abs(coefficient["Std. Error"] - row$standard_error) < 1e-10,
    abs(coefficient["Estimate"] - qnorm(.975) * coefficient["Std. Error"] - row$lower_95) < 1e-10)
}

# Audit whether equal-area projected centroid distances change the specified
# two-nearest-neighbor graph relative to spherical distances. This is a geometry
# check, not an alternative chosen according to a residual statistic.
centroids <- read.csv("outputs/quarterly_diagnostics/centroids_epsg6933.csv")
points <- sf::st_as_sf(centroids, coords = c("X", "Y"), crs = 6933)
geodesic_distance <- as.matrix(sf::st_distance(sf::st_transform(points, 4326)))
diag(geodesic_distance) <- Inf
geodesic_graph <- matrix(0, nrow(centroids), nrow(centroids))
for (index in seq_len(nrow(centroids))) {
  geodesic_graph[index, order(geodesic_distance[index, ])[1:2]] <- 1
}
geodesic_graph <- (geodesic_graph + t(geodesic_graph)) > 0
saved_weights <- as.matrix(read.csv("outputs/quarterly_diagnostics/spatial_weights.csv", row.names = 1))
graph_difference <- sum(geodesic_graph != saved_weights) / 2
cat("Projected versus spherical two-neighbor graph: ", graph_difference,
    " differing undirected edges.\n", sep = "")
stopifnot(graph_difference == 0)
cat("All history influence summaries agree with saved models; spatial neighbor graph survives distance check.\n")
