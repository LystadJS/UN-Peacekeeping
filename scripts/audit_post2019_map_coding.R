# Audit a bounded visual reconstruction, not a complete deployment panel.
# Run from the repository root. PDF reading/rendering used pypdf/Poppler because
# they preserve the source-page evidence; all numerical analysis is in R.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(readr)
output_directory <- "outputs/post2019_map_coding"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
sources <- read_csv("data/post2019_map_coding_sources.csv", show_col_types = FALSE)
hash_file <- function(path) digest::digest(readBin(path, "raw", file.info(path)$size),
  algo = "sha256", serialize = FALSE)
for (i in seq_len(nrow(sources))) {
  if (!file.exists(sources$path[i])) {
    dir.create(dirname(sources$path[i]), recursive = TRUE, showWarnings = FALSE)
    download.file(sources$url[i], sources$path[i], mode = "wb")
  }
  stopifnot(file.info(sources$path[i])$size == sources$bytes[i],
    hash_file(sources$path[i]) == sources$sha256[i])
}
readings <- read_csv("data/post2019_map_coding_transcription.csv", show_col_types = FALSE)
stopifnot(!anyDuplicated(readings[c("revision", "location")]),
  nrow(readings) == 92L, all(readings$revision %in% sources$revision))
# Zero here counts explicitly sized symbols in a reviewed site box, never
# deployment absence. Unnamed sites retain NA; unsized units remain unresolved.
components <- readings |>
  mutate(sized_military = 650 * military_battalions +
    150 * military_companies + 35 * military_platoons,
    sized_fpu = 150 * fpu_companies,
    complete_locality_strength = NA_real_) |>
  left_join(sources, by = "revision", relationship = "many-to-one")
stopifnot(all(is.na(components$sized_military[components$coding_status == "site_not_named"])),
  all(is.na(components$complete_locality_strength)))
# Agent readings are unblinded: existing coding and earlier checks were visible.
# Record explicit visual symbols before this numerical comparison; this is not
# an independent blinded transcription or a preregistered freeze. Source revisions,
# not modern row months, identify the same map. Published geosplit allocations
# must never be divided again. No ambiguous reading is filled from modern data.
modern <- readRDS("data/raw/geo_pko/2.3/location_map.rds") |>
  ungroup() |> filter(mission == "MONUSCO", year %in% 2020:2022) |>
  mutate(revision = as.numeric(sub(".*[Rr]ev\\.? *([0-9.]+).*", "\\1", source)),
    modern_military = as.numeric(no.troops) - as.numeric(fpu.no),
    modern_fpu = as.numeric(fpu.no)) |>
  select(revision, location, modern_military, modern_fpu, geosplit) |>
  distinct()
comparison <- components |>
  left_join(modern, by = c("revision", "location"), relationship = "one-to-one") |>
  mutate(sized_difference = sized_military - modern_military,
    fpu_difference = sized_fpu - modern_fpu)
write_csv(comparison, file.path(output_directory, "site_map_comparison.csv"))
summary <- comparison |> group_by(revision, map_title_month, map_footer_month,
    availability_status) |>
  summarise(reviewed_site_rows = n(), numeric_sized_rows = sum(!is.na(sized_military)),
    unresolved_site_rows = sum(is.na(sized_military)),
    rows_with_unsized_units = sum(unsized_military_present, na.rm = TRUE),
    comparable_modern_rows = sum(!is.na(sized_difference)),
    differing_sized_rows = sum(sized_difference != 0, na.rm = TRUE),
    differing_fpu_rows = sum(fpu_difference != 0, na.rm = TRUE), .groups = "drop")
write_csv(summary, "data/post2019_map_coding_audit.csv")
# Preserve a chronological map-observation history. Deliberately do not expand
# to months or carry values through an intervening unread/undated observation.
write_csv(components |> arrange(location, revision),
  file.path(output_directory, "partial_site_histories.csv"))
print(summary, width = Inf)
