library(dplyr)
library(readr)
library(tidyr)
library(lubridate)

study_months <- seq(as.Date("2015-01-01"), as.Date("2025-12-01"), by = "month")
deployment_end <- as.Date("2024-12-01")
study_provinces <- c("Ituri", "North Kivu", "South Kivu")

read_csv_local <- function(path, ...) read_csv(path, show_col_types = FALSE, ...)
write_result <- function(data, name) write_csv(data, file.path(result_dir, paste0(name, ".csv")))

require_columns <- function(data, columns, label) {
  absent <- setdiff(columns, names(data))
  if (length(absent)) stop(label, " is missing: ", paste(absent, collapse = ", "))
}

unique_key <- function(data, keys, label) {
  if (anyNA(data[keys]) || anyDuplicated(data[keys])) stop("Invalid key in ", label)
}

key_text <- function(value) {
  value <- stringi::stri_trans_general(as.character(value), "Latin-ASCII")
  value <- gsub("[^a-z0-9]+", " ", tolower(value))
  trimws(value)
}

province_name <- function(value) {
  case_when(
    key_text(value) %in% c("ituri") ~ "Ituri",
    key_text(value) %in% c("nord kivu", "north kivu") ~ "North Kivu",
    key_text(value) %in% c("sud kivu", "south kivu") ~ "South Kivu"
  )
}

period_start <- function(year, month) as.Date(sprintf("%04d-%02d-01", year, month))

as_number <- function(value) suppressWarnings(as.numeric(as.character(value)))

complete_sum <- function(value) if (anyNA(value)) NA_real_ else sum(value)

safe_fit <- function(fit) {
  tryCatch({
    value <- fit()
    good <- isTRUE(value$sdr$pdHess) && isTRUE(value$fit$convergence == 0) &&
      all(is.finite(unlist(glmmTMB::fixef(value))))
    list(fit = if (good) value else NULL, status = if (good) "ok" else "convergence_or_hessian")
  }, error = function(error) list(fit = NULL, status = conditionMessage(error)))
}

read_layer <- function(path) {
  layer <- sf::st_read(path, quiet = TRUE)
  sf::st_transform(sf::st_make_valid(layer), 4326)
}

coordinate_match <- function(data, territories) {
  destination <- rep(NA_character_, nrow(data))
  matches <- integer(nrow(data))
  valid <- which(is.finite(data$longitude) & is.finite(data$latitude) &
                   abs(data$longitude) <= 180 & abs(data$latitude) <= 90)
  if (length(valid)) {
    points <- sf::st_as_sf(data[valid, ], coords = c("longitude", "latitude"), crs = 4326)
    candidates <- sf::st_intersects(points, territories, model = "closed")
    matches[valid] <- lengths(candidates)
    single <- lengths(candidates) == 1L
    destination[valid[single]] <- territories$territory_id[unlist(candidates[single])]
  }
  mutate(data, territory_id = destination, coordinate_matches = matches)
}

add_lags <- function(panel) {
  arrange(panel, territory_id, month) |>
    group_by(territory_id) |>
    mutate(
      adjacent = lag(month) == month %m-% months(1),
      across(c(incidents, battles, presence, troop_strength, map_age,
               ucdp_incidents, narrow_incidents, exact_incidents),
             ~ if_else(adjacent %in% TRUE, lag(.x), NA), .names = "{.col}_lag"),
      map_lag = if_else(adjacent %in% TRUE, lag(map_key), NA_character_)
    ) |>
    ungroup() |>
    select(-adjacent)
}
