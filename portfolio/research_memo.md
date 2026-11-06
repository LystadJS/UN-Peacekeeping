# Protection or apparent protection around MONUSCO

## Local violence and observation uncertainty in a quarterly pilot

Prepared for Marc A. Scott | 6 November 2026

**The pilot does not establish a protective or harmful deployment association.** It provides a reproducible assessment of what a multilevel count model can recover, where that recovery fails, and how measurement assumptions affect interpretation. The history-adjusted model modestly improves retrospective prediction, but the average gain is concentrated geographically. The contribution is a methodological application with an empirical case, rather than a new identification result.

## Scope and measurement

The original question concerned variation across localities in the association between peacekeeping presence and subsequent recorded violence. The audit narrowed that ambition. The active study covers 2016-2023 in Nord-Kivu, Sud-Kivu and Ituri, using 19 fixed city-territory composites. Nine have complete eligible deployment histories, yielding 288 locality-quarters and 1,248 retained one-sided violence events. Their selection is based on full-period exposure availability and limits generalization.

The primary outcome counts UCDP GED 26.1 events with exact-place coding, a unique geographic assignment and dates contained in one month. UCDP's qualifying lethal organized violence is not a measure of all civilian harm. Recorded civilian fatalities in the same events form a separate outcome. The workflow preserves source versions, hashes, exclusions and geographic crosswalks; original and row-level derived files remain separate from published summaries. [1, 3]

Geo-PKO 2.3 supplies listed military strength, excluding formed police units, rather than a verified presence-versus-absence contrast. Monthly rows carry source-map information forward. The exposure is the previous quarter's mean listed strength per 1,000 personnel, requiring three usable months and map ages no greater than five months. Unlisted deployment remains unknown. A three-month rule leaves no uninterrupted locality series, although an unbalanced analysis is possible. Quarterly aggregation reduces temporal detail without resolving uncertainty about when deployments changed. [2]

## Model and estimand

The negative-binomial model includes a locality random intercept, province effects, a linear quarterly trend and seasonality. It separates within-locality deviations in lagged strength from between-locality mean strength, then adjusts for the log-transformed previous recorded event count, prior violent-spell duration and an earlier strength lag. The target is a common conditional within-locality association per 1,000 personnel.

Locality-specific deployment slopes were not fitted. Only eight of the nine retained localities supply within-strength variation, and within-centered adjacent strength lags correlate 0.954. These constraints support caution about recoverable heterogeneity; they do not show that heterogeneity is absent. The empirical coefficient is -0.133 (95% Wald interval [-0.770, 0.504]). The corresponding count ratio is **0.876 [0.463, 1.656]**. Both directions remain compatible with the interval.

<!-- pagebreak -->

## What simulation establishes

Simulation preceded empirical fitting. An initial fixed-design experiment used 800 fits. The subsequent dynamic evaluation used the actual nine-locality exposure schedule as a base, with synthetic counts, known coefficients and explicit initial histories; the selection scenario perturbed that schedule. It retained 1,400 fits across 1,200 generated panels; two estimators were applied to the same 200 prehistory panels. The ordinary model was tested under favorable and null conditions, correlated prehistory, responsive deployment and differential recording. Each scenario used 200 replications.

![Simulation recovery across controlled and adverse scenarios](figures/figure_2_simulation_recovery_memo.png)

*Figure 1. Synthetic recovery on the audited exposure design. The plotted mean estimates and their Monte Carlo intervals summarize repeated simulations; they are not empirical locality effects or individual coefficient intervals. Coverage refers to nominal 95% coefficient intervals. The known nonnull coefficient is -0.30.*

The ordinary model passed its prespecified favorable and initial-condition screens. Coverage was 95.5% in the favorable scenario and 93.5% with correlated prehistory. The matched prehistory null gave 95.5% coverage and a 4.5% false-direction rate. Its bias of 0.042, with Monte Carlo SE 0.023, was close to the 0.05 tolerance. Passing this finite screen does not establish negligible bias more generally.

The adverse scenarios were informative failures. Deployment responding to past violence and hidden risk produced bias of +0.313 and coverage of 68%; differential recording produced bias of +0.312 and coverage of 81%. Successful numerical estimation therefore coexisted with poor recovery of the known coefficient. Even favorable RMSE was about 0.32, comparable to the magnitude of the simulated effect. The design offers limited precision.

The simulation is illustrative rather than calibrated to every empirical parameter. Its correlated prehistory comes from a finite 40-quarter run, not a proof of stationarity. An initial-condition adjustment was diagnostic only and could not be transferred unchanged to the empirical design because its columns were redundant. No new theorem, latent-state identification, or recoverable local slope distribution is claimed.

<!-- pagebreak -->

## Empirical sensitivity and remaining dependence

All 17 history-model deletion intervals included zero, but point estimates moved appreciably. Removing 2017 changed the slope from -0.133 to -0.535. All 11 measurement, secondary-outcome and monthly specification intervals also included zero. Early and midpoint deployment-change assumptions shifted the point estimate to +0.193 and +0.347. The monthly and fatality analogues change the target and have not received matching simulation validation.

![Sensitivity to assumed relative recording probabilities](figures/figure_3_reporting_sensitivity_memo.png)

*Figure 2. Assumed recording differences can change the inferred association. The band is a model-based 95% interval conditional on each recording ratio. Movement across the curve represents changes in assumptions. The curve is an exact algebraic coefficient shift, not an estimate of actual recording probabilities.*

For the log-linear recording model, the point estimate changes sign at an assumed probability ratio of 0.876 per additional 1,000 personnel. The conditional interval becomes wholly positive below 0.463 or wholly negative above 1.656. Equal recording probabilities leave the original inconclusive result. Nonlinear recording assumptions give different thresholds; none of these calculations removes deployment confounding.

Residual checks also limit interpretation. The history model's median lag-two randomized-residual correlation was 0.140, above its conditional reference bound of 0.114. Its range across randomizations overlapped the envelope, while a deterministic Pearson check gave 0.189. This is a warning about unresolved temporal structure, not a calibrated significance test. The mean spatial statistic fell inside a narrow reference based on a two-neighbor graph among the nine retained localities; other spatial patterns remain possible.

Conditional count simulations reproduced the inspected history-model summaries, including zero frequency and the number of large counts. They held fitted effects and observed histories fixed, so they did not evaluate evolving trajectories or full parameter uncertainty. All 34 deletion fits and 44 sensitivity fits met numerical checks. This supports reproducibility of the calculations, not universal model adequacy.

<!-- pagebreak -->

## Prediction and discussion

Expanding training windows predicted 2019 Q1 through 2023 Q4, using training-only exposure means and preceding-quarter outcomes. All 40 fits were usable, producing 180 held-out forecasts per model. The history model improved mean log score by 0.0429 and performed better in 14 of 20 quarters. Only four of nine locality averages improved; excluding Irumu's scores reversed the aggregate advantage. This concentration check changes score aggregation without refitting the models.

| Held-out metric | Baseline | History |
|---|---:|---:|
| Mean log score | -2.2296 | -2.1867 |
| Mean absolute count error | 5.004 | 3.805 |
| Observed coverage of 95% intervals | 95.0% | 95.0% |
| Mean 95% interval width | 22.98 | 17.07 |

The intervals are conditional plug-in NB2 predictions and omit uncertainty in estimated parameters and locality effects. The localities were selected retrospectively. Historical release vintages were unavailable, so occurrence dates do not establish real-time availability. The results therefore concern recorded violence under retrospective information, not operational forecasting or latent violence.

This application connects to your work on prediction and uncertainty conditional on sequence history, the IES project's concern with heterogeneity and overstated certainty, and thinkCausal's attention to methods as implemented in practice. [4-6] It does not implement the sequence paper's decomposition or evaluate software usability. The repository makes the underlying work inspectable: source reconciliation, multilevel estimation, simulation with known truth, and tests of assumptions and uncertainty.

I would next compare the current model with one prespecified second violence-history lag, retaining the same measurement rules and evaluating both models in matched simulation and rolling prediction. The comparison should be judged by recovery and prediction before examining whether the deployment coefficient becomes more favorable. Two questions would help bound that extension:

1. With residual lag-two structure and nine localities, would a second violence-history lag be informative, or would it mainly add instability?
2. What simulation evidence and deployment variation would justify reintroducing locality-specific deployment slopes?

Better deployment-change dates, verification of listing completeness and historical event-publication records would reduce uncertainty that richer regression alone cannot resolve. The current findings support methodological discussion without protection rankings or deployment recommendations.

### Sources and reproducibility

[1] [UCDP methodology and GED](https://www.uu.se/en/department/peace-and-conflict-research/research/ucdp/ucdp-methodology.html), GED 26.1. [2] [Geo-PKO dataset](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset), version 2.3. [3] [Repository findings and reproducible evidence](https://github.com/LystadJS/UN-Peacekeeping/blob/36f4b09adcddb954db3de59975155fc95659f513/docs/quarterly_evaluation_findings.md).

[4] Scott, Pennoni and Bórquez (2026), [Knowing What We Don't Know](https://doi.org/10.3390/e28070730). [5] NYU, [IES project on heterogeneity and uncertainty](https://steinhardt.nyu.edu/priism/what-when-and-whom). [6] Perrett, Hill, Srivastava and Scott (2026), [thinkCausal software evaluation](https://doi.org/10.1080/00031305.2026.2627264).
