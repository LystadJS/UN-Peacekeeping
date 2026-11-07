# Rebuild the audited quarterly panel in a NEW isolated directory from originals.
# No downloads, copied intermediate data, empirical fits, or readiness overrides.
# Usage: Rscript scripts/rebuild_original_inputs.R [new_directory] --execute
.libPaths(c(".local_library", .libPaths()))
arguments <- commandArgs(trailingOnly = TRUE)
execute <- "--execute" %in% arguments
prepared_project <- "--prepared-project" %in% arguments
arguments <- arguments[!arguments %in% c("--execute", "--prepared-project")]
project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
stopifnot(file.exists("scripts/audit_week_1.R"), length(arguments) <= 1L)
target <- if (length(arguments)) arguments[[1]] else file.path("outputs", paste0("raw_rebuild_", format(Sys.time(), "%Y%m%d_%H%M%S")))
steps <- c("scripts/audit_week_1.R", "tests/run_week_1_checks.R", "scripts/build_quarterly_exposure.R",
  "tests/run_quarterly_checks.R", "scripts/build_quarterly_panel.R",
  "tests/run_quarterly_panel_checks.R", "scripts/audit_quarterly_freshness.R",
  "scripts/audit_quarterly_design.R", "scripts/plot_quarterly_coverage.R",
  "scripts/record_quarterly_panel_manifest.R")
if (!execute) {
  cat("Prepared isolated raw rebuild; no files copied or pipeline run.\nTarget:", target,
      "\nRun again with --execute after reviewing this ordered workflow:\n")
  cat(paste(steps, collapse = "\n"), "\n")
  quit(status = 0L)
}
if (!prepared_project && (file.exists(target) || dir.exists(target))) stop("Target must be a new directory: ", target)
if (prepared_project) {
  target <- normalizePath(target, winslash = "/", mustWork = TRUE)
  if (any(dir.exists(file.path(target, c("outputs", "data/interim", "data/processed"))))) {
    stop("Prepared project must not contain outputs, interim or processed directories.")
  }
  data_entries <- list.files(file.path(target, "data"), all.files = TRUE, no.. = TRUE)
  if (!all(data_entries %in% c("raw", "source_manifest.csv", "quarterly_data_dictionary.csv"))) stop("Unapproved prepared data input.")
  allowed_top <- c("scripts", "tests", "R", "config", "docs", "data", "portfolio",
    ".local_library", "un_peacekeeping.Rproj", "README.md", "AGENTS.md", ".gitignore",
    "DESCRIPTION", "LICENSE", ".Rprofile", "renv.lock")
  top_entries <- list.files(target, all.files = TRUE, no.. = TRUE)
  if (!all(top_entries %in% allowed_top)) stop("Unapproved prepared top-level input: ",
    paste(setdiff(top_entries, allowed_top), collapse = ", "))
  if (!dir.exists(file.path(target, ".local_library"))) stop("Prepared isolated library missing.")
  setwd(target)
}
# Hash every pinned original, including documentation, before copying anything.
manifest <- read.csv("data/source_manifest.csv", stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(manifest$local_path), all(grepl("^data/raw/", manifest$local_path)),
          all(grepl("^[a-fA-F0-9]{64}$", manifest$sha256)))
hash_file <- function(path) digest::digest(readBin(path, "raw", n = file.info(path)$size),
                                         algo = "sha256", serialize = FALSE)
for (i in seq_len(nrow(manifest))) {
  path <- manifest$local_path[i]
  if (!file.exists(path) || hash_file(path) != manifest$sha256[i]) stop("Original missing/hash mismatch: ", path)
}
if (!prepared_project) dir.create(target, recursive = TRUE)
target <- normalizePath(target, winslash = "/", mustWork = TRUE)
copy_relative <- function(path) {
  destination <- file.path(target, path)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(path, destination, overwrite = FALSE))
}
# Explicit allowlist prevents copied fitted models, status flags or checkpoint
# CSVs from accidentally satisfying downstream requirements in the clean run.
code_paths <- unlist(lapply(c("scripts", "tests", "R", "config"), function(directory)
  list.files(directory, recursive = TRUE, full.names = TRUE)))
copy_paths <- unique(c(code_paths, "un_peacekeeping.Rproj", "data/source_manifest.csv",
                       "data/quarterly_data_dictionary.csv", manifest$local_path))
if (prepared_project) copy_paths <- copy_paths[file.exists(copy_paths)]
if (!prepared_project) for (path in copy_paths) copy_relative(path)
for (i in seq_len(nrow(manifest))) {
  stopifnot(hash_file(file.path(target, manifest$local_path[i])) == manifest$sha256[i])
}
write.csv(data.frame(path = copy_paths, sha256 = vapply(copy_paths, hash_file, character(1))),
          file.path(target, "rebuild_input_hashes.csv"), row.names = FALSE)
# Use installed packages without copying package binaries into the new project.
# This records the environment, but is not a cross-machine dependency lockfile.
library_paths <- if (prepared_project) c(file.path(target, ".local_library"), .Library) else
  normalizePath(.libPaths(), winslash = "/", mustWork = TRUE)
Sys.setenv(R_LIBS = paste(library_paths, collapse = .Platform$path.sep),
  AUDIT_AGGREGATE_CITIES = "true")
if (prepared_project) Sys.setenv(R_LIBS_USER = file.path(target, ".local_library"),
  R_LIBS_SITE = file.path(target, ".local_library"))
rscript <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
setwd(target)
dir.create("rebuild_logs")
execution <- data.frame(step = character(), exit_code = integer(), seconds = numeric())
for (step in steps) {
  started <- proc.time()[[3]]
  log_path <- file.path("rebuild_logs", paste0(basename(step), ".log"))
  process_arguments <- if (prepared_project)
    c("--vanilla", shQuote("scripts/run_isolated.R"), shQuote(step)) else
    c("--vanilla", shQuote(step))
  exit_code <- system2(rscript, process_arguments, stdout = log_path, stderr = log_path)
  execution <- rbind(execution, data.frame(step = step, exit_code = exit_code,
    seconds = proc.time()[[3]] - started))
  write.csv(execution, "rebuild_execution.csv", row.names = FALSE)
  if (exit_code != 0L) stop("Rebuild failed at ", step, "; inspect ", target, "/", log_path)
}
capture.output(sessionInfo(), file = "rebuild_session_info.txt")
writeLines(c("Raw-to-quarterly panel rebuild completed with independent accounting checks.",
  "No empirical model, simulation, final portfolio or substantive result was rebuilt by this entry point.",
  "No validation readiness flag was copied or enabled."), "rebuild_status.txt")
cat("Completed isolated raw rebuild:", target, "\n")
