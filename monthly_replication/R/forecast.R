forecast_origin <- function(panel, origin) {
  # The target month is excluded from both the training slice and predictors.
  # This slice uses revised histories unless explicitly replaced with a vintage.
  history <- filter(panel, month < origin, !is.na(incidents))
  target <- filter(panel, month == origin)
  if (!nrow(history) || !nrow(target)) return(tibble())
  global_mean <- mean(history$incidents)
  territory_history <- summarise(group_by(history, territory_id),
    history_count = sum(incidents), history_months = n(), .groups = "drop")
  target <- left_join(target, territory_history, by = "territory_id") |>
    mutate(history_mean = (replace_na(history_count, 0L) + 6 * global_mean + 0.1) /
             (replace_na(history_months, 0L) + 6))
  baseline <- function(label, mean_count) {
    transmute(target, territory_id, province, month, observed = incidents, model = label,
              scope = "all", deployment_available = !is.na(presence_lag),
              distribution = "Poisson", mean_count, size = Inf, fit_status = "ok")
  }
  results <- bind_rows(baseline("territory_history", target$history_mean),
    baseline("recent_count", (coalesce(target$incidents_lag, target$history_mean) + target$history_mean) / 2))
  usable <- filter(history, !is.na(incidents_lag), !is.na(battles_lag))
  paired <- filter(usable, !is.na(presence_lag))
  base_formula <- incidents ~ log1p(incidents_lag) + log1p(battles_lag) + province +
    season + month_index + (1 | territory_id)
  for (family_name in c("poisson", "nb2")) {
    family <- if (family_name == "poisson") poisson() else glmmTMB::nbinom2()
    for (spec_name in c("history_all", "history_paired", "deployment_paired")) {
      uses_deployment <- spec_name == "deployment_paired"
      is_paired <- spec_name != "history_all"
      sample <- if (is_paired) paired else usable
      eligible <- !is.na(target$incidents_lag) & !is.na(target$battles_lag) &
        target$territory_id %in% sample$territory_id
      # The paired model domain ends with the deployment source's study window.
      if (is_paired) eligible <- eligible & !is.na(target$presence_lag) & origin <= deployment_end
      if (!any(eligible)) next
      formula <- if (uses_deployment) update(base_formula, . ~ . + presence_lag) else base_formula
      fit <- if (uses_deployment && n_distinct(sample$presence_lag) < 2L) {
        list(fit = NULL, status = "no deployment variation in training")
      } else {
        safe_fit(function() glmmTMB::glmmTMB(formula, family = family, data = sample,
          control = glmmTMB::glmmTMBControl(rank_check = "adjust")))
      }
      if (!is.null(fit$fit) && uses_deployment &&
          !"presence_lag" %in% names(glmmTMB::fixef(fit$fit)$cond)) {
        fit <- list(fit = NULL, status = "deployment term rank deficient")
      }
      predicted <- rep(NA_real_, nrow(target))
      if (!is.null(fit$fit)) {
        predicted[eligible] <- tryCatch(predict(fit$fit, newdata = target[eligible, ], type = "response"),
          error = function(error) rep(NA_real_, sum(eligible)))
      }
      size <- if (family_name == "nb2" && !is.null(fit$fit)) sigma(fit$fit) else Inf
      fit_status <- ifelse(!eligible, "ineligible", ifelse(is.finite(predicted) & predicted > 0,
        "ok", if (fit$status == "ok") "prediction_failed" else fit$status))
      results <- bind_rows(results, transmute(target, territory_id, province, month, observed = incidents,
        model = paste(family_name, spec_name, sep = "_"), scope = if (is_paired) "paired" else "all",
        deployment_available = !is.na(presence_lag), distribution = family$family,
        mean_count = predicted, size = size, fit_status = fit_status))
    }
  }
  results
}

count_scores <- function(observed, mean_count, size) {
  if (!is.finite(observed) || !is.finite(mean_count) || mean_count <= 0 ||
      is.na(size) || size <= 0) return(rep(NA_real_, 6))
  if (is.infinite(size)) {
    probability <- function(k) ppois(k, mean_count)
    quantile_count <- function(p) qpois(p, mean_count)
    log_probability <- dpois(observed, mean_count, log = TRUE)
  } else {
    probability <- function(k) pnbinom(k, size, mu = mean_count)
    quantile_count <- function(p) qnbinom(p, size, mu = mean_count)
    log_probability <- dnbinom(observed, size, mu = mean_count, log = TRUE)
  }
  support <- seq.int(0, max(observed, quantile_count(1 - 1e-9)))
  c(-log_probability, sum((probability(support) - (support >= observed))^2),
    quantile_count(c(.25, .75, .05, .95)))
}

score_forecasts <- function(prediction) {
  scores <- as_tibble(t(vapply(seq_len(nrow(prediction)), function(index) {
    count_scores(prediction$observed[index], prediction$mean_count[index], prediction$size[index])
  }, numeric(6))), .name_repair = function(x) c("log_score", "ranked_probability_score",
    "lower_50", "upper_50", "lower_90", "upper_90"))
  bind_cols(prediction, scores) |>
    mutate(absolute_error = abs(observed - mean_count),
           covered_50 = between(observed, lower_50, upper_50),
           covered_90 = between(observed, lower_90, upper_90),
           width_50 = upper_50 - lower_50, width_90 = upper_90 - lower_90)
}

forecast_summary <- function(data, ...) {
  group_by(data, ...) |>
    summarise(eligible_rows = n(), scored = sum(is.finite(log_score)),
      across(c(log_score, ranked_probability_score, absolute_error, covered_50, covered_90, width_50, width_90),
             ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)), .groups = "drop")
}

score_interval <- function(data) {
  monthly <- arrange(summarise(group_by(data, month), total = sum(difference), rows = n(), .groups = "drop"), month)
  count <- nrow(monthly)
  if (count < 12L) return(c(lower = NA_real_, upper = NA_real_))
  if (!identical(monthly$month, seq(min(monthly$month), max(monthly$month), by = "month"))) {
    return(c(lower = NA_real_, upper = NA_real_))
  }
  set.seed(721)
  block <- 6L
  resamples <- replicate(1999, {
    starts <- sample.int(count, ceiling(count / block), replace = TRUE)
    rows <- unlist(lapply(starts, function(start) (start - 1L + seq_len(block) - 1L) %% count + 1L))[seq_len(count)]
    sum(monthly$total[rows]) / sum(monthly$rows[rows])
  })
  setNames(quantile(resamples, c(.025, .975), names = FALSE), c("lower", "upper"))
}

evaluate_deployment <- function(scored) {
  development <- filter(scored, year(month) <= 2022)
  pick <- function(data) {
    choices <- forecast_summary(data, model) |> filter(scored > 0) |> arrange(log_score, model)
    if (nrow(choices)) choices$model[1] else NA_character_
  }
  baselines <- c("territory_history", "recent_count")
  benchmark <- pick(filter(development, model %in% baselines))
  deployment_model <- pick(filter(development, grepl("_deployment_paired$", model)))
  if (anyNA(c(benchmark, deployment_model))) return("no deployment model qualified during development")
  comparison_models <- c(benchmark, sub("deployment_paired$", "history_paired", deployment_model), deployment_model)
  locked <- scored |>
    filter(year(month) %in% 2023:2024, model %in% comparison_models, is.finite(log_score)) |>
    group_by(month, territory_id) |>
    filter(n_distinct(model) == length(comparison_models)) |>
    ungroup()
  if (!nrow(locked)) return("no successful locked common-row deployment comparison")
  write_result(forecast_summary(locked, model), "forecasts_locked_common_rows")
  wide <- locked |> select(territory_id, month, model, log_score) |>
    pivot_wider(names_from = model, values_from = log_score)
  comparisons <- bind_rows(lapply(comparison_models[1:2], function(comparator) {
    difference <- mutate(wide, difference = .data[[deployment_model]] - .data[[comparator]])
    interval <- score_interval(difference)
    tibble(deployment_model, comparator, rows = nrow(difference), mean_difference = mean(difference$difference),
           lower_95 = interval[["lower"]], upper_95 = interval[["upper"]])
  }))
  write_result(comparisons, "forecast_deployment_comparisons")
  calibration <- forecast_summary(filter(locked, model == deployment_model))$covered_90
  if (all(!is.na(comparisons$upper_95) & comparisons$upper_95 < 0) &&
      dplyr::between(calibration, .85, .95)) {
    "improvement supported in retrospective matched-row evaluation"
  } else {
    "deployment improvement not demonstrated by the locked scoring and calibration criteria"
  }
}

run_forecasts <- function(panel) {
  if (all(is.na(panel$incidents))) return("blocked: ACLED export and receipt required")
  origins <- study_months[study_months >= as.Date("2018-01-01")]
  predictions <- bind_rows(lapply(seq_along(origins), function(index) forecast_origin(panel, origins[index])))
  if (!nrow(predictions)) return("blocked: no forecasts")
  scores <- score_forecasts(predictions) |>
    mutate(split = case_when(year(month) <= 2022 ~ "development", year(month) == 2025 ~ "locked_2025",
                            TRUE ~ "locked_2023_2024"),
           count_range = case_when(observed == 0 ~ "zero", observed < 4 ~ "one_to_three", observed >= 4 ~ "four_plus"))
  write_result(scores, "forecasts")
  write_result(forecast_summary(scores, split, model), "forecast_summary")
  write_result(forecast_summary(scores, split, model, province, count_range), "forecast_calibration")
  write_result(count(scores, split, model, fit_status), "forecast_failures")
  write_result(forecast_summary(filter(scores, year(month) >= 2023, scope == "all"), model),
               "forecast_outcome_history_2023_2025")
  outcome_comparison <- filter(scores, split != "development", scope == "all", is.finite(log_score)) |>
    group_by(month, territory_id) |>
    filter(n_distinct(model) == 4L) |>
    ungroup()
  write_result(forecast_summary(outcome_comparison, split, model), "forecasts_history_common_rows")
  write_result(tibble(deployment_conclusion = evaluate_deployment(scores)), "forecast_conclusion")
  "completed: retrospective revised data; see forecast conclusion for deployment comparison"
}
