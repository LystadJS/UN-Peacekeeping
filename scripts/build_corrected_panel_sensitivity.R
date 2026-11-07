# Rebuild exposure histories under explicit source corrections, preserving the
# frozen outcome/history panel and its original complete-history sample.
# These are retrospective measurement sensitivities, not as-of forecasts.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
output_root <- "outputs/corrected_panel_sensitivity"
dir.create(output_root, recursive = TRUE, showWarnings = FALSE)
quarter_index <- function(date) as.integer(format(date, "%Y")) * 4L +
  (as.integer(format(date, "%m")) - 1L) %/% 3L
input_paths <- c("data/raw/geo_pko/2.3/location_map.rds",
  "data/raw/geo_pko/2.3/location_month.rds",
  "outputs/week_1/audit_aggregated/deployment_lineage.csv",
  "outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds",
  "data/deployment_symbol_adjudication.csv",
  "data/nyamilima_geography_correction_proposal.csv")
inputs <- data.frame(path = input_paths, bytes = file.info(input_paths)$size,
  sha256 = vapply(input_paths, function(path) digest::digest(
    readBin(path, "raw", file.info(path)$size), algo = "sha256", serialize = FALSE), character(1)))
write.csv(inputs, "data/corrected_panel_inputs.csv", row.names = FALSE)

frozen <- readRDS(input_paths[4])
stopifnot(nrow(frozen) == 608L, sum(frozen$core_sample) == 288L,
  !anyDuplicated(frozen[c("locality_id", "year", "quarter")]))
decisions <- read.csv(input_paths[5])
geography <- read.csv(input_paths[6])
stopifnot(nrow(decisions) == 10L, nrow(geography) == 1L,
  geography$candidate_locality_id == "COD009015", !geography$frozen_panel_corrected)
# Include older maps carried into2014 monthly history; age rules still exclude stale values.
# Non-numeric strength labels deliberately become NA, never zero.
maps <- readRDS(input_paths[1]) |> ungroup() |>
  mutate(map_source_row = row_number()) |>
  filter(mission == "MONUSCO", year >= 2013, year <= 2023) |>
  mutate(map_date = as.Date(sprintf("%04d-%02d-01", year, month)),
    location_clean = trimws(location),
    revision = as.numeric(sub(".*[Rr]ev[.]? *([0-9.]+).*", "\\1", source)),
    original_military = suppressWarnings(as.numeric(no.troops)) - as.numeric(fpu.no)) |>
  left_join(decisions |> select(revision, location_clean = location,
    adjudicated_military, adjudicated_fpu, decision),
    by = c("revision", "location_clean"), relationship = "one-to-one")
stopifnot(sum(maps$location_clean == "Nyamilima" & maps$year >= 2016) == 17L,
  sum(!is.na(maps$adjudicated_military)) == 10L)

# Link every published monthly row back to its exact map record, including
# coordinates and original strength. This preserves the provider's carry-forward
# schedule instead of creating new map dates or switching revisions by guesswork.
monthly_original <- readRDS(input_paths[2]) |> ungroup()
lineage <- read.csv(input_paths[3], na.strings = c("", "NA")) |>
  mutate(period = as.Date(period), map_date = as.Date(map_date),
    original_locality_id = locality_id,
    latitude = monthly_original$latitude[source_row],
    longitude = monthly_original$longitude[source_row],
    original_fpu = as.numeric(monthly_original$fpu.no[source_row]),
    original_military = suppressWarnings(as.numeric(no.troops)) - original_fpu)
keys <- c("source", "map_date", "location_clean", "latitude", "longitude", "no.troops")
map_lookup <- maps |> select(all_of(keys), map_source_row, revision,
  adjudicated_military, adjudicated_fpu, decision)
stopifnot(!anyDuplicated(map_lookup[keys]))
lineage <- lineage |> left_join(map_lookup, by = keys, relationship = "many-to-one")
stopifnot(!anyNA(lineage$map_source_row), !anyDuplicated(lineage$source_row),
  all(lineage$map_date <= lineage$period), all(lineage$map_age >= 0))
locality_ids <- unique(frozen$locality_id)

build_scenario <- function(scenario) {
  corrected <- scenario != "original_reconstructed"
  use_mavivi_alternative <- scenario == "mavivi_plus_150"
  rows <- lineage |> mutate(
    corrected_locality_id = if_else(corrected & location_clean == "Nyamilima",
      geography$candidate_locality_id, original_locality_id),
    scenario_latitude = if_else(corrected & location_clean == "Nyamilima", geography$candidate_latitude, latitude),
    scenario_longitude = if_else(corrected & location_clean == "Nyamilima", geography$candidate_longitude, longitude),
    scenario_fpu = if (corrected) coalesce(adjudicated_fpu, original_fpu) else original_fpu,
    military_strength = if (corrected) coalesce(adjudicated_military, original_military) else original_military,
    military_strength = if_else(use_mavivi_alternative & revision == 51 &
      location_clean == "Mavivi", military_strength + 150, military_strength),
    locality_changed = coalesce(original_locality_id, "") != coalesce(corrected_locality_id, ""),
    military_changed = !is.na(military_strength) & !is.na(original_military) &
      military_strength != original_military,
    scenario = scenario)
  monthly <- rows |> filter(!is.na(corrected_locality_id)) |>
    group_by(locality_id = corrected_locality_id, period) |>
    summarise(strength = if (anyNA(military_strength)) NA_real_ else sum(military_strength),
      max_age = max(map_age),
      sources = paste(sort(unique(paste(source, map_date))), collapse = ";"), .groups = "drop")
  grid <- crossing(locality_id = locality_ids,
    period = seq(as.Date("2014-01-01"), as.Date("2023-12-01"), by = "month")) |>
    left_join(monthly, by = c("locality_id", "period"), relationship = "one-to-one") |>
    mutate(source_quarter = quarter_index(period),
      acceptable = is.finite(strength) & strength >= 0 & is.finite(max_age) &
        max_age >= 0 & max_age <= 5)
  quarters <- grid |> group_by(locality_id, source_quarter) |>
    summarise(known_months = sum(acceptable),
      strength = if (n() == 3L && all(acceptable)) mean(strength) / 1000 else NA_real_,
      source_maps = paste(unique(na.omit(sources)), collapse = ";"), .groups = "drop") |>
    arrange(locality_id, source_quarter) |> group_by(locality_id) |>
    mutate(strength_lag = lag(strength), strength_lag2 = lag(strength, 2L),
      exposure_sources = lag(source_maps)) |> filter(source_quarter >= 2016L * 4L) |>
    mutate(strength_between = mean(strength_lag, na.rm = TRUE),
      strength_within = strength_lag - strength_between,
      reconstructed_complete_locality = all(!is.na(strength_lag))) |> ungroup()
  replacement_fields <- c("known_months", "strength", "source_maps", "strength_lag",
    "strength_lag2", "exposure_sources", "strength_between", "strength_within")
  panel <- frozen |> select(-all_of(replacement_fields)) |>
    left_join(quarters |> select(locality_id, source_quarter, all_of(replacement_fields),
      reconstructed_complete_locality),
      by = c("locality_id", "source_quarter"), relationship = "one-to-one") |>
    mutate(strength_lag_rebuilt = strength_lag)
  stopifnot(nrow(panel) == 608L,
    identical(panel$complete_locality, panel$reconstructed_complete_locality),
    identical(panel$history_complete,
      !is.na(panel$events_lag) & !is.na(panel$violent_spell_lag) & !is.na(panel$strength_lag2)))
  panel <- panel |> select(all_of(names(frozen)))
  stopifnot(identical(panel$recorded_events, frozen$recorded_events),
    identical(panel$core_sample, frozen$core_sample), is.factor(panel$season))
  directory <- file.path(output_root, scenario)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  write.csv(rows, file.path(directory, "monthly_source_lineage.csv"), row.names = FALSE, na = "")
  write.csv(grid, file.path(directory, "monthly_exposure_grid.csv"), row.names = FALSE, na = "")
  for (sample in c("all_localities", "complete_exposure")) {
    result <- if (sample == "all_localities") panel else filter(panel, core_sample)
    name <- paste0("quarterly_panel_", sample)
    write.csv(result, file.path(directory, paste0(name, ".csv")), row.names = FALSE, na = "")
    saveRDS(result, file.path(directory, paste0(name, ".rds")))
  }
  list(panel = panel, rows = rows)
}

# A zero-change reconstruction first checks every frozen field. This gate catches
# accidental changes to joins, timing, aggregation, lag construction or ordering.
reconstructed <- build_scenario("original_reconstructed")
for (name in names(frozen)) {
  a <- frozen[[name]]; b <- reconstructed$panel[[name]]
  stopifnot(identical(is.na(a), is.na(b)))
  if (is.numeric(a)) stopifnot(all(abs(a - b) < 1e-10, na.rm = TRUE)) else
    stopifnot(identical(as.character(a), as.character(b)))
}
scenarios <- c("supported_corrections", "mavivi_plus_150")
results <- lapply(scenarios, build_scenario)
names(results) <- scenarios
changed <- function(a, b) (!is.na(a) & !is.na(b) & abs(a - b) > 1e-10) |
  xor(is.na(a), is.na(b))
summaries <- lineage_summaries <- list()
for (scenario in scenarios) {
  result <- results[[scenario]]; panel <- result$panel
  differences <- panel |> select(locality_id, locality, year, quarter, core_sample,
    strength, strength_lag, strength_lag2, strength_between, strength_within)
  fields <- c("strength", "strength_lag", "strength_lag2", "strength_between", "strength_within")
  for (field in fields) {
    differences[[paste0("original_", field)]] <- frozen[[field]]
    differences[[paste0("change_", field)]] <- panel[[field]] - frozen[[field]]
  }
  write.csv(differences, file.path(output_root, scenario, "quarterly_exposure_changes.csv"),
    row.names = FALSE, na = "")
  summaries[[scenario]] <- bind_rows(lapply(fields, function(field) data.frame(
    scenario = scenario, field = field,
    changed_all_rows = sum(changed(panel[[field]], frozen[[field]])),
    changed_core_rows = sum(changed(panel[[field]], frozen[[field]]) & panel$core_sample),
    max_absolute_change = max(abs(panel[[field]] - frozen[[field]]), na.rm = TRUE),
    all_rows = nrow(panel), core_rows = sum(panel$core_sample))))
  lineage_summaries[[scenario]] <- result$rows |>
    filter(locality_changed | military_changed) |>
    group_by(scenario, location_clean, revision, map_date) |>
    summarise(monthly_rows = n(), first_month = min(period), last_month = max(period),
      locality_changed = any(locality_changed), military_changed = any(military_changed),
      original_military = first(original_military), scenario_military = first(military_strength),
      .groups = "drop")
}
write.csv(bind_rows(summaries), "data/corrected_panel_change_summary.csv", row.names = FALSE)
write.csv(bind_rows(lineage_summaries), "data/corrected_panel_lineage_summary.csv", row.names = FALSE)
write.csv(data.frame(scenario = c("original_reconstructed", scenarios),
  interpretation = c("Unchanged reconstruction gate against frozen panel",
    "Adjudicated settlement/locality and explicit source-component decisions",
    "Supported corrections plus unverified150-person Mavivi revision51 alternative"),
  original_panel_modified = FALSE, authenticated_historical_forecast = FALSE),
  "data/corrected_panel_scenarios.csv", row.names = FALSE)
print(bind_rows(summaries))
cat("Corrected panels rebuilt separately; original fields reproduced before corrections.\n")
