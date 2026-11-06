# Conditional quarterly empirical protocol

Prepared 2026-11-06 before empirical fitting. This addendum specifies a bounded descriptive comparison; it does not itself open the empirical gate. `scripts/fit_quarterly_empirical.R` must stop unless both `history_extension_validated` and `empirical_ready` are explicitly true in `data/pilot_validation_status.json`. The parent protocol's separate measurement decision remains required.

## Sample and models

Use the existing nine-locality, 288-quarter panel, 2016 Q1 through 2023 Q4, without selecting localities on outcomes. The response is the strict retained UCDP one-sided event count. Unknown deployment is never recoded as absence. All rows require complete prior count, uncensored prior violent-spell duration, and second deployment lag. No empirical outcome fitting has been performed by this preparation task.

Both models use `glmmTMB`, `nbinom2()`, default estimation settings, and a locality random intercept. The baseline contains linear quarter index, four-level calendar quarter, and province. The history model adds within-centered prior-quarter listed military strength, its locality mean, log(1 + prior recorded count), prior violent-spell duration, and strength two quarters before the outcome. This formula and estimator match the ordinary dynamic simulation exactly. Strength units are 1,000 personnel. No varying slopes, initial-condition adjustments, interactions, or estimator searches are authorized by this addendum.

The target coefficient is the common conditional within-locality association with lagged listed strength, given the other covariates. It is not a causal deployment effect. Full-period centering is retrospective; predictive validation would require training-window construction. Prior GED event dates likewise do not establish that the records were available in real time.

## Known design constraints

Within-centered first and second strength lags correlate 0.954. The ordinary-history fixed design has full column rank; adding both initial event count and initial spell makes the empirical matrix rank deficient. Therefore the initial-adjusted simulation model is not substituted automatically. Shabunda has no within-strength changes and does not directly identify the within-locality strength coefficient. Only nine locality intercepts are available; uncertainty about their distribution remains material.

The five-month map-age rule is a measurement assumption. Carried-forward rows do not represent independently measured monthly deployments. The alternative three-month rule leaves no complete localities, so this analysis cannot be described as robust to that restriction. The sample is conditional on complete listed exposure, not representative of every locality or of no-deployment conditions.

## Saved summaries and interpretation

Save fitted model RDS objects; fixed-effect coefficients, standard errors and 95% Wald intervals; optimizer convergence; positive-definite Hessian status; NB2 dispersion; Pearson residual sum divided by residual degrees of freedom; observed and fitted conditional zero fractions; warnings, timing, package versions, and the gate snapshot and panel fingerprint. Retain failed fits in the diagnostics. Mark nonconverged or nonfinite results unusable rather than treating them as substantive findings.

The Pearson ratio and zero fraction are descriptive checks, not complete goodness-of-fit tests. The expected zero fraction conditions on fitted locality effects. Temporal/spatial residual assessment, extreme-count reproduction, influence analysis, timing/reporting sensitivities and rolling predictive validation are deferred. A successful fit alone establishes none of these. Do not claim predictive validation, causal identification, or supported locality rankings from this entry point.

## Conditional measurement decision — 2026-11-06, before coefficient fitting

Proceed with the two bounded descriptive fits specified above once the independently checked ordinary history gates pass. This decision accepts the existing five-month map-age rule as a disclosed pilot measurement assumption. It does not certify deployment absence, precise deployment-change dates, completeness of violence reporting, or generalizability outside the nine listed-exposure localities. Unknown deployment is excluded rather than treated as zero. Panel accounting, history completeness, source trace, fixed-effect rank, and protocol matching have passed their checks.

Selection and recording stress scenarios are expected limitations of the conditional association, not identification tests that observational data can pass. Their failures must accompany any coefficient reporting. The readiness flag applies only to the baseline and common-slope history fits in this addendum; it does not authorize claims of forecasting validity, supported heterogeneity, or operational recommendations. The initial-adjusted estimator remains excluded.

## Follow-up evaluation authorization — 2026-11-06

The user subsequently authorized residual/influence checks, sensitivity analysis, and predictive validation. Their detailed rules are in quarterly_evaluation_scope.md and the diagnostic, sensitivity and prediction protocols. The formerly deferred checks listed above have now been performed within those explicit scopes. See quarterly_evaluation_findings.md for results and unresolved limitations; no causal or operational claims were thereby authorized.
