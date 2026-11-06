# Quarterly sensitivity protocol

Recorded 2026-11-06 before these sensitivity fits. The initial history coefficient is already known, so these are explicitly follow-up sensitivity analyses rather than a preregistration of the primary result. The baseline specification and numerical usability rule are unchanged. No thresholds are selected to obtain a preferred empirical sign.

## Reporting assumptions

Keep recorded event counts unchanged and add a known `log(q)` offset to the NB2 mean. The implied underlying qualifying-event mean is conditional on that assumed q, not an estimated correction. Use log-linear q = 0.8 exp(lambda * strength - max(lambda * strength)) over the observed nine-locality panel, lambda from log(0.25) to log(4) in 81 equally spaced steps. This keeps probabilities positive and at most 0.8. The relative recording probability for a 1,000-personnel increment is exp(lambda), where both exposure values are in the observed range. The normalization is illustrative and does not identify absolute recording completeness.

Because strength equals its within and between components, this offset is exactly collinear with existing predictors: both strength coefficients shift by minus lambda, while the intercept absorbs the normalization. Thus this curve is an algebraic sensitivity translation, not additional empirical evidence. Verify it with three actual offset fits and report analytic sign/inconclusiveness thresholds. Confidence bands are model-based intervals within each assumed q; their movement across lambda represents assumption uncertainty.

Also fit 21 nonlinear alternatives q = logistic(logit(0.65) + k * within-strength), k equally spaced from -2 to 2. Label the horizontal contrast q(within-strength=1)/q(within-strength=0), not a constant ratio at every exposure. Save each scenario's observed q range. These are illustrative deployment-dependent assumptions; unobserved risk-dependent reporting and deployment confounding remain unresolved.

## Measurement scenarios

Retain the same nine originally selected localities unless a scenario explicitly loses eligible rows. Recalculate means on each retained estimation sample and disclose changed sample composition.

1. Baseline five-month source-map age rule, 288 quarters.
2. Three-month age rule applied to both lag-1 and lag-2 deployment quarters, creating an unbalanced subset. Fit a paired five-month reference on exactly those rows to expose sample-selection versus exposure differences.
3. Retrospective earlier deployment changes: between consecutive map dates with positive finite strength at both endpoints, switch to the later value at the first intervening month, or at the first month on/after the interval midpoint. Actual map-date values stay unchanged. Modify only months already listed with known strength; never infer zero or fill unknown intervals. Preserve the old value where endpoints are unavailable and after the final map. These timing scenarios intentionally use later maps and are not forecasting inputs.
4. Accept date intervals contained in one quarter instead of one month; preserve exact-place and unique-polygon requirements. Rebuild outcome histories consistently from 2014 onward.
5. Accept location precision codes 1 or 2 with a unique polygon assignment, retaining month-contained dates. This admits less precise coordinates; it does not establish correct locality assignment.
6. Separately assign the flagged exact-place boundary event 470483 to named Irumu; assign the flagged exact-place Vido event 451304 to named Beni. These are alternative name-based assignments, not verified repairs. Other precision rules stay fixed.
7. Fit civilian fatalities among retained one-sided events as a separate NB2 outcome, retaining the primary recorded-event history controls. This exploratory severity model has not received its own simulation validation; its counts and interpretation are not interchangeable with event frequency.
8. Fit an exploratory monthly analogue for the same nine localities: one-month strength/event/spell histories, second monthly strength lag, 12-level month seasonality, and linear time in quarter units. It has a different horizon and history definition; its uncertainty is not validated by the quarterly simulation. It is a structural aggregation contrast, not an exact replication of the quarterly estimand.

## Evaluation and outputs

For every fit retain row/event totals, strength variation, fixed-effect rank, optimizer convergence, Hessian status, random-intercept SD, warnings, slope, SE and Wald interval. Rank failure or a nonconverged/nonfinite fit is retained as unusable. Save row-level scenario panels and fitted objects locally; track aggregate results and reproducible code. Inspect reporting and specification figures. Independently verify baseline reproduction, q bounds/algebra, unique keys, changed-event accounting, timing changes bounded by adjacent maps, and age-three paired-sample equality.

No causal effect, recovered true violence, validated monthly/fatality estimator, or robustness to every plausible reporting process is claimed. Changes in sign with an interval spanning zero remain inconclusive.

## Reporting-risk amendment — 2026-11-06

After the original strength-only results and before the following nine additional fits, add the explicitly illustrative grid logit(q) = logit(0.65) + a * within-strength + b * centered log(1 + prior recorded events), with a in {-1, 0, 1} and b in {-0.5, 0, 0.5}. Center the risk proxy by its overall mean in the nine-locality panel. This proxy is recorded history, not observed latent risk or externally estimated reporting completeness. Retain all nine fits separately and do not select a/b from their results. This small grid examines assumed joint recording dependence; it does not resolve unmeasured deployment confounding or exhaust plausible reporting mechanisms.
