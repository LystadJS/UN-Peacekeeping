# Usage: Rscript scripts/score_prospective_2027_q1.R outcomes.csv release_metadata.csv
# Outcomes must first be reconstructed/audited using the frozen event rule.
.libPaths(c(".local_library", .libPaths()))
library(readr)
source("R/prospective_scoring.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Supply audited outcome CSV and release-metadata CSV")
archive <- "portfolio/prospective_2027_q1"
expected <- c(
 frozen_forecasts.csv="ff1ad6c0c76ff1dc5582c37c9c704c941dfa70c517a9e559246c61883f0a9baf",
 frozen_benchmark_distribution.csv="6ab405e4b5f916890d6cc974fe4c5cf8c89239921a5d23baf500825fd37eeb31",
 SPECIFICATION.md="9935cd64544b2a99f6be82dd3a314f23330f84f7670928d5cc21df3ecff7e17e")
for (name in names(expected)) {
  if (digest::digest(file=file.path(archive,name),algo="sha256") != expected[[name]])
    stop("Frozen archive changed: ",name)
}
outcomes <- read_csv(args[1], show_col_types=FALSE,
 col_types=cols(locality_id=col_character(),target_quarter=col_character(),
                recorded_events=col_double(),coverage_complete=col_logical()))
meta <- read_csv(args[2],show_col_types=FALSE,col_types=cols(.default=col_character()))
stopifnot(nrow(problems(outcomes))==0,nrow(problems(meta))==0)
validate_release_metadata(meta)
if (!file.exists(meta$eligibility_audit_path)) stop("Referenced eligibility audit is missing")
forecasts <- read_csv(file.path(archive,"frozen_forecasts.csv"),show_col_types=FALSE)
benchmark <- read_csv(file.path(archive,"frozen_benchmark_distribution.csv"),show_col_types=FALSE)
results <- score_frozen_counts(outcomes,forecasts,benchmark)
destination <- file.path("outputs/prospective_2027_q1_scores",meta$stage)
if (dir.exists(destination)) stop("Stage already scored. Preserve it; document corrections separately.")
# All validation happens before creating a score directory.
dir.create(destination,recursive=TRUE)
write_csv(results$rows,file.path(destination,"locality_scores.csv"))
write_csv(results$summary,file.path(destination,"summary.csv"))
write_csv(meta,file.path(destination,"release_metadata.csv"))
inputs <- c(args,meta$eligibility_audit_path)
write_csv(data.frame(path=inputs,sha256=vapply(inputs,function(p)
 digest::digest(file=p,algo="sha256"),character(1))),file.path(destination,"outcome_provenance.csv"))
print(results$summary)
