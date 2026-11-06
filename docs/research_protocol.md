# Research protocol — provisional

**Superseded specification:** the user authorized the [2016–2023 quarterly protocol](quarterly_protocol.md). Use that revision for current work; the monthly/binary model below is retained as historical proposal context.

## Scope and interpretation

Estimate conditional within-locality deployment associations and their variation, with predictive validation. Deployment responds to conflict, recording may depend on deployment, and unmeasured confounding remains possible. Neither lagging deployment nor partial pooling establishes causality. The simulation has known structural effects; empirical slopes do not inherit that interpretation.

Use eastern DRC during 2015–2023 only if the source audit supports it. Define provinces and administrative level before extracting outcomes. Acquire pre-2015 history for lag construction; otherwise exclude and document the initial incomplete-history months. Do not treat missing coverage as zero violence or zero deployment.

## Model sequence

Use NB2 counts, with variance mu + mu^2 / phi. Let P be lagged deployment, P_bar the locality mean, and P_within = P - P_bar.

1. Baseline: locality random intercept, calendar effects, province effects.
2. History: baseline plus P_within, P_bar, and prespecified lagged history.
3. Heterogeneity: history model plus locality random deployment slopes, only if variation supports them.

History candidates: log(1 + prior-month recorded events), consecutive violent months ending in the prior month, and deployment two months earlier. Compare history-only against deployment-plus-history if attributing predictive gains specifically to history. Avoid indiscriminate lag searches. Province intercepts and locality random intercepts require multiple localities per province.

The within-locality coefficient is the central association. Estimate locality deviations by partial pooling and report uncertainty in their dispersion. Summarize within-locality transitions, exposed/unexposed months, and independent map updates before fitting slopes. Do not use a universal transition cutoff as a substitute for simulation-based feasibility assessment.

Full-sample descriptive fits may use full-period locality means. For validation, calculate means, scaling, and all other transformations on training data only and apply those values to the test period. Future calendar-month fixed effects cannot be predicted: validation must use an extrapolatable calendar structure (initial candidate: linear month index plus month-of-year effects), with richer trends assessed as sensitivity analyses. Distinguish this predictive specification from saturated retrospective calendar effects.

## Validation and diagnostics

Use expanding-window temporal validation with a prespecified horizon (initial candidate: next month after at least 36 training months). Compute histories only from information available at forecast origin. A multi-month horizon requires recursive simulation of unknown histories; never feed future realized outcomes into those forecasts.

Report held-out predictive log scores and predictive interval coverage, including parameter and random-effect uncertainty. Check overdispersion, zero frequencies, tails, temporal residual correlation, spatial residual structure, optimizer status, Hessian, and slope variance near the boundary. Record failed fits; do not silently omit them. Compare same-locality forecasting separately from new-locality prediction. Any spatial holdout is an additional task, not a substitute for temporal validation.

## Simulation design

Cross deployment selection (off/on), differential recording (off/on), and true slope heterogeneity (off/on): eight cells. Initial generator uses binary deployment, NB2 qualifying event counts, a burn-in, persistent deployment, and binomial recording. Selection responds to previously recorded events; latent locality risk also affects deployment when selection is enabled. Differential recording depends on deployment and latent risk. These are explicit stress-test mechanisms, not calibrated descriptions of DRC.

Known truth includes the average structural log effect and local structural effects. Compare fitted within-locality slopes to those truths as a recovery challenge; dynamic feedback and model misspecification can make the fitted associational target differ. Include oracle fits using true counts and risk to separate modeling failures from observation failures. Sweep recording effects in both directions before drawing general conclusions; the starter setting increases recording under deployment.

Start with a few replicates for debugging, then choose replicates from Monte Carlo precision (for example, coverage MCSE sqrt(p*(1-p)/R)). Report coefficient bias/RMSE, 95% interval coverage, slope-SD recovery, local-slope recovery, incorrect directional conclusions, convergence and failure rates. A directional error means a 95% interval excludes zero opposite the true sign; when truth is zero, report false directional claims separately. Boundary variance inference requires profile/bootstrap or a justified Bayesian alternative, not a naive symmetric Wald interval.

## Recording sensitivity

Assume Y_observed | Y_true ~ Binomial(Y_true, q). Under NB thinning and fixed q, the observed mean is q * mu_true. Refit with log(q) as an offset across declared q scenarios; do not divide observed counts by q and treat fractional values as counts.

For binary lagged presence, vary q0 and q1 in (0,1], showing q1/q0 and the within-locality estimate and interval. State whether history remains recorded history; that analysis does not reconstruct latent conflict history. A constant recording ratio offers an analytic coefficient-shift check, but variable risk-dependent recording needs explicit refitting. Plot model-conditional intervals separately from variation across assumed q. Recording probabilities are not estimated by this exercise, and confounding is not resolved.

## Memo and figures

Produce local trajectories with source-map timing, partially pooled associations with intervals, and the recording sensitivity curve. Do not rank localities as successes/failures. Document unsupported random slopes and inconclusive results as findings rather than hiding them.
