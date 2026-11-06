# Separate, prospectively documented matched null; original runs are untouched.
.libPaths(c(".local_library", .libPaths()))
source("R/dynamic_quarterly_simulation.R")
directory <- "outputs/dynamic_quarterly_null_disjoint"
dir.create(directory, recursive=TRUE, showWarnings=FALSE)
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
records <- list()
for (replication in seq_len(200L)) {
  simulation <- simulate_dynamic_quarterly(design, 20361107L+replication,
    "stationary_initial", effect_override=0)
  simulation$scenario <- "correlated_prehistory_null"
  stopifnot(simulation$beta==0, all(is.finite(simulation$data$true_events)),
    all(simulation$data$recorded_events <= simulation$data$true_events))
  fit <- fit_dynamic_quarterly(simulation)
  fit$replication <- replication
  records[[replication]] <- fit
  if (replication==1L) saveRDS(simulation, file.path(directory, "example.rds"))
  if (replication%%20L==0L) {
    write.csv(do.call(rbind,records), file.path(directory,"fit_records.csv"), row.names=FALSE)
    message("Correlated-prehistory null: ",replication,"/200")
  }
}
records <- do.call(rbind,records)
write.csv(records,file.path(directory,"fit_records.csv"),row.names=FALSE)
valid <- records[records$usable, ]
covered <- abs(valid$estimate)<=1.96*valid$se
wrong <- !covered
summary <- data.frame(scenario="correlated_prehistory_null",estimator="ordinary_history",
  attempts=nrow(records),n_usable=nrow(valid),fit_rate=nrow(valid)/nrow(records),
  bias=mean(valid$estimate),bias_mcse=sd(valid$estimate)/sqrt(nrow(valid)),
  rmse=sqrt(mean(valid$estimate^2)),coverage=mean(covered),
  coverage_mcse=sqrt(mean(covered)*(1-mean(covered))/nrow(valid)),
  success_and_coverage=sum(covered)/nrow(records),directional_error=mean(wrong),
  directional_mcse=sqrt(mean(wrong)*(1-mean(wrong))/nrow(valid)),
  near_zero_intercept_fits=sum(valid$random_intercept_sd<1e-4),
  elapsed_seconds=sum(records$seconds))
summary$gate <- with(summary,fit_rate>=.95 & abs(bias)<=.05 & coverage>=.90 &
  coverage_mcse<=.02 & directional_error<=.10)
write.csv(summary,file.path(directory,"simulation_summary.csv"),row.names=FALSE)
capture.output(sessionInfo(),file=file.path(directory,"session_info.txt"))
print(summary,row.names=FALSE)
