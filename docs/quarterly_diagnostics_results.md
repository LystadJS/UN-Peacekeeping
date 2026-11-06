# Quarterly residual diagnostics and influence results

Completed 2026-11-06 under `quarterly_diagnostics_protocol.md`. Both saved models were assessed on 288 locality–quarters in nine localities. All 34 case-deletion refits (17 per model) converged with positive Hessians and finite positive coefficient standard errors; no fit warning was captured. These checks identify remaining limitations, not a general declaration that the model is validated.

## Residual dependence remains

| Statistic | Baseline observed median | History observed median | History conditional 95% reference envelope |
|---|---:|---:|---:|
| Same-locality lag-1 correlation | 0.255 | −0.089 | [−0.118, 0.114] |
| Same-locality lag-2 correlation | 0.279 | 0.140 | [−0.117, 0.114] |
| Same-locality lag-4 correlation | 0.129 | 0.053 | [−0.130, 0.118] |
| Mean quarterly spatial Moran statistic | −0.125 | −0.121 | [−0.207, −0.041] |

The baseline temporal-correlation medians exceed their own reference envelopes at all three lags. The history model reduces lag-1 persistence but retains a lag-2 warning: median 0.140 exceeds its conditional upper reference bound 0.114. The statistic also depends on the randomized treatment of discrete counts: its 200 observed-jitter draws have a 95% range [0.055, 0.207]. Some randomizations overlap the reference envelope, so the result is a warning about unresolved temporal structure rather than a calibrated rejection. The history model's observed lag-1 jitter range is [−0.175, −0.009], despite its median lying within the reference envelope.

The mean spatial statistic lies within the reference envelope for each model. Negative Moran values should not be compared to zero as a universal null: with nine centered observations, the chosen network's conditional references are centered near −0.125. This narrow check uses a symmetrized two-nearest-centroid graph among the retained localities, not all administrative neighbors. It does not exclude other spatial patterns, quarter-specific dependence, or dependence in omitted areas.

An exploratory deterministic Pearson-residual check was added after examining the primary randomized-residual results. Its history-model correlations are −0.131, 0.189 and 0.085 at lags 1, 2 and 4; baseline values are 0.216, 0.288 and 0.133. This agrees that positive lag-2 structure remains, without relying on count jitter. It has no separate calibrated reference test and does not replace the prespecified diagnostics. Values are saved in `data/quarterly_diagnostic_pearson.csv` and independently checked against the model's Pearson residual method.

## Conditional count reproduction

The observed panel contains 1,248 events, a zero fraction of 0.458, maximum count 48, type-8 95th percentile 24.5, and 23 quarters with at least 20 recorded events. The history model's 2,000 fixed-parameter conditional replicates yield respective 95% envelopes of [1088.975, 1439], [0.392, 0.479], [45, 117], [18.25, 29.5], and [13, 24]. All five observed summaries lie inside these envelopes. The baseline's corresponding upper-tail frequency envelope is [10, 22], below the observed 23; its other four summaries lie inside their envelopes.

The history model's simulated maximum has median 69, above observed 48, even though 48 lies within the broad reference interval. Matching a few summaries is not evidence of comprehensive tail calibration. The checks condition on fitted locality effects and fixed observed histories, ignore parameter uncertainty, and do not propagate outcomes into subsequent histories. They therefore assess one-step conditional count distributions, not multistep trajectories or out-of-sample predictive validity. Reference comparisons reuse the fitted data and are not formal goodness-of-fit p-values.

## Case-deletion sensitivity

All 17 history-model deletion intervals include zero. Leaving out a locality produces coefficients from −0.306 (Rutshuru omitted) to +0.028 (Beni omitted), compared with full-data −0.133. Leaving out a year produces coefficients from −0.535 (2017 omitted) to +0.058 (2019 omitted). Thus the point-estimate direction is not stable, while the broad conclusion that the association is inconclusive survives every inspected deletion.

The largest change is deletion of 2017: −0.535, 95% Wald interval [−1.192, 0.121], a shift of −1.24 full-data standard errors. This is appreciable numerical influence, not a reason to remove 2017 or a formal outlier designation. The sole Ituri locality is Irumu; deleting it removes the Ituri province contrast and changes geographic support. Exposure centering and original historical predictors are retained in every deletion, so omitting a year does not silently redefine lags or splice nonadjacent years together.

## Saved variance estimates

Inspection of the two full-data models and all 34 deletion models found no random-intercept SD below the pilot's descriptive near-zero threshold of 0.0001. All 36 saved fits have positive Hessians, convergence code zero, finite fixed-effect coefficients and standard errors, and positive standard errors. The full-data random-intercept SDs are 0.944 (baseline) and 0.629 (history). Across deletion fits they range from 0.765–1.052 and 0.333–0.740, respectively. NB2 size ranges are 1.414–2.939 for baseline deletions and 2.791–4.847 for history deletions, compared with full-data 1.801 and 3.594.

Thus no inspected fit has a near-zero variance warning, but the variance estimates change materially with data deletion. This is not a formal variance-stability test, and positive Hessians do not establish precise estimation of a random-effect distribution from nine localities. `scripts/summarize_quarterly_variance.R` reads the saved models without refitting and writes `data/quarterly_diagnostic_variance.csv`.

## Reproduction and acceptance

Run `scripts/diagnose_quarterly_models.R`, then `tests/run_quarterly_diagnostic_checks.R`. The latter independently checks actual-count summaries, simulated reference quantiles, temporal pairing by splitting and sorting localities, Moran calculations by matrix multiplication, deletion denominators, and saved history-model intervals. RNG seeds are 2026110602 for baseline and 2026110603 for history (base 2026110601 plus model index). No deletion was adopted as the primary sample and no model specification was changed after these findings.

Tracked aggregate evidence: `data/quarterly_diagnostic_counts.csv`, `data/quarterly_diagnostic_dependence.csv`, `data/quarterly_diagnostic_locality_acf.csv`, and `data/quarterly_influence_results.csv`. Local `outputs/quarterly_diagnostics/` contains residual draws, conditional simulation summaries, spatial weights/centroids, saved deletion fits, session information, and PNG/PDF figures. Both figures were visually inspected for labels, intervals, and clipping.

**Assessment: share with caveats.** The requested diagnostic and deletion checks are complete, but the residual temporal warning and case-deletion shifts remain unresolved analytical limitations. Further model changes would require a new stated specification and matching simulation/predictive evaluation; these results do not authorize post hoc selection of a more favorable association.
