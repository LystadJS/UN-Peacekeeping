# Retrieve the declared sources once. Existing nonempty originals are never
# overwritten; a hash mismatch requires a new version directory and review.
.libPaths(c(".local_library", .libPaths()))
sources <- read.csv("config/week_1_sources.csv", stringsAsFactors = FALSE)
previous <- if (file.exists("data/source_manifest.csv")) {
  read.csv("data/source_manifest.csv", stringsAsFactors = FALSE)
} else NULL
options(timeout = 300)
for (index in seq_len(nrow(sources))) {
  path <- sources$local_path[index]
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(path) || file.info(path)$size == 0) {
    temporary_path <- paste0(path, ".partial")
    download.file(sources$download_url[index], temporary_path, mode = "wb", quiet = TRUE)
    stopifnot(file.info(temporary_path)$size > 0)
    if (file.exists(path)) stop("An empty previous download needs manual review: ", path)
    stopifnot(file.rename(temporary_path, path))
  }
  # Hash bytes directly: Windows sandbox ACL probes can misreport file.access()
  # even when the same file can be opened normally by R.
  hash <- digest::digest(readBin(path, "raw", n = file.info(path)$size),
                         algo = "sha256", serialize = FALSE)
  if (!is.null(previous) && "sha256" %in% names(previous)) {
    old_hash <- previous$sha256[previous$source_id == sources$source_id[index]]
    old_hash <- old_hash[!is.na(old_hash) & nzchar(old_hash)]
    if (length(old_hash) && !all(old_hash == hash)) stop("Source hash changed: ", path)
  }
  sources$sha256[index] <- hash
  sources$bytes[index] <- file.info(path)$size
  # File mtime is the saved download timestamp; UTC is explicit in the manifest.
  sources$retrieved_at_utc[index] <- format(file.info(path)$mtime, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  sources$audit_status[index] <- "acquired_hash_verified"
}
write.csv(sources, "data/source_manifest.csv", row.names = FALSE, na = "")
message("Verified ", nrow(sources), " acquired artifacts; originals preserved.")
