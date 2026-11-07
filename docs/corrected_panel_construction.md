# Separately versioned corrected-panel construction

Prepared 7 November 2026 for the authorized retrospective sensitivity analysis. **The original panel, source files and original fitted models remain unchanged.** The new panels retain the same 608 locality-quarters, nine-locality/288-row complete-history sample, outcomes, conflict histories, season factors and estimator-ready schema.

## Corrections and source lineage

`scripts/build_corrected_panel_sensitivity.R` links each published monthly deployment row to its exact source-map record using map identifier, map month, location, original coordinates and original strength. The join is many-to-one, preserves unique monthly source-row identifiers and must leave no unmatched row. Older 2013 maps are included in the lookup because some 2014 history rows carry those sources; the existing maximum map-age rule still excludes stale values.

The supported-corrections scenario applies the [adjudicated source decisions](deployment_adjudication_findings.md):

- Nyamilima's settlement/locality assignment changes to Rutshuru for all 17 source-map rows in the pilot window, propagating to all 47 associated monthly rows from February 2020 through December 2023. The candidate coordinate remains a settlement point, not a surveyed military compound.
- On revisions 49–51 only, the military components are Rwindi 650 and Nyamilima 150. The military component at Bukavu on revision 49 becomes 300 after the FPU correction. Mavivi's adjudicated 2,200 agrees with its existing total and does not change the supported panel.
- November 2023 revision 52 receives the documented Nyamilima geographic correction, but its existing unit coding is not replaced by an extrapolation from the three adjudicated maps. Its November–December values cannot affect an outcome-quarter first or second deployment lag within the 2016–2023 fitting window.

The separate `mavivi_plus_150` scenario adds 150 to Mavivi's revision-51 military component and propagates that assumption through August–October 2023. It represents the disputed larger contributor subtotal, not an established correction or known actual staffing. All scenarios retain unknown numerical strengths and unknown unlisted localities; no unknown absence becomes zero.

## Aggregation, histories and centering

The rebuild uses the provider's original monthly carry-forward schedule and the original three-known-month quarterly rule. Known monthly military strengths are summed by locality; a quarter is usable only when every month is known and its maximum source-map age is at most five months. Quarterly means remain in thousands of coded personnel. First and second deployment lags are reconstructed from the expanded 2014–2023 history rather than changed directly in the fitted panel.

Between-locality means are recomputed over each locality's 2016–2023 first-lag series; within-locality deviations are recomputed from those means. This matches the original retrospective association specification, not an online forecasting construction. Consequently, a late-period source correction can change centered predictors in earlier rows even though their raw lagged exposure did not change. No outcome history, locality selection or held-out forecasting scheme is altered.

Before applying corrections, the `original_reconstructed` scenario must reproduce every field of the frozen 30-column panel, including missingness and ordering; numeric tolerance is 1e-10. Complete-history membership and history-completeness flags must remain unchanged in both corrected scenarios. This checks that new results are not attributable to unrelated panel-construction drift.

## Panel consequences and outputs

Supported corrections change 17 first-lag cells and 16 second-lag cells; full-sample centering changes 64 within/between cells across Rutshuru and Kabare. The maximum raw deployment-lag change is 0.65 thousand personnel. The disputed Mavivi alternative adds one changed first-lag cell in Beni in 2023 Q4; its centered predictors change across all 32 Beni quarters. It adds no second-lag change inside the fitting window.

Four public generated tables preserve input fingerprints, changed-field counts, changed source-map/month lineage and scenario definitions. Detailed outputs remain private under `outputs/corrected_panel_sensitivity/{original_reconstructed,supported_corrections,mavivi_plus_150}/`: monthly source lineage, monthly exposure grid, all-locality and core panels in CSV/RDS form, and scenario-versus-original exposure differences for the two corrected scenarios.

The construction script fits no models. Model results are produced separately by `scripts/fit_corrected_panel_sensitivity.R`; the original-source snapshot is checked independently. These sensitivities do not resolve historical release availability, the missing September information set, exact base footprints or actual unsized personnel.
