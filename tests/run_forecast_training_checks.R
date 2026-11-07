# Independent checks of archived event histories and their availability masks.
# Run-length encoding verifies spells independently of the builder's recursion.
.libPaths(c(".local_library", .libPaths()))
grid <- read.csv("outputs/forecast_training/training_history_grid.csv")
stopifnot(nrow(grid) == 760L, !anyDuplicated(grid[c("locality_id", "source_quarter")]),
  sum(grid$complete_occurrence_quarter) == 722L)
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-10, check.attributes = FALSE))
for (id in unique(grid$locality_id)) {
  rows <- grid[grid$locality_id == id, ]
  rows <- rows[order(rows$source_quarter), ]
  stopifnot(nrow(rows) == 40L, all(diff(rows$source_quarter) == 1L))
  observed <- rows$recorded_events[rows$complete_occurrence_quarter]
  runs <- rle(observed > 0)
  run_spells <- unlist(Map(function(positive, length) {
    if (positive) seq_len(length) else rep(0L, length)
  }, runs$values, runs$lengths), use.names = FALSE)
  run_censored <- rep(FALSE, length(observed))
  if (runs$values[1]) run_censored[seq_len(runs$lengths[1])] <- TRUE
  spells <- c(run_spells, NA_integer_, NA_integer_)
  censored <- c(run_censored, NA, NA)
  lag_counts <- c(NA, head(rows$recorded_events, -1))
  lag_spells <- c(NA, head(spells, -1))
  lag_censored <- c(NA, head(censored, -1))
  stopifnot(same(rows$events_lag, lag_counts),
    same(rows$log1p_events_lag, log1p(lag_counts)),
    same(rows$violent_spell_lag_observed, lag_spells),
    same(rows$violent_spell_left_censored, lag_censored),
    same(rows$violent_spell_lag, ifelse(lag_censored, NA, lag_spells)))
}
stopifnot(all(is.na(grid$recorded_events[grid$year == 2023 & grid$quarter >= 3])),
  all(is.na(grid$events_lag[grid$year == 2023 & grid$quarter == 4])))
comparison <- read.csv("outputs/forecast_training/training_history_comparison.csv")
stopifnot(nrow(comparison) == 570L, sum(comparison$current_core) == 270L,
  all(comparison$source_quarter <= 2023L * 4L + 1L))

# The partial window must agree with the earlier, independent release comparison.
available <- read.csv("data/forecast_training_availability.csv")
origin <- read.csv("data/forecast_origin_event_comparison.csv")
for (window in c("july_only", "july_august")) {
  partial <- origin[origin$window == window, ]
  field <- if (window == "july_only") "july_partial_events" else "july_august_partial_events"
  stopifnot(same(available[[field]], partial$archived_events[match(available$locality_id, partial$locality_id)]))
}
stopifnot(all(is.na(available$q3_full_events)), all(is.na(available$origin_q4_events_lag)),
  all(is.na(available$origin_q4_violent_spell_lag)))
inputs <- read.csv("data/forecast_training_inputs.csv")
evidence <- read.csv("data/forecast_origin_release_followup.csv")
evidence <- evidence[!duplicated(evidence$local_path), ]
files <- rbind(inputs[c("path", "bytes", "sha256")],
  data.frame(path = evidence$local_path, bytes = evidence$bytes, sha256 = evidence$sha256))
stopifnot(nrow(inputs) == 10L, nrow(evidence) == 7L)
for (i in seq_len(nrow(files))) {
  stopifnot(file.info(files$path[i])$size == files$bytes[i],
    digest::digest(readBin(files$path[i], "raw", n = files$bytes[i]),
      algo = "sha256", serialize = FALSE) == files$sha256[i])
}
html <- paste(readLines("outputs/forecast_origin/release_followup/ucdp_downloads_20230930.html", warn=FALSE), collapse="\n")
stopifnot(grepl("August 2023: Version 23.0.8", html, fixed=TRUE),
  grepl("candidateged/GEDEvent_v23_0_8.csv", html, fixed=TRUE))
headers <- jsonlite::fromJSON("outputs/forecast_origin/release_followup/wayback_capture_headers.json")
stopifnot(headers$memento_datetime == "Sat, 30 Sep 2023 03:04:00 GMT",
  grepl("20230930030400", headers$final_url, fixed=TRUE))
source("scripts/record_analysis_snapshot.R")
coding_sources <- read.csv("data/forecast_origin_coding_sources.csv")
for (i in seq_len(nrow(coding_sources))) {
  bytes <- readBin(coding_sources$path[i], "raw", n = file.info(coding_sources$path[i])$size)
  stopifnot(digest::digest(bytes, algo = "sha256", serialize = FALSE) == coding_sources$sha256[i])
  if (!is.na(coding_sources$git_blob[i]) && nzchar(coding_sources$git_blob[i])) {
    git_bytes <- c(charToRaw(paste0("blob ", length(bytes))), as.raw(0), bytes)
    stopifnot(digest::digest(git_bytes, algo = "sha1", serialize = FALSE) == coding_sources$git_blob[i])
  }
}
deployment <- read.csv("outputs/forecast_origin/coding/historical_training_strength.csv")
known <- !is.na(deployment$archived_strength_lag)
stopifnot(nrow(deployment) == 589L, sum(known) == 164L,
  same(deployment$archived_strength_lag[known], deployment$strength_lag[known]),
  all(is.na(deployment$archived_strength_lag[deployment$source_quarter > 2020L * 4L])))
revisions <- read.csv("data/forecast_origin_coding_revision_ledger.csv")
stopifnot(!anyDuplicated(revisions$map_date[revisions$selected]))
for (date in unique(revisions$map_date)) {
  rows <- revisions[revisions$map_date == date, ]
  stopifnot(sum(rows$selected) == 1L, rows$revision[rows$selected] == max(rows$revision))
}
joint <- read.csv("outputs/forecast_training/joint_training_history.csv")
stopifnot(nrow(joint) == 570L, sum(joint$jointly_populated) == 162L,
  sum(joint$jointly_populated & joint$current_core) == 153L,
  all(joint$jointly_populated == complete.cases(joint[c("recorded_events", "events_lag",
    "violent_spell_lag", "archived_strength_lag", "archived_strength_lag2")])))
cat("Histories, partial masks, 19 hashes, Git blob, map revisions and joint coverage verified.\n")
