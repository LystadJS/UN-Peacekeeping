run_handover <- function(panel, territories, acled, ucdp) {
  inventory <- read_csv_local("config/handover.csv",
    col_types = cols(date = col_date(), date_verified = col_logical()))
  labels <- sf::st_drop_geometry(territories) |>
    filter(province == "South Kivu") |>
    mutate(join_name = trimws(sub(" (city|ville)$", "", key_text(territory_name)))) |>
    select(join_name, territory_id)
  # Some cities and territories can share a name. Keep case geography
  # unresolved unless the named territory has exactly one candidate.
  labels <- add_count(labels, join_name) |> filter(n == 1L) |> select(-n)
  inventory <- inventory |>
    mutate(join_name = key_text(territory_name)) |>
    left_join(labels, by = "join_name", na_matches = "never") |>
    select(-join_name)
  write_result(inventory, "handover_register")
  reporting <- read_csv_local("config/reporting.csv",
    col_types = cols(start_date = col_date(), end_date = col_date()))
  write_result(reporting, "handover_reporting_evidence")
  write_result(read_csv_local("config/handover_gates.csv"), "handover_identification_gates")
  write_result(read_csv_local("config/south_kivu_context.csv"), "south_kivu_conflict_context")

  outcomes <- c("incidents", "event_fatalities", "ucdp_incidents", "ucdp_civilian_deaths")
  south <- filter(panel, province == "South Kivu", year >= 2021)
  province_months <- group_by(south, month) |>
    summarise(across(all_of(outcomes), complete_sum), .groups = "drop")
  write_result(province_months, "south_kivu_monthly")
  paired <- bind_rows(lapply(c(2024L, 2025L), function(post_year) {
    eligible_months <- if (post_year == 2024L) 7:12 else 1:12
    province_months |>
      filter(lubridate::month(month) %in% eligible_months, year(month) %in% c(2021:2023, post_year)) |>
      mutate(period = if_else(year(month) == post_year, "post", "season_matched_reference"),
             comparison_year = post_year) |>
      group_by(comparison_year, period) |>
      summarise(months = n(), across(all_of(outcomes), ~ complete_sum(.x) / n()), .groups = "drop")
  }))
  write_result(paired, "south_kivu_period_comparison")

  cases <- filter(inventory, date_verified, !is.na(territory_id), milestone == "facility_transferred")
  case_counts <- inner_join(south, cases |> select(case_id, territory_id, date),
                            by = "territory_id", relationship = "many-to-many") |>
    mutate(anchor = floor_date(date, "month"),
           relative_month = 12L * (year(month) - year(anchor)) + lubridate::month(month) - lubridate::month(anchor)) |>
    filter(abs(relative_month) %in% 1:6) |>
    add_count(territory_id, month, name = "concurrent_case_windows") |>
    mutate(period = if_else(relative_month < 0, "before", "after")) |>
    group_by(case_id, territory_id, date, period) |>
    summarise(months = n(), any_shared_territory_month = any(concurrent_case_windows > 1L),
              across(all_of(outcomes), complete_sum), .groups = "drop")
  write_result(case_counts, "south_kivu_case_windows")

  source_mix <- function(data, labels, date_column, source_column, system) {
    data |>
      filter(decision == "included", year(.data[[date_column]]) >= 2021) |>
      inner_join(labels, by = "territory_id") |>
      transmute(system, month, source_record = .data[[source_column]]) |>
      mutate(source_record = if_else(is.na(source_record) | source_record == "", "missing_source", source_record)) |>
      separate_longer_delim(source_record, delim = ";") |>
      mutate(source_record = trimws(source_record)) |>
      count(system, month, source_record, name = "event_source_mentions")
  }
  mix <- source_mix(ucdp, labels, "date_start", "source_office", "UCDP")
  if (!is.null(acled)) {
    mix <- bind_rows(mix, source_mix(filter(acled, targeted), labels, "date", "source", "ACLED"))
  }
  write_result(mix, "south_kivu_source_mentions")
}
