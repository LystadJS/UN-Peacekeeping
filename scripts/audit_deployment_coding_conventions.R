# Resolve proposed mechanisms against the published row-level coding itself.
# No source, original panel, fitted model, or historical-availability flag changes.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
output_directory <- "outputs/coding_conventions"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
manifest <- read.csv("data/deployment_coding_conventions_sources.csv")
for (i in seq_len(nrow(manifest))) {
  stopifnot(file.info(manifest$path[i])$size == manifest$bytes[i],
    digest::digest(readBin(manifest$path[i], "raw", manifest$bytes[i]),
      algo = "sha256", serialize = FALSE) == manifest$sha256[i])
}
rows <- readRDS(manifest$path[manifest$source_id == "geo_pko_map"]) |>
  ungroup() |> filter(mission == "MONUSCO", year == 2023,
    month %in% c(2, 6, 8), location %in% c("Mavivi", "Bukavu", "Rwindi", "Nyamilima")) |>
  mutate(revision = as.integer(sub(".*Rev. ", "", source)))
stopifnot(nrow(rows) == 12L, !anyDuplicated(rows[c("location", "revision")]))
write.csv(rows, file.path(output_directory, "affected_source_rows.csv"), row.names = FALSE)

# TCC subtotals can be partially known. Their sum is a known-component subtotal,
# never the actual full headcount; unknown military police remain unknown.
tcc_columns <- grep("^notroopspertcc_", names(rows), value = TRUE)
tcc_values <- as.data.frame(lapply(rows[tcc_columns], function(x) suppressWarnings(as.numeric(x))))
audit <- rows |> transmute(revision, location, battalion, company, platoon,
  other_units = other.size, total_coded = as.numeric(no.troops),
  infantry_indicator = inf, infantry_coded = inf.no,
  fpu_indicator = fpu, fpu_coded = fpu.no,
  military_after_fpu_subtraction = as.numeric(no.troops) - fpu.no,
  fpu_type_listed = grepl("(^|, *)12(,|$)", troop.type),
  reconnaissance_type_listed = grepl("(^|, *)10(,|$)", troop.type),
  military_police_unsized_in_comment = grepl("MP unit, size not given", comment.on.unit, fixed = TRUE),
  helicopter_unsized_in_comment = grepl("helicopter support unit, size not given", comment.on.unit, fixed = TRUE),
  first_tcc = nameoftcc_1, first_tcc_coded = suppressWarnings(as.numeric(notroopspertcc_1)),
  second_tcc = nameoftcc_2, second_tcc_coded = suppressWarnings(as.numeric(notroopspertcc_2))) |>
  mutate(standard_sized_unit_sum = 650 * battalion + 150 * company + 35 * platoon,
    known_tcc_subtotal = rowSums(tcc_values, na.rm = TRUE),
    tcc_minus_total = known_tcc_subtotal - total_coded,
    source_mechanism = case_when(
      location == "Bukavu" & revision == 49L ~ "egypt_150_in_total_and_infantry_but_fpu_zero_despite_fpu_type",
      location == "Mavivi" & revision == 51L ~ "six_companies_include_tiu_but_tcc_subtotal_conflicts_with_total",
      location == "Mavivi" ~ "six_companies_include_tiu_helicopter_explicitly_unsized",
      location %in% c("Rwindi", "Nyamilima") ~ "country_and_unit_size_assignment_requires_geographic_adjudication",
      TRUE ~ "comparison_row_consistent_fpu_subtraction"))
stopifnot(all(audit$standard_sized_unit_sum == audit$total_coded),
  sum(audit$tcc_minus_total != 0) == 1L,
  audit$tcc_minus_total[audit$location == "Mavivi" & audit$revision == 51L] == 150,
  audit$fpu_type_listed[audit$location == "Bukavu" & audit$revision == 49L],
  audit$fpu_coded[audit$location == "Bukavu" & audit$revision == 49L] == 0,
  all(audit$helicopter_unsized_in_comment[audit$location == "Mavivi"]))
write.csv(audit, "data/deployment_coding_conventions_audit.csv", row.names = FALSE, na = "")
print(audit |> select(revision, location, total_coded, fpu_coded, known_tcc_subtotal, tcc_minus_total))
cat("Coding mechanisms audited; one residual TCC-total inconsistency remains.\n")
