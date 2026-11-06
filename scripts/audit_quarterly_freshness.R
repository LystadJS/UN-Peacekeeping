# Sensitivity of observation availability to deployment-map age.
# This describes design support; it never treats unlisted months as zero.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
dir.create("outputs/quarterly_pilot", recursive = TRUE, showWarnings = FALSE)
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv",
                    stringsAsFactors = FALSE)
original <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
stopifnot(all(lineage$source_row >= 1L), all(lineage$source_row <= nrow(original)))
lineage$strength <- suppressWarnings(as.numeric(lineage$no.troops)) -
  suppressWarnings(as.numeric(original$fpu.no[lineage$source_row]))
lineage <- lineage |> filter(!is.na(locality_id), nzchar(locality_id)) |>
  mutate(period = as.Date(period))
monthly <- lineage |> group_by(locality_id, period) |>
  summarise(strength = if (any(is.na(strength))) NA_real_ else sum(strength),
            max_age = max(map_age), .groups = "drop")
stopifnot(all(monthly$strength >= 0, na.rm = TRUE), all(monthly$max_age >= 0))
localities <- read.csv("outputs/week_1/audit_aggregated/locality_inventory.csv")
grid <- crossing(locality_id = localities$locality_id,
                 period = seq(as.Date("2015-10-01"), as.Date("2023-12-01"), by = "month")) |>
  left_join(monthly, by = c("locality_id", "period"), relationship = "one-to-one") |>
  mutate(year = as.integer(format(period, "%Y")),
         quarter = (as.integer(format(period, "%m")) - 1L) %/% 3L + 1L)
results <- lapply(c(0L, 1L, 2L, 3L, 5L), function(age_limit) {
  quarters <- grid |> mutate(usable = !is.na(strength) & !is.na(max_age) & max_age <= age_limit) |>
    group_by(locality_id, year, quarter) |>
    summarise(exposure_available = n() == 3L && all(usable), .groups = "drop") |>
    arrange(locality_id, year, quarter) |> group_by(locality_id) |>
    mutate(lag_available = lag(exposure_available)) |> filter(year >= 2016) |>
    summarise(eligible_quarters = sum(lag_available), .groups = "drop")
  data.frame(maximum_map_age_months = age_limit, candidate_localities = nrow(quarters),
    candidate_locality_quarters = nrow(quarters) * 32L,
    eligible_locality_quarters = sum(quarters$eligible_quarters),
    complete_history_localities = sum(quarters$eligible_quarters == 32L))
})
summary <- bind_rows(results)
write.csv(summary, "data/quarterly_freshness_sensitivity.csv", row.names = FALSE)
print(summary)
