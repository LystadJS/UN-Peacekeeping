# Reproduce the quarterly pilot

For a clean end-to-end run from retained originals, use the [clean rebuild runbook](clean_rebuild_runbook.md). The commands below describe individual stages; the isolated workflow has now been executed and independently compared.

Run R from the repository root with the acquired, hashed original inputs still in the ignored `data/raw/` directory. Source acquisition and the original geographic audit must already be complete; see the Week 1 runbook. Package versions are recorded in the pilot and dynamic run metadata. Installed packages and raw data are not distributed in Git.

## Panel and descriptive measurement audit

```r
source("scripts/build_quarterly_exposure.R")
source("tests/run_quarterly_checks.R")
source("scripts/build_quarterly_panel.R")
source("tests/run_quarterly_panel_checks.R")
source("scripts/audit_quarterly_freshness.R")
source("scripts/plot_quarterly_coverage.R")
source("scripts/audit_quarterly_design.R")
source("scripts/record_quarterly_panel_manifest.R")
```

The panel builder preserves the original 19-locality grid and separately exports the nine-locality complete-exposure sample. The manifest records an audited snapshot, not a frozen empirical model. Read the quarterly dictionary alongside the older monthly source dictionary.

## Simulation validation

The previously completed core experiment is reproducible with `scripts/validate_quarterly_simulation.R`; independently check its saved records with `scripts/recheck_simulation_summary.R`. Re-running fitting is unnecessary merely to inspect existing results.

The history experiment and its separately specified initial-condition null extension are:

```r
source("tests/run_dynamic_quarterly_checks.R")
source("scripts/validate_dynamic_quarterly.R")
source("scripts/check_dynamic_generated_data.R")
source("scripts/validate_dynamic_quarterly_null.R")
source("scripts/summarize_dynamic_quarterly.R")
source("scripts/update_quarterly_validation_status.R")
source("scripts/plot_dynamic_validation.R")
```

These fit synthetic outcomes only. They retain failures and warnings in local per-fit records. The original history experiment has 1,200 fit attempts; the matched null extension adds 200. Seeds and generator parameters reconstruct the datasets. The initial-adjusted estimator is diagnostic and cannot substitute for a failed ordinary-model gate without its own validation.

The status updater checks all required ordinary-model scenarios and never automatically enables empirical fitting. A changed estimator, eligibility rule, or history treatment requires a documented protocol change and matching validation. Predictive evaluation additionally requires training-only exposure centering and an explicit treatment of retrospective event-reporting availability.

The bounded empirical protocol and its measurement decision were subsequently recorded in `docs/empirical_quarterly_protocol.md`. With both readiness flags explicitly true, run `scripts/fit_quarterly_empirical.R`, then `scripts/summarize_quarterly_empirical.R`. Refreshing validation deliberately closes readiness again; it preserves the historical fitted-model flag and requires the measurement decision to be reaffirmed before another empirical run.

## Residual, sensitivity, and predictive evaluation

Read `docs/quarterly_evaluation_scope.md` and the three follow-up protocols. With the audited panel and saved primary models available, run:

```r
source("scripts/record_evaluation_inputs.R")
source("scripts/diagnose_quarterly_models.R")
source("tests/run_quarterly_diagnostic_checks.R")
source("scripts/summarize_quarterly_variance.R")
source("scripts/analyze_quarterly_sensitivity.R")
source("tests/run_quarterly_sensitivity_checks.R")
source("scripts/validate_quarterly_prediction.R")
source("tests/run_quarterly_prediction_checks.R")
source("scripts/check_quarterly_evaluation.R")
source("scripts/record_quarterly_evaluation_status.R")
```

The three fitting/diagnostic workflows are independent and use distinct output directories. Their tests and the final cross-check require completed outputs. `scripts/summarize_quarterly_prediction.R` can refresh score aggregates and figures from saved predictions without refitting. The input manifest fingerprints the primary panel and models; the cross-check verifies that evaluation did not alter them.

Tracked CSVs contain aggregate findings. Fitted objects, event-level and locality-quarter inputs, residual draws and figures remain local under `outputs/quarterly_diagnostics/`, `outputs/quarterly_sensitivity/`, and `outputs/quarterly_prediction/`. Their session files record the loaded package environments. Completion flags mean the specified evaluations were performed; they do not certify that residual dependence, measurement bias, or operational uncertainty were resolved.

## Deployment absence and historical availability follow-up

After the original-input audit and quarterly panel build, run `scripts/audit_absence_followup.R` and `scripts/audit_historical_source_dates.R`. These descriptive checks fit no models and change no panel. The clean workflow includes both stages. The official-source evidence ledgers are documented provenance inputs, not generated scientific comparisons; raw historical Candidate files remain ignored. Read [the deployment findings](deployment_absence_followup.md), [release investigation](historical_data_availability.md), and [code/source-date checks](historical_availability_code_audit.md). The new stages were also run against the retained isolated clean project; this is an additive check, not a second full estimation run.

The [one-origin supplement](forecast_origin_reconstruction.md) fixes 1 October 2023 and provides pinned-input acquisition, event comparisons and dated map reconciliation. Its reproduction commands are separate from model fitting. Complete historical predictor availability remains uncertified; no partial-window count or modern numeric deployment comparator is promoted to a complete as-of predictor.

The [training extension](forecast_training_followup.md) adds annual/cumulative event history, an archived deployment prefix and a joint-coverage audit. Its reproduction sequence is reconstruct_forecast_training.R, audit_forecast_origin_coding.R, assemble_forecast_training_availability.R and tests/run_forecast_training_checks.R. Complete Q3 event information and later deployment coding remain unresolved; no new fitting gate is opened.

## Post-2019 and September supplement — 2026-11-07

Read [the synthesis](post2019_and_september_followup.md). After the existing origin-event and training-history stages, run `scripts/audit_september_2023.R`, `scripts/reconstruct_post2019_deployment.R` and `scripts/audit_post2019_map_coding.R`, then `scripts/assemble_post2019_training.R` and `tests/run_post2019_followup_checks.R`. The deployment stage also requires the original quarterly panel and earlier coding audit. Original evidence and static transcription manifests are required; derived ledgers must be regenerated. These stages fit no models and do not replace the frozen panel. They expand joint training overlap to 204 of 570 rows while leaving complete September counts, later locality deployment histories and full-window centering unresolved. Unknown absence stays missing.

## Expanded deployment histories and September provenance

After the prior post-2019 stages, run `audit_deployment_release_catalog.R`, `audit_deployment_release.R`, `audit_september_reporting_gaps.R`, and `reconstruct_deployment_2021_2023.R`, then `tests/run_deployment_history_completion_checks.R`. Script names are relative to `scripts/` except the test. Follow the static source manifests and retain their original bytes. These stages produce a retrospective comparison and an explicit historical-gap ledger; they do not feed the fitted panel. See [findings](deployment_history_completion_followup.md).
