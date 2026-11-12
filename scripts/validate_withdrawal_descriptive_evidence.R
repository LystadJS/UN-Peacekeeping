# Independent arithmetic and lineage checks for the descriptive extension.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(readr)
folder <- 'outputs/withdrawal_descriptive'
get_table <- function(name) read_csv(file.path(folder, paste0(name, '.csv')), show_col_types = FALSE)
cases <- get_table('case_index')
series <- get_table('case_monthly_series')
summary <- get_table('before_after_and_missing_death_scenario')
timing <- get_table('timing_and_inclusion_sensitivity')
influence <- get_table('severe_event_influence')
profiles <- get_table('baseline_comparison_profiles')
events <- read_csv('outputs/withdrawal_feasibility/eligible_event_lineage.csv', show_col_types = FALSE,
  guess_max = 100000)
stopifnot(nrow(problems(events)) == 0)
panel <- read_csv('outputs/withdrawal_feasibility/monthly_panel.csv', show_col_types = FALSE)
checks <- tibble(check = character(), passed = logical(), observations = integer())
check <- function(name, condition, observations) {
  if (!isTRUE(condition)) stop(paste('Validation failed:', name))
  checks <<- bind_rows(checks, tibble(check = name, passed = TRUE, observations = as.integer(observations)))
}
check('one case-definition-month row', !anyDuplicated(series[c('case_id','definition','month')]), nrow(series))
check('19 preperiod candidate profiles per case-definition',
  all(count(profiles, case_id, definition)$n == 19), nrow(profiles))
check('24 months in every baseline candidate profile', all(profiles$months == 24), nrow(profiles))
check('all comparisons explicitly unapproved', all(profiles$status == 'No causal control approved'), nrow(profiles))

# Reproduce the original quarter counts independently, not from extension tables.
original <- readRDS('outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds')
quarterly <- panel |> filter(definition == 'strict', month >= as.Date('2016-01-01'),
    month < as.Date('2024-01-01')) |>
  mutate(source_quarter = as.integer(format(month, '%Y')) * 4L +
    (as.integer(format(month, '%m')) - 1L) %/% 3L) |>
  group_by(locality_id, source_quarter) |>
  summarise(events = sum(events), deaths = sum(civilian_deaths), .groups = 'drop') |>
  inner_join(original, by = c('locality_id','source_quarter'))
check('original 2016-2023 quarterly outcomes reproduced', nrow(quarterly) == 608 &&
  all(quarterly$events == quarterly$recorded_events) &&
  all(quarterly$deaths == quarterly$civilian_fatalities), nrow(quarterly))

# Exact day windows use fully contained event date intervals. Do not equate a
# 180-day interval with six complete calendar months or double-count straddlers.
handover <- read_csv('outputs/south_kivu_handovers/handover_windows.csv', show_col_types = FALSE)
for (i in seq_len(nrow(handover))) {
  row <- handover[i, ]
  matching <- events |> filter(definition == 'strict', locality_id == row$locality_id,
    start_date >= row$window_start, end_date <= row$window_end)
  check(paste('original handover window', i), nrow(matching) == row$events &&
    sum(matching$deaths_civilians) == row$civilian_fatalities, nrow(matching))
}

# Full-period arithmetic and integer tipping-point minimality.
check('monthly rates use period-specific denominators',
  all(abs(summary$monthly_difference - (summary$deaths_post / 6 - summary$deaths_pre / 24)) < 1e-10), nrow(summary))
declines <- filter(summary, monthly_difference < 0)
check('missing-death thresholds are sufficient and minimal',
  all((declines$deaths_post + declines$additional_post_deaths_to_erase_decline) / 6 >= declines$deaths_pre / 24) &&
  all((declines$deaths_post + declines$additional_post_deaths_to_erase_decline - 1) / 6 < declines$deaths_pre / 24), nrow(declines))
check('no missing-death threshold for non-declines',
  all(is.na(summary$additional_post_deaths_to_erase_decline[summary$monthly_difference >= 0])), nrow(summary))
check('all timing scenarios complete', all(timing$months_pre == 24 & timing$months_post == 6), nrow(timing))

# Strict events must be included in the conservative territorial sensitivity;
# the corresponding before/after event and death counts cannot shrink.
wide <- summary |> select(case_id, definition, deaths_pre, deaths_post, events_pre, events_post) |>
  pivot_wider(names_from = definition, values_from = c(deaths_pre, deaths_post, events_pre, events_post))
check('territorial sensitivity contains strict counts',
  all(wide$deaths_pre_territorial >= wide$deaths_pre_strict) &&
  all(wide$deaths_post_territorial >= wide$deaths_post_strict) &&
  all(wide$events_pre_territorial >= wide$events_pre_strict) &&
  all(wide$events_post_territorial >= wide$events_post_strict), nrow(wide))

# Audit the largest-event deletion using raw eligible records and date windows.
for (i in seq_len(nrow(influence))) {
  row <- influence[i, ]
  if (is.na(row$largest_id)) next
  event <- events |> filter(definition == row$definition, id == row$largest_id)
  check(paste('largest-event record exists', i), nrow(event) == 1 &&
    event$deaths_civilians == row$largest_deaths, 1)
  recalculated <- if (row$largest_block == 'pre_24') {
    row$deaths_post / 6 - (row$deaths_pre - event$deaths_civilians) / 24
  } else (row$deaths_post - event$deaths_civilians) / 6 - row$deaths_pre / 24
  check(paste('largest-event deletion arithmetic', i),
    abs(recalculated - row$difference_without_largest) < 1e-10, 1)
}
province <- get_table('south_kivu_provincial_summary')
for (definition_value in c('strict', 'territorial')) {
  subset <- panel |> filter(province == 'Sud-Kivu', definition == definition_value)
  baseline <- subset |> filter(month >= as.Date('2022-04-01'), month <= as.Date('2024-03-01'))
  followup <- subset |> filter(month >= as.Date('2024-05-01'), month <= as.Date('2024-10-01'))
  target <- province |> filter(definition == definition_value)
  check(paste('provincial counts without duplicate handovers', definition_value),
    sum(baseline$civilian_deaths) == target$deaths_pre &&
    sum(followup$civilian_deaths) == target$deaths_post &&
    nrow(baseline) == 24 * 8 && nrow(followup) == 6 * 8, nrow(baseline) + nrow(followup))
}
write_csv(checks, file.path(folder, 'validation_checks.csv'))
cat(nrow(checks), 'independent checks passed. No model fitted.\n')
