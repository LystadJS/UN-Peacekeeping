# Dynamic quarterly simulation protocol — revision 1

Original DGP and numerical tolerances recorded 2026-11-06 before running the simulations below. During-run clarifications on the same date label finite prehistory accurately and restrict the adjusted estimator to diagnosis; they do not alter simulations or thresholds. The separate matched-null extension is documented in `dynamic_quarterly_null_extension.md` before its own run. This extends the common-strength core; no empirical outcome model is fitted.

## Target and model

Use the nine-locality, 32-quarter exposure design already audited. Strength is the preceding-quarter mean listed military personnel divided by 1,000. The within-strength coefficient is the target (-0.30, or 0 under the null). Fit NB2 with locality random intercept, province, linear time, seasonal quarter, within/between strength, `log1p(events_lag)`, `violent_spell_lag`, and `strength_lag2`.

The favorable/null generator uses all these regressors with coefficients 0.20 for lagged recorded events, 0.01 per prior consecutive violent quarter, and 0.05 per 1,000 earlier personnel. Other parameters: intercept 1.0, between-strength 0.15, random-intercept SD 0.6, NB2 size 2, time trend 0.005, seasons (0,0.10,-0.10,0.05). Counts are thinned with constant q=0.65. Conditional history is recorded history in the favorable design, so thinning preserves the specified conditional log mean. This is an explicit generative assumption, not a claim that actual violence depends only on recorded history.

## Initial conditions and stress cases

Favorable/null histories start at fixed zero, independently of the random intercept; initial earlier strength equals the first available lagged strength. This is a controlled finite-start validation, **not stationarity** or a faithful reconstruction of the first empirical quarter. A separate correlated-prehistory scenario (machine identifier `stationary_initial`) generates 40 preperiod quarters conditional on the same random intercept, then retains the correlated initial event count and spell. The identifier does not assert stationarity: finite burn-in is not a stationarity proof, particularly with an uncapped positive spell coefficient. Inspect count and spell extremes in the generated samples. Fit the ordinary history model and a prespecified diagnostic variant adding initial log event count and initial spell. That variant is an approximate initial-condition adjustment whose performance must be demonstrated, not assumed.

Five scenarios, 200 replicates each:

1. favorable: fixed-zero initialization, actual strength schedule, constant recording;
2. null: same, strength coefficient zero;
3. selection: positive strength responds to prior recorded events and persistent unobserved risk; latent risk also enters violence;
4. differential recording: q depends on strength and persistent risk, and true violence depends on previous true events rather than observed events;
5. correlated prehistory (`stationary_initial`): favorable data-generating coefficients, but a finite 40-quarter prehistory generated as above.

Risk is AR(1) with coefficient 0.5 and innovation SD 0.5. Selection adds 0.25 log(1+prior recorded events) and 0.25 risk to the base strength, bounded below at 0.01; latent risk adds 0.5 to the log mean in this scenario. Differential reporting uses logit(q)=logit(0.65)+0.8*(strength-base locality mean)-0.4*risk. These stress mechanisms are illustrative; empirical values are not calibrated or fitted.

The favorable mean uses beta*strength + (0.15-beta)*base locality mean, algebraically identical to the within/between model when strength follows the fixed design. Selection uses the same structural parameterization; its observed centered slope need not recover the structural derivative because assignment and latent effects are dependent.

## Evaluation and gate

Seed base 20261107 plus scenario-index*10000 plus replicate. Retain all fit outcomes, errors, warnings, runtimes, convergence codes, Hessian flags and estimated random-intercept SD. Usability requires convergence zero, positive Hessian, finite slope and positive finite SE. Report near-zero random-intercept variance separately rather than hiding it.

Fixed-zero favorable and null must each meet the prior pilot thresholds: at least 95% usable fits; absolute bias <=0.05; 95% Wald coverage >=90%; coverage MCSE <=0.02; null false-direction rate <=10%. Also report bias MCSE, RMSE, conditional coverage, success-and-coverage over all attempts and directional errors. No thresholds change after viewing results.

**Empirical gate additionally requires** acceptable recovery of the ordinary history estimator under correlated prehistory, because observed prehistory is not fixed independently of latent locality risk. The initial-adjusted estimator is diagnostic only: this run contains no matched null validation for it, so it cannot open the empirical gate even if its nonnull recovery is acceptable. If ordinary recovery fails, leave empirical fitting blocked and separately prespecify matched favorable and null validation of any revised estimator rather than omit history regressors. This clarification was recorded during execution, before correlated-prehistory results were available; numerical tolerances and simulations are unchanged. Passing these scenarios still does not establish robustness to reporting bias or endogenous deployment.

The earlier deployment-history boundary in the empirical panel must use 2015 Q3 for a 2016 Q1 outcome. The simulation's repeated initial strength is a stated initial-state assumption, not substituted empirical history. Unresolved left-censoring of violent spells must remain flagged in the empirical panel.
