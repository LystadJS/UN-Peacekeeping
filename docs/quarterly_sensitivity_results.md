# Reporting and measurement sensitivity findings

Completed 2026-11-06 under the follow-up protocol in `quarterly_sensitivity_protocol.md`. All 44 numerical fits were usable: 11 specification fits, three log-linear offset verification fits, 21 nonlinear reporting fits, and nine separately documented strength/history reporting assumptions. Usable means optimizer convergence zero, positive-definite Hessian and finite positive slope SE; it is not a claim of model adequacy or calibrated uncertainty.

**The direction of the point association is sensitive to deployment timing, while every measurement-specification interval includes zero.** This supports retaining an inconclusive substantive interpretation, not a finding of equivalence or proof that all measurement problems are harmless.

## Measurement comparisons

All slopes below are conditional log count associations per 1,000 listed military personnel. The monthly model and fatality model change the estimand and have not received corresponding simulation validation.

| Specification | Rows | Recorded event total | Slope | 95% Wald interval |
|---|---:|---:|---:|---|
| Primary quarterly | 288 | 1,248 | −0.133 | [−0.770, 0.504] |
| Source-map age at most three months | 252 | 1,233 | 0.004 | [−0.636, 0.644] |
| Original exposure on the same 252 rows | 252 | 1,233 | 0.004 | [−0.636, 0.644] |
| Early map-interval switch | 288 | 1,248 | 0.193 | [−0.336, 0.722] |
| Midpoint map-interval switch | 288 | 1,248 | 0.347 | [−0.206, 0.900] |
| Quarter-contained event-date intervals | 288 | 1,252 | −0.138 | [−0.775, 0.499] |
| Location precision 1 or 2 | 288 | 1,594 | −0.180 | [−0.762, 0.401] |
| Boundary event assigned to named Irumu | 288 | 1,249 | −0.132 | [−0.769, 0.505] |
| Vido event assigned to named Beni | 288 | 1,249 | −0.131 | [−0.767, 0.506] |
| Civilian fatalities, separate outcome | 288 | 1,248 | −0.140 | [−1.158, 0.879] |
| Monthly analogue, different horizon | 864 | 1,248 | 0.433 | [−0.237, 1.102] |

The three-month rule is applied to both prior deployment quarters. It removes 36 rows and 15 retained events. The paired reference has identical exposure values on those rows and produces the identical estimate, so this particular difference is a sample-restriction effect, not evidence of a corrected strength measurement. The restricted panel is unbalanced and remains limited to the original nine localities.

Early and midpoint assumptions alter 166 and 97 monthly stocks respectively within the 2014–2023 reconstruction. Both endpoint rows must trace to their actual map dates and contain positive finite strength. Actual map observations remain fixed; unknown listing is never filled or converted to zero. The timing alternatives are retrospective scenarios using later maps, not information available at a forecast origin. They expose meaningful point-estimate sensitivity to when a mapped change is assumed to have occurred.

Accepting quarter-contained dates adds four core-sample events; accepting location precision 2 adds 346. Each scenario rebuilds recorded-event and spell histories from 2014. The named-location alternatives add exactly one flagged exact-place record each, without treating names as independently verified geographic repairs. Wider location uncertainty and all possible spatial misclassification are not resolved by these few alternatives.

The fatality outcome totals 4,467 recorded civilian deaths in retained one-sided events; the table's event column remains 1,248. Its controls retain recorded-event histories. The monthly analogue uses one-month histories and second monthly strength lags with 12-level seasonality, rather than quarterly histories. Neither result is a validated substitute for the primary quarterly event-frequency analysis.

## Assumed recording probabilities

The log-linear curve uses q = 0.8 exp(lambda * strength − max(lambda * strength)). Every probability is positive and at most 0.8; the smallest probability across the displayed ratio range is approximately 0.0144. These absolute levels are illustrative. The ratio range 0.25–4 per 1,000 personnel is deliberately broad and not estimated from external evidence.

Rows with `q_min = q_max = 1` in the measurement-specification table simply have a zero offset and target recorded counts. They do not assert that recording is complete or that recorded counts equal underlying events.

The within-strength coefficient shifts exactly by −lambda because the log(q) offset is a linear combination of existing strength columns and the intercept. Three actual refits verified both the shifted coefficient and unchanged SE. Consequently:

- The point estimate changes sign at an assumed relative recording probability of **0.876** per additional 1,000 personnel.
- A positive conditional interval requires a ratio **below 0.463**.
- A negative conditional interval requires a ratio **above 1.656**.

At the boundary values an interval endpoint equals zero; between 0.463 and 1.656 the interval includes zero. The starting result is already inconclusive. These thresholds describe consequences of assumptions; they do not reveal actual reporting behavior or establish protection/harm. The curve's band is uncertainty conditional on each assumption, while movement along the curve is uncertainty across assumptions.

The 21 nonlinear alternatives use logistic q with baseline 0.65 at zero within-strength. Slopes range from **−0.900 to 0.606**. Four high positive recording-strength slopes (logit slope 1.4–2.0) yield negative intervals; none yields a positive interval. Their reference q(1)/q(0) ratios are 1.358–1.434, which are local contrasts, not constant per-unit recording ratios. They cannot be compared numerically to the constant-ratio threshold without accounting for the different q shape. This illustrates that the sensitivity conclusion also depends on the assumed functional form.

The nine additional joint assumptions combine strength slopes −1, 0, 1 with recorded-history proxy slopes −0.5, 0, 0.5 in logit(q). All intervals include zero; estimates span **−0.560 to 0.275**. The proxy is centered log(1 + prior recorded events), not observed latent risk. This modest illustrative grid neither estimates reporting completeness nor addresses unmeasured deployment confounding.

## Verification and reproducibility

Run `scripts/analyze_quarterly_sensitivity.R`, then `tests/run_quarterly_sensitivity_checks.R`. The latter independently checks saved model coefficients and interval arithmetic, q bounds and analytic thresholds, identical paired samples, map-endpoint provenance and unknown preservation, and event counts reconstructed from the original ledger with base R. A source-map summary ordering issue was corrected before final verification; numerical results were unchanged. Explicit endpoint guards were added and the workflow rerun.

Aggregate tables are `data/quarterly_sensitivity_*.csv`. Scenario panels, fitted objects, session details and PNG/PDF figures remain under ignored `outputs/quarterly_sensitivity/`. Both figures were visually inspected for clipping, labels, intervals and the distinction between comparable measurement variants and different outcomes/horizons. No raw records are redistributed by these summaries.

The checked result is **shareable with caveats**: absence of a clear common association persists across the tested measurement alternatives, while its point direction and reporting-adjusted interpretation depend on assumptions. Better dated deployment changes, corroborated ambiguous event locations, and independent evidence on recording probabilities would reduce these specific uncertainties. These analyses do not justify locality rankings or deployment recommendations.
