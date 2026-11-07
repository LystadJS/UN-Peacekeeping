# Reconstruct event histories from versions documented in use before 1 Oct 2023.
# Version-level evidence does not authenticate today's bytes as historical copies.
# No deployment series, historical model or operational forecast is fabricated.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(sf)
output_directory <- "outputs/forecast_training"
raw_directory <- file.path(output_directory, "raw")
dir.create(raw_directory, recursive = TRUE, showWarnings = FALSE)
origin <- as.Date("2023-10-01")
quarter_index <- function(date) as.integer(format(date, "%Y")) * 4L +
  (as.integer(format(date, "%m")) - 1L) %/% 3L
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
  algo = "sha256", serialize = FALSE)
originals <- data.frame(
  path = c(file.path(raw_directory, "ged231-csv.zip"),
    file.path(raw_directory, "GEDEvent_v23_01_23_06.csv"),
    "outputs/forecast_origin/raw/GEDEvent_v23_0_7.csv",
    "outputs/forecast_origin/raw/GEDEvent_v23_0_8.csv"),
  url = c("https://ucdp.uu.se/downloads/ged/ged231-csv.zip",
    "https://ucdp.uu.se/downloads/candidateged/GEDEvent_v23_01_23_06.csv",
    "https://ucdp.uu.se/downloads/candidateged/GEDEvent_v23_0_7.csv",
    "https://ucdp.uu.se/downloads/candidateged/GEDEvent_v23_0_8.csv"),
  sha256 = c("9aa082f9e1f62da5ea3245c39b1cee45daab6dc8b3a17fb0f0cdae9ba13ce6f7",
    "a86195e4fdb438fb077b4cc12417cc060ae0dc485d11a5ad23e702a8cf51f419",
    "95576442d36c612bb88ea766d0aa1c8075ca65a60cc6a59fd6ce90e79bb430c5",
    "388c48cb356ce46095ddaa5448ed5d182e3de41d0ca1e34fd84acb7faa19a94b"))
for (i in seq_len(nrow(originals))) {
  dir.create(dirname(originals$path[i]), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(originals$path[i]))
    download.file(originals$url[i], originals$path[i], mode = "wb")
  stopifnot(hash_file(originals$path[i]) == originals$sha256[i])
}
annual_path <- file.path(raw_directory, "GEDEvent_v23_1.csv")
unzip(originals$path[1], exdir = raw_directory)

# Explicit types avoid guessing irrelevant numeric fields and preserve date text.
needed <- c("id", "year", "country_id", "type_of_violence", "where_prec",
  "latitude", "longitude", "date_start", "date_end", "source_date", "deaths_civilians")
read_events <- function(path) readr::read_csv(path, show_col_types = FALSE,
  col_select = all_of(needed), col_types = readr::cols(.default = readr::col_character(),
    id = readr::col_double(), year = readr::col_integer(), country_id = readr::col_integer(),
    type_of_violence = readr::col_integer(), where_prec = readr::col_integer(),
    latitude = readr::col_double(), longitude = readr::col_double(),
    deaths_civilians = readr::col_double()))
raw_sources <- list(ged_23_1 = read_events(annual_path),
  candidate_jan_jun = read_events(originals$path[2]), july = read_events(originals$path[3]),
  august = read_events(originals$path[4]))
stopifnot(all(vapply(raw_sources, function(x) !anyDuplicated(x$id) && !anyNA(x$id), logical(1))))
source_inventory <- bind_rows(lapply(names(raw_sources), function(name) data.frame(
  release = name, global_rows = nrow(raw_sources[[name]]),
  drc_rows = sum(raw_sources[[name]]$country_id == 490), within_file_duplicate_ids = 0L)))
write.csv(source_inventory, "data/forecast_training_source_inventory.csv", row.names = FALSE)
# A pre-cutoff archived provider page advertises August. Include the latest
# representation within the July-August window, preserving discarded copies.
partial_rows <- bind_rows(mutate(raw_sources$july, archive_month = 7L),
  mutate(raw_sources$august, archive_month = 8L)) |>
  arrange(id, desc(archive_month)) |> group_by(id) |>
  mutate(duplicate_rank = row_number()) |> ungroup()
write.csv(partial_rows, file.path(output_directory, "partial_month_duplicate_ledger.csv"), row.names = FALSE)
sources <- list(ged_23_1 = raw_sources$ged_23_1,
  candidate_jan_jun = raw_sources$candidate_jan_jun, july_partial = raw_sources$july,
  july_august_partial = partial_rows |> filter(duplicate_rank == 1L))

boundary_path <- "data/raw/boundaries/salb_2018.geojson"
crosswalk_path <- "config/city_aggregation.csv"
coverage_path <- "outputs/quarterly_pilot/exposure_coverage.csv"
history_path <- "outputs/quarterly_pilot/panel/history_grid_2014_2023.csv"
panel_path <- "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv"
boundaries <- st_read(boundary_path, quiet = TRUE) |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
  left_join(read.csv(crosswalk_path), by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id),
    locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = "drop")
stopifnot(nrow(boundaries) == 19L, all(st_is_valid(boundaries)))
inventory <- st_drop_geometry(boundaries) |>
  left_join(read.csv(coverage_path) |> select(locality_id, current_core = complete_locality),
    by = "locality_id", relationship = "one-to-one")

# Every vintage is filtered through its own coordinates, precision and dates.
# The annual and cumulative products have disjoint admitted occurrence windows;
# repeated IDs are audited, not silently selected by latest GED membership.
limits <- data.frame(release = names(sources),
  first = as.Date(c("2014-01-01", "2023-01-01", "2023-07-01", "2023-07-01")),
  last = as.Date(c("2022-12-31", "2023-06-30", "2023-07-31", "2023-08-31")))
audit_release <- function(rows, release_name) {
  limit <- limits[limits$release == release_name, ]
  rows <- rows |> filter(country_id == 490) |>
    mutate(start_date = as.Date(date_start), end_date = as.Date(date_end),
      valid_dates = !is.na(start_date) & !is.na(end_date) & start_date <= end_date,
      valid_coordinates = is.finite(longitude) & is.finite(latitude) &
        abs(longitude) <= 180 & abs(latitude) <= 90,
      match_count = 0L, locality_id = NA_character_)
  valid <- which(rows$valid_coordinates)
  matches <- st_intersects(st_as_sf(rows[valid, ], coords = c("longitude", "latitude"), crs = 4326), boundaries)
  rows$match_count[valid] <- lengths(matches)
  rows$locality_id[valid] <- vapply(matches, function(x)
    if (length(x) == 1L) boundaries$locality_id[x] else NA_character_, character(1))
  rows |> mutate(release = release_name, source_quarter = quarter_index(start_date),
    reason = case_when(!valid_dates ~ "invalid_dates",
      start_date < limit$first | end_date > limit$last ~ "outside_source_occurrence_window",
      type_of_violence != 3 ~ "other_violence_type",
      !valid_coordinates ~ "invalid_coordinates", match_count > 1L ~ "multiple_polygon_matches",
      match_count == 0L ~ "outside_target_or_unmatched", where_prec != 1L ~ "location_precision_not_exact",
      format(start_date, "%Y-%m") != format(end_date, "%Y-%m") ~ "cross_month_date_interval",
      TRUE ~ "eligible"))
}
ledger <- bind_rows(lapply(names(sources), function(name) audit_release(sources[[name]], name)))
stopifnot(!anyNA(ledger$reason))
write.csv(ledger, file.path(output_directory, "event_ledger.csv"), row.names = FALSE, na = "")
flow <- ledger |> count(release, reason, name = "records")
stopifnot(sum(flow$records) == nrow(ledger))
write.csv(flow, "data/forecast_training_event_flow.csv", row.names = FALSE)
eligible <- ledger |> filter(reason == "eligible")
stopifnot(!anyDuplicated(eligible[c("release", "id")]), !anyNA(eligible$deaths_civilians),
  !anyDuplicated(eligible$id[!grepl("partial", eligible$release)]))
pairs <- combn(names(raw_sources), 2L, simplify = FALSE)
duplicates <- bind_rows(lapply(pairs, function(pair) data.frame(
  release_a = pair[1], release_b = pair[2],
  global_shared_ids = length(intersect(raw_sources[[pair[1]]]$id, raw_sources[[pair[2]]]$id)),
  drc_shared_ids = length(intersect(raw_sources[[pair[1]]]$id[raw_sources[[pair[1]]]$country_id == 490],
    raw_sources[[pair[2]]]$id[raw_sources[[pair[2]]]$country_id == 490])))))
stopifnot(all(duplicates$drc_shared_ids == 0L))
write.csv(duplicates, "data/forecast_training_duplicate_audit.csv", row.names = FALSE)

# Publication clues are audited separately; source dates cannot certify release
# dates. Missing sentinels or malformed dates are never interpreted as available.
date_tokens <- eligible |> select(id, release, source_date) |>
  separate_rows(source_date, sep = ";") |> mutate(source_date = trimws(source_date),
    missing = is.na(source_date) | source_date == "" | source_date == "1753-01-01",
    parsed = as.Date(ifelse(missing, NA_character_, source_date), format = "%Y-%m-%d"),
    invalid = !missing & (is.na(parsed) | format(parsed, "%Y-%m-%d") != source_date))
stopifnot(!any(date_tokens$invalid))
date_events <- date_tokens |> group_by(release, id) |> summarise(
  no_valid_date = all(is.na(parsed)),
  all_sources_after_origin = any(!is.na(parsed)) && all(parsed > origin, na.rm = TRUE),
  any_source_after_origin = any(parsed > origin, na.rm = TRUE), .groups = "drop")
dates <- date_events |> group_by(release) |> summarise(events = n(),
  events_without_valid_source_dates = sum(no_valid_date),
  all_sources_after_origin = sum(all_sources_after_origin),
  any_source_after_origin = sum(any_source_after_origin), .groups = "drop")
write.csv(dates, "data/forecast_training_source_dates.csv", row.names = FALSE)

# Only full occurrence quarters through June enter the complete-quarter counts.
# July is a separate partial count. Q3/Q4 are NA, not zero, in the training grid.
totals <- eligible |> filter(!grepl("partial", release)) |>
  group_by(locality_id, source_quarter) |> summarise(recorded_events = n(),
    civilian_fatalities = sum(deaths_civilians), .groups = "drop")
grid <- crossing(locality_id = inventory$locality_id, source_quarter = (2014L * 4L):(2023L * 4L + 3L)) |>
  left_join(totals, by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  mutate(complete_occurrence_quarter = source_quarter <= 2023L * 4L + 1L,
    recorded_events = ifelse(complete_occurrence_quarter, replace_na(recorded_events, 0L), NA_integer_),
    civilian_fatalities = ifelse(complete_occurrence_quarter, replace_na(civilian_fatalities, 0), NA_real_),
    year = source_quarter %/% 4L, quarter = source_quarter %% 4L + 1L)
make_history <- function(rows) {
  rows <- arrange(rows, source_quarter)
  spell <- rep(NA_integer_, nrow(rows)); censored <- rep(NA, nrow(rows))
  for (i in seq_len(nrow(rows))) {
    value <- rows$recorded_events[i]
    if (is.na(value)) next
    if (value == 0L) { spell[i] <- 0L; censored[i] <- FALSE } else {
      spell[i] <- if (i == 1L) 1L else spell[i - 1L] + 1L
      censored[i] <- if (i == 1L) TRUE else censored[i - 1L]
    }
  }
  rows |> mutate(events_lag = lag(recorded_events), log1p_events_lag = log1p(events_lag),
    violent_spell_lag_observed = lag(spell), violent_spell_left_censored = lag(censored),
    violent_spell_lag = ifelse(violent_spell_left_censored, NA_integer_, violent_spell_lag_observed),
    history_outcome_quarter = lag(source_quarter))
}
grid <- grid |> group_by(locality_id) |> group_modify(~ make_history(.x)) |> ungroup() |>
  left_join(inventory, by = "locality_id", relationship = "many-to-one") |>
  mutate(availability = ifelse(complete_occurrence_quarter,
    "Named versions documented in pre-origin use; historical byte identity unverified",
    "Full-quarter information not reconstructed"))
write.csv(grid, file.path(output_directory, "training_history_grid.csv"), row.names = FALSE, na = "")
stopifnot(nrow(grid) == 760L, sum(grid$complete_occurrence_quarter) == 722L,
  all(is.na(grid$recorded_events[grid$year == 2023 & grid$quarter >= 3])),
  all(is.na(grid$events_lag[grid$year == 2023 & grid$quarter == 4])),
  all(is.na(grid$violent_spell_lag[grid$year == 2023 & grid$quarter == 4])))

current <- read.csv(history_path)
fields <- c("recorded_events", "civilian_fatalities", "events_lag", "log1p_events_lag",
  "violent_spell_lag_observed", "violent_spell_left_censored", "violent_spell_lag")
comparison <- grid |> filter(year >= 2016, complete_occurrence_quarter) |>
  left_join(current |> select(locality_id, source_quarter, all_of(fields)),
    by = c("locality_id", "source_quarter"), suffix = c("_archive", "_current"), relationship = "one-to-one")
stopifnot(nrow(comparison) == 570L, !anyDuplicated(comparison[c("locality_id", "source_quarter")]))
write.csv(comparison, file.path(output_directory, "training_history_comparison.csv"), row.names = FALSE, na = "")
equal_values <- function(a, b) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(as.numeric(a) - as.numeric(b)) < 1e-10)
field_comparison <- bind_rows(lapply(c("all_19", "current_core_9"), function(population) {
  rows <- if (population == "all_19") comparison else filter(comparison, current_core)
  bind_rows(lapply(fields, function(field) data.frame(population = population, field = field,
    locality_quarters = nrow(rows), equal_including_missing = sum(equal_values(rows[[paste0(field, "_archive")]], rows[[paste0(field, "_current")]])),
    changed = sum(!equal_values(rows[[paste0(field, "_archive")]], rows[[paste0(field, "_current")]])))))
}))
write.csv(field_comparison, "data/forecast_training_field_comparison.csv", row.names = FALSE)
quarterly <- comparison |> group_by(year, quarter) |> summarise(localities = n(),
  archive_events = sum(recorded_events_archive), current_events = sum(recorded_events_current),
  archive_core_events = sum(recorded_events_archive[current_core]),
  current_core_events = sum(recorded_events_current[current_core]),
  changed_locality_counts = sum(recorded_events_archive != recorded_events_current), .groups = "drop")
write.csv(quarterly, "data/forecast_training_quarter_comparison.csv", row.names = FALSE)
locality_summary <- comparison |> group_by(locality_id, locality, current_core) |>
  summarise(complete_training_quarters = n(), archive_events = sum(recorded_events_archive),
    current_events = sum(recorded_events_current), changed_quarter_counts = sum(recorded_events_archive != recorded_events_current),
    changed_prior_counts = sum(!equal_values(events_lag_archive, events_lag_current)),
    changed_spell_lengths = sum(!equal_values(violent_spell_lag_archive, violent_spell_lag_current)), .groups = "drop")
write.csv(locality_summary, "data/forecast_training_locality_comparison.csv", row.names = FALSE)
availability <- inventory |> left_join(eligible |> filter(release == "july_partial") |>
  count(locality_id, name = "july_partial_events"), by = "locality_id", relationship = "one-to-one") |>
  left_join(eligible |> filter(release == "july_august_partial") |>
    count(locality_id, name = "july_august_partial_events"), by = "locality_id", relationship = "one-to-one") |>
  mutate(july_partial_events = replace_na(july_partial_events, 0L),
    july_august_partial_events = replace_na(july_august_partial_events, 0L),
    latest_complete_occurrence_quarter = "2023Q2", complete_training_quarters_2016_onward = 30L,
    q3_full_events = NA_integer_, origin_q4_events_lag = NA_integer_, origin_q4_violent_spell_lag = NA_integer_,
    historical_byte_identity_verified = FALSE, deployment_history_reconstructed = FALSE)
write.csv(availability, "data/forecast_training_availability.csv", row.names = FALSE, na = "")

# Independently ensure the current-history comparator agrees with current panel
# fields, not merely with a differently named history file.
panel <- read.csv(panel_path) |> filter(year >= 2016, year < 2023 | quarter <= 2)
panel <- panel[match(paste(comparison$locality_id, comparison$source_quarter), paste(panel$locality_id, panel$source_quarter)), ]
stopifnot(nrow(panel) == 570L, all(vapply(fields, function(field)
  all(equal_values(comparison[[paste0(field, "_current")]], panel[[field]])), logical(1))))
paths <- c(originals$path, annual_path, boundary_path, crosswalk_path, coverage_path, history_path, panel_path)
manifest <- data.frame(path = paths, source = c(originals$url, "Extracted from pinned GED23.1 ZIP",
  "Retained SALB2018 geometry", "Project composite crosswalk", "Current sample marker only",
  "Current GED26.1 history comparator", "Current frozen panel reconciliation"),
  bytes = file.info(paths)$size, sha256 = vapply(paths, hash_file, character(1)), pinned_on = "2026-11-07")
write.csv(manifest, "data/forecast_training_inputs.csv", row.names = FALSE)
print(quarterly |> summarise(archive_events = sum(archive_events), current_events = sum(current_events),
  archive_core_events = sum(archive_core_events), current_core_events = sum(current_core_events),
  changed_locality_counts = sum(changed_locality_counts)))
print(field_comparison)
cat("570 training comparisons reconstructed; all Q3 totals and Q4 event-history inputs remain unknown.\n")
