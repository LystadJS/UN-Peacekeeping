# Corrected-panel model sensitivity

Fitted 7 November 2026 under the [bounded follow-up protocol](corrected_panel_sensitivity_protocol.md). **The supported corrections make the estimated within-locality association somewhat more negative, while its interval remains wide and includes zero.** The alternative Mavivi subtotal produces the same qualitative conclusion. These results do not establish equivalence, a causal protection effect or an authenticated historical forecast.

## Comparable fits

All full-data fits retain the original nine localities, 288 locality-quarters and 1,248 recorded one-sided-violence events. Outcome counts, conflict-history covariates, sample membership, season, province and calendar index are identical. The baseline is fitted once because all of its inputs are unchanged. The ordinary history model retains the original NB2 family, default `glmmTMB` estimator, locality random intercept and fixed formula. Full-period exposure centering is recomputed within each measurement scenario; this remains retrospective descriptive estimation.

| Exposure version | Within-strength estimate | Conditional 95% Wald interval | Change from original |
|---|---:|---:|---:|
| Original reference | −0.1326 | [−0.7695, 0.5043] | — |
| Supported corrections | −0.1885 | [−0.8296, 0.4525] | −0.0559 |
| Supported corrections plus Mavivi 2,350 alternative | −0.2102 | [−0.8496, 0.4293] | −0.0776 |

The coefficient is the conditional log-count association per 1,000 prior-quarter listed military personnel, controlling for the declared history and calendar terms. The supported-correction shift is about 0.172 of the original standard error; the Mavivi alternative shifts it by about 0.239 original standard errors. These are descriptive change measures, not equivalence tests. On the ratio scale, the supported estimate is 0.828 with interval [0.436, 1.572], compatible with both lower and higher recorded event rates under the model.

The Mavivi alternative is an explicitly retained stress scenario using the inconsistent larger contributor subtotal on revision 51. It is not promoted to a verified personnel correction merely because it produces a usable fit. The original reference refit reproduces every baseline/history fixed-effect estimate and standard error within absolute tolerance 0.000001. [Model comparison](../data/corrected_panel_model_comparison.csv); [all coefficients](../data/corrected_panel_coefficients.csv).

## Numerical and descriptive checks

All four full-data fits—the shared baseline and three history fits—and all nine corrected-history locality-deletion fits have optimizer convergence code zero, positive-definite Hessians and finite positive coefficient standard errors. Fixed-effect matrices have full rank. No fit was discarded and no alternate optimizer or specification was selected from these results. [Diagnostics](../data/corrected_panel_model_diagnostics.csv).

The supported history model's NB2 dispersion is 3.602, compared with 3.594 originally. Its Pearson sum per residual degree of freedom is 1.141, compared with 1.137. The fitted conditional zero fraction is approximately 0.437, compared with the observed 0.458. Pearson residual correlations at lags one, two and four quarters are −0.131, 0.187 and 0.083; the corresponding original values are −0.131, 0.189 and 0.085. These deterministic descriptive checks do not replace the earlier simulation-reference residual diagnostics or establish independence. Previously documented dependence limitations remain.

Relative to the original fit, supported corrections change conditional fitted means by 0.0336 events per row on average in absolute value, with a maximum absolute change of 0.7432. The Mavivi alternative changes them by 0.0433 on average, with maximum 0.7389. These are **in-sample conditional fitted-mean changes**, not out-of-sample predictive gains or interval coverage. No rolling forecast evaluation was repeated in this bounded sensitivity run. [Fitted-mean comparison](../data/corrected_panel_fitted_mean_changes.csv).

## Locality-deletion sensitivity

Each deletion retains the supported panel's original full-sample centering and prior histories, matching the earlier influence procedure. The nine corrected-history estimates range from −0.3106 when Rutshuru is omitted to −0.0542 when Beni including city is omitted. Every conditional 95% interval includes zero. Omitting Irumu gives −0.0685; the remaining intervals and original-versus-corrected deletion contrasts are retained in the [influence table](../data/corrected_panel_locality_influence.csv).

These checks show that the inconclusive interval conclusion survives this specified set of source corrections and locality deletions. They do not establish uniform stability or justify dropping a locality from the primary sample. The original sample selection, nine-cluster uncertainty, incomplete reporting, deployment selection and unresolved historical availability remain limitations.

## Reproduction and scope

Run `scripts/fit_corrected_panel_sensitivity.R` after building the separately versioned scenario panels and retaining the dated protocol. The script checks invariant inputs before fitting, records panel/protocol fingerprints, saves all 13 fitted objects, and retains warnings and failed attempts if any occur. Five public CSV tables contain coefficients, full-fit diagnostics, scenario comparisons, fitted-mean changes and locality influence. Detailed conditional predictions and model objects remain private under `outputs/corrected_panel_sensitivity/models/`.

The original panel, fitted models and original result tables are untouched. This is a measurement sensitivity supplement, not a replacement primary analysis, new identification argument or fresh validation of the full simulation/forecasting workflow. Human review remains skipped at the user's direction, not completed.

The [isolated reproduction receipt](../data/corrected_panel_reproduction_checks.json) confirms all 13 model objects and their scientific summaries were reproduced under the declared tolerance. See [combined findings](corrected_panel_sensitivity_findings.md) for the source decision, panel changes and remaining limits.
