# Independent reconciliation of saved audit outputs, not model validation.
directory <- "outputs/week_1/audit_aggregated/"
ledger <- read.csv(paste0(directory,"event_ledger.csv"), stringsAsFactors=FALSE)
panel <- read.csv(paste0(directory,"feasibility_coverage_panel.csv"), stringsAsFactors=FALSE)
retained <- subset(ledger, reason == "retained_primary_audit")
stopifnot(nrow(ledger)==5511L, nrow(retained)==2189L,
          !anyDuplicated(ledger$id), !anyDuplicated(panel[c("locality_id","period")]),
          nrow(panel)==19L*108L, sum(panel$recorded_events)==nrow(retained),
          all(retained$where_prec==1L), all(retained$match_count==1L),
          all(substr(retained$start_date,1,7)==substr(retained$end_date,1,7)),
          sum(panel$deployment_status=="Not listed; absence unverified")==823L)
joins <- read.csv(paste0(directory,"join_audit.csv"))
stopifnot(all(joins$input_rows==joins$output_rows))
unmatched <- read.csv(paste0(directory,"monthly_rows_without_matching_map.csv"))
stopifnot(nrow(unmatched)==0L)
flow <- read.csv(paste0(directory,"event_flow.csv"))
stopifnot(sum(flow$records)==nrow(ledger))

# Independently reconstruct locality/month counts from retained source IDs.
retained$period <- paste0(substr(retained$start_date,1,7),"-01")
counts <- aggregate(id ~ locality_id + period, retained, length)
comparison <- merge(counts, panel, by=c("locality_id","period"), all.x=TRUE)
stopifnot(nrow(comparison)==nrow(counts), all(comparison$id==comparison$recorded_events))
cat("Week 1 source-accounting, keys, date rules, missingness and count reconciliation passed.\n")
