# Conditional-on-design simulation: deployment schedules are empirical; all
# outcomes and latent risks are synthetic. beta is per 1,000 listed personnel.
simulate_quarterly <- function(design, seed, scenario) {
  set.seed(seed)
  data <- design
  ids <- unique(data$locality_id)
  intercepts <- rnorm(length(ids),0,.6)
  data$random_intercept <- intercepts[match(data$locality_id,ids)]
  data$latent_risk <- rnorm(nrow(data))
  beta <- if(scenario=="null") 0 else -.3
  # A correlated latent risk term is a controlled confounding stress test. It
  # does not purport to reproduce the dynamic deployment decision process.
  if(scenario=="latent_confounding") {
    data$latent_risk <- .7*data$strength_within + .5*data$latent_risk
  }
  log_mean <- 1.5 + data$random_intercept + beta*data$strength_within +
    .15*data$strength_between + .005*data$time_index +
    c(0,.1,-.1,.05)[data$quarter]
  if(scenario=="latent_confounding") log_mean <- log_mean + .5*data$latent_risk
  data$true_events <- rnbinom(nrow(data),mu=exp(log_mean),size=2)
  data$q <- if(scenario=="differential_recording") {
    plogis(qlogis(.65)+.8*data$strength_within-.4*data$latent_risk)
  } else rep(.65,nrow(data))
  data$recorded_events <- rbinom(nrow(data),data$true_events,data$q)
  list(data=data,beta=beta,seed=seed,scenario=scenario)
}

fit_quarterly_simulation <- function(simulation) {
  warnings_seen <- character()
  started <- proc.time()[[3]]
  fit <- tryCatch(withCallingHandlers(
    glmmTMB::glmmTMB(recorded_events ~ strength_within + strength_between +
      time_index + season + province + (1|locality_id),
      family=glmmTMB::nbinom2(),data=simulation$data),
    warning=function(w) {warnings_seen <<- c(warnings_seen,conditionMessage(w));invokeRestart("muffleWarning")}),
    error=function(e)e)
  result <- data.frame(scenario=simulation$scenario,seed=simulation$seed,truth=simulation$beta,
    estimate=NA_real_,se=NA_real_,usable=FALSE,convergence=NA_integer_,hessian=FALSE,
    seconds=proc.time()[[3]]-started,message=paste(unique(warnings_seen),collapse=" | "))
  if(inherits(fit,"error")) {result$message<-conditionMessage(fit);return(result)}
  result$convergence <- fit$fit$convergence
  result$hessian <- isTRUE(fit$sdr$pdHess)
  coefficients <- tryCatch(summary(fit)$coefficients$cond,error=function(e)NULL)
  if(!is.null(coefficients)) {
    result$estimate <- coefficients["strength_within","Estimate"]
    result$se <- coefficients["strength_within","Std. Error"]
  }
  result$usable <- result$convergence==0 && result$hessian &&
    is.finite(result$estimate) && is.finite(result$se) && result$se>0
  result
}
