# Quarterly common-strength pilot: validation results

**Core simulation gate passed; empirical models have not been fitted.** The result applies to a common slope with the specified calendar/province structure and random intercept, conditional on nine continuously observed localities. It does not validate causal identification, dynamic history adjustment, varying slopes or generalization to unlisted places.

## Protocol and exposure design

The [quarterly protocol](quarterly_protocol.md) fixes 2016 Q1–2023 Q4, 19 analytical composites, and preceding-quarter mean military strength per 1,000 personnel. Mean monthly stocks are used rather than summed stocks. A full quarter requires three numeric monthly estimates with source age at most five months. The first exposure quarter is 2015 Q4. Unknown listing remains unknown.

There are 608 possible locality-quarter outcomes. Lagged strength is available for 362; 246 remain unavailable. Requiring complete exposure history selects nine localities and 288 rows. Eight of these nine have within-locality strength variation; Shabunda contributes intercept/calendar information but no within-strength variation. This retrospective complete-history restriction is a selection condition, not a claim of ignorable missingness.

The [source-map review](deployment_absence_review.md) inspected two original endpoint maps. It supports distinguishing troop symbols from headquarters/police and preserves unlisted status as unknown; it does not certify zero deployment across unreviewed places or dates. URLs and hashes are in the separate pilot manifest.

## Simulation results

Four scenarios, 200 replicates each, use the observed exposure schedules and fully synthetic outcomes. Truth is a log-count slope of -0.30 per 1,000 personnel except in the null case (0). All 800 attempted fits met convergence, Hessian and finite-SE criteria. Failed-fit rows would remain in the denominators; none occurred.

| Scenario | Slope bias | Bias MCSE | RMSE | 95% interval coverage | Coverage MCSE | Confident wrong direction |
|---|---:|---:|---:|---:|---:|---:|
| Favorable | -0.0002 | 0.0071 | 0.0999 | 96.0% | 1.39 pp | 0.0% |
| Null | -0.0097 | 0.0074 | 0.1055 | 94.0% | 1.68 pp | 6.0% nonzero claims |
| Differential recording | +0.2759 | 0.0067 | 0.2914 | 20.0% | 2.83 pp | 1.0% |
| Hidden-risk confounding | +0.3468 | 0.0078 | 0.3638 | 8.5% | 1.97 pp | 8.5% |

Both favorable and null cases meet the thresholds specified before performance inspection: at least 95% usable fits, absolute bias <=0.05, coverage >=90%, coverage MCSE <=0.02, and null false-direction rate <=10%. These are pilot tolerances. Zero observed favorable directional errors does not imply zero population risk. Stress-case Monte Carlo precision supports the large failures shown here, not fine comparisons between nearby mechanisms.

Differential recording nearly erases the structural negative slope on average; hidden risk can reverse its apparent direction. These are controlled stress mechanisms, not estimates of actual DRC reporting probabilities or deployment selection. In particular, the hidden-risk test encodes correlated unmeasured risk rather than a full temporal decision rule responding to past violence. The core mean model is correctly specified only in the favorable/null configurations.

## Checks and reproducibility

`tests/run_quarterly_checks.R` checks quarterly keys, complete exposure histories, centering, lag alignment, seed reproducibility and binomial thinning. Every simulated fit has a saved seed, estimate, SE, convergence result, Hessian flag, warning/error message and runtime. One complete synthetic dataset per scenario is retained as an example; all other datasets are reproducible from their seeds and the fixed design. Full fitted model objects are not archived.

An initial summary implementation overwrote its logical usable-fit indicator with the usable-fit count inside a dplyr summary. Range checks and comparison with per-fit records exposed that error. It was corrected before delivery, and all reported metrics were independently recomputed from the unchanged 800 fit records using base R. No generator, fit, threshold or seed was changed. The recovery figure was generated directly from the per-fit estimates and was visually inspected.

The [machine-readable summary](../data/pilot_simulation_summary.csv), [package inventory](../data/pilot_package_versions.csv) and [local protocol version record](../data/pilot_protocol_version.csv) are tracked. The protocol record is not an external preregistration. Detailed fits, synthetic examples, exposures and the figure remain under ignored `outputs/quarterly_pilot/`.

Reproduction commands, from the repository root with the recorded dependencies installed:

```r
source("scripts/build_quarterly_exposure.R")
source("tests/run_quarterly_checks.R")
source("scripts/validate_quarterly_simulation.R")
source("scripts/recheck_simulation_summary.R")
source("scripts/record_pilot_environment.R")
```

## Gate interpretation

The common-slope **core estimator** passed its prespecified synthetic recovery gate for this fixed exposure design. The full history-adjusted empirical workflow remains unvalidated; it needs a matching dynamic simulation and recorded-outcome panel checks. Timing measurement error, spatial dependence, alternative count intensities and other reporting mechanisms remain outside this bounded validation. No empirical deployment coefficient has been estimated, and `empirical_ready` remains false.
