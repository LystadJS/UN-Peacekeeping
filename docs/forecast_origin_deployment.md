# Deployment evidence at the 1 October 2023 forecast origin

Reconstructed on 2026-11-07 for **2023-10-01 00:00 UTC**, the start of the existing 2023 Q4 forecast fold. The investigation supports availability of the three relevant map identities before this origin. It does **not** authenticate the modern Geo-PKO numeric coding as the exact information distributed in 2023, and it does not certify operational absence anywhere.

## Evidence recovered

Three official UN report PDFs were downloaded from the UN Digital Library, hashed and retained locally. Their covers and final map pages were inspected. Each report contains the map revision cited in the current deployment lineage:

| Current predictor | Represented months | Map identity and reference month | Dated report containing the map |
|---|---|---|---|
| Q2 strength, used as `strength_lag2` | April–May 2023 | 4412 Rev. 49, February 2023 | [S/2023/208](https://digitallibrary.un.org/record/4007100/files/S_2023_208-EN.pdf), 20 March 2023; page 18 |
| Q2 strength and Q3 strength | June–July 2023 | 4412 Rev. 50, June 2023 | [S/2023/451](https://digitallibrary.un.org/record/4013932/files/S_2023_451-EN.pdf), 19 June 2023; page 18 |
| Q3 strength, used as `strength_lag` | August–September 2023 | 4412 Rev. 51, August 2023 | [S/2023/691](https://digitallibrary.un.org/record/4022183/files/S_2023_691-EN.pdf), 21 September 2023; page 18 |

The report covers also carry English production codes dated 23 March, 29 June and 27 September, respectively, all before the origin. The [28 September Security Council meeting record, S/PV.9427](https://documents.un.org/api/symbol/access?l=en&s=S%2FPV.9427&t=pdf), refers to S/2023/691, supporting its circulation before the forecast date. That corroboration was read through indexed official text; it was not downloaded or hashed.

These are dated publication records, not exact first-upload logs or historical byte-for-byte snapshots. The PDFs retrieved now may have been regenerated or superseded after the original report dates. Their matching map identities, report dates and pre-origin discussion support a bounded map-level reconstruction; they do not establish complete revision history. The reference month is not treated as the online release date. In particular, June and August maps need not have been available at the start of those months even though their containing reports precede 1 October.

The initial mission-hosted download was unavailable; the Digital Library downloads succeeded. Original PDFs and hashes are listed in [source provenance](../data/forecast_origin_deployment_sources.csv); they remain under ignored `outputs/forecast_origin/deployment/`. No redistribution permission is assumed. The final map pages were rendered with Poppler and inspected: revision numbers and months match, and positive mission/troop symbols around Beni, Goma and Shabunda are visible. This was an identity and selected-presence check, not exhaustive unit recoding, exact strength verification, or a review of operational reach. Python was used only for PDF text extraction because the bundled PDF reader was practical; data reconciliation uses R.

## Comparison with the current panel

Run `Rscript scripts/audit_forecast_origin_deployment.R` after the retained quarterly panel exists and the three PDFs are present at their manifest paths. The script verifies all three hashes, joins each represented month to its report evidence, and independently rebuilds both current strength lags from source-row lineage and the retained raw Geo-PKO file. It subtracts FPU strength, applies the existing three-month/five-month-age rule, and expresses quarterly means in thousands of listed military personnel.

The [six-month ledger](../data/forecast_origin_deployment_months.csv) covers April–September 2023. Every source-map identity is linked to a dated pre-origin report. Each month contains 32 MONUSCO source rows across the raw lineage, not 32 localities or independent maps. The [19-locality comparison](../data/forecast_origin_deployment_comparison.csv) reproduces the current panel's Q2 and Q3 strengths to numerical tolerance, including missingness. Fourteen candidate localities have nonmissing values for both quarters, including all nine core localities. Five remain missing: Aru, Djugu, Idjwi, Mahagi and Mambasa. Unknown listing is not zero deployment.

For illustration, current Q2 to Q3 strengths change from 0.800 to 0.366667 thousand in Walungu, 2.200 to 2.556667 in Irumu including Bunia, and 0.850 to 0.750 in Kabare including Bukavu. These are comparisons of current coded values, not independently recovered historical staffing changes. No value was changed in the fitted panel.

The output deliberately leaves both `as_of_certified_strength_*` fields missing for all 19 localities. Even for the nine core localities, this study has not recoded all historical symbols, unit-size assumptions, geosplit allocations, FPU deductions or geographic assignments from contemporaneous source versions. A reader may condition a sensitivity exercise on today's coding applied to these dated maps, but must not label that exercise an authenticated vintage forecast.

## What remains unresolved

- **Numeric coding and revision history:** the complete Geo-PKO version actually available at the origin was not acquired. No evidence establishes that today's strengths and coordinates equal its values.
- **Within-quarter timing:** carrying reference-month maps forward is the retained measurement convention. Report dates establish availability by the chosen origin, not actual dates of deployment changes.
- **Unlisted places and temporary operations:** the earlier Djugu investigation documents military presence despite absent panel listings. This map reconstruction does not create an absence category or recover its strength.
- **Geography:** fixed modern SALB-derived composites make comparisons consistent, but their historical digital availability and the crosswalk's contemporaneous use are not certified.
- **Full forecasting input set:** prior event counts, earlier spell history, training-period values and the estimator's historical information set require separate reconstruction. Map evidence alone does not make the current model operationally validated.

The bounded advance is concrete: both required deployment quarters now have identified, retained, pre-origin dated report sources for all three map revisions. The unresolved numerical and historical-information gaps remain explicit. No model was refitted, and human review remains skipped by user instruction, not completed.
