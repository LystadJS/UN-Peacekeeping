association_sample <- function(panel, outcome, exposure, controls = TRUE, maximum_map_age = Inf) {
  panel |>
    filter(month <= deployment_end, is.finite(log_population),
           !is.na(.data[[outcome]]), !is.na(.data[[exposure]]),
           !is.na(map_age_lag), map_age_lag <= maximum_map_age) |>
    mutate(response = .data[[outcome]], exposure = .data[[exposure]],
           prior_outcome = .data[[paste0(outcome, "_lag")]]) |>
    filter(!controls | (!is.na(prior_outcome) & !is.na(battles_lag))) |>
    group_by(territory_id) |>
    mutate(exposure_between = mean(exposure), exposure_within = exposure - exposure_between) |>
    ungroup()
}

fit_association <- function(data, family, controls) {
  if (!nrow(data) || sum(data$response) == 0 || !any(data$exposure_within != 0)) {
    return(list(fit = NULL, status = "no eligible within-territory contrast"))
  }
  specification <- response ~ exposure_within + exposure_between + province +
    factor(month) + offset(log_population) + (1 | territory_id)
  if (controls) specification <- update(specification, . ~ . + log1p(prior_outcome) + log1p(battles_lag))
  safe_fit(function() glmmTMB::glmmTMB(specification, data = data, family = family,
    control = glmmTMB::glmmTMBControl(rank_check = "adjust")))
}

association_result <- function(run, data, label, family, increment = 1) {
  coefficients <- if (is.null(run$fit)) NULL else summary(run$fit)$coefficients$cond
  usable <- "exposure_within" %in% rownames(coefficients)
  status <- if (!is.null(run$fit) && !usable) "exposure term rank deficient" else run$status
  estimate <- if (usable) coefficients["exposure_within", "Estimate"] else NA_real_
  standard_error <- if (usable) coefficients["exposure_within", "Std. Error"] else NA_real_
  tibble(specification = label, family = family, status, rows = nrow(data),
         territories = n_distinct(data$territory_id), source_maps = n_distinct(data$map_lag),
         switching_territories = n_distinct(data$territory_id[data$exposure_within != 0]),
         contrast_increment = increment, estimate_log_rate = estimate * increment,
         rate_ratio = exp(estimate * increment),
         lower_95 = exp((estimate - qnorm(.975) * standard_error) * increment),
         upper_95 = exp((estimate + qnorm(.975) * standard_error) * increment),
         aic = if (is.null(run$fit)) NA_real_ else AIC(run$fit))
}

association_diagnostics <- function(fit, data, territories) {
  set.seed(20261123)
  check_counts <- function(value) c(zeros = sum(value == 0), maximum = max(value),
                                    upper_decile = unname(quantile(value, .9)))
  simulated <- vapply(simulate(fit, nsim = 200), check_counts, numeric(3))
  write_result(tibble(statistic = rownames(simulated), observed = check_counts(data$response),
    lower_95 = apply(simulated, 1, quantile, .025),
    upper_95 = apply(simulated, 1, quantile, .975)), "association_count_diagnostics")
  residual_data <- mutate(data, residual = residuals(fit, type = "pearson"))
  temporal <- arrange(residual_data, territory_id, month) |>
    group_by(territory_id) |>
    mutate(prior = if_else(lag(month) == month %m-% months(1), lag(residual), NA_real_)) |>
    filter(!is.na(prior)) |>
    summarise(pairs = n(), pearson_lag_one = if (n() > 2L && sd(residual) > 0 && sd(prior) > 0)
      cor(residual, prior) else NA_real_, .groups = "drop")
  write_result(temporal, "association_temporal_residuals")
  spatial <- summarise(group_by(residual_data, territory_id), residual = mean(residual), .groups = "drop")
  geometry <- inner_join(territories, spatial, by = "territory_id")
  if (nrow(geometry) > 3L && sd(geometry$residual) > 0) {
    graph <- spdep::poly2nb(geometry, row.names = geometry$territory_id)
    if (any(spdep::card(graph) > 0L)) {
      weights <- spdep::nb2listw(graph, zero.policy = TRUE)
      simulation <- spdep::moran.mc(geometry$residual, weights, nsim = 499, zero.policy = TRUE)
      write_result(tibble(territories = nrow(geometry), moran_i = unname(simulation$statistic),
                          permutation_p_value = simulation$p.value), "association_spatial_residuals")
    }
  }
}

association_simulation <- function(fit, data) {
  # These simulations diagnose the fitted design. The reporting and selection
  # scenarios are hypothetical, so their magnitudes never correct the estimates.
  set.seed(723L)
  coefficient <- glmmTMB::fixef(fit)$cond[["exposure_within"]]
  size <- sigma(fit)
  baseline <- predict(fit, type = "response")
  draws <- as.integer(Sys.getenv("MONUSCO_ASSOC_SIMULATIONS", "50"))
  if (is.na(draws) || draws < 1L) stop("MONUSCO_ASSOC_SIMULATIONS must be a positive integer.")
  scenarios <- c("fitted_reference", "differential_recording", "time_varying_deployment_selection")
  bind_rows(lapply(scenarios, function(scenario) {
    bind_rows(lapply(seq_len(draws), function(simulation_id) {
      mean_count <- baseline
      if (scenario == "time_varying_deployment_selection") {
        # A latent risk term is correlated with deviations in deployment.
        mean_count <- mean_count * exp(.4 * data$exposure_within + rnorm(nrow(data), 0, .2))
      }
      simulated <- rnbinom(nrow(data), mu = mean_count, size = size)
      if (scenario == "differential_recording") {
        simulated <- rbinom(length(simulated), simulated, ifelse(data$exposure == 1L, .7, .9))
      }
      data$response <- simulated
      fitted <- fit_association(data, glmmTMB::nbinom2(), TRUE)
      association_result(fitted, data, scenario, "negative binomial") |>
        transmute(scenario, simulation_id, status, reference_log_rate = coefficient,
                  estimate_log_rate,
                  reference_interval_coverage = lower_95 <= exp(coefficient) & upper_95 >= exp(coefficient))
    }))
  }))
}

run_association <- function(panel, territories) {
  if (all(is.na(panel$incidents))) return("blocked: ACLED export and receipt required")
  if (!any(panel$presence %in% 0L)) return("blocked: no verified map absence")
  if (anyNA(panel$population)) return("blocked: population series incomplete")
  primary <- association_sample(panel, "incidents", "presence_lag")
  write_result(primary |> group_by(province, territory_id) |>
    summarise(months = n(), source_maps = n_distinct(map_lag),
              listed_months = sum(exposure == 1), distinct_exposure = n_distinct(exposure), .groups = "drop"),
    "association_support")
  fit <- fit_association(primary, glmmTMB::nbinom2(), TRUE)
  poisson <- fit_association(primary, poisson(), TRUE)
  primary_results <- association_result(fit, primary, "primary", "negative binomial")
  results <- bind_rows(primary_results, association_result(poisson, primary, "primary", "Poisson"))
  alternatives <- tibble(label = c("narrow_acled", "exact_location_acled", "ucdp_one_sided",
                                   "troop_strength", "map_age_at_most_three", "omit_lagged_conflict"),
                         outcome = c("narrow_incidents", "exact_incidents", "ucdp_incidents",
                                     rep("incidents", 3)),
                         exposure = c(rep("presence_lag", 3), "troop_strength_lag", rep("presence_lag", 2)),
                         controls = c(rep(TRUE, 5), FALSE), max_age = c(rep(Inf, 4), 3, Inf))
  for (index in seq_len(nrow(alternatives))) {
    row <- alternatives[index, ]
    sample <- association_sample(panel, row$outcome, row$exposure, row$controls, row$max_age)
    if (row$label != "omit_lagged_conflict") {
      # Match exposure/outcome variants to rows that would support the primary comparison.
      sample <- semi_join(sample, primary, by = c("territory_id", "month")) |>
        group_by(territory_id) |>
        mutate(exposure_between = mean(exposure), exposure_within = exposure - exposure_between) |>
        ungroup()
    }
    increment <- 1
    if (row$label == "troop_strength") {
      changes <- sample |>
        arrange(territory_id, month) |>
        group_by(territory_id) |>
        mutate(change = abs(exposure - lag(exposure)),
               consecutive = lag(month) == month %m-% months(1)) |>
        ungroup() |>
        filter(consecutive, change > 0) |>
        pull(change)
      if (length(changes)) increment <- median(changes)
    }
    alternate <- fit_association(sample, glmmTMB::nbinom2(), row$controls)
    results <- bind_rows(results, association_result(alternate, sample, row$label, "negative binomial", increment))
    matched <- semi_join(primary, sample, by = c("territory_id", "month")) |>
      group_by(territory_id) |>
      mutate(exposure_between = mean(exposure), exposure_within = exposure - exposure_between) |>
      ungroup()
    matched_fit <- fit_association(matched, glmmTMB::nbinom2(), TRUE)
    results <- bind_rows(results, association_result(matched_fit, matched,
      paste0(row$label, "_matched_primary"), "negative binomial"))
  }
  write_result(results, "association_results")
  if (primary_results$status != "ok" || !is.finite(primary_results$lower_95)) return("blocked: primary fit inadequate")
  saveRDS(fit$fit, file.path(result_dir, "association_primary_fit.rds"))
  observed_baselines <- unname(quantile(predict(fit$fit, type = "response"), c(.25, .5, .75)))
  write_result(tibble(expected_baseline_count = observed_baselines,
                      expected_count_with_rate_ratio = observed_baselines * primary_results$rate_ratio),
               "association_absolute_scale")
  association_diagnostics(fit$fit, primary, territories)
  influence <- bind_rows(lapply(c("territory_id", "map_lag"), function(key) {
    bind_rows(lapply(unique(primary[[key]]), function(value) {
      subset <- filter(primary, .data[[key]] != value) |>
        group_by(territory_id) |>
        mutate(exposure_between = mean(exposure), exposure_within = exposure - exposure_between) |>
        ungroup()
      result <- fit_association(subset, glmmTMB::nbinom2(), TRUE)
      association_result(result, subset, value, "negative binomial") |>
        mutate(omission_dimension = key)
    }))
  }))
  write_result(influence, "association_influence")
  write_result(association_simulation(fit$fit, primary), "association_simulation")
  "completed"
}
