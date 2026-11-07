# Reconcile the August2023 contributor subtotal with source symbols and counts.
# This is a declared local analysis decision, not a provider-confirmed correction
# or a measurement of actual personnel. Retained provider bytes remain unchanged.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
output_directory <- "outputs/mavivi_subtotal_resolution"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
sources <- read.csv("data/mavivi_subtotal_sources.csv")
stopifnot(nrow(sources) == 3L, !anyDuplicated(sources$path))
for (i in seq_len(nrow(sources))) {
  stopifnot(file.info(sources$path[i])$size == sources$bytes[i],
    digest::digest(readBin(sources$path[i], "raw", sources$bytes[i]),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
rows <- readRDS(sources$path[sources$source_id == "provider_2_3_map_rows"]) |>
  ungroup() |> filter(mission == "MONUSCO", location == "Mavivi") |>
  mutate(revision = as.numeric(sub(".*[Rr]ev[.] *", "", source))) |>
  filter(revision %in% 48:57) |> arrange(revision)
stopifnot(nrow(rows) == 10L, identical(rows$revision, as.numeric(48:57)))
write.csv(rows, file.path(output_directory, "source_transition_rows.csv"), row.names = FALSE)
tcc_columns <- grep("^notroopspertcc_", names(rows), value = TRUE)
tcc_values <- as.data.frame(lapply(rows[tcc_columns], function(x) suppressWarnings(as.numeric(x))))
audit <- rows |>
  transmute(revision, source_year = year, source_month = month,
    total_coded = as.numeric(no.troops), battalions = battalion,
    companies = company, platoons = platoon,
    south_africa_coded = suppressWarnings(as.numeric(notroopspertcc_1)),
    south_africa_is_first_tcc = nameoftcc_1 == "South Africa",
    helicopter_unsized_in_comment = grepl("helicopter support unit.*size (not given|unknown)",
      comment.on.unit),
    after_forecast_origin = year > 2023 | (year == 2023 & month >= 10)) |>
  mutate(unit_count_total = 650 * battalions + 150 * companies + 35 * platoons,
    known_tcc_subtotal = rowSums(tcc_values, na.rm = TRUE),
    other_known_tcc_subtotal = known_tcc_subtotal - south_africa_coded,
    subtotal_minus_total = known_tcc_subtotal - total_coded)
stopifnot(all(audit$south_africa_is_first_tcc),
  all(audit$total_coded == 2200), all(audit$unit_count_total == 2200),
  all(audit$other_known_tcc_subtotal == 1250),
  all(audit$helicopter_unsized_in_comment),
  all(audit$south_africa_coded[audit$revision != 51] == 950),
  audit$south_africa_coded[audit$revision == 51] == 1100,
  sum(audit$subtotal_minus_total != 0) == 1L)
write.csv(audit, "data/mavivi_subtotal_transition_audit.csv", row.names = FALSE)

# The original August map was inspected at high resolution. South Africa has
# one sized infantry battalion, one QRF company and one TIU company. Helicopter
# support lacks a size bar, so assigning it150 would invent a sized component.
# The rest of the known countries supply Tanzania800 and Indonesia/Kenya/Nepal150
# each; Bangladesh MP has unknown size and is not converted to a zero headcount.
south_africa_from_symbols <- 650 + 150 + 150
adjudicated_total <- south_africa_from_symbols + audit$other_known_tcc_subtotal[audit$revision == 51]
decision <- data.frame(revision = 51L, location = "Mavivi",
  original_south_africa_subtotal = 1100,
  adjudicated_south_africa_subtotal = south_africa_from_symbols,
  original_known_tcc_subtotal = 2350, source_total = 2200,
  adjudicated_sized_total = adjudicated_total,
  alternative_total_for_sensitivity = 2350,
  disposition = "resolved_for_source_consistent_analysis_scenario",
  original_provider_cause_verified = FALSE,
  provider_confirmed_correction = FALSE,
  actual_headcount_verified = FALSE,
  original_source_modified = FALSE,
  historical_information_set_certified = FALSE,
  basis = "August map symbols and unit fields; adjacent contributor rows corroborate950",
  reviewed_on = "2026-11-07")
stopifnot(adjudicated_total == 2200, south_africa_from_symbols == 950)
write.csv(decision, "data/mavivi_subtotal_adjudication.csv", row.names = FALSE)
print(audit)
print(decision)
cat("Mavivi reconciled for the declared analysis; original provider cause remains unverified.\n")
