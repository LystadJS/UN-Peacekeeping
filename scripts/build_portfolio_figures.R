# Final scientific figures for the research memo and discussion portfolio.
# No fitting occurs here. Selection and interpretation are fixed in the figure notes.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
directory <- "portfolio/figures"
private_directory <- "outputs/portfolio_figures"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
dir.create(private_directory, recursive = TRUE, showWarnings = FALSE)
blue <- "#326681"
orange <- "#AA6125"
figure_manifest <- data.frame()
theme_portfolio <- function(size = 10) {
  theme_minimal(base_size = size, base_family = "sans") +
    theme(plot.title = element_text(face = "bold", colour = "#111111"),
      plot.subtitle = element_text(colour = "#333333"),
      plot.caption = element_text(hjust = 0, size = size - 1, lineheight = 1.05),
      panel.grid.minor = element_blank(), panel.grid.major.x = element_line(colour = "#E4E4E4"),
      panel.grid.major.y = element_line(colour = "#E4E4E4"),
      strip.text = element_text(face = "bold"), legend.position = "top",
      plot.title.position = "plot", plot.caption.position = "plot",
      panel.spacing.x = grid::unit(.4, "cm"), plot.margin = margin(7, 8, 7, 8))
}
save_figure <- function(plot, name, width, height) {
  # ggsave's inferred PNG device changes when optional ragg is installed.
  # Use R's explicit Cairo renderer so unrelated optional packages cannot
  # silently change the portfolio typography in an isolated reproduction.
  ggsave(file.path(directory, paste0(name, ".png")), plot,
    width = width, height = height, dpi = 300, bg = "white",
    device = grDevices::png, type = "cairo-png")
  ggsave(file.path(directory, paste0(name, ".pdf")), plot,
    width = width, height = height, bg = "white", device = cairo_pdf)
  for (extension in c("png", "pdf")) {
    path <- file.path(directory, paste0(name, ".", extension))
    figure_manifest <<- bind_rows(figure_manifest, data.frame(file = path,
      width_inches = width, height_inches = height, format = extension,
      sha256 = digest::digest(readBin(path, "raw", n = file.info(path)$size),
                               algo = "sha256", serialize = FALSE)))
  }
}
quarter_date <- function(year, quarter) as.Date(sprintf("%04d-%02d-01", year, 3L * (quarter - 1L) + 1L))

# Trajectories show retrospective observed records and truly held-out predictions.
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds") |>
  mutate(date = quarter_date(year, quarter))
predictions <- read.csv("outputs/quarterly_prediction/predictions.csv") |>
  filter(model == "history") |> mutate(date = quarter_date(year, quarter))
stopifnot(nrow(panel) == 288L, nrow(predictions) == 180L,
  !anyDuplicated(predictions[c("locality_id", "test_index")]))
showcase_ids <- c("COMPOSITE_BENI", "COMPOSITE_IRUMU", "COD009007")
short_names <- c(COMPOSITE_BENI = "Beni", COMPOSITE_IRUMU = "Irumu", COD009007 = "Masisi")
lineage <- read.csv("outputs/week_1/audit_aggregated/deployment_lineage.csv")
deployment <- readRDS("data/raw/geo_pko/2.3/location_month.rds") |> ungroup()
lineage$strength <- as.numeric(lineage$no.troops) - as.numeric(deployment$fpu.no[lineage$source_row])
stocks <- lineage |> filter(locality_id %in% showcase_ids) |>
  mutate(date = as.Date(period)) |> filter(date >= as.Date("2016-01-01"), date <= as.Date("2023-12-01")) |>
  group_by(locality_id, date) |> summarise(value = sum(strength) / 1000,
    n_maps = n_distinct(map_date), source_age = max(map_age), .groups = "drop")
stopifnot(all(stocks$n_maps == 1L), all(is.finite(stocks$value)), all(stocks$value >= 0))
event_data <- panel |> filter(locality_id %in% showcase_ids) |>
  transmute(locality_id, date, value = recorded_events, measure = "Recorded events")
stock_data <- stocks |> mutate(measure = "Listed stock (1,000)")
combined <- bind_rows(event_data, stock_data) |>
  mutate(facet = paste(unname(short_names[locality_id]), measure, sep = " | "))
facet_levels <- unlist(lapply(short_names, function(name) paste(name,
  c("Recorded events", "Listed stock (1,000)"), sep = " | ")))
combined$facet <- factor(combined$facet, levels = facet_levels)
prediction_data <- predictions |> filter(locality_id %in% showcase_ids) |>
  mutate(facet = factor(paste(unname(short_names[locality_id]), "Recorded events", sep = " | "), levels = facet_levels))
write.csv(combined, file.path(private_directory, "trajectory_plot_data.csv"), row.names = FALSE)
write.csv(prediction_data, file.path(private_directory, "trajectory_prediction_data.csv"), row.names = FALSE)
time_scale <- scale_x_date(limits = as.Date(c("2016-01-01", "2023-12-01")),
  breaks = as.Date(c("2016-01-01", "2019-01-01", "2023-12-01")),
  labels = c("2016", "2019", "2023"), expand = expansion(mult = c(.02, .02)))
trajectory <- ggplot(combined, aes(date, value)) +
  geom_ribbon(data = prediction_data, aes(x = date, ymin = lower_95, ymax = upper_95),
    inherit.aes = FALSE, fill = blue, alpha = .18) +
  geom_line(data = filter(combined, measure == "Recorded events"), linewidth = .35, colour = "#222222") +
  geom_point(data = filter(combined, measure == "Recorded events"), size = .65, colour = "#222222") +
  geom_line(data = prediction_data, aes(date, predicted_mean), inherit.aes = FALSE,
    colour = blue, linewidth = .65) +
  geom_step(data = filter(combined, measure == "Listed stock (1,000)"), colour = orange, linewidth = .55) +
  geom_point(data = filter(combined, measure == "Listed stock (1,000)", source_age == 0), colour = orange, size = 1.3) +
  facet_wrap(~ facet, ncol = 2, scales = "free_y") + time_scale +
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, .08))) +
  labs(title = "Recorded violence and deployment observation timing",
    subtitle = "Three named examples from nine selected localities; independent panel scales",
    x = NULL, y = NULL,
    caption = "Black: recorded events. Blue: held-out history mean and 95% plug-in count interval (2019-2023).\nOrange: monthly listed stock; dots mark source-map months, steps include carry-forward.\nThe model uses prior-quarter mean strength. Beni/Irumu include their city composites; no causal contrast is shown.") + theme_portfolio(9.5)
save_figure(trajectory, "figure_1_trajectories", 7, 6.2)

all_trajectory <- ggplot(panel, aes(date, recorded_events)) +
  geom_ribbon(data = predictions, aes(x = date, ymin = lower_95, ymax = upper_95),
    inherit.aes = FALSE, fill = blue, alpha = .18) +
  geom_line(colour = "#222222", linewidth = .35) +
  geom_line(data = predictions, aes(date, predicted_mean), colour = blue, linewidth = .6) +
  facet_wrap(~ locality, ncol = 3, scales = "free_y", labeller = label_wrap_gen(24)) + time_scale +
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, .08))) +
  labs(title = "All nine selected locality trajectories", subtitle = "288 recorded quarters; 180 held-out forecasts; panel-specific count scales",
    x = NULL, y = "Recorded events", caption = "Black: recorded counts. Blue: history mean and conditional 95% plug-in count interval.\nRetrospective selected sample; parameter/random-effect estimation uncertainty and real-time release availability are not represented.") +
  theme_portfolio(9)
save_figure(all_trajectory, "figure_1_all_localities", 8, 6.5)

# Mean recovery and coefficient-interval coverage are intentionally distinguished.
simulation <- bind_rows(read.csv("data/dynamic_quarterly_simulation_summary.csv"),
  read.csv("data/dynamic_quarterly_null_summary.csv")) |> filter(estimator == "ordinary_history") |>
  mutate(truth = ifelse(scenario %in% c("null", "correlated_prehistory_null"), 0, -.3),
    mean_estimate = truth + bias, mc_lower = mean_estimate - qnorm(.975) * bias_mcse,
    mc_upper = mean_estimate + qnorm(.975) * bias_mcse,
    truth_group = ifelse(truth == 0, "Truth\n0", "Truth\n-0.30"))
scenario_names <- c(favorable = "Favorable", selection = "Deployment selection",
  differential_recording = "Differential recording", stationary_initial = "Correlated prehistory",
  null = "Zero-start null", correlated_prehistory_null = "Prehistory null")
simulation$label <- paste0(unname(scenario_names[simulation$scenario]),
  "  (", sprintf("%.1f", 100 * simulation$coverage), "% coverage)")
simulation$label <- factor(simulation$label, levels = rev(simulation$label[match(names(scenario_names), simulation$scenario)]))
simulation$truth_group <- factor(simulation$truth_group, levels = c("Truth\n-0.30", "Truth\n0"))
write.csv(simulation, file.path(directory, "figure_2_simulation_data.csv"), row.names = FALSE)
simulation_plot <- ggplot(simulation, aes(mean_estimate, label)) +
  geom_vline(data = distinct(simulation, truth_group, truth), aes(xintercept = truth), colour = "#555555", linetype = 2) +
  geom_errorbar(aes(xmin = mc_lower, xmax = mc_upper), orientation = "y", width = .15, colour = blue) +
  geom_point(size = 2, colour = blue) + facet_grid(truth_group ~ ., scales = "free_y", space = "free_y") +
  scale_x_continuous(limits = c(-.45, .16), breaks = c(-.4, -.3, -.2, -.1, 0, .1)) +
  labs(title = "Average recovery under known simulation conditions", subtitle = "Ordinary history model; 200 replications per scenario",
    x = "Mean estimated log count coefficient per 1,000 personnel", y = NULL,
    caption = "Bars: 95% Monte Carlo intervals for mean estimates. Labels: coefficient-interval coverage.\nDashed lines mark known synthetic truth. These are simulation results, not empirical protection effects.") + theme_portfolio(10) +
    theme(strip.text.y = element_text(angle = 0))
save_figure(simulation_plot, "figure_2_simulation_recovery", 7, 4.2)
simulation_memo <- simulation_plot + labs(title = NULL, subtitle = NULL,
  x = "Mean estimated coefficient", caption = "Bars: 95% Monte Carlo intervals for means; labels: coefficient-interval coverage.\n200 replications per scenario. Dashed lines: known truth. Synthetic outcomes only.") +
  theme_portfolio(9.5) + theme(strip.text.y = element_text(size = 8.5, angle = 0))
save_figure(simulation_memo, "figure_2_simulation_recovery_memo", 6.5, 2.8)

reporting <- read.csv("data/quarterly_sensitivity_reporting_curve.csv")
write.csv(reporting, file.path(directory, "figure_3_reporting_data.csv"), row.names = FALSE)
reporting_plot <- ggplot(reporting, aes(relative_recording_per_1000, estimate)) +
  geom_ribbon(aes(ymin = lower_95, ymax = upper_95), fill = blue, alpha = .18) +
  geom_line(colour = blue, linewidth = .8) + geom_hline(yintercept = 0, linetype = 2, colour = "#555555") +
  geom_vline(xintercept = 1, colour = "#888888", linetype = 3) +
  scale_x_log10(breaks = c(.25, .5, 1, 2, 4)) +
  labs(title = "Reporting assumptions and the inferred association",
    subtitle = "Nine localities; 288 quarters; exact log-linear offset sensitivity",
    x = "Assumed recording-probability ratio per 1,000 additional personnel",
    y = "Conditional log count coefficient",
    caption = "Band: 95% coefficient interval conditional on each assumed recording ratio.\nThe shift is algebraic; recording is not estimated and confounding remains.") + theme_portfolio(10)
save_figure(reporting_plot, "figure_3_reporting_sensitivity", 7, 4.2)
reporting_memo <- reporting_plot + labs(title = NULL, subtitle = NULL,
  x = "Assumed recording-probability ratio per 1,000 personnel",
  y = "Conditional coefficient",
  caption = "Band: conditional 95% coefficient interval. Curve movement reflects assumptions, not estimated reporting.\nThe algebraic shift does not address deployment confounding.") + theme_portfolio(9.5)
save_figure(reporting_memo, "figure_3_reporting_sensitivity_memo", 6.5, 2.8)

specification_names <- c(primary = "Primary quarterly (n=288)", age_three = "Map age at most 3 months (n=252)",
  early_map_switch = "Early map switch (n=288)", midpoint_map_switch = "Midpoint switch (n=288)",
  location_precision_1_or_2 = "Location precision 1 or 2 (n=288)")
specifications <- read.csv("data/quarterly_sensitivity_specifications.csv") |>
  filter(scenario %in% names(specification_names)) |>
  mutate(label = factor(unname(specification_names[scenario]), levels = rev(unname(specification_names))))
write.csv(specifications, file.path(directory, "figure_4_empirical_data.csv"), row.names = FALSE)
empirical_plot <- ggplot(specifications, aes(estimate, label)) +
  geom_vline(xintercept = 0, linetype = 2, colour = "#555555") +
  geom_errorbar(aes(xmin = lower_95, xmax = upper_95), orientation = "y", width = .15, colour = blue) +
  geom_point(size = 2.3, colour = blue) +
  labs(title = "The common association remains imprecise", subtitle = "Actual quarterly event-count fits under five measurement assumptions",
    x = "Log count coefficient per 1,000 listed military personnel", y = NULL,
    caption = "Points and model-based 95% Wald intervals. No locality-specific deployment slopes were fitted.\nTiming alternatives use later maps retrospectively; the three-month rule changes the sample.") + theme_portfolio(10)
save_figure(empirical_plot, "figure_4_empirical_sensitivity", 7, 3.6)

locality_scores <- read.csv("data/quarterly_prediction_localities.csv") |> arrange(locality)
locality_scores$locality <- factor(locality_scores$locality, levels = rev(locality_scores$locality))
write.csv(locality_scores, file.path(directory, "figure_5_prediction_data.csv"), row.names = FALSE)
overall <- read.csv("data/quarterly_prediction_comparison.csv")$mean_log_score_difference
prediction_plot <- ggplot(locality_scores, aes(mean_log_score_difference, locality)) +
  geom_vline(xintercept = 0, colour = "#555555") +
  geom_vline(xintercept = overall, linetype = 2, colour = orange) +
  geom_segment(aes(x = 0, xend = mean_log_score_difference, yend = locality), colour = blue, linewidth = .7) +
  geom_point(colour = blue, size = 2.3) +
  labs(title = "Predictive gains are concentrated across localities",
    subtitle = "20 held-out quarters per locality; alphabetical order",
    x = "Mean log score: history minus baseline", y = NULL,
    caption = "Positive values favor history. Dashed line: overall +0.0429; omitting Irumu scores gives -0.0147.\nDescriptive score aggregation, not refitting or protection ranking. Retrospective plug-in forecasts only.") + theme_portfolio(10)
save_figure(prediction_plot, "figure_5_prediction_comparison", 7, 4.5)
capture.output(sessionInfo(), file = file.path(private_directory, "session_info.txt"))
stopifnot(nrow(figure_manifest) == 16L, !anyDuplicated(figure_manifest$file))
write.csv(figure_manifest, file.path(directory, "figure_manifest.csv"), row.names = FALSE)
cat("Final portfolio figures and aggregate chart data exported. No models refitted.\n")
