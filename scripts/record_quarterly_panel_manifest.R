# Record exact derived panel artifacts without publishing row-level observations.
# Rebuild the panel first. These hashes identify an audit snapshot, not a claim
# that the modeling protocol or empirical analysis has been frozen.
.libPaths(c(".local_library", .libPaths()))
directory <- "outputs/quarterly_pilot/panel"
paths <- file.path(directory, c("quarterly_panel_all_localities.csv",
  "quarterly_panel_complete_exposure.csv", "history_grid_2014_2023.csv",
  "initial_conditions_2015_q4.csv", "panel_summary.csv"))
stopifnot(all(file.exists(paths)))
manifest <- data.frame(
  path = paths,
  sha256 = vapply(paths, function(path) {
    digest::digest(readBin(path, "raw", n = file.info(path)$size),
                   algo = "sha256", serialize = FALSE)
  }, character(1)),
  bytes = file.info(paths)$size,
  rows = vapply(paths, function(path) nrow(read.csv(path)), integer(1)),
  recorded_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
  status = "audited_snapshot_not_empirical_model_freeze"
)
write.csv(manifest, "data/quarterly_panel_manifest.csv", row.names = FALSE)
print(manifest[c("path", "rows", "status")], row.names = FALSE)
