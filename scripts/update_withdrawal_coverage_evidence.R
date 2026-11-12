# Apply documentary corrections without choosing dates from outcome patterns.
library(readr)
library(dplyr)
root <- 'data/withdrawal_feasibility'
register_path <- file.path(root, 'episode_register.csv')
register <- read_csv(register_path, col_types = cols(.default = col_character()))
snapshot <- file.path(root, 'episode_register_before_coverage_followup.csv')
if (!file.exists(snapshot)) write_csv(register, snapshot)
extra <- read_csv(file.path(root, 'coverage_followup_sources.csv'),
  col_types = cols(.default = col_character()))
sources_path <- file.path(root, 'sources.csv')
sources <- read_csv(sources_path, col_types = cols(.default = col_character()))
sources <- bind_rows(sources |> filter(!source_id %in% extra$source_id),
  extra |> select(source_id, publication_date, publisher, url, supported_claim))
write_csv(sources, sources_path)
# Conflicting claims must not be collapsed into an invented precise date.
# Remove Pinga from assigned territorial windows until base and catchment are
# located consistently; the previous assignment is preserved in the snapshot.
for (i in seq_len(nrow(register))) {
  id <- register$episode_id[i]
  if (id == 'pinga_2017') {
    register$locality_id[i] <- NA_character_
    register$change_date_lower[i] <- NA_character_
    register$change_date_upper[i] <- NA_character_
    register$feasibility_class[i] <- '3'
    register$change_type[i] <- 'base closure; month disputed'
    register$geographic_scope[i] <- 'Pinga / Masisi-Walikale interface; base and catchment unresolved'
    register$decision_reason[i] <- 'Documentary only: CIVIC May 2017 conflicts with UNJHRO August 2017; territorial assignment also conflicts.'
    register$notes[i] <- 'Separate claims retained in protection-area evidence; no preferred closure month selected.'
    register$source_ids[i] <- 's02;s04;p04;p06;p09'
    register$nearby_un_presence[i] <- 'Kitshanga base reported before closure; accessibility concern; 2019 Pinga patrol does not establish 2017 continuity.'
  }
  if (id %in% c('walikale_2017','bunyampuri_2017','masisi_2017','nyabiondo_2017','luofu_2017')) {
    register$source_ids[i] <- paste(unique(c(strsplit(register$source_ids[i], ';')[[1]],
      'p01','p02','p08')), collapse = ';')
    register$notes[i] <- paste('p01 reports fixed-base closure on 31 July; p08 discusses departing Nyabiondo personnel in an August briefing.',
      'Keep broad documentary interval pending final-convoy reconciliation; no date is loss of all protection.')
    register$nearby_un_presence[i] <- 'Named mobile deployments from early August; see protection_area_evidence_2017.csv. Continuous patrol intensity unknown.'
  }
  if (id == 'nyabiondo_2017') register$source_ids[i] <- paste(register$source_ids[i], 'p03;p04', sep = ';')
  if (id == 'luofu_2017') {
    register$source_ids[i] <- paste(register$source_ids[i], 'p05', sep = ';')
    register$notes[i] <- paste(register$notes[i], 'UNJHRO also records June 2019 Luofu closure: reconcile operational phases.')
  }
  if (id == 'bunyakiri_2024') {
    register$source_ids[i] <- paste(unique(c(strsplit(register$source_ids[i], ';')[[1]], 'r02')), collapse = ';')
    register$notes[i] <- 'Humanitarian report describes departure 18 April; UN formal handover 19 April. Existing handover anchor retained; distinct milestones need reconciliation.'
  }
}
write_csv(register, register_path)
stopifnot(nrow(register) == 36, sum(register$feasibility_class == '2') == 21,
  sum(register$feasibility_class == '3') == 15,
  all(unlist(strsplit(register$source_ids, ';')) %in% sources$source_id))
