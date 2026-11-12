# Turn reviewed descriptive outputs into a readable local research packet.
# No model is fitted and no remote page or manuscript is modified.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(ggplot2)
folder <- 'outputs/withdrawal_descriptive'
read_result <- function(name) read_csv(file.path(folder, paste0(name, '.csv')),
  show_col_types = FALSE, guess_max = 100000)
cases <- read_result('case_index')
summary <- read_result('before_after_and_missing_death_scenario')
influence <- read_result('severe_event_influence')
timing <- read_result('timing_and_inclusion_sensitivity')
geography <- read_result('geography_conflict_sensitivity')
severe <- read_result('severe_event_review')
profiles <- read_result('baseline_comparison_profiles')
milestones <- read_result('case_documentary_milestones')
monthly <- read_result('case_monthly_series')
province <- read_result('south_kivu_provincial_summary')
register <- read_csv('data/withdrawal_feasibility/episode_register.csv', show_col_types = FALSE)
assessments <- read_csv('data/withdrawal_feasibility/comparison_assessments.csv', show_col_types = FALSE)
sources <- read_csv('data/withdrawal_feasibility/sources.csv', show_col_types = FALSE)
panel <- read_csv('outputs/withdrawal_feasibility/monthly_panel.csv', show_col_types = FALSE)
# The comparison display is restricted to baseline dates and named candidates
# from the existing documentary assessment, never selected from follow-up outcomes.
comparison_ids <- c('COD011006', 'COMPOSITE_KABARE', 'COMPOSITE_UVIRA',
  'COD009007', 'COMPOSITE_BENI', 'COD017013')
baseline_display <- profiles |> filter(case_id == 'south_kivu_2024__COD011006',
  definition == 'strict', candidate_locality_id %in% comparison_ids) |>
  select(candidate_locality, deaths, first_12_deaths, last_12_deaths,
    death_months, actor_overlap, other_change_ids)
baseline_plot_data <- panel |> filter(definition == 'strict', locality_id %in% comparison_ids,
  month >= as.Date('2022-04-01'), month <= as.Date('2024-03-01'))
baseline_plot <- ggplot(baseline_plot_data, aes(month, civilian_deaths)) +
  geom_line(color = '#245875', linewidth = .5) + geom_point(size = 1, color = '#245875') +
  facet_wrap(~locality, scales = 'free_y', ncol = 2) +
  scale_x_date(date_breaks = '6 months', date_labels = '%b %Y') +
  scale_y_continuous(limits = function(x) c(0, max(1, x[2])),
    breaks = function(x) unique(round(pretty(x, n = 4)))) +
  labs(title = 'Before the South Kivu withdrawal: different violence histories',
    subtitle = 'April 2022 to March 2024 only; documentary candidates, not approved controls',
    x = NULL, y = 'Recorded civilian deaths per month',
    caption = 'Different y-axis scales. Actor overlap table uses Kalehe as reference; no post-period outcomes select these locations.') +
  theme_minimal(base_size = 11) + theme(plot.caption = element_text(hjust = 0, size = 9))
ggsave(file.path(folder, 'baseline_comparison_histories.png'), baseline_plot,
  width = 11, height = 8, dpi = 160)
write_csv(baseline_display, file.path(folder, 'priority_baseline_comparison.csv'))

# Simple Markdown tables keep exact values inspectable beside the figures.
markdown_table <- function(x) {
  x <- as.data.frame(x)
  x[] <- lapply(x, function(z) {
    if (is.numeric(z)) z <- format(round(z, 3), trim = TRUE, scientific = FALSE)
    z <- as.character(z)
    z[is.na(z) | z == 'NA'] <- 'unknown / not applicable'
    str_replace_all(z, '[\r\n|]', ' ')
  })
  c(paste0('| ', paste(names(x), collapse = ' | '), ' |'),
    paste0('| ', paste(rep('---', ncol(x)), collapse = ' | '), ' |'),
    apply(x, 1, function(row) paste0('| ', paste(row, collapse = ' | '), ' |')))
}
parts <- c('# MONUSCO withdrawal descriptive evidence packet', '',
  '12 November 2026. Recorded one-sided civilian deaths are the primary outcome; recorded events are secondary.', '',
  '**The existing data support timelines and measurement checks, but not a credible estimate of the effect of withdrawal.** The patterns vary by locality, some depend on a single event, and one influential event has conflicting territorial assignments. None of these results establishes that MONUSCO withdrawal increased or decreased underlying civilian deaths.', '',
  '## What was completed', '',
  paste(nrow(cases), 'distinct territorial/date displays cover', n_distinct(cases$decision_cluster),
    'provisional decision clusters. They are not independent experiments. Identical dates and territories within a cluster are deduplicated; overlapping component and provincial displays remain clearly labelled.'), '',
  '- Fixed 24-month baseline and six-month follow-up timelines for every registered, geographically assigned episode with a usable date interval.',
  '- Largest-event review, complete single-event-deletion ranges and source/geography flags.',
  '- Baseline-only profiles for all 19 candidate localities, with event-frequency actor overlap and existing documentary comparison decisions.',
  '- Strict versus conservative territorial inclusion, earliest/latest timing, uniform geography-conflict exclusion, and hypothetical missing-death scenarios.', '',
  '## How to read the comparisons', '',
  'The main baseline is the 24 complete calendar months before the earliest documented transition month. Follow-up is the six complete months after the latest documented transition month. All transition months are displayed but omitted from the before/after summaries. Three-month follow-up blocks are also saved. These calendar-month windows differ intentionally from the earlier 90/180-day handover windows; those counts are checked separately.', '',
  'Because the periods differ in length, comparisons use deaths per month. The descriptive difference is post deaths / 6 minus pre deaths / 24. It is not a treatment effect. The six-month historical benchmark is pre deaths / 4, not an estimate of what would have happened without withdrawal. Seasonality, changing conflict conditions and reporting can all affect it.', '',
  'Zeros mean no eligible events were retained in the dataset. They do not certify monitoring coverage. GED low/high bound total event deaths; they are not civilian-specific confidence intervals. All outcomes remain the original corrected coding; conflict exclusions are labelled sensitivities.', '',
  '## South Kivu provincial picture', '',
  'One provincial decision, eight non-overlapping territorial outcome units. Anchor: protection-operation cessation on 30 April 2024; baseline April 2022 to March 2024 and follow-up May to October 2024.', '',
  markdown_table(province |> select(definition, deaths_pre, deaths_post, pre_monthly_deaths,
    post_monthly_deaths, additional_post_deaths_to_erase_decline)), '',
  'The last column asks how many additional post-period deaths would reach or exceed the historical monthly benchmark while holding baseline reporting fixed. It does not estimate missing deaths or their plausibility. The strict benchmark is 17.75 deaths in six months; eight are recorded, so ten additional deaths would erase the decline against that benchmark.', '',
  'Reporting is not stable by assumption: KST announced a pause in November 2023, before the handovers; the UN series stopped covering South Kivu after April 2024; humanitarian reports continued with limited coverage. Source presence does not establish detection completeness. See the [coverage follow-up](withdrawal_protection_coverage_followup.md).', '')

focus <- cases |> filter(decision_cluster == 'nk_2017_reconfiguration' |
  str_detect(episode_ids, 'bunyakiri_2024|kavumu_2024|sange_2024'))
focus_summary <- summary |> inner_join(select(focus, case_id, sites, locality), by = 'case_id') |>
  filter(definition == 'strict') |> select(sites, locality, deaths_pre, deaths_post,
    pre_monthly_deaths, post_monthly_deaths)
parts <- c(parts, '## Priority case findings', '', markdown_table(focus_summary), '',
  '**Walikale:** the apparent decrease is highly dependent on event 234588, the Luhanga massacre with 34 stored civilian deaths. Its coordinates fall in the project\u2019s Walikale polygon, but GED ADM2 identifies Lubero. [AFP/VOA](https://www.voaafrique.com/a/pres-de-34-civils-tues-dans-aatque-village-hutu-par-des-miliciens-nande-en-rdc/3613252.html) and [Radio Okapi](https://www.radiookapi.net/2016/11/29/actualite/securite/nord-kivu-inhumation-des-victimes-de-massacre-de-luhanga) also identify Lubero. Radio Okapi\u2019s later burial report gives a different civilian tally from the provisional AFP report. Preserve the data for reproduction, but do not treat either the locality assignment or stored fatality bounds as settled.', '',
  '**Timing correction (12 November):** July 31 is the supported fixed-base closure anchor. October 19 is a retrospective publication date, not a documented departure alternative. Historical envelope and October-anchor outputs remain for reproduction only. Mobile protection continued in named locations; the end of all coverage is unknown. See [follow-up review](withdrawal_followup_review.md).', '',
  '**Bunyakiri/Kalehe:** four of the six strict follow-up deaths are in Numbi; the other records are in Buganga and Cifunzi Kalonge. These are territorial outcomes, not demonstrated Bunyakiri protection-area outcomes. The local increase survives deleting the four-death event, but the geographic exposure problem remains.', '',
  '**Kavumu/Kabare:** the strict follow-up contains one recorded death at Katana and one in Bukavu. The Katana record has total-event bounds of 1 to 7. The near-flat monthly comparison does not show that airport handover preserved community protection.', '',
  '**Sange/Uvira:** the follow-up has no retained strict events, while six of the 13 baseline deaths occurred at Bijombo. An empty follow-up cannot distinguish no eligible violence from incomplete observation; Bijombo\u2019s connection to Sange\u2019s protection area is unresolved.', '',
  '## Comparison locations', '',
  'Candidate profiles use only the 24 pre-transition months. No post-withdrawal outcome was used to select or rank controls. Actor overlap is the sum of the smaller event shares for each actor across two baseline distributions; it is undefined when either locality has no recorded baseline events. It is descriptive, not a matching score or causal eligibility threshold.', '',
  markdown_table(assessments |> select(episode_group, comparison_location, decision)), '',
  'Sake shares the Masisi outcome unit and supplied activity into Nyabiondo; it cannot be an independent untreated territorial control. Other South Kivu localities share the provincial withdrawal. Djugu and Beni differ in conflict dynamics; Masisi experienced the M23 offensive and a position withdrawal. Similar baseline averages would not override those substantive problems.', '',
  'Detailed [baseline profiles](../outputs/withdrawal_descriptive/baseline_comparison_profiles.csv) retain all candidates, exposure-listing limitations and other registered changes. No candidate is upgraded to a causal control.', '',
  '![Pre-withdrawal comparison histories](../outputs/withdrawal_descriptive/baseline_comparison_histories.png)', '',
  'Selected baseline profiles below use Kalehe as the actor-overlap reference. The first/last columns each span 12 months; differences are descriptive. Beni, Djugu and Masisi were already named in the documentary assessment, not selected using these values.', '',
  markdown_table(baseline_display), '',
  '![Timing and inclusion sensitivity](../outputs/withdrawal_descriptive/measurement_sensitivity.png)', '',
    '## Checks and human review', '',
  'The script reconciles every case-month against event-level counts, verifies complete windows and checks upstream input hashes. Original quarter and handover counts are independently rechecked by the validation script. See [validation results](../outputs/withdrawal_descriptive/validation_checks.csv).', '',
  'Review priority: resolve Luhanga\u2019s coordinates versus the boundary and administrative description before any new primary geographic coding. A uniform sensitivity removes all known ADM2/polygon disagreements, not just this consequential event. Nineteen unique conflicting records occur across the displayed windows; unknown administrative fields are not treated as matches. Other recorded uncertainties are retained in the event ledger.', '',
  'Patrol catchments, actual patrol continuity and historical monitoring effort still await external records. If those records are unavailable, retain descriptive inference. A causal analysis would require a separate fixed specification and credible comparison, not another fitted model.', '',
  '## Case pages', '',
  'Every page below uses the same rules. Images and the [combined timeline PDF](../outputs/withdrawal_descriptive/all_case_timelines.pdf) are generated by R. The tables describe overlapping windows; do not sum across cases.', '')

for (i in seq_len(nrow(cases))) {
  cs <- cases[i, ]
  rows <- summary |> filter(case_id == cs$case_id) |>
    select(definition, deaths_pre, deaths_post, events_pre, events_post, monthly_difference)
  sens <- timing |> filter(case_id == cs$case_id) |>
    select(definition, scenario, deaths_pre, deaths_post, monthly_difference)
  infl <- influence |> filter(case_id == cs$case_id, definition == 'strict')
  geo <- geography |> filter(case_id == cs$case_id, definition == 'strict')
  ev <- severe |> filter(case_id == cs$case_id, definition == 'strict', block != 'transition') |>
    select(block, id, start_date, deaths_civilians, where_description, admin_agrees)
  regs <- register |> filter(episode_id %in% str_split(cs$episode_ids, ';')[[1]])
  ids <- unique(unlist(str_split(regs$source_ids, ';')))
  links <- sources |> filter(source_id %in% ids)
  ms <- milestones |> filter(case_id == cs$case_id) |>
    select(date_lower, date_upper, documented_area, activity_type, limitation)
  influence_text <- if (is.na(infl$largest_id)) {
    'No retained pre/post event is available for an event-deletion calculation; this does not certify absence of violence.'
  } else paste('Largest pre/post event:', infl$largest_id, '; deaths:', infl$largest_deaths,
      '. Monthly difference after deleting that one event:', round(infl$difference_without_largest, 3),
      '. All single-event-deletion differences range from', round(infl$min_single_deletion_difference, 3),
      'to', round(infl$max_single_deletion_difference, 3), '(sensitivity range, not an interval estimate).')
  parts <- c(parts, paste('###', cs$sites, '-', cs$locality), '',
    paste('Decision cluster:', cs$decision_cluster, '| Recorded transition:', cs$change_date_lower,
      'to', cs$change_date_upper, '| Feasibility class:', cs$feasibility_class), '',
    paste(unique(regs$decision_reason), collapse = ' '), '',
    paste0('![Monthly recorded deaths and events](../outputs/withdrawal_descriptive/figures/', cs$case_id, '.png)'), '',
    markdown_table(rows), '', '**Timing and inclusion sensitivity**', '', markdown_table(sens), '',
    influence_text, '',
    paste('Removing all known geography conflicts gives', geo$pre_deaths_without_conflicts,
      'pre deaths and', geo$post_deaths_without_conflicts, 'post deaths; monthly difference',
      round(geo$monthly_difference_without_conflicts, 3), '. Unknown ADM2 remains unresolved.'), '',
    '**Largest saved event records in each non-transition block**', '', markdown_table(ev), '')
  if (nrow(ms) > 0) parts <- c(parts, '**Documentary protection milestones**', '', markdown_table(ms), '')
  parts <- c(parts, paste(paste0('[', links$source_id, ': ', links$publisher, '](', links$url, ')'), collapse = ' ; '), '')
}
parts <- c(parts, '## Reproduction', '',
  'Run from the project root with the established R library:', '', '```r',
  'source("scripts/build_withdrawal_descriptive_evidence.R")',
  'source("scripts/validate_withdrawal_descriptive_evidence.R")',
  'source("scripts/write_withdrawal_descriptive_packet.R")', '```', '',
  'The upstream feasibility audit must already exist and its input hashes must match. Its workflow reconstructs the original geography and inclusion rules. No raw GED redistribution is required to inspect this packet; local inputs remain in their existing ignored data directories.')
writeLines(parts, 'docs/withdrawal_descriptive_evidence_packet.md', useBytes = TRUE)

# Compact comparison figure: differences between recorded monthly rates only.
# Use point shapes as well as color so definitions remain distinguishable.
figure_rows <- timing |> inner_join(select(focus, case_id, locality, sites), by = 'case_id') |>
  mutate(label = paste(locality, sites, sep = '\n'),
    scenario = factor(scenario, levels = c('main_interval_envelope',
      'earliest_documented_month', 'latest_documented_month')))
p <- ggplot(figure_rows, aes(monthly_difference, label, color = definition, shape = scenario)) +
  geom_vline(xintercept = 0, color = 'grey65') +
  geom_point(position = position_dodge(width = .6), size = 2.6) +
  scale_color_manual(values = c(strict = '#245875', territorial = '#a54d1c')) +
  labs(title = 'How timing and event inclusion change the descriptive comparison',
    subtitle = '24 complete baseline months and six follow-up months; territorial outcomes',
    x = 'Post minus pre recorded civilian deaths per month', y = NULL,
    caption = 'Points are alternative calculations, not estimated treatment effects or confidence intervals.') +
  theme_minimal(base_size = 11) + theme(legend.position = 'bottom', plot.caption = element_text(hjust = 0))
ggsave(file.path(folder, 'measurement_sensitivity.png'), p, width = 11, height = 7, dpi = 160)
cat('Wrote descriptive evidence packet and sensitivity figure.\n')
