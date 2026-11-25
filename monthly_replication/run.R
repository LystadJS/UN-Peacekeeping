# Run from the standalone project folder. Source data can be staged locally
# or shared read-only with the adjacent historical project.
arguments <- commandArgs(trailingOnly = TRUE)
valid_arguments <- c("--render", "--panel-only", "--require-primary")
if (length(setdiff(arguments, valid_arguments))) stop("Unknown run argument.")
if (!file.exists("R/support.R")) stop("Run Rscript run.R from monthly_replication.")

source("R/libraries.R")
source("R/support.R")
source("R/panel.R")
source("R/handover.R")
source("R/association.R")
source("R/forecast.R")
source("R/vintages.R")

input_dir <- Sys.getenv("MONUSCO_MONTHLY_INPUTS", "inputs")
result_dir <- Sys.getenv("MONUSCO_MONTHLY_RESULTS", "results")
dir.create(result_dir, recursive = TRUE, showWarnings = FALSE)
upstream <- function(local, sibling) {
  path <- file.path(input_dir, local)
  if (file.exists(path)) path else file.path("../data/raw", sibling)
}

local_boundaries <- file.path(input_dir, "ocha_adm2.geojson")
geo_path <- if (file.exists(local_boundaries)) local_boundaries else
  upstream("geoboundaries_adm2.geojson", "boundaries/geoboundaries_adm2.geojson")
boundary_reference <- upstream("salb_2018.geojson", "boundaries/salb_2018.geojson")
monthly_path <- upstream("location_month.rds", "geo_pko/2.3/location_month.rds")
map_path <- upstream("location_map.rds", "geo_pko/2.3/location_map.rds")
ucdp_path <- upstream("ged261-csv.zip", "ucdp/26.1/ged261-csv.zip")
acled_path <- file.path(input_dir, "acled.csv")
acled_receipt <- file.path(input_dir, "acled_receipt.csv")
population_years <- 2015:2025
population_url <- worldpop_url(population_years)
population_paths <- file.path(input_dir, "population", basename(population_url))

manifest <- tibble(
  source_id = c("boundary", "boundary_reference", "geo_pko_month", "geo_pko_map",
                "ucdp_ged", "acled", "acled_receipt", paste0("worldpop_", population_years)),
  version = c(if (geo_path == local_boundaries) "OCHA ADM2 v01 (valid 2019-09-11)" else "9469f09",
              "SALB 2018", "2.3", "2.3", "26.1", "frozen export", "local receipt",
              rep("R2025A UA v1", length(population_years))),
  path = c(geo_path, boundary_reference, monthly_path, map_path, ucdp_path,
           acled_path, acled_receipt, population_paths),
  source_url = c(if (geo_path == local_boundaries) "https://data.humdata.org/dataset/f42132b9-8cc6-4201-b020-9259c56e8868/resource/97260e2b-65b1-41e3-aef2-fb0e6874e406/download/cod_admin_boundaries.geojson.zip" else
      "https://github.com/wmgeolab/geoBoundaries/raw/9469f09/releaseData/gbOpen/COD/ADM2/geoBoundaries-COD-ADM2.geojson",
    "https://salb.un.org/en/data/cod", rep("https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset", 2),
    "https://ucdp.uu.se/downloads/ged/ged261-csv.zip", "https://acleddata.com/conflict-data/data-export-tool",
    NA_character_, population_url),
  redistribution = c("verify layer terms", "verify SALB terms", rep("keep local", 2), "verify release terms",
                     "keep local; apply ACLED terms", "keep local", rep("check attribution", length(population_years)))
) |>
  mutate(available = file.exists(path), bytes = if_else(available, file.size(path), NA_real_),
         local_modified_utc = format(file.info(path)$mtime, tz = "UTC", usetz = TRUE),
         sha256 = vapply(path, function(value) {
           if (file.exists(value)) digest::digest(readBin(value, "raw", n = file.size(value)), algo = "sha256", serialize = FALSE) else NA_character_
         }, character(1)))
write_result(manifest, "source_manifest")
writeLines(capture.output(sessionInfo()), file.path(result_dir, "session_info.txt"))
required <- c(geo_path, monthly_path, map_path, ucdp_path)
if (geo_path != local_boundaries) required <- c(required, boundary_reference)
if (any(!file.exists(required))) stop("Required source files missing. See results/source_manifest.csv.")

territories <- read_territories(geo_path, boundary_reference)
write_result(sf::st_drop_geometry(territories), "territory_crosswalk")
population <- extract_population(population_paths, territories)
write_result(population, "population_audit")
deployment <- read_deployment(monthly_path, map_path, territories)
write_result(deployment$lineage, "deployment_lineage")
write_result(deployment$listings, "deployment_listings")
write_result(deployment$schedule, "deployment_map_schedule")
coverage <- read_coverage("config/deployment_coverage.csv", deployment, territories$territory_id)
acled <- NULL
if (file.exists(acled_path) && file.exists(acled_receipt)) {
  receipt <- read_csv_local(acled_receipt, col_types = cols(.default = col_character()))
  require_columns(receipt, c("exported_at", "country", "start_date", "end_date", "event_types"), "ACLED receipt")
  if (nrow(receipt) != 1L || anyNA(receipt[c("exported_at", "country", "start_date", "end_date", "event_types")]) ||
      is.na(as.Date(receipt$exported_at)) ||
      !key_text(receipt$country) %in% c("democratic republic of the congo", "democratic republic of congo", "drc") ||
      as.Date(receipt$start_date) > min(study_months) ||
      as.Date(receipt$end_date) < as.Date("2025-12-31") || key_text(receipt$event_types) != "all") {
    stop("ACLED receipt must identify a dated all-event DRC export covering the entire study period.")
  }
  acled <- assign_acled(acled_path, territories)
  write_result(count(acled, decision, name = "events"), "acled_event_flow")
  write_result(acled, "acled_crosswalk")
}
ucdp <- assign_ucdp(ucdp_path, territories)
write_result(count(ucdp, decision, name = "events"), "ucdp_event_flow")
write_result(ucdp, "ucdp_crosswalk")
panel <- make_panel(territories, population, deployment, coverage, acled, ucdp)
write_result(panel, "territory_month_panel")
write_result(count(panel, province, year, deployment_status, name = "territory_months"), "deployment_coverage_flow")
write_result(filter(panel, month <= deployment_end, deployment_status == "unknown") |>
  select(territory_id, month, existing_map_key = map_key, indeterminate_listing) |>
  left_join(deployment$schedule, by = "month", relationship = "many-to-many") |> arrange(month, territory_id),
  "coverage_review_queue")

run_handover(panel, territories, acled, ucdp)
status <- tibble(stage = c("panel", "acled_input", "population", "deployment_zeros", "handover_descriptive",
                           "handover_causal", "forecast_vintages"),
                 status = c("built", if (is.null(acled)) "blocked: authorized export and receipt required" else "available",
                            if (anyNA(panel$population)) "incomplete" else "available",
                            if (any(panel$presence %in% 0L)) "reviewed rows available" else "blocked: no verified absence rows",
                            if (is.null(acled)) "UCDP only" else "ACLED and UCDP",
                            "blocked: protection reach, reporting continuity and comparator unresolved",
                            if (is.null(acled)) "blocked: ACLED verification outcome unavailable" else run_vintage_forecasts(panel, territories, input_dir)))
if (!"--panel-only" %in% arguments) {
  association_status <- run_association(panel, territories)
  forecast_status <- run_forecasts(panel)
  status <- bind_rows(status, tibble(stage = c("primary_association", "retrospective_forecast"),
                                    status = c(association_status, forecast_status)))
}
write_result(status, "run_status")
print(status, n = Inf)
if ("--render" %in% arguments) {
  quarto <- Sys.getenv("QUARTO_BIN", Sys.which("quarto"))
  if (!nzchar(quarto)) stop("Set QUARTO_BIN to the Quarto executable.")
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
  if (system2(quarto, c("render", "manuscript.qmd"), stdout = "", stderr = "") != 0L) stop("Quarto render failed.")
}
if ("--require-primary" %in% arguments &&
    (!exists("association_status") || association_status != "completed")) quit(status = 2L)
