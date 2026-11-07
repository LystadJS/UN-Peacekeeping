# Corrected-panel sensitivity protocol

Recorded 7 November 2026 after the source adjudication and before this follow-up's coefficient fits. This is a local analysis commitment, not external preregistration. The user explicitly authorized the corrected-panel analysis and further Mavivi investigation. Original inputs, panels, fitted models and their 18-file snapshot remain unchanged.

## Question and fixed scope

Assess whether the common within-locality listed-strength association and its uncertainty materially change after applying the supported source corrections. Retain the original 2016–2023 quarterly outcome definition, fixed geography, nine-locality/288-row model sample, baseline and ordinary history formulas, `glmmTMB` NB2 family, default estimator, linear calendar trend, season and province effects, and locality random intercept. Do not introduce varying slopes or select estimators from the resulting coefficients.

Rebuild the deployment portion from source lineage, including preperiod information needed for both lags. Reconcile the unmodified reconstruction with the frozen panel before interpreting corrected results. Preserve unknown listings and strengths, original map timing, already allocated geosplits and the five-month freshness rule. Recalculate quarterly averages, first and second lags, locality means and within-locality deviations; do not patch only the final centered variable. Outcome counts, conflict histories and sample membership must remain identical.

## Scenarios fixed before fitting

1. **Original reference:** reproduce the original exposure and model to establish numerical comparability.
2. **Supported corrections:** use the documented Nyamilima settlement/locality correction for all 17 affected source-map rows in the pilot window; apply adjudicated Rwindi/Nyamilima assignments on revisions 49–51 and Bukavu's FPU correction on revision 49. Mavivi's sized-unit total remains 2,200. Do not extrapolate these unit decisions to unreviewed maps.
3. **Mavivi subtotal alternative:** on top of supported corrections, substitute 2,350 for Mavivi revision 51 only, propagating that assumption through the same source-map carry-forward and panel construction. This is an explicit sensitivity assumption motivated by the inconsistent contributor subtotal, not a certified personnel correction. Retain it even if subsequent source investigation supports 2,200 more strongly; document the resulting interpretation.

The exact military compound coordinate and historical download bytes remain unverified. This is a retrospective measurement sensitivity, not an authenticated forecast-origin reconstruction. The baseline model's inputs are unchanged and its fitted object can serve as a shared comparison after equality is verified.

## Evaluation and outputs

Save all scenario panels, changed source rows, map/month/quarter lineage, input hashes, model objects, coefficients, conditional 95% Wald intervals, warnings and computational diagnostics separately. Keep failed fits visible. Check fixed-design rank, optimizer convergence, Hessian status, finite standard errors, dispersion, fitted zero proportions and conditional fitted-mean shifts. Compare the within-strength coefficient and intervals with the original, without interpreting statistical non-significance as proof of equivalence.

Fit nine locality-deletion versions of the supported-correction history model using the original influence procedure. Compare their ranges and the influence of corrected localities with the original analysis; avoid an unbounded estimator or specification search. Conditional fitted-mean comparisons are descriptive, not out-of-sample predictive validation. A new rolling validation or full simulation suite is outside this bounded sensitivity run.

Reproduce the new construction and fitting in the retained isolated environment, requiring exact keys, sample membership and outcome/history values, exposure agreement within absolute 1e-10, and fitted scientific quantities within absolute 1e-6 while excluding elapsed time and other incidental metadata. Verify the original frozen snapshot and the unchanged `docs/project_plan.md`. Update the README's remaining-work checklist and report unresolved source issues separately from completed model sensitivity. Human review remains skipped at the user's direction, not completed.
