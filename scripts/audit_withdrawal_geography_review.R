# Investigate all known ADM2/polygon conflicts in the saved eligible record.
# Alternative boundary agreement is diagnostic, not a vote on the correct map.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(sf)
library(ggplot2)
out <- 'outputs/withdrawal_review'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
events <- read_csv('outputs/withdrawal_feasibility/eligible_event_lineage.csv',
  show_col_types = FALSE, guess_max = 100000) |> distinct(id, .keep_all = TRUE)
conflicts <- events |> filter(!is.na(admin_locality_id), admin_locality_id != locality_id)
stopifnot(!anyDuplicated(conflicts$id), nrow(problems(events)) == 0)
points <- st_as_sf(conflicts, coords = c('longitude', 'latitude'), crs = 4326, remove = FALSE)
crosswalk <- read_csv('config/city_aggregation.csv', show_col_types = FALSE)
files <- list.files('data/raw/boundaries', pattern = 'geojson$', full.names = TRUE)
results <- list()
layers <- list()
for (path in files) {
  layer_name <- tools::file_path_sans_ext(basename(path))
  layer <- st_read(path, quiet = TRUE) |> st_make_valid()
  if ('adm2nm' %in% names(layer)) {
    layer <- layer |> transmute(boundary_name = adm2nm, locality_id = adm2cd) |>
      left_join(crosswalk, by = 'locality_id') |>
      mutate(mapped_id = coalesce(composite_id, locality_id))
  } else {
    layer <- layer |> transmute(boundary_name = shapeName, mapped_id = NA_character_)
  }
  hits <- st_intersects(points, layer)
  distances <- rep(NA_real_, nrow(points))
  # Distances are calculated only against matching official SALB IDs. Names in
  # the alternate source are retained as supplied, with no speculative crosswalk.
  for (j in seq_len(nrow(points))) {
    claimed <- layer |> filter(mapped_id == points$admin_locality_id[j])
    if (nrow(claimed) > 0) distances[j] <- min(as.numeric(st_distance(
      st_transform(points[j, ], 32735), st_transform(claimed, 32735)))) / 1000
  }
  results[[layer_name]] <- tibble(id = points$id, boundary_layer = layer_name,
    match_count = lengths(hits),
    assigned_names = vapply(hits, function(i) paste(layer$boundary_name[i], collapse = ';'), character(1)),
    assigned_ids = vapply(hits, function(i) paste(unique(na.omit(layer$mapped_id[i])), collapse = ';'), character(1)),
    km_to_claimed_administrative_polygon = distances)
  layers[[layer_name]] <- layer
}
assignments <- bind_rows(results)
write_csv(assignments, file.path(out, 'all_boundary_assignments.csv'))
review <- conflicts |> select(id, start_date, end_date, locality_id, admin_locality_id,
    adm_2, where_description, where_coordinates, longitude, latitude, deaths_civilians,
    source_article, original_eligible) |>
  left_join(assignments |> select(id, boundary_layer, assigned_names) |>
    pivot_wider(names_from = boundary_layer, values_from = assigned_names), by = 'id') |>
  mutate(review_status = 'Unresolved primary assignment; alternate boundaries do not adjudicate coordinates',
    reviewer_decision = NA_character_, reviewer_rationale = NA_character_, reviewer_source = NA_character_)
write_csv(review, file.path(out, 'geography_review_all_conflicts.csv'))

# Local boundary map: only the stored event coordinate is plotted, not an inferred
# replacement location. Map identifies a disagreement, not the correct territory.
luhanga <- points |> filter(id == 234588)
stopifnot(nrow(luhanga) == 1)
box <- st_bbox(c(xmin = 28.65, xmax = 29.25, ymin = -.95, ymax = -.35), crs = st_crs(4326))
salb <- suppressWarnings(st_crop(layers$salb_2018, box))
alternate <- suppressWarnings(st_crop(layers$geoboundaries_adm2, box))
p <- ggplot() + geom_sf(data = salb, aes(fill = boundary_name), alpha = .3, linewidth = .6) +
  geom_sf(data = alternate, fill = NA, color = '#a63d40', linetype = 'dashed', linewidth = .7) +
  geom_sf(data = luhanga, shape = 4, size = 4, stroke = 1.2) +
  annotate('text', x = 29.01, y = -.62, label = 'Stored Luhanga coordinate', hjust = 0, size = 3) +
  coord_sf(xlim = c(28.65,29.25), ylim = c(-.95,-.35), expand = FALSE) +
  labs(title = 'Luhanga: stored coordinate and alternative territorial boundaries',
    subtitle = 'Solid boundaries: SALB 2018; dashed red: geoBoundaries (2019 geography)',
    fill = 'SALB territory', x = 'Longitude', y = 'Latitude',
    caption = 'Sources: project GED v26.1 coordinate; SALB; geoBoundaries/OCHA-RGC.\nDashed-line differences do not establish a corrected coordinate or protection catchment.') +
  theme_minimal(base_size = 11) + theme(legend.position = 'bottom', plot.caption = element_text(hjust = 0))
ggsave(file.path(out, 'luhanga_boundary_review.png'), p, width = 10, height = 7, dpi = 170)

# A documented alternative assignment scenario transfers Luhanga to Lubero,
# preserving its stored deaths and event total. It remains separate from primary
# coding until the boundary/coordinate discrepancy is adjudicated.
base <- read_csv('outputs/withdrawal_descriptive/before_after_and_missing_death_scenario.csv',
  show_col_types = FALSE)
scenario <- base |> filter(str_detect(case_id, 'bunyampuri_2017|luofu_2017')) |>
  mutate(scenario = 'Luhanga to administratively reported Lubero; other records unchanged',
    revised_pre_deaths = deaths_pre + if_else(str_detect(case_id, 'luofu'), 34, -34),
    revised_monthly_difference = deaths_post / 6 - revised_pre_deaths / 24)
stopifnot(all(scenario$revised_pre_deaths >= 0))
write_csv(scenario, file.path(out, 'luhanga_reassignment_scenario.csv'))

# Correctly distinguish a reported fixed-base closure from a later retrospective
# publication. October 19 is not evidence of an October departure.
timing <- read_csv('outputs/withdrawal_descriptive/timing_and_inclusion_sensitivity.csv',
  show_col_types = FALSE) |> filter(str_detect(case_id, 'bunyampuri_2017|luofu_2017|masisi_2017')) |>
  mutate(interpretation = case_when(scenario == 'earliest_documented_month' ~
    'July 2017 fixed-base closure anchor, supported by retrospective UN account',
    scenario == 'latest_documented_month' ~
    'October report-date anchor only; NOT a documented departure alternative',
    TRUE ~ 'Historical broad envelope retained for reproduction; not a verified operational transition'))
write_csv(timing, file.path(out, 'closure_vs_report_date_comparison.csv'))
write_csv(tibble(check = c('unique conflict records', 'all five boundary layers checked',
  'Luhanga row present', 'scenario conserves baseline deaths across Walikale and Lubero'),
  passed = c(!anyDuplicated(review$id), n_distinct(assignments$boundary_layer) == 5,
    234588 %in% review$id,
    all((scenario |> group_by(definition) |> summarise(delta = sum(revised_pre_deaths - deaths_pre)))$delta == 0))),
  file.path(out, 'acceptance_checks.csv'))
writeLines(capture.output(sessionInfo()), file.path(out, 'session_info.txt'))
print(filter(assignments, id == 234588))
cat(nrow(review), 'unique conflicts audited across all saved eligible years.\n')
