# Dynamic quarterly common-strength validation

The ordinary history model passes the prespecified finite-sample validation gates, including the separately seeded correlated-prehistory null. It fails to recover the known common strength coefficient under the illustrative selection and differential-recording stresses. This simulation workflow fits synthetic outcomes only; subsequent bounded empirical fits are reported separately in [initial empirical results](quarterly_empirical_results.md).

## Results

Each row contains 200 attempts, all numerically usable. Bias and RMSE are on the log-count scale per 1,000 personnel; coverage refers to nominal 95% Wald intervals. Directional error means a confidently wrong sign when truth is negative, or either confidently nonzero sign when truth is zero.

| Scenario / estimator | Bias (MCSE) | RMSE | Coverage (MCSE, percentage points) | Directional error | Near-zero intercept SD |
|---|---:|---:|---:|---:|---:|
| Fixed-zero favorable / ordinary | -0.034 (0.023) | 0.322 | 95.5% (1.47) | 0.0% | 0/200 |
| Fixed-zero null / ordinary | -0.028 (0.023) | 0.328 | 94.0% (1.68) | 6.0% | 5/200 |
| Selection / ordinary | +0.313 (0.016) | 0.388 | 68.0% (3.30) | 4.5% | 10/200 |
| Differential recording / ordinary | +0.312 (0.026) | 0.486 | 81.0% (2.77) | 6.0% | 3/200 |
| Correlated prehistory / ordinary | -0.004 (0.025) | 0.349 | 93.5% (1.74) | 0.5% | 11/200 |
| Correlated-prehistory null / ordinary | +0.042 (0.023) | 0.325 | 95.5% (1.47) | 4.5% | 15/200 |
| Correlated prehistory / initial-adjusted diagnostic | -0.018 (0.025) | 0.358 | 93.0% (1.80) | 0.5% | 60/200 |

All four required ordinary-estimator rows meet the unchanged usable-fit, bias, coverage, Monte Carlo precision and null directional-error thresholds. This opens only the bounded simulation validation gate. In particular, the matched-prehistory-null bias of +0.042 is close to the 0.05 tolerance and its MCSE is 0.023: passing this 200-replication screen is not strong evidence that bias is below the tolerance across repeated simulation batches. Larger prospectively specified runs would sharpen that assessment. Monte Carlo error for the adverse-scenario coverage estimates exceeds two percentage points; those stress results are diagnostic rather than a completed precision target.

The adverse cases average estimates close to zero despite truth -0.30, with substantial undercoverage. Numerically successful estimation therefore does not ensure recovery under unmeasured deployment selection or differential recording. Even favorable RMSE is roughly 0.32, comparable to the magnitude of the true slope: the small, persistent-exposure design offers limited precision. Near-zero random-intercept estimates are disclosed rather than counted as numerical failures; all fits met the stated convergence, Hessian and finite-SE rules.

The 1,400 retained fits cover 1,200 independent generated panels, with two estimators applied to the same 200 nonnull prehistory panels. The initial-adjusted diagnostic passes its nonnull numerical criteria but lacks matched-null validation, has frequent near-zero intercept estimates, and is rank-deficient when transferred unchanged to the empirical covariate design. It is not the validated empirical estimator.

## Scope and interpretation

This experiment adds lagged recorded events, prior violent-spell duration and earlier deployment strength to the locality-random-intercept negative-binomial model. It uses the nine-locality, 32-quarter exposure schedule, with known common within-strength coefficient -0.30 or zero. Original scenarios contain 200 replications each; a separately documented matched correlated-prehistory null adds 200. The initial-adjusted variant is diagnostic only.

The favorable fixed-zero initial state is deliberately controlled. The correlated-prehistory stress instead generates 40 prior quarters conditional on locality risk. This is neither a stationarity proof nor an empirical calibration: across the generated nonnull panels the maximum initial count/spell is 115/40, whereas the audited empirical 2015 Q4 file has maxima 5/5. The stress examines a possible vulnerability, not its prevalence in these data.

The generated-data audit regenerated all 1,000 original panels from their seeds. Every count was finite and every recorded count was no greater than the corresponding underlying count. The largest true/recorded count was 540/333 and the largest retained lagged spell 71 quarters. These finite-run checks do not guarantee stability outside the inspected simulation horizon, particularly with an uncapped positive spell term.

The actual empirical fixed-effect design has strong correlation between adjacent deployment histories (within-locality correlation 0.954). The ordinary history design has full column rank, but including both initial log event count and initial spell creates a rank-deficient empirical design (13 of 14 columns independent; see `quarterly_design_diagnostics.md`). Therefore even favorable simulated performance of the diagnostic adjustment would not justify transferring that formula unchanged. Any revised estimator needs a separate specification and validation.

## Reproduction and provenance

Run `scripts/validate_dynamic_quarterly.R`, `scripts/check_dynamic_generated_data.R`, and `scripts/validate_dynamic_quarterly_null.R`; after all complete, run `scripts/summarize_dynamic_quarterly.R`. The final script reconstructs key metrics independently from retained fit records and exports tracked aggregates and package/seed metadata to `data/`. Per-fit records and example generated panels remain under ignored `outputs/`.

The first matched-null attempt accidentally reused the favorable scenario's seed range. It is superseded and excluded from validation. The amended extension uses base 20361107 and checks disjointness against the original seeds. The amendment was recorded before the replacement run and did not change the DGP, estimator or numerical tolerances. See `dynamic_quarterly_null_extension.md`.
