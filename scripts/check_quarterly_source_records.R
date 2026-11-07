# Independently reconstruct fixed diverse sample cells from ORIGINAL inputs.
# No fitted model or new eligibility rule is used. Row-level traces stay ignored.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(sf)
output_directory <- "outputs/quarterly_pilot/source_spotchecks"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds")
initial <- read.csv("outputs/quarterly_pilot/panel/initial_conditions_2015_q4.csv")
history <- read.csv("outputs/quarterly_pilot/panel/history_grid_2014_2023.csv")
dictionary <- read.csv("data/quarterly_data_dictionary.csv")
stopifnot(!anyDuplicated(dictionary$variable), all(nzchar(dictionary$definition)),
  all(nzchar(dictionary$units)), all(nzchar(dictionary$missing_rule)),
  all(unique(c(names(panel), names(initial), names(history))) %in% dictionary$variable))
# These cases are declared before reconstruction: initial history, end of period,
# constant deployment, unlisted deployment, and changing exposure availability.
cases <- data.frame(locality_id = c("COMPOSITE_BENI", "COD009015", "COD011016",
  "COD017001", "COMPOSITE_FIZI", "COMPOSITE_LUBERO"),
  year = c(2016L, 2023L, 2016L, 2016L, 2019L, 2018L), quarter = c(1L,4L,1L,1L,2L,3L))
# Resolve the explicit Aru case from the inventory instead of assuming its code.
cases$locality_id[4] <- unique(panel$locality_id[panel$locality == "Aru"])
selected <- inner_join(cases, panel, by = c("locality_id", "year", "quarter"), relationship = "one-to-one")
stopifnot(nrow(selected) == 6L)
boundary <- st_read("data/raw/boundaries/salb_2018.geojson", quiet = TRUE) |>
  filter(adm1nm %in% c("Nord-Kivu", "Sud-Kivu", "Ituri")) |>
  transmute(locality_id = adm2cd) |>
  left_join(read.csv("config/city_aggregation.csv"), by = "locality_id", relationship = "many-to-one") |>
  mutate(locality_id = coalesce(composite_id, locality_id)) |>
  group_by(locality_id) |> summarise(.groups = "drop")
assign_unique <- function(rows) {
  matches <- st_intersects(st_as_sf(rows, coords = c("longitude", "latitude"), crs = 4326), boundary)
  rows$locality_id <- vapply(matches, function(x) if (length(x) == 1L) boundary$locality_id[x] else NA_character_, character(1))
  rows
}
quarter_index <- function(date) as.integer(format(date, "%Y"))*4L + (as.integer(format(date, "%m"))-1L)%/%3L
# Extract afresh in a separate input directory, never reuse the panel's interim CSV.
input_directory <- "outputs/source_spotcheck_inputs"
dir.create(input_directory, recursive = TRUE, showWarnings = FALSE)
unzip("data/raw/ucdp/26.1/ged261-csv.zip", exdir = input_directory)
events <- readr::read_csv(file.path(input_directory, "GEDEvent_v26_1.csv"), show_col_types = FALSE) |>
  filter(country_id == 490, year >= 2014, year <= 2023, type_of_violence == 3, where_prec == 1,
    is.finite(longitude), is.finite(latitude), abs(longitude) <= 180, abs(latitude) <= 90) |>
  mutate(start = as.Date(date_start), end = as.Date(date_end)) |>
  filter(!is.na(start), !is.na(end), end >= start, format(start,"%Y-%m") == format(end,"%Y-%m")) |>
  assign_unique() |> mutate(index = quarter_index(start))
deployment <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup() |>
  mutate(source_row = row_number()) |>
  filter(trimws(mission) == "MONUSCO", year >= 2014, year <= 2023,
    is.finite(longitude), is.finite(latitude), abs(longitude) <= 180, abs(latitude) <= 90) |>
  assign_unique() |> mutate(period = as.Date(sprintf("%04d-%02d-01", year, month)),
    age = (year-source_year)*12L + month-source_month,
    military = suppressWarnings(as.numeric(no.troops))-suppressWarnings(as.numeric(fpu.no)), index = quarter_index(period))
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv")
results <- vector("list", nrow(selected))
for (i in seq_len(nrow(selected))) {
  row <- selected[i,]; index <- row$year*4L + row$quarter-1L
  source_events <- events |> filter(locality_id == row$locality_id, index == !!index)
  prior_events <- events |> filter(locality_id == row$locality_id, index == !!index-1L)
  source_deployments <- deployment |> filter(locality_id == row$locality_id, index == !!index-1L)
  monthly <- source_deployments |> group_by(period) |>
    summarise(strength = sum(military), age = if (length(age)) max(age) else NA_real_, .groups = "drop")
  rebuilt_strength <- if (nrow(monthly) == 3L && all(is.finite(monthly$strength) & monthly$strength >= 0 &
    is.finite(monthly$age) & monthly$age >= 0 & monthly$age <= 5)) mean(monthly$strength)/1000 else NA_real_
  lineage_rows <- lineage |> filter(locality_id == row$locality_id,
    quarter_index(as.Date(period)) == index-1L)
  passed <- nrow(source_events) == row$recorded_events &&
    sum(source_events$deaths_civilians) == row$civilian_fatalities && nrow(prior_events) == row$events_lag &&
    isTRUE(all.equal(rebuilt_strength, row$strength_lag, tolerance = 1e-10)) &&
    setequal(source_deployments$source_row, lineage_rows$source_row)
  results[[i]] <- data.frame(case = i, locality_id = row$locality_id, year = row$year, quarter = row$quarter,
    source_events = nrow(source_events), prior_events = nrow(prior_events),
    source_deployment_rows = nrow(source_deployments), rebuilt_strength = rebuilt_strength, passed = passed)
  write.csv(source_events, file.path(output_directory, paste0("case_",i,"_events.csv")), row.names = FALSE)
  write.csv(source_deployments, file.path(output_directory, paste0("case_",i,"_deployment.csv")), row.names = FALSE)
}
results <- bind_rows(results)
write.csv(results, file.path(output_directory, "case_results.csv"), row.names = FALSE)
stopifnot(all(results$passed))
aggregate <- data.frame(check = c("dictionary_fields", "original_source_cases", "case_failures"),
  value = c(length(unique(c(names(panel), names(initial), names(history)))), nrow(results), sum(!results$passed)))
write.csv(aggregate, "data/quarterly_source_spotcheck_summary.csv", row.names = FALSE)
print(results)
print(aggregate)
