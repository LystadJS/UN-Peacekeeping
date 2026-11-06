# Inspect saved variance estimates only; no additional model fitting is performed.
.libPaths(c(".local_library", .libPaths()))
library(glmmTMB)
full_paths <- file.path("outputs/quarterly_pilot/empirical", c("baseline_model.rds", "history_model.rds"))
deletion_paths <- list.files("outputs/quarterly_diagnostics", pattern = "^influence_.*[.]rds$", full.names = TRUE)
stopifnot(length(deletion_paths) == 34L, all(file.exists(full_paths)))
paths <- c(full_paths, deletion_paths)
records <- lapply(paths, function(path) {
  model <- readRDS(path)
  coefficients <- summary(model)$coefficients$cond
  random_intercept_sd <- unname(attr(VarCorr(model)$cond$locality_id, "stddev")[1])
  data.frame(artifact = basename(path), scope = ifelse(grepl("^influence_", basename(path)), "deletion", "full"),
    model = ifelse(grepl("baseline", basename(path)), "baseline", "history"),
    random_intercept_sd = random_intercept_sd,
    near_zero_random_intercept = is.finite(random_intercept_sd) && random_intercept_sd < 1e-4,
    nb2_dispersion = as.numeric(sigma(model)), convergence = model$fit$convergence,
    positive_hessian = isTRUE(model$sdr$pdHess),
    finite_coefficients_and_se = all(is.finite(coefficients[, 1:2])),
    positive_standard_errors = all(coefficients[, 2] > 0),
    observations = nobs(model))
})
results <- do.call(rbind, records)
stopifnot(nrow(results) == 36L, all(is.finite(results$random_intercept_sd)),
  all(is.finite(results$nb2_dispersion)), all(results$nb2_dispersion > 0))
write.csv(results, "data/quarterly_diagnostic_variance.csv", row.names = FALSE)
print(results[results$scope == "full", ])
print(aggregate(cbind(random_intercept_sd, nb2_dispersion) ~ model + scope, results, range))
cat("Near-zero random-intercept estimates:", sum(results$near_zero_random_intercept), "of", nrow(results), "\n")
cat("Positive Hessians:", sum(results$positive_hessian), "of", nrow(results), "\n")
