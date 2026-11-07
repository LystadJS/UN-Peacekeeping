# Resolve locality assignment using independent historical settlement evidence.
# The candidate point describes Nyamilima town, not a surveyed MONUSCO base.
# No frozen exposure panel or source file is changed by this audit.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(sf)
output_directory <- "outputs/nyamilima_adjudication"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
sources <- read.csv("data/nyamilima_geography_sources.csv")
for (i in seq_len(nrow(sources))) {
  stopifnot(file.info(sources$path[i])$size == sources$bytes[i],
    digest::digest(readBin(sources$path[i], "raw", sources$bytes[i]),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
# Parse only the required public attributes; contributor names/IDs are not
# propagated into derived outputs. Original XML stays in the ignored directory.
xml <- readLines(sources$path[sources$source_id == "osm_node_history"], warn = FALSE)
nodes <- grep("<node ", xml, value = TRUE, fixed = TRUE)
attribute <- function(lines, name) {
  pattern <- paste0('.* ', name, '="([^"]+)".*')
  stopifnot(all(grepl(pattern, lines)))
  sub(pattern, "\\1", lines)
}
versions <- data.frame(version = as.integer(attribute(nodes, "version")),
  timestamp = attribute(nodes, "timestamp"),
  latitude = as.numeric(attribute(nodes, "lat")),
  longitude = as.numeric(attribute(nodes, "lon")))
stopifnot(nrow(versions) == 4L, identical(versions$version, 1:4),
  all(versions$timestamp < "2023-10-01T00:00:00Z"),
  length(unique(versions$latitude)) == 1L,
  length(unique(versions$longitude)) == 1L,
  sum(grepl('k="is_in:territoire" v="Rutshuru"', xml, fixed = TRUE)) == 4L,
  sum(grepl('k="name" v="Nyamilima"', xml, fixed = TRUE)) == 4L)
write.csv(versions, file.path(output_directory, "osm_coordinate_history.csv"), row.names = FALSE)
# Independently retained UN text supports the administrative assignment. PDF
# rendering was inspected; the numerical rerun needs the original PDF only.
pages <- pdftools::pdf_text(sources$path[sources$source_id == "monusco_february_2015"])
stopifnot(grepl("Nyamilima", pages[15], fixed = TRUE),
  grepl("territoire de Rutshuru", pages[15], fixed = TRUE))

full_boundaries <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE)
# Some polygons outside the research region contain duplicate vertices. Repair
# only the in-memory national lookup used to label the displaced original point;
# the study-region geometries below retain the established original workflow.
national_lookup <- st_make_valid(full_boundaries)
boundaries <- full_boundaries |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
  left_join(read.csv("config/city_aggregation.csv"), by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id), locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = "drop")
modern_all <- readRDS("data/raw/geo_pko/2.3/location_map.rds") |>
  ungroup() |> filter(mission == "MONUSCO", location == "Nyamilima", year %in% 2016:2023)
modern <- modern_all |> filter(year %in% 2021:2023) |>
  mutate(revision = as.numeric(sub(".*[Rr]ev[.] *", "", source))) |>
  filter(revision %in% c(40:44, 45.1, 46:51))
stopifnot(nrow(modern) == 12L, nrow(modern_all) == 17L,
  n_distinct(modern_all$latitude) == 1L, n_distinct(modern_all$longitude) == 1L)
points <- data.frame(point_type = c("current_geopko", "historical_osm_settlement"),
  longitude = c(modern$longitude[1], versions$longitude[1]),
  latitude = c(modern$latitude[1], versions$latitude[1]))
geographic_points <- st_as_sf(points, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
hits <- st_intersects(geographic_points, boundaries)
stopifnot(lengths(hits)[1] == 0L, lengths(hits)[2] == 1L,
  boundaries$locality_id[hits[[2]]] == "COD009015")
points$matched_locality_id <- vapply(hits, function(i) if (length(i)) boundaries$locality_id[i] else NA_character_, character(1))
points$matched_locality <- vapply(hits, function(i) if (length(i)) boundaries$locality[i] else NA_character_, character(1))
full_hits <- st_intersects(geographic_points, national_lookup)
stopifnot(all(lengths(full_hits) == 1L))
points$salb_admin1 <- vapply(full_hits, function(i) full_boundaries$adm1nm[i], character(1))
points$salb_admin2 <- vapply(full_hits, function(i) full_boundaries$adm2nm[i], character(1))
displacement_km <- as.numeric(st_distance(geographic_points[1, ], geographic_points[2, ])) / 1000
rutshuru <- boundaries[boundaries$locality_id == "COD009015", ]
boundary_margin_km <- as.numeric(st_distance(geographic_points[2, ], st_boundary(rutshuru))) / 1000
points$distance_from_current_km <- c(0, displacement_km)
points$distance_to_rutshuru_boundary_km <- as.numeric(st_distance(geographic_points, st_boundary(rutshuru))) / 1000
write.csv(points, "data/nyamilima_geography_adjudication.csv", row.names = FALSE, na = "")
# A reproducible correction proposal is separate from its application. The
# exact military compound point and a historical snapshot of these bytes remain
# unverified even though the version history predates the forecast origin.
proposal <- data.frame(location = "Nyamilima", original_longitude = points$longitude[1],
  original_latitude = points$latitude[1], candidate_longitude = points$longitude[2],
  candidate_latitude = points$latitude[2], candidate_locality_id = "COD009015",
  candidate_locality = "Rutshuru", displacement_km = displacement_km,
  candidate_boundary_margin_km = boundary_margin_km, source_node_id = "1158948544",
  coordinate_version_first_timestamp = min(versions$timestamp),
  coordinate_version_latest_timestamp = max(versions$timestamp),
  affected_reviewed_map_rows = nrow(modern),
  affected_full_pilot_source_rows = nrow(modern_all),
  locality_adjudication = "resolved_for_settlement_and_locality_correction_scenario",
  exact_military_base_point_verified = FALSE,
  contemporaneous_download_bytes_authenticated = FALSE,
  frozen_panel_corrected = FALSE)
stopifnot(displacement_km > 200, boundary_margin_km > 1)
write.csv(proposal, "data/nyamilima_geography_correction_proposal.csv", row.names = FALSE)
print(proposal)
cat("Nyamilima locality assignment adjudicated; frozen files unchanged.\n")
