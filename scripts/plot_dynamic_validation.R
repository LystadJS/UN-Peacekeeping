# Plot only final, complete 200-replication summaries. No simulation or fits here.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
paths <- c("data/dynamic_quarterly_simulation_summary.csv",
           "data/dynamic_quarterly_null_summary.csv")
if (!all(file.exists(paths))) stop("Final dynamic summaries are not available; do not plot partial runs.")
results <- bind_rows(lapply(paths, read.csv))
expected <- c("favorable", "null", "selection", "differential_recording", "stationary_initial", "correlated_prehistory_null")
stopifnot(nrow(results) == 7L, all(results$attempts == 200L),
  !anyDuplicated(results[c("scenario", "estimator")]),
  setequal(results$scenario, expected), all(results$n_usable > 0 & results$n_usable <= 200),
  all(abs(results$fit_rate - results$n_usable / results$attempts) < 1e-10))
labels <- c(favorable = "Fixed exposure; zero initial history",
  null = "Zero-effect null; zero initial history",
  selection = "Deployment responds to prior risk",
  differential_recording = "Deployment/risk-dependent recording",
  stationary_initial = "Correlated prehistory; negative effect",
  correlated_prehistory_null = "Correlated prehistory; zero-effect null")
results <- results |> arrange(match(scenario, expected), estimator) |>
  mutate(row_label = paste0(unname(labels[scenario]),
    ifelse(estimator == "initial_adjusted", " [initial-adjusted diagnostic]", " [ordinary]"),
    "\nUsable fits: ", n_usable, "/", attempts, " (", sprintf("%.1f", 100 * fit_rate), "%)"),
    row_label = factor(row_label, levels = rev(row_label)))
chart_data <- results |> pivot_longer(c(coverage, directional_error), names_to = "measure", values_to = "rate")
# Wilson Monte Carlo intervals describe binomial simulation variability among
# usable fits. Unlike plug-in normal intervals they remain informative at zero.
z <- qnorm(.975)
chart_data <- chart_data |> mutate(
  center = (rate + z^2 / (2 * n_usable)) / (1 + z^2 / n_usable),
  half_width = z * sqrt(rate * (1 - rate) / n_usable + z^2 / (4 * n_usable^2)) /
    (1 + z^2 / n_usable), lower = center - half_width, upper = center + half_width,
  measure = factor(measure, levels = c("coverage", "directional_error"),
    labels = c("95% coefficient-interval coverage", "Confidently incorrect direction")))
chart <- ggplot(chart_data, aes(rate, row_label)) +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = .18,
    colour = "#326681", linewidth = .6) +
  geom_point(aes(shape = estimator), size = 2.7, colour = "#214F6B") +
  facet_wrap(~ measure, nrow = 1) +
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, .2), labels = function(x) paste0(100*x, "%")) +
  scale_shape_manual(values = c(ordinary_history = 16, initial_adjusted = 1), guide = "none") +
  labs(title = "Dynamic common-slope simulation: interval performance",
    subtitle = "200 replications per scenario-estimator; point rates and 95% Wilson Monte Carlo intervals",
    x = "Fraction among usable fits", y = NULL,
    caption = "Coverage targets the known structural deployment coefficient; negative-effect scenarios count confidently positive estimates as wrong.\nNull scenarios count either confidently positive or negative estimates as wrong. These error definitions differ.\nFit failures remain in the displayed 200-attempt denominators but are excluded from coverage/error fractions.\nThe initial-adjusted estimator is a diagnostic, not the proposed empirical specification. Simulation results do not establish causal identification.") +
  theme_minimal(base_size = 11) + theme(panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(), plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"), plot.caption = element_text(hjust = 0),
    plot.margin = margin(12, 15, 12, 12))
output_directory <- "outputs/dynamic_quarterly"
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
write.csv(chart_data, file.path(output_directory, "validation_figure_data.csv"), row.names = FALSE)
for (extension in c("png", "pdf")) {
  ggsave(file.path(output_directory, paste0("dynamic_interval_performance.", extension)),
    chart, width = 15, height = 8, dpi = 160, bg = "white")
}
