# Check provenance and availability boundaries independently of the audit scripts.
# These checks do not turn a retrospective release into an as-of dataset.
.libPaths(c(".local_library", .libPaths()))
verify_manifest <- function(path, expected_rows) {
  manifest <- read.csv(path)
  stopifnot(nrow(manifest) == expected_rows, !anyDuplicated(manifest$path))
  for (i in seq_len(nrow(manifest))) {
    raw <- readBin(manifest$path[i], "raw", file.info(manifest$path[i])$size)
    stopifnot(length(raw) == manifest$bytes[i],
      digest::digest(raw, algo = "sha256", serialize = FALSE) == manifest$sha256[i])
  }
}
verify_manifest("data/deployment_release_catalog_sources.csv", 2L)
verify_manifest("data/deployment_release_evidence.csv", 9L)
verify_manifest("data/september_reporting_gap_sources.csv", 5L)
verify_manifest("data/september_reporting_gap_inputs.csv", 1L)

release <- read.csv("data/deployment_release_advertisement.csv")
stopifnot(identical(as.character(release$advertised_version), c("2.1", "2.1", "2.2")),
  !any(release$exact_first_release_established),
  !any(release$current_2_2_bytes_authenticated_before_cutoff))
coverage <- read.csv("data/deployment_release_2_2_coverage.csv")
stopifnot(max(coverage$year) == 2022L, !any(coverage$admitted_as_of_2023_10_01),
  coverage$source_rows[coverage$year == 2021L] == 155L,
  coverage$source_rows[coverage$year == 2022L] == 178L)
catalog <- read.csv("data/deployment_release_catalog_audit.csv")
stopifnot(catalog$catalog_record_created == "2022-09-28",
  !catalog$exact_public_release_verified, !catalog$contemporaneous_pdf_bytes_authenticated)

# Recompute the source dependence from private records; never sum proxy records
# into a certified historical count or confuse a source date with a release date.
events <- read.csv("outputs/september_reporting_gaps/candidate_provenance_ledger.csv")
stopifnot(nrow(events) == 23L, !anyDuplicated(events$id),
  sum(events$source_office == "Kivu Security Tracker") == 21L,
  sum(events$source_office == "Kivu Security Tracker" & events$has_pre_origin_material) == 5L,
  sum(events$current_core & events$source_office == "Kivu Security Tracker") == 12L,
  sum(events$current_core & events$source_office == "Kivu Security Tracker" & events$has_pre_origin_material) == 4L,
  all(is.na(events$certified_available_coded_record)))
summary <- read.csv("data/september_reporting_gap_summary.csv")
stopifnot(all(is.na(summary$certified_historical_count)),
  sum(summary$events[summary$population == "all_19"]) == 23L)

# A complete grid is not a complete measured history. Unknown strengths stay NA.
monthly <- read.csv("outputs/deployment_2021_2023/monthly_history_gaps.csv")
locality_maps <- read.csv("outputs/deployment_2021_2023/locality_map_history.csv")
stopifnot(nrow(monthly) == 627L, nrow(locality_maps) == 228L,
  !anyDuplicated(monthly[c("locality_id", "period")]),
  !anyDuplicated(locality_maps[c("locality_id", "revision")]),
  max(monthly$period) == "2023-09-01",
  all(is.na(monthly$complete_historical_coded_strength)),
  all(is.na(locality_maps$complete_historical_coded_strength)))
census <- read.csv("outputs/deployment_2021_2023/all_site_reconciliation.csv")
stopifnot(!anyDuplicated(census[c("revision", "location")]),
  all(is.na(census$historically_available_complete_strength)),
  all(census$revision %in% c(40:44, 45.1, 46:51)))
numeric <- !is.na(census$sized_military)
stopifnot(all(census$sized_military[numeric] ==
  650 * census$military_battalions[numeric] +
  150 * census$military_companies[numeric] + 35 * census$military_platoons[numeric]))
stopifnot(nrow(census) == 431L, sum(numeric) == 279L,
  sum(census$difference != 0, na.rm = TRUE) == 10L)
retrospective <- read.csv("outputs/deployment_2021_2023/retrospective_monthly_strength.csv")
stopifnot(nrow(retrospective) == 1254L,
  !anyDuplicated(retrospective[c("release", "locality_id", "period")]),
  !any(retrospective$certified_available_at_origin),
  all(retrospective$source_map_date <= retrospective$period),
  sum(!is.na(retrospective$retrospective_strength[retrospective$release == 2.2])) == 336L,
  sum(!is.na(retrospective$retrospective_strength[retrospective$release == 2.3])) == 462L,
  all(is.na(retrospective$retrospective_strength[
    retrospective$release == 2.2 & retrospective$period > "2022-12-01"])),
  all(is.na(retrospective$retrospective_strength[retrospective$status == "unlisted_unknown"])))
comparison <- read.csv("outputs/deployment_2021_2023/retrospective_release_comparison.csv")
stopifnot(nrow(comparison) == 627L, sum(!is.na(comparison$difference)) == 336L,
  all(comparison$difference[!is.na(comparison$difference)] == 0))
cat("Deployment-history completion checks passed; unavailable historical strengths and September counts remain missing.\n")
