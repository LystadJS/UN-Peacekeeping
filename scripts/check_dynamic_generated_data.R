# Independently regenerate every data-generating seed to inspect finite-sample
# count/spell extremes. This performs no estimation and does not change the DGP.
.libPaths(c(".local_library",.libPaths()))
source("R/dynamic_quarterly_simulation.R")
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
scenarios <- c("favorable","null","selection","differential_recording","stationary_initial")
checks <- list()
for (scenario_index in seq_along(scenarios)) {
  for (replication in seq_len(200L)) {
    simulation <- simulate_dynamic_quarterly(design,20261107L+10000L*scenario_index+replication,scenarios[scenario_index])
    panel <- simulation$data
    checks[[length(checks)+1L]] <- data.frame(scenario=scenarios[scenario_index],replication=replication,
      max_true_events=max(panel$true_events),max_recorded_events=max(panel$recorded_events),
      max_spell=max(panel$violent_spell_lag),max_initial_events=max(panel$initial_events),
      max_initial_spell=max(panel$initial_spell),min_recording=min(panel$recording_probability),
      max_recording=max(panel$recording_probability),
      finite_counts=all(is.finite(panel$true_events)&is.finite(panel$recorded_events)),
      valid_thinning=all(panel$recorded_events<=panel$true_events),
      max_strength=max(panel$strength_lag))
  }
}
checks <- do.call(rbind,checks)
stopifnot(all(checks$finite_counts),all(checks$valid_thinning))
write.csv(checks,"outputs/dynamic_quarterly/generated_data_checks.csv",row.names=FALSE)
print(aggregate(cbind(max_true_events,max_recorded_events,max_spell,max_initial_events,max_initial_spell,max_strength)~scenario,checks,max))
