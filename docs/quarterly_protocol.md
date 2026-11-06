# Quarterly pilot protocol — revision 1

Recorded 2026-11-05 (America/New_York), before any empirical coefficient fitting or simulation performance inspection for this revision. Supersedes monthly/binary choices in the original protocol. The original remains a record of the proposal.

## Population and estimand

Audit all 19 fixed city–territory composites, 2016 Q1–2023 Q4. Use 2015 Q4 exposure/history for the first outcome quarter. Primary outcome: retained one-sided recorded events. Secondary: civilian fatalities in those events. Retain strict exact-place/single-month assignment for this first pilot; quarter-contained ambiguous dates are a later sensitivity rule, not silently reinstated.

Exposure is **mean listed military strength during the preceding quarter, per 1,000 personnel**, calculated from three monthly stocks (`no.troops - fpu.no`), not their sum. Require all three source-derived months with numeric strength and source-map age at most five months. Unlisted remains unknown, never zero. Preserve source-map identifiers and age; do not interpolate using future maps. Primary centering uses eligible locality mean exposure; prediction uses training means only.

The coefficient is a within-locality conditional log-count association per additional 1,000 listed personnel. This is not a deployed-versus-undeployed contrast. Listing completeness and estimated strength remain measurement assumptions. First validation conditions on localities with complete exposure histories throughout the window; this is a retrospective selected sample and may not generalize to unlisted places or prospective availability.

## Staged model validation

Core NB2 model: locality random intercept, province intercepts, linear quarter index, quarter-of-year fixed effects, within-locality strength and between-locality mean strength. No random deployment slopes. Compare baseline without strength later. The core simulation gate must precede adding log(1+prior-quarter events), violent-spell duration and earlier deployment history; the history extension needs a matching dynamic simulation gate. A successful core gate alone does not validate that extension.

The favorable generator uses the actual eligible exposure schedules and calendar/province design, with synthetic outcomes only. NB2 size 2, random-intercept SD 0.6, intercept 1.5, between-strength coefficient 0.15, quarter trend 0.005 and seasonal log effects (0,0.10,-0.10,0.05). True within coefficient -0.30; null scenario 0. Recording q=0.65 is constant in favorable cases, preserving the log slope under binomial thinning.

Stress tests: (a) recording logit depends on within-strength and latent risk; (b) unobserved time-varying risk correlated with strength, representing an adverse selection/confounding configuration. These are illustrative mechanisms, not estimated DRC reporting or deployment processes. The stress confounding scenario is not a full model of deployment responding to past violence; dynamic history/selection is a separate required extension.

Run 200 replicates per scenario with seed base 20261106; save every fit, warning, convergence flag, runtime and generator seed. The generating parameters and fixed exposure design reconstruct every synthetic dataset. A fit is usable only with convergence code zero, positive-definite Hessian and finite positive slope SE. Never drop failed runs from the fit-rate denominator.

**Prespecified core gate:** favorable and null scenarios each require usable-fit rate >=95%; absolute slope bias <=0.05; 95% Wald interval coverage >=90%; Monte Carlo SE of coverage <=0.02. Null confidently nonzero rate must be <=10%. Report bias MCSE, RMSE, coverage and directional-error MCSE. Wrong direction means an interval excludes zero opposite the true sign; under null use either nonzero direction. Also report success-and-coverage over all attempted runs. These are pilot tolerances, not proof of uniform validity. If a gate fails, investigate and record changes before rerunning; do not silently tune the threshold.

## Before empirical fitting

Both exposure coverage and simulation gates must pass. Source-map spot checks may clarify mapped presence but cannot certify absence over all unreviewed dates or operational patrol activity. Unlisted months stay excluded. Investigate changed totals, unknown strength and source-map replication. For later prediction, use expanding windows beginning after 12 quarters and predict the next quarter using only prior-quarter covariates; retrospective release data do not establish real-time forecast availability.

Report residual dependence, predictive count checks, influence and small-cluster uncertainty. Strength reporting sensitivity uses a declared continuous q(strength,risk) grid and log(q) offsets, not binary q1/q0 unless a binary contrast is explicitly reintroduced. Empirical fitting remains disabled in the current task until results of this validation and remaining measurement gates are recorded.

## Audit addendum — 2026-11-06

The quarterly panel and its histories are now constructed and independently checked; see [panel audit](quarterly_panel_audit.md). The 2016 Q1 second strength lag uses 2015 Q3, and violent-spell history extends to 2014 with explicit left-censor flags. Event occurrence histories remain retrospective, not evidence of real-time data availability.

The [freshness audit](quarterly_freshness_audit.md) shows that the nine-locality complete-exposure design depends on permitting five-month-old source maps. A three-month rule retains 343 locality-quarters but no complete locality. This finding is reported without changing the rule to optimize outcome estimates. Eligibility now explicitly rejects negative/nonfinite strength or source age and requires exactly three months.

The [dynamic protocol](dynamic_quarterly_protocol.md) governs history-model validation, including initial-condition stress and a separately specified matched null check. Its adjusted initial-state model is diagnostic unless separately validated. No substantive empirical deployment estimate has been inspected in making these additions.
