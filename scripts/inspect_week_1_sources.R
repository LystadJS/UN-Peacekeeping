.libPaths(c(".local_library", .libPaths()))
library(sf)
for (vintage in c("2013", "2015_jan", "2015_jul", "2018")) {
  boundaries <- st_read(paste0("data/raw/boundaries/salb_", vintage, ".geojson"), quiet = TRUE)
  cat(vintage, nrow(boundaries), "invalid", sum(!st_is_valid(boundaries)), "\n")
  print(st_drop_geometry(boundaries)[grepl("Kivu|Ituri", boundaries$adm1nm), c("adm1nm", "adm2nm", "adm2cd")])
}
cat("READXL:", requireNamespace("readxl", quietly = TRUE), "\n")
cat(pdftools::pdf_text("data/raw/boundaries/salb_terms.pdf"))
if (requireNamespace("readxl", quietly = TRUE)) {
  print(readxl::excel_sheets("data/raw/boundaries/salb_history.xlsx"))
  print(head(readxl::read_excel("data/raw/boundaries/salb_history.xlsx"), 15))
}
