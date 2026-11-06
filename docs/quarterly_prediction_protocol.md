# Quarterly rolling predictive evaluation protocol

Recorded 2026-11-06 before this evaluation is fitted. The user authorized completion of predictive validation. The evaluated models are the existing baseline and ordinary history NB2 random-intercept specifications; no estimator search or outcome-based tuning will occur.

## Population and timing

Use the existing nine-locality complete-exposure panel, 2016 Q1–2023 Q4. Train initially on 12 quarters through 2018 Q4 and predict each next quarter, expanding the training window through 2023 Q3. This yields 20 one-quarter-ahead folds, each with nine held-out outcomes (180 outcome forecasts per model).

The nine localities were selected using full-period exposure availability. Accordingly this is a retrospective evaluation conditional on that selected population, not a prospective eligibility design or evaluation in new localities. The released GED retrospectively incorporates later reporting and revision. Prior occurrence dates do not establish real-time availability at forecast origin. Deployment histories also derive from retrospectively assembled maps.

For every fold, calculate the locality mean of lagged strength from training rows only, overwrite both training and test centering, and use that same training mean for the test within-strength deviation. All outcome/history predictors precede the held-out outcome quarter. The next quarter's lagged recorded count is the preceding quarter's observed count, not a recursively forecast count: this is one-step prediction. No held-out count enters model fitting, centering, thresholds, or random-effect estimation.

## Models and predictive distribution

Fit `glmmTMB(..., family=nbinom2())` with default estimation settings. Baseline: linear quarter index, quarter-of-year factor, province, and locality random intercept. History: additionally within and between lagged listed strength, `log1p(events_lag)`, `violent_spell_lag`, and `strength_lag2`, exactly matching the ordinary dynamic model.

Use training-fitted conditional means for known localities and training-estimated NB2 size. The predictive distribution is **conditional plug-in NB2**: it includes count-process variation, but excludes parameter uncertainty and uncertainty in estimated random effects. Its interval coverage is an empirical diagnostic of that particular procedure, not a claim that its intervals represent all forecast uncertainty. Prediction uses `re.form=NULL` and never re-estimates locality effects from test outcomes.

## Metrics, failures, and checks

Save all 40 attempted fits, warnings, optimizer codes, Hessian status, training/test sizes, training strength means, training-only high-count threshold, and elapsed time. A usable fold requires convergence zero, positive-definite Hessian, finite coefficients/standard errors, finite positive predicted means, and finite positive NB2 size. Do not silently replace failed fits or omit their attempted-fold denominators.

For usable predictions, report mean log predictive probability (higher is better), mean absolute error, central 80% and 95% NB2 count-interval coverage and width, and sample sizes. Central discrete intervals use `qnbinom` at 0.10/0.90 and 0.025/0.975; discreteness can produce coverage above the nominal level. Pair model comparisons on identical locality-quarter forecasts where both fits are usable. Report fold-specific differences and their overall mean; do not treat 180 correlated forecasts as independent evidence for a formal significance test.

Define high-violence forecast outcomes as counts strictly greater than the training-only 90th percentile of recorded events, using R quantile type 7. This is a retrospective outcome-stratified diagnostic; it is not a forecast-time high-risk classification. Report its selected denominator, scores, coverage and widths separately, retaining zero-row groups explicitly.

Independently check unique keys, temporal ordering, prior-count and earlier-strength alignment, exact training means, prediction denominators, NB2 log scores and interval coverage. Produce a fold-score comparison and coverage figure using ggplot2; inspect exported PNGs. Save row-level predictions and models locally; publish aggregate fold/overall results and reproducible code only.

## Descriptive follow-up recorded after initial readout

The small overall log-score difference prompted a concentration check requested during review: report alphabetical locality mean differences and the average difference when each held-out quarter or locality is omitted from score aggregation. These use existing held-out scores, do not refit models, and do not change forecast specifications or validation thresholds. They are exploratory stability summaries, not prespecified formal tests or protection-success rankings.
