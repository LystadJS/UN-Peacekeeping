# Synthetic checks only: these are NOT 2027 outcomes or performance estimates.
.libPaths(c(".local_library", .libPaths()))
library(readr)
source("R/prospective_scoring.R")
f <- read_csv("portfolio/prospective_2027_q1/frozen_forecasts.csv",show_col_types=FALSE)
b <- read_csv("portfolio/prospective_2027_q1/frozen_benchmark_distribution.csv",show_col_types=FALSE)
x <- data.frame(locality_id=f$locality_id,target_quarter="2027 Q1",
                recorded_events=rep(0,19),coverage_complete=TRUE)
expect_error <- function(expr) {
  caught <- tryCatch({force(expr); FALSE},error=function(e)TRUE)
  stopifnot(caught)
}
zero <- score_frozen_counts(x,f,b)
stopifnot(zero$summary$surges==0,
 abs(zero$summary$nb_brier-mean(f$nb_surge_probability^2))<1e-12)
at <- x; at$recorded_events <- f$surge_threshold
stopifnot(score_frozen_counts(at,f,b)$summary$surges==19)
below <- at; below$recorded_events <- below$recorded_events-1
stopifnot(score_frozen_counts(below,f,b)$summary$surges==0)
reversed <- score_frozen_counts(x[19:1,],f,b)
stopifnot(all.equal(zero$summary,reversed$summary))
bad <- x; bad$recorded_events[1] <- NA; expect_error(validate_future_outcomes(bad,f))
bad <- x; bad$recorded_events[1] <- -.5; expect_error(validate_future_outcomes(bad,f))
bad <- x; bad$recorded_events[1] <- .5; expect_error(validate_future_outcomes(bad,f))
bad <- x; bad$coverage_complete[1] <- FALSE; expect_error(validate_future_outcomes(bad,f))
bad <- x; bad$locality_id[1] <- bad$locality_id[2]; expect_error(validate_future_outcomes(bad,f))
expect_error(validate_future_outcomes(x[-1,],f))
bad <- x; bad$target_quarter[1] <- "2026 Q4"; expect_error(validate_future_outcomes(bad,f))
meta <- data.frame(stage="preliminary",release_id="SYNTHETIC",
 release_date="2027-04-20",coverage_start="2027-01-01",coverage_end="2027-03-31",
 source_url="https://example.org/SYNTHETIC",eligibility_audit_path="SYNTHETIC",
 release_selection_note="SYNTHETIC TEST ONLY")
expect_error(validate_release_metadata(meta,today=as.Date("2026-11-16")))
validate_release_metadata(meta,today=as.Date("2027-04-21"))
bad <- meta; bad$coverage_end <- "2027-02-28"
expect_error(validate_release_metadata(bad,today=as.Date("2027-04-21")))
# A severe synthetic episode must remain scoreable, beyond empirical support.
severe <- x; severe$recorded_events[1] <- 500
s <- score_frozen_counts(severe,f,b)
stopifnot(is.finite(s$summary$nb_crps),is.finite(s$summary$benchmark_crps))
cat("Synthetic scoring and rejection checks passed; no real outcome scores written.
")
