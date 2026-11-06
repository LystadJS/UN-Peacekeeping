# Independently reconstruct the reported metrics from all retained fit attempts.
# This is intentionally separate from the runner's in-memory summary.
fit_records <- read.csv("outputs/dynamic_quarterly/fit_records.csv")
reported <- read.csv("outputs/dynamic_quarterly/simulation_summary.csv")
stopifnot(nrow(fit_records) == 1200L)
for (index in seq_len(nrow(reported))) {
  row <- reported[index, ]
  attempts <- subset(fit_records, scenario == row$scenario & estimator == row$estimator)
  usable <- attempts[attempts$usable, ]
  errors <- usable$estimate - usable$truth
  coverage <- abs(errors) <= 1.96 * usable$se
  wrong_direction <- ifelse(usable$truth == 0,
    abs(usable$estimate) > 1.96 * usable$se,
    usable$estimate * sign(usable$truth) + 1.96 * usable$se < 0)
  stopifnot(nrow(attempts) == row$attempts, nrow(usable) == row$n_usable,
    abs(mean(errors) - row$bias) < 1e-10,
    abs(sqrt(mean(errors^2)) - row$rmse) < 1e-10,
    abs(mean(coverage) - row$coverage) < 1e-10,
    abs(mean(wrong_direction) - row$directional_error) < 1e-10,
    abs(sum(coverage)/nrow(attempts) - row$success_and_coverage) < 1e-10)
}
dir.create("data", showWarnings = FALSE)
write.csv(reported, "data/dynamic_quarterly_simulation_summary.csv", row.names = FALSE)
checks <- read.csv("outputs/dynamic_quarterly/generated_data_checks.csv")
# Retain only scenario-level extrema in the repository; full generated panels
# and per-fit records remain local, reproducible from the documented seeds.
numeric_columns <- names(checks)[vapply(checks, is.numeric, logical(1))]
numeric_columns <- setdiff(numeric_columns, c("seed", "replication"))
audit <- aggregate(checks[numeric_columns], list(scenario=checks$scenario), max)
audit$min_recording <- vapply(audit$scenario, function(scenario_name)
  min(checks$min_recording[checks$scenario == scenario_name]), numeric(1))
audit$all_finite_counts <- vapply(audit$scenario, function(scenario_name)
  all(checks$finite_counts[checks$scenario == scenario_name]), logical(1))
audit$all_valid_thinning <- vapply(audit$scenario, function(scenario_name)
  all(checks$valid_thinning[checks$scenario == scenario_name]), logical(1))
write.csv(audit, "data/dynamic_quarterly_generated_audit.csv", row.names = FALSE)
metadata <- c(
  "Recorded 2026-11-06; dynamic quarterly simulation revision 1.",
  "200 replicates each; scenarios favorable, null, selection, differential_recording, stationary_initial.",
  "Seed = 20261107 + 10000 * scenario_index + replication; one-based indices.",
  "1000 generated panels; 1200 fits including diagnostic initial-adjusted model.",
  "stationary_initial is a finite 40-quarter correlated-prehistory stress, not proven stationarity.",
  "Initial-adjusted model is diagnostic only: matched null validation was not run.",
  "All thresholds in docs/dynamic_quarterly_protocol.md remained unchanged."
)
writeLines(c(metadata, "", readLines("outputs/dynamic_quarterly/session_info.txt")),
  "data/dynamic_quarterly_run_metadata.txt")
message("Independent bias, RMSE, coverage, directional-error and denominator checks passed.")

# The extension is a separate experiment. Verify and export without combining
# its seeds or denominators with the original five scenarios.
null_directory <- "outputs/dynamic_quarterly_null_disjoint"
null_records <- read.csv(file.path(null_directory,"fit_records.csv"))
null_summary <- read.csv(file.path(null_directory,"simulation_summary.csv"))
null_valid <- null_records[null_records$usable, ]
null_covered <- abs(null_valid$estimate)<=1.96*null_valid$se
stopifnot(nrow(null_records)==200L, all(null_records$truth==0),
  all(null_records$seed==20361107L+null_records$replication),
  !any(null_records$seed %in% fit_records$seed),
  abs(mean(null_valid$estimate)-null_summary$bias)<1e-10,
  abs(mean(null_covered)-null_summary$coverage)<1e-10,
  abs(mean(!null_covered)-null_summary$directional_error)<1e-10,
  abs(sum(null_covered)/nrow(null_records)-null_summary$success_and_coverage)<1e-10)
write.csv(null_summary,"data/dynamic_quarterly_null_summary.csv",row.names=FALSE)
writeLines(c("Separate correlated-prehistory null extension; 200 replicates.",
  "Seed = 20361107 + replication. Ordinary history estimator only.",
  "Protocol: docs/dynamic_quarterly_null_extension.md; recorded before extension run.",
  "",readLines(file.path(null_directory,"session_info.txt"))),
  "data/dynamic_quarterly_null_metadata.txt")
message("Independent correlated-prehistory null checks passed.")
