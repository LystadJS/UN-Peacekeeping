# Preparation only: no downloads, package installation, model fitting or claims
# that the empirical audit has passed. Run from the repository root.
if (!file.exists("un_peacekeeping.Rproj")) {
  stop("Run this script from the UN-Peacekeeping repository root.")
}

# Keep acquired originals and intermediate/analysis products in separate ignored
# directories. Empty directories are recreated by this script after cloning.
working_directories <- c(
  "data/raw", "data/interim", "data/processed",
  "outputs/week_1", "outputs/week_1/audit", "outputs/week_1/figures"
)
for (directory in working_directories) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
}

# Snapshot only the packages relevant to the proposed workflow. An installed
# version inventory is not a lockfile or a claim of end-to-end reproducibility.
package_names <- c("dplyr", "ggplot2", "glmmTMB", "sf", "renv")
package_locations <- vapply(package_names, function(package_name) {
  package_path <- find.package(package_name, quiet = TRUE)
  if (length(package_path)) package_path[[1]] else NA_character_
}, character(1))
package_inventory <- data.frame(
  package = package_names,
  installed = !is.na(package_locations),
  loadable = vapply(package_names, requireNamespace, logical(1), quietly = TRUE),
  version = vapply(package_names, function(package_name) {
    if (!is.na(package_locations[[package_name]])) {
      as.character(packageVersion(package_name))
    } else {
      NA_character_
    }
  }, character(1)),
  library_path = unname(package_locations),
  stringsAsFactors = FALSE
)

# Timestamp snapshots so later preparations do not overwrite earlier evidence.
snapshot_id <- format(Sys.time(), "%Y%m%dT%H%M%OS6Z", tz = "UTC")
snapshot_id <- gsub("[.]", "_", snapshot_id)
snapshot_directory <- file.path("outputs/week_1", snapshot_id)
dir.create(snapshot_directory, recursive = TRUE, showWarnings = FALSE)
write.csv(package_inventory, file.path(snapshot_directory, "package_inventory.csv"),
          row.names = FALSE, na = "")
capture.output(sessionInfo(), file = file.path(snapshot_directory, "session_info.txt"))

# Verify template schemas without manufacturing any empirical check results.
template_paths <- c(
  "data/source_manifest.csv", "data/data_dictionary.csv", "data/audit_checks.csv",
  "data/templates/exclusion_ledger.csv", "data/templates/boundary_crosswalk.csv",
  "data/templates/join_audit.csv"
)
for (template_path in template_paths) {
  field_counts <- count.fields(template_path, sep = ",", quote = "\"")
  stopifnot(length(unique(field_counts)) == 1L)
  template <- read.csv(template_path, stringsAsFactors = FALSE, check.names = FALSE)
  stopifnot(!anyDuplicated(names(template)))
}
audit_checks <- read.csv("data/audit_checks.csv", stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(audit_checks$check_id))

writeLines(c(
  "Week 1 preparation completed; empirical audit NOT RUN.",
  paste("Environment snapshot:", snapshot_directory),
  "No data were downloaded and no packages were installed.",
  "Next action: follow docs/week_1_runbook.md when acquisition is authorized."
), file.path(snapshot_directory, "preparation_status.txt"))
print(package_inventory, row.names = FALSE)
message("Week 1 directories and environment snapshot prepared: ", snapshot_directory)
