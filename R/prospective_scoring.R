# Pure scoring functions for the frozen 2027 Q1 research forecast.
# No refitting, threshold updates, data acquisition, or file writes occur here.
validate_future_outcomes <- function(outcomes, forecasts) {
  required <- c("locality_id", "target_quarter", "recorded_events", "coverage_complete")
  if (!all(required %in% names(outcomes))) stop("Missing required outcome columns")
  if (nrow(outcomes) != 19L || anyDuplicated(outcomes$locality_id) ||
      !setequal(outcomes$locality_id, forecasts$locality_id))
    stop("Outcome panel must contain exactly the frozen 19 localities")
  if (anyNA(outcomes[required])) stop("Unknown outcomes or coverage cannot become zero")
  if (!is.logical(outcomes$coverage_complete) || !all(outcomes$coverage_complete))
    stop("All rows require documented complete release coverage")
  if (!all(outcomes$target_quarter == "2027 Q1")) stop("Wrong target quarter")
  y <- outcomes$recorded_events
  if (!is.numeric(y) || any(!is.finite(y) | y < 0 | y != floor(y)))
    stop("Counts must be finite nonnegative integers")
  invisible(TRUE)
}

validate_release_metadata <- function(meta, today = Sys.Date()) {
  required <- c("stage", "release_id", "release_date", "coverage_start", "coverage_end",
                "source_url", "eligibility_audit_path", "release_selection_note")
  if (nrow(meta) != 1L || !all(required %in% names(meta)) ||
      anyNA(meta[required]) || any(trimws(unlist(meta[required])) == ""))
    stop("One complete release provenance record is required")
  if (!meta$stage %in% c("preliminary", "final")) stop("Invalid release stage")
  dates <- as.Date(c(meta$release_date, meta$coverage_start, meta$coverage_end))
  if (anyNA(dates)) stop("Invalid release dates")
  if (today <= as.Date("2027-03-31") || dates[1] > today ||
      dates[1] <= as.Date("2027-03-31") || dates[3] > dates[1] ||
      dates[2] > as.Date("2027-01-01") || dates[3] < as.Date("2027-03-31"))
    stop("Target period or declared release coverage is incomplete/unavailable")
  if (!grepl("^https://", meta$source_url)) stop("Public release evidence URL required")
  # This checks declared metadata, NOT its truth or first-release priority.
  # The linked eligibility audit and publisher evidence must be reviewed.
  invisible(TRUE)
}

score_frozen_counts <- function(outcomes, forecasts, benchmark) {
  validate_future_outcomes(outcomes, forecasts)
  rows <- forecasts[match(outcomes$locality_id, forecasts$locality_id), ]
  rows$y <- outcomes$recorded_events
  rows$surge <- as.integer(rows$y >= rows$surge_threshold)
  rows$nb_brier <- (rows$nb_surge_probability - rows$surge)^2
  rows$benchmark_brier <- (rows$benchmark_surge_probability - rows$surge)^2
  rows$nb_squared_error <- (rows$nb_mean - rows$y)^2
  rows$benchmark_squared_error <- (rows$benchmark_mean - rows$y)^2
  rows$nb_log_loss <- -dnbinom(rows$y, mu = rows$nb_mean, size = rows$nb_size, log = TRUE)
  rows$nb_covered <- rows$y >= rows$nb_lower90 & rows$y <= rows$nb_upper90
  rows$nb_crps <- rows$benchmark_crps <- numeric(nrow(rows))
  for (i in seq_len(nrow(rows))) {
    b <- benchmark[benchmark$locality_id == rows$locality_id[i], ]
    b <- b[order(b$count), ]
    stopifnot(nrow(b) > 0, !anyDuplicated(b$count), all(b$probability >= 0),
              abs(sum(b$probability) - 1) < 1e-10)
    cap <- as.integer(max(rows$y[i], b$count,
                         qnbinom(1-1e-10, mu = rows$nb_mean[i], size = rows$nb_size[i])))
    grid <- 0:cap
    truth <- as.numeric(grid >= rows$y[i])
    nb_cdf <- pnbinom(grid, mu = rows$nb_mean[i], size = rows$nb_size[i])
    masses <- numeric(length(grid)); masses[b$count + 1L] <- b$probability
    rows$nb_crps[i] <- sum((nb_cdf - truth)^2)
    rows$benchmark_crps[i] <- sum((cumsum(masses) - truth)^2)
    extended <- 0:(2L * cap)
    check <- sum((pnbinom(extended, mu=rows$nb_mean[i], size=rows$nb_size[i]) -
                    as.numeric(extended >= rows$y[i]))^2)
    stopifnot(abs(check - rows$nb_crps[i]) < 1e-8)
  }
  summary <- data.frame(
    n = nrow(rows), surges = sum(rows$surge), observed_rate = mean(rows$surge),
    nb_mean_risk = mean(rows$nb_surge_probability),
    benchmark_mean_risk = mean(rows$benchmark_surge_probability),
    nb_brier = mean(rows$nb_brier), benchmark_brier = mean(rows$benchmark_brier),
    paired_brier_difference = mean(rows$nb_brier - rows$benchmark_brier),
    nb_crps = mean(rows$nb_crps), benchmark_crps = mean(rows$benchmark_crps),
    nb_mse = mean(rows$nb_squared_error), benchmark_mse = mean(rows$benchmark_squared_error),
    nb_log_loss = mean(rows$nb_log_loss), nb_coverage90 = mean(rows$nb_covered),
    nb_mean_interval_width = mean(rows$nb_upper90 - rows$nb_lower90))
  list(rows = rows, summary = summary)
}
