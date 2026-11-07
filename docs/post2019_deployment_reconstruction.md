# Post-2019 deployment reconstruction at 1 October 2023

**A pinned provider archive now recovers numeric deployment coding through December 2020. It does not recover a complete 2021–September 2023 training history.** This supplement extends the previous 2.0 reconstruction without refitting empirical models or replacing the original retrospective panel.

## Recovered source and historical availability

The provider's [Geo-PKO dashboard repository at commit d00be8bf](https://github.com/geopko/Geo-PKO-Shiny-Dashboard/tree/d00be8bfd060813db91cffc004a761d3039f93b9) contains `data/Geo_PKO_v.2.1_ISO3.csv`. The commit is dated 12 June 2021, preceding the forecast cutoff. Downloaded bytes match the repository Git blob `3ff742e68f580b83c625f0b78e74748c3f24571e`; the source manifest also records SHA256 and length. This is stronger evidence of pre-cutoff numeric availability than a current download labelled with an old version.

The file contains 18,699 rows, including 1,381 MONUSCO rows; 183 are dated 2020. It is a **provider dashboard transformation of 2.1**, not an independently recovered original release workbook. Its 118 columns retain source map, location, coordinates, unit measures, total troop coding and FPU coding. The [pinned transformation script](https://github.com/geopko/Geo-PKO-Shiny-Dashboard/blob/d00be8bfd060813db91cffc004a761d3039f93b9/data_wrangling.R) documents added country codes and date labels. Its displayed join/filter code does not establish that the saved CSV exactly follows that script; the retained CSV itself is audited. In particular it still includes superseded map rows despite a displayed republished-source filter.

The latest pre-cutoff dashboard commit was found using the repository commits endpoint with `until=2023-10-01T00:00:00Z`. A [researcher replication repository](https://github.com/skytheacademic/all_about_that_base) reports downloading 2.1 on 4 April 2023; the inspected `data/geo_pko/Geo-PKO-v-2-1.csv` path was introduced in a 12 January 2024 commit, so that path's history does not independently prove pre-cutoff bytes. A [2023 UNU-WIDER working paper](https://www.wider.unu.edu/sites/default/files/Publications/Working-paper/PDF/wp2023-35-windows-of-peace-effect-ceasefires-economic-recovery.pdf) also cites 2.1 through 2020. Neither corroborating citation extends numeric coverage beyond 2020.

No full 2.2 numeric artifact with verified pre-cutoff publication was recovered in this bounded search. Post-cutoff references to 2.2 and the current 2.3 download do not resolve that gap. This is a search outcome, not proof that no usable archive exists.

## Reconstruction and checks

The script reads all fields as text before explicit numeric conversions, selects the highest map revision within each source month, and checks unique source/location/coordinate keys. For June 2020, Rev 37 is superseded by 37.1; February 36, September 38 and December 39 are retained. Map dates are carried forward only through the final covered month, December 2020. Missing listings remain unknown, never zero. Existing geosplit allocations are not divided again. Military strength remains `no.troops-fpu.no`, in thousands for the panel.

Geography is the same 19 fixed SALB city/territory composites as the current pilot. Historical availability of that digital boundary artifact remains unverified; this comparison isolates deployment vintage on a common research geography. Each quarterly exposure needs three known months and map age no greater than five months. No December 2020 values are extrapolated into 2021. A 2021Q1 first lag is available because it uses 2020Q4; a 2021Q2 second lag can likewise be available.

Among 589 candidate locality-quarter training rows for 2016Q1–2023Q3:

- 208 first-lag values are now available, compared with 164 under 2.0:44 additional values,36 in the current nine-locality sample and 8 outside it.
- All 164 values shared with the older reconstruction are unchanged.
- The nine current-sample localities each have 21 first-lag quarters,2016Q1–2021Q1, rather than 17. Their remaining 90 training rows lack verified numeric first lags.
- Of 208 comparable current-panel values,206 agree and 2 differ. Neither source is overwritten to force agreement.

| Outcome quarter | Composite | Historical 2.1 first lag | Current 2.3 first lag | Difference |
|---|---|---:|---:|---:|
|2021Q1|Masisi|1.116667|0.950000|0.166667|
|2021Q1|Irumu including Bunia|1.966667|1.916667|0.050000|

Units are thousands of coded military personnel, averaged over the preceding quarter. Both differences originate in December 2020: Sake is coded 800 in 2.1 and 300 in 2.3; Bunia is 2050 versus 1900 after subtracting FPU. These are real source-vintage discrepancies, not evidence of actual personnel changing between releases. Independent visual reading of the retained December 2020 Rev 39 map supports sized-unit components of 300 at Sake and 1900 at Bunia, matching the modern coding; both sites also have unsized MP symbols whose headcounts remain unresolved. The original coding decisions causing the 2.1 differences are unverified. The independent dated-map transcription work investigates the symbols; uncertain unsized units and administrative conversion rules prevent treating coded strength as an exact headcount.

## Remaining gaps and interpretation

The modern source inventory identifies 2021 maps 40–43,2022 maps 44–48, and 2023 maps 49–51 as reconstruction targets. Their identities are not evidence that the modern numeric values were available at the cutoff. Selected dated-map readings can recover sized-unit components at selected sites, but cannot certify complete composite strengths, unlisted absence, or all monthly transitions. See the companion post-2019 map-coding audit for independently retained report evidence.

Full-training within-locality centering means remain missing for every candidate locality. There is still no complete as-of deployment panel for a 2023 forecast, and this supplement licenses neither a historical forecast-performance claim nor another empirical fit. Release timing, original-record availability, geographic vintage and deployment absence remain separate limitations.

## Reproduction and artifacts

Run `scripts/reconstruct_post2019_deployment.R` after the original quarterly panel and `scripts/audit_forecast_origin_coding.R`. The only new static input is `data/post2019_deployment_sources.csv`; missing raw bytes are downloaded from its immutable URL and verified. The raw CSV is private under `outputs/post2019_deployment/raw/`.

Generated public summaries are `data/post2019_deployment_geography_audit.csv`, `revision_ledger.csv`, `training_summary.csv`, `training_coverage.csv`, `version_comparison.csv`, `source_schedule.csv`, and `changed_quarters.csv`, all with the `post2019_deployment_` prefix. Detailed map lineage, monthly strengths, training strengths and December 2020 source differences remain under ignored `outputs/post2019_deployment/`. The training file retains `archived_strength_lag` and `archived_strength_lag2` for integration with the event-history reconstruction.

Validation enforces source hash, source sizes/coverage, unambiguous spatial assignments, unique analysis keys, revision selection,164 stable overlapping values,44 newly recovered values and no archived first lag after 2021Q1. Human review remains skipped at the user's direction; automated checks do not constitute human verification.



