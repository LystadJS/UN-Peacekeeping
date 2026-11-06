# Dynamic outcomes with observed-history regressors and explicit initialization.
# Empirical schedules inform exposure only; no empirical violence outcomes enter.
simulate_dynamic_quarterly <- function(design, seed, scenario, effect_override=NULL) {
  set.seed(seed)
  design <- design[order(design$locality_id, design$time_index), ]
  ids <- unique(design$locality_id)
  beta <- if (scenario == "null") 0 else -0.30
  # Used only by the separately prespecified correlated-prehistory null run.
  # Omitting this argument leaves every original scenario and seed unchanged.
  if (!is.null(effect_override)) beta <- effect_override
  intercepts <- rnorm(length(ids), 0, 0.6)
  rows <- vector("list", nrow(design))
  row_index <- 0L
  for (locality_index in seq_along(ids)) {
    local <- design[design$locality_id == ids[locality_index], ]
    base_mean <- mean(local$strength_lag)
    previous_recorded <- 0L
    previous_true <- 0L
    previous_spell <- 0L
    previous_strength <- local$strength_lag[1]
    risk <- 0

    # Prehistory is generated only in the initial-condition stress case. The
    # other scenarios have an explicit fixed, exogenous starting state.
    if (scenario == "stationary_initial") {
      for (preperiod in seq_len(40L)) {
        log_mean <- 1.0 + intercepts[locality_index] + beta*previous_strength +
          (0.15-beta)*base_mean + 0.20*log1p(previous_recorded) +
          0.01*previous_spell + 0.05*previous_strength +
          c(0,0.10,-0.10,0.05)[(preperiod-1L)%%4L+1L]
        previous_true <- rnbinom(1, mu=exp(log_mean), size=2)
        previous_recorded <- rbinom(1, previous_true, 0.65)
        previous_spell <- if (previous_recorded > 0) previous_spell+1L else 0L
      }
    }
    initial_events <- previous_recorded
    initial_spell <- previous_spell
    for (quarter_index in seq_len(nrow(local))) {
      risk <- 0.5*risk + rnorm(1,0,0.5)
      strength <- local$strength_lag[quarter_index]
      if (scenario == "selection") {
        strength <- max(0.01, strength + 0.25*log1p(previous_recorded) + 0.25*risk)
      }
      history_count <- if (scenario == "differential_recording") previous_true else previous_recorded
      log_mean <- 1.0 + intercepts[locality_index] + beta*strength +
        (0.15-beta)*base_mean + 0.20*log1p(history_count) +
        0.01*previous_spell + 0.05*previous_strength +
        0.005*local$time_index[quarter_index] +
        c(0,0.10,-0.10,0.05)[local$quarter[quarter_index]]
      if (scenario == "selection") log_mean <- log_mean + 0.5*risk
      true_events <- rnbinom(1,mu=exp(log_mean),size=2)
      recording_probability <- if (scenario == "differential_recording") {
        plogis(qlogis(0.65)+0.8*(strength-base_mean)-0.4*risk)
      } else 0.65
      recorded_events <- rbinom(1,true_events,recording_probability)
      row <- as.data.frame(local[quarter_index,])
      row$strength_lag <- strength
      row$strength_lag2 <- previous_strength
      row$events_lag <- previous_recorded
      row$violent_spell_lag <- previous_spell
      row$initial_events <- initial_events
      row$initial_spell <- initial_spell
      row$true_events <- true_events
      row$recorded_events <- recorded_events
      row$recording_probability <- recording_probability
      row$latent_risk <- risk
      row$true_random_intercept <- intercepts[locality_index]
      row_index <- row_index+1L
      rows[[row_index]] <- row
      previous_true <- true_events
      previous_recorded <- recorded_events
      previous_spell <- if (recorded_events > 0) previous_spell+1L else 0L
      previous_strength <- strength
    }
  }
  panel <- dplyr::bind_rows(rows) |>
    dplyr::group_by(locality_id) |>
    dplyr::mutate(strength_between=mean(strength_lag),
                  strength_within=strength_lag-strength_between) |>
    dplyr::ungroup()
  list(data=panel, beta=beta, seed=seed, scenario=scenario)
}

fit_dynamic_quarterly <- function(simulation, initial_adjustment=FALSE) {
  model_formula <- recorded_events ~ strength_within + strength_between +
    time_index + season + province + log1p(events_lag) + violent_spell_lag +
    strength_lag2 + (1|locality_id)
  if (initial_adjustment) {
    model_formula <- update(model_formula, . ~ . + log1p(initial_events) + initial_spell)
  }
  warnings_seen <- character()
  started <- proc.time()[[3]]
  fit <- tryCatch(withCallingHandlers(
    glmmTMB::glmmTMB(model_formula, family=glmmTMB::nbinom2(), data=simulation$data),
    warning=function(w) {warnings_seen <<- c(warnings_seen,conditionMessage(w)); invokeRestart("muffleWarning")}),
    error=function(e)e)
  result <- data.frame(scenario=simulation$scenario,
    estimator=if(initial_adjustment) "initial_adjusted" else "ordinary_history",
    seed=simulation$seed, truth=simulation$beta,estimate=NA_real_,se=NA_real_,
    usable=FALSE,convergence=NA_integer_,hessian=FALSE,random_intercept_sd=NA_real_,
    seconds=proc.time()[[3]]-started,message=paste(unique(warnings_seen),collapse=" | "))
  if (inherits(fit,"error")) {result$message<-conditionMessage(fit); return(result)}
  result$convergence <- fit$fit$convergence
  result$hessian <- isTRUE(fit$sdr$pdHess)
  coefficients <- tryCatch(summary(fit)$coefficients$cond,error=function(e)NULL)
  if (!is.null(coefficients)) {
    result$estimate <- coefficients["strength_within","Estimate"]
    result$se <- coefficients["strength_within","Std. Error"]
    result$random_intercept_sd <- unname(attr(glmmTMB::VarCorr(fit)$cond$locality_id,"stddev")[1])
  }
  result$usable <- result$convergence==0 && result$hessian &&
    is.finite(result$estimate) && is.finite(result$se) && result$se>0
  result
}
