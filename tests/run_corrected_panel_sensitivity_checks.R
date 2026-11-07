# Independently verify source-to-panel propagation and saved model summaries.
# Explicit expected lag changes are derived from the adjudicated map schedule,
# not copied from the construction script's generated difference columns.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(glmmTMB)
root <- "outputs/corrected_panel_sensitivity"
original <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
original_all <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds")
rebuilt <- readRDS(file.path(root, "original_reconstructed/quarterly_panel_all_localities.rds"))
stopifnot(isTRUE(all.equal(original_all, rebuilt, tolerance = 1e-10)),
  nrow(original_all) == 608L, nrow(original) == 288L)
sources <- read.csv("data/mavivi_subtotal_sources.csv")
inputs <- read.csv("data/corrected_panel_inputs.csv")
for (manifest in list(sources, inputs)) {
  for (i in seq_len(nrow(manifest))) {
    raw <- readBin(manifest$path[i], "raw", file.info(manifest$path[i])$size)
    stopifnot(length(raw) == manifest$bytes[i],
      digest::digest(raw, algo = "sha256", serialize = FALSE) == manifest$sha256[i])
  }
}
decision <- read.csv("data/mavivi_subtotal_adjudication.csv")
transition <- read.csv("data/mavivi_subtotal_transition_audit.csv")
stopifnot(nrow(decision) == 1L, nrow(transition) == 10L,
  decision$adjudicated_south_africa_subtotal == 950,
  decision$adjudicated_sized_total == 2200,
  decision$alternative_total_for_sensitivity == 2350,
  !decision$provider_confirmed_correction, !decision$actual_headcount_verified,
  !decision$original_source_modified,
  sum(transition$subtotal_minus_total != 0) == 1L,
  all(transition$south_africa_coded[transition$revision != 51] == 950))

exposure_fields <- c("known_months", "strength", "source_maps", "strength_lag",
  "strength_lag2", "exposure_sources", "strength_between", "strength_within",
  "strength_lag_rebuilt")
stable_fields <- setdiff(names(original), exposure_fields)
quarter_id <- function(year, quarter) year * 4L + quarter - 1L
for (scenario in c("supported_corrections", "mavivi_plus_150")) {
  panel <- readRDS(file.path(root, scenario, "quarterly_panel_complete_exposure.rds"))
  all_panel <- readRDS(file.path(root, scenario, "quarterly_panel_all_localities.rds"))
  stopifnot(nrow(panel) == 288L, nrow(all_panel) == 608L,
    identical(panel[stable_fields], original[stable_fields]),
    identical(all_panel[stable_fields], original_all[stable_fields]),
    !anyDuplicated(panel[c("locality_id", "source_quarter")]),
    sum(panel$recorded_events) == 1248L)
  expected <- rep(0, nrow(original))
  rutshuru <- original$locality_id == "COD009015"
  period <- original$source_quarter
  expected[rutshuru & period == quarter_id(2020, 2)] <- .1
  expected[rutshuru & period >= quarter_id(2020, 3) & period <= quarter_id(2023, 1)] <- .15
  expected[rutshuru & period == quarter_id(2023, 2)] <- 1.45 / 3
  expected[rutshuru & period %in% quarter_id(2023, 3:4)] <- .65
  expected[original$locality_id == "COMPOSITE_KABARE" & period %in% quarter_id(2023, 2:3)] <- -.1
  if (scenario == "mavivi_plus_150")
    expected[original$locality_id == "COMPOSITE_BENI" & period == quarter_id(2023, 4)] <- .1
  expected_between <- ave(expected, original$locality_id, FUN = mean)
  expected_lag2 <- ave(expected, original$locality_id, FUN = function(x) c(0, head(x, -1)))
  stopifnot(max(abs((panel$strength_lag - original$strength_lag) - expected)) < 1e-10,
    max(abs((panel$strength_between - original$strength_between) - expected_between)) < 1e-10,
    max(abs((panel$strength_within - original$strength_within) - (expected - expected_between))) < 1e-10,
    max(abs((panel$strength_lag2 - original$strength_lag2) - expected_lag2)) < 1e-10)
  lineage <- read.csv(file.path(root, scenario, "monthly_source_lineage.csv"))
  nyamilima <- filter(lineage, locality_changed)
  stopifnot(nrow(nyamilima) == 47L, n_distinct(nyamilima$map_source_row) == 17L,
    all(nyamilima$location_clean == "Nyamilima"),
    all(nyamilima$corrected_locality_id == "COD009015"),
    all(lineage$military_strength[lineage$revision == 52 & lineage$location_clean == "Nyamilima"] == 650),
    !anyDuplicated(lineage$source_row), all(lineage$map_date <= lineage$period))
  changed_military <- filter(lineage, military_changed)
  stopifnot(all(changed_military$revision %in% 49:51))
  mavivi <- filter(changed_military, location_clean == "Mavivi")
  if (scenario == "supported_corrections") stopifnot(nrow(mavivi) == 0L) else
    stopifnot(nrow(mavivi) == 3L, all(mavivi$revision == 51),
      identical(sort(mavivi$period), c("2023-08-01", "2023-09-01", "2023-10-01")),
      all(mavivi$military_strength == 2350))
}

# Recompute the reported coefficient and interval from saved fits, retaining the
# distinction between computational usability and scientific identification.
diagnostics <- read.csv("data/corrected_panel_model_diagnostics.csv")
influence <- read.csv("data/corrected_panel_locality_influence.csv")
comparison <- read.csv("data/corrected_panel_model_comparison.csv")
stopifnot(nrow(diagnostics) == 4L, nrow(influence) == 9L, nrow(comparison) == 3L,
  all(diagnostics$usable), all(influence$usable),
  all(diagnostics$design_rank == diagnostics$design_columns),
  all(influence$rows == 256L), all(influence$localities == 8L))
for (i in seq_len(nrow(comparison))) {
  row <- comparison[i, ]
  fit <- readRDS(file.path(root, "models", paste0(row$scenario, "_history_model.rds")))
  value <- summary(fit)$coefficients$cond["strength_within", ]
  stopifnot(abs(row$estimate - value["Estimate"]) < 1e-10,
    abs(row$standard_error - value["Std. Error"]) < 1e-10,
    abs(row$lower_95 - (row$estimate - qnorm(.975) * row$standard_error)) < 1e-10,
    abs(row$upper_95 - (row$estimate + qnorm(.975) * row$standard_error)) < 1e-10,
    row$interval_contains_zero == (row$lower_95 <= 0 & row$upper_95 >= 0))
}
stopifnot(all(comparison$interval_contains_zero), all(influence$interval_contains_zero))
source("scripts/record_analysis_snapshot.R")
cat("Corrected-panel source propagation, independent lag deltas and thirteen saved fits checked.\n")
