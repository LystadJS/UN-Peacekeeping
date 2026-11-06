.libPaths(c(".local_library",.libPaths()))
library(dplyr)
source("R/quarterly_simulation.R")
design <- readRDS("outputs/quarterly_pilot/exposure_design.rds")
audit <- read.csv("outputs/quarterly_pilot/exposure_audit.csv")
stopifnot(nrow(audit)==608,nrow(design)==288,n_distinct(design$locality_id)==9,
          all(is.finite(design$strength_lag)),all(design$strength_lag>=0),
          !anyDuplicated(audit[c("locality_id","year","quarter")]))
for(locality in unique(design$locality_id)) {
  local <- design[design$locality_id==locality,]
  stopifnot(abs(mean(local$strength_within))<1e-10,
            all(abs(local$strength_lag[-1]-head(local$strength,-1))<1e-10))
}
first <- simulate_quarterly(design,77,"favorable")
second <- simulate_quarterly(design,77,"favorable")
stopifnot(identical(first,second),all(first$data$recorded_events<=first$data$true_events),
          all(first$data$q==.65),first$beta==-.3)
null <- simulate_quarterly(design,77,"null")
stopifnot(null$beta==0)
cat("Quarterly keys, centering, lag alignment, seed reproducibility and thinning checks passed.\n")
