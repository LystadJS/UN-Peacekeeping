# Week 1 feasibility decision

**Decision: REVISE THE DESIGN before empirical estimation.** Audit date: 2026-11-05 (America/New_York). No deployment association has been estimated; `empirical_ready` remains `FALSE`.

See [audit findings](week_1_audit.md) and [machine-readable checks](../data/audit_checks.csv). The sources support a descriptive feasibility panel, but not the proposed locality-specific binary deployment slopes without further work.

- Sources: 20 acquired and hashed artifacts, including UCDP GED 26.1, Geo-PKO 2.3, and historical SALB boundaries; see manifest.
- Audit window: 2015–2023 with 2014 history inspected.
- Leading geography: 19 fixed city–territory composites in North Kivu, South Kivu and Ituri; analytical units rather than legal administrative claims.
- Retention: 2,189 recorded one-sided events in 2,052 unique composite-months; all DRC audit rows accounted for.
- Source integrity: no duplicate GED IDs or Geo-PKO location-time keys; no spatial join expansion; every monthly deployment row matches source-map attributes.
- Timing: 39 source-map updates over 108 months; median interval three months; monthly map age reaches five months.
- Deployment support: nine composites positive throughout; only seven conditional binary switchers with one to three changes each; 823 unlisted composite-months have unverified absence.
- Boundary risk: city aggregation resolves 136 of 137 ambiguous one-sided event matches. One Djugu/Irumu point remains excluded. Three Vido I coordinate/name discrepancies remain flagged. Early Djugu historical geometry is invalid and was not repaired.

## Revised design to validate next

1. Prefer a **2016–2023 quarterly pilot** in the 19 composites for the next protocol revision. This avoids unresolved early-2015 Djugu equivalence and better reflects map cadence. Quarters do not eliminate carry-forward uncertainty; retain monthly timing sensitivity.
2. Review original mission maps before coding unlisted locations as absence. Preserve unknown status and its sample-selection consequences.
3. Evaluate a common-slope **listed military-strength contrast** among adequately observed localities. This changes the question to variation in recorded strength conditional on observation; it is not deployment versus no deployment. Freeze its scale and availability rule before fitting.
4. Hold varying deployment slopes behind simulation recovery checks matched to empirical sparsity and map cadence. The simulation-supported assessment remains useful even if empirical random slopes are dropped.
5. Freeze revised geography, period, precision filters and estimand before model fitting. Preserve exclusions and test their sensitivity. Keep raw files local under source-specific terms.

This decision is based on measurement and design support, not an adverse estimated peacekeeping association. It does not establish causal effects, locality rankings or operational recommendations.
