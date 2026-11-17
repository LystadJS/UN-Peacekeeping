# Historical integration and synthetic boundary tests; no 2027 outcomes.
.libPaths(c(".local_library",.libPaths()))
library(readr)
source("R/prospective_outcomes.R")
boundaries <- load_frozen_boundaries()
events <- read_ged_outcomes("data/interim/ucdp/GEDEvent_v26_1.csv")
result <- construct_strict_outcomes(events,boundaries,"2023-10-01","2023-12-31")
expected <- read_csv("outputs/reporting_lag_pilot/scored_forecasts.csv",show_col_types=FALSE)
actual <- result$counts$recorded_events[match(expected$locality_id,result$counts$locality_id)]
stopifnot(identical(as.numeric(actual),expected$y),sum(actual)==38)
# Duplicate the location of an eligible historical event for controlled tests.
one <- result$ledger[result$ledger$reason=="eligible",][1,]
synthetic <- one[rep(1,6),names(events)]
synthetic$id <- 1:6
synthetic$date_start <- c("2027-01-01","2027-03-31","2027-01-31",
                          "2027-01-15","2027-01-15","2026-12-31")
synthetic$date_end <- c("2027-01-01","2027-03-31","2027-02-01",
                        "2027-01-15","2027-01-15","2027-01-01")
synthetic$where_prec <- c(1,1,1,2,1,1)
synthetic$type_of_violence <- c(3,3,3,3,1,3)
test <- construct_strict_outcomes(synthetic,boundaries,"2027-01-01","2027-03-31")
stopifnot(sum(test$counts$recorded_events)==2,
 identical(test$ledger$reason,c("eligible","eligible","cross_month_date_interval",
 "location_precision_not_exact","not_one_sided","outside_occurrence_window")))
duplicate <- rbind(synthetic,synthetic[1,])
failed <- tryCatch({construct_strict_outcomes(duplicate,boundaries,"2027-01-01","2027-03-31");FALSE},error=function(e)TRUE)
stopifnot(failed)
cat("All 19 historical locality counts reproduce (38 events); synthetic inclusion checks passed.
")
