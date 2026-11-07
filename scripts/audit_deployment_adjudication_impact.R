# Calculate the consequences of adjudicated source coding without changing the
# frozen panel. Unit and geography decisions are crossed so their interaction
# is visible: a site swap need not cancel when one original point was excluded.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
output_directory <- "outputs/deployment_adjudication"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)

# Decisions are explicit static readings, supported by preserved original PDFs,
# the codebook and the provider's full component rows. Never overwrite them from
# a modern value merely to make an apparent discrepancy disappear.
sources <- read.csv("data/deployment_symbol_adjudication_sources.csv")
for (i in seq_len(nrow(sources))) {
  stopifnot(file.info(sources$path[i])$size == sources$bytes[i],
    digest::digest(readBin(sources$path[i], "raw", sources$bytes[i]),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
decisions <- read.csv("data/deployment_symbol_adjudication.csv")
geography <- read.csv("data/nyamilima_geography_correction_proposal.csv")
stopifnot(nrow(decisions) == 10L,
  !anyDuplicated(decisions[c("revision", "location")]),
  nrow(geography) == 1L, geography$candidate_locality_id == "COD009015",
  !geography$frozen_panel_corrected)
census <- read.csv("outputs/deployment_2021_2023/all_site_reconciliation.csv",
  na.strings = c("", "NA")) |>
  filter(revision %in% 49:51, catalog_present %in% TRUE) |>
  left_join(decisions |> select(revision, location, current_coded_military,
    adjudicated_military, decision), by = c("revision", "location"),
    relationship = "one-to-one")
stopifnot(nrow(census) == 96L,
  sum(!is.na(census$adjudicated_military)) == 10L,
  all(census$modern_military[!is.na(census$adjudicated_military)] ==
    census$current_coded_military[!is.na(census$adjudicated_military)]),
  all(is.na(census$locality_id[census$location == "Nyamilima"])))

# These are map-reference observations, not monthly or quarterly exposures.
# The candidate settlement point is adequate for a locality scenario; exact
# base coordinates, actual headcounts and historical digital bytes remain open.
scenarios <- expand_grid(unit_decisions = c(FALSE, TRUE),
  geography_decision = c(FALSE, TRUE)) |>
  mutate(scenario = case_when(
    unit_decisions & geography_decision ~ "combined_decisions",
    unit_decisions ~ "unit_decisions_only",
    geography_decision ~ "geography_only",
    TRUE ~ "original_coding"))
rows <- bind_rows(lapply(seq_len(nrow(scenarios)), function(i) {
  scenario_row <- scenarios[i, ]
  census |>
    transmute(revision, location, original_locality_id = locality_id,
      original_military = modern_military,
      scenario_locality_id = if_else(scenario_row$geography_decision &
        location == "Nyamilima", geography$candidate_locality_id, locality_id),
      scenario_military = if (scenario_row$unit_decisions)
        coalesce(adjudicated_military, modern_military) else modern_military,
      scenario = scenario_row$scenario,
      unit_decisions = scenario_row$unit_decisions,
      geography_decision = scenario_row$geography_decision,
      frozen_panel_changed = FALSE,
      complete_actual_strength_verified = FALSE)
}))
write.csv(rows, file.path(output_directory, "source_row_scenarios.csv"),
  row.names = FALSE, na = "")
affected_ids <- c("COD009015", "COMPOSITE_KABARE", "COMPOSITE_BENI")
totals <- rows |> filter(scenario_locality_id %in% affected_ids) |>
  group_by(revision, locality_id = scenario_locality_id, scenario) |>
  summarise(listed_source_rows = n(),
    listed_military_subtotal = if (anyNA(scenario_military)) NA_real_ else
      sum(scenario_military), .groups = "drop")
baseline <- totals |> filter(scenario == "original_coding") |>
  select(revision, locality_id, original_subtotal = listed_military_subtotal)
totals <- totals |> left_join(baseline, by = c("revision", "locality_id"),
  relationship = "many-to-one") |>
  mutate(change_from_original = listed_military_subtotal - original_subtotal,
    interpretation = "map_reference_coded_subtotal_not_actual_headcount",
    frozen_panel_changed = FALSE)
stopifnot(nrow(totals) == 36L, !anyNA(totals$listed_military_subtotal))
write.csv(totals, "data/deployment_adjudication_locality_impact.csv",
  row.names = FALSE)
print(totals |> filter(scenario == "combined_decisions"))
cat("Adjudication impact scenarios saved separately; no panel or model changed.\n")
