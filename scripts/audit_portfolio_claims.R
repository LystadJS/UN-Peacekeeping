# Independent saved-output audit: no refitting and no artifact modification.
# Recalculate portfolio claims from row-level forecasts, retained fits and draws.
.libPaths(c(".local_library", .libPaths()))
library(glmmTMB)
near <- function(actual, expected, tolerance = 1e-8) {
  stopifnot(length(actual) == length(expected), all(is.finite(actual)),
            all(is.finite(expected)), max(abs(actual - expected)) < tolerance)
}
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
stopifnot(nrow(panel) == 288L, length(unique(panel$locality_id)) == 9L,
          sum(panel$recorded_events) == 1248L)
predictions <- read.csv("outputs/quarterly_prediction/predictions.csv")
stopifnot(nrow(predictions) == 360L,
          !anyDuplicated(predictions[c("model", "locality_id", "test_index")]))
near(predictions$log_score, dnbinom(predictions$recorded_events,
     mu = predictions$predicted_mean, size = predictions$nb2_size, log = TRUE))
near(predictions$lower_95, qnbinom(.025, mu = predictions$predicted_mean,
                                  size = predictions$nb2_size))
near(predictions$upper_95, qnbinom(.975, mu = predictions$predicted_mean,
                                  size = predictions$nb2_size))
# Reconstruct every held-out mean from the saved model and training-only means.
for (model in c("baseline", "history")) for (fold in 13:32) {
  test <- panel[panel$time_index == fold, ]
  train <- panel[panel$time_index < fold, ]
  means <- tapply(train$strength_lag, train$locality_id, mean)
  test$strength_between <- unname(means[test$locality_id])
  test$strength_within <- test$strength_lag - test$strength_between
  saved <- predictions[predictions$model == model & predictions$test_index == fold, ]
  saved <- saved[match(test$locality_id, saved$locality_id), ]
  fit <- readRDS(sprintf("outputs/quarterly_prediction/%s_fold_%02d.rds", model, fold))
  near(as.numeric(predict(fit, newdata = test, type = "response")), saved$predicted_mean)
  near(saved$strength_between, test$strength_between)
  stopifnot(nobs(fit) == 9L * (fold - 1L))
}
summary <- read.csv("data/quarterly_prediction_summary.csv")
for (model in c("baseline", "history")) {
  rows <- predictions[predictions$model == model, ]
  row <- summary[summary$model == model & summary$subset == "all", ]
  near(c(mean(rows$log_score), mean(abs(rows$recorded_events - rows$predicted_mean)),
         mean(rows$recorded_events >= rows$lower_95 & rows$recorded_events <= rows$upper_95),
         mean(rows$upper_95 - rows$lower_95)),
       unlist(row[c("mean_log_score", "mean_absolute_error", "coverage_95", "mean_width_95")]))
}
baseline <- predictions[predictions$model == "baseline", ]
history <- predictions[predictions$model == "history", ]
paired <- merge(baseline, history, by = c("locality_id", "test_index"), suffixes = c("_b", "_h"))
gain <- paired$log_score_h - paired$log_score_b
stopifnot(nrow(paired) == 180L, sum(tapply(gain, paired$test_index, mean) > 0) == 14L,
          sum(tapply(gain, paired$locality_id, mean) > 0) == 4L,
          mean(gain[paired$locality_id != "COMPOSITE_IRUMU"]) < 0)
near(mean(gain), read.csv("data/quarterly_prediction_comparison.csv")$mean_log_score_difference)

# Exact reporting transformation and figure source bindings.
fit <- readRDS("outputs/corrected_panel_sensitivity/models/supported_corrections_history_model.rds")
coefficient <- summary(fit)$coefficients$cond["strength_within", ]
reporting <- read.csv("portfolio/figures/figure_3_reporting_data.csv")
near(reporting$estimate, coefficient[1] - log(reporting$relative_recording_per_1000))
near(reporting$lower_95, reporting$estimate - qnorm(.975) * coefficient[2])
near(reporting$upper_95, reporting$estimate + qnorm(.975) * coefficient[2])
# Confirm illustrative recording probabilities are feasible on corrected support.
corrected_panel <- readRDS(paste0("outputs/corrected_panel_sensitivity/",
                                "supported_corrections/quarterly_panel_complete_exposure.rds"))
expected_q_min <- vapply(log(reporting$relative_recording_per_1000), function(lambda) {
  relative_log_q <- lambda * corrected_panel$strength_lag
  min(.8 * exp(relative_log_q - max(relative_log_q)))
}, numeric(1))
near(reporting$q_min, expected_q_min)
stopifnot(all(reporting$q_max == .8), all(reporting$q_min > 0),
          all(reporting$scenario == "supported_corrections"),
          all(reporting$calculation == "algebraic_no_refit"))
simulation <- read.csv("portfolio/figures/figure_2_simulation_data.csv")
records <- rbind(read.csv("outputs/dynamic_quarterly/fit_records.csv"),
                 read.csv("outputs/dynamic_quarterly_null_disjoint/fit_records.csv"))
stopifnot(nrow(records) == 1400L)
for (i in seq_len(nrow(simulation))) {
  row <- simulation[i, ]
  fits <- records[records$scenario == row$scenario & records$estimator == "ordinary_history", ]
  stopifnot(nrow(fits) == 200L, all(fits$usable))
  near(row$mean_estimate, mean(fits$estimate))
  near(row$coverage, mean(abs(fits$estimate - fits$truth) <= 1.96 * fits$se))
  near(c(row$mc_lower, row$mc_upper), mean(fits$estimate) + c(-1, 1) *
         qnorm(.975) * sd(fits$estimate - fits$truth) / sqrt(nrow(fits)))
}
specifications <- read.csv("data/quarterly_sensitivity_specifications.csv")
figure <- read.csv("portfolio/figures/figure_4_empirical_data.csv")
corrected_comparison <- read.csv("data/corrected_panel_model_comparison.csv")
match_rows <- match(figure$scenario, corrected_comparison$scenario)
stopifnot(nrow(figure) == 3L, !anyNA(match_rows),
          setequal(figure$scenario, corrected_comparison$scenario))
near(as.matrix(figure[c("estimate", "lower_95", "upper_95", "rows")]),
     as.matrix(corrected_comparison[match_rows, c("estimate", "lower_95", "upper_95", "rows")]))
# Validate the revised public comparisons directly against retained fitted objects.
# Original measurement sensitivities below remain historical evidence, not refits.
for (i in seq_len(nrow(corrected_comparison))) {
  row <- corrected_comparison[i, ]
  saved_fit <- readRDS(paste0("outputs/corrected_panel_sensitivity/models/",
                            row$scenario, "_history_model.rds"))
  saved_beta <- summary(saved_fit)$coefficients$cond["strength_within", ]
  near(c(row$estimate, row$standard_error), unname(saved_beta[1:2]))
  near(c(row$lower_95, row$upper_95),
       saved_beta[1] + c(-1, 1) * qnorm(.975) * saved_beta[2])
}
stopifnot(nrow(specifications) == 11L, all(specifications$usable),
          all(specifications$lower_95 < 0 & specifications$upper_95 > 0))
for (i in seq_len(nrow(specifications))) {
  model <- readRDS(paste0("outputs/quarterly_sensitivity/", specifications$scenario[i], "_model.rds"))
  beta <- summary(model)$coefficients$cond["strength_within", ]
  near(c(specifications$estimate[i], specifications$se[i]), unname(beta[1:2]))
}
locality_figure <- read.csv("portfolio/figures/figure_5_prediction_data.csv")
near(locality_figure$mean_log_score_difference,
     unname(tapply(gain, paired$locality_id, mean)[locality_figure$locality_id]))

# Inspect retained diagnostic draws rather than merely comparing two summaries.
dependence <- read.csv("data/quarterly_diagnostic_dependence.csv")
for (model in c("baseline", "history")) {
  draws <- readRDS(paste0("outputs/quarterly_diagnostics/", model, "_diagnostic_draws.rds"))
  rows <- dependence[dependence$model == model, ]
  for (i in seq_len(nrow(rows))) {
    statistic <- match(rows$metric[i], rownames(draws$observed_dependence))
    near(rows$observed[i], median(draws$observed_dependence[statistic, ]))
    near(c(rows$reference_lower[i], rows$reference_upper[i]),
         unname(quantile(draws$simulated_dependence[statistic, ], c(.025, .975))))
  }
}
influence <- read.csv("data/quarterly_influence_results.csv")
stopifnot(nrow(influence) == 34L, all(influence$usable))
history_influence <- influence[influence$model == "history", ]
stopifnot(nrow(history_influence) == 17L,
          all(history_influence$lower_95 < 0 & history_influence$upper_95 > 0))
for (i in seq_len(nrow(history_influence))) {
  row <- history_influence[i, ]
  model <- readRDS(paste0("outputs/quarterly_diagnostics/influence_history_",
                         row$kind, "_", row$omitted, ".rds"))
  beta <- summary(model)$coefficients$cond["strength_within", ]
  near(c(row$estimate, row$standard_error), unname(beta[1:2]))
}
cat("Portfolio claim audit passed: saved models, forecasts, simulation, sensitivity, dependence and figure data.\n")
print(c(log_score_gain = mean(gain), omitted_irumu_gain =
          mean(gain[paired$locality_id != "COMPOSITE_IRUMU"])))
