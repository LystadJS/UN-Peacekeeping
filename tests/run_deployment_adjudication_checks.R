# Independent checks of the adjudication decisions, source lineage and impact.
# Successful checks validate these declared corrections, not actual headcounts
# or a complete information set at the historical forecast origin.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
manifest_paths <- c("data/deployment_coding_conventions_sources.csv",
  "data/nyamilima_geography_sources.csv", "data/deployment_symbol_adjudication_sources.csv")
sources <- bind_rows(lapply(manifest_paths, read.csv)) |>
  select(path, bytes, sha256) |> distinct()
stopifnot(nrow(sources) == 8L, !anyDuplicated(sources$path))
for (i in seq_len(nrow(sources))) {
  bytes <- readBin(sources$path[i], "raw", file.info(sources$path[i])$size)
  stopifnot(length(bytes) == sources$bytes[i],
    digest::digest(bytes, algo = "sha256", serialize = FALSE) == sources$sha256[i])
}

decisions <- read.csv("data/deployment_symbol_adjudication.csv")
prior <- read.csv("data/deployment_2021_2023_component_differences.csv")
joined <- inner_join(decisions, prior, by = c("revision", "location"),
  relationship = "one-to-one")
stopifnot(nrow(decisions) == 10L, nrow(joined) == 10L,
  all(joined$prior_visual_military == joined$sized_military),
  all(joined$current_coded_military == joined$modern_military),
  all(decisions$adjudicated_military == 650 * decisions$military_battalions +
    150 * decisions$military_companies), !any(decisions$complete_actual_strength_verified),
  sum(decisions$decision == "prior_transcription_error_resolved") == 3L,
  sum(decisions$decision == "fpu_subtraction_inconsistency_resolved") == 1L,
  sum(decisions$decision == "source_map_site_assignment_adjudicated") == 6L)

# Explain the original discrepancies from source fields, including the separate
# unresolved August contributor subtotal. Do not mistake a subtotal for a total.
components <- read.csv("data/deployment_coding_conventions_audit.csv")
bukavu <- filter(components, revision == 49, location == "Bukavu")
mavivi <- filter(components, location == "Mavivi")
stopifnot(nrow(components) == 12L, nrow(bukavu) == 1L, nrow(mavivi) == 3L,
  bukavu$total_coded == 450, bukavu$fpu_coded == 0, bukavu$fpu_type_listed,
  bukavu$second_tcc == "Egypt", bukavu$second_tcc_coded == 150,
  all(mavivi$total_coded == 2200), all(mavivi$company == 6),
  all(mavivi$helicopter_unsized_in_comment),
  mavivi$known_tcc_subtotal[mavivi$revision == 51] == 2350,
  sum(components$tcc_minus_total != 0) == 1L)

geography <- read.csv("data/nyamilima_geography_adjudication.csv")
proposal <- read.csv("data/nyamilima_geography_correction_proposal.csv")
versions <- read.csv("outputs/nyamilima_adjudication/osm_coordinate_history.csv")
stopifnot(nrow(geography) == 2L, nrow(proposal) == 1L, nrow(versions) == 4L,
  proposal$candidate_locality_id == "COD009015",
  proposal$displacement_km > 235, proposal$displacement_km < 237,
  proposal$candidate_boundary_margin_km > 2.7,
  proposal$candidate_boundary_margin_km < 2.9,
  all(versions$timestamp < "2023-10-01T00:00:00Z"),
  length(unique(versions$longitude)) == 1L, length(unique(versions$latitude)) == 1L,
  !proposal$exact_military_base_point_verified,
  !proposal$contemporaneous_download_bytes_authenticated, !proposal$frozen_panel_corrected,
  geography$salb_admin1[geography$point_type == "current_geopko"] == "Maniema",
  geography$salb_admin2[geography$point_type == "current_geopko"] == "Lubutu")

rows <- read.csv("outputs/deployment_adjudication/source_row_scenarios.csv")
impact <- read.csv("data/deployment_adjudication_locality_impact.csv")
stopifnot(nrow(rows) == 384L,
  !anyDuplicated(rows[c("revision", "location", "scenario")]),
  !any(rows$frozen_panel_changed), !any(rows$complete_actual_strength_verified),
  nrow(impact) == 36L,
  !anyDuplicated(impact[c("revision", "locality_id", "scenario")]),
  all(impact$change_from_original[impact$scenario == "original_coding"] == 0))
combined <- filter(impact, scenario == "combined_decisions")
stopifnot(all(combined$change_from_original[combined$locality_id == "COD009015"] == 650),
  all(combined$change_from_original[combined$locality_id == "COMPOSITE_BENI"] == 0),
  combined$change_from_original[combined$locality_id == "COMPOSITE_KABARE" & combined$revision == 49] == -150,
  all(combined$change_from_original[combined$locality_id == "COMPOSITE_KABARE" & combined$revision != 49] == 0),
  all(impact$change_from_original[impact$locality_id == "COD009015" & impact$scenario == "unit_decisions_only"] == 500),
  all(impact$change_from_original[impact$locality_id == "COD009015" & impact$scenario == "geography_only"] == 650))
source("scripts/record_analysis_snapshot.R")
cat("Adjudication checks passed: ten decisions, geographic evidence, residual inconsistency and crossed impacts.\n")
