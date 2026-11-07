# Historical deployment coding and training-prefix reconstruction

Completed 2026-11-07 for the fixed **2023-10-01 00:00 UTC** origin. This follow-up recovers a byte-defined older deployment dataset and independently checks selected symbols on the 2023 maps. It does not authenticate a complete 2023 numeric deployment series or refit a model.

## A historical dataset was recovered

The provider's own [Geo-PKO R repository](https://github.com/geopko/Geo-PKO-R) contains the full version 2.0 CSV. Its [pinned commit `da0129ca`](https://github.com/geopko/Geo-PKO-R/commit/da0129ca963cacf75dcc089811b65d301eaf3d54) is dated 2020-12-16 23:50:21 UTC. The [immutable file URL](https://raw.githubusercontent.com/geopko/Geo-PKO-R/da0129ca963cacf75dcc089811b65d301eaf3d54/data/Geo_PKO_v.2.0.csv) was downloaded and its Git blob hash independently matched `b71f4951a41c38813bb375700b2cf3a1ddff23a5`. The SHA-256 fingerprint is in [the source manifest](../data/forecast_origin_coding_sources.csv). This is stronger content provenance than a changing current-download URL, although Git metadata alone is not independent proof of the server's first public-upload instant.

The [provider's reproducible tutorial](https://geopko.github.io/Geo-PKO-R/index.html), dated December 2020, explicitly uses this version and records its repository history. The provider also [announced version 2.0 on 18 December 2020](https://www.uu.se/en/department/peace-and-conflict-research/news/archive/2020-12-18-geo-pko-2.0-global-data-on-local-peacekeeping-deployments). Together these support historical availability of version 2.0 well before the forecast origin. They do not establish that it was the latest available version in October 2023.

The recovered file has 17,927 rows overall and 1,198 MONUSCO map-location rows, covering 2010 through **December 2019**. The [version 2.0 codebook](https://www.uu.se/download/18.3f2acc1b18f157bd287131/1714053575165/Codebook-v-2-0.pdf), internally dated December 2020, was also downloaded and hashed. The current URL's upload timestamp is not treated as its original publication date. Current provider instructions still direct users to request older versions; no provider was contacted. This bounded search recovered version 2.0, not the complete version distributed in October 2023.

## Reconstructed deployment training history

`scripts/audit_forecast_origin_coding.R` independently assigns historical coordinates to the same fixed SALB composites used by the pilot. It retains original rows and geographic-match counts locally, subtracts the published FPU component, and respects already allocated geosplit values rather than dividing them again. Unknown listings and strengths remain missing. The geography is held fixed for comparability; its historical digital availability is not newly certified.

An important source issue was resolved before interpreting the reconstruction: **the older CSV contains superseded revisions for the same map month**. December 2018 includes revisions 31 and 31.1, February 2019 includes 32 and 32.1, and September 2019 includes 34, 34.1 and 34.2. Summing those rows would count representations of units multiple times. The reconstruction selects the highest numbered revision within each map month, all present in the pinned 2020 file, and publishes the [revision-selection ledger](../data/forecast_origin_coding_revision_ledger.csv). This is not evidence about the exact dates each revision first appeared.

Monthly values use the most recent selected mission map and the existing maximum age of five months. Expansion stops at the release's final observed month, December 2019: it does **not** carry the final map into 2020–2023. The original three-known-month quarterly rule is preserved. Thus training outcome-quarter 2020 Q1 can have a reconstructed first deployment lag from 2019 Q4, but later first-lag values stay unknown.

| Comparison population | Known archived first-lag locality-quarters | Equal to current panel | Changed |
|---|---:|---:|---:|
| Existing nine-locality sample | 153 | 153 | 0 |
| Other ten candidate localities | 11 | 11 | 0 |
| All 19 candidates | 164 | 164 | 0 |

For each core locality, the reconstructed first-lag prefix spans 17 outcome quarters, 2016 Q1–2020 Q1, of the 31 training quarters preceding the origin. Its second lag is known for 18 quarters through 2020 Q2. The remaining 126 core first-lag cells are unknown in this old release. These matches establish consistency over the available overlap, not completeness of the later training set. No full-training centering mean is calculated from the partial prefix; its field remains missing for every locality.

The [coverage table](../data/forecast_origin_coding_training_coverage.csv) and [comparison summary](../data/forecast_origin_coding_training_summary.csv) are public aggregates. The 589-row locality-quarter reconstruction remains private at `outputs/forecast_origin/coding/historical_training_strength.csv`; raw maps, monthly expansion and geographic lineage are retained alongside it. No archived or current row was added to the frozen fitted panel.

## Thirty selected map-symbol checks

The [explicit transcription](../data/forecast_origin_coding_transcription.csv) records visual readings for ten clear locations on each of revisions 49, 50 and 51: Komanda, Bogoro, Eringeti, Kamango, Lubero, Nyanzale, Kamanyola, Sange, Beni and Uvira. Covers and map identities had already been checked; this follow-up inspected enlarged eastern map insets. Cases with ambiguous connectors or unsized complex formations were not forced into full-locality estimates. This is an agent transcription, not human review, and it was not blinded to the current data.

The historical codebook uses 650 personnel per battalion, 150 per company and 35 per platoon. FPU estimates are included in `no.troops`, so the military component subtracts them. Headquarters, individual police and military observers are not additional military companies. Published geosplit allocations must not be counted twice. These conventions were documented before 2023; they are estimates from unit symbols, not measured headcounts. [Codebook, pp. 2–5](https://www.uu.se/download/18.3f2acc1b18f157bd287131/1714053575165/Codebook-v-2-0.pdf)

All 30 selected **sized-unit components** and their FPU components match the current coded values. Komanda changes from one company in revisions 49/50 to one battalion in revision 51, giving 150 to 650 under the stated conversion. Beni's two FPU company symbols produce a zero sized-military component after subtraction; that is not operational absence. Uvira's sized symbols imply 800 military plus 150 FPU personnel, but an unsized MP symbol remains excluded from that arithmetic. Its unknown contribution is not presumed to be zero actual personnel. See [symbol comparison](../data/forecast_origin_coding_symbol_comparison.csv).

These checks narrow the coding gap for explicit source symbols. They do not reconstruct every site in the nine analytical localities, recode all headquarters/special-unit/coordinate decisions, identify every temporary deployment, or establish a complete historical Geo-PKO version for 2023.

## Reproduction and remaining gaps

Run `Rscript scripts/audit_forecast_origin_coding.R` after the original panel exists. The script verifies or downloads the two new pinned originals, reads the static transcription and source manifests, and regenerates the symbol comparison, geographic/revision audits, training summaries and private panels. Original UN PDFs remain fingerprinted by `data/forecast_origin_deployment_sources.csv`. The source and transcription CSVs are static inputs; all other `forecast_origin_coding_*.csv` outputs are generated.

The remaining obstacles are specific: deployment coding for 2020–September 2023, authentic complete training centering, comprehensive recoding of 2023 symbols and coordinates, unresolved operational reach and historical boundary availability. The recovered early prefix does not resolve event-release timing or missing September violence information. Current empirical estimates remain unchanged, and human review remains skipped at the user's request, not completed.
