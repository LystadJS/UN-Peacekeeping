# Quarterly retrospective predictive evaluation

Completed 2026-11-06 under `quarterly_prediction_protocol.md`. All **40 fits were usable**: baseline and history in 20 expanding-window folds, predicting 2019 Q1–2023 Q4 after at least 12 training quarters. Each model produced 180 held-out locality-quarter forecasts. No fit was silently substituted or removed; optimizer convergence, Hessian and finite-value checks passed for every fold.

The history model has a **small average log-score advantage**, with lower absolute error and narrower plug-in count intervals. That advantage is geographically concentrated and does not establish causal identification or operational forecasting readiness.

| Held-out metric, all 180 forecasts | Baseline | History |
|---|---:|---:|
| Mean log predictive probability; higher is better | −2.2296 | −2.1867 |
| Mean absolute count error | 5.004 | 3.805 |
| 80% count-interval coverage | 83.89% | 83.89% |
| 95% count-interval coverage | 95.00% | 95.00% |
| Mean 80% count-interval width | 14.58 | 11.03 |
| Mean 95% count-interval width | 22.98 | 17.07 |

The paired mean log-score difference (history minus baseline) is **+0.04290**. History performs better in 14 of 20 held-out quarters. Its poor 2019 Q2 performance remains in the comparison. Removing any one held-out quarter from score aggregation leaves a positive mean difference, ranging from +0.01545 to +0.11328. This is a descriptive score-concentration check, not a leave-period-out refit or formal uncertainty interval.

Only **four of nine locality-specific mean score differences are positive**. Irumu and Masisi have the largest positive contributions; the alphabetical locality table is saved without any protection-success ranking. Omitting Irumu's held-out scores from aggregation changes the mean advantage to approximately **−0.0147**, without refitting any model. Thus the average improvement should not be described as uniform across localities. Locality and quarter results are dependent; no independent-observation significance test is claimed.

## High-count outcomes

Forty-three held-out outcomes exceed their fold's training-only 90th-percentile count threshold. The threshold never uses future outcomes, but membership in this diagnostic stratum depends on the realized held-out count. It is not a forecast-time high-risk classifier.

| Metric among 43 high-count outcomes | Baseline | History |
|---|---:|---:|
| Mean log predictive probability | −4.1638 | −4.1294 |
| Mean absolute count error | 10.754 | 9.233 |
| 80% count-interval coverage | 65.12% | 69.77% |
| 95% count-interval coverage | 90.70% | 88.37% |
| Mean 95% count-interval width | 55.51 | 45.12 |

Intervals cover fewer of these high-count outcomes than the overall sample. However, selecting cases on realized outcome size changes the coverage target: nominal conditional coverage is not guaranteed within such a stratum even for a well-specified distribution. These values reveal performance on large observed counts, not a standalone calibration test.

## What was and was not validated

Training-only locality strength means replace the full-period descriptive means in every training and test fold. Stored model frames contain only outcomes before the held-out quarter; lagged outcome and earlier-strength fields align with the preceding panel row. Test-period counts do not update fitted locality effects. The procedures use one-step prediction with previously observed counts, not recursively simulated future histories.

Forecast distributions are **conditional plug-in NB2**: count-process variation is represented, but fixed-parameter and random-effect estimation uncertainty is omitted. Discrete central count intervals can over-cover their nominal levels. The observed 95% aggregate coverage is a result for these 180 selected observations, not proof of general calibration or full predictive uncertainty.

The population was selected retrospectively for full-period listed-exposure availability. GED release vintages and publication timing have not established which events were actually available at each historical forecast origin. Deployment information is also retrospectively assembled. This evaluates prediction of recorded violence under retrospective data availability and the five-month source-map rule; it is not a prospective operational forecast, an evaluation in new localities, or prediction of unobserved violence.

## Reproduction and checks

Run `scripts/validate_quarterly_prediction.R` to fit all folds. It calls `scripts/summarize_quarterly_prediction.R`, which can also refresh aggregates and figures directly from saved forecasts without refitting. Run `tests/run_quarterly_prediction_checks.R` for independent verification of training frames, centering, lag alignment, probability calculations, quantile definitions, paired scores and concentration summaries. Numeric comparisons use tolerances appropriate for CSV serialization.

Aggregate CSVs are tracked under `data/quarterly_prediction_*.csv`. Row-level forecasts, training means, model objects and PNG/PDF figures remain under ignored `outputs/quarterly_prediction/`. Both exported figures were visually inspected for clipping, labels, denominators and agreement with saved summaries. The score plot preserves every quarter, including adverse periods; the coverage plot identifies the outcome-selected high-count stratum and the plug-in uncertainty limitation.

Next evidence needed for operational use includes prospective eligibility, release-vintage or publication-availability records, uncertainty-inclusive forecast distributions, and performance assessment on additional periods/localities. None is substituted by the favorable aggregate coverage reported here.
