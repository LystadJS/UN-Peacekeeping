# Run the prespecified history-model experiment; no empirical fitting occurs.
.libPaths(c(".local_library",.libPaths()))
library(dplyr)
source("R/dynamic_quarterly_simulation.R")
source("tests/run_dynamic_quarterly_checks.R")
directory <- "outputs/dynamic_quarterly"
dir.create(directory,recursive=TRUE,showWarnings=FALSE)
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
scenarios <- c("favorable","null","selection","differential_recording","stationary_initial")
replications <- 200L
results <- list()
for (scenario_index in seq_along(scenarios)) {
  for (replication in seq_len(replications)) {
    simulation <- simulate_dynamic_quarterly(design,
      20261107L+10000L*scenario_index+replication,scenarios[scenario_index])
    ordinary <- fit_dynamic_quarterly(simulation)
    ordinary$replication <- replication
    results[[length(results)+1L]] <- ordinary
    if (scenarios[scenario_index]=="stationary_initial") {
      adjusted <- fit_dynamic_quarterly(simulation,initial_adjustment=TRUE)
      adjusted$replication <- replication
      results[[length(results)+1L]] <- adjusted
    }
    if (replication==1L) saveRDS(simulation,file.path(directory,paste0("example_",scenarios[scenario_index],".rds")))
    if (replication%%20L==0L) {
      write.csv(bind_rows(results),file.path(directory,"fit_records.csv"),row.names=FALSE)
      message(scenarios[scenario_index],": ",replication,"/",replications)
    }
  }
}
results <- bind_rows(results)
write.csv(results,file.path(directory,"fit_records.csv"),row.names=FALSE)
# Base-R summaries avoid overwriting a row-level logical fit indicator inside
# a data-masked summary; failed attempts retain their denominator contribution.
groups <- split(results,interaction(results$scenario,results$estimator,drop=TRUE))
summary <- do.call(rbind,lapply(groups,function(rows) {
  valid <- rows[rows$usable,]
  error <- valid$estimate-valid$truth
  lower <- valid$estimate-1.96*valid$se
  upper <- valid$estimate+1.96*valid$se
  covered <- lower<=valid$truth & upper>=valid$truth
  wrong <- ifelse(valid$truth==0,lower>0|upper<0,ifelse(valid$truth<0,lower>0,upper<0))
  data.frame(scenario=rows$scenario[1],estimator=rows$estimator[1],attempts=nrow(rows),
    n_usable=nrow(valid),fit_rate=nrow(valid)/nrow(rows),bias=mean(error),
    bias_mcse=sd(error)/sqrt(nrow(valid)),rmse=sqrt(mean(error^2)),
    coverage=mean(covered),coverage_mcse=sqrt(mean(covered)*(1-mean(covered))/nrow(valid)),
    success_and_coverage=sum(covered)/nrow(rows),directional_error=mean(wrong),
    directional_mcse=sqrt(mean(wrong)*(1-mean(wrong))/nrow(valid)),
    near_zero_intercept_fits=sum(valid$random_intercept_sd<1e-4),
    elapsed_seconds=sum(rows$seconds))
}))
summary$gate <- with(summary,ifelse(scenario %in% c("favorable","null","stationary_initial"),
  fit_rate>=.95 & abs(bias)<=.05 & coverage>=.90 & coverage_mcse<=.02 &
    (scenario!="null"|directional_error<=.10),NA))
write.csv(summary,file.path(directory,"simulation_summary.csv"),row.names=FALSE)
capture.output(sessionInfo(),file=file.path(directory,"session_info.txt"))
capture.output(warnings(),file=file.path(directory,"warnings.txt"))
print(summary,row.names=FALSE)
