# Distinguish dated September reporting from an available September GED release.
# Reuse the already audited, version-specific event ledgers and preserve all
# underlying rows locally. Publication dates alone never certify coded availability.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
origin <- as.Date("2023-10-01")
output_directory <- "outputs/september_2023"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
# The static evidence ledger fingerprints retrieved pages and archive responses.
# Changed source artifacts must not silently replace the inspected evidence.
evidence <- read.csv("data/september_2023_evidence.csv")
for (i in seq_len(nrow(evidence))) {
  stopifnot(file.info(evidence$path[i])$size == evidence$bytes[i],
    digest::digest(readBin(evidence$path[i], "raw", n = evidence$bytes[i]),
      algo = "sha256", serialize = FALSE) == evidence$sha256[i])
}
october_6 <- paste(readLines("outputs/september_2023/ucdp_downloads_20231006.html", warn = FALSE), collapse = "\n")
october_30 <- paste(readLines("outputs/september_2023/ucdp_downloads_20231030.html", warn = FALSE), collapse = "\n")
stopifnot(grepl("August 2023: Version 23.0.8", october_6, fixed = TRUE),
  grepl("September 2023: Version 23.0.9", october_30, fixed = TRUE),
  grepl("candidateged/GEDEvent_v23_0_9.csv", october_30, fixed = TRUE))
paths <- c(candidate_23_0_9 = "outputs/forecast_origin/q3_conditionalarchive_ledger.csv",
  current_ged_26_1 = "outputs/forecast_origin/q3_conditionalcurrent_ledger.csv")
coverage_path <- "outputs/quarterly_pilot/exposure_coverage.csv"
coverage <- read.csv(coverage_path)
core_ids <- coverage$locality_id[coverage$complete_locality]
summaries <- localities <- list()
for (version in names(paths)) {
  ledger <- read.csv(paths[[version]], stringsAsFactors = FALSE)
  rows <- ledger |> filter(reason == "eligible", start_date >= "2023-09-01",
    end_date <= "2023-09-30")
  stopifnot(!anyDuplicated(rows$id))
  tokens <- rows |> select(id, source_date) |> separate_rows(source_date, sep = ";") |>
    mutate(source_date = trimws(source_date),
      missing_date = is.na(source_date) | source_date == "" | source_date == "1753-01-01",
      parsed = as.Date(ifelse(missing_date, NA_character_, source_date), format = "%Y-%m-%d"),
      invalid = !missing_date & (is.na(parsed) | format(parsed, "%Y-%m-%d") != source_date))
  stopifnot(!any(tokens$invalid))
  dates <- tokens |> group_by(id) |> summarise(valid_dates = sum(!is.na(parsed)),
    has_pre_origin_material = any(parsed < origin, na.rm = TRUE),
    has_origin_day_material = any(parsed == origin, na.rm = TRUE),
    has_post_origin_material = any(parsed > origin, na.rm = TRUE),
    all_dated_material_post_origin = any(!is.na(parsed)) && all(parsed > origin, na.rm = TRUE),
    .groups = "drop")
  rows <- rows |> left_join(dates, by = "id", relationship = "one-to-one") |>
    mutate(version = version, current_core = locality_id %in% core_ids,
      certified_available_coded_record = NA,
      interpretation = "Listed-source timing proxy; not an authenticated historical GED record")
  write.csv(rows, file.path(output_directory, paste0(version, "_september_ledger.csv")),
    row.names = FALSE, na = "")
  summaries[[version]] <- bind_rows(lapply(c("all_19", "current_core_9"), function(population) {
    subset <- if (population == "all_19") rows else filter(rows, current_core)
    data.frame(version = version, population = population, retained_september_events = nrow(subset),
      events_with_pre_origin_listed_material = sum(subset$has_pre_origin_material),
      events_with_origin_day_material = sum(subset$has_origin_day_material),
      events_with_post_origin_material = sum(subset$has_post_origin_material),
      events_all_dated_material_post_origin = sum(subset$all_dated_material_post_origin),
      events_without_valid_dates = sum(subset$valid_dates == 0L),
      certified_complete_september_count = NA_integer_)
  }))
  localities[[version]] <- coverage |> select(locality_id, locality, current_core = complete_locality) |>
    left_join(rows |> group_by(locality_id) |> summarise(retained_september_events = n(),
      events_with_pre_origin_listed_material = sum(has_pre_origin_material), .groups = "drop"),
      by = "locality_id", relationship = "one-to-one") |>
    mutate(version = version,
      across(c(retained_september_events, events_with_pre_origin_listed_material), ~replace_na(.x, 0L)),
      certified_complete_september_count = NA_integer_)
}
summary <- bind_rows(summaries)
locality_summary <- bind_rows(localities)
stopifnot(nrow(summary) == 4L, nrow(locality_summary) == 38L,
  !anyDuplicated(locality_summary[c("version", "locality_id")]),
  all(is.na(summary$certified_complete_september_count)))
write.csv(summary, "data/september_2023_summary.csv", row.names = FALSE, na = "")
write.csv(locality_summary, "data/september_2023_locality_summary.csv", row.names = FALSE, na = "")
inputs <- c(unname(paths), coverage_path)
manifest <- data.frame(path = inputs, bytes = file.info(inputs)$size,
  sha256 = vapply(inputs, function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
    algo = "sha256", serialize = FALSE), character(1)),
  scope = c("Audited archived Candidate window; not available-by-cutoff proof",
    "Audited current GED window; retrospective comparator", "Current sample marker only"))
write.csv(manifest, "data/september_2023_inputs.csv", row.names = FALSE)
print(summary)
cat("September source-date proxies audited; certified September totals remain unknown.\n")
