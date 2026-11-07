# Reconstruct archived event information for a fixed 2023-10-01 forecast origin.
# These are release-content comparisons, not certified complete as-of predictors.
# Current geography is held fixed to isolate event-record differences; its
# historical availability is a separate unresolved part of the reconstruction.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(sf)
origin <- as.Date("2023-10-01")
output_directory <- "outputs/forecast_origin"
raw_directory <- file.path(output_directory, "raw")
dir.create(raw_directory, recursive = TRUE, showWarnings = FALSE)
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
  algo = "sha256", serialize = FALSE)
expected_hash <- c("95576442d36c612bb88ea766d0aa1c8075ca65a60cc6a59fd6ce90e79bb430c5",
  "388c48cb356ce46095ddaa5448ed5d182e3de41d0ca1e34fd84acb7faa19a94b",
  "e8363b6647421d70da5460b7ab7d0dbf20f005bcc00f58c37d119e07d950a852")
source_paths <- sprintf("%s/GEDEvent_v23_0_%s.csv", raw_directory, 7:9)
source_urls <- sprintf("https://ucdp.uu.se/downloads/candidateged/GEDEvent_v23_0_%s.csv", 7:9)
for (i in seq_along(source_paths)) {
  if (!file.exists(source_paths[i])) download.file(source_urls[i], source_paths[i], mode = "wb")
  stopifnot(hash_file(source_paths[i]) == expected_hash[i])
}
archive_files <- lapply(seq_along(source_paths), function(i) {
  rows <- readr::read_csv(source_paths[i], show_col_types = FALSE)
  stopifnot(!anyDuplicated(rows$id), !anyNA(rows$id))
  mutate(rows, archive_month = i + 6L, archive_row = row_number())
})
archive_rows <- bind_rows(archive_files)
# Article dates are a byte-content sanity check, not release timestamps. Later
# dated material raises availability questions, while implausibly future dates
# may be coding errors; neither kind is silently corrected here.
summarize_source_dates <- function(rows, scope) {
  tokens <- rows |> select(id, source_date) |> separate_rows(source_date, sep = ";") |>
    mutate(source_date = trimws(source_date),
      missing_date = is.na(source_date) | source_date == "" | source_date == "1753-01-01",
      parsed_date = as.Date(ifelse(missing_date, NA_character_, source_date), format = "%Y-%m-%d"),
      invalid_date = !missing_date & (is.na(parsed_date) | format(parsed_date, "%Y-%m-%d") != source_date))
  stopifnot(!any(tokens$invalid_date))
  by_event <- tokens |> group_by(id) |> summarise(
    valid_dates = sum(!is.na(parsed_date)),
    all_dated_material_after_origin = any(!is.na(parsed_date)) && all(parsed_date > origin, na.rm = TRUE),
    any_dated_material_after_origin = any(parsed_date > origin, na.rm = TRUE), .groups = "drop")
  data.frame(scope = scope, events = nrow(rows),
    events_without_valid_source_dates = sum(by_event$valid_dates == 0L),
    all_dated_material_after_origin = sum(by_event$all_dated_material_after_origin),
    any_dated_material_after_origin = sum(by_event$any_dated_material_after_origin),
    missing_date_tokens = sum(tokens$missing_date), invalid_date_tokens = sum(tokens$invalid_date),
    tokens_after_retrieval_date = sum(tokens$parsed_date > as.Date("2026-11-07"), na.rm = TRUE),
    maximum_source_date = if (all(is.na(tokens$parsed_date))) NA_character_ else
      as.character(max(tokens$parsed_date, na.rm = TRUE)))
}
source_date_checks <- bind_rows(lapply(seq_along(archive_files), function(i) {
  bind_rows(summarize_source_dates(archive_files[[i]], paste0("all_global_release_23_0_", i + 6L)),
    summarize_source_dates(filter(archive_files[[i]], country_id == 490),
      paste0("all_DRC_release_23_0_", i + 6L)))
}))
current_path <- "data/interim/ucdp/GEDEvent_v26_1.csv"
current <- readr::read_csv(current_path, show_col_types = FALSE)
stopifnot(!anyDuplicated(current$id))

# Rebuild the SAME fixed composite polygons from originals, assigning each
# release's own coordinates before applying precision and date rules.
boundary_path <- "data/raw/boundaries/salb_2018.geojson"
crosswalk_path <- "config/city_aggregation.csv"
boundaries <- st_read(boundary_path, quiet = TRUE) |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
  left_join(read.csv(crosswalk_path), by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id),
    locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = "drop")
stopifnot(nrow(boundaries) == 19L, all(st_is_valid(boundaries)))
inventory <- st_drop_geometry(boundaries)
coverage <- read.csv("outputs/quarterly_pilot/exposure_coverage.csv")
inventory <- inventory |> left_join(coverage |> select(locality_id,
  current_complete_sample = complete_locality), by = "locality_id", relationship = "one-to-one")

audit_rows <- function(rows, end_date_limit) {
  rows <- rows |> filter(country_id == 490) |> mutate(start_date = as.Date(date_start),
    end_date = as.Date(date_end), valid_coordinates = is.finite(longitude) & is.finite(latitude) &
      abs(longitude) <= 180 & abs(latitude) <= 90,
    valid_dates = !is.na(start_date) & !is.na(end_date) & start_date <= end_date,
    same_month = format(start_date, "%Y-%m") == format(end_date, "%Y-%m"),
    match_count = 0L, locality_id = NA_character_)
  valid <- which(rows$valid_coordinates)
  matches <- st_intersects(st_as_sf(rows[valid, ], coords = c("longitude", "latitude"), crs = 4326), boundaries)
  rows$match_count[valid] <- lengths(matches)
  rows$locality_id[valid] <- vapply(matches, function(index)
    if (length(index) == 1L) boundaries$locality_id[index] else NA_character_, character(1))
  rows |> mutate(reason = case_when(
    !valid_dates ~ "invalid_dates",
    start_date < as.Date("2023-07-01") | end_date > end_date_limit ~ "outside_comparison_dates",
    type_of_violence != 3 ~ "other_violence_type",
    !valid_coordinates ~ "invalid_coordinates",
    match_count > 1 ~ "multiple_polygon_matches",
    match_count == 0 ~ "outside_target_or_unmatched",
    where_prec != 1 ~ "location_precision_not_exact",
    !same_month ~ "cross_month_date_interval",
    TRUE ~ "eligible"))
}
windows <- data.frame(window = c("july_only", "july_august", "q3_conditional"),
  last_archive_month = 7:9, end = as.Date(c("2023-07-31", "2023-08-31", "2023-09-30")),
  availability = c("July version existed before origin; historical byte identity unverified",
    "August advertised before origin; historical CSV byte identity unverified",
    "Retrospective Q3 benchmark; includes post-origin listed sources"))
comparisons <- flows <- summaries <- transitions <- retained_source_dates <- list()
for (i in seq_len(nrow(windows))) {
  window <- windows$window[i]
  end_date_limit <- windows$end[i]
  subset <- archive_rows |> filter(archive_month <= windows$last_archive_month[i])
  # Cross-month records can repeat. Retain the last supplied representation in
  # THIS window, before filtering. Preserve every discarded copy in a local ledger.
  ranked <- subset |> arrange(id, desc(archive_month)) |> group_by(id) |>
    mutate(duplicate_rank = row_number()) |> ungroup()
  archived <- ranked |> filter(duplicate_rank == 1L) |> audit_rows(end_date_limit)
  latest <- audit_rows(current, end_date_limit)
  write.csv(ranked, file.path(output_directory, paste0(window, "archive_rows.csv")), row.names = FALSE)
  write.csv(archived, file.path(output_directory, paste0(window, "archive_ledger.csv")), row.names = FALSE)
  write.csv(latest, file.path(output_directory, paste0(window, "current_ledger.csv")), row.names = FALSE)
  a <- archived |> filter(reason == "eligible")
  b <- latest |> filter(reason == "eligible")
  stopifnot(!anyDuplicated(a$id), !anyDuplicated(b$id))
  retained_source_dates[[i]] <- summarize_source_dates(a, paste0("retained_", window))
  comparisons[[i]] <- inventory |>
    left_join(a |> count(locality_id, name = "archived_events"), by = "locality_id") |>
    left_join(b |> count(locality_id, name = "current_events"), by = "locality_id") |>
    mutate(across(c(archived_events, current_events), ~ replace_na(.x, 0L)),
      window = window, current_minus_archive = current_events - archived_events,
      availability = windows$availability[i], certified_full_prior_quarter_events = NA_integer_)
  flows[[i]] <- bind_rows(archived |> count(reason) |> mutate(dataset = "archived_candidate"),
    latest |> count(reason) |> mutate(dataset = "current_ged26_1")) |> mutate(window = window)
  stopifnot(nrow(comparisons[[i]]) == 19L, !anyDuplicated(comparisons[[i]]$locality_id),
    sum(flows[[i]]$n[flows[[i]]$dataset == "archived_candidate"]) == nrow(archived),
    sum(flows[[i]]$n[flows[[i]]$dataset == "current_ged26_1"]) == nrow(latest),
    all(is.na(comparisons[[i]]$certified_full_prior_quarter_events)))
  # ID overlap describes linkable records only. It does not adjudicate every
  # possible split/merge or renumbering between Candidate and later annual GED.
  matched <- full_join(a |> select(id, archive_locality = locality_id),
    b |> select(id, current_locality = locality_id), by = "id", relationship = "one-to-one") |>
    mutate(match_status = case_when(is.na(archive_locality) ~ "current_only_id",
      is.na(current_locality) ~ "archive_only_id", TRUE ~ "shared_id"))
  write.csv(matched, file.path(output_directory, paste0(window, "id_comparison.csv")), row.names = FALSE)
  transitions[[i]] <- bind_rows(
    a |> anti_join(b, by = "id") |> select(id) |>
      left_join(latest |> select(id, reason), by = "id", relationship = "one-to-one") |>
      mutate(direction = "archive_eligible_current_not_eligible",
        reason = replace_na(reason, "id_not_found_in_current_DRC_records")),
    b |> anti_join(a, by = "id") |> select(id) |>
      left_join(archived |> select(id, reason), by = "id", relationship = "one-to-one") |>
      mutate(direction = "current_eligible_archive_not_eligible",
        reason = replace_na(reason, "id_not_found_in_selected_archive_DRC_records"))) |>
    count(direction, reason, name = "events") |> mutate(window = window)
  summaries[[i]] <- data.frame(window = window, original_archive_rows = nrow(subset),
    duplicate_rows_removed = sum(ranked$duplicate_rank > 1L),
    drc_unique_archive_rows = nrow(archived), archived_events = nrow(a), current_events = nrow(b),
    archived_core_events = sum(a$locality_id %in% inventory$locality_id[inventory$current_complete_sample]),
    current_core_events = sum(b$locality_id %in% inventory$locality_id[inventory$current_complete_sample]),
    shared_ids = sum(matched$match_status == "shared_id"),
    archive_only_ids = sum(matched$match_status == "archive_only_id"),
    current_only_ids = sum(matched$match_status == "current_only_id"),
    shared_ids_changed_locality = sum(matched$archive_locality != matched$current_locality, na.rm = TRUE))
}
write.csv(bind_rows(comparisons), "data/forecast_origin_event_comparison.csv", row.names = FALSE, na = "")
write.csv(bind_rows(flows), "data/forecast_origin_event_flow.csv", row.names = FALSE)
write.csv(bind_rows(summaries), "data/forecast_origin_event_summary.csv", row.names = FALSE)
write.csv(bind_rows(transitions), "data/forecast_origin_event_transitions.csv", row.names = FALSE)
write.csv(bind_rows(source_date_checks, bind_rows(retained_source_dates)),
  "data/forecast_origin_event_source_dates.csv", row.names = FALSE)
paths <- c(source_paths, current_path, boundary_path, crosswalk_path,
  "outputs/quarterly_pilot/exposure_coverage.csv",
  "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv")
manifest <- data.frame(path = paths, source = c(source_urls,
  "Extracted from retained GED26.1 ZIP in data/source_manifest.csv",
  "Retained SALB2018 geometry in data/source_manifest.csv", "Project city-territory crosswalk",
  "Current sample marker only; not historical eligibility", "Current Q4 lag-count reconciliation"),
  bytes = file.info(paths)$size, sha256 = vapply(paths, hash_file, character(1)),
  retrieved_for_this_comparison = c(rep("2026-11-07", 3), rep("retained_project_input", 5)))
write.csv(manifest, "data/forecast_origin_event_inputs.csv", row.names = FALSE)
# Verify the current full-quarter reconstruction exactly reconciles to the frozen
# Q4 panel's lagged count, rather than assuming similar total counts are enough.
panel <- read.csv("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv") |>
  filter(year == 2023, quarter == 4) |> select(locality_id, events_lag)
reconciliation <- comparisons[[3]] |> inner_join(panel, by = "locality_id", relationship = "one-to-one")
stopifnot(nrow(reconciliation) == 19L, all(reconciliation$current_events == reconciliation$events_lag),
  all(is.na(reconciliation$certified_full_prior_quarter_events)))
print(bind_rows(summaries))
cat("All 19 current Q4 lag counts reconciled; as-of full-quarter counts remain unknown.\n")
