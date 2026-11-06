# Recompute aggregate diagnostics and figures from saved forecasts; no refitting.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
directory <- "outputs/quarterly_prediction"
fit_records <- read.csv(file.path(directory, "fit_records.csv"),
                        colClasses = c(messages = "character"))
predictions <- read.csv(file.path(directory, "predictions.csv"))
summarize_scores <- function(rows) {
  data.frame(predictions = nrow(rows), mean_log_score = mean(rows$log_score),
    mean_absolute_error = mean(rows$absolute_error),
    coverage_80 = mean(rows$covered_80), coverage_95 = mean(rows$covered_95),
    mean_width_80 = mean(rows$width_80), mean_width_95 = mean(rows$width_95))
}
overall <- bind_rows(lapply(c("baseline", "history"), function(model_name) {
  rows <- predictions[predictions$model == model_name, ]
  bind_rows(cbind(model = model_name, subset = "all", summarize_scores(rows)),
    cbind(model = model_name, subset = "high_violence", summarize_scores(rows[rows$high_violence, ])))
}))
fold_summary <- predictions |> group_by(model, test_index, year, quarter) |>
  summarise(predictions = n(), mean_log_score = mean(log_score),
    coverage_80 = mean(covered_80), coverage_95 = mean(covered_95), .groups = "drop")
paired <- predictions |> select(locality_id, test_index, model, log_score) |>
  pivot_wider(names_from = model, values_from = log_score) |>
  filter(is.finite(baseline) & is.finite(history)) |>
  mutate(history_minus_baseline = history - baseline)
paired_folds <- paired |> group_by(test_index) |>
  summarise(paired_predictions = n(), mean_log_score_difference = mean(history_minus_baseline),
    .groups = "drop") |>
  mutate(year = 2016L + (test_index - 1L) %/% 4L, quarter = (test_index - 1L) %% 4L + 1L)
paired_overall <- data.frame(paired_predictions = nrow(paired),
  paired_folds = nrow(paired_folds),
  mean_log_score_difference = mean(paired$history_minus_baseline),
  folds_history_better = sum(paired_folds$mean_log_score_difference > 0))
# Descriptive concentration checks requested after the initial readout. They
# reuse held-out scores, do not refit, and are not independent significance tests.
locality_names <- predictions |> distinct(locality_id, locality)
locality_comparison <- paired |> group_by(locality_id) |>
  summarise(paired_predictions = n(), mean_log_score_difference = mean(history_minus_baseline),
    .groups = "drop") |>
  left_join(locality_names, by = "locality_id", relationship = "one-to-one") |>
  mutate(mean_difference_omitting_locality =
    (sum(paired$history_minus_baseline) - paired_predictions * mean_log_score_difference) /
      (nrow(paired) - paired_predictions)) |>
  arrange(locality)
omission_comparison <- bind_rows(lapply(sort(unique(paired$test_index)), function(omitted) {
  retained <- paired[paired$test_index != omitted, ]
  data.frame(omitted_test_index = omitted,
    omitted_year = 2016L + (omitted - 1L) %/% 4L,
    omitted_quarter = (omitted - 1L) %% 4L + 1L,
    retained_predictions = nrow(retained),
    mean_log_score_difference = mean(retained$history_minus_baseline))
}))
write.csv(locality_comparison, "data/quarterly_prediction_localities.csv", row.names = FALSE)
write.csv(omission_comparison, "data/quarterly_prediction_omission.csv", row.names = FALSE)
write.csv(fit_records, "data/quarterly_prediction_fits.csv", row.names = FALSE)
write.csv(overall, "data/quarterly_prediction_summary.csv", row.names = FALSE)
write.csv(fold_summary, "data/quarterly_prediction_folds.csv", row.names = FALSE)
write.csv(paired_folds, "data/quarterly_prediction_paired_folds.csv", row.names = FALSE)
write.csv(paired_overall, "data/quarterly_prediction_comparison.csv", row.names = FALSE)
capture.output(sessionInfo(), file = file.path(directory, "summary_session_info.txt"))

# Scientific figures: preserve per-quarter comparisons rather than implying
# independence of all 180 forecasts or a validated operational forecast.
score_plot <- ggplot(paired_folds, aes(test_index, mean_log_score_difference)) +
  geom_hline(yintercept = 0, colour = "gray55") +
  geom_line(colour = "#326681") + geom_point(colour = "#326681", size = 2) +
  scale_x_continuous(breaks = c(13, 17, 21, 25, 29, 32),
    labels = c("2019 Q1", "2020 Q1", "2021 Q1", "2022 Q1", "2023 Q1", "2023 Q4")) +
  labs(title = "One-quarter-ahead log-score comparison",
    subtitle = "Nine retrospectively selected localities; training expands from 12 quarters",
    x = "Held-out outcome quarter", y = "Mean log score: history minus baseline",
    caption = "Positive values favor history. Same held-out observations paired within each quarter.\nConditional plug-in NB2 predictions; parameter uncertainty and real-time reporting availability are not represented.") +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0))
coverage_data <- overall |> select(model, subset, predictions, coverage_80, coverage_95) |>
  pivot_longer(starts_with("coverage"), names_to = "interval", values_to = "coverage") |>
  mutate(nominal = ifelse(interval == "coverage_80", .8, .95),
         interval = ifelse(interval == "coverage_80", "80% count interval", "95% count interval"),
         subset_label = paste0(ifelse(subset == "all", "All outcomes", "High-count outcomes"),
                               " (n=", predictions, ")"))
coverage_plot <- ggplot(coverage_data, aes(model, coverage, colour = model)) +
  geom_hline(aes(yintercept = nominal), colour = "gray65", linetype = 2) +
  geom_point(size = 3) + facet_grid(subset_label ~ interval) +
  scale_y_continuous(limits = c(0, 1), labels = function(value) paste0(100 * value, "%")) +
  scale_colour_manual(values = c(baseline = "#326681", history = "#AA6125"), guide = "none") +
  labs(title = "Held-out coverage of plug-in count intervals", x = NULL, y = "Observed coverage",
    caption = "Dashed lines are nominal reference levels; discrete count intervals can over-cover.\nHigh counts exceed the training-only 90th percentile; outcome selection means nominal conditional coverage is not guaranteed.\nIntervals omit parameter/random-effect estimation uncertainty; localities are selected by full-period exposure availability.") +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0))
for (extension in c("png", "pdf")) {
  ggsave(file.path(directory, paste0("rolling_log_scores.", extension)), score_plot,
    width = 10, height = 5.5, dpi = 160, bg = "white")
  ggsave(file.path(directory, paste0("rolling_interval_coverage.", extension)), coverage_plot,
    width = 10, height = 6.5, dpi = 160, bg = "white")
}
print(overall)
print(paired_overall)
