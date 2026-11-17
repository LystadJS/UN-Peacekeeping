# Fixed outcome construction for prospective scoring. This performs no fitting.
load_frozen_boundaries <- function() {
  paths <- c("data/raw/boundaries/salb_2018.geojson", "config/city_aggregation.csv")
  hashes <- c("6565722e4287e220dab8d65f049a119d08165a47acaaf7515c5573c7f8ce9b02",
              "309c448324b639b5752e3daccfcc751b468f4b03dc153db7f052f07554023029")
  for(i in seq_along(paths))
    if(digest::digest(file=paths[i],algo="sha256") != hashes[i]) stop("Frozen geography changed")
  boundaries <- sf::st_read(paths[1],quiet=TRUE) |>
    dplyr::filter(adm1nm %in% c("Nord-Kivu","Sud-Kivu","Ituri")) |>
    dplyr::transmute(locality_id=adm2cd,locality=adm2nm,province=adm1nm) |>
    dplyr::left_join(readr::read_csv(paths[2],show_col_types=FALSE),
                     by="locality_id",relationship="many-to-one") |>
    dplyr::mutate(locality_id=dplyr::coalesce(composite_id,locality_id),
                  locality=dplyr::coalesce(composite_name,locality)) |>
    dplyr::group_by(locality_id,locality,province) |> dplyr::summarise(.groups="drop")
  stopifnot(nrow(boundaries)==19,all(sf::st_is_valid(boundaries)))
  boundaries
}

read_ged_outcomes <- function(path) {
  needed <- c("id","country_id","type_of_violence","where_prec",
              "longitude","latitude","date_start","date_end")
  x <- readr::read_csv(path,col_select=dplyr::all_of(needed),show_col_types=FALSE,
    col_types=readr::cols(.default=readr::col_double(),
                         date_start=readr::col_character(),date_end=readr::col_character()))
  if(nrow(readr::problems(x))) stop("GED columns did not parse cleanly")
  if(anyNA(x$id)||anyDuplicated(x$id)||anyNA(x$country_id))
    stop("Missing IDs/country or duplicate IDs; reconcile release before counting")
  x
}

construct_strict_outcomes <- function(events,boundaries,start,end) {
  if(anyNA(events$id)||anyDuplicated(events$id)) stop("Event IDs must be unique")
  start <- as.Date(start); end <- as.Date(end)
  if(is.na(start)||is.na(end)||start>end) stop("Invalid occurrence window")
  x <- events |> dplyr::filter(country_id==490) |>
    dplyr::mutate(start_date=as.Date(date_start),end_date=as.Date(date_end),
      valid_dates=!is.na(start_date)&!is.na(end_date)&start_date<=end_date,
      valid_coordinates=is.finite(longitude)&is.finite(latitude)&
                        abs(longitude)<=180&abs(latitude)<=90,
      locality_id=NA_character_,match_count=0L)
  valid <- which(x$valid_coordinates)
  if(length(valid)) {
    matches <- sf::st_intersects(sf::st_as_sf(x[valid,],coords=c("longitude","latitude"),crs=4326),boundaries)
    x$match_count[valid] <- lengths(matches)
    x$locality_id[valid] <- vapply(matches,function(z)
      if(length(z)==1)boundaries$locality_id[z] else NA_character_,character(1))
  }
  # Whole intervals must fit the quarter AND one calendar month. Do not split
  # an imprecise interval or move an event to manufacture eligible counts.
  ledger <- x |> dplyr::mutate(reason=dplyr::case_when(
    !valid_dates~"invalid_dates",
    start_date<start|end_date>end~"outside_occurrence_window",
    is.na(type_of_violence)|type_of_violence!=3~"not_one_sided",
    !valid_coordinates~"invalid_coordinates",
    match_count!=1~"not_uniquely_assigned",
    is.na(where_prec)|where_prec!=1~"location_precision_not_exact",
    format(start_date,"%Y-%m")!=format(end_date,"%Y-%m")~"cross_month_date_interval",
    TRUE~"eligible"))
  eligible <- dplyr::filter(ledger,reason=="eligible")
  totals <- eligible |> dplyr::count(locality_id,name="recorded_events")
  counts <- sf::st_drop_geometry(boundaries) |> dplyr::select(locality_id,locality) |>
    dplyr::left_join(totals,by="locality_id") |>
    dplyr::mutate(recorded_events=tidyr::replace_na(recorded_events,0L))
  stopifnot(sum(counts$recorded_events)==nrow(eligible),nrow(counts)==19,!anyNA(ledger$reason))
  list(counts=counts,ledger=ledger)
}
