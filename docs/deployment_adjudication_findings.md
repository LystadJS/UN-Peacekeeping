# Deployment-coding adjudication: decisions and remaining work

**Sensitivity follow-up — 2026-11-07:** The [Mavivi analysis choice and separately versioned corrected-panel sensitivity](corrected_panel_sensitivity_findings.md) are now complete. The primary total is 2,200; the 2,350 alternative was tested. The original field's cause remains unverified. This supersedes the analysis-blocker wording below without changing original source rows or fits.

Completed 7 November 2026. **All ten previously identified component discrepancies have been adjudicated, and Nyamilima's settlement/locality mismatch is resolved for a correction scenario.** This does not certify actual headcounts, exact base coordinates or a complete historical information set. A separate August 2023 contributor-subtotal inconsistency remains unresolved.

## Decisions

| Issue | Decision | Consequence |
|---|---|---|
| Mavivi, three 2023 maps | Earlier agent readings mistakenly counted unsized helicopter support as a company. The sized component is 2,200. | Retain the published total; correct our earlier interpretation. TIU was already included. |
| Bukavu, February 2023 | The total includes an Egyptian FPU company, but the FPU field incorrectly records zero. | Military-only component is 450 − 150 = 300. The extra 150 was not an assumed MP headcount. |
| Rwindi and Nyamilima, six rows | Map leaders and independent geography support Rwindi 650 and Nyamilima 150. | Preserve these site assignments in the correction decisions rather than the reversed provider assignments. |
| Nyamilima locality | Historical settlement coordinates and a 2015 UN publication support Rutshuru. The provider point falls in Lubutu, Maniema, about 235.8 km away. | A documented settlement-point correction is available; the exact military compound remains unverified. |

The [ten-row decision ledger](../data/deployment_symbol_adjudication.csv) preserves both earlier readings and adjudicated values. Read the [symbol evidence](deployment_symbol_adjudication.md), [provider component audit](deployment_coding_conventions.md), and [geographic adjudication](nyamilima_geography_adjudication.md) for the underlying sources. Earlier transcriptions remain intact as superseded evidence, not silent corrections.

## Consequences for locality subtotals

The [impact table](../data/deployment_adjudication_locality_impact.csv) crosses unit decisions with the geographic decision. It compares source-map subtotals, not monthly exposures, quarterly coefficients or actual personnel totals.

| Locality | Combined change from current coding |
|---|---|
| Rutshuru | +650 on each of revisions 49, 50 and 51: subtotal 450 becomes 1,100. |
| Kabare including Bukavu | −150 on revision 49: subtotal 900 becomes 750. No change on revisions 50 or 51. |
| Beni including city | No change on these maps. The earlier Mavivi discrepancy was a transcription error. |

For Rutshuru, unit decisions alone would add 500 while Nyamilima remained outside the geographic join. Geography alone adds 650 under the original coding. Applying both still adds 650: the site-value interchange then cancels within Rutshuru, but recovering the previously excluded site does not. These effects must not be summed as independent adjustments.

The geographic issue affects all 17 Nyamilima source rows in the full pilot window, beginning in 2020. The impact table deliberately examines only the three adjudicated 2023 maps. A corrected-panel sensitivity analysis must separately audit the broader lineage, timing, lags and centering rather than extrapolate these map-level changes into fitted results.

## What remains unresolved

Mavivi revision 51's known troop-contributor subtotals sum to **2,350**, while its total and unit-count arithmetic give **2,200** and its comments still describe helicopter support as unsized. The original ten-row discrepancy is resolved at the source-symbol/component level; the reason for this separate cross-field inconsistency remains unknown. The larger subtotal is not substituted for the total.

Exact compound coordinates, unsized actual personnel, other unresolved map sites, historical digital availability and September coded outcome information remain separate gaps. No provider was contacted. No frozen source file, original panel or fitted model was changed, and no corrected-panel sensitivity model was fitted. Human review remains skipped at the user's request, not completed.

## Reproduction

After the preceding reconstruction, run `scripts/audit_deployment_coding_conventions.R`, `scripts/adjudicate_nyamilima_geography.R`, `scripts/audit_deployment_adjudication_impact.R`, and `tests/run_deployment_adjudication_checks.R`. Static source manifests and decisions are inputs; the clean workflow stages only their original artifacts and regenerates derived histories. Detailed source rows remain private. The numerical checks do not themselves validate visual judgment; original PDFs were separately inspected at higher resolution and the decisions independently reviewed by another agent.

The [validation receipt](../data/deployment_adjudication_checks.json) records four generated public tables and three private tables matching the isolated rerun exactly, eight distinct source hashes verified, 384 source-row scenarios and 36 locality subtotals checked, and all 18 frozen analysis files unchanged. The original project-plan file is also unchanged. This is an additive audit, not a corrected-panel fit or a full estimation rerun.
