# Inspect predictor geometry only; never fit an outcome model or interpret effects.
.libPaths(c(".local_library", .libPaths()))
library(dplyr)
panel <- readRDS("outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds")
initial <- read.csv("outputs/quarterly_pilot/panel/initial_conditions_2015_q4.csv")
panel <- panel |> left_join(initial, by = "locality_id", relationship = "many-to-one") |>
  arrange(locality_id, time_index) |> group_by(locality_id) |>
  mutate(lag2_within = strength_lag2 - mean(strength_lag2)) |> ungroup()
stopifnot(nrow(panel) == 288L, all(panel$history_complete))
locality_diagnostics <- panel |> group_by(locality_id, locality) |>
  summarise(quarters = n(), distinct_lag1 = n_distinct(round(strength_lag, 10)),
    transitions_lag1 = sum(abs(diff(strength_lag)) > 1e-10),
    sd_lag1 = sd(strength_lag), distinct_lag2 = n_distinct(round(strength_lag2, 10)),
    transitions_lag2 = sum(abs(diff(strength_lag2)) > 1e-10),
    sd_lag2 = sd(strength_lag2), .groups = "drop")
# Fixed-effect columns reproduce the proposed dynamic model, without fitting it.
# Scale nonconstant numeric predictors before model.matrix; retain categorical
# contrasts. The condition number consequently depends on this stated coding.
numeric_predictors <- c("strength_within", "strength_between", "time_index",
  "log1p_events_lag", "violent_spell_lag", "strength_lag2", "initial_log_events", "initial_spell")
panel$initial_log_events <- log1p(panel$initial_recorded_events)
scaled_panel <- panel
for (variable in numeric_predictors) {
  if (sd(panel[[variable]]) > 0) scaled_panel[[variable]] <- as.numeric(scale(panel[[variable]]))
}
base_formula <- ~ strength_within + strength_between + time_index + season + province +
  log1p_events_lag + violent_spell_lag + strength_lag2
design_summary <- function(formula, label) {
  design <- model.matrix(formula, scaled_panel)
  singular_values <- svd(design, nu = 0, nv = 0)$d
  rank <- qr(design)$rank
  data.frame(design = label, rows = nrow(design), columns = ncol(design), rank = rank,
    condition_number = if (rank < ncol(design)) Inf else max(singular_values) / min(singular_values))
}
geometry <- bind_rows(design_summary(base_formula, "ordinary_history"),
  design_summary(update(base_formula, ~ . + initial_log_events + initial_spell), "initial_adjusted"))
correlation <- cor(panel$strength_within, panel$lag2_within)
dir.create("outputs/quarterly_pilot/design", showWarnings = FALSE)
write.csv(locality_diagnostics, "outputs/quarterly_pilot/design/locality_strength_variation.csv", row.names = FALSE)
write.csv(geometry, "outputs/quarterly_pilot/design/fixed_design_geometry.csv", row.names = FALSE)
write.csv(data.frame(within_lag1_lag2_correlation = correlation),
  "outputs/quarterly_pilot/design/lag_correlation.csv", row.names = FALSE)
print(locality_diagnostics, width = Inf)
print(geometry)
print(correlation)
