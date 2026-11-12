# Descriptive withdrawal evidence, using the existing audited outcomes.
# Run from the project root after audit_withdrawal_feasibility.R.
# No effect model, optimized comparison selection, or new inclusion rule is fit.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(ggplot2)

input_dir <- 'outputs/withdrawal_feasibility'
output_dir <- 'outputs/withdrawal_descriptive'
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(output_dir, 'figures'), showWarnings = FALSE)
read_table <- function(name) read_csv(file.path(input_dir, paste0(name, '.csv')),
  show_col_types = FALSE, guess_max = 100000)
save_table <- function(x, name) write_csv(x, file.path(output_dir, paste0(name, '.csv')))
month_number <- function(x) as.integer(format(x, '%Y')) * 12L + as.integer(format(x, '%m'))
month_date <- function(x) as.Date(sprintf('%04d-%02d-01', (x - 1L) %/% 12L, (x - 1L) %% 12L + 1L))

panel <- read_table('monthly_panel')
events <- read_table('eligible_event_lineage')
register <- read_csv('data/withdrawal_feasibility/episode_register.csv', show_col_types = FALSE)
old_windows <- read_table('episode_monthly_windows')
inventory <- distinct(panel, locality_id, locality, province)
stopifnot(nrow(inventory) == 19, n_distinct(panel$definition) == 2,
  !anyDuplicated(panel[c('definition', 'locality_id', 'month')]),
  !anyDuplicated(events[c('definition', 'id')]),
  all(events$type_of_violence == 3), all(events$same_month),
  all(events$deaths_civilians >= 0))

# Reject stale inputs: the original audit's input hashes must still match.
manifest <- read_table('input_manifest')
hash_file <- function(path) digest::digest(readBin(path, 'raw', n = file.info(path)$size),
  serialize = FALSE, algo = 'sha256')
current_hash <- vapply(manifest$path, hash_file, character(1))
stopifnot(all(current_hash == manifest$sha256))

# Equivalent territorial series for bases sharing the same decision/date interval
# are one descriptive case, not repeated observations. Different component dates
# remain separately labelled displays and must never be summed as experiments.
cases <- old_windows |> distinct(episode_id, decision_cluster, locality_id, locality, province) |>
  left_join(register |> select(episode_id, site, change_date_lower, change_date_upper,
    feasibility_class, geographic_scope, notes), by = 'episode_id') |>
  group_by(decision_cluster, locality_id, locality, province, change_date_lower, change_date_upper) |>
  summarise(case_id = first(sort(episode_id)), episode_ids = paste(sort(episode_id), collapse = ';'),
    sites = paste(sort(unique(site)), collapse = ' / '),
    feasibility_class = max(feasibility_class), .groups = 'drop') |>
  mutate(case_id = paste(case_id, locality_id, sep = '__'),
    lower_month = month_number(change_date_lower), upper_month = month_number(change_date_upper),
    scope = if_else(decision_cluster == 'south_kivu_2024',
      'One provincial withdrawal; component and territorial series overlap',
      'Territorial outcome context; protection catchment not established'))
stopifnot(!anyDuplicated(cases$case_id), !anyNA(cases$lower_month))
save_table(cases, 'case_index')

# Join counts by locality, then apply the fixed window. No post-outcome choices.
case_months <- inner_join(cases, panel, by = c('locality_id', 'locality', 'province'),
  relationship = 'many-to-many') |>
  filter(month_index >= lower_month - 24, month_index <= upper_month + 6) |>
  mutate(block = case_when(month_index < lower_month ~ 'pre_24',
    month_index <= upper_month ~ 'transition', month_index <= upper_month + 3 ~ 'post_1_3',
    TRUE ~ 'post_4_6'))
save_table(case_months, 'case_monthly_series')
stopifnot(all(count(filter(case_months, block == 'pre_24'), case_id, definition)$n == 24),
  all(count(filter(case_months, str_detect(block, '^post')), case_id, definition)$n == 6))

case_events <- inner_join(cases, events, by = 'locality_id', relationship = 'many-to-many') |>
  mutate(month_index = month_number(month)) |>
  filter(month_index >= lower_month - 24, month_index <= upper_month + 6) |>
  mutate(block = case_when(month_index < lower_month ~ 'pre_24',
    month_index <= upper_month ~ 'transition', month_index <= upper_month + 3 ~ 'post_1_3',
    TRUE ~ 'post_4_6'))

# Independently reconcile event-level aggregates against the saved monthly panel.
recount <- case_events |> group_by(case_id, definition, month) |>
  summarise(recount_events = n(), recount_deaths = sum(deaths_civilians), .groups = 'drop')
reconcile <- case_months |> left_join(recount, by = c('case_id', 'definition', 'month')) |>
  mutate(recount_events = replace_na(recount_events, 0L), recount_deaths = replace_na(recount_deaths, 0))
stopifnot(all(reconcile$events == reconcile$recount_events),
  all(reconcile$civilian_deaths == reconcile$recount_deaths))

block_summary <- case_months |> group_by(case_id, definition, block) |>
  summarise(months = n(), events = sum(events), deaths = sum(civilian_deaths),
    largest_event = max(largest_episode), kst_events = sum(kst_events),
    un_events = sum(un_events), okapi_events = sum(okapi_events), .groups = 'drop') |>
  mutate(deaths_per_month = deaths / months,
    kst_share = if_else(events > 0, kst_events / events, NA_real_))
save_table(block_summary, 'block_summary')

# The benchmark is the observed baseline monthly mean, not a counterfactual.
before_after <- case_months |> filter(block != 'transition') |>
  mutate(period = if_else(block == 'pre_24', 'pre', 'post')) |>
  group_by(case_id, definition, period) |>
  summarise(months = n(), deaths = sum(civilian_deaths), events = sum(events),
    first_half_deaths = sum(civilian_deaths[month_index < first(lower_month) - 12]),
    .groups = 'drop') |>
  select(-first_half_deaths) |>
  pivot_wider(names_from = period, values_from = c(months, deaths, events)) |>
  mutate(pre_monthly_deaths = deaths_pre / months_pre,
    post_monthly_deaths = deaths_post / months_post,
    monthly_difference = post_monthly_deaths - pre_monthly_deaths,
    pre_monthly_events = events_pre / months_pre,
    post_monthly_events = events_post / months_post,
    six_month_baseline_benchmark = pre_monthly_deaths * months_post,
    # Integer deaths required to reach or exceed the historical-rate benchmark.
    # This assumes all hypothetical additional deaths occur in follow-up and
    # holds baseline ascertainment fixed; it is not estimated missingness.
    additional_post_deaths_to_erase_decline = if_else(monthly_difference < 0,
      ceiling(six_month_baseline_benchmark - deaths_post - 1e-10), NA_real_))
save_table(before_after, 'before_after_and_missing_death_scenario')

# Severe episodes: retain the three largest records in each block (including
# transition), break ties by event ID, and expose original source text and location.
# UCDP low/high are total-event fatality bounds, NOT civilian-specific bounds.
raw <- read_csv('data/interim/ucdp/GEDEvent_v26_1.csv', show_col_types = FALSE,
  col_select = c(id, best, low, high), guess_max = 100000)
stopifnot(!anyDuplicated(raw$id))
top_events <- case_events |> group_by(case_id, definition, block) |>
  arrange(desc(deaths_civilians), id, .by_group = TRUE) |> slice_head(n = 3) |>
  ungroup() |> left_join(raw, by = 'id') |>
  select(case_id, episode_ids, definition, block, id, locality_id, locality,
    start_date, end_date, deaths_civilians, best, low, high, side_a, side_b,
    where_description, where_prec, date_prec, adm_2, admin_locality_id, admin_agrees,
    longitude, latitude, decision_reason, source_article) |>
  mutate(bound_interpretation = 'low/high bound total event deaths; not civilian-only uncertainty',
    audit_status = 'Saved GED/source-citation audit; no fresh independent corroboration claimed',
    civilian_total_discrepancy = deaths_civilians != best)
save_table(top_events, 'severe_event_review')

# Delete one largest event from the WHOLE pre/post series, rather than choosing
# different removals to engineer a direction. Also calculate all single-event
# deletions to show the full range without treating these as confidence intervals.
deletions <- case_events |> filter(block != 'transition') |>
  select(case_id, definition, id, block, deaths_civilians) |>
  left_join(before_after, by = c('case_id', 'definition')) |>
  mutate(difference_without_event = (deaths_post - if_else(block != 'pre_24', deaths_civilians, 0)) / months_post -
    (deaths_pre - if_else(block == 'pre_24', deaths_civilians, 0)) / months_pre)
largest_deletion <- deletions |> group_by(case_id, definition) |>
  arrange(desc(deaths_civilians), id, .by_group = TRUE) |> slice_head(n = 1) |> ungroup() |>
  select(case_id, definition, largest_id = id, largest_block = block,
    largest_deaths = deaths_civilians, difference_without_largest = difference_without_event)
deletion_range <- deletions |> group_by(case_id, definition) |>
  summarise(min_single_deletion_difference = min(difference_without_event),
    max_single_deletion_difference = max(difference_without_event), .groups = 'drop')
influence <- before_after |> left_join(largest_deletion, by = c('case_id', 'definition')) |>
  left_join(deletion_range, by = c('case_id', 'definition')) |>
  mutate(largest_share = if_else(deaths_pre + deaths_post > 0,
      largest_deaths / (deaths_pre + deaths_post), NA_real_),
    direction_changes_without_largest = if_else(is.na(largest_id), NA,
      sign(monthly_difference) != sign(difference_without_largest)))
save_table(influence, 'severe_event_influence')

# Uniform geography sensitivity: remove every eligible event whose parsed ADM2
# disagrees with its polygon assignment. This is not adjudication or reassignment.
# Unknown ADM2 remains unknown, rather than being treated as a confirmed match.
geography_conflicts <- case_events |> filter(!is.na(admin_locality_id),
  admin_locality_id != locality_id)
save_table(geography_conflicts, 'geography_conflict_review')
conflict_totals <- geography_conflicts |> filter(block != 'transition') |>
  group_by(case_id, definition) |>
  summarise(conflicting_events = n(),
    conflicting_pre_deaths = sum(deaths_civilians[block == 'pre_24']),
    conflicting_post_deaths = sum(deaths_civilians[block != 'pre_24']), .groups = 'drop')
geography_sensitivity <- before_after |>
  left_join(conflict_totals, by = c('case_id', 'definition')) |>
  mutate(across(starts_with('conflicting_'), ~replace_na(.x, 0)),
    pre_deaths_without_conflicts = deaths_pre - conflicting_pre_deaths,
    post_deaths_without_conflicts = deaths_post - conflicting_post_deaths,
    monthly_difference_without_conflicts = post_deaths_without_conflicts / months_post -
      pre_deaths_without_conflicts / months_pre)
save_table(geography_sensitivity, 'geography_conflict_sensitivity')

# A provincial summary is calculated only from the eight non-overlapping
# territorial rows anchored to the provincial cessation date, never handovers.
province_summary <- before_after |> filter(str_starts(case_id, 'south_kivu_2024__')) |>
  group_by(definition) |> summarise(localities = n(), deaths_pre = sum(deaths_pre),
    deaths_post = sum(deaths_post), events_pre = sum(events_pre), events_post = sum(events_post),
    .groups = 'drop') |>
  mutate(pre_monthly_deaths = deaths_pre / 24, post_monthly_deaths = deaths_post / 6,
    monthly_difference = post_monthly_deaths - pre_monthly_deaths,
    additional_post_deaths_to_erase_decline = if_else(monthly_difference < 0,
      ceiling(deaths_pre / 4 - deaths_post - 1e-10), NA_real_))
stopifnot(all(province_summary$localities == 8))
save_table(province_summary, 'south_kivu_provincial_summary')

# Timing sensitivity uses the earliest and latest documented month as alternative
# anchors. It does not reinterpret those dates as the cessation of all protection.
# Each alternative uses 24 full pre-months and six full post-months, omitting its
# anchor month. Main envelope analysis above omits the entire uncertain interval.
timing <- bind_rows(mutate(cases, scenario = 'earliest_documented_month', anchor = lower_month),
  mutate(cases, scenario = 'latest_documented_month', anchor = upper_month)) |>
  inner_join(panel, by = c('locality_id', 'locality', 'province'), relationship = 'many-to-many') |>
  filter(month_index >= anchor - 24, month_index <= anchor + 6, month_index != anchor) |>
  mutate(period = if_else(month_index < anchor, 'pre', 'post')) |>
  group_by(case_id, definition, scenario, period) |>
  summarise(months = n(), deaths = sum(civilian_deaths), events = sum(events), .groups = 'drop') |>
  pivot_wider(names_from = period, values_from = c(months, deaths, events)) |>
  mutate(monthly_difference = deaths_post / months_post - deaths_pre / months_pre)
stopifnot(all(timing$months_pre == 24), all(timing$months_post == 6))
save_table(bind_rows(timing, before_after |> mutate(scenario = 'main_interval_envelope') |>
  select(all_of(names(timing)))), 'timing_and_inclusion_sensitivity')

# Baseline comparisons: every candidate is retained, no post-period outcome enters
# the profile or the actor-overlap calculation. Similarity does not approve controls.
profiles <- read_table('all_comparison_preperiod_profiles')
case_lookup <- cases |> select(case_id, episode_ids, locality_id) |>
  separate_rows(episode_ids, sep = ';') |>
  rename(episode_id = episode_ids, treated_locality_id = locality_id)
profiles <- profiles |> inner_join(case_lookup, by = c('episode_id', 'treated_locality_id')) |>
  distinct(case_id, definition, locality_id, .keep_all = TRUE) |>
  rename(candidate_locality_id = locality_id, candidate_locality = locality) |>
  mutate(baseline_monthly_deaths = deaths / months,
    first_12_monthly_deaths = first_12_deaths / 12,
    last_12_monthly_deaths = last_12_deaths / 12,
    baseline_change = last_12_monthly_deaths - first_12_monthly_deaths,
    documented_presence_interpretation = 'Numeric listing coverage is not uninterrupted protection',
    status = 'No causal control approved')
actor_profiles <- cases |> select(case_id, lower_month) |>
  cross_join(events |> select(definition, locality_id, month, side_a)) |>
  filter(month_number(month) >= lower_month - 24, month_number(month) < lower_month) |>
  count(case_id, definition, locality_id, side_a, name = 'actor_events') |>
  group_by(case_id, definition, locality_id) |>
  mutate(actor_share = actor_events / sum(actor_events)) |> ungroup()
# Actor composition is event-frequency based; a zero-event baseline has no
# estimable actor distribution and remains missing rather than perfect overlap.
actor_overlap <- lapply(seq_len(nrow(profiles)), function(i) {
  p <- profiles[i, ]
  a <- actor_profiles |> filter(case_id == p$case_id, definition == p$definition,
    locality_id == p$treated_locality_id) |> select(side_a, treated_share = actor_share)
  b <- actor_profiles |> filter(case_id == p$case_id, definition == p$definition,
    locality_id == p$candidate_locality_id) |> select(side_a, candidate_share = actor_share)
  if (nrow(a) == 0 || nrow(b) == 0) return(NA_real_)
  both <- full_join(a, b, by = 'side_a') |>
    mutate(across(c(treated_share, candidate_share), ~replace_na(.x, 0)))
  sum(pmin(both$treated_share, both$candidate_share))
}) |> unlist()
profiles$actor_overlap <- actor_overlap
save_table(profiles, 'baseline_comparison_profiles')
save_table(actor_profiles, 'baseline_actor_profiles')

# Every case receives two longitudinal panels with independent labelled axes.
# Blank recorded months plot at zero because that is the data's count, not proof
# of monitoring. Transition shading communicates date uncertainty explicitly.
theme_set(theme_minimal(base_size = 11))
milestones <- read_csv('data/withdrawal_feasibility/protection_area_evidence_2017.csv',
  show_col_types = FALSE) |> separate_rows(episode_ids, sep = ';') |>
  rename(episode_id = episode_ids) |> inner_join(case_lookup, by = 'episode_id',
    relationship = 'many-to-many') |> distinct(case_id, evidence_id, .keep_all = TRUE)
save_table(milestones, 'case_documentary_milestones')
pdf(file.path(output_dir, 'all_case_timelines.pdf'), width = 11, height = 7.5)
for (i in seq_len(nrow(cases))) {
  cs <- cases[i, ]
  rows <- case_months |> filter(case_id == cs$case_id, definition == 'strict') |>
    select(month, civilian_deaths, events) |>
    pivot_longer(-month, names_to = 'outcome', values_to = 'count') |>
    mutate(outcome = factor(recode(outcome, civilian_deaths = 'Recorded civilian deaths',
      events = 'Recorded attacks on civilians'),
      levels = c('Recorded civilian deaths', 'Recorded attacks on civilians')))
  plot <- ggplot(rows, aes(month, count)) +
    annotate('rect', xmin = month_date(cs$lower_month), xmax = month_date(cs$upper_month + 1),
      ymin = -Inf, ymax = Inf, fill = '#ead9bb', alpha = .55) +
    geom_line(color = '#245875', linewidth = .5) + geom_point(color = '#245875', size = 1.2) +
    facet_wrap(~outcome, ncol = 1, scales = 'free_y') +
    scale_x_date(date_breaks = '6 months', date_labels = '%b %Y') +
    scale_y_continuous(limits = function(x) c(0, max(1, x[2])),
      breaks = function(x) unique(round(pretty(x, n = 4)))) +
    labs(title = str_wrap(paste(cs$locality, '|', cs$sites), 95),
      subtitle = paste('Change dated', cs$change_date_lower, 'to', cs$change_date_upper,
        '| Shading covers whole transition months; 24 pre-months and six post-months.'),
      x = NULL, y = 'Recorded count', caption = paste(str_wrap(cs$scope, 105),
        'Strict event definition. Territorial context, not a base catchment. Reporting completeness unknown.', sep = '\n')) +
    theme(plot.caption = element_text(hjust = 0, size = 9))
  ms <- milestones |> filter(case_id == cs$case_id, !is.na(date_lower),
    date_lower >= min(rows$month), date_lower <= max(rows$month),
    !str_detect(activity_type, 'proposed|planned'))
  if (nrow(ms) > 0) {
    plot <- plot + geom_vline(data = ms, aes(xintercept = date_lower),
      inherit.aes = FALSE, linetype = 'dotdash', color = '#497a51', alpha = .65) +
      labs(caption = paste(str_wrap(paste('Green markers: documented regional operations/onsets;',
        paste(paste(ms$date_lower, ms$documented_area), collapse = '; ')), 115),
        'Markers do not establish continuous coverage or exclusive catchments. Full intervals and sources in milestone ledger.',
        'Strict territorial counts; reporting completeness unknown. Shared decisions and component series are not independent.', sep = '\n'))
  }
  # These reporting milestones apply as context, not verified local blackout dates.
  if (cs$decision_cluster == 'south_kivu_2024') {
    plot <- plot + geom_vline(xintercept = as.Date('2023-11-09'), linetype = 'dotted', color = '#8c3744') +
      labs(caption = paste('Dotted line: KST pause announced 9 Nov 2023; coverage change predates handovers.',
        'One provincial decision; territorial outcomes, not base catchments. Reporting completeness unknown.', sep = '\n'))
  }
  print(plot)
  ggsave(file.path(output_dir, 'figures', paste0(cs$case_id, '.png')), plot,
    width = 11, height = 7.5, dpi = 150)
}
dev.off()

# Record the original audit's independent reproduction tests alongside new checks.
checks <- tibble(check = c('unique descriptive case IDs', 'event/monthly counts reconcile',
  '24 baseline months per case and definition', '6 follow-up months per case and definition',
  'timing windows complete', 'upstream input hashes unchanged', 'new effect models fitted'),
  passed = TRUE, value = c(nrow(cases), nrow(reconcile), 24, 6, nrow(timing), nrow(manifest), 0))
save_table(checks, 'acceptance_checks')
inputs <- c(file.path(input_dir, c('monthly_panel.csv', 'eligible_event_lineage.csv',
  'episode_monthly_windows.csv', 'all_comparison_preperiod_profiles.csv', 'input_manifest.csv')),
  'data/withdrawal_feasibility/episode_register.csv', 'scripts/build_withdrawal_descriptive_evidence.R')
save_table(tibble(path = inputs, sha256 = vapply(inputs, hash_file, character(1))), 'input_manifest')
writeLines(capture.output(sessionInfo()), file.path(output_dir, 'session_info.txt'))
print(cases |> count(decision_cluster))
print(before_after |> inner_join(select(cases, case_id, sites, locality), by = 'case_id') |>
  filter(definition == 'strict') |>
  select(sites, locality, deaths_pre, deaths_post, monthly_difference,
    additional_post_deaths_to_erase_decline))
