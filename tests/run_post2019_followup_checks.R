# Independently check the saved follow-up artifacts without refitting models.
# Run after the three supplement audits and joint-history reconstruction.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)

# Verify source bytes rather than trusting dates or version labels alone.
verify_sources <- function(path, expected_rows) {
  sources <- read.csv(path)
  stopifnot(nrow(sources) == expected_rows, !anyDuplicated(sources$path))
  for (i in seq_len(nrow(sources))) {
    stopifnot(file.exists(sources$path[i]),
      file.info(sources$path[i])$size == sources$bytes[i])
    actual_hash <- digest::digest(readBin(sources$path[i], "raw", sources$bytes[i]),
      algo = "sha256", serialize = FALSE)
    stopifnot(actual_hash == sources$sha256[i])
  }
}
verify_sources("data/september_2023_evidence.csv", 7L)
verify_sources("data/september_2023_inputs.csv", 3L)
verify_sources("data/post2019_deployment_sources.csv", 1L)
verify_sources("data/post2019_map_coding_sources.csv", 10L)

# September categories overlap when a record lists both early and late material.
# They are timing proxies, never certified historical coded event counts.
september <- read.csv("data/september_2023_summary.csv")
expected <- data.frame(
  version = c("candidate_23_0_9", "candidate_23_0_9", "current_ged_26_1", "current_ged_26_1"),
  population = rep(c("all_19", "current_core_9"), 2),
  total = c(23L, 13L, 34L, 21L), early = c(7L, 5L, 9L, 7L),
  late = c(16L, 8L, 27L, 16L), only_late = c(16L, 8L, 25L, 14L))
september <- left_join(expected, september,
  by = c("version", "population"), relationship = "one-to-one")
stopifnot(nrow(september) == 4L,
  all(september$retained_september_events == september$total),
  all(september$events_with_pre_origin_listed_material == september$early),
  all(september$events_with_post_origin_material == september$late),
  all(september$events_all_dated_material_post_origin == september$only_late),
  all(september$early + september$late - september$total == c(0L, 0L, 2L, 2L)),
  all(is.na(september$certified_complete_september_count)))

# Check the historical numeric prefix against both older and current coding.
training <- read.csv("outputs/post2019_deployment/historical_training_strength.csv")
older <- read.csv("outputs/forecast_origin/coding/historical_training_strength.csv") |>
  select(locality_id, source_quarter, older_strength = archived_strength_lag)
comparison <- left_join(training, older,
  by = c("locality_id", "source_quarter"), relationship = "one-to-one")
shared <- !is.na(comparison$older_strength) & !is.na(comparison$archived_strength_lag)
changed <- !is.na(training$archived_strength_lag) & !is.na(training$strength_lag) &
  abs(training$archived_strength_lag - training$strength_lag) > 1e-10
stopifnot(nrow(training) == 589L,
  !anyDuplicated(training[c("locality_id", "source_quarter")]),
  sum(!is.na(training$archived_strength_lag)) == 208L,
  sum(shared) == 164L,
  all(abs(comparison$older_strength[shared] - comparison$archived_strength_lag[shared]) < 1e-10),
  sum(is.na(comparison$older_strength) & !is.na(comparison$archived_strength_lag)) == 44L,
  sum(changed) == 2L,
  all(training$source_quarter[changed] == 2021L * 4L),
  setequal(training$locality[changed], c("Masisi", "Irumu including Bunia")),
  all(is.na(training$archived_strength_lag[training$source_quarter > 2021L * 4L])))
monthly <- read.csv("outputs/post2019_deployment/historical_monthly_strength.csv")
stopifnot(all(is.na(monthly$archived_strength[monthly$period > "2020-12-01"])),
  all(is.na(monthly$archived_strength[monthly$availability == "unlisted_unknown"])))

# Jointly populated rows remain a conditional prefix, not a full forecasting set.
joint <- read.csv("outputs/post2019_deployment/joint_training_history.csv")
coverage <- read.csv("data/post2019_deployment_joint_coverage.csv")
training_coverage <- read.csv("data/post2019_deployment_training_coverage.csv")
stopifnot(nrow(joint) == 570L,
  !anyDuplicated(joint[c("locality_id", "source_quarter")]),
  sum(joint$jointly_populated) == 204L,
  sum(joint$jointly_populated & joint$current_core) == 189L,
  all(joint$jointly_populated == (joint$event_history_populated & joint$deployment_history_populated)),
  !any(coverage$full_30_quarter_centering_available),
  all(is.na(training_coverage$complete_as_of_centering_mean)))
joined_strength <- left_join(joint, training |>
    select(locality_id, source_quarter, expected_lag = archived_strength_lag,
      expected_lag2 = archived_strength_lag2),
  by = c("locality_id", "source_quarter"), relationship = "one-to-one")
stopifnot(isTRUE(all.equal(joined_strength$archived_strength_lag, joined_strength$expected_lag)),
  isTRUE(all.equal(joined_strength$archived_strength_lag2, joined_strength$expected_lag2)))

# Recompute symbol arithmetic, while preserving unresolved sites and unsized units.
maps <- read.csv("outputs/post2019_map_coding/site_map_comparison.csv")
unknown <- is.na(maps$sized_military)
stopifnot(nrow(maps) == 92L, !anyDuplicated(maps[c("revision", "location")]),
  sum(!unknown) == 90L, sum(unknown) == 2L,
  all(maps$location[unknown] == "Eringeti"),
  all(maps$coding_status[unknown] == "site_not_named"),
  sum(maps$unsized_military_present, na.rm = TRUE) == 14L,
  all(is.na(maps$complete_locality_strength)),
  isTRUE(all.equal(maps$sized_military,
    650 * maps$military_battalions + 150 * maps$military_companies + 35 * maps$military_platoons)),
  isTRUE(all.equal(maps$sized_fpu, 150 * maps$fpu_companies)))
map_summary <- read.csv("data/post2019_map_coding_audit.csv")
stopifnot(sum(map_summary$reviewed_site_rows) == 92L,
  sum(map_summary$numeric_sized_rows) == 90L,
  sum(map_summary$unresolved_site_rows) == 2L,
  sum(map_summary$rows_with_unsized_units) == 14L)
cat("Post-2019 follow-up checks passed: provenance, September uncertainty, deployment prefix, joint histories and map components.\n")
