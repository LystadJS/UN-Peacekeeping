# Usage: Rscript scripts/build_prospective_outcomes.R release.csv release_metadata.csv
# Requires reviewed publisher-coverage evidence. Does not download or infer it.
.libPaths(c(".local_library",.libPaths()))
library(readr)
source("R/prospective_scoring.R")
source("R/prospective_outcomes.R")
args <- commandArgs(trailingOnly=TRUE)
if(length(args)!=2) stop("Supply raw GED CSV and reviewed release metadata CSV")
meta <- read_csv(args[2],show_col_types=FALSE,col_types=cols(.default=col_character()))
validate_release_metadata(meta)
out <- file.path("outputs/prospective_2027_q1_outcomes",meta$stage)
if(gsub("\\\\","/",meta$eligibility_audit_path) != file.path(out,"event_ledger.csv"))
  stop("Audit path must be the stage output event_ledger.csv")
if(dir.exists(out)) stop("Stage already built; preserve it and document any correction separately")
if(file.exists(meta$eligibility_audit_path)) stop("Refusing to overwrite an existing event audit")
events <- read_ged_outcomes(args[1])
result <- construct_strict_outcomes(events,load_frozen_boundaries(),"2027-01-01","2027-03-31")
counts <- result$counts |>
 dplyr::mutate(target_quarter="2027 Q1",coverage_complete=TRUE)
forecasts <- read_csv("portfolio/prospective_2027_q1/frozen_forecasts.csv",show_col_types=FALSE)
validate_future_outcomes(counts,forecasts)
dir.create(out,recursive=TRUE)
dir.create(dirname(meta$eligibility_audit_path),recursive=TRUE,showWarnings=FALSE)
write_csv(result$ledger,meta$eligibility_audit_path)
write_csv(counts,file.path(out,"outcomes.csv"))
write_csv(meta,file.path(out,"release_metadata.csv"))
write_csv(data.frame(raw_path=args[1],raw_sha256=digest::digest(file=args[1],algo="sha256"),
 metadata_path=args[2],metadata_sha256=digest::digest(file=args[2],algo="sha256"),
 eligible_events=sum(counts$recorded_events)),
 file.path(out,"construction_provenance.csv"))
cat("Outcome panel built; inspect event ledger and source evidence before scoring.
")

