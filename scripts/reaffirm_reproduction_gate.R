# Reaffirm the already authorized empirical protocol for a clean reproduction.
# This is deliberately separate from validation: passing simulations alone does
# not authorize a new design, estimator, sample, or measurement convention.
.libPaths(c(".local_library", .libPaths()))
if (!identical(Sys.getenv("REPRODUCE_APPROVED_PROTOCOL"), "quarterly_2016_2023_common_strength")) {
  stop("Set the explicit reproduction decision only after reviewing the existing protocol.")
}
status <- jsonlite::fromJSON("data/pilot_validation_status.json")
core <- read.csv("data/pilot_simulation_summary.csv")
required <- core[core$scenario %in% c("favorable", "null"), ]
stopifnot(nrow(required) == 2L, all(required$attempts == 200L),
          all(required$core_gate), isTRUE(status$history_extension_validated),
          identical(status$history_gate, "passed"))
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
stopifnot(nrow(panel) == 288L, length(unique(panel$locality_id)) == 9L,
          sum(panel$recorded_events) == 1248L, all(panel$core_sample))
protocol <- "docs/empirical_quarterly_protocol.md"
stopifnot(file.exists(protocol))
status$empirical_ready <- TRUE
status$reproduction_decision <- list(
  purpose = "Reproduce the existing user-authorized quarterly protocol, without changing its assumptions",
  protocol = protocol,
  protocol_sha256 = digest::digest(readBin(protocol, "raw", file.info(protocol)$size),
                                   algo = "sha256", serialize = FALSE),
  absence_certified = FALSE,
  independent_human_review_complete = FALSE)
jsonlite::write_json(status, "data/pilot_validation_status.json", pretty = TRUE,
                    auto_unbox = TRUE, null = "null")
message("Existing empirical protocol reaffirmed for this clean reproduction only.")
