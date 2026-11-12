# A citation/coverage audit, not a completeness estimate or effect regression.
# Run audit_withdrawal_feasibility.R first to rebuild the event lineage.
.libPaths(c('.local_library', .libPaths()))
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
# Restricted Windows tokens can make file.access report unreadable even when
# opening the authorized file succeeds. A normal connection uses the actual
# open operation; it does not change permissions or request elevated access.
read_csv <- function(file, ...) {
  connection <- base::file(file, open = 'rb')
  on.exit(close(connection))
  readr::read_csv(connection, ...)
}
out <- 'outputs/withdrawal_coverage_followup'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
save_table <- function(x, name) write_csv(x, file.path(out, paste0(name, '.csv')))
area_evidence <- read_csv('data/withdrawal_feasibility/protection_area_evidence_2017.csv',
  col_types = cols(.default = col_character()))
source_register <- read_csv('data/withdrawal_feasibility/sources.csv',
  col_types = cols(.default = col_character()))
stopifnot(nrow(area_evidence) == 16, !anyDuplicated(area_evidence$evidence_id),
  all(unlist(strsplit(area_evidence$source_ids, ';')) %in% source_register$source_id),
  all(as.Date(area_evidence$date_lower) <= as.Date(area_evidence$date_upper), na.rm = TRUE))
input <- 'outputs/withdrawal_feasibility/event_adjudication_ledger.csv'
events <- read_csv(input, show_col_types = FALSE,
  col_types = cols(exclusion_reason = col_character(), evidence = col_character()))
inventory <- read_csv('outputs/week_1/audit_aggregated/locality_inventory.csv', show_col_types = FALSE)
south_ids <- inventory |> filter(province == 'Sud-Kivu') |> pull(locality_id)
stopifnot(length(south_ids) == 8, nrow(problems(events)) == 0, !anyDuplicated(events$id))
# Compare like event definitions. The broad sensitivity still requires unique
# territorial assignment and a within-month date interval; it is not all reports.
selected <- bind_rows(
  events |> filter(original_eligible) |> mutate(definition = 'strict'),
  events |> filter(original_eligible | add_event) |> mutate(definition = 'territorial'),
  events |> filter(type_of_violence == 3, valid_dates, same_month, match_count == 1) |>
    mutate(definition = 'all_spatial_precisions')) |>
  filter(locality_id %in% south_ids, year %in% 2022:2025) |>
  mutate(month = as.Date(format(start_date, '%Y-%m-01')),
    text = str_to_lower(coalesce(source_article, '')),
    has_kst = str_detect(text, 'kivu security|barom[eè]tre|barometre'),
    has_okapi = str_detect(text, 'okapi'),
    source_group = if_else(has_kst, 'KST cited (possibly with others)', 'No KST citation'),
    missing_source = str_trim(text) == '',
    period = case_when(year == 2022 ~ '2022',
      month < as.Date('2023-11-01') ~ '2023 Jan-Oct',
      year == 2023 ~ '2023 Nov-Dec',
      month < as.Date('2024-04-01') ~ '2024 Jan-Mar',
      month == as.Date('2024-04-01') ~ '2024 Apr',
      month <= as.Date('2024-10-01') ~ '2024 May-Oct',
      year == 2024 ~ '2024 Nov-Dec', TRUE ~ '2025'))
stopifnot(!anyDuplicated(selected[c('id','definition')]))
save_table(selected |> select(-text), 'source_event_lineage')
period_totals <- selected |> group_by(definition, period) |>
  summarise(events = n(), deaths = sum(deaths_civilians),
    kst_events = sum(has_kst), okapi_events = sum(has_okapi),
    missing_source = sum(missing_source), kst_share = mean(has_kst), .groups = 'drop') |>
  complete(definition, period = c('2022','2023 Jan-Oct','2023 Nov-Dec',
    '2024 Jan-Mar','2024 Apr','2024 May-Oct','2024 Nov-Dec','2025'),
    fill = list(events = 0L, deaths = 0, kst_events = 0L, okapi_events = 0L,
      missing_source = 0L))
save_table(period_totals, 'period_source_totals')
annual <- selected |> group_by(definition, year) |>
  summarise(events = n(), deaths = sum(deaths_civilians), kst_events = sum(has_kst),
    okapi_events = sum(has_okapi), .groups = 'drop')
save_table(annual, 'annual_source_totals')
previous <- read_csv('outputs/withdrawal_feasibility/source_composition.csv', show_col_types = FALSE) |>
  filter(province == 'Sud-Kivu', year >= 2022)
check <- inner_join(annual, previous, by = c('definition','year'), suffix = c('', '_old'))
stopifnot(nrow(check) == 8, all(check$events == check$events_old),
  all(check$deaths == check$civilian_deaths), all(check$kst_events == check$kst_events_old))
# Count zero citations only as a property of captured records. If no events were
# captured, the share is NA, never zero reporting coverage.
monthly <- crossing(locality_id = south_ids,
  month = seq(as.Date('2022-01-01'), as.Date('2025-12-01'), by = 'month')) |>
  left_join(selected |> filter(definition == 'strict') |>
    group_by(locality_id, month) |>
    summarise(events = n(), deaths = sum(deaths_civilians), kst_events = sum(has_kst),
      okapi_events = sum(has_okapi), .groups = 'drop'), by = c('locality_id','month')) |>
  mutate(across(c(events,deaths,kst_events,okapi_events), ~replace_na(.x, 0)),
    kst_share = if_else(events > 0, kst_events / events, NA_real_),
    reporting_completeness = 'Unknown')
save_table(monthly, 'locality_month_reporting_audit')
# A territorially named monitoring table establishes some reporting activity;
# it does not establish continuous coverage of every village in that territory.
coverage <- crossing(locality_id = south_ids,
    checkpoint = c('April 2024','January-June 2024','August 2024')) |>
  left_join(inventory |> select(locality_id, locality), by = 'locality_id') |>
  mutate(source_id = case_when(checkpoint == 'April 2024' ~ 'r02',
    checkpoint == 'January-June 2024' ~ 'r03', TRUE ~ 'r04'),
    status = if_else(locality_id %in% c('COD011006','COMPOSITE_FIZI','COMPOSITE_UVIRA'),
      'Locality named; reporting activity documented',
      'Not established by reviewed territorial table; not zero incidents'),
    full_locality_coverage = 'Unknown', comparable_mortality_series = FALSE)
save_table(coverage, 'humanitarian_reporting_checkpoints')
save_table(selected |> filter(definition == 'strict') |>
  select(id, locality_id, start_date, end_date, deaths_civilians, source_article, period),
  'strict_records_for_independent_reconciliation')
# A few retained records have a fatal allegation in their cited headline but
# zero best-estimate civilian deaths. Check their stored bounds rather than
# treating them as absent reports or replacing GED with headline totals.
fatality_fields <- read_csv('data/interim/ucdp/GEDEvent_v26_1.csv',
  col_select = c(id, type_of_violence, deaths_a, deaths_b, deaths_civilians,
    deaths_unknown, best, high, low), show_col_types = FALSE) |>
  filter(id %in% c(538744, 565242, 524907))
stopifnot(nrow(fatality_fields) == 3,
  all(fatality_fields$best == with(fatality_fields,
    deaths_a + deaths_b + deaths_civilians + deaths_unknown)))
save_table(fatality_fields, 'fatality_field_spot_check')
plot_rows <- selected |> filter(definition == 'strict') |> count(month, source_group) |>
  complete(month = seq(as.Date('2022-01-01'), as.Date('2025-12-01'), by = 'month'),
    source_group, fill = list(n = 0))
p <- ggplot(plot_rows, aes(month, n, fill = source_group)) + geom_col() +
  geom_vline(xintercept = as.Date(c('2023-11-09','2024-04-30')), linetype = 2) +
  scale_fill_manual(values = c('KST cited (possibly with others)' = '#365f84',
    'No KST citation' = '#c28b43')) +
  labs(title = 'South Kivu: the recorded-event source mix changes',
    subtitle = 'Strict one-sided-event sample; lines mark KST pause announcement and protection-operation cessation',
    x = NULL, y = 'Retained GED events per month', fill = NULL,
    caption = 'Bars measure captured records, not reporting completeness or underlying violence.') +
  theme_minimal(base_size = 11) + theme(legend.position = 'bottom')
ggsave(file.path(out, 'south_kivu_source_mix.png'), p, width = 11, height = 5, dpi = 180)
paths <- c(input, 'scripts/audit_south_kivu_reporting_continuity.R',
  'data/interim/ucdp/GEDEvent_v26_1.csv',
  'data/withdrawal_feasibility/coverage_followup_sources.csv',
  'data/withdrawal_feasibility/protection_area_evidence_2017.csv')
save_table(tibble(path = paths, sha256 = vapply(paths, function(p)
  digest::digest(readBin(p, 'raw', n = file.info(p)$size), serialize = FALSE,
    algo = 'sha256'), character(1))), 'input_manifest')
annual_checked_rows <- nrow(check)
save_table(tibble(check = c('documentary activity rows', 'reconciled annual definition rows',
  'locality month rows', 'humanitarian checkpoints', 'fatality spot checks', 'model fits'),
  value = c(nrow(area_evidence), annual_checked_rows, nrow(monthly), nrow(coverage),
    nrow(fatality_fields), 0)), 'acceptance_checks')
writeLines(capture.output(sessionInfo()), file.path(out, 'session_info.txt'))
print(period_totals |> filter(definition == 'strict'))
print(annual)
