run_vintage_forecasts <- function(panel, territories, input_dir) {
  manifest_path <- file.path(input_dir, "forecast_vintages.csv")
  if (!file.exists(manifest_path)) return("unverified: no dated ACLED snapshots supplied")
  snapshots <- read_csv_local(manifest_path, col_types = cols(
    target_month = col_date(), export_date = col_date(), file = col_character()))
  unique_key(snapshots, "target_month", "forecast vintage manifest")
  if (anyNA(snapshots$export_date) || any(!snapshots$target_month %in% study_months) ||
      any(snapshots$export_date >= snapshots$target_month) ||
      any(is.na(snapshots$file) | basename(snapshots$file) != snapshots$file)) {
    stop("Each vintage must identify a local file and export date before its target calendar month.")
  }
  scores <- bind_rows(lapply(seq_len(nrow(snapshots)), function(index) {
    snapshot <- snapshots[index, ]
    records <- assign_acled(file.path(input_dir, snapshot$file), territories)
    known_through <- floor_date(snapshot$export_date, "month") %m-% months(1)
    counts <- records |>
      filter(decision == "included", date <= snapshot$export_date, month <= known_through) |>
      summarise(incidents = sum(targeted), battles = sum(battle), .by = c(territory_id, month))
    history <- panel |>
      select(-incidents, -battles) |>
      left_join(counts, by = c("territory_id", "month"), relationship = "one-to-one") |>
      mutate(incidents = if_else(month <= known_through, replace_na(incidents, 0L), NA_integer_),
             battles = if_else(month <= known_through, replace_na(battles, 0L), NA_integer_),
             # These map vintages do not have verified public release dates.
             presence = NA_integer_) |>
      add_lags() |>
      group_by(territory_id) |>
      mutate(incidents_lag = lag(incidents_lag), battles_lag = lag(battles_lag)) |>
      ungroup() |>
      left_join(select(panel, territory_id, month, verified_outcome = incidents), by = c("territory_id", "month")) |>
      mutate(incidents = if_else(month == snapshot$target_month, verified_outcome, incidents))
    forecast_origin(history, snapshot$target_month) |>
      mutate(export_date = snapshot$export_date, information_through = known_through)
  }))
  if (!nrow(scores)) return("no eligible outcomes in supplied vintages")
  write_result(score_forecasts(scores), "forecast_vintage_scores")
  "completed: archived ACLED history; deployment publication vintages remain unverified"
}
