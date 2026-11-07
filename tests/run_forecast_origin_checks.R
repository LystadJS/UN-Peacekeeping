# Cross-check the one-origin supplement without refitting or altering the pilot.
.libPaths(c(".local_library", .libPaths()))
comparison <- read.csv("data/forecast_origin_event_comparison.csv")
summary <- read.csv("data/forecast_origin_event_summary.csv")
stopifnot(nrow(comparison) == 57L,
  !anyDuplicated(comparison[c("window", "locality_id")]),
  all(is.na(comparison$certified_full_prior_quarter_events)))
for (i in seq_len(nrow(summary))) {
  rows <- comparison[comparison$window == summary$window[i], ]
  stopifnot(nrow(rows) == 19L, sum(rows$current_complete_sample) == 9L,
    sum(rows$archived_events) == summary$archived_events[i],
    sum(rows$current_events) == summary$current_events[i],
    sum(rows$archived_events[rows$current_complete_sample]) == summary$archived_core_events[i],
    sum(rows$current_events[rows$current_complete_sample]) == summary$current_core_events[i])
}
panel <- read.csv("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv")
panel <- panel[panel$year == 2023 & panel$quarter == 4, ]
quarter <- comparison[comparison$window == "q3_conditional", ]
stopifnot(identical(as.integer(quarter$current_events),
  as.integer(panel$events_lag[match(quarter$locality_id, panel$locality_id)])))

deployment <- read.csv("data/forecast_origin_deployment_comparison.csv")
months <- read.csv("data/forecast_origin_deployment_months.csv")
stopifnot(nrow(deployment) == 19L, !anyDuplicated(deployment$locality_id),
  all(is.na(deployment$as_of_certified_strength_lag)),
  all(is.na(deployment$as_of_certified_strength_lag2)), nrow(months) == 6L,
  all(as.Date(months$report_date) < as.Date("2023-10-01")),
  !any(months$exact_historical_geopko_coding_verified))
for (field in c("strength_lag", "strength_lag2")) {
  expected <- panel[[field]][match(deployment$locality_id, panel$locality_id)]
  stopifnot(isTRUE(all.equal(deployment[[paste0("rebuilt_", field)]], expected,
    tolerance = 1e-10, check.attributes = FALSE)))
}
evidence <- read.csv("data/forecast_origin_release_evidence.csv")
stopifnot(!any(evidence$exact_first_release_verified),
  !any(evidence$historical_byte_identity_verified))

# Validate all eight event-analysis inputs, plus the three original UN reports.
# Raw-byte hashing avoids unreliable Windows file.access permission probes.
inputs <- read.csv("data/forecast_origin_event_inputs.csv")
reports <- read.csv("data/forecast_origin_deployment_sources.csv")
inputs <- rbind(inputs[c("path", "bytes", "sha256")],
  data.frame(path = reports$local_path, bytes = reports$bytes, sha256 = reports$sha256))
stopifnot(nrow(inputs) == 11L)
for (i in seq_len(nrow(inputs))) {
  stopifnot(file.info(inputs$path[i])$size == inputs$bytes[i],
    digest::digest(readBin(inputs$path[i], "raw", n = inputs$bytes[i]),
      algo = "sha256", serialize = FALSE) == inputs$sha256[i])
}
source("scripts/record_analysis_snapshot.R")
cat("One-origin counts, missingness, map dates and 11 input hashes verified.\n")
