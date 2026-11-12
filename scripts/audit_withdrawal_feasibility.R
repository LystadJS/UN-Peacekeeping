# Run from the project root with Rscript. This audit fits no effect model.
# Counts are recorded one-sided civilian deaths, not all civilian war deaths.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(sf)
library(ggplot2)
output_dir <- 'outputs/withdrawal_feasibility'
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
save_table <- function(x, name) write_csv(x, file.path(output_dir, paste0(name, '.csv')))
month_start <- function(x) as.Date(format(as.Date(x), '%Y-%m-01'))
month_number <- function(x) as.integer(format(x, '%Y')) * 12L + as.integer(format(x, '%m'))

# Rebuild all event types so the existing territorial review can be reused
# unchanged, with only input years and output paths overridden.
crosswalk <- read_csv('config/city_aggregation.csv', show_col_types = FALSE)
boundaries <- st_read('data/raw/boundaries/salb_2018.geojson', quiet = TRUE) |>
  filter(adm1nm %in% c('Nord-Kivu', 'Sud-Kivu', 'Ituri')) |>
  transmute(locality_id = adm2cd, locality = adm2nm, province = adm1nm) |>
  left_join(crosswalk, by = 'locality_id') |>
  mutate(locality_id = coalesce(composite_id, locality_id),
         locality = coalesce(composite_name, locality)) |>
  group_by(locality_id, locality, province) |> summarise(.groups = 'drop')
inventory <- st_drop_geometry(boundaries)
stopifnot(nrow(inventory) == 19, all(st_is_valid(boundaries)))
ged <- read_csv('data/interim/ucdp/GEDEvent_v26_1.csv', show_col_types = FALSE) |>
  filter(country_id == 490, year %in% 2014:2025) |>
  mutate(date_start = as.Date(date_start), date_end = as.Date(date_end),
    valid_coordinates = !is.na(longitude) & !is.na(latitude) &
      abs(longitude) <= 180 & abs(latitude) <= 90,
    valid_dates = !is.na(date_start) & !is.na(date_end) & date_start <= date_end)
stopifnot(!anyDuplicated(ged$id))
matches <- rep(list(integer()), nrow(ged))
matches[ged$valid_coordinates] <- st_intersects(st_as_sf(
  ged[ged$valid_coordinates, ], coords = c('longitude', 'latitude'), crs = 4326), boundaries)
ledger <- ged |> transmute(id, year, type_of_violence, adm_1, adm_2, where_prec, date_prec,
  start_date = date_start, end_date = date_end, longitude, latitude,
  valid_coordinates, valid_dates, match_count = lengths(matches),
  locality_id = vapply(matches, function(i) if (length(i) == 1) inventory$locality_id[i]
    else NA_character_, character(1)), reason = 'rebuilt spatial ledger')
save_table(ledger, 'spatial_event_ledger')
local({
  previous_options <- options(monusco.audit_years = 2014:2025,
    monusco.audit_output = output_dir,
    monusco.audit_ledger = file.path(output_dir, 'spatial_event_ledger.csv'))
  on.exit(options(previous_options))
  source('scripts/audit_territorial_assignment.R', local = new.env(parent = globalenv()))
})
events <- read_csv(file.path(output_dir, 'event_adjudication_ledger.csv'), show_col_types = FALSE,
  col_types = cols(exclusion_reason = col_character(), evidence = col_character()))
old <- read_csv('outputs/territorial_assignment/event_adjudication_ledger.csv', show_col_types = FALSE,
  col_types = cols(exclusion_reason = col_character(), evidence = col_character()))
stopifnot(nrow(problems(events)) == 0, nrow(problems(old)) == 0)
overlap <- inner_join(events, old, by = 'id', suffix = c('', '_old'))
stopifnot(nrow(overlap) == nrow(old),
  identical(overlap$original_eligible, overlap$original_eligible_old),
  identical(overlap$add_event, overlap$add_event_old))
# Keep strict exact-place counts primary for continuity. The territorial rule is
# a parallel measurement sensitivity, not a post-outcome choice of observations.
eligible <- bind_rows(
  filter(events, original_eligible) |> mutate(definition = 'strict'),
  filter(events, original_eligible | add_event) |> mutate(definition = 'territorial')) |>
  left_join(ged |> select(id, side_a, side_b), by = 'id') |>
  mutate(month = month_start(start_date),
    kst_cited = str_detect(str_to_lower(coalesce(source_article, '')),
      'kivu security|kivu security tracker|barom[eè]tre|barometre'),
    un_cited = str_detect(str_to_lower(coalesce(source_article, '')),
      'monusco|unjhro|ohchr|united nations|nations unies'),
    okapi_cited = str_detect(str_to_lower(coalesce(source_article, '')), 'okapi'))
stopifnot(!anyNA(eligible$deaths_civilians), all(eligible$deaths_civilians >= 0))
save_table(eligible, 'eligible_event_lineage')
save_table(filter(events, year >= 2024, add_event), 'later_territorial_additions_review')
totals <- eligible |> group_by(definition, locality_id, month) |>
  summarise(events = n(), civilian_deaths = sum(deaths_civilians),
    largest_episode = max(deaths_civilians), kst_events = sum(kst_cited),
    un_events = sum(un_cited), okapi_events = sum(okapi_cited), .groups = 'drop')
panel <- crossing(inventory, definition = c('strict', 'territorial'),
    month = seq(as.Date('2014-01-01'), as.Date('2025-12-01'), by = 'month')) |>
  left_join(totals, by = c('definition', 'locality_id', 'month')) |>
  mutate(across(c(events, civilian_deaths, largest_episode, kst_events, un_events, okapi_events),
    ~ replace_na(.x, 0)), month_index = month_number(month),
    coverage_status = 'Recorded counts; complete reporting not established')
save_table(panel, 'monthly_panel')
# Exact reproduction against the original quarterly panel, not just grand totals.
original <- readRDS('outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds')
quarter_check <- panel |> filter(definition == 'strict', month >= as.Date('2016-01-01'),
    month < as.Date('2024-01-01')) |>
  mutate(source_quarter = as.integer(format(month, '%Y')) * 4L +
    (as.integer(format(month, '%m')) - 1L) %/% 3L) |>
  group_by(locality_id, source_quarter) |>
  summarise(events = sum(events), deaths = sum(civilian_deaths), .groups = 'drop') |>
  inner_join(original, by = c('locality_id', 'source_quarter'))
stopifnot(nrow(quarter_check) == 608,
  all(quarter_check$events == quarter_check$recorded_events),
  all(quarter_check$deaths == quarter_check$civilian_fatalities))
# Reproduce the existing daily handover windows independently of our new monthly
# audit windows. Events crossing an outer boundary remain excluded consistently.
handover <- read_csv('outputs/south_kivu_handovers/handover_windows.csv', show_col_types = FALSE)
handover$rebuilt_events <- vapply(seq_len(nrow(handover)), function(i) sum(
  eligible$definition == 'strict' & eligible$locality_id == handover$locality_id[i] &
  eligible$start_date >= handover$window_start[i] & eligible$end_date <= handover$window_end[i]), numeric(1))
handover$rebuilt_deaths <- vapply(seq_len(nrow(handover)), function(i) sum(
  eligible$deaths_civilians[eligible$definition == 'strict' &
  eligible$locality_id == handover$locality_id[i] & eligible$start_date >= handover$window_start[i] &
  eligible$end_date <= handover$window_end[i]]), numeric(1))
stopifnot(all(handover$events == handover$rebuilt_events),
  all(handover$civilian_fatalities == handover$rebuilt_deaths))
save_table(handover, 'handover_reproduction')

register <- read_csv('data/withdrawal_feasibility/episode_register.csv', show_col_types = FALSE,
  col_types = cols(.default = col_character(), feasibility_class = col_integer())) |>
  mutate(across(c(change_date_lower, change_date_upper), as.Date))
sources <- read_csv('data/withdrawal_feasibility/sources.csv', show_col_types = FALSE)
stopifnot(all(unlist(strsplit(register$source_ids, ';')) %in% sources$source_id),
  !anyDuplicated(register$episode_id),
  all(na.omit(register$locality_id) %in% inventory$locality_id))
save_table(register, 'episode_decisions')
# A provincial decision is expanded into outcome units but never counted as
# eight independent treatment assignments. Base-component rows remain separate
# documentary timelines and must not be pooled with their provincial parent.
units <- register |> filter(!is.na(locality_id), !is.na(change_date_lower))
province_row <- filter(register, episode_id == 'south_kivu_2024')
units <- bind_rows(units, bind_rows(lapply(inventory$locality_id[inventory$province == 'Sud-Kivu'],
  function(id) mutate(province_row, locality_id = id))))
window_rows <- list()
pre_rows <- list()
for (i in seq_len(nrow(units))) {
  episode <- units[i, ]
  lower <- month_number(episode$change_date_lower)
  upper <- month_number(episode$change_date_upper)
  # Use 24 complete months before the earliest possible transition month and
  # six complete months after the latest. Transition months are omitted explicitly.
  window_rows[[i]] <- panel |> filter(locality_id == episode$locality_id,
      month_index >= lower - 24, month_index <= upper + 6) |>
    mutate(episode_id = episode$episode_id, decision_cluster = episode$decision_cluster,
      block = case_when(month_index < lower ~ 'pre_24', month_index <= upper ~ 'transition',
        month_index <= upper + 3 ~ 'post_1_3', TRUE ~ 'post_4_6'))
  # All candidate comparisons are characterized using pre-change observations
  # only. There is deliberately no ranking based on subsequent violence.
  pre_rows[[i]] <- panel |> filter(month_index >= lower - 24, month_index < lower) |>
    group_by(definition, locality_id, locality, province) |>
    summarise(months = n(), events = sum(events), deaths = sum(civilian_deaths),
      death_months = sum(civilian_deaths > 0),
      first_12_deaths = sum(civilian_deaths[month_index < lower - 12]),
      last_12_deaths = sum(civilian_deaths[month_index >= lower - 12]),
      largest_episode = max(largest_episode), kst_events = sum(kst_events),
      .groups = 'drop') |>
    mutate(episode_id = episode$episode_id, treated_locality_id = episode$locality_id,
      same_outcome_unit = locality_id == treated_locality_id,
      interpretation = 'Screening only; continued protection and comparability need documentary evidence')
}
windows <- bind_rows(window_rows)
stopifnot(all(count(filter(windows, block == 'pre_24'), episode_id, locality_id, definition)$n == 24),
  all(count(filter(windows, str_detect(block, '^post')), episode_id, locality_id, definition)$n == 6))
save_table(windows, 'episode_monthly_windows')
summary <- windows |> filter(block != 'transition') |>
  group_by(episode_id, decision_cluster, locality_id, locality, definition, block) |>
  summarise(months = n(), events = sum(events), civilian_deaths = sum(civilian_deaths),
    largest_episode = max(largest_episode), kst_events = sum(kst_events),
    un_events = sum(un_events), okapi_events = sum(okapi_events), .groups = 'drop')
save_table(summary, 'outcome_coverage_windows')
profiles <- bind_rows(pre_rows)
# Numeric listings provide a coverage check, not certification of patrols.
listed <- read_csv(paste0('outputs/corrected_panel_sensitivity/supported_corrections/',
  'monthly_exposure_grid.csv'), show_col_types = FALSE) |>
  mutate(month_index = month_number(period))
presence_profiles <- lapply(seq_len(nrow(units)), function(i) {
  lower <- month_number(units$change_date_lower[i])
  listed |> filter(month_index >= lower - 24, month_index < lower) |>
    group_by(locality_id) |> summarise(listing_months = n(),
      acceptable_positive_months = sum(acceptable & strength > 0, na.rm = TRUE),
      .groups = 'drop') |> mutate(episode_id = units$episode_id[i],
        treated_locality_id = units$locality_id[i])
}) |> bind_rows()
profiles <- profiles |> left_join(presence_profiles,
  by = c('episode_id', 'treated_locality_id', 'locality_id'))
# Identify other documented changes in a candidate comparison's observation
# window. This uses treatment histories, never its favorable post-outcome counts.
profiles$other_change_ids <- vapply(seq_len(nrow(profiles)), function(i) {
  episode <- units[match(profiles$episode_id[i], units$episode_id), ]
  lower <- month_number(episode$change_date_lower) - 24
  upper <- month_number(episode$change_date_upper) + 6
  relevant <- units |> filter(locality_id == profiles$locality_id[i],
    episode_id != profiles$episode_id[i], month_number(change_date_lower) <= upper,
    month_number(change_date_upper) >= lower)
  paste(unique(relevant$episode_id), collapse = ';')
}, character(1))
save_table(profiles, 'all_comparison_preperiod_profiles')
save_table(read_csv('data/withdrawal_feasibility/comparison_assessments.csv',
  show_col_types = FALSE), 'documentary_comparison_assessments')
save_table(events |> filter(type_of_violence == 3, match_count == 1) |>
  count(locality_id, year, decision_reason, name = 'records'), 'inclusion_coverage_audit')
save_table(events |> filter(type_of_violence == 3, match_count == 1,
  valid_dates, !same_month), 'month_boundary_exclusions')
save_table(eligible |> left_join(inventory, by = 'locality_id') |>
  group_by(definition, province, year) |> summarise(events = n(),
    civilian_deaths = sum(deaths_civilians), kst_events = sum(kst_cited),
    un_events = sum(un_cited), okapi_events = sum(okapi_cited), .groups = 'drop'), 'source_composition')
save_table(eligible |> count(definition, locality_id, year, side_a, side_b, name = 'events'),
  'actor_composition')
adjacent <- st_touches(boundaries)
save_table(bind_rows(lapply(seq_along(adjacent), function(i) tibble(
  locality_id = rep(inventory$locality_id[i], length(adjacent[[i]])),
  neighbor_id = inventory$locality_id[adjacent[[i]]]))), 'boundary_neighbors')
# This descriptive figure shows the provincial decision only, without pretending
# the component bases or eight outcome units are independent experiments.
figure_rows <- windows |> filter(episode_id == 'south_kivu_2024', definition == 'strict')
p <- ggplot(figure_rows, aes(month, civilian_deaths)) + geom_line(linewidth = .4) +
  geom_point(size = 1) + geom_vline(xintercept = as.Date('2024-04-30'),
    linetype = 2, color = '#b24b36') + facet_wrap(~locality, scales = 'free_y', ncol = 2) +
  labs(title = 'South Kivu: recorded civilian deaths around withdrawal',
    subtitle = '24 complete pre-months and six post-months; transition month shown',
    x = NULL, y = 'Recorded civilian deaths',
    caption = 'One provincial decision. Different y-axis scales. Reporting completeness is unknown; this is not a treatment-effect estimate.') +
  scale_y_continuous(limits = function(x) c(0, max(1, x[2])),
    breaks = function(x) unique(round(pretty(x, n = 4)))) + theme_minimal(base_size = 10)
ggsave(file.path(output_dir, 'south_kivu_feasibility.png'), p, width = 10, height = 10, dpi = 180)
inputs <- c('data/interim/ucdp/GEDEvent_v26_1.csv', 'data/raw/boundaries/salb_2018.geojson',
  'config/city_aggregation.csv', 'data/territorial_assignment_exceptions.csv',
  'data/withdrawal_feasibility/episode_register.csv', 'data/withdrawal_feasibility/sources.csv',
  'data/withdrawal_feasibility/comparison_assessments.csv',
  'scripts/audit_withdrawal_feasibility.R', 'scripts/audit_territorial_assignment.R')
save_table(tibble(path = inputs, sha256 = vapply(inputs, function(path)
  digest::digest(readBin(path, 'raw', n = file.info(path)$size),
    serialize = FALSE, algo = 'sha256'), character(1))), 'input_manifest')
writeLines(capture.output(sessionInfo()), file.path(output_dir, 'session_info.txt'))
save_table(tibble(check = c('overlap event decisions', 'quarterly outcome rows',
  'handover windows', 'monthly panel rows', 'model fits'),
  value = c(nrow(overlap), nrow(quarter_check), nrow(handover), nrow(panel), 0)), 'acceptance_checks')
print(count(register, feasibility_class))
print(filter(summary, episode_id == 'south_kivu_2024', definition == 'strict'))
