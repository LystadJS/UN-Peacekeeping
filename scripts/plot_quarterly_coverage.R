# Descriptive coverage only: no model or outcome-dependent sample selection.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(ggplot2)
output_directory <- "outputs/quarterly_pilot"
panel <- readRDS(file.path(output_directory, "panel/quarterly_panel_all_localities.rds"))
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv")
stopifnot(nrow(panel) == 608L, !anyDuplicated(panel[c("locality_id", "year", "quarter")]))
# Freshness is the maximum age among listed unit rows in the exposure quarter.
# It is not an independent measurement of deployment in every carried month.
freshness <- lineage |> filter(!is.na(locality_id), match_count == 1) |>
  mutate(period = as.Date(period), source_index = as.integer(format(period, "%Y")) * 4L +
    (as.integer(format(period, "%m")) - 1L) %/% 3L) |>
  group_by(locality_id, source_index) |>
  summarise(max_map_age = if (all(is.na(map_age))) NA_real_ else max(map_age, na.rm = TRUE),
            .groups = "drop")
chart_data <- panel |> mutate(source_index = year * 4L + quarter - 2L) |>
  left_join(freshness, by = c("locality_id", "source_index"), relationship = "many-to-one") |>
  mutate(locality_label = paste0(locality, ifelse(core_sample, " *", "")),
    locality_label = factor(locality_label, levels = rev(sort(unique(locality_label)))),
    coverage = ifelse(is.na(strength_lag), "Unknown / incomplete", "Listed strength available"),
    freshness = ifelse(is.na(max_map_age), "No mapped listing", paste0(max_map_age, " months")))
stopifnot(nrow(chart_data) == 608L)
write.csv(chart_data, file.path(output_directory, "quarterly_coverage_figure_data.csv"), row.names = FALSE)
plot_theme <- theme_minimal(base_size = 11) + theme(
  panel.grid = element_blank(), legend.position = "top", plot.title = element_text(face = "bold"),
  plot.caption = element_text(hjust = 0), plot.margin = margin(12, 15, 12, 12))
base_plot <- ggplot(chart_data, aes(time_index, locality_label)) +
  scale_x_continuous(breaks = c(1, 5, 9, 13, 17, 21, 25, 29, 32),
    labels = c("2016 Q1", "2017 Q1", "2018 Q1", "2019 Q1", "2020 Q1", "2021 Q1", "2022 Q1", "2023 Q1", "2023 Q4"),
    expand = expansion(add = .5)) + labs(x = "Outcome quarter (exposure is previous quarter)", y = NULL) + plot_theme
coverage_plot <- base_plot + geom_tile(aes(fill = coverage), colour = "white", linewidth = .25) +
  geom_point(data = filter(chart_data, is.na(strength_lag)), shape = 4, size = 1.4, colour = "#555555") +
  scale_fill_manual(values = c("Unknown / incomplete" = "#EEEEEE", "Listed strength available" = "#326681"), name = NULL) +
  labs(title = "Quarterly deployment-strength coverage", subtitle = "19 localities; 608 locality-quarters; 2016-2023",
    caption = "* Nine complete-exposure localities (288 quarters). Crosses mark unknown/incomplete exposure, not troop absence.\nAvailable = three numeric source months and map age at most five months. Source: audited Geo-PKO 2.3 lineage.")
freshness_plot <- base_plot + geom_tile(aes(fill = max_map_age), colour = "white", linewidth = .25) +
  geom_point(data = filter(chart_data, is.na(max_map_age)), shape = 4, size = 1.4, colour = "#555555") +
  scale_fill_gradient(low = "#E6EFF4", high = "#214F6B", na.value = "#EEEEEE", name = "Maximum map age (months)", breaks = 0:5) +
  labs(title = "Age of the source maps behind quarterly exposure", subtitle = "19 localities; 608 locality-quarters; 2016-2023",
    caption = "Maximum month-to-map age among listed rows in the preceding quarter; crosses indicate no mapped listing.\nA freshness value does not guarantee three-month strength coverage. Carried-forward rows are not new observations.\n* Complete-exposure sample. Source: audited Geo-PKO 2.3 deployment lineage.")
for (name in c("coverage", "freshness")) {
  chart <- if (name == "coverage") coverage_plot else freshness_plot
  for (extension in c("png", "pdf")) {
    ggsave(file.path(output_directory, paste0("quarterly_", name, ".", extension)),
      chart, width = 14, height = 8, units = "in", dpi = 160, bg = "white")
  }
}
print(chart_data |> count(coverage))
print(range(chart_data$max_map_age, na.rm = TRUE))
