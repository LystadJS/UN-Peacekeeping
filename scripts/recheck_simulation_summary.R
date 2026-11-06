# Recompute metrics independently from per-replication records; no model refits.
# A summary must not overwrite the logical `usable` column with its count.
results <- read.csv("outputs/quarterly_pilot/simulation_fits.csv",stringsAsFactors=FALSE)
summary <- do.call(rbind,lapply(split(results,results$scenario),function(rows) {
  valid <- rows[rows$usable,]
  covered <- valid$lower<=valid$truth & valid$upper>=valid$truth
  wrong <- ifelse(valid$truth==0,valid$lower>0|valid$upper<0,
                  ifelse(valid$truth<0,valid$lower>0,valid$upper<0))
  errors <- valid$estimate-valid$truth
  data.frame(scenario=rows$scenario[1],attempts=nrow(rows),n_usable=nrow(valid),
    fit_rate=nrow(valid)/nrow(rows),bias=mean(errors),bias_mcse=sd(errors)/sqrt(nrow(valid)),
    rmse=sqrt(mean(errors^2)),coverage=mean(covered),
    coverage_mcse=sqrt(mean(covered)*(1-mean(covered))/nrow(valid)),
    success_and_coverage=sum(covered)/nrow(rows),directional_error=mean(wrong),
    directional_mcse=sqrt(mean(wrong)*(1-mean(wrong))/nrow(valid)),elapsed_seconds=sum(rows$seconds))
}))
summary$core_gate <- with(summary,ifelse(scenario %in% c("favorable","null"),
  fit_rate>=.95 & abs(bias)<=.05 & coverage>=.90 & coverage_mcse<=.02 &
    (scenario!="null"|directional_error<=.10),NA))
stopifnot(nrow(results)==800,all(summary$fit_rate>=0 & summary$fit_rate<=1),
          all(summary$coverage>=0 & summary$coverage<=1),all(is.finite(summary$bias_mcse)))
write.csv(summary,"outputs/quarterly_pilot/simulation_summary.csv",row.names=FALSE)
write.csv(summary,"data/pilot_simulation_summary.csv",row.names=FALSE)
print(summary)
