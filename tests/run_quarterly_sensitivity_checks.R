# Independent arithmetic and source-boundary checks on completed sensitivity runs.
.libPaths(c(".local_library", .libPaths()))
directory <- "outputs/quarterly_sensitivity"
results <- read.csv("data/quarterly_sensitivity_specifications.csv")
primary <- read.csv("data/quarterly_empirical_coefficients.csv")
primary <- primary[primary$model == "history" & primary$term == "strength_within", ]
stopifnot(nrow(primary) == 1L, nrow(results) == 11L)
reporting_fits <- rbind(read.csv("data/quarterly_sensitivity_logistic_reporting.csv")[names(results)],
                       read.csv("data/quarterly_sensitivity_joint_reporting.csv")[names(results)])
stopifnot(nrow(reporting_fits) == 30L, all(reporting_fits$q_min > 0), all(reporting_fits$q_max <= 1))
all_fits <- rbind(results, reporting_fits)
for (index in seq_len(nrow(all_fits))) {
  row <- all_fits[index, ]
  data <- readRDS(file.path(directory, paste0(row$scenario, "_panel.rds")))
  stopifnot(nrow(data) == row$rows, sum(data$recorded_events_original) == row$event_total,
    sum(data$recorded_events) == row$outcome_total)
  if (row$usable) {
    fit <- readRDS(file.path(directory, paste0(row$scenario, "_model.rds")))
    coefficient <- summary(fit)$coefficients$cond["strength_within", ]
    stopifnot(abs(coefficient[1] - row$estimate) < 1e-10,
      abs(coefficient[2] - row$se) < 1e-10,
      abs(row$lower_95 - (row$estimate - qnorm(.975) * row$se)) < 1e-10,
      abs(row$upper_95 - (row$estimate + qnorm(.975) * row$se)) < 1e-10)
  }
}
curve <- read.csv("data/quarterly_sensitivity_reporting_curve.csv")
stopifnot(max(abs(curve$estimate - primary$estimate + log(curve$relative_recording_per_1000))) < 1e-10,
  all(curve$q_min > 0), all(curve$q_max <= 1))
thresholds <- read.csv("data/quarterly_sensitivity_reporting_thresholds.csv")
stopifnot(max(abs(thresholds$relative_recording_per_1000 -
  exp(c(primary$estimate, primary$lower_95, primary$upper_95)))) < 1e-10)
age <- readRDS(file.path(directory, "age_three_panel.rds"))
paired <- readRDS(file.path(directory, "age_three_paired_reference_panel.rds"))
stopifnot(identical(age[c("locality_id", "source_quarter")], paired[c("locality_id", "source_quarter")]),
  max(abs(age$strength_lag - paired$strength_lag)) < 1e-10,
  max(abs(age$strength_lag2 - paired$strength_lag2)) < 1e-10)

# Check changes against original monthly map endpoints, without using the
# implementation's timing_changed flag or its interval loop.
timing <- readRDS(file.path(directory, "monthly_timing_scenarios.rds"))
original <- timing$original
for (scenario in c("early", "midpoint")) {
  alternative <- timing[[scenario]]
  stopifnot(identical(is.na(original$strength), is.na(alternative$strength)))
  changed <- which(is.finite(original$strength) & original$strength != alternative$strength)
  for (index in changed) {
    month <- original$month_index[index]
    previous <- max(timing$map_month_index[timing$map_month_index < month])
    following <- min(timing$map_month_index[timing$map_month_index > month])
    locality <- original$locality_id[index]
    prior_strength <- original$strength[original$locality_id == locality & original$month_index == previous]
    next_strength <- original$strength[original$locality_id == locality & original$month_index == following]
    endpoint_rows <- original[original$locality_id == locality & original$month_index %in% c(previous, following), ]
    stopifnot(length(prior_strength) == 1, length(next_strength) == 1,
      is.finite(prior_strength), is.finite(next_strength), prior_strength > 0, next_strength > 0,
      alternative$strength[index] == next_strength,
      all(endpoint_rows$map_date == endpoint_rows$period),
      !(month %in% timing$map_month_index))
    if (scenario == "midpoint") stopifnot(month >= ceiling((previous + following) / 2))
  }
}
# One flagged exact-place record is restored in each named-assignment scenario.
stopifnot(results$event_total[results$scenario == "boundary_named_irumu"] == 1249L,
  results$event_total[results$scenario == "vido_named_beni"] == 1249L,
  results$event_total[results$scenario == "monthly_analogue"] == 1248L)

# Reconcile alternative event totals from the original audit ledger using base R,
# independently of the sensitivity builder's grouped aggregation helper.
ledger <- read.csv("outputs/week_1/audit_aggregated/event_ledger.csv")
start <- as.Date(ledger$start_date)
end <- as.Date(ledger$end_date)
start_quarter <- as.integer(format(start, "%Y")) * 4L + (as.integer(format(start, "%m")) - 1L) %/% 3L
end_quarter <- as.integer(format(end, "%Y")) * 4L + (as.integer(format(end, "%m")) - 1L) %/% 3L
same_month <- format(start, "%Y-%m") == format(end, "%Y-%m")
for (scenario in c("primary", "quarter_contained_dates", "location_precision_1_or_2",
                    "boundary_named_irumu", "vido_named_beni")) {
  data <- readRDS(file.path(directory, paste0(scenario, "_panel.rds")))
  locality <- ledger$locality_id
  matches <- ledger$match_count
  if (scenario == "boundary_named_irumu") {
    locality[ledger$id == 470483] <- "COMPOSITE_IRUMU"
    matches[ledger$id == 470483] <- 1L
  }
  if (scenario == "vido_named_beni") {
    locality[ledger$id == 451304] <- "COMPOSITE_BENI"
    matches[ledger$id == 451304] <- 1L
  }
  keep <- ledger$type_of_violence == 3 & ledger$valid_dates & ledger$valid_coordinates &
    matches == 1 & locality %in% data$locality_id & ledger$year >= 2016 &
    ledger$where_prec %in% (if (scenario == "location_precision_1_or_2") 1:2 else 1L) &
    (if (scenario == "quarter_contained_dates") start_quarter == end_quarter else same_month)
  counts <- table(paste(locality[keep], start_quarter[keep]))
  observed <- as.integer(counts[match(paste(data$locality_id, data$source_quarter), names(counts))])
  observed[is.na(observed)] <- 0L
  stopifnot(identical(observed, data$recorded_events_original))
}
cat("Sensitivity saved-model arithmetic, q thresholds, paired samples, timing endpoints and event totals passed.\n")
