# Record audit outcomes without converting unresolved measurement into a pass.
source("tests/run_week_1_checks.R") # Prevent stale pinned results from being published.
checks <- read.csv("data/audit_checks.csv", stringsAsFactors = FALSE)
directory <- "outputs/week_1/audit_aggregated/"
checks$status <- c("qualified", "passed", "passed", "passed", "qualified", "qualified",
 "qualified", "qualified", "unresolved", "passed", "qualified", "passed",
 "passed", "qualified", "passed_feasibility_only", "insufficient_for_random_slopes",
 "passed_feasibility_only", "passed_with_scope_limit", "revise_design")
checks$records_checked <- c(20,417968,5511,5511,5511,4,5511,2052,2052,3917,2917,
                           5511,2189,1342,2052,19,2189,5511,19)
checks$records_affected <- c(NA,0,0,0,NA,1,1,NA,823,0,728,0,0,65,0,NA,0,0,NA)
checks$evidence_path <- c("data/source_manifest.csv", paste0(directory, c(
 "source_checks.csv","source_checks.csv","source_checks.csv","event_name_crosswalk.csv",
 "boundary_footprint_stability.csv","event_ledger.csv","feasibility_coverage_panel.csv",
 "feasibility_coverage_panel.csv","monthly_rows_without_matching_map.csv","event_flow.csv",
 "join_audit.csv","feasibility_coverage_panel.csv","deployment_measurement_flags.csv",
 "feasibility_coverage_panel.csv","locality_variation.csv","event_ledger.csv","event_flow.csv")),
 "docs/feasibility_decision.md")
checks$resolution <- c(
 "20 artifacts hashed; Geo-PKO redistribution license not explicit; raw data remain local",
 "Zero duplicate IDs in global GED file",
 "Zero invalid or reversed dates in DRC 2014-2023 subset",
 "Zero impossible coordinate ranges; geographic accuracy assessed separately",
 "Coordinate-based assignment retained; historical name crosswalk exported; three Vido I records disagree with target geography",
 "Composite footprints agree from July 2015; early Djugu geometry invalid and not repaired",
 "One Djugu/Irumu boundary event excluded; no arbitrary assignment; 275 outside-target or unmatched cases remain explicit",
 "Zero means no retained recorded event; completeness of underlying reporting is not established",
 "823 composite-months unlisted; no absence inferred; source map review needed",
 "All 3917 MONUSCO monthly rows match original map attributes including June 2013 carry-forward",
 "719 imprecise and 9 cross-month events excluded from 2917 uniquely assigned one-sided events",
 "List-based matching preserves input rows; no join expansion",
 "2189 retained event IDs reconcile to complete 2052-row feasibility grid",
 "No duplicate location-map keys; 64 geosplit rows preserve source allocations; one unknown-strength row outside target; no unit IDs for independent unit-level audit",
 "No duplicate composite-month keys; not a frozen analysis panel",
 "Only seven conditional binary switchers with one to three changes; zeros remain unverified",
 "Retained IDs and map source row/date references saved locally",
 "Ledger covers all 5511 in-scope DRC source rows; country/year prefilter reproducible from original archive",
 "Revise geography/timing/deployment contrast before empirical modeling; keep empirical_ready FALSE")
write.csv(checks, "data/audit_checks.csv", row.names = FALSE, na = "")

dictionary <- read.csv("data/data_dictionary.csv", stringsAsFactors = FALSE)
dictionary$source_mapping_status <- "not_constructed_for_model"
dictionary$source_fields <- ""
dictionary$definition[dictionary$variable=="source_map_date"] <- "Publication month of contributing deployment source map"
dictionary$transformation[dictionary$variable=="source_map_date"] <- "Use source_year/source_month from expanded product; preserve source identifier"
map_field <- function(variable, fields, status = "audited_feasibility") {
  index <- match(variable, dictionary$variable)
  dictionary$source_fields[index] <<- fields
  dictionary$source_mapping_status[index] <<- status
}
map_field("locality_id", "SALB adm2cd; config/city_aggregation.csv for composites")
map_field("province_id", "SALB adm1nm; analysis ID pending")
map_field("month", "UCDP date_start/date_end; Geo-PKO year/month")
map_field("recorded_events", "GED id; country_id=490; type_of_violence=3; where_prec=1; dates inside month")
map_field("civilian_fatalities", "GED deaths_civilians within retained one-sided events")
map_field("other_civilian_fatalities", "GED deaths_civilians where type_of_violence in 1/2", "defined_not_aggregated")
map_field("deployment_presence", "Positive (no.troops - fpu.no); unlisted remains unknown", "unresolved_absence")
map_field("deployment_strength", "Geo-PKO no.troops - fpu.no; numeric only; keep geosplit allocations", "listed_strength_only")
map_field("source_map_id", "Geo-PKO mission + source + source_year/source_month")
map_field("source_map_date", "Geo-PKO source_year/source_month are source publication month")
map_field("map_age_months", "12*(year-source_year) + month-source_month")
map_field("carried_forward", "map_age > 0")
map_field("event_coverage_complete", "Not identifiable as reporting completeness from GED", "unresolved")
map_field("deployment_coverage_complete", "Requires original mission-map completeness review", "unresolved")
map_field("boundary_version", "SALB 2018-05-30 validity vintage; fixed composite geometry")
write.csv(dictionary, "data/data_dictionary.csv", row.names = FALSE, na = "")

# Export a compact version inventory for the actual audit environment.
.libPaths(c(".local_library", .libPaths()))
packages <- c("dplyr","tidyr","readr","ggplot2","sf","pdftools","readxl","digest","jsonlite")
write.csv(data.frame(package=packages, version=vapply(packages,function(p) {
  if (!requireNamespace(p, quietly=TRUE)) stop("Audit dependency unavailable: ",p)
  as.character(getNamespaceVersion(p))
},character(1))),
          "data/audit_package_versions.csv", row.names=FALSE)
