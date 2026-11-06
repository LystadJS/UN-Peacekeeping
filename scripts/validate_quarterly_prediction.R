# Expanding-window, one-step prediction of retrospectively recorded violence.
# See the protocol for the selected population, failure rules, and the important
# distinction between plug-in count intervals and full forecast uncertainty.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
library(glmmTMB)

panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
stopifnot(nrow(panel) == 288L, n_distinct(panel$locality_id) == 9L,
  !anyDuplicated(panel[c("locality_id", "time_index")]), all(panel$history_complete),
  all(panel$history_outcome_quarter == panel$source_quarter - 1L))
directory <- "outputs/quarterly_prediction"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
formulas <- list(
  baseline = recorded_events ~ time_index + season + province + (1 | locality_id),
  history = recorded_events ~ strength_within + strength_between + time_index +
    season + province + log1p(events_lag) + violent_spell_lag + strength_lag2 +
    (1 | locality_id))
fit_records <- list()
predictions <- list()
centering_records <- list()

for (test_index in 13:32) {
  train <- panel |> filter(time_index < test_index)
  test <- panel |> filter(time_index == test_index)
  stopifnot(nrow(train) == 9L * (test_index - 1L), nrow(test) == 9L,
    max(train$time_index) < min(test$time_index))
  # Discard descriptive full-period centering and construct training-only means.
  means <- train |> group_by(locality_id) |>
    summarise(training_strength_mean = mean(strength_lag), .groups = "drop")
  center_from_training <- function(rows) {
    rows |> select(-strength_between, -strength_within) |>
      left_join(means, by = "locality_id", relationship = "many-to-one") |>
      mutate(strength_between = training_strength_mean,
             strength_within = strength_lag - training_strength_mean)
  }
  train <- center_from_training(train)
  test <- center_from_training(test)
  centering_records[[length(centering_records) + 1L]] <-
    means |> mutate(test_index = test_index, training_quarters = test_index - 1L)
  high_threshold <- as.numeric(quantile(train$recorded_events, .90, type = 7))

  for (model_name in names(formulas)) {
    warnings_seen <- character()
    started <- proc.time()[[3]]
    fit <- tryCatch(withCallingHandlers(
      glmmTMB(formulas[[model_name]], family = nbinom2(), data = train),
      warning = function(warning) {
        warnings_seen <<- c(warnings_seen, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }), error = function(error) error)
    record <- data.frame(model = model_name, test_index = test_index,
      year = unique(test$year), quarter = unique(test$quarter),
      training_rows = nrow(train), test_rows = nrow(test),
      high_count_threshold = high_threshold, convergence = NA_integer_,
      positive_definite_hessian = FALSE, usable = FALSE, nb2_size = NA_real_,
      seconds = NA_real_, messages = paste(unique(warnings_seen), collapse = " | "))
    if (inherits(fit, "error")) {
      record$messages <- paste(record$messages, conditionMessage(fit), sep = " | ")
    } else {
      saveRDS(fit, file.path(directory, sprintf("%s_fold_%02d.rds", model_name, test_index)))
      record$convergence <- fit$fit$convergence
      record$positive_definite_hessian <- isTRUE(fit$sdr$pdHess)
      record$nb2_size <- sigma(fit)
      coefficients <- tryCatch(summary(fit)$coefficients$cond, error = function(error) NULL)
      predicted_mean <- tryCatch(as.numeric(predict(fit, newdata = test,
        type = "response", re.form = NULL, allow.new.levels = FALSE)),
        error = function(error) error)
      if (inherits(predicted_mean, "error")) {
        record$messages <- paste(record$messages, conditionMessage(predicted_mean), sep = " | ")
      } else {
        record$usable <- record$convergence == 0 && record$positive_definite_hessian &&
          !is.null(coefficients) && all(is.finite(coefficients[, c("Estimate", "Std. Error")])) &&
          all(coefficients[, "Std. Error"] > 0) && is.finite(record$nb2_size) &&
          record$nb2_size > 0 && length(predicted_mean) == nrow(test) &&
          all(is.finite(predicted_mean) & predicted_mean > 0)
        if (isTRUE(record$usable)) {
          predictions[[length(predictions) + 1L]] <- test |>
            transmute(locality_id, locality, test_index = time_index, year, quarter,
              model = model_name, recorded_events, predicted_mean = predicted_mean,
              nb2_size = record$nb2_size, high_count_threshold = high_threshold,
              high_violence = recorded_events > high_threshold,
              strength_between, strength_within,
              log_score = dnbinom(recorded_events, mu = predicted_mean,
                                  size = record$nb2_size, log = TRUE),
              absolute_error = abs(recorded_events - predicted_mean),
              lower_80 = qnbinom(.10, mu = predicted_mean, size = record$nb2_size),
              upper_80 = qnbinom(.90, mu = predicted_mean, size = record$nb2_size),
              lower_95 = qnbinom(.025, mu = predicted_mean, size = record$nb2_size),
              upper_95 = qnbinom(.975, mu = predicted_mean, size = record$nb2_size)) |>
            mutate(covered_80 = recorded_events >= lower_80 & recorded_events <= upper_80,
              covered_95 = recorded_events >= lower_95 & recorded_events <= upper_95,
              width_80 = upper_80 - lower_80, width_95 = upper_95 - lower_95)
        }
      }
    }
    record$seconds <- proc.time()[[3]] - started
    fit_records[[length(fit_records) + 1L]] <- record
  }
  message("Completed outcome quarter ", unique(test$year), " Q", unique(test$quarter))
}
fit_records <- bind_rows(fit_records)
predictions <- bind_rows(predictions)
centering_records <- bind_rows(centering_records)
write.csv(fit_records, file.path(directory, "fit_records.csv"), row.names = FALSE)
write.csv(predictions, file.path(directory, "predictions.csv"), row.names = FALSE)
write.csv(centering_records, file.path(directory, "training_means.csv"), row.names = FALSE)
stopifnot(nrow(fit_records) == 40L, all(is.finite(predictions$log_score)))
capture.output(sessionInfo(), file = file.path(directory, "fit_session_info.txt"))

source("scripts/summarize_quarterly_prediction.R")
