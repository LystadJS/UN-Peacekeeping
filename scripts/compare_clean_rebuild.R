# Compare a completed clean rebuild with retained reference outputs, without fitting.
# Usage: Rscript scripts/compare_clean_rebuild.R [clean_project] [--panel-only]
# References are read only here, AFTER generation; no fitting script sources this file.
.libPaths(c(".local_library", .libPaths()))
library(glmmTMB)
arguments <- commandArgs(trailingOnly = TRUE)
panel_only <- "--panel-only" %in% arguments
arguments <- setdiff(arguments, "--panel-only")
stopifnot(length(arguments) <= 1L)
reference_root <- normalizePath(".", winslash = "/")
clean_root <- normalizePath(if (length(arguments)) arguments[1] else
  "outputs/clean_rebuild_20261106/project", winslash = "/", mustWork = TRUE)
stopifnot(reference_root != clean_root)
tolerance <- 1e-8
records <- list()
record <- function(path, check, passed, detail = "") {
  records[[length(records) + 1L]] <<- data.frame(path = path, check = check,
    passed = isTRUE(passed), detail = detail, stringsAsFactors = FALSE)
}

# These are documentation/provenance inputs, not generated scientific aggregates.
# They are listed explicitly; no arbitrary missing CSV is silently discarded.
static_data <- c("audit_checks.csv", "audit_package_versions.csv", "data_dictionary.csv",
  "map_review.csv", "pilot_package_versions.csv", "pilot_protocol_version.csv",
  "pilot_source_manifest.csv", "quarterly_data_dictionary.csv", "source_manifest.csv",
  "absence_followup_evidence.csv", "historical_availability_evidence.csv",
  "forecast_origin_release_evidence.csv", "forecast_origin_deployment_sources.csv")
reference_data <- list.files("data", pattern = "\\.csv$", full.names = TRUE)
expected_data <- reference_data[!basename(reference_data) %in% static_data]
raw_directories <- c("outputs/week_1/audit_aggregated", "outputs/quarterly_pilot/panel",
                     "outputs/quarterly_pilot/design")
scientific_directories <- c("outputs/quarterly_pilot", "outputs/dynamic_quarterly",
  "outputs/dynamic_quarterly_null_disjoint", "outputs/quarterly_diagnostics",
  "outputs/quarterly_prediction", "outputs/quarterly_sensitivity")
if (panel_only) {
  csv_paths <- c(unlist(lapply(raw_directories, list.files, pattern = "\\.csv$",
    full.names = TRUE)), "outputs/quarterly_pilot/exposure_audit.csv",
    "outputs/quarterly_pilot/exposure_coverage.csv",
    "data/quarterly_freshness_sensitivity.csv", "data/quarterly_panel_manifest.csv")
} else {
  csv_paths <- c(expected_data, unlist(lapply(c(raw_directories, scientific_directories),
    list.files, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)),
    list.files("portfolio/figures", pattern = "\\.csv$", full.names = TRUE))
  # Also inspect every other common data CSV, including the pinned source manifest.
  common <- intersect(reference_data, paste0("data/", list.files(file.path(clean_root, "data"),
    pattern = "\\.csv$")))
  csv_paths <- c(csv_paths, common)
}
csv_paths <- sort(unique(gsub("\\\\", "/", csv_paths)))
panel_paths <- c(unlist(lapply(raw_directories, list.files, pattern = "\\.csv$",
  full.names = TRUE, recursive = TRUE)), "outputs/quarterly_pilot/exposure_audit.csv",
  "outputs/quarterly_pilot/exposure_coverage.csv")
manifest_paths <- c("data/quarterly_panel_manifest.csv", "data/quarterly_evaluation_input_manifest.csv",
                    "portfolio/figures/figure_manifest.csv",
                    "portfolio/figures/descriptive_panel_manifest.csv")

compare_column <- function(a, b, exact = FALSE) {
  if (length(a) != length(b) || !identical(is.na(a), is.na(b))) return(FALSE)
  keep <- !is.na(a)
  a <- a[keep]; b <- b[keep]
  if (is.numeric(a) && is.numeric(b)) {
    if (!identical(is.infinite(a), is.infinite(b))) return(FALSE)
    if (any(is.infinite(a)) && !identical(a[is.infinite(a)], b[is.infinite(b)])) return(FALSE)
    finite <- is.finite(a) & is.finite(b)
    if (!any(finite)) return(TRUE)
    if (exact) return(all(a[finite] == b[finite]))
    return(max(abs(a[finite] - b[finite])) <= tolerance)
  }
  identical(as.character(a), as.character(b))
}
# Use a maximum absolute difference, not all.equal's average/relative scale.
compare_object <- function(a, b) {
  if (!identical(class(a), class(b)) || !identical(dim(a), dim(b)) ||
      !identical(dimnames(a), dimnames(b)) || !identical(names(a), names(b))) return(FALSE)
  if (inherits(a, "formula")) return(identical(deparse(a), deparse(b)))
  if (is.data.frame(a)) return(identical(a, b))
  if (is.list(a)) return(length(a) == length(b) &&
    all(vapply(seq_along(a), function(i) compare_object(a[[i]], b[[i]]), logical(1))))
  if (is.atomic(a)) return(compare_column(as.vector(a), as.vector(b)))
  identical(a, b)
}
for (path in csv_paths) {
  rebuilt <- file.path(clean_root, path)
  if (!file.exists(rebuilt)) { record(path, "required_file", FALSE, "Missing rebuilt output"); next }
  a <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  b <- read.csv(rebuilt, check.names = FALSE, stringsAsFactors = FALSE)
  # Only explicit timing and artifact-hash metadata are exempt. Scientific
  # source IDs, seed values, warnings, denominators and labels are never exempt.
  ignored <- c("seconds", "elapsed_seconds")
  if (path %in% manifest_paths) ignored <- c(ignored, "recorded_utc", "sha256", "bytes")
  columns <- setdiff(names(a), ignored)
  schema_ok <- identical(columns, setdiff(names(b), ignored)) && nrow(a) == nrow(b)
  record(path, "schema_and_rows", schema_ok, paste("Reference rows:", nrow(a)))
  if (!schema_ok) next
  failed <- character()
  for (column in columns) {
    # Exact checks cover all panel/source-lineage cells and all categorical,
    # integer-valued, coverage, probability-denominator and gate outputs.
    exact <- path %in% panel_paths ||
      grepl("coverage|covered|directional_error|fit_rate|gate|usable|convergence|hessian|outside_reference|passed", column) ||
      (is.numeric(a[[column]]) && all(a[[column]] == floor(a[[column]]), na.rm = TRUE))
    if (!compare_column(a[[column]], b[[column]], exact)) failed <- c(failed, column)
  }
  record(path, "values", !length(failed), if (length(failed)) paste(failed, collapse = ", ") else
    paste("Matched; ignored fields:", paste(intersect(names(a), ignored), collapse = ", ")))
}

# RDS panels preserve factor types and other metadata that CSV comparisons miss.
rds_paths <- c("outputs/quarterly_pilot/exposure_design.rds",
  "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds",
  "outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
if (!panel_only) rds_paths <- unique(c(rds_paths, unlist(lapply(scientific_directories,
  list.files, pattern = "\\.rds$", full.names = TRUE, recursive = TRUE))))
for (path in sort(rds_paths)) {
  rebuilt <- file.path(clean_root, path)
  if (!file.exists(rebuilt)) { record(path, "required_file", FALSE, "Missing rebuilt RDS"); next }
  a <- readRDS(path); b <- readRDS(rebuilt)
  if (inherits(a, "glmmTMB")) {
    # Serialized environments contain irrelevant path/session details; compare
    # the scientifically interpreted model content, not opaque object bytes.
    if (!inherits(b, "glmmTMB")) { record(path, "model_class", FALSE); next }
    ca <- summary(a)$coefficients; cb <- summary(b)$coefficients
    coefficient_ok <- compare_object(ca, cb)
    dispersion_ok <- compare_column(sigma(a), sigma(b))
    variance_ok <- compare_object(glmmTMB::VarCorr(a), glmmTMB::VarCorr(b))
    flags_ok <- identical(a$fit$convergence, b$fit$convergence) &&
      identical(a$sdr$pdHess, b$sdr$pdHess) && nobs(a) == nobs(b)
    record(path, "model_estimates_and_flags", coefficient_ok && dispersion_ok && variance_ok && flags_ok)
  } else {
    # Exact panels/source identities; simulations/diagnostic arrays allow only
    # the same absolute numeric tolerance used for other scientific outputs.
    exact <- is.data.frame(a) || grepl("monthly_timing_scenarios", path)
    result <- if (exact) identical(a, b) else compare_object(a, b)
    record(path, if (exact) "exact_panel_or_timing" else "saved_scientific_object", result)
  }
}
if (!panel_only) {
  a <- jsonlite::fromJSON("data/pilot_validation_status.json")
  status_path <- file.path(clean_root, "data/pilot_validation_status.json")
  if (!file.exists(status_path)) record("data/pilot_validation_status.json", "required_file", FALSE) else {
    b <- jsonlite::fromJSON(status_path)
    gate_fields <- c("history_extension_validated", "history_gate", "empirical_ready",
      "empirical_models_fitted", "empirical_fits_numerically_usable", "empirical_diagnostics_complete",
      "influence_checks_complete", "measurement_sensitivity_complete", "reporting_sensitivity_complete",
      "predictive_validation_complete", "operational_forecast_validated", "causal_effect_identified")
    for (field in gate_fields) record("data/pilot_validation_status.json", field,
      field %in% names(a) && field %in% names(b) && identical(a[[field]], b[[field]]))
  }
}
result <- do.call(rbind, records)
if (panel_only) {
  print(result[!result$passed, ], row.names = FALSE)
  cat("Panel-only checks:", nrow(result), "; passed:", sum(result$passed), "\n")
} else {
  write.csv(result, "docs/clean_rebuild_comparison.csv", row.names = FALSE)
  lines <- c("# Independent clean-rebuild comparison", "",
    paste("Rebuilt project:", clean_root),
    paste("Checks:", nrow(result), "; passed:", sum(result$passed), "; failed:", sum(!result$passed)), "",
    "Scientific numeric tolerance: absolute 1e-8. Panel/source-lineage cells, integer-valued fields, coverage, gates and convergence flags require exact equality.",
    "Only seconds/elapsed_seconds and explicitly named manifest recorded_utc/sha256/bytes fields are omitted. Relative paths and scientific identifiers remain checked.",
    "Non-generated documentation/provenance CSVs are not required outputs; any that exist in both roots are compared. Explicit list:",
    paste0("- ", static_data), "",
    "All retained reference scientific CSVs and selected private RDS objects are required; a missing rebuilt file fails. Model object environments are not byte-compared; fixed coefficients, SEs, dispersion, random-effect variance, sample size and convergence flags are compared.",
    "This script reads reference outputs only for post-generation comparison. It does not feed them into the clean workflow, fit models, alter scientific tables, or complete independent human interpretation.", "",
    if (all(result$passed)) "All specified comparisons passed." else "Comparison failed. Inspect clean_rebuild_comparison.csv; do not claim complete concordance.")
  writeLines(lines, "docs/clean_rebuild_comparison.md")
  print(result[!result$passed, ], row.names = FALSE)
}
if (!all(result$passed)) stop("Clean-rebuild comparison failed; scientific outputs were not modified.")
