# Interpret catalogue dates separately from a map's reference month or release.
# The retained XML is a current catalogue export, not a historical web capture.
.libPaths(c(".local_library", .libPaths()))
sources <- read.csv("data/deployment_release_catalog_sources.csv")
for (i in seq_len(nrow(sources))) {
  path <- sources$path[i]
  stopifnot(file.info(path)$size == sources$bytes[i],
    digest::digest(readBin(path, "raw", file.info(path)$size),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
lines <- readLines(sources$path[sources$source_id == "revision_46_catalog"], warn = FALSE)
control_value <- function(tag) {
  pattern <- paste0('<controlfield tag="', tag, '">([^<]+)</controlfield>')
  matched <- grep(pattern, lines, value = TRUE)
  stopifnot(length(matched) == 1L)
  sub(paste0(".*", pattern, ".*"), "\\1", matched)
}
entered <- as.Date(substr(control_value("008"), 1L, 6L), "%y%m%d")
stopifnot(entered == as.Date("2022-09-28"),
  any(grepl("4412_Rev-_46.pdf", lines, fixed = TRUE)))
# MARC 008/00-05 is the catalogue record's creation date; 005 is its last
# transaction. Neither proves the date its attached PDF became public.
result <- data.frame(revision = 46, map_reference_month = "2022-08",
  catalog_record_created = as.character(entered),
  catalog_latest_transaction = control_value("005"),
  conflicting_catalog_269_value = "2022-06",
  evidence_scope = "current_catalog_reports_pre_cutoff_record_creation",
  exact_public_release_verified = FALSE,
  contemporaneous_pdf_bytes_authenticated = FALSE,
  stringsAsFactors = FALSE)
stopifnot(any(grepl('>2022-06</subfield>', lines, fixed = TRUE)))
write.csv(result, "data/deployment_release_catalog_audit.csv", row.names = FALSE)
print(result)
