source("R/libraries.R")
source("R/support.R")
source("R/panel.R")
source("R/association.R")
source("R/forecast.R")

result_dir <- Sys.getenv("MONUSCO_MONTHLY_RESULTS", "results")
panel <- read_csv_local(file.path(result_dir, "territory_month_panel.csv"))
stopifnot(!anyDuplicated(panel[c("territory_id", "month")]),
          nrow(panel) == n_distinct(panel$territory_id) * length(study_months),
          all(is.na(panel$presence[panel$month > deployment_end])),
          all(panel$coverage_confirmed[panel$presence %in% 0L] %in% TRUE),
          all(panel$map_key[panel$presence %in% 0L] == panel$coverage_map[panel$presence %in% 0L]))
gap <- filter(panel, territory_id == first(territory_id), month %in% study_months[c(1, 3, 4)])
relagged <- add_lags(gap)
stopifnot(all(is.na(relagged$ucdp_incidents_lag[1:2])),
          relagged$ucdp_incidents_lag[3] == relagged$ucdp_incidents[2])
point_scores <- count_scores(3L, 2, Inf)
stopifnot(isTRUE(all.equal(point_scores[1], -dpois(3L, 2, log = TRUE))),
          point_scores[5] <= point_scores[3], point_scores[4] <= point_scores[6])
stopifnot(identical(count_scores(3L, 0, Inf), rep(NA_real_, 6)))

# Exercise both likelihoods with positive/zero exposure in a synthetic panel.
set.seed(932L)
example_panel <- panel |>
  filter(month < as.Date("2019-01-01")) |>
  mutate(season = factor(lubridate::month(month), levels = 1:12),
         territory_effect = as.integer(factor(territory_id)) / 20,
         presence = rbinom(n(), 1L, .5),
         troop_strength = 150 * presence + 25 * rbinom(n(), 1L, .5),
         map_age = 1L,
         map_key = paste0("fixture-", quarter(month, with_year = TRUE)),
         incidents = rnbinom(n(), mu = exp(.5 + territory_effect - .3 * presence), size = 1.8),
         battles = rpois(n(), 2),
         ucdp_incidents = rpois(n(), 1),
         narrow_incidents = rbinom(n(), incidents, .7),
         exact_incidents = rbinom(n(), incidents, .85),
         population = 100000 * exp(territory_effect), log_population = log(population)) |>
  add_lags()
origin <- as.Date("2018-03-01")
initial_predictions <- suppressWarnings(forecast_origin(example_panel, origin))
changed <- mutate(example_panel, incidents = if_else(month > origin, incidents + 1000, incidents))
future_predictions <- suppressWarnings(forecast_origin(changed, origin))
stopifnot(identical(initial_predictions, future_predictions),
          sum(initial_predictions$fit_status == "ok") > 3L * n_distinct(example_panel$territory_id),
          all(score_forecasts(initial_predictions)$log_score[initial_predictions$fit_status == "ok"] >= 0))
model_data <- association_sample(example_panel, "incidents", "presence_lag")
fit <- fit_association(model_data, glmmTMB::nbinom2(), TRUE)
poisson_fit <- fit_association(model_data, poisson(), TRUE)
estimate <- association_result(fit, model_data, "fixture", "negative binomial")
stopifnot(is.finite(estimate$rate_ratio), estimate$lower_95 < estimate$upper_95,
          is.finite(association_result(poisson_fit, model_data, "fixture", "Poisson")$rate_ratio))
cat("Passed panel, gap, count scoring, future-invariance, and mixed-model checks.\n")
