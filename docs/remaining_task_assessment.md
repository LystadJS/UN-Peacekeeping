# Assessment of remaining pilot tasks

Recorded 2026-11-06. This independent assessment distinguishes unfinished work from stale checklist wording and deferred extensions. It does not change the shared project plan, fit models, or retrospectively preregister completed analyses. The user has explicitly skipped independent human interpretation: its disposition is **user-skipped**, not completed or passed.

## Recommended disposition of unchecked entries

| Original item or group | Disposition | Evidence and qualification |
|---|---|---|
| Data dictionary | Existing work with a bounded completeness update | `data/data_dictionary.csv` and `data/quarterly_data_dictionary.csv` already document the source and active quarterly fields. The parallel dictionary update should be linked once verified; do not present old monthly placeholders as current model definitions. |
| Distinguish deployment absence from unknown | Completed coding distinction; certification unresolved | `deployment_absence_review.md`, quarterly protocol and panel builders retain unlisted months as unknown. They do not certify true deployment absence. |
| Fit proposed baseline count model | Completed in revised scope | Core/common-strength validation and the bounded baseline/history empirical fits are complete. A no-strength baseline cannot itself supply a strength-recovery coefficient. |
| Verify generated distributions | Completed bounded implementation validation | Dynamic generator, generated-data checks, known-truth recovery and independent numerical audits verify the specified finite-run mechanism. This is not proof of stationarity, empirical calibration or behavior outside the inspected horizon. |
| Preserve latent/recorded counts, strength and truth | Reconstructible already; full archive being completed | Every retained seed, fixed design, generator and parameter setting exists, with example panels. The parallel archive task materializes all 2,000 distinct retained synthetic panels without new fitting; original and clean rerun datasets are replications of the same seeds, not additional independent evidence. Link its final manifest rather than claiming the previous example-only archive was exhaustive. |
| Increase replications until MC precision adequate | No further runs required for current bounded conclusions | All prespecified required coverage-MCSE gates pass. Stress precision supports the qualitative failure comparisons; see calculations below. A sharper bias-tolerance decision would be a separately specified extension. |
| Investigate unexpected failures and distinguish failure types | Completed with limits retained | Independent reviews document the summary bug and seed collision, their corrections, rank deficiency of the diagnostic adjusted estimator, finite-sample imprecision and adverse-mechanism bias. Numerical convergence does not establish structural validity. |
| Freeze manageable empirical model set | Completed specification | `empirical_quarterly_protocol.md` fixes the baseline and ordinary common-strength history models. No varying-slope or initial-adjusted substitution occurred. |
| Distinguish zero events from unavailable/ineligible observations | Completed | `quarterly_panel_audit.md` and panel outputs define zero as no retained GED record under the filter, preserve unknown exposure and explain incomplete reporting. |
| Ensure every predictor was available before outcome | Partly satisfied; stronger claim unavailable | Occurrence-time ordering and training-only centering are verified. Historical publication/revision availability and prospective locality eligibility remain unresolved. Reword the completed task to the tested retrospective rule; retain real-time availability as a limitation. |
| Manually verify selected source records | Completed agent source-trace sample; further checks bounded | The panel audit records six specific GED IDs and Beni prehistory examples checked against released source records. The parallel source-check task adds evidence. Neither is independent confirmation of the underlying news reports or human-reader acceptance. |
| Specify baseline/history/varying-slope models | Baseline/history complete; varying slopes deferred | Active protocols and saved formula objects define the two fitted models. The revised pilot deliberately does not fit locality-specific slopes. |
| Define contrast and coefficient interpretation | Completed | Within-locality conditional log-count association per 1,000 prior-quarter listed military personnel, with within/between components separated. It is not a presence/absence or causal effect contrast. |
| Prespecify temporal windows, scores and intervals | Completed local protocol record | `quarterly_prediction_protocol.md` specifies 12 initial quarters, 20 expanding-window test quarters, log scores and 80%/95% plug-in intervals. Concentration summaries were explicitly added after the initial readout. |
| Specify sparse-locality, location and stale-map handling | Completed | Strict primary rules and separately interpreted alternatives appear in the quarterly and sensitivity protocols. Five-month map age and the retrospective complete-exposure restriction remain assumptions. |
| Criteria for simplifying unsupported random slopes | Superseded by deliberate exclusion | The common-slope revision, design diagnostics and simulation scope justify deferral. Do not claim a tested random-slope simplification rule or validated heterogeneity recovery. |
| Separate confirmatory and exploratory analyses | Completed classification, limited registration claim | Dated primary/model protocols, follow-up sensitivity protocol and explicitly labeled Pearson/concentration/joint-reporting additions document ordering. This is a locally recorded analysis plan, not external preregistration. |
| Timestamp before substantive estimates | Locally documented chronology; do not upgrade evidence | `pilot_protocol_version.csv`, dated addenda and Git history support version provenance. Some commits contain both protocols and completed results, so commit timestamps alone do not prove pre-fit registration of every clause. Preserve the recorded chronology without backdating. |
| Plot distributions, variation and usable observations | Existing coverage/design/trajectory evidence; bounded descriptive completion | Existing outputs already show locality coverage, strength variation and trajectories. The parallel descriptive task can close any explicit histogram/distribution gap without model fitting. |
| Confirm adequate within-locality variation | Assessment completed, qualified conclusion | Eight of nine localities vary; Shabunda does not. Adjacent centered strength lags correlate 0.954. Common-slope simulation supports the bounded analysis, not broad identifiability of local slopes. |
| Freeze panel/protocol and log changes | Current-version snapshot appropriate now | Record current hashes, timestamp, code/version pointers and amendment policy after these edits. Label it a current reviewed snapshot, not a pre-results freeze or external preregistration. Earlier audit manifests are snapshots, not evidence of an immutable original empirical freeze. |
| Fit/plot partially pooled locality deployment slopes | Deferred, not missing deliverables in active pilot | The authorized common-slope design replaces these with common-association sensitivity and simulation figures. Partial pooling of intercepts does not produce locality-specific deployment coefficients. |
| Small-multiple trajectories with map dates and intervals | Completed | `portfolio/figures/figure_1_trajectories` shows three named examples and source-map markers; the all-nine supplement shows retained trajectories and held-out intervals. Selection and plug-in uncertainty are disclosed. |
| Common/varying effects, original eight cells, slope-variance recovery | Deferred extensions | They are outside the approved narrow common-slope pilot and should not be checked as achieved. |
| Another reader interprets central figures | User-skipped | Keep completion/acceptance false and record the user's skip disposition. Do not infer a positive review from silence, agent inspection or automated tests. |

Several already-checked descriptions are stale, including “final panel pending,” “empirical estimation not cleared,” and “monthly sensitivity remains necessary.” Preserve earlier dated decisions as history, but update the active checklist descriptions to point to completed panels, authorized fitting and exploratory monthly sensitivity. Likewise, refer to prediction gains for the **combined history model**; the existing comparator adds both deployment and conflict history, so it does not isolate the incremental contribution of conflict history alone.

## Monte Carlo precision and whether further fitting is justified

The required ordinary scenarios have coverage MCSEs 0.0147, 0.0168, 0.0174 and 0.0147, all below the prespecified 0.02 threshold. That criterion governed the favorable/null and initial-condition gates. It was not imposed as a pass condition on the adverse mechanisms.

Independent calculations from the saved summaries give the following approximate 95% Monte Carlo intervals. They concern simulation summaries, not empirical effects, and use normal MC approximations. Coverage-loss intervals combine independent-scenario MC variances.

| Stress scenario | Coverage | Coverage MC interval | Bias MC interval | Coverage loss versus favorable, MC interval |
|---|---:|---:|---:|---:|
| Responsive deployment/hidden risk | 0.680 | [0.6154, 0.7446] | [0.2810, 0.3448] | [0.2043, 0.3457] |
| Differential recording | 0.810 | [0.7556, 0.8644] | [0.2605, 0.3640] | [0.0835, 0.2065] |

These intervals support the current qualitative statements of substantial upward bias and poorer coverage. They do not support fine ranking of the two bias magnitudes, and the portfolio does not make such a claim. Additional fits solely to make a generic checklist box appear complete are unwarranted.

The matched-prehistory-null bias is 0.04208 with MCSE 0.02283; its approximate MC interval is [-0.00267, 0.08682]. Thus the realized pilot gate passes, but the experiment does not strongly establish that underlying bias is below 0.05. This qualification is already explicit in the dynamic results and memo. If a later scientific decision requires that sharper distinction, prospectively fix an enlarged sample and unchanged estimator/DGP, report it as additional evidence, and avoid repeated stopping when the gate first passes. It is not necessary to reopen the completed bounded pilot now.

The calculations can be reproduced in R without fitting:

```r
x <- read.csv("data/dynamic_quarterly_simulation_summary.csv")
x <- x[x$estimator == "ordinary_history", ]
favorable <- x[x$scenario == "favorable", ]
stress <- x[x$scenario %in% c("selection", "differential_recording"), ]
for (i in seq_len(nrow(stress))) {
  row <- stress[i, ]
  print(list(
    scenario = row$scenario,
    coverage_mc_interval = row$coverage + c(-1, 1) * qnorm(.975) * row$coverage_mcse,
    bias_mc_interval = row$bias + c(-1, 1) * qnorm(.975) * row$bias_mcse,
    coverage_loss_mc_interval = favorable$coverage - row$coverage +
      c(-1, 1) * qnorm(.975) * sqrt(favorable$coverage_mcse^2 + row$coverage_mcse^2)
  ))
}
matched_null <- read.csv("data/dynamic_quarterly_null_summary.csv")
matched_null$bias + c(-1, 1) * qnorm(.975) * matched_null$bias_mcse
```

## Bounded closeout

Finish the already assigned dictionary/source checks, descriptive figures and synthetic archive; verify their manifests; reconcile stale checklist wording; record the current reviewed snapshot after edits; and propagate the human-review skip disposition while retaining false completion flags. Do not initiate a new empirical specification, heterogeneity analysis or simulation expansion to close superseded proposal items. Real-time release availability, absence certification, residual dependence, source-install/cross-platform restoration and any unavailable native PowerPoint test remain explicitly limited or deferred rather than asserted complete.

## Completed follow-up

The assigned dictionary/source checks, descriptive figures and full synthetic archive are now complete. Six source cases passed; all 36 exported fields are documented; 2,000 panels were regenerated independently in both projects and all 4,000 file hashes verified. The current 18-file snapshot was recorded and verified without backdating. See followup_checks.json, quarterly_source_spotchecks.md, simulation_archive.md and descriptive_panel_results.md. The plan has been reconciled and human review is skipped by user instruction, not completed.

## Availability follow-up — 2026-11-07

The requested follow-up is complete: [deployment evidence](deployment_absence_followup.md) identifies presence in unlisted Djugu; [historical archives](historical_data_availability.md) provide a possible reconstruction route; [source-date and eligibility checks](historical_availability_code_audit.md) quantify delayed listed reporting and narrow one selection concern. Absence certification, complete as-of reconstruction and operational validation remain unresolved. The current panel, model estimates and human-review disposition are unchanged.

## One-origin follow-up — 2026-11-07

The [fixed-origin exercise](forecast_origin_reconstruction.md) is complete as a partial information reconstruction. Three original report maps and three archived Candidate files were inspected or processed and fingerprinted. Current-panel comparisons are reproducible; missing last-month information, unauthenticated numeric deployment coding and unreconstructed training histories prevent an authenticated historical forecast. This narrows the evidence gaps without marking operational validation complete or changing the fitted sample.

## Training reconstruction follow-up — 2026-11-07

The [available training-history reconstruction](forecast_training_followup.md) is complete for its supported scope. August public-advertisement evidence is now resolved, event histories cover 30 complete outcome quarters, and a pinned older deployment file supplies an early prefix. The full joint historical training set and origin predictors remain incomplete. These findings supersede earlier blanket statements that training histories had not been reconstructed, without certifying an operational forecast or changing the fitted pilot.
