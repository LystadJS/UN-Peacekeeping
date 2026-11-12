# Conservative territorial evidence review; this script does not fit a model.
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
output_dir <- getOption('monusco.audit_output', 'outputs/territorial_assignment')
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
inventory <- read_csv('outputs/week_1/audit_aggregated/locality_inventory.csv', show_col_types = FALSE) |>
  mutate(territory = str_to_lower(str_remove(locality, ' including.*')),
         aliases = case_when(territory == 'irumu' ~ 'irumu|bunia',
                             territory == 'kabare' ~ 'kabare|bukavu',
                             territory == 'nyiragongo' ~ 'nyiragongo|goma',
                             territory == 'fizi' ~ 'fizi|baraka',
                             territory == 'lubero' ~ 'lubero|butembo',
                             TRUE ~ territory))
ged <- read_csv('data/interim/ucdp/GEDEvent_v26_1.csv', show_col_types = FALSE) |>
  filter(country_id == 490, year %in% getOption('monusco.audit_years', 2014:2023))
ledger <- read_csv(getOption('monusco.audit_ledger',
  'outputs/week_1/audit_aggregated/event_ledger.csv'), show_col_types = FALSE)
stopifnot(!anyDuplicated(ged$id), !anyDuplicated(ledger$id))
events <- ledger |> left_join(ged |> select(id, where_description, where_coordinates,
  deaths_civilians, source_article), by = 'id', relationship = 'one-to-one') |>
  mutate(start_date = as.Date(start_date), end_date = as.Date(end_date),
         same_month = format(start_date, '%Y-%m') == format(end_date, '%Y-%m'),
         source_quarter = as.integer(format(start_date, '%Y')) * 4L +
           (as.integer(format(start_date, '%m')) - 1L) %/% 3L,
         original_eligible = type_of_violence == 3 & valid_coordinates & valid_dates &
           match_count == 1 & where_prec == 1 & same_month,
         description = str_to_lower(coalesce(where_description, '')))

# Exact ADM2 dictionary; city and territory names map to the pre-existing
# composite, never to a new geography inferred from a headline.
admin_ids <- vapply(coalesce(events$adm_2, ''), function(admin) {
  matches <- inventory$locality_id[vapply(inventory$aliases, function(alias)
    str_detect(str_to_lower(admin), paste0('^(', alias, ') (territory|town territory|city territory)$')),
    logical(1))]
  if (length(matches) == 1) matches else NA_character_
}, character(1))
events$admin_locality_id <- admin_ids
events$named_localities <- vapply(events$description, function(description) {
  paste(inventory$locality_id[vapply(inventory$aliases, function(alias)
    str_detect(description, paste0('\\b(', alias, ')\\b')), logical(1))], collapse = ';')
}, character(1))
# A distance or direction from a city is not itself proof of containment.
events$explicit_containment <- vapply(seq_len(nrow(events)), function(i) {
  lookup <- match(events$locality_id[i], inventory$locality_id)
  if (is.na(lookup)) return(FALSE)
  alias <- paste0('(', inventory$aliases[lookup], ')')
  pattern <- paste0('\\b', alias, '\\s+(territor|district)|territor[^,.;\\n]{0,16}\\b', alias,
    '\\b|\\bin\\s+(the\\s+)?', alias, '\\b|^south ', alias, '\\b|\\bbeni[- ]mbau\\b')
  str_detect(events$description[i], pattern)
}, logical(1))
events <- events |> mutate(
  admin_agrees = !is.na(admin_locality_id) & !is.na(locality_id) & admin_locality_id == locality_id,
  names_target = !is.na(locality_id) & named_localities == locality_id,
  multiple_or_other_names = named_localities != '' & !names_target,
  preliminary_add = !original_eligible & type_of_violence == 3 & valid_coordinates &
    valid_dates & match_count == 1 & same_month & where_prec %in% 2:3 &
    admin_agrees & ((names_target & explicit_containment) | where_prec == 3) & !multiple_or_other_names,
  decision_reason = case_when(original_eligible ~ 'original_retained',
    type_of_violence != 3 ~ 'other_violence_type',
    !valid_coordinates | !valid_dates | match_count != 1 | !same_month ~ 'other_filter_fails',
    !where_prec %in% 2:3 ~ 'precision_not_2_or_3',
    !admin_agrees ~ 'admin_polygon_conflict_or_unmapped',
    multiple_or_other_names ~ 'other_or_multiple_localities_in_description',
    preliminary_add ~ 'concordant_territorial_evidence',
    TRUE ~ 'insufficient_narrative_evidence')
)
# Narrative exceptions are reviewed before fitting and are applied to every
# year, not chosen according to how a record affects the MONUSCO coefficient.
exceptions_path <- 'data/territorial_assignment_exceptions.csv'
if (file.exists(exceptions_path)) {
  exceptions <- read_csv(exceptions_path, show_col_types = FALSE)
  stopifnot(!anyDuplicated(exceptions$id), all(exceptions$id %in% events$id))
  events <- events |> left_join(exceptions, by = 'id', relationship = 'one-to-one') |>
    mutate(add_event = (preliminary_add | coalesce(accept_from_source, FALSE)) & is.na(exclusion_reason),
           decision_reason = case_when(!is.na(exclusion_reason) ~ exclusion_reason,
             coalesce(accept_from_source, FALSE) ~ 'explicit_source_territory', TRUE ~ decision_reason))
} else {
  events$add_event <- events$preliminary_add
}
write_csv(events, file.path(output_dir, 'event_adjudication_ledger.csv'))
write_csv(events |> filter(type_of_violence == 3, where_prec > 1),
          file.path(output_dir, 'excluded_record_review.csv'))
write_csv(events |> filter(add_event) |> select(id, year, locality_id, adm_2,
  where_prec, where_description, where_coordinates, decision_reason, source_article),
  file.path(output_dir, 'accepted_additions.csv'))
print(events |> filter(type_of_violence == 3, where_prec > 1) |> count(decision_reason))
