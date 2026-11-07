# Reconstruct a historical deployment-training prefix and check selected map symbols.
# This is a supplement, not a replacement panel or a fitted forecasting model.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(sf)
output_directory <- "outputs/forecast_origin/coding"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
sources <- read.csv("data/forecast_origin_coding_sources.csv")
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
  algo = "sha256", serialize = FALSE)
for (i in seq_len(nrow(sources))) {
  if (!file.exists(sources$path[i])) download.file(sources$url[i], sources$path[i], mode = "wb")
  stopifnot(hash_file(sources$path[i]) == sources$sha256[i])
}

# The transcription is an explicit agent visual reading of three dated maps.
# Only clear selected symbols are coded. Unsized MP units remain outside the
# sized-unit component, so its sum is not the complete actual military strength.
transcription <- read.csv("data/forecast_origin_coding_transcription.csv") |>
  mutate(source = paste0("Map No. 4412 Rev. ", revision),
    reconstructed_sized_military = 650 * military_battalions +
      150 * military_companies + 35 * military_platoons,
    reconstructed_fpu = 150 * fpu_companies,
    reconstructed_including_fpu = reconstructed_sized_military + reconstructed_fpu)
modern <- readRDS("data/raw/geo_pko/2.3/location_map.rds") |> ungroup()
modern_selected <- modern |> filter(mission == "MONUSCO", year == 2023,
    source %in% transcription$source) |>
  select(source, location, no.troops, fpu.no, geosplit, comment.on.unit)
manual_comparison <- transcription |>
  left_join(modern_selected, by = c("source", "location"), relationship = "one-to-one") |>
  mutate(modern_total = as.numeric(no.troops), modern_fpu = as.numeric(fpu.no),
    modern_military = modern_total - modern_fpu,
    sized_military_difference = reconstructed_sized_military - modern_military,
    fpu_difference = reconstructed_fpu - modern_fpu,
    interpretation = "Selected sized-unit component only; not actual or complete military strength")
stopifnot(nrow(manual_comparison) == 30L,
  !anyDuplicated(manual_comparison[c("source", "location")]),
  !anyNA(manual_comparison$modern_total), all(manual_comparison$geosplit == 0),
  all(manual_comparison$sized_military_difference == 0),
  all(manual_comparison$fpu_difference == 0))
write.csv(manual_comparison, "data/forecast_origin_coding_symbol_comparison.csv", row.names = FALSE)

# Rebuild fixed research geography independently from the original SALB file.
# Its historical digital availability is still unverified. Geometry is held fixed
# so historical-vs-current coding can be compared on the same locality units.
boundaries <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE) |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
  left_join(read.csv("config/city_aggregation.csv"), by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id), locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = "drop")
stopifnot(nrow(boundaries) == 19L, all(st_is_valid(boundaries)))
historical_all <- readr::read_csv(sources$path[sources$source_id == "geopko_2_0"],
  col_types = readr::cols(.default = "c"))
historical <- historical_all |> mutate(original_row = row_number()) |>
  filter(mission == "MONUSCO") |>
  mutate(year = as.integer(year), month = as.integer(month),
    map_date = as.Date(sprintf("%04d-%02d-01", year, month)),
    longitude = as.numeric(longitude), latitude = as.numeric(latitude),
    military = suppressWarnings(as.numeric(no.troops)) - suppressWarnings(as.numeric(fpu.no)),
    valid_coordinates = is.finite(longitude) & is.finite(latitude) &
      abs(longitude) <= 180 & abs(latitude) <= 90,
    match_count = 0L, locality_id = NA_character_)
valid <- which(historical$valid_coordinates)
matches <- st_intersects(st_as_sf(historical[valid, ], coords = c("longitude", "latitude"), crs = 4326), boundaries)
historical$match_count[valid] <- lengths(matches)
historical$locality_id[valid] <- vapply(matches, function(index)
  if (length(index) == 1L) boundaries$locality_id[index] else NA_character_, character(1))
stopifnot(nrow(historical_all) == 17927L, nrow(historical) == 1198L,
  max(historical$map_date) == as.Date("2019-12-01"), !anyNA(historical$map_date))
write.csv(historical, file.path(output_directory, "historical_map_lineage.csv"), row.names = FALSE)
write.csv(historical |> count(match_count, valid_coordinates, name = "rows"),
  "data/forecast_origin_coding_geography_audit.csv", row.names = FALSE)

# The historical CSV includes superseded revisions for the SAME map month.
# Adding them would duplicate units. All versions are in the pinned2020 commit,
# so select the highest numbered revision within each month for this2023 origin.
# Preserve the selection ledger rather than silently deduplicating locations.
revision_ledger <- historical |> distinct(map_date, source) |>
  mutate(revision = ifelse(grepl("original", source, ignore.case = TRUE), 0,
    suppressWarnings(as.numeric(sub("^.*[Rr]ev[.] *", "", trimws(source)))))) |>
  group_by(map_date) |>
  mutate(selected = revision == max(revision), revisions_for_month = n()) |> ungroup()
stopifnot(!anyNA(revision_ledger$revision),
  !anyDuplicated(revision_ledger$map_date[revision_ledger$selected]))
write.csv(revision_ledger, "data/forecast_origin_coding_revision_ledger.csv", row.names = FALSE)
historical_selected <- historical |> inner_join(
  revision_ledger |> filter(selected) |> select(map_date, source),
  by = c("map_date", "source"), relationship = "many-to-one")
stopifnot(!anyDuplicated(historical_selected[c("source", "location", "latitude", "longitude")]))

# Expand each mission map to represented months only through the archive's
# final observed month. Do not carry the December2019 map into later years.
# Geosplit values are already allocated in the published rows; never divide again.
month_number <- function(date) as.integer(format(date, "%Y")) * 12L + as.integer(format(date, "%m"))
quarter_index <- function(date) as.integer(format(date, "%Y")) * 4L +
  (as.integer(format(date, "%m")) - 1L) %/% 3L
map_dates <- sort(unique(historical_selected$map_date))
periods <- seq(as.Date("2014-01-01"), as.Date("2023-09-01"), by = "month")
monthly <- bind_rows(lapply(periods, function(period) {
  date <- as.Date(period, origin = "1970-01-01")
  before_end <- date <= max(map_dates)
  latest_map <- max(map_dates[map_dates <= date])
  age <- month_number(date) - month_number(latest_map)
  rows <- historical_selected |> filter(map_date == latest_map, match_count == 1L) |>
    group_by(locality_id) |>
    summarise(listed_rows = n(), strength = if (anyNA(military)) NA_real_ else sum(military), .groups = "drop")
  st_drop_geometry(boundaries) |> left_join(rows, by = "locality_id", relationship = "one-to-one") |>
    mutate(period = date, source_map_date = if (before_end) latest_map else as.Date(NA),
      map_age = if (before_end) age else NA_integer_,
      archived_strength = ifelse(before_end & age >= 0 & age <= 5 & is.finite(strength) & strength >= 0,
        strength / 1000, NA_real_),
      availability = case_when(!before_end ~ "outside_archived_release_coverage",
        is.na(listed_rows) ~ "unlisted_unknown", age > 5 ~ "stale_map",
        !is.finite(strength) ~ "unknown_numeric_strength", TRUE ~ "archived_listed_strength")) |>
    select(-strength, -listed_rows)
}))
write.csv(monthly, file.path(output_directory, "historical_monthly_strength.csv"), row.names = FALSE, na = "")
quarterly <- monthly |> mutate(exposure_quarter = quarter_index(period)) |>
  group_by(locality_id, exposure_quarter) |>
  summarise(known_months = sum(!is.na(archived_strength)),
    archived_strength = if (n() == 3L && all(!is.na(archived_strength))) mean(archived_strength) else NA_real_,
    .groups = "drop")
panel <- read.csv("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv") |>
  filter(source_quarter < 2023L * 4L + 3L) |>
  select(locality_id, locality, province, source_quarter, year, quarter, core_sample,
    strength_lag, strength_lag2)
training <- panel |>
  left_join(quarterly |> transmute(locality_id, source_quarter = exposure_quarter + 1L,
    archived_strength_lag = archived_strength, known_months_lag = known_months),
    by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  left_join(quarterly |> transmute(locality_id, source_quarter = exposure_quarter + 2L,
    archived_strength_lag2 = archived_strength),
    by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
  mutate(difference_lag = archived_strength_lag - strength_lag,
    comparison_status = case_when(is.na(archived_strength_lag) & is.na(strength_lag) ~ "both_missing",
      is.na(archived_strength_lag) ~ "current_only_known", is.na(strength_lag) ~ "archive_only_known",
      abs(difference_lag) < 1e-10 ~ "both_known_equal", TRUE ~ "both_known_changed"),
    scope = "Historical2.0 numeric coding on fixed modern geography; partial training prefix")
stopifnot(nrow(training) == 589L, !anyDuplicated(training[c("locality_id", "source_quarter")]),
  all(is.na(training$archived_strength_lag[training$source_quarter > 2020L * 4L])))
write.csv(training, file.path(output_directory, "historical_training_strength.csv"), row.names = FALSE, na = "")
summary <- training |> count(core_sample, comparison_status, name = "locality_quarters")
write.csv(summary, "data/forecast_origin_coding_training_summary.csv", row.names = FALSE)
coverage <- training |> group_by(locality_id, locality, core_sample) |>
  summarise(training_quarters = n(), archived_known_lag_quarters = sum(!is.na(archived_strength_lag)),
    archived_known_lag2_quarters = sum(!is.na(archived_strength_lag2)),
    complete_as_of_centering_mean = if (all(!is.na(archived_strength_lag))) mean(archived_strength_lag) else NA_real_,
    .groups = "drop")
stopifnot(all(is.na(coverage$complete_as_of_centering_mean)))
write.csv(coverage, "data/forecast_origin_coding_training_coverage.csv", row.names = FALSE, na = "")
print(summary)
cat("30 selected map-symbol components and partial historical training strength reconstructed.\n")
