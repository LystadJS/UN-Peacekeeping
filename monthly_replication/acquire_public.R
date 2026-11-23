# Optional public-input bootstrap for a checkout without the historic data tree.
source("R/libraries.R")
source("R/support.R")
source("R/panel.R")
input_dir <- Sys.getenv("MONUSCO_MONTHLY_INPUTS", "inputs")
dir.create(file.path(input_dir, "population"), recursive = TRUE, showWarnings = FALSE)
options(timeout = max(120L, getOption("timeout")))

download_checked <- function(url, path, expected_hash = NA_character_) {
  verify <- function(file) {
    size <- file.size(file)
    if (is.na(size) || size == 0) stop("Empty download: ", file)
    if (!is.na(expected_hash)) {
      actual <- digest::digest(readBin(file, "raw", n = size), algo = "sha256", serialize = FALSE)
      if (!identical(actual, expected_hash)) stop("Hash mismatch: ", file)
    }
  }
  if (file.exists(path)) {
    verify(path)
    return(invisible(path))
  }
  temporary <- tempfile(tmpdir = dirname(path))
  on.exit(unlink(temporary))
  status <- download.file(url, temporary, mode = "wb")
  if (status != 0L) stop("Download failed: ", url)
  verify(temporary)
  if (!file.rename(temporary, path)) stop("Could not stage: ", path)
  invisible(path)
}

ocha_url <- paste0("https://data.humdata.org/dataset/f42132b9-8cc6-4201-b020-9259c56e8868/",
  "resource/97260e2b-65b1-41e3-aef2-fb0e6874e406/download/cod_admin_boundaries.geojson.zip")
ocha_file <- file.path(input_dir, "ocha_adm2.geojson")
if (!file.exists(ocha_file)) {
  archive <- download_checked(ocha_url, file.path(input_dir, "ocha_boundaries.zip"))
  extracted <- unzip(archive, files = "cod_admin2.geojson", exdir = input_dir)
  if (!file.rename(extracted, ocha_file)) stop("Could not stage OCHA ADM2 layer.")
}

geo_pko_base <- "https://www.uu.se/download/"
download_checked(paste0(geo_pko_base, "18.74301a071971546b354496ab/1749556881879/Geo_PKO_v.2.3_location_month.rds"),
  file.path(input_dir, "location_month.rds"),
  "146b7e2f298093145faf076839dc35de42924c86d533a0a3c8b9db579f339f4a")
download_checked(paste0(geo_pko_base, "18.74301a071971546b354496b0/1749556889697/Geo_PKO_v.2.3_location_map.rds"),
  file.path(input_dir, "location_map.rds"),
  "bd75161e315c6c0837b6b3782dbf2e370f6f81a59155df21cc407350371831ce")
download_checked("https://ucdp.uu.se/downloads/ged/ged261-csv.zip",
  file.path(input_dir, "ged261-csv.zip"),
  "8c941d84954e555ee2e54f40fa04d9203bf1e2f962203d0a9930966c4947c667")
for (url in worldpop_url(2015:2025)) {
  download_checked(url, file.path(input_dir, "population", basename(url)))
}
