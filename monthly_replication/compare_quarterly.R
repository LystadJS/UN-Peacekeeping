# An optional post-build comparison against the released quarterly audit.
# The reference never feeds the monthly panel, model, or forecast.
source("R/libraries.R")
source("R/support.R")
result_dir <- Sys.getenv("MONUSCO_MONTHLY_RESULTS", "results")
prior_dir <- Sys.getenv("MONUSCO_QUARTERLY_RELEASE", "../portfolio/monusco_class_project_20261118")
prior <- read_csv_local(file.path(prior_dir, "data/intermediate/corrected_panel_lineage_summary.csv"))
monthly <- read_csv_local(file.path(result_dir, "deployment_lineage.csv")) |>
  transmute(location_key = key_text(location), map_date, source,
            months = period, territory_id, monthly_military = military_estimate) |>
  group_by(location_key, map_date) |>
  summarise(monthly_listing_months = n_distinct(months), monthly_maps = paste(sort(unique(source)), collapse = "; "),
            monthly_territories = paste(sort(unique(na.omit(territory_id))), collapse = "; "),
            monthly_military = if (n_distinct(monthly_military) == 1) first(monthly_military) else NA_real_,
            .groups = "drop")
comparison <- prior |>
  mutate(location_key = key_text(location_clean)) |>
  left_join(monthly, by = c("location_key", "map_date"), relationship = "many-to-one") |>
  mutate(comparison = case_when(
    is.na(monthly_listing_months) ~ "prior audit key not present in monthly input",
    is.na(monthly_military) ~ "monthly listing estimate is indeterminate",
    monthly_military == original_military & military_changed ~ "monthly input reproduces pre-adjudication listing",
    monthly_military == scenario_military ~ "monthly input matches corrected audit strength",
    TRUE ~ "different value; compare source symbols and geographic assignment"))
write_result(comparison, "external_quarterly_deployment_audit")
print(count(comparison, comparison))
