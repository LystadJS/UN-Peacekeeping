# Generate synthetic data with known structural effects. No empirical input is used.
simulate_panel <- function(seed = 1L, n_localities = 40L, n_months = 60L,
                           burn_in = 24L, selection = FALSE,
                           differential_recording = FALSE,
                           heterogeneity = FALSE) {
  stopifnot(n_localities >= 4L, n_months >= 3L, burn_in >= 2L)
  set.seed(seed)
  total_months <- n_months + burn_in
  locality_risk <- rnorm(n_localities, 0, 0.6)
  true_mean_slope <- -0.4
  true_slope_sd <- if (heterogeneity) 0.3 else 0
  local_slopes <- rnorm(n_localities, true_mean_slope, true_slope_sd)
  prior_events <- integer(n_localities)
  prior_presence <- integer(n_localities)
  prior_spell <- integer(n_localities)
  rows <- vector("list", total_months)

  for (month_index in seq_len(total_months)) {
    # Presence represents deployment during the preceding month, selected using
    # information from that month. Persistence generates realistic limited switches.
    selection_term <- if (selection) {
      0.6 * log1p(prior_events) + 0.4 * locality_risk
    } else {
      rep(0, n_localities)
    }
    presence <- rbinom(n_localities, 1, plogis(-1 + prior_presence + selection_term))
    seasonal_term <- 0.15 * sin(2 * pi * month_index / 12)
    true_mean <- exp(0.2 + locality_risk + seasonal_term +
                       local_slopes * presence + 0.2 * log1p(prior_events))
    true_events <- rnbinom(n_localities, mu = true_mean, size = 2)

    # Thinning changes the observed count, never the structural event generator.
    recording_probability <- if (differential_recording) {
      plogis(qlogis(0.65) + 0.8 * presence - 0.5 * locality_risk)
    } else {
      rep(0.65, n_localities)
    }
    recorded_events <- rbinom(n_localities, true_events, recording_probability)
    rows[[month_index]] <- data.frame(
      locality_id = sprintf("synthetic_%03d", seq_len(n_localities)),
      province_id = paste0("province_", (seq_len(n_localities) - 1L) %% 4L + 1L),
      month_index = month_index - burn_in,
      recorded_events = recorded_events,
      true_events = true_events,
      presence_lag = presence,
      presence_lag2 = prior_presence,
      events_lag = prior_events,
      violent_spell_lag = prior_spell,
      recording_probability = recording_probability,
      latent_risk = locality_risk,
      true_local_slope = local_slopes
    )
    prior_spell <- ifelse(recorded_events > 0, prior_spell + 1L, 0L)
    prior_events <- recorded_events
    prior_presence <- presence
  }

  panel <- dplyr::bind_rows(rows) |>
    dplyr::filter(month_index > 0) |>
    dplyr::group_by(locality_id) |>
    dplyr::mutate(
      # Full-period means are for descriptive fits only; recompute within each
      # training window before evaluating predictions on held-out observations.
      presence_between = mean(presence_lag),
      presence_within = presence_lag - presence_between,
      month_of_year = factor((month_index - 1L) %% 12L + 1L)
    ) |>
    dplyr::ungroup()

  list(panel = panel, truth = list(
    population_mean_slope = true_mean_slope,
    population_slope_sd = true_slope_sd,
    realized_mean_slope = mean(local_slopes),
    realized_slope_sd = sd(local_slopes),
    seed = seed, selection = selection,
    differential_recording = differential_recording,
    heterogeneity = heterogeneity
  ))
}
