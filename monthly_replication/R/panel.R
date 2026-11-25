read_territories <- function(boundary_path, reference_path) {
  boundary <- read_layer(boundary_path)
  if ("shapeID" %in% names(boundary)) {
    # Match names within overlapping areas. The reference supplies labels and
    # territory codes only; all analysis geometry comes from the chosen layer.
    reference <- read_layer(reference_path) |>
      transmute(territory_id = adm2cd, territory_name = adm2nm,
                province = province_name(adm1nm)) |>
      filter(!is.na(province))
    label_key <- function(value) trimws(sub(" (city|ville)$", "", key_text(value)))
    candidates <- sf::st_intersects(boundary, reference)
    index <- vapply(seq_len(nrow(boundary)), function(row) {
      matches <- candidates[[row]]
      named <- matches[label_key(reference$territory_name[matches]) == label_key(boundary$shapeName[row])]
      if (length(named) == 1L) named else NA_integer_
    }, integer(1))
    layer <- boundary |>
      mutate(boundary_id = shapeID, territory_id = reference$territory_id[index],
             territory_name = reference$territory_name[index], province = reference$province[index]) |>
      filter(!is.na(province)) |>
      select(boundary_id, territory_id, territory_name, province)
    if (!setequal(layer$territory_id, reference$territory_id)) {
      stop("Boundary crosswalk incomplete. Unmapped reference units: ",
           paste(reference$territory_name[!reference$territory_id %in% layer$territory_id], collapse = ", "))
    }
  } else {
    names(boundary) <- tolower(names(boundary))
    if ("adm2_name" %in% names(boundary)) boundary$adm2_en <- boundary$adm2_name
    if ("adm1_name" %in% names(boundary)) boundary$adm1_en <- boundary$adm1_name
    require_columns(boundary, c("adm2_pcode", "adm2_en", "adm1_en"), "OCHA ADM2")
    layer <- boundary |>
      transmute(boundary_id = adm2_pcode, territory_id = adm2_pcode,
                territory_name = adm2_en, province = province_name(adm1_en)) |>
      filter(!is.na(province))
  }
  unique_key(sf::st_drop_geometry(layer), "territory_id", "boundary crosswalk")
  if (!setequal(unique(layer$province), study_provinces)) stop("Boundary province coverage is incomplete.")
  layer
}

worldpop_url <- function(year) {
  file <- sprintf("cod_pop_%d_CN_1km_R2025A_UA_v1.tif", year)
  sprintf("https://data.worldpop.org/GIS/Population/Global_2015_2030/R2025A/%d/COD/v1/1km_ua/constrained/%s",
          year, file)
}

extract_population <- function(paths, territories) {
  bind_rows(lapply(seq_along(paths), function(index) {
    path <- paths[index]
    population_year <- 2014L + index
    if (!file.exists(path)) {
      return(tibble(territory_id = territories$territory_id, year = population_year,
                    population = NA_real_, missing_cell_share = NA_real_, raster_total = NA_real_))
    }
    raster <- terra::rast(path)
    if (terra::nlyr(raster) != 1L || !terra::is.lonlat(raster) ||
        ncol(raster) < 10L || any(abs(terra::res(raster) - 1 / 120) > 1e-5)) {
      stop("Unexpected WorldPop grid: ", path)
    }
    shape <- sf::st_transform(territories, terra::crs(raster))
    sums <- exactextractr::exact_extract(raster, shape, "sum", progress = FALSE)
    missing_share <- exactextractr::exact_extract(raster, shape, function(values, coverage_fraction) {
      sum(coverage_fraction[is.na(values)]) / sum(coverage_fraction)
    }, progress = FALSE)
    national_total <- terra::global(raster, "sum", na.rm = TRUE)[1, 1]
    if (any(!is.finite(sums) | sums <= 0) || sum(sums) > national_total) stop("Invalid population totals.")
    tibble(territory_id = territories$territory_id, year = population_year,
           population = sums, missing_cell_share = missing_share, raster_total = national_total)
  }))
}

read_deployment <- function(monthly_path, map_path, territories) {
  monthly <- readRDS(monthly_path) |> as_tibble() |> ungroup() |>
    mutate(source_row = row_number()) |>
    filter(mission == "MONUSCO", country == "DRC", year >= 2015L) |>
    mutate(period = period_start(year, month), map_date = period_start(source_year, source_month))
  maps <- readRDS(map_path) |> as_tibble() |> ungroup() |>
    filter(mission == "MONUSCO", country == "DRC", year >= 2014L) |>
    mutate(map_date = period_start(year, month))
  listing_fields <- c("source", "map_date", "location", "latitude", "longitude", "no.troops", "fpu.no")
  map_rows <- maps |> distinct(across(all_of(listing_fields)))
  lineage <- monthly |>
    left_join(mutate(map_rows, original_map_match = TRUE), by = listing_fields, na_matches = "na") |>
    mutate(map_key = paste(source, map_date, sep = " | "),
           map_age = 12L * (year(period) - year(map_date)) + month(period) - month(map_date),
           military_estimate = as_number(no.troops) - as_number(fpu.no),
           military_estimate = if_else(military_estimate >= 0, military_estimate, NA_real_))
  if (anyNA(lineage$map_age) || any(lineage$map_age < 0L)) stop("Invalid deployment map chronology.")
  lineage <- coordinate_match(lineage, territories)
  fields <- c("period", "map_key", "location", "latitude", "longitude")
  listings <- lineage |>
    group_by(across(all_of(fields))) |>
    summarise(territory_id = first(territory_id), map_age = first(map_age),
              source_rows = n(), map_match = all(original_map_match %in% TRUE),
              military_estimate = if (n_distinct(military_estimate) == 1L) first(military_estimate) else NA_real_,
              ambiguous_listing = n_distinct(military_estimate) > 1L, .groups = "drop")
  assigned <- listings |>
    filter(!is.na(territory_id)) |>
    group_by(territory_id, month = period) |>
    summarise(listed = any(military_estimate > 0 & map_match, na.rm = TRUE),
              indeterminate_listing = anyNA(military_estimate) || !all(map_match),
              troop_strength = if (n_distinct(map_key) == 1L && all(map_match)) complete_sum(military_estimate) else NA_real_,
              map_age = max(map_age), map_key = paste(sort(unique(map_key)), collapse = "; "), .groups = "drop")
  schedule <- lineage |> distinct(month = period, map_key, map_age)
  list(lineage = lineage |> select(source_row, all_of(listing_fields), period, map_key, map_age,
                                    territory_id, coordinate_matches, original_map_match, military_estimate),
       listings = listings, assigned = assigned, schedule = schedule)
}

read_coverage <- function(path, deployment, territory_ids) {
  reviewed <- read_csv_local(path, col_types = cols(
    territory_id = col_character(), month = col_date(), map_key = col_character(),
    coverage_confirmed = col_logical(), source_url = col_character(), decision_note = col_character()))
  unique_key(reviewed, c("territory_id", "month"), "deployment coverage review")
  if (any(!reviewed$territory_id %in% territory_ids) ||
      nrow(anti_join(reviewed, deployment$schedule, by = c("month", "map_key"))) ||
      anyNA(reviewed$coverage_confirmed) ||
      any(reviewed$coverage_confirmed & (is.na(reviewed$source_url) | is.na(reviewed$decision_note)))) {
    stop("Coverage ledger contains an invalid territory, map, or undocumented decision.")
  }
  left_join(reviewed, deployment$schedule, by = c("month", "map_key"), relationship = "many-to-one") |>
    rename(coverage_map = map_key, coverage_age = map_age)
}

assign_acled <- function(path, territories) {
  records <- read_csv_local(path, col_types = cols(.default = col_character()))
  names(records) <- tolower(names(records))
  require_columns(records, c("event_id_cnty", "event_date", "country", "admin1", "admin2",
    "civilian_targeting", "event_type", "fatalities", "longitude", "latitude", "geo_precision", "time_precision"), "ACLED")
  if (!"source" %in% names(records)) records$source <- NA_character_
  if (!"source_scale" %in% names(records)) records$source_scale <- NA_character_
  records <- records |>
    filter(key_text(country) %in% c("democratic republic of congo", "democratic republic of the congo", "drc")) |>
    transmute(event_id = event_id_cnty, date = as.Date(parse_date_time(event_date, c("ymd", "dmy"), quiet = TRUE)),
              reported_province = province_name(admin1), reported_territory = admin2,
              longitude = as_number(longitude), latitude = as_number(latitude),
              geo_precision = as_number(geo_precision), time_precision = as_number(time_precision),
              targeted = key_text(civilian_targeting) %in% "civilian targeting",
              narrow = event_type == "Violence against civilians", battle = event_type == "Battles",
              fatalities = as_number(fatalities), source, source_scale)
  unique_key(records, "event_id", "ACLED DRC")
  if (!nrow(records) || anyNA(records$date) || anyNA(records$narrow) || anyNA(records$battle)) {
    stop("ACLED extract has no DRC events or contains invalid required date/type fields.")
  }
  labels <- sf::st_drop_geometry(territories) |>
    transmute(territory_id, assigned_province = province, assigned_territory = territory_name)
  normalize_territory <- function(value) trimws(sub(" (city|ville)$", "", key_text(value)))
  coordinate_match(records, territories) |>
    left_join(labels, by = "territory_id", relationship = "many-to-one") |>
    mutate(month = floor_date(date, "month"),
           geographic_conflict = (!is.na(reported_province) & assigned_province != reported_province) |
             (!is.na(reported_territory) & normalize_territory(reported_territory) != normalize_territory(assigned_territory)),
           decision = case_when(
             !month %in% study_months ~ "outside_study_period",
             coordinate_matches > 1L ~ "multiple_polygon_matches",
             is.na(territory_id) ~ "outside_study_or_unresolved",
             geographic_conflict %in% TRUE ~ "admin_coordinate_conflict",
             !geo_precision %in% c(1, 2) ~ "location_precision",
             !time_precision %in% 1 ~ "date_precision",
             TRUE ~ "included"))
}

assign_ucdp <- function(path, territories) {
  extract_dir <- tempfile("monthly_ged_")
  dir.create(extract_dir)
  on.exit(unlink(extract_dir, recursive = TRUE))
  entries <- unzip(path, list = TRUE)$Name
  csv <- entries[grepl("^[^/\\\\]+\\.csv$", entries, ignore.case = TRUE)]
  if (length(csv) != 1L) stop("Expected one GED CSV.")
  records <- read_csv_local(unzip(path, files = csv, exdir = extract_dir),
                            col_select = all_of(c("id", "country", "type_of_violence", "date_start", "date_end",
                                                  "date_prec", "where_prec", "latitude", "longitude",
                                                  "deaths_civilians", "source_headline", "source_office")))
  records <- records |>
    filter(country == "DR Congo (Zaire)", type_of_violence == 3L) |>
    mutate(date_start = as.Date(date_start), date_end = as.Date(date_end), month = floor_date(date_start, "month"))
  if (!nrow(records)) stop("No DRC one-sided GED incidents. Verify provider country labels.")
  unique_key(records, "id", "GED")
  coordinate_match(records, territories) |>
    mutate(decision = case_when(
      !month %in% study_months ~ "outside_study_period",
      is.na(territory_id) ~ "outside_study_or_unresolved",
      !where_prec %in% c(1, 2) ~ "location_precision",
      is.na(date_end) | date_end < date_start | month != floor_date(date_end, "month") ~ "cross_month_or_invalid_date",
      TRUE ~ "included"))
}

make_panel <- function(territories, population, deployment, coverage, acled, ucdp) {
  acled_counts <- if (is.null(acled)) {
    tibble(territory_id = character(), month = as.Date(character()), incidents = integer(),
           narrow_incidents = integer(), exact_incidents = integer(), battles = integer(), event_fatalities = numeric())
  } else {
    filter(acled, decision == "included") |>
      group_by(territory_id, month) |>
      summarise(incidents = sum(targeted), narrow_incidents = sum(narrow),
                exact_incidents = sum(targeted & geo_precision == 1L), battles = sum(battle),
                event_fatalities = complete_sum(fatalities[targeted]), .groups = "drop")
  }
  ged_counts <- filter(ucdp, decision == "included") |>
    group_by(territory_id, month) |>
    summarise(ucdp_incidents = n(), ucdp_civilian_deaths = complete_sum(deaths_civilians), .groups = "drop")
  panel <- crossing(territory_id = territories$territory_id, month = study_months) |>
    left_join(sf::st_drop_geometry(territories), by = "territory_id", relationship = "many-to-one") |>
    mutate(year = year(month), season = factor(lubridate::month(month), levels = 1:12),
           month_index = 12L * (year - 2015L) + lubridate::month(month)) |>
    left_join(population, by = c("territory_id", "year"), relationship = "many-to-one") |>
    left_join(deployment$assigned, by = c("territory_id", "month"), relationship = "one-to-one") |>
    left_join(coverage, by = c("territory_id", "month"), relationship = "one-to-one") |>
    left_join(acled_counts, by = c("territory_id", "month"), relationship = "one-to-one") |>
    left_join(ged_counts, by = c("territory_id", "month"), relationship = "one-to-one") |>
    mutate(
      presence = case_when(
        month > deployment_end ~ NA_integer_,
        listed %in% TRUE ~ 1L,
        coverage_confirmed %in% TRUE & !indeterminate_listing %in% TRUE &
          (is.na(map_key) | map_key == coverage_map) ~ 0L),
      deployment_status = case_when(
        presence == 1L ~ "listed_military_presence",
        presence == 0L ~ "supported_no_military_listing",
        TRUE ~ "unknown"),
      troop_strength = case_when(presence == 0L ~ 0, presence == 1L ~ troop_strength),
      map_key = coalesce(map_key, coverage_map), map_age = coalesce(map_age, coverage_age),
      across(c(incidents, narrow_incidents, exact_incidents, battles),
             ~ if (is.null(acled)) .x else replace_na(.x, 0L)),
      event_fatalities = if_else(incidents %in% 0L, 0, event_fatalities),
      ucdp_civilian_deaths = if_else(is.na(ucdp_incidents), 0, ucdp_civilian_deaths),
      ucdp_incidents = replace_na(ucdp_incidents, 0L),
      log_population = log(population),
      south_kivu_reporting_caveat = province == "South Kivu" & month >= as.Date("2024-05-01")
    ) |>
    add_lags()
  unique_key(panel, c("territory_id", "month"), "monthly panel")
  stopifnot(nrow(panel) == nrow(territories) * length(study_months),
            sum(panel$ucdp_incidents) == sum(ucdp$decision == "included"),
            all(is.na(panel$presence[panel$month > deployment_end])))
  if (!is.null(acled)) stopifnot(sum(panel$incidents) == sum(acled$decision == "included" & acled$targeted))
  panel
}
