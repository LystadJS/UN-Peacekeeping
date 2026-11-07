# Materialize existing synthetic seeds only. Never call a fitting function.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
source("R/quarterly_simulation.R")
source("R/dynamic_quarterly_simulation.R")
directory <- "outputs/simulation_archive"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
paths <- c(core = "outputs/quarterly_pilot/simulation_fits.csv",
  dynamic = "outputs/dynamic_quarterly/fit_records.csv",
  matched_null = "outputs/dynamic_quarterly_null_disjoint/fit_records.csv")
records <- bind_rows(lapply(names(paths), function(group) {
  rows <- read.csv(paths[[group]])
  rows$family <- group
  rows
}))
stopifnot(nrow(records) == 2200L)
# Initial-adjusted and ordinary fits share a dataset, but all fit attempts are
# represented, including failed attempts. Do not filter on usable.
jobs <- records |> distinct(family, scenario, seed, truth) |> arrange(family, scenario, seed)
stopifnot(nrow(jobs) == 2000L, !anyDuplicated(jobs[c("family", "scenario", "seed")]))
hash_file <- function(path) digest::digest(readBin(path, "raw", n = file.info(path)$size), algo = "sha256", serialize = FALSE)
provenance_paths <- c(unname(paths), "R/quarterly_simulation.R", "R/dynamic_quarterly_simulation.R",
  "outputs/quarterly_pilot/exposure_design.rds")
write.csv(data.frame(path = provenance_paths, sha256 = vapply(provenance_paths, hash_file, character(1))),
  file.path(directory, "input_manifest.csv"), row.names = FALSE)
# Archive generator source verbatim: it contains all fixed DGP parameters,
# including initialization and risk transitions, beyond beta saved per object.
for (path in provenance_paths[grepl("^R/", provenance_paths)])
  file.copy(path, file.path(directory, basename(path)), overwrite = TRUE)
manifest <- vector("list", nrow(jobs))
for (i in seq_len(nrow(jobs))) {
  job <- jobs[i, ]
  simulation <- if (job$family == "core") {
    simulate_quarterly(design, job$seed, job$scenario)
  } else if (job$family == "matched_null") {
    generated <- simulate_dynamic_quarterly(design, job$seed, "stationary_initial", effect_override = 0)
    generated$scenario <- "correlated_prehistory_null"
    generated
  } else simulate_dynamic_quarterly(design, job$seed, job$scenario)
  stopifnot(simulation$seed == job$seed, simulation$beta == job$truth,
    identical(simulation$scenario, job$scenario), nrow(simulation$data) == 288L,
    all(simulation$data$recorded_events <= simulation$data$true_events))
  matching <- records |> filter(family == job$family, scenario == job$scenario, seed == job$seed)
  stopifnot(nrow(matching) >= 1L, all(matching$truth == simulation$beta))
  first_seed <- min(jobs$seed[jobs$family == job$family & jobs$scenario == job$scenario])
  example_checked <- job$seed == first_seed
  if (example_checked) {
    example_path <- if (job$family == "core") paste0("outputs/quarterly_pilot/synthetic_example_",job$scenario,".rds") else
      if (job$family == "dynamic") paste0("outputs/dynamic_quarterly/example_",job$scenario,".rds") else
        "outputs/dynamic_quarterly_null_disjoint/example.rds"
    stopifnot(isTRUE(all.equal(simulation, readRDS(example_path), tolerance = 0)))
  }
  filename <- paste0(job$family,"_",job$scenario,"_",job$seed,".rds")
  path <- file.path(directory, filename)
  if (file.exists(path)) stopifnot(identical(readRDS(path), simulation)) else saveRDS(simulation, path)
  manifest[[i]] <- data.frame(family = job$family, scenario = job$scenario, seed = job$seed,
    truth = job$truth, rows = nrow(simulation$data), fit_attempts = nrow(matching),
    unusable_fit_attempts = sum(!matching$usable), example_checked = example_checked,
    file = filename, sha256 = hash_file(path))
  if (i %% 200L == 0L) message("Archived ", i, "/2000 panels")
}
manifest <- bind_rows(manifest)
stopifnot(sum(manifest$fit_attempts) == 2200L, sum(manifest$example_checked) == 10L)
write.csv(manifest, file.path(directory, "panel_manifest.csv"), row.names = FALSE)
summary <- manifest |> group_by(family) |> summarise(panels = n(), panel_rows = sum(rows),
  fit_attempts = sum(fit_attempts), unusable_fit_attempts = sum(unusable_fit_attempts),
  examples_verified = sum(example_checked), .groups = "drop")
write.csv(summary, "data/simulation_archive_summary.csv", row.names = FALSE)
capture.output(sessionInfo(), file = file.path(directory, "session_info.txt"))
print(summary)
