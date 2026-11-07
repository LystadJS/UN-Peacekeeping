# Reconstruct map provenance at the fixed 2023-10-01 forecast origin.
# Numeric strengths are modern Geo-PKO comparators, not certified vintage values.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
forecast_origin <- as.Date("2023-10-01")
sources <- read.csv("data/forecast_origin_deployment_sources.csv")
stopifnot(nrow(sources) == 3L, !anyDuplicated(sources$source))
for (i in seq_len(nrow(sources))) {
  path <- sources$local_path[i]
  stopifnot(file.exists(path), file.info(path)$size == sources$bytes[i],
    digest::digest(readBin(path, "raw", n = file.info(path)$size),
      algo = "sha256", serialize = FALSE) == sources$sha256[i])
}
sources <- sources |> mutate(reference_month = as.Date(reference_month),
  report_date = as.Date(report_date), english_processing_date = as.Date(english_processing_date),
  dated_report_before_origin = report_date < forecast_origin &
    english_processing_date < forecast_origin)
stopifnot(all(sources$dated_report_before_origin))

lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv") |>
  mutate(period = as.Date(period), map_date = as.Date(map_date)) |>
  filter(period >= as.Date("2023-04-01"), period < forecast_origin) |>
  left_join(select(sources, source, reference_month, report, report_date,
    dated_report_before_origin), by = "source", relationship = "many-to-one")
stopifnot(!anyNA(lineage$report), all(lineage$map_date == lineage$reference_month),
  !anyDuplicated(lineage$source_row))
monthly_sources <- lineage |> group_by(period, source, map_date, map_age,
    report, report_date, dated_report_before_origin) |>
  summarise(source_rows = n(), .groups = "drop") |>
  mutate(forecast_origin = forecast_origin,
    predictor = ifelse(period < as.Date("2023-07-01"), "strength_lag2", "strength_lag"),
    exact_historical_geopko_coding_verified = FALSE)
stopifnot(nrow(monthly_sources) == 6L)
write.csv(monthly_sources, "data/forecast_origin_deployment_months.csv", row.names = FALSE)

# Independently reconcile both current quarter means using retained source rows.
# No missing monthly deployment or unlisted locality is converted to zero.
raw_months <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
lineage$military_strength <- suppressWarnings(as.numeric(lineage$no.troops)) -
  suppressWarnings(as.numeric(raw_months$fpu.no[lineage$source_row]))
monthly_strength <- lineage |> filter(!is.na(locality_id), nzchar(locality_id)) |>
  group_by(locality_id, period) |>
  summarise(strength = if (anyNA(military_strength)) NA_real_ else sum(military_strength),
    max_age = max(map_age), .groups = "drop")
panel <- read.csv("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.csv") |>
  filter(year == 2023, quarter == 4)
stopifnot(nrow(panel) == 19L)
rebuilt <- crossing(locality_id = panel$locality_id,
    period = seq(as.Date("2023-04-01"), as.Date("2023-09-01"), by = "month")) |>
  left_join(monthly_strength, by = c("locality_id", "period"), relationship = "one-to-one") |>
  mutate(predictor = ifelse(period < as.Date("2023-07-01"), "strength_lag2", "strength_lag"),
    usable = is.finite(strength) & strength >= 0 & !is.na(max_age) & max_age >= 0 & max_age <= 5) |>
  group_by(locality_id, predictor) |>
  summarise(value = if (all(usable)) mean(strength) / 1000 else NA_real_, .groups = "drop") |>
  pivot_wider(names_from = predictor, values_from = value, names_prefix = "rebuilt_")
comparison <- panel |> select(locality_id, locality, core_sample, strength_lag, strength_lag2) |>
  left_join(rebuilt, by = "locality_id", relationship = "one-to-one") |>
  mutate(forecast_origin = forecast_origin,
    as_of_certified_strength_lag = NA_real_, as_of_certified_strength_lag2 = NA_real_,
    status = ifelse(is.na(strength_lag), "No usable modern listing; operational absence unknown",
      "Map identities predate origin; numeric modern coding not historically certified")) |>
  arrange(locality)
for (field in c("strength_lag", "strength_lag2")) {
  a <- comparison[[field]]
  b <- comparison[[paste0("rebuilt_", field)]]
  stopifnot(identical(is.na(a), is.na(b)), max(abs(a - b), na.rm = TRUE) < 1e-10)
}
write.csv(comparison, "data/forecast_origin_deployment_comparison.csv", row.names = FALSE, na = "")
cat("Three report hashes, six map-months and 19 current locality comparisons verified.\n")
