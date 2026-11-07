# Fetch only the six pinned original artifacts used by the one-origin supplement.
# Existing files are verified, never overwritten. The current hashes identify
# retrieved bytes; they do not establish historical byte identity or release dates.
.libPaths(c(".local_library", .libPaths()))
event_inputs <- read.csv("data/forecast_origin_event_inputs.csv")
event_inputs <- event_inputs[grepl("^https://", event_inputs$source), ]
deployment_inputs <- read.csv("data/forecast_origin_deployment_sources.csv")
inputs <- rbind(data.frame(path = event_inputs$path, url = event_inputs$source,
  bytes = event_inputs$bytes, sha256 = event_inputs$sha256),
  data.frame(path = deployment_inputs$local_path, url = deployment_inputs$url,
    bytes = deployment_inputs$bytes, sha256 = deployment_inputs$sha256))
stopifnot(nrow(inputs) == 6L, !anyDuplicated(inputs$path))
for (i in seq_len(nrow(inputs))) {
  path <- inputs$path[i]
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(path)) download.file(inputs$url[i], path, mode = "wb")
  stopifnot(file.info(path)$size == inputs$bytes[i],
    digest::digest(readBin(path, "raw", n = file.info(path)$size),
      algo = "sha256", serialize = FALSE) == inputs$sha256[i])
}
cat("Six original one-origin artifacts verified; no files overwritten.\n")
