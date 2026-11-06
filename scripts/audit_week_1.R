# Week 1 measurement audit. This creates a feasibility panel, NOT model input.
# Source files remain untouched; all row-level outputs stay in ignored folders.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(sf)
library(ggplot2)
dir.create("outputs/week_1/audit", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/week_1/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("data/interim/ucdp", recursive = TRUE, showWarnings = FALSE)
aggregate_cities <- identical(Sys.getenv("AUDIT_AGGREGATE_CITIES"), "true")
audit_directory <- if (aggregate_cities) "outputs/week_1/audit_aggregated" else "outputs/week_1/audit"
figure_directory <- if (aggregate_cities) "outputs/week_1/figures_aggregated" else "outputs/week_1/figures"
dir.create(audit_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_directory, recursive = TRUE, showWarnings = FALSE)
write_audit <- function(data, name) {
  write.csv(as.data.frame(data), file.path(audit_directory, paste0(name, ".csv")),
            row.names = FALSE, na = "")
}
month_date <- function(year, month) as.Date(sprintf("%04d-%02d-01", year, month))
month_number <- function(date) as.integer(format(date, "%Y")) * 12L + as.integer(format(date, "%m"))

# Read the pinned originals, retaining row numbers as provenance for Geo-PKO,
# which has no globally unique row identifier in the supplied files.
event_file <- "data/interim/ucdp/GEDEvent_v26_1.csv"
if (!file.exists(event_file)) unzip("data/raw/ucdp/26.1/ged261-csv.zip", exdir = dirname(event_file))
events_all <- readr::read_csv(event_file, show_col_types = FALSE)
events <- events_all |> filter(country_id == 490, year >= 2014, year <= 2023)
maps_all <- readRDS("data/raw/geo_pko/2.3/location_map.rds") |> ungroup()
months_all <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
maps <- maps_all |> mutate(source_row = row_number()) |>
  filter(trimws(mission) == "MONUSCO", year >= 2014, year <= 2023) |>
  mutate(map_date = month_date(year, month), location_clean = trimws(location),
         troop_number = suppressWarnings(as.numeric(no.troops)))
months <- months_all |> mutate(source_row = row_number()) |>
  filter(trimws(mission) == "MONUSCO", year >= 2014, year <= 2023) |>
  mutate(period = month_date(year, month), map_date = month_date(source_year, source_month),
         map_age = month_number(period) - month_number(map_date),
         location_clean = trimws(location), troop_number = suppressWarnings(as.numeric(no.troops)))

# Pin a fixed modern geography for the audit. Historical comparisons below
# determine whether it can be used retrospectively without changing the unit.
boundaries_all <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE)
boundaries <- boundaries_all |> filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm)
stopifnot(!anyDuplicated(boundaries$locality_id), all(st_is_valid(boundaries)))
if (aggregate_cities) {
  # Deliberate aggregation, permitted by SALB terms, not a polygon repair.
  # These are analytical city-territory composites, not legal administrative units.
  city_crosswalk <- read.csv("config/city_aggregation.csv", stringsAsFactors = FALSE)
  boundaries <- boundaries |>
    left_join(city_crosswalk, by = "locality_id", relationship = "many-to-one") |>
    mutate(locality_id = coalesce(composite_id, locality_id),
           locality = coalesce(composite_name, locality)) |>
    group_by(locality_id, locality, province) |> summarise(.groups = "drop")
  stopifnot(all(st_is_valid(boundaries)))
}
write_audit(st_drop_geometry(boundaries), "locality_inventory")
write_audit(st_drop_geometry(boundaries_all) |> mutate(valid_geometry = st_is_valid(boundaries_all)), "boundary_validity")

# A list of polygon matches avoids a join that can silently multiply events.
# Keep ambiguous and unmatched records in the ledger rather than forcing a match.
assign_locality <- function(data) {
  valid <- is.finite(data$longitude) & is.finite(data$latitude) &
    abs(data$longitude) <= 180 & abs(data$latitude) <= 90
  data$valid_coordinates <- valid
  data$match_count <- 0L
  data$locality_id <- NA_character_
  if (any(valid)) {
    points <- st_as_sf(data[valid, ], coords = c("longitude", "latitude"), crs = 4326)
    matches <- st_intersects(points, boundaries)
    data$match_count[valid] <- lengths(matches)
    data$locality_id[valid] <- vapply(matches, function(index) {
      if (length(index) == 1L) boundaries$locality_id[index] else NA_character_
    }, character(1))
  }
  data
}
events <- assign_locality(events)
maps <- assign_locality(maps)
months <- assign_locality(months)
events <- events |> mutate(
  start_date = as.Date(date_start), end_date = as.Date(date_end),
  valid_dates = !is.na(start_date) & !is.na(end_date) & start_date <= end_date,
  same_month = format(start_date, "%Y-%m") == format(end_date, "%Y-%m"),
  period = as.Date(format(start_date, "%Y-%m-01")),
  reason = case_when(
    type_of_violence != 3 ~ "other_violence_type",
    year == 2014 ~ "preperiod_history",
    !valid_coordinates ~ "invalid_coordinate",
    !valid_dates ~ "invalid_date",
    match_count > 1 ~ "multiple_polygon_matches",
    match_count == 0 ~ "outside_target_or_unmatched",
    where_prec != 1 ~ "location_precision_not_exact",
    !same_month ~ "cross_month_date_interval",
    TRUE ~ "retained_primary_audit"
  ))
# The strict primary audit uses exact-place coding and intervals wholly inside a
# month. Less precise observations remain available for sensitivity, not erased.
write_audit(events |> select(id, year, type_of_violence, adm_1, adm_2, where_prec,
                            date_prec, start_date, end_date, longitude, latitude,
                            valid_coordinates, valid_dates, match_count, locality_id, reason), "event_ledger")
write_audit(events |> count(reason, name = "records"), "event_flow")
write_audit(events |> filter(type_of_violence == 3, year >= 2015) |>
              count(year, where_prec, date_prec, same_month, match_count), "event_precision")
write_audit(events |> count(year, type_of_violence), "drc_event_inventory")
write_audit(events |> filter(match_count == 1) |> count(adm_1, adm_2, locality_id), "event_name_crosswalk")
write_audit(events |> filter(type_of_violence == 3, year >= 2015,
                             grepl("Kivu|Ituri", adm_1), match_count != 1), "named_target_unmatched_events")

# Validate core source invariants without replacing or deduplicating records.
source_checks <- data.frame(
  check = c("global_duplicate_event_ids", "drc_invalid_coordinates", "drc_invalid_dates",
            "drc_fatality_sum_mismatch", "map_duplicate_location_date_keys",
            "month_duplicate_location_period_keys", "month_negative_map_age"),
  affected = c(sum(duplicated(events_all$id)), sum(!events$valid_coordinates),
    sum(!events$valid_dates), sum(events$best != events$deaths_a + events$deaths_b +
                                  events$deaths_civilians + events$deaths_unknown, na.rm = TRUE),
    sum(duplicated(maps[c("location_clean", "map_date")])),
    sum(duplicated(months[c("location_clean", "period")])), sum(months$map_age < 0)),
  checked = c(nrow(events_all), rep(nrow(events), 3), nrow(maps), nrow(months), nrow(months))
)
write_audit(source_checks, "source_checks")
write_audit(maps |> count(location_clean, map_date) |> filter(n > 1), "duplicate_map_keys")
write_audit(months |> count(location_clean, period) |> filter(n > 1), "duplicate_month_keys")

# Verify carried-forward rows against the original location-map product by
# source/date/location/coordinates and strength. No inferred zero is inserted.
map_keys <- maps_all |> filter(trimws(mission) == "MONUSCO") |>
  mutate(map_date = month_date(year, month), location_clean = trimws(location)) |>
  select(source, map_date, location_clean, latitude, longitude, no.troops) |> distinct()
month_unmatched <- months |> anti_join(map_keys,
  by = c("source", "map_date", "location_clean", "latitude", "longitude", "no.troops"))
write_audit(month_unmatched, "monthly_rows_without_matching_map")
write_audit(months |> select(source_row, period, source, map_date, map_age,
                            location_clean, locality_id, match_count, no.troops, geosplit), "deployment_lineage")
map_schedule <- maps |> distinct(source, map_date) |> arrange(map_date) |>
  mutate(gap_months = month_number(map_date) - lag(month_number(map_date)))
write_audit(map_schedule, "map_schedule")
write_audit(months |> filter(year >= 2015) |> count(year, source, map_date, map_age), "map_freshness")
write_audit(maps |> filter(is.na(troop_number) | geosplit == 1) |>
              select(source_row, source, map_date, location_clean, no.troops, geosplit,
                     geocomment, comment.on.unit, fpu.no, locality_id), "deployment_measurement_flags")

# Nonzero no.troops includes formed police units. Define military strength only
# when both estimates are numeric; do not mistake headquarters/observer rows for
# troops. Unknown positive strength remains an explicit unresolved flag.
months <- months |> mutate(fpu_number = suppressWarnings(as.numeric(fpu.no)),
  military_strength = troop_number - fpu_number,
  positive_military = !is.na(military_strength) & military_strength > 0)
strength_by_map <- months |> filter(year >= 2015, match_count == 1) |>
  distinct(locality_id, source, map_date, location_clean, military_strength) |>
  group_by(locality_id, source, map_date) |>
  summarise(listed_strength = if(any(is.na(military_strength))) NA_real_ else sum(military_strength),
            locations = n(), .groups = "drop") |>
  arrange(locality_id, map_date)
write_audit(strength_by_map, "listed_strength_by_map")
write_audit(strength_by_map |> group_by(locality_id) |>
  summarise(observed_maps = n(), known_strength_maps = sum(!is.na(listed_strength)),
            distinct_strengths = n_distinct(listed_strength, na.rm = TRUE),
            changes_between_listed_maps = sum(diff(listed_strength) != 0, na.rm = TRUE), .groups="drop"),
  "strength_variation")
deployment_months <- months |> filter(year >= 2015, match_count == 1) |>
  group_by(locality_id, period) |> summarise(
    listed_rows = n(), positive_military = any(positive_military),
    unknown_strength = any(is.na(military_strength)),
    min_map_age = min(map_age), max_map_age = max(map_age),
    distinct_maps = n_distinct(paste(source, map_date)), .groups = "drop")
retained <- events |> filter(reason == "retained_primary_audit")
event_months <- retained |> group_by(locality_id, period) |>
  summarise(recorded_events = n(), civilian_fatalities = sum(deaths_civilians), .groups = "drop")
grid <- tidyr::crossing(locality_id = boundaries$locality_id,
                        period = seq(as.Date("2015-01-01"), as.Date("2023-12-01"), by = "month"))
coverage <- grid |> left_join(deployment_months, by = c("locality_id", "period"), relationship = "one-to-one") |>
  left_join(event_months, by = c("locality_id", "period"), relationship = "one-to-one") |>
  left_join(st_drop_geometry(boundaries), by = "locality_id", relationship = "many-to-one") |>
  mutate(recorded_events = coalesce(recorded_events, 0L),
    civilian_fatalities = coalesce(civilian_fatalities, 0),
    deployment_status = case_when(
      is.na(listed_rows) ~ "Not listed; absence unverified",
      positive_military ~ "Positive military estimate",
      unknown_strength ~ "Unknown strength",
      TRUE ~ "Listed; no positive military estimate"))
stopifnot(nrow(coverage) == nrow(boundaries) * 108L,
          !anyDuplicated(coverage[c("locality_id", "period")]),
          sum(coverage$recorded_events) == nrow(retained))
# Zero here means no retained source record under the frozen filter, not no
# underlying violence or verified completeness of local reporting.
write_audit(coverage, "feasibility_coverage_panel")
variation <- coverage |> arrange(locality_id, period) |> group_by(locality_id, locality, province) |>
  summarise(positive_months = sum(deployment_status == "Positive military estimate"),
    unverified_months = sum(deployment_status == "Not listed; absence unverified"),
    listed_nonpositive_months = sum(deployment_status == "Listed; no positive military estimate"),
    presence_transitions_if_unlisted_zero = sum(diff(as.integer(deployment_status == "Positive military estimate")) != 0),
    recorded_events = sum(recorded_events), .groups = "drop")
write_audit(variation, "locality_variation")
write_audit(data.frame(table = c("event_polygon_assignment", "map_polygon_assignment", "month_polygon_assignment"),
  input_rows = c(nrow(events), nrow(maps), nrow(months)),
  output_rows = c(nrow(events), nrow(maps), nrow(months)),
  unmatched = c(sum(events$match_count == 0),sum(maps$match_count == 0),sum(months$match_count == 0)),
  ambiguous = c(sum(events$match_count > 1),sum(maps$match_count > 1),sum(months$match_count > 1))), "join_audit")

# Compare historical geometry to the selected geography using intersection area.
# Never repair SALB geometry: terms prohibit changing it without contributor consent.
# Invalid features outside the target do not affect these intersections.
crosswalks <- list()
boundary_summary <- list()
stability <- list()
target_projected <- st_transform(boundaries, 6933)
for (vintage in c("2013", "2015_jan", "2015_jul", "2018")) {
  old <- st_read(paste0("data/raw/boundaries/salb_", vintage, ".geojson"), quiet = TRUE)
  valid <- st_is_valid(old)
  old_valid <- old[valid, ]
  intersects_target <- lengths(st_intersects(old_valid, boundaries)) > 0
  old_selected <- old_valid[intersects_target, ]
  old_projected <- st_transform(old_selected, 6933)
  old_projected$source_area <- as.numeric(st_area(old_projected))
  overlap <- suppressWarnings(st_intersection(
    old_projected |> select(source_id = adm2cd, source_name = adm2nm, source_area),
    target_projected |> select(locality_id, locality)))
  overlap$overlap_area <- as.numeric(st_area(overlap))
  crosswalks[[vintage]] <- st_drop_geometry(overlap) |>
    mutate(vintage = vintage, source_area_share = overlap_area / source_area) |>
    filter(source_area_share > 0.000001)
  # Compare the union of source polygons mostly contained in each target with
  # that target. This detects changed footprints, not just changed names/IDs.
  stability[[vintage]] <- bind_rows(lapply(seq_len(nrow(target_projected)), function(index) {
    target_id <- target_projected$locality_id[index]
    ids <- crosswalks[[vintage]] |> filter(locality_id == target_id, source_area_share > .999) |> pull(source_id)
    if (!length(ids)) return(data.frame(vintage=vintage, locality_id=target_id, relative_area_difference=NA_real_))
    source_union <- st_union(old_projected[old_projected$adm2cd %in% ids,])
    difference <- st_sym_difference(source_union, st_geometry(target_projected[index,]))
    data.frame(vintage=vintage, locality_id=target_id,
      relative_area_difference=sum(as.numeric(st_area(difference))) / as.numeric(st_area(target_projected[index,])))
  }))
  boundary_summary[[vintage]] <- data.frame(vintage = vintage, total_units = nrow(old),
    invalid_geometries = sum(!valid), intersecting_target_units = nrow(old_selected))
}
write_audit(bind_rows(crosswalks), "boundary_crosswalk_area")
write_audit(bind_rows(boundary_summary), "boundary_vintage_inventory")
write_audit(bind_rows(stability), "boundary_footprint_stability")

# Compare the alternative open boundary geometry without adopting its different
# urban-unit definitions. Every point retains its complete match count.
alternative <- st_read("data/raw/boundaries/geoboundaries_adm2.geojson", quiet = TRUE)
alternative_matches <- st_intersects(st_as_sf(retained, coords = c("longitude", "latitude"), crs = 4326), alternative)
write_audit(data.frame(event_id = retained$id, salb_locality = retained$locality_id,
  alternative_match_count = lengths(alternative_matches),
  alternative_name = vapply(alternative_matches, function(x) if(length(x)==1) alternative$shapeName[x] else NA_character_, character(1))),
  "alternative_boundary_event_assignment")

# Three audit figures, with uncertainty in source measurement visible in labels.
theme_set(theme_minimal(base_size = 11) + theme(panel.grid.minor = element_blank(),
                                               plot.caption = element_text(hjust = 0)))
coverage_plot <- ggplot(coverage, aes(period, factor(locality, levels = rev(sort(unique(locality)))), fill = deployment_status)) +
  geom_tile() + scale_fill_manual(values = c("Positive military estimate" = "#0072B2",
    "Not listed; absence unverified" = "#D9D9D9", "Listed; no positive military estimate" = "#E69F00",
    "Unknown strength" = "#CC79A7")) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(title = "Deployment evidence by locality and month", x = NULL, y = NULL, fill = NULL,
    subtitle = paste(if(aggregate_cities) "SALB city-territory composites;" else "Fixed SALB 2018 geography;",
                     "North Kivu, South Kivu and Ituri, 2015-2023"),
    caption = "Geo-PKO 2.3. Unlisted localities are not verified deployment absences.\nMilitary estimate subtracts formed police units; monthly rows may carry earlier maps forward.") +
  theme(legend.position = "bottom", legend.text = element_text(size = 9)) + guides(fill = guide_legend(nrow = 2))
ggsave(file.path(figure_directory, "deployment_coverage.png"), coverage_plot, width = 12, height = 9, dpi = 160)
freshness_plot <- ggplot(months |> filter(year >= 2015), aes(period, map_age)) +
  geom_point(alpha = .08, colour = "#0072B2", size = 1) +
  geom_vline(data = map_schedule |> filter(map_date >= as.Date("2015-01-01")),
             aes(xintercept = map_date), colour = "#D55E00", alpha = .5, linewidth = .3) +
  labs(title = "Age of the map underlying monthly deployment rows", x = NULL, y = "Months since source-map publication",
    subtitle = "All MONUSCO locations; vertical lines mark source-map updates",
    caption = "Geo-PKO 2.3. Overlapping points indicate multiple locations; they are not independent map observations.")
ggsave(file.path(figure_directory, "deployment_freshness.png"), freshness_plot, width = 11, height = 5, dpi = 160)
plot_events <- events |> filter(type_of_violence == 3, year >= 2015, match_count == 1) |>
  mutate(precision = if_else(where_prec == 1, "Exact place", "Uncertain location"))
overview <- ggplot() + geom_sf(data = boundaries, fill = "#F2F2F2", linewidth = .25) +
  geom_point(data = plot_events, aes(longitude, latitude, colour = precision, shape = precision), size = .8, alpha = .4) +
  scale_colour_manual(values = c("Exact place" = "#0072B2", "Uncertain location" = "#D55E00")) +
  scale_shape_manual(values = c("Exact place" = 16, "Uncertain location" = 4)) +
  labs(title = "One-sided violence locations and candidate analysis units", colour = NULL, shape = NULL,
    subtitle = "2015-2023; uncertain points show coded reference locations, not uncertainty areas",
    caption = "UCDP GED 26.1; from SALB Data, United Nations; Institut Geographique du Congo.\nOnly points uniquely intersecting the selected provinces are shown. Boundaries imply no UN endorsement.") +
  theme(legend.position = "bottom")
ggsave(file.path(figure_directory, "geographic_overview.png"), overview, width = 9, height = 10, dpi = 160)
event_plot <- ggplot(coverage, aes(period, factor(locality, levels = rev(sort(unique(locality)))), fill = recorded_events)) +
  geom_tile() + scale_fill_viridis_c(trans = "sqrt") +
  labs(title = "Retained recorded events by locality and month", x = NULL, y = NULL, fill = "Events",
    subtitle = "Exact-place one-sided events with dates contained within one month",
    caption = "UCDP GED 26.1. Zero = no retained event record; it does not establish complete local reporting.")
ggsave(file.path(figure_directory, "event_coverage.png"), event_plot, width = 12, height = 9, dpi = 160)

summary <- list(global_events = nrow(events_all), drc_events_2014_2023 = nrow(events),
  target_localities = nrow(boundaries), target_events_retained = nrow(retained),
  target_one_sided_all_precision = nrow(plot_events), map_rows = nrow(maps), monthly_rows = nrow(months),
  independent_maps_2015_2023 = sum(map_schedule$map_date >= as.Date("2015-01-01")),
  unmatched_monthly_to_map = nrow(month_unmatched),
  map_gap_summary = as.list(as.numeric(summary(map_schedule$gap_months[map_schedule$map_date>=as.Date("2015-01-01")]))),
  map_age_summary = as.list(as.numeric(summary(months$map_age[months$year>=2015]))),
  positive_localities = sum(variation$positive_months > 0),
  always_positive_localities = sum(variation$positive_months == 108),
  switching_if_unlisted_zero = sum(variation$presence_transitions_if_unlisted_zero > 0),
  unverified_locality_months = sum(coverage$deployment_status == "Not listed; absence unverified"))
jsonlite::write_json(summary, file.path(audit_directory,"summary.json"), auto_unbox = TRUE, pretty = TRUE)
capture.output(sessionInfo(), file = file.path(audit_directory, "session_info.txt"))
print(summary)
capture.output(warnings(), file = file.path(audit_directory, "warnings.txt"))
