# Verify saved evaluation independently of the runner's dplyr summaries.
.libPaths(c(".local_library", .libPaths()))
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
directory <- "outputs/quarterly_prediction"
records <- read.csv(file.path(directory, "fit_records.csv"))
predictions <- read.csv(file.path(directory, "predictions.csv"))
means <- read.csv(file.path(directory, "training_means.csv"))
reported <- read.csv("data/quarterly_prediction_summary.csv")
stopifnot(nrow(records) == 40L,
  !anyDuplicated(records[c("model", "test_index")]),
  !anyDuplicated(predictions[c("model", "locality_id", "test_index")]),
  nrow(predictions) == 9L * sum(records$usable),
  setequal(unique(records$test_index), 13:32))

for (test_index in 13:32) {
  train <- panel[panel$time_index < test_index, ]
  test <- panel[panel$time_index == test_index, ]
  previous <- panel[panel$time_index == test_index - 1L, ]
  previous <- previous[match(test$locality_id, previous$locality_id), ]
  stopifnot(all(test$events_lag == previous$recorded_events),
    all(abs(test$strength_lag2 - previous$strength_lag) < 1e-10),
    all(test$history_outcome_quarter < test$source_quarter))
  # Base-R means and stored model frames expose any future-information centering
  # or accidental training/test inclusion, independent of the runner's joins.
  expected <- tapply(train$strength_lag, train$locality_id, mean)
  stored <- means[means$test_index == test_index, ]
  stopifnot(all(abs(stored$training_strength_mean - expected[stored$locality_id]) < 1e-12))
  for (model in c("baseline", "history")) {
    fit <- readRDS(file.path(directory, sprintf("%s_fold_%02d.rds", model, test_index)))
    stopifnot(nrow(fit$frame) == nrow(train),
      identical(as.numeric(fit$frame$recorded_events), as.numeric(train$recorded_events)),
      identical(as.numeric(fit$frame$time_index), as.numeric(train$time_index)),
      max(fit$frame$time_index) < test_index)
    if (model == "history") {
      expected_row_means <- as.numeric(expected[train$locality_id])
      stopifnot(all(abs(fit$frame$strength_between - expected_row_means) < 1e-12),
        all(abs(fit$frame$strength_within - (train$strength_lag - expected_row_means)) < 1e-12))
    }
    rows <- predictions[predictions$model == model & predictions$test_index == test_index, ]
    if (nrow(rows)) {
      stopifnot(all(abs(rows$strength_between - expected[rows$locality_id]) < 1e-12),
        all(abs(rows$high_count_threshold - quantile(train$recorded_events, .9, type = 7)) < 1e-10),
        all(rows$high_violence == (rows$recorded_events > rows$high_count_threshold)))
    }
  }
}

# Independent NB2 probability formula, rather than dnbinom used in the runner.
y <- predictions$recorded_events
mu <- predictions$predicted_mean
size <- predictions$nb2_size
expected_log_score <- lgamma(y + size) - lgamma(size) - lgamma(y + 1) +
  size * log(size / (size + mu)) + y * log(mu / (size + mu))
stopifnot(max(abs(expected_log_score - predictions$log_score)) < 1e-9,
  all(predictions$lower_95 <= predictions$lower_80),
  all(predictions$upper_95 >= predictions$upper_80))
for (level in c(80, 95)) {
  lower <- predictions[[paste0("lower_", level)]]
  upper <- predictions[[paste0("upper_", level)]]
  tail_probability <- (1 - level/100)/2
  # Quantile definition: CDF reaches the target at the returned integer but not
  # at the preceding integer. This checks actual endpoints, not only coverage.
  stopifnot(all(pnbinom(lower, mu = mu, size = size) >= tail_probability - 1e-12),
    all(pnbinom(lower - 1, mu = mu, size = size) < tail_probability + 1e-12),
    all(pnbinom(upper, mu = mu, size = size) >= 1 - tail_probability - 1e-12),
    all(pnbinom(upper - 1, mu = mu, size = size) < 1 - tail_probability + 1e-12),
    all(predictions[[paste0("covered_", level)]] == (y >= lower & y <= upper)))
}
for (index in seq_len(nrow(reported))) {
  row <- reported[index, ]
  rows <- predictions[predictions$model == row$model, ]
  if (row$subset == "high_violence") rows <- rows[rows$high_violence, ]
  stopifnot(nrow(rows) == row$predictions,
    abs(mean(rows$log_score) - row$mean_log_score) < 1e-10,
    abs(mean(abs(rows$recorded_events - rows$predicted_mean)) - row$mean_absolute_error) < 1e-10,
    abs(mean(rows$covered_80) - row$coverage_80) < 1e-10,
    abs(mean(rows$covered_95) - row$coverage_95) < 1e-10)
}
paired <- merge(predictions[predictions$model == "baseline", c("locality_id", "test_index", "log_score")],
  predictions[predictions$model == "history", c("locality_id", "test_index", "log_score")],
  by = c("locality_id", "test_index"), suffixes = c("_baseline", "_history"))
comparison <- read.csv("data/quarterly_prediction_comparison.csv")
stopifnot(nrow(paired) == comparison$paired_predictions,
  abs(mean(paired$log_score_history - paired$log_score_baseline) -
        comparison$mean_log_score_difference) < 1e-10)
locality_summary <- read.csv("data/quarterly_prediction_localities.csv")
omission_summary <- read.csv("data/quarterly_prediction_omission.csv")
for (index in seq_len(nrow(locality_summary))) {
  row <- locality_summary[index, ]
  selected <- paired$locality_id == row$locality_id
  differences <- paired$log_score_history - paired$log_score_baseline
  stopifnot(sum(selected) == row$paired_predictions,
    abs(mean(differences[selected]) - row$mean_log_score_difference) < 1e-10,
    abs(mean(differences[!selected]) - row$mean_difference_omitting_locality) < 1e-10)
}
for (index in seq_len(nrow(omission_summary))) {
  row <- omission_summary[index, ]
  selected <- paired$test_index != row$omitted_test_index
  stopifnot(sum(selected) == row$retained_predictions,
    abs(mean((paired$log_score_history - paired$log_score_baseline)[selected]) -
          row$mean_log_score_difference) < 1e-10)
}
cat("Prediction fold timing, train-only centering, saved frames, lag alignment, NB2 scores, quantiles and summaries verified.\n")
