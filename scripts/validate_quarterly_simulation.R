.libPaths(c(".local_library",.libPaths()))
library(dplyr)
library(ggplot2)
source("R/quarterly_simulation.R")
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
stopifnot(n_distinct(design$locality_id)==9,nrow(design)==288,
          all(is.finite(design$strength_within)))
scenarios <- c("favorable","null","differential_recording","latent_confounding")
replications <- 200L
results <- list()
for(scenario_index in seq_along(scenarios)) {
  for(replication in seq_len(replications)) {
    seed <- 20261106L + 10000L*scenario_index + replication
    simulation <- simulate_quarterly(design,seed,scenarios[scenario_index])
    stopifnot(all(simulation$data$recorded_events<=simulation$data$true_events))
    result <- fit_quarterly_simulation(simulation)
    result$replication <- replication
    results[[length(results)+1L]] <- result
    if(replication==1L) saveRDS(simulation,paste0("outputs/quarterly_pilot/synthetic_example_",scenarios[scenario_index],".rds"))
    # Checkpoint all attempted fits, including failures, every twenty replicates.
    if(replication%%20L==0L) {
      write.csv(bind_rows(results),"outputs/quarterly_pilot/simulation_fits.csv",row.names=FALSE)
      message(scenarios[scenario_index],": ",replication,"/",replications)
    }
  }
}
results <- bind_rows(results) |> mutate(error=estimate-truth,
  lower=estimate-1.96*se,upper=estimate+1.96*se,
  covered=lower<=truth & upper>=truth,
  wrong_direction=if_else(truth==0, lower>0|upper<0,
                         if_else(truth<0,lower>0,upper<0)))
summary <- results |> group_by(scenario) |> summarise(
  attempts=n(),n_usable=sum(usable),fit_rate=mean(usable),
  bias=mean(error[usable]),bias_mcse=sd(error[usable])/sqrt(sum(usable)),
  rmse=sqrt(mean(error[usable]^2)),coverage=mean(covered[usable]),
  coverage_mcse=sqrt(coverage*(1-coverage)/sum(usable)),
  success_and_coverage=sum(usable & coalesce(covered,FALSE))/n(),
  directional_error=mean(wrong_direction[usable]),
  directional_mcse=sqrt(directional_error*(1-directional_error)/sum(usable)),
  elapsed_seconds=sum(seconds),.groups="drop") |>
  mutate(core_gate=if_else(scenario %in% c("favorable","null"),
    fit_rate>=.95 & abs(bias)<=.05 & coverage>=.90 & coverage_mcse<=.02 &
      (scenario!="null"|directional_error<=.10),NA))
write.csv(results,"outputs/quarterly_pilot/simulation_fits.csv",row.names=FALSE)
write.csv(summary,"outputs/quarterly_pilot/simulation_summary.csv",row.names=FALSE)
capture.output(sessionInfo(),file="outputs/quarterly_pilot/simulation_session.txt")
plot <- ggplot(results |> filter(usable),aes(scenario,estimate)) +
  geom_boxplot(fill="#56B4E9",outlier.alpha=.3) +
  geom_point(data=distinct(results,scenario,truth),aes(y=truth),shape=4,size=4,colour="#D55E00",stroke=1.2) +
  coord_flip() + theme_minimal(base_size=12) +
  labs(title="Common strength-slope recovery on the nine-locality design",
       subtitle="Synthetic outcomes; 200 replicates per scenario; orange crosses mark structural truth",
       x=NULL,y="Log-count slope per 1,000 listed personnel",
       caption="Boxes show usable fits only. Failure rates and Monte Carlo uncertainty are reported separately.")
ggsave("outputs/quarterly_pilot/simulation_recovery.png",plot,width=11,height=5,dpi=160)
print(summary,width=Inf)
