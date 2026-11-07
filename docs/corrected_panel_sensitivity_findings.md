# Corrected-panel sensitivity: findings

Completed 7 November 2026. **The supported source corrections make the estimated association somewhat more negative, but the uncertainty remains wide and the substantive conclusion remains inconclusive.** The result also remains inconclusive under the larger Mavivi subtotal alternative. These are conditional observational associations, not causal protection effects.

| Exposure version | Within-locality coefficient | Conditional 95% Wald interval |
|---|---:|---:|
| Original reference | −0.1326 | [−0.7695, 0.5043] |
| Supported corrections | −0.1885 | [−0.8296, 0.4525] |
| Supported corrections plus Mavivi 2,350 alternative | −0.2102 | [−0.8496, 0.4293] |

Coefficients describe the log-count association per 1,000 prior-quarter listed military personnel. All scenarios retain nine localities, 288 quarters, 1,248 recorded events and the original common-slope NB2 specification. The supported-correction shift is −0.0559, about 0.172 of the original standard error. This is a descriptive comparison, not an equivalence test. All nine supported-panel locality-deletion intervals also include zero. [Model results and diagnostics](corrected_panel_model_results.md)

## What was resolved and changed

The [Mavivi audit](mavivi_subtotal_resolution.md) resolves the analysis choice as a South African sized subtotal of 950 and a total of 2,200. Map symbols, unit counts and nine adjacent rows support that choice. The original field's cause remains unverified; provider bytes are preserved. The larger 2,350 subtotal is retained only as an explicit revision-51 sensitivity assumption.

The [separate panel reconstruction](corrected_panel_construction.md) propagates Nyamilima's locality correction through all 17 affected source-map rows and 47 monthly rows. It applies the adjudicated 2023 Rwindi/Nyamilima assignments and February Bukavu FPU subtraction, without extrapolating unit decisions to unreviewed maps. Quarterly strength, both lags, locality means and within-locality deviations are rebuilt. Supported corrections change 17 first-lag cells, 16 second-lag cells and 64 centered-exposure cells in the core sample. Outcome histories and sample membership are unchanged.

Before fitting, the unchanged reconstruction reproduced every frozen panel field. The [follow-up protocol](corrected_panel_sensitivity_protocol.md) fixed the scenarios and estimator before new coefficient fits. Original source data, panels, models and result tables remain unchanged; this is a separately versioned sensitivity supplement.

## Validation and remaining limits

All 13 fits per run were numerically usable: one shared baseline, three history fits and nine locality deletions. The retained isolated environment reproduced 11 public tables, 17 private CSV tables, six panel objects and 13 model objects under the declared tolerances. Independent checks reconstructed the expected lag and centering changes directly from the source schedule. All 18 frozen analysis files and the unchanged project-plan file were verified. [Reproduction receipt](../data/corrected_panel_reproduction_checks.json)

This does not establish a complete historical information set, exact compound coordinates, actual personnel totals, causal identification or operational forecasting readiness. September coded inputs and other deployment-availability gaps remain. Residual dependence and nine-locality uncertainty are not removed by correcting exposure coding. The original full simulation and rolling forecasting workflows were not repeated; conditional fitted-mean comparisons are not new predictive validation. Human review remains skipped at the user's direction, not completed.
