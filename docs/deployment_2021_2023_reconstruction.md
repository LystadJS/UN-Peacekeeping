# Deployment histories for 2021–2023: reconstruction and unresolved gaps

Completed 7 November 2026 for the unchanged 1 October 2023 cutoff. **The work reconstructs retrospective listed-strength histories and substantially expands source-map readings, but it does not recover a complete authenticated historical deployment panel.** The original panel and fitted results are unchanged.

## What has been reconstructed

The newly retrieved official Geo-PKO 2.2 file provides map-level coding through November 2022. A separate retrospective calculation reconstructs monthly listed military strength for January 2021–December 2022, with December explicitly carried from November. The current 2.3 release supplies a separate retrospective comparator through September 2023. Both follow the existing maximum five-month map-age rule, select the highest revision within a source month, subtract FPU strength, retain existing geosplit allocations without dividing them again, and preserve unlisted or unknown localities as missing. These are declared reconstruction assumptions, not independently observed monthly deployments.

On the fixed 19-locality research geography, version 2.2 supplies 336 numerical locality-months across 2021–2022, while 2.3 supplies 462 across January 2021–September 2023. All 336 shared numerical values agree. Five localities remain unlisted/unknown in these retrospective calculations; absence is not inferred from their missing rows. The private two-release monthly grid contains 1,254 rows, including all missing cells. Version 2.2 supplies no 2023 values and is never carried into 2023.

[The release investigation](deployment_release_search.md) does not authenticate version 2.2 before the forecast cutoff. The December 2023 archived provider page still advertises 2.1, and an April 2024 capture advertises 2.2. These page observations do not establish the exact first release or exclude another earlier distribution route. Neither 2.2 nor current 2.3 numerical values are admitted as certified historical predictors.

## Expanded source-map readings

The [new static transcription](../data/deployment_2021_2023_added_transcription.csv) adds 161 site–map readings. Eleven additional sites were inspected on all twelve revisions from February 2021 through August 2023; 29 additional readings address complex 2023 formations and Walungu. Each map image was inspected; repeated values are not inferred by interpolation. Himbe/Himbi is an explicit spelling crosswalk, while the map label Munigi is compared with the existing catalog's Monigi Camp. The readings are unblinded agent interpretations, not independent human transcription.

Combining them with earlier readings yields 279 numerical sized-component readings. The reconciliation contains 429 current-catalog site–map rows plus two unresolved Eringeti readings absent from that catalog, for 431 rows. **The current catalog is only a comparison denominator:** covering all of its sites does not establish that it captured every historical deployment or temporary base.

For the February and June 2023 maps, 31 of 32 catalog sites now have numerical component readings; the remaining site is Kinshasa, outside the research geography. For August, 30 of 32 have readings: Kinshasa and Tshabi remain unresolved. Tshabi maps into Irumu under the current geocoding, and its unit-size symbol requires further adjudication. A complete locality-level coded history therefore cannot be certified from this work. Actual headcounts also remain distinct from symbol-based estimates, especially where MPs have no size marker.

## Discrepancies requiring adjudication

Ten numerical differences are retained rather than forced to agree with the current coding:

| Site and map | Visual sized military component | Current coding | Issue |
|---|---:|---:|---|
| Bukavu, February 2023 | 300 | 450 | Two sized Chinese support companies; MP has no clearly visible size marker |
| Mavivi, February/June/August 2023 | 2,350 | 2,200 | Two battalions plus seven sized companies, including TIU; historical handling of TIU remains unverified |
| Rwindi, February/June/August 2023 | 650 | 150 | India two-bar symbol connects to western point; crowded labels need adjudication |
| Nyamilima, February/June/August 2023 | 150 | 650 | Morocco one-bar symbol connects to eastern point; potential site-coding interchange |

A second agent inspected these 2023 symbols and leaders, but neither reading is human or blinded verification. They identify possible coding differences, not established errors or actual troop changes. Headquarters, observers and individual police do not become infantry companies merely because they carry size-like markings.

The Nyamilima comparison raises an additional geographic issue. Its current coordinates are latitude **−0.5490497**, longitude **27.4724**, and fail the fixed 19-locality boundary join on every reviewed 2021–2023 map. Rwindi joins to Rutshuru. The apparent 500-person interchange therefore **does not cancel inside the retained analysis geography**: a revised site reading could affect its Rutshuru subtotal. No coordinate or frozen-panel value has been changed. Independent location evidence and the original coding decision are needed before correction. See the [difference ledger](../data/deployment_2021_2023_component_differences.csv).

## Available histories versus a complete information set

The private locality-map table includes all 228 locality–map combinations. It records read component sums and whether every current-catalog site was read, separately from the complete historical coded-strength field, which remains missing. The complete requested January 2021–September 2023 grid contains 627 locality-month cells with unresolved historical totals; this is an explicit gap ledger, not a new usable empirical panel. Source reference months, report production dates and conditional revision-46 availability remain separate. A map describing August does not automatically imply that it was available in August.

The next requirements are the remaining original unit/site coding decisions, resolution of Tshabi and the numerical discrepancies, independently supported geolocation, a defensible historical site census including unlisted absence, and availability/timing evidence. The retrospective release comparison is useful for source stability; it cannot close these historical-availability gaps or validate an operational forecast.

## Reproduction

Run `Rscript scripts/reconstruct_deployment_2021_2023.R` after the prior map audits and the deployment-release acquisition/audit. Static inputs are the new transcription plus the earlier `post2019_map_coding_transcription.csv` and `forecast_origin_coding_transcription.csv`. Original PDF fingerprints and dates come from `post2019_map_coding_sources.csv` and `forecast_origin_deployment_sources.csv`; the newly recovered RDS fingerprint comes from `deployment_release_evidence.csv`. The script verifies twelve PDF hashes/sizes and the new RDS hash/size, uses the fixed original boundaries for comparison, and never overwrites the frozen panel.

Four public generated tables report map coverage, locality coverage, retrospective release coverage and component differences. Five private tables under `outputs/deployment_2021_2023/` preserve the complete site reconciliation, locality-map histories, missing historical monthly grid, retrospective monthly strengths and release comparison. Detailed rows and raw sources remain ignored/private. Human review remains skipped at the user's direction, not completed.
