# Audit release evidence separately from the periods described by deployment data.
# The recovered 2.2 file is a retrospective comparison source, never an admitted
# 1 October 2023 training input. Later advertisement cannot prove exact release.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
evidence <- read.csv("data/deployment_release_evidence.csv")
stopifnot(nrow(evidence) == 9L, !anyDuplicated(evidence$evidence_id))
for (i in seq_len(nrow(evidence))) {
  path <- evidence$path[i]
  stopifnot(file.info(path)$size == evidence$bytes[i],
    digest::digest(readBin(path, "raw", n = file.info(path)$size),
      algo = "sha256", serialize = FALSE) == evidence$sha256[i])
}
captures <- c("20230501080938", "20231206141424", "20240413090009")
versions <- c("2.1", "2.1", "2.2")
expected_mementos <- c("Mon, 01 May 2023 08:09:38 GMT",
  "Wed, 06 Dec 2023 14:14:24 GMT", "Sat, 13 Apr 2024 09:00:09 GMT")
for (i in seq_along(captures)) {
  root <- paste0("outputs/deployment_release_search/provider_", captures[i])
  page <- paste(readLines(paste0(root, ".html"), warn = FALSE), collapse = "\n")
  response <- jsonlite::fromJSON(paste0(root, "_response.json"))
  stopifnot(grepl(paste0("<h1>The Geocoded Peacekeeping Operations (Geo-PKO) Dataset ",
    versions[i], "</h1>"), page, fixed = TRUE),
    response$requested_capture == captures[i], response$status_code == 200L,
    response$memento_datetime == expected_mementos[i],
    grepl(captures[i], response$url, fixed = TRUE))
  if (versions[i] == "2.2") stopifnot(grepl("covers 1994-2022", page, fixed = TRUE))
}
release_audit <- data.frame(capture = captures, advertised_version = versions,
  coverage_end_year = c(2020L, 2020L, 2022L),
  before_forecast_cutoff = captures < "20231001000000",
  exact_first_release_established = FALSE,
  current_2_2_bytes_authenticated_before_cutoff = FALSE)
write.csv(release_audit, "data/deployment_release_advertisement.csv", row.names = FALSE)

# Inspect the actual recovered vintage, rather than inferring coverage from its
# filename. Rows are source-map/location records, not independent monthly reads.
historical <- readRDS("outputs/deployment_release_search/geopko_2_2.rds")
stopifnot(nrow(historical) == 20057L, ncol(historical) == 113L,
  max(historical$year) == 2022L)
coverage <- historical |> filter(mission == "MONUSCO") |>
  group_by(year) |> summarise(source_rows = n(), source_maps = n_distinct(source),
    locations = n_distinct(location), last_source_month = max(month), .groups = "drop") |>
  mutate(admitted_as_of_2023_10_01 = FALSE)
stopifnot(coverage$source_rows[coverage$year == 2021L] == 155L,
  coverage$source_rows[coverage$year == 2022L] == 178L,
  !any(coverage$year >= 2023L))
write.csv(coverage, "data/deployment_release_2_2_coverage.csv", row.names = FALSE)
cat("Nine release evidence hashes verified; 2.2 remains retrospective-only.\n")
