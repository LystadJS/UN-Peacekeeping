# Quantify missing deployment listings without treating them as zero troops.
# This is a descriptive follow-up; it does not change the frozen analysis panel.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)

lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv") |>
  mutate(period = as.Date(period)) |>
  filter(period >= as.Date("2016-01-01"), period <= as.Date("2023-12-01"))
localities <- read.csv("outputs/week_1/audit_aggregated/locality_inventory.csv")
coverage <- read.csv("outputs/quarterly_pilot/exposure_coverage.csv")

# Count listing evidence, not independently observed months or operational coverage.
monthly_listing <- lineage |>
  filter(!is.na(locality_id), nzchar(locality_id)) |>
  distinct(locality_id, period) |>
  count(locality_id, name = "listed_months")
summary_table <- localities |>
  left_join(monthly_listing, by = "locality_id", relationship = "one-to-one") |>
  mutate(listed_months = replace_na(listed_months, 0L),
         unlisted_months = 96L - listed_months) |>
  left_join(select(coverage, locality_id, eligible_quarters, complete_locality),
            by = "locality_id", relationship = "one-to-one") |>
  mutate(verified_zero_months = 0L,
         zero_status = "No months certified as operational absence") |>
  arrange(locality)
stopifnot(nrow(summary_table) == 19L,
          all(summary_table$listed_months + summary_table$unlisted_months == 96L),
          summary_table$listed_months[summary_table$locality == "Djugu"] == 0L)
write.csv(summary_table, "data/absence_followup_localities.csv", row.names = FALSE, na = "")

# These place names are explicitly identified in official UN reports. Matching
# names is only a diagnostic: alternative spellings or geometry errors would need
# a separate adjudication and cannot be resolved by assigning guessed strengths.
place_patterns <- c(Drodro = "^(drodro|drodo)$", Bayoo = "^(bayoo|bayo)$", Fataki = "^fataki$",
                    Rhoo = "^(rhoo|roe)$", Jina = "^jina$", Amee = "^(amee|ame)$")
raw_months <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |>
  ungroup() |> filter(mission == "MONUSCO", year >= 2016, year <= 2023)
raw_maps <- readRDS("data/raw/geo_pko/2.3/location_map.rds") |>
  ungroup() |> filter(mission == "MONUSCO", year >= 2016, year <= 2023)
name_checks <- bind_rows(lapply(names(place_patterns), function(place_name) {
  pattern <- place_patterns[[place_name]]
  data.frame(place = place_name, name_pattern = pattern,
    monthly_rows = sum(grepl(pattern, raw_months$location, ignore.case = TRUE)),
    map_rows = sum(grepl(pattern, raw_maps$location, ignore.case = TRUE)),
    interpretation = "Name diagnostic only; not exhaustive alias adjudication")
}))
write.csv(name_checks, "data/absence_followup_place_checks.csv", row.names = FALSE)
cat("Audited 19 locality listing histories and six official-report place names.\n")
