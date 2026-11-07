# Compare the additive tasks with the independently rebuilt project.
# References are used only after generation; no model is fitted here.
.libPaths(c(".local_library", .libPaths()))
clean_root <- "outputs/clean_rebuild_20261106/project"
tables <- c("data/quarterly_source_spotcheck_summary.csv", "data/simulation_archive_summary.csv",
            "portfolio/figures/descriptive_panel_summary.csv")
for (path in tables) stopifnot(identical(read.csv(path), read.csv(file.path(clean_root, path))))
manifest_path <- "outputs/simulation_archive/panel_manifest.csv"
original <- read.csv(manifest_path)
rebuilt <- read.csv(file.path(clean_root, manifest_path))
stopifnot(nrow(original) == 2000L, identical(original, rebuilt))
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
                                          algo = "sha256", serialize = FALSE)
# Verify actual archived bytes, not just agreement between two manifest tables.
for (root in c(".", clean_root)) {
  for (i in seq_len(nrow(original))) {
    stopifnot(hash_file(file.path(root, "outputs/simulation_archive", original$file[i])) == original$sha256[i])
  }
}
status <- jsonlite::fromJSON("portfolio/human_review/review_status.json")
stopifnot(identical(status$status, "skipped_by_user"), !status$feedback_received,
          !status$human_review_complete)
source("scripts/record_analysis_snapshot.R")
jsonlite::write_json(list(aggregate_tables_matched = length(tables),
  synthetic_panels_per_run = 2000L, archived_files_hash_verified = 4000L,
  snapshot_files_verified = 18L, human_review = "skipped_by_user_not_completed",
  new_model_fits = 0L), "docs/followup_checks.json", pretty = TRUE, auto_unbox = TRUE)
message("Follow-up aggregates, 4,000 archive hashes and current snapshot verified.")
