# Record a current analysis snapshot, never a retrospective preregistration.
# Text hashes normalize CRLF to LF; derived CSVs are fingerprinted as raw bytes.
# Re-running verifies the recorded snapshot and fails if anything has changed.
.libPaths(c(".local_library", .libPaths()))
snapshot_path <- "config/analysis_snapshot.json"
paths <- c("config/city_aggregation.csv", "data/source_manifest.csv",
  "docs/quarterly_protocol.md", "docs/empirical_quarterly_protocol.md",
  "docs/dynamic_quarterly_protocol.md", "docs/dynamic_quarterly_null_extension.md",
  "R/quarterly_simulation.R", "R/dynamic_quarterly_simulation.R",
  "R/diagnostic_helpers.R", "scripts/audit_week_1.R",
  "scripts/build_quarterly_exposure.R", "scripts/build_quarterly_panel.R",
  "scripts/fit_quarterly_empirical.R", "scripts/diagnose_quarterly_models.R",
  "scripts/analyze_quarterly_sensitivity.R", "scripts/validate_quarterly_prediction.R",
  "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv",
  "outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.csv")
hash_file <- function(path, method) {
  if (method == "utf8_lf") {
    value <- paste0(paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n"), "\n")
    digest::digest(enc2utf8(value), algo = "sha256", serialize = FALSE)
  } else digest::digest(readBin(path, "raw", file.info(path)$size), algo = "sha256", serialize = FALSE)
}
stopifnot(all(file.exists(paths)))
methods <- ifelse(startsWith(paths, "outputs/"), "raw_bytes", "utf8_lf")
files <- data.frame(path = paths, hash_method = methods,
  sha256 = mapply(hash_file, paths, methods, USE.NAMES = FALSE))
if (file.exists(snapshot_path)) {
  previous <- jsonlite::fromJSON(snapshot_path)
  stopifnot(identical(previous$files, files))
  message("Current analysis snapshot verified: ", nrow(files), " files.")
} else {
  snapshot <- list(recorded_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    scope = "Current reviewed common-slope quarterly analysis; no new estimation",
    registration_claim = "Post-results local snapshot, not external preregistration or proof of pre-results freezing",
    change_rule = "Log any later change and record a new explicitly dated snapshot; do not silently overwrite this one",
    files = files)
  jsonlite::write_json(snapshot, snapshot_path, pretty = TRUE, auto_unbox = TRUE)
  message("Current analysis snapshot recorded: ", nrow(files), " files.")
}
