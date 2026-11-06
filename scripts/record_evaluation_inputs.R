# Fingerprint the unchanged primary inputs before combining evaluation findings.
# Raw source versions are already covered by the source manifest. These hashes
# identify the panel and model objects that the new diagnostics evaluate.
.libPaths(c(".local_library", .libPaths()))
paths <- c("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds",
  "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds",
  "outputs/quarterly_pilot/empirical/baseline_model.rds",
  "outputs/quarterly_pilot/empirical/history_model.rds",
  "outputs/quarterly_pilot/empirical/gate_at_fit.json")
stopifnot(all(file.exists(paths)))
manifest <- data.frame(path = paths, bytes = file.info(paths)$size,
  sha256 = vapply(paths, function(path) {
    digest::digest(readBin(path, "raw", n = file.info(path)$size),
                   algo = "sha256", serialize = FALSE)
  }, character(1)), recorded_utc = format(Sys.time(), tz = "UTC", usetz = TRUE))
write.csv(manifest, "data/quarterly_evaluation_input_manifest.csv", row.names = FALSE)
cat("Recorded", nrow(manifest), "primary evaluation input fingerprints.\n")
