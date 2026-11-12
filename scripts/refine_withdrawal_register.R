# Curatorial refinements after dated source review; no outcome-based decisions.
# Historical initial-pass script. The subsequent coverage audit supersedes its
# Pinga assignment and date claims; do not overwrite that newer evidence.
if (file.exists('data/withdrawal_feasibility/episode_register_before_coverage_followup.csv')) {
  stop('Initial-pass refinement is superseded. Use update_withdrawal_coverage_evidence.R and the curated register.')
}
library(readr)
library(dplyr)
path <- 'data/withdrawal_feasibility/episode_register.csv'
r <- read_csv(path, col_types = cols(.default = col_character()))
r <- r |> mutate(
  geographic_scope = coalesce(geographic_scope, 'Base; protection catchment unmapped'),
  planned_date = case_when(episode_id %in% c('walikale_2017','bunyampuri_2017',
    'masisi_2017','nyabiondo_2017','luofu_2017') ~ '2017-07-31',
    episode_id == 'kasai_2021' ~ '2021-06-30',
    episode_id == 'offices_2019' ~ '2019-06-30', TRUE ~ planned_date),
  change_date_lower = if_else(episode_id == 'pinga_2017', '2017-05-01', change_date_lower),
  change_date_upper = case_when(episode_id == 'pinga_2017' ~ '2017-05-31',
    episode_id %in% c('walikale_2017','bunyampuri_2017','masisi_2017','nyabiondo_2017','luofu_2017') ~ '2017-10-19',
    TRUE ~ change_date_upper),
  feasibility_class = if_else(episode_id == 'pinga_2017', '2', feasibility_class),
  change_type = if_else(episode_id == 'pinga_2017', 'base closure; month known', change_type),
  source_ids = if_else(episode_id %in% c('walikale_2017','bunyampuri_2017',
    'masisi_2017','nyabiondo_2017','luofu_2017'), 's03;s04;s28', source_ids),
  notes = case_when(episode_id == 'pinga_2017' ~ 'CIVIC January 2018 report page 2 states May 2017; boundary-crossing catchment unresolved.',
    episode_id %in% c('walikale_2017','bunyampuri_2017','masisi_2017','nyabiondo_2017','luofu_2017') ~
      'Conservative interval from scheduled start to October retrospective confirmation; not a verified last-departure date.',
    episode_id == 'butembo_2022' ~ '18-24 August is a provisional reporting-week envelope; exact final departure remains uncertain.',
    TRUE ~ coalesce(notes, 'Unknown dates are missing; no absence inferred from missing listings.')),
  actual_departure_date = if_else(episode_id %in% c('rumangabo_2022','sake_2024'),
    change_date_lower, actual_departure_date),
  replacement_evidence = case_when(episode_id == 'kamanyola_2024' ~ 'PNC received base; not proof of sustained community patrols',
    episode_id %in% c('bunyakiri_2024','kavumu_2024') ~ 'FARDC received facilities; continuing deployment constrained',
    episode_id == 'sange_2024' ~ 'FARDC and PNC temporary arrangements reported after transfer',
    episode_id == 'kamango_2023' ~ 'Local authorities received installations; FARDC regiment present at ceremony',
    TRUE ~ replacement_evidence),
  decision_reason = case_when(feasibility_class == '2' ~ paste('Descriptive only:', withdrawal_reason_and_confounding,
    '| Territorial outcomes do not establish base protection catchment or a credible counterfactual.'),
    TRUE ~ paste('Documentary only:', geographic_scope, '| Timing or community-protection exposure remains unverified.')))
write_csv(r, path)
s <- read_csv('data/withdrawal_feasibility/sources.csv', col_types = cols(.default = col_character()))
if (!'s28' %in% s$source_id) s <- bind_rows(s, tibble(source_id = 's28', publication_date = '2017-10-19',
  publisher = 'Radio Okapi', url = 'https://www.radiookapi.net/2017/10/19/actualite/securite/nord-kivu-evaluation-des-defis-securitaires-apres-la-fermeture-des',
  supported_claim = 'Retrospective review confirms closures; individual final departure dates not stated.'))
s$publication_date[s$source_id == 's09'] <- NA_character_
write_csv(s, 'data/withdrawal_feasibility/sources.csv')
