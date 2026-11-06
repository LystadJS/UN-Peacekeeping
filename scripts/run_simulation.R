# Generate a small, inspectable eight-cell design. These files are synthetic.
source("scripts/check_environment.R")
source("R/simulate_panel.R")
source("config/analysis_config.R")
scenario_grid <- expand.grid(
  selection = c(FALSE, TRUE),
  differential_recording = c(FALSE, TRUE),
  heterogeneity = c(FALSE, TRUE)
)
output_directory <- file.path("outputs", "simulation")
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)

for (scenario_index in seq_len(nrow(scenario_grid))) {
  scenario <- scenario_grid[scenario_index, ]
  simulation <- simulate_panel(
    seed = analysis_config$seed + scenario_index,
    selection = scenario$selection,
    differential_recording = scenario$differential_recording,
    heterogeneity = scenario$heterogeneity
  )
  saveRDS(simulation, file.path(output_directory,
                              sprintf("synthetic_scenario_%02d.rds", scenario_index)))
}
write.csv(scenario_grid, file.path(output_directory, "scenario_grid.csv"), row.names = FALSE)
capture.output(sessionInfo(), file = file.path(output_directory, "session_info.txt"))
message("Generated eight synthetic scenarios. No model recovery results have been estimated.")
