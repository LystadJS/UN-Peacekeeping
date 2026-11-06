# Quarterly evaluation findings

Completed 2026-11-06 for the 2016–2023 pilot. The requested residual diagnostics, influence checks, measurement/reporting sensitivity analyses, and retrospective predictive evaluation are complete. **The deployment association remains inconclusive, while the history model offers a small, geographically concentrated predictive improvement.** Completion of these checks does not mean that all model limitations have been resolved.

The primary analysis remains nine localities and 288 quarters, selected for complete listed deployment exposure under the five-month source-map rule. The within-locality log-count coefficient is −0.133, with 95% Wald interval [−0.770, 0.504], or conditional count ratio 0.876 [0.463, 1.656] per additional 1,000 listed military personnel in the previous quarter. Unknown deployment is never interpreted as absence.

## What the checks establish

| Question | Finding | Interpretation |
|---|---|---|
| Does history remove residual temporal structure? | Lag-2 randomized-residual median correlation is 0.140; its conditional reference upper bound is 0.114. Pearson residual correlation is 0.189. | Temporal structure remains a warning; the reference comparison is not a calibrated significance test. |
| Is there evidence against the narrow spatial reference? | Mean quarterly Moran statistic lies inside its conditional reference envelope. | This does not exclude spatial dependence outside the selected nine-locality, two-neighbor graph or in individual quarters. |
| Does one locality or year determine a clear strength association? | All 17 history-model deletion intervals include zero; omitting 2017 shifts the coefficient to −0.535. | Inconclusiveness persists, but point estimates are sensitive and appreciable influence remains. |
| Do measurement alternatives resolve the direction? | The tested timing, freshness, event-inclusion, and assignment alternatives retain zero-crossing strength intervals. | No stable directional conclusion emerges. Monthly and fatality analogues change the target and are exploratory. |
| Does history help one-quarter-ahead prediction? | Mean log-score gain is +0.0429 across 180 held-out outcomes; history wins 14 of 20 quarters but only four of nine locality averages. | Average improvement is small and concentrated. Removing Irumu's scores reverses the average gain; this is a score-aggregation check, not a refit. |
| Are held-out count intervals well covered? | Both models cover 171/180 outcomes with nominal 95% plug-in intervals; history intervals are narrower on average. | This is observed coverage for a selected retrospective sample, not proof of general calibration or uncertainty-inclusive operational readiness. |

All 34 deletion fits and all 40 rolling forecast fits met the stated numerical checks. Count-distribution diagnostics show better reproduction of the frequency of large observed counts with history, while broad maximum-count envelopes and residual dependence remain. No inconvenient fold, deletion, or measurement fit was silently removed.

No random-intercept SD was below 0.0001 in the two primary and 34 deletion models. The history-model SD nevertheless ranged from 0.333 to 0.740 across deletions, compared with 0.629 in the full sample. Positive Hessians and the absence of a near-zero boundary do not establish precise variance estimation from nine localities.

## Reporting assumptions can change the conclusion

Under the illustrative log-linear reporting model, the underlying-event coefficient equals the recorded-event coefficient minus the assumed log recording-probability ratio per additional 1,000 personnel. The point estimate changes sign at a ratio of approximately 0.876. The conditional interval becomes wholly positive below 0.463 or wholly negative above 1.656. At equal recording probabilities the original interval already includes zero.

These thresholds are an **algebraic sensitivity calculation**, not evidence that recording actually differs by those amounts. The assumed probabilities are bounded on the observed design; their absolute normalization is illustrative. Nonlinear and joint deployment/history-proxy reporting scenarios are reported separately. None estimates the true recording mechanism or removes unmeasured deployment confounding. Uncertainty within one assumed mechanism is different from uncertainty across mechanisms.

## Limits that remain

Prediction uses expanding training windows, training-only exposure centering, and prior-quarter histories. However, the localities were selected using full-period deployment availability, and historical release vintages are unavailable. It therefore assesses retrospective recorded-violence prediction within this selected sample, not a real-time forecasting system or new localities. Plug-in predictive distributions omit parameter and random-effect estimation uncertainty. Coverage among high-count outcomes is an outcome-selected descriptive check, not a separate nominal-coverage test.

The five-month map-age assumption remains consequential: a three-month rule yields an unbalanced sample rather than complete locality histories. Timing scenarios use later maps only as retrospective alternatives. Strength changes at adjacent lags remain highly correlated. The ordinary model has only nine locality intercepts, and its model-based coefficient intervals are conditional on assumptions that the diagnostics do not fully support.

The defensible contribution is the documented boundary of inference: favorable synthetic recovery and modest retrospective prediction coexist with selection/reporting vulnerability, imprecise associations, and unresolved temporal structure. These findings support methodological discussion, not locality protection rankings or deployment recommendations.

## Evidence and next research step

- [Residual diagnostics and influence](quarterly_diagnostics_results.md)
- [Reporting and measurement sensitivity](quarterly_sensitivity_results.md)
- [Retrospective prediction](quarterly_prediction_results.md)
- [Evaluation scope](quarterly_evaluation_scope.md) and [reproduction runbook](quarterly_runbook.md)

A bounded follow-on would prespecify a treatment of the remaining temporal dependence and test it in matched simulation and rolling prediction before comparing its substantive strength coefficient. Better source-map change dates, verification of listing completeness, and event publication vintages would address measurement and deployment-availability limitations that a richer regression alone cannot fix. Independent human interpretation of the figures and a final portfolio memo remain separate acceptance tasks.
