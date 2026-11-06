# First conditional quarterly fits

Fitted 2026-11-06 after independent verification of all required ordinary-history simulation gates and the measurement decision in `empirical_quarterly_protocol.md`. These are initial descriptive estimates, not a completed empirical evaluation.

Both the baseline and history models used 288 quarters in nine localities and returned convergence code zero, positive-definite Hessians, finite standard errors, and no captured warnings. The common within-locality strength coefficient was **−0.1326**, with a model-based 95% Wald interval **[−0.7695, 0.5043]** per additional 1,000 listed military personnel in the previous quarter. Exponentiating gives a conditional count ratio of **0.876 [0.463, 1.656]**. The interval includes associations in both directions. This does not establish protection, harm, or equivalence to no association.

| Descriptive check | Baseline | History |
|---|---:|---:|
| NB2 size parameter | 1.801 | 3.594 |
| Pearson residual sum / residual df | 1.057 | 1.137 |
| Observed zero fraction | 0.458 | 0.458 |
| Fitted conditional zero fraction | 0.446 | 0.437 |

These checks are not a full validation of count tails, residual dependence, influence, or uncertainty. The history model conditions on prior recorded events, spell duration, and earlier deployment. Adjacent deployment histories correlate 0.954, and only eight localities supply within-strength variation. No varying locality slopes were fitted.

Interpretation remains conditional on the five-month map-age rule and complete listed exposure. Unknown deployment was not treated as absence. The simulation's selection and reporting stress cases produced roughly +0.31 log-slope bias; passing favorable recovery checks does not resolve those empirical threats. Simulation parameters were illustrative, not calibrated to every fitted empirical parameter, and passing 200-replication screens does not establish uniform inferential validity.

Aggregate coefficients and basic diagnostics are tracked in `data/quarterly_empirical_coefficients.csv` and `data/quarterly_empirical_diagnostics.csv`. Model objects, panel fingerprint, gate snapshot, and session information remain local under `outputs/quarterly_pilot/empirical/`. Reproduction uses `scripts/fit_quarterly_empirical.R` and `scripts/summarize_quarterly_empirical.R`; the fitting entry point requires explicit readiness flags.

At the time of these initial fits, temporal/spatial residual assessment, extreme-count reproduction, locality/period influence checks, timing/reporting sensitivity, and rolling retrospective predictive evaluation remained open. Those requested follow-ups were subsequently completed on 2026-11-06; see [combined evaluation findings](quarterly_evaluation_findings.md). Their completion does not establish causal effects, supported locality rankings, or operational readiness.
