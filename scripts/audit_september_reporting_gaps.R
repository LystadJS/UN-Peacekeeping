# Trace remaining September provenance bottlenecks without inventing a coded
# information set at the fixed origin. Source offices are record provenance,
# not mutually independent observation channels or estimated reporting rates.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
output_directory <- "outputs/september_reporting_gaps"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
sources <- read.csv("data/september_reporting_gap_sources.csv")
for (i in seq_len(nrow(sources))) {
  stopifnot(file.info(sources$path[i])$size == sources$bytes[i],
    digest::digest(readBin(sources$path[i], "raw", sources$bytes[i]),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
# Check the inspected claim markers as well as artifact identity. Publication
# wording is contextual evidence; it is not a certified event release timestamp.
claim_markers <- c(crg_kst_offline = "Information collection has been paused",
  acled_kst_retrospective = "17 December 2025", elimu_mambau_report = "2023-09-05")
for (id in names(claim_markers)) {
  page <- paste(readLines(sources$path[sources$evidence_id == id], warn = FALSE), collapse = "\n")
  stopifnot(grepl(claim_markers[[id]], page, fixed = TRUE))
}
# An empty archive-index response is a recorded search result, never evidence
# that no release existed. These two bounded routes complement earlier queries.
for (id in c("api_preorigin_query", "cumulative_preorigin_query")) {
  query <- sources$path[sources$evidence_id == id]
  stopifnot(length(jsonlite::fromJSON(query)) == 0L)
}
input_path <- "outputs/september_2023/candidate_23_0_9_september_ledger.csv"
events <- read.csv(input_path) |>
  mutate(kst_only = source_office == "Kivu Security Tracker",
    kst_listed = grepl("Kivu Security Tracker", source_office, fixed = TRUE),
    other_source_listed = !kst_only,
    provenance_group = case_when(kst_only ~ "kst_only",
      kst_listed ~ "kst_and_other", TRUE ~ "other_only"))
stopifnot(nrow(events) == 23L, !anyDuplicated(events$id),
  all(is.na(events$certified_available_coded_record)))
# Preserve row-level provenance locally. No source date becomes a data-release
# date, and none of these records is appended to the July-August count.
write.csv(events, file.path(output_directory, "candidate_provenance_ledger.csv"),
  row.names = FALSE, na = "")
summaries <- lapply(c("all_19", "current_core_9"), function(population) {
  subset <- if (population == "all_19") events else filter(events, current_core)
  subset |> group_by(provenance_group) |>
    summarise(events = n(),
      pre_origin_listed_material = sum(has_pre_origin_material),
      all_dated_material_post_origin = sum(all_dated_material_post_origin),
      certified_historical_count = NA_integer_, .groups = "drop") |>
    mutate(population = population, .before = 1)
})
summary <- bind_rows(summaries)
write.csv(summary, "data/september_reporting_gap_summary.csv", row.names = FALSE, na = "")
inputs <- data.frame(path = input_path, bytes = file.info(input_path)$size,
  sha256 = digest::digest(readBin(input_path, "raw", file.info(input_path)$size),
    algo = "sha256", serialize = FALSE))
write.csv(inputs, "data/september_reporting_gap_inputs.csv", row.names = FALSE)
all_localities <- filter(summary, population == "all_19")
stopifnot(sum(all_localities$events) == 23L,
  all_localities$events[all_localities$provenance_group == "kst_only"] == 21L,
  all_localities$pre_origin_listed_material[all_localities$provenance_group == "kst_only"] == 5L,
  sum(all_localities$all_dated_material_post_origin) == 16L,
  all(is.na(summary$certified_historical_count)))
print(summary)
cat("September source bottlenecks audited; complete historical counts remain unknown.\n")
