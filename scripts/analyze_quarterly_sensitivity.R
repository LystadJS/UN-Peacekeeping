# Follow-up sensitivity analyses. Read the dated protocol before interpretation.
# Raw data, scenario panels and fitted objects remain local and ignored by Git.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
library(glmmTMB)
directory <- "outputs/quarterly_sensitivity"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
core_ids <- unique(panel$locality_id)
primary_model <- readRDS("outputs/quarterly_pilot/empirical/history_model.rds")
primary_coefficient <- summary(primary_model)$coefficients$cond["strength_within", ]
model_formula <- recorded_events ~ strength_within + strength_between + time_index +
  season + province + log1p(events_lag) + violent_spell_lag + strength_lag2 +
  offset(log_q) + (1 | locality_id)
fixed_formula <- ~ strength_within + strength_between + time_index + season +
  province + log1p(events_lag) + violent_spell_lag + strength_lag2

# Retain numerical failures in the summary rather than dropping inconvenient fits.
fit_scenario <- function(data, scenario, family_group, outcome = "recorded_events") {
  data <- as.data.frame(data)
  if (!"log_q" %in% names(data)) data$log_q <- 0
  data$recorded_events_original <- data$recorded_events
  data$recorded_events <- data[[outcome]]
  design <- model.matrix(fixed_formula, data)
  result <- data.frame(scenario = scenario, family_group = family_group,
    outcome = outcome, rows = nrow(data), localities = length(unique(data$locality_id)),
    event_total = sum(data$recorded_events_original), outcome_total = sum(data$recorded_events),
    rank = qr(design)$rank, columns = ncol(design), estimate = NA_real_, se = NA_real_,
    lower_95 = NA_real_, upper_95 = NA_real_, convergence = NA_integer_,
    positive_hessian = FALSE, random_intercept_sd = NA_real_, usable = FALSE,
    q_min = min(exp(data$log_q)), q_max = max(exp(data$log_q)), messages = "")
  saveRDS(data, file.path(directory, paste0(scenario, "_panel.rds")))
  if (nrow(design) != nrow(data) || any(!is.finite(design)) || result$rank < result$columns) {
    result$messages <- "Incomplete or rank-deficient fixed-effect design; no fit attempted"
    return(result)
  }
  warnings_seen <- character()
  model <- tryCatch(withCallingHandlers(
    glmmTMB(model_formula, family = nbinom2(), data = data),
    warning = function(warning) {
      warnings_seen <<- c(warnings_seen, conditionMessage(warning))
      invokeRestart("muffleWarning")
    }), error = function(error) error)
  result$messages <- paste(unique(warnings_seen), collapse = " | ")
  if (inherits(model, "error")) {
    result$messages <- paste(result$messages, conditionMessage(model), sep = " | ")
    return(result)
  }
  saveRDS(model, file.path(directory, paste0(scenario, "_model.rds")))
  coefficients <- summary(model)$coefficients$cond["strength_within", ]
  result$estimate <- coefficients["Estimate"]
  result$se <- coefficients["Std. Error"]
  result$lower_95 <- result$estimate - qnorm(.975) * result$se
  result$upper_95 <- result$estimate + qnorm(.975) * result$se
  result$convergence <- model$fit$convergence
  result$positive_hessian <- isTRUE(model$sdr$pdHess)
  result$random_intercept_sd <- unname(attr(VarCorr(model)$cond$locality_id, "stddev")[1])
  result$usable <- result$convergence == 0 && result$positive_hessian &&
    is.finite(result$estimate) && is.finite(result$se) && result$se > 0
  result
}

# The log-linear reporting sensitivity is an exact reparameterization. The data
# do not identify lambda; these shifted intervals are conditional on each choice.
lambda <- seq(log(.25), log(4), length.out = 81L)
reporting <- data.frame(lambda = lambda, relative_recording_per_1000 = exp(lambda),
  estimate = unname(primary_coefficient["Estimate"]) - lambda,
  se = unname(primary_coefficient["Std. Error"]))
reporting$lower_95 <- reporting$estimate - qnorm(.975) * reporting$se
reporting$upper_95 <- reporting$estimate + qnorm(.975) * reporting$se
reporting$q_min <- vapply(lambda, function(value) {
  log_q <- log(.8) + value * panel$strength_lag - max(value * panel$strength_lag)
  min(exp(log_q))
}, numeric(1))
reporting$q_max <- .8
reporting_checks <- lapply(c(log(.5), 0, log(2)), function(value) {
  data <- panel
  data$log_q <- log(.8) + value * data$strength_lag - max(value * data$strength_lag)
  fit <- fit_scenario(data, paste0("linear_q_", round(1000 * exp(value))), "reporting_check")
  fit$lambda <- value
  stopifnot(fit$usable, abs(fit$estimate - (primary_coefficient["Estimate"] - value)) < 1e-4,
            abs(fit$se - primary_coefficient["Std. Error"]) < 1e-4)
  fit
}) |> bind_rows()
thresholds <- data.frame(threshold = c("point_changes_sign", "positive_interval_below", "negative_interval_above"),
  relative_recording_per_1000 = exp(c(primary_coefficient["Estimate"],
    primary_coefficient["Estimate"] - qnorm(.975) * primary_coefficient["Std. Error"],
    primary_coefficient["Estimate"] + qnorm(.975) * primary_coefficient["Std. Error"])))
write.csv(reporting, "data/quarterly_sensitivity_reporting_curve.csv", row.names = FALSE)
write.csv(thresholds, "data/quarterly_sensitivity_reporting_thresholds.csv", row.names = FALSE)

# Nonlinear q alters the fitted mean more than an exactly collinear offset does.
# The contrast is defined at within-strength 0 versus 1, not universally constant.
logistic_results <- lapply(seq(-2, 2, length.out = 21L), function(value) {
  data <- panel
  data$log_q <- plogis(qlogis(.65) + value * data$strength_within, log.p = TRUE)
  fit <- fit_scenario(data, paste0("logistic_q_", sprintf("%02d", round((value + 2) * 5))), "nonlinear_reporting")
  fit$logit_slope <- value
  fit$reference_recording_ratio <- plogis(qlogis(.65) + value) / .65
  fit
}) |> bind_rows()
write.csv(logistic_results, "data/quarterly_sensitivity_logistic_reporting.csv", row.names = FALSE)

# Separate dated amendment: a small joint strength/recorded-history grid. The
# proxy is not latent risk and these assumed q values are not empirically fitted.
risk_grid <- expand.grid(strength_recording = c(-1, 0, 1), risk_recording = c(-.5, 0, .5))
risk_center <- mean(log1p(panel$events_lag))
risk_results <- lapply(seq_len(nrow(risk_grid)), function(index) {
  assumption <- risk_grid[index, ]
  data <- panel
  data$log_q <- plogis(qlogis(.65) + assumption$strength_recording * data$strength_within +
    assumption$risk_recording * (log1p(data$events_lag) - risk_center), log.p = TRUE)
  fit <- fit_scenario(data, paste0("joint_reporting_", index), "joint_reporting")
  fit$strength_recording <- assumption$strength_recording
  fit$risk_recording <- assumption$risk_recording
  fit$risk_center <- risk_center
  fit
}) |> bind_rows()
write.csv(risk_results, "data/quarterly_sensitivity_joint_reporting.csv", row.names = FALSE)

# Reconstruct monthly military stocks from audited lineage, excluding FPU.
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv")
source_deployment <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
# Text-coded unknown strengths stay missing; conversion does not infer zero.
lineage$strength <- suppressWarnings(as.numeric(lineage$no.troops)) -
  suppressWarnings(as.numeric(source_deployment$fpu.no[lineage$source_row]))
monthly <- lineage |> filter(locality_id %in% core_ids) |>
  mutate(period = as.Date(period), map_date = as.Date(map_date)) |>
  group_by(locality_id, period) |>
  summarise(strength = if (anyNA(strength)) NA_real_ else sum(strength),
    max_age = max(map_age), n_maps = n_distinct(map_date), map_date = first(map_date), .groups = "drop")
stopifnot(all(monthly$n_maps == 1L), !anyDuplicated(monthly[c("locality_id", "period")]))
monthly <- crossing(locality_id = core_ids,
  period = seq(as.Date("2014-01-01"), as.Date("2023-12-01"), by = "month")) |>
  left_join(monthly, by = c("locality_id", "period"), relationship = "one-to-one") |>
  mutate(month_index = as.integer(format(period, "%Y")) * 12L + as.integer(format(period, "%m")) - 1L,
    source_quarter = month_index %/% 3L)
map_months <- sort(unique(as.Date(lineage$map_date)))
map_month_index <- as.integer(format(map_months, "%Y")) * 12L + as.integer(format(map_months, "%m")) - 1L

# Only shift changes within an interval whose two map observations are positive
# and finite. Months without a listed stock remain unknown even in sensitivity.
timing_monthly <- function(mode) {
  altered <- monthly
  altered$timing_changed <- FALSE
  for (locality in core_ids) {
    rows <- which(altered$locality_id == locality)
    local <- altered[rows, ]
    for (interval in seq_len(length(map_month_index) - 1L)) {
      left <- map_month_index[interval]
      right <- map_month_index[interval + 1L]
      left_row <- match(left, local$month_index)
      right_row <- match(right, local$month_index)
      if (is.na(left_row) || is.na(right_row)) next
      endpoints <- local$strength[c(left_row, right_row)]
      if (any(!is.finite(endpoints)) || any(endpoints <= 0)) next
      # Calendar map dates alone are insufficient: both locality rows must
      # actually trace to those maps, not an older carried-forward source.
      endpoint_rows <- local[c(left_row, right_row), ]
      if (anyNA(endpoint_rows$map_date) ||
          any(endpoint_rows$map_date != endpoint_rows$period)) next
      switch <- if (mode == "early") left + 1L else ceiling((left + right) / 2)
      change <- which(local$month_index >= switch & local$month_index < right &
                        is.finite(local$strength) & local$strength > 0)
      if (length(change)) {
        stopifnot(all(local$month_index[change] > left), all(local$month_index[change] < right))
        local$timing_changed[change] <- local$strength[change] != endpoints[2]
        local$strength[change] <- endpoints[2]
      }
    }
    altered[rows, ] <- local
  }
  stopifnot(identical(is.na(altered$strength), is.na(monthly$strength)))
  altered
}
quarterly_exposure <- function(monthly_data, age_limit = 5L) {
  monthly_data |> mutate(usable = is.finite(strength) & strength >= 0 &
      is.finite(max_age) & max_age >= 0 & max_age <= age_limit) |>
    group_by(locality_id, source_quarter) |>
    summarise(value = if (n() == 3L && all(usable)) mean(strength) / 1000 else NA_real_, .groups = "drop") |>
    arrange(locality_id, source_quarter) |> group_by(locality_id) |>
    mutate(strength_lag = lag(value), strength_lag2 = lag(value, 2L)) |> ungroup()
}
replace_exposure <- function(data, exposure) {
  data |> select(-strength_lag, -strength_lag2, -strength_within, -strength_between) |>
    left_join(exposure |> select(locality_id, source_quarter, strength_lag, strength_lag2),
      by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
    filter(is.finite(strength_lag), is.finite(strength_lag2)) |>
    group_by(locality_id) |> mutate(strength_between = mean(strength_lag),
      strength_within = strength_lag - strength_between) |> ungroup()
}
reference <- replace_exposure(panel, quarterly_exposure(monthly))
stopifnot(nrow(reference) == nrow(panel), max(abs(reference$strength_lag - panel$strength_lag)) < 1e-10)
age_three <- replace_exposure(panel, quarterly_exposure(monthly, 3L))
paired_reference <- panel |> semi_join(age_three, by = c("locality_id", "source_quarter")) |>
  group_by(locality_id) |> mutate(strength_between = mean(strength_lag),
    strength_within = strength_lag - strength_between) |> ungroup()
stopifnot(identical(age_three$locality_id, paired_reference$locality_id),
          identical(age_three$source_quarter, paired_reference$source_quarter),
          max(abs(age_three$strength_lag - paired_reference$strength_lag)) < 1e-10)
early <- timing_monthly("early")
midpoint <- timing_monthly("midpoint")
saveRDS(list(original = monthly, early = early, midpoint = midpoint,
             map_month_index = map_month_index), file.path(directory, "monthly_timing_scenarios.rds"))
timing_summary <- data.frame(scenario = c("early", "midpoint"),
  changed_months = c(sum(early$timing_changed), sum(midpoint$timing_changed)),
  eligible_months = c(sum(is.finite(early$strength)), sum(is.finite(midpoint$strength))))
write.csv(timing_summary, "data/quarterly_sensitivity_timing_changes.csv", row.names = FALSE)

# Event precision scenarios rebuild all history controls, not just current Y.
events <- read.csv("outputs/week_1/audit_aggregated/event_ledger.csv") |>
  mutate(start_date = as.Date(start_date), end_date = as.Date(end_date))
source_events <- readr::read_csv("data/interim/ucdp/GEDEvent_v26_1.csv", show_col_types = FALSE) |>
  select(id, deaths_civilians)
events <- events |> left_join(source_events, by = "id", relationship = "one-to-one") |>
  mutate(source_quarter = (as.integer(format(start_date, "%Y")) * 12L +
      as.integer(format(start_date, "%m")) - 1L) %/% 3L,
    end_quarter = (as.integer(format(end_date, "%Y")) * 12L +
      as.integer(format(end_date, "%m")) - 1L) %/% 3L,
    source_month = as.integer(format(start_date, "%Y")) * 12L + as.integer(format(start_date, "%m")) - 1L,
    same_month = format(start_date, "%Y-%m") == format(end_date, "%Y-%m"))
eligible_events <- function(data = events, precision = 1L, quarter_dates = FALSE) {
  data |> filter(type_of_violence == 3, valid_coordinates, valid_dates, match_count == 1L,
    locality_id %in% core_ids, where_prec %in% precision,
    if (quarter_dates) source_quarter == end_quarter else same_month)
}
make_histories <- function(data) {
  data <- arrange(data, period_index)
  spell <- integer(nrow(data))
  censored <- logical(nrow(data))
  for (index in seq_len(nrow(data))) {
    if (data$recorded_events[index] > 0) {
      spell[index] <- if (index == 1L) 1L else spell[index - 1L] + 1L
      censored[index] <- if (index == 1L) TRUE else censored[index - 1L]
    }
  }
  data$events_lag <- lag(data$recorded_events)
  data$violent_spell_lag <- ifelse(lag(censored), NA_integer_, lag(spell))
  data
}
event_history <- function(selected, monthly_period = FALSE) {
  selected$period_index <- if (monthly_period) selected$source_month else selected$source_quarter
  periods <- if (monthly_period) seq(2014 * 12L, 2023 * 12L + 11L) else seq(2014 * 4L, 2023 * 4L + 3L)
  totals <- selected |> group_by(locality_id, period_index) |>
    summarise(recorded_events = n(), civilian_fatalities = sum(deaths_civilians), .groups = "drop")
  crossing(locality_id = core_ids, period_index = periods) |>
    left_join(totals, by = c("locality_id", "period_index"), relationship = "one-to-one") |>
    mutate(recorded_events = coalesce(recorded_events, 0L), civilian_fatalities = coalesce(civilian_fatalities, 0)) |>
    group_by(locality_id) |> group_modify(~ make_histories(.x)) |> ungroup()
}
replace_outcomes <- function(selected) {
  history <- event_history(selected) |> rename(source_quarter = period_index)
  panel |> select(-recorded_events, -civilian_fatalities, -events_lag, -violent_spell_lag) |>
    left_join(history, by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
    filter(!is.na(events_lag), !is.na(violent_spell_lag))
}
strict_events <- eligible_events()
strict_rebuilt <- replace_outcomes(strict_events)
stopifnot(identical(strict_rebuilt$recorded_events, panel$recorded_events),
  identical(strict_rebuilt$events_lag, panel$events_lag),
  identical(strict_rebuilt$violent_spell_lag, panel$violent_spell_lag))
boundary_events <- events
boundary_events$locality_id[boundary_events$id == 470483] <- "COMPOSITE_IRUMU"
boundary_events$match_count[boundary_events$id == 470483] <- 1L
vido_events <- events
vido_events$locality_id[vido_events$id == 451304] <- "COMPOSITE_BENI"
vido_events$match_count[vido_events$id == 451304] <- 1L

panels <- list(primary = panel, age_three = age_three, age_three_paired_reference = paired_reference,
  early_map_switch = replace_exposure(panel, quarterly_exposure(early)),
  midpoint_map_switch = replace_exposure(panel, quarterly_exposure(midpoint)),
  quarter_contained_dates = replace_outcomes(eligible_events(quarter_dates = TRUE)),
  location_precision_1_or_2 = replace_outcomes(eligible_events(precision = 1:2)),
  boundary_named_irumu = replace_outcomes(eligible_events(boundary_events)),
  vido_named_beni = replace_outcomes(eligible_events(vido_events)))
measurement <- bind_rows(lapply(names(panels), function(name) {
  fit_scenario(panels[[name]], name, "measurement")
}))
stopifnot(abs(measurement$estimate[measurement$scenario == "primary"] - primary_coefficient["Estimate"]) < 1e-5)
measurement <- bind_rows(measurement, fit_scenario(panel, "civilian_fatalities", "secondary_outcome", "civilian_fatalities"))

# Monthly analogue changes the forecast horizon and history definition. It is
# explicitly exploratory and has no monthly simulation-based validity claim.
monthly_panel <- monthly |> arrange(locality_id, month_index) |> group_by(locality_id) |>
  mutate(usable = is.finite(strength) & strength >= 0 & is.finite(max_age) & max_age >= 0 & max_age <= 5,
    stock = ifelse(usable, strength / 1000, NA_real_),
    strength_lag = lag(stock), strength_lag2 = lag(stock, 2L)) |> ungroup() |>
  left_join(event_history(strict_events, monthly_period = TRUE),
    by = c("locality_id", "month_index" = "period_index"), relationship = "one-to-one") |>
  filter(month_index >= 2016L * 12L, is.finite(strength_lag), is.finite(strength_lag2),
    !is.na(events_lag), !is.na(violent_spell_lag)) |>
  group_by(locality_id) |> mutate(strength_between = mean(strength_lag),
    strength_within = strength_lag - strength_between) |> ungroup() |>
  left_join(panel |> distinct(locality_id, province), by = "locality_id", relationship = "many-to-one") |>
  mutate(time_index = (month_index - 2016 * 12 + 1) / 3,
    season = factor(month_index %% 12L + 1L))
measurement <- bind_rows(measurement, fit_scenario(monthly_panel, "monthly_analogue", "different_time_horizon"))
write.csv(measurement, "data/quarterly_sensitivity_specifications.csv", row.names = FALSE)
write.csv(reporting_checks, "data/quarterly_sensitivity_reporting_checks.csv", row.names = FALSE)

# Leave inspectable control checks alongside all source-row scenario panels.
checks <- data.frame(check = c("primary_outcome_reproduced", "primary_history_reproduced",
  "baseline_fit_reproduced", "log_linear_offset_verified", "age_three_paired_sample_identical",
  "timing_does_not_fill_unknowns", "all_reporting_probabilities_valid"), passed = TRUE)
stopifnot(all(reporting$q_min > 0 & reporting$q_max <= 1),
  all(logistic_results$q_min > 0 & logistic_results$q_max <= 1),
  all(risk_results$q_min > 0 & risk_results$q_max <= 1),
  !anyDuplicated(monthly_panel[c("locality_id", "month_index")]))
write.csv(checks, "data/quarterly_sensitivity_checks.csv", row.names = FALSE)
capture.output(sessionInfo(), file = file.path(directory, "session_info.txt"))

curve <- ggplot(reporting, aes(relative_recording_per_1000, estimate)) +
  geom_ribbon(aes(ymin = lower_95, ymax = upper_95), fill = "#93BDCB", alpha = .5) +
  geom_line(colour = "#214F6B", linewidth = .9) + geom_hline(yintercept = 0, linetype = 2) +
  geom_vline(xintercept = 1, colour = "grey50", linetype = 3) +
  scale_x_log10(breaks = c(.25, .5, 1, 2, 4)) +
  labs(title = "Reporting assumptions can change the inferred association",
    subtitle = "Nine localities; 288 quarters; 2016-2023. Exact log-linear offset sensitivity.",
    x = "Assumed recording-probability ratio per 1,000 additional personnel",
    y = "Conditional log count association", caption =
      "Band: model-based 95% interval conditional on each assumed reporting ratio. Curve movement: assumption uncertainty.\nThe coefficient shift is algebraic, not new information about reporting. No confounding correction or causal interpretation.") +
  theme_minimal(base_size = 12) + theme(plot.caption = element_text(hjust = 0))
scenario_labels <- c(primary = "Primary quarterly model", age_three = "Map age at most 3 months",
  age_three_paired_reference = "Original exposure; same restricted rows",
  early_map_switch = "Map-interval early switch", midpoint_map_switch = "Map-interval midpoint switch",
  quarter_contained_dates = "Quarter-contained event dates",
  location_precision_1_or_2 = "Location precision 1 or 2", boundary_named_irumu = "Boundary event assigned to Irumu",
  vido_named_beni = "Vido event assigned to Beni", civilian_fatalities = "Civilian fatalities (secondary)",
  monthly_analogue = "Monthly analogue (different horizon)")
specification <- measurement |> mutate(label = paste0(unname(scenario_labels[scenario]), " (n=", rows, ")"),
  family_group = recode(family_group, measurement = "Measurement", secondary_outcome = "Secondary outcome",
                       different_time_horizon = "Different time horizon"),
  label = factor(label, levels = rev(label)))
spec_plot <- ggplot(specification |> filter(usable), aes(estimate, label)) +
  geom_vline(xintercept = 0, linetype = 2, colour = "grey50") +
  geom_errorbar(aes(xmin = lower_95, xmax = upper_95), orientation = "y", width = .2) +
  geom_point(aes(shape = family_group), size = 2.5, colour = "#214F6B") +
  labs(title = "Conditional associations across measurement specifications",
    subtitle = "Points and 95% Wald intervals; failed fits remain in the accompanying table",
    x = "Log count association per 1,000 personnel", y = NULL, shape = "Specification",
    caption = "Monthly and fatality models change the estimand and have not received matching simulation validation.\nMap timing alternatives use later maps retrospectively; they are not forecasting inputs. Sample changes are shown explicitly.") +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0), legend.position = "bottom")
for (extension in c("png", "pdf")) {
  ggsave(file.path(directory, paste0("reporting_sensitivity.", extension)), curve,
    width = 10, height = 6, dpi = 160, bg = "white")
  ggsave(file.path(directory, paste0("specification_sensitivity.", extension)), spec_plot,
    width = 12, height = 8, dpi = 160, bg = "white")
}
print(measurement[c("scenario", "rows", "event_total", "estimate", "lower_95", "upper_95", "usable")])
print(thresholds)
