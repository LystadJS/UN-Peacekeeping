.libPaths(c(".local_library",.libPaths()))
source("R/dynamic_quarterly_simulation.R")
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
first <- simulate_dynamic_quarterly(design, 88, "favorable")
second <- simulate_dynamic_quarterly(design, 88, "favorable")
stopifnot(identical(first,second), nrow(first$data)==288L,
          all(first$data$recorded_events<=first$data$true_events),
          all(first$data$initial_events==0),all(first$data$initial_spell==0))
for (locality in unique(first$data$locality_id)) {
  local <- first$data[first$data$locality_id==locality,]
  stopifnot(all(local$events_lag[-1]==head(local$recorded_events,-1)),
            all(local$strength_lag2[-1]==head(local$strength_lag,-1)))
  expected_spell <- 0L
  for (index in seq_len(nrow(local))) {
    stopifnot(local$violent_spell_lag[index]==expected_spell)
    expected_spell <- if(local$recorded_events[index]>0) expected_spell+1L else 0L
  }
}
stress <- simulate_dynamic_quarterly(design, 88, "stationary_initial")
stopifnot(any(stress$data$initial_events>0), all(stress$data$recorded_events<=stress$data$true_events))
cat("Dynamic seed, count, time-order, earlier-strength and spell checks passed.\n")
