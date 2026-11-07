# Post-2019 deployment-map reconstruction

This supplement reconstructs **selected site components, not complete locality deployment strengths** for the 1 October 2023 information-set audit. Nine map revisions spanning February 2021–November 2022 were inspected at ten previously selected sites. Two additional December 2020 site checks address discrepancies between the recovered Geo-PKO 2.1 release and current 2.3 data. These are unblinded agent readings: existing coding and earlier checks were visible. They are not independent blinded transcription or human verification. No empirical model or frozen panel was changed.

## Sources and timing

The source manifest records official URLs, file sizes, SHA-256 hashes, map pages, report dates, English production dates and retrieval date. Nine report PDFs and one standalone map are retained privately. The report maps are in [S/2020/1150](https://digitallibrary.un.org/record/3893406/files/S_2020_1150-EN.pdf), S/2021/274, S/2021/587, [S/2021/807](https://digitallibrary.un.org/record/3941889/files/S_2021_807-EN.pdf), S/2021/987, S/2022/252, S/2022/503, S/2022/709 and S/2022/892; the remaining map is [revision 46](https://digitallibrary.un.org/record/3988906/files/4412_Rev-_46.pdf). Exact download URLs for every report are in the manifest.

| Revision | Map title | Report | English production date |
|---|---|---|---|
| 39 | December 2020 | S/2020/1150 | 2 December 2020 |
| 40 | February 2021 | S/2021/274 | 23 March 2021 |
| 41 | June 2021 | S/2021/587 | 24 June 2021 |
| 42 | September 2021 | S/2021/807 | 27 September 2021 |
| 43 | November 2021 | S/2021/987 | 2 December 2021 |
| 44 | February 2022 | S/2022/252 | 28 March 2022 |
| 45.1 | May 2022 | S/2022/503 | 27 June 2022 |
| 46 | August 2022 | Standalone UN map | Not established |
| 47 | September 2022 | S/2022/709 | 28 September 2022 |
| 48 | November 2022 | S/2022/892 | 8 December 2022 |

Report issue dates and printed English production dates differ; neither is silently replaced by the map's reference month. These dated official reports support a reconstruction of information before the October 2023 cutoff, but do not provide exact first-download timestamps. Revision 46 has PDF creation metadata of 19 September 2022; **file creation is not proof of public release**. Its availability remains conditional until a dated public posting or archived release is located.

Revision 45.1 has a material internal timing discrepancy: its title says **May 2022**, its footer says **June 2022**, and S/2022/503 was issued on 22 June and produced in English on 27 June. Current Geo-PKO `location_map.rds` assigns this revision to month 5, May. This audit preserves both map labels and does not change the frozen dataset. Historical forecasting must not treat this map as available during May merely because it describes May deployments.

## Coding rules and findings

The static transcription contains 92 reviewed site–map rows: 90 rows at the ten selected sites across revisions 40–48 (including 45.1), plus Sake and Bunia at revision 39. Ninety rows yield sized components; Eringeti is not named on revisions 40 and 41, so those two rows remain missing. Nearby South African units are not reassigned to Eringeti by inference.

Following the historical Geo-PKO conversion conventions already audited in [the coding follow-up](forecast_origin_coding_followup.md), a two-bar battalion contributes 650, a one-bar company 150, and a platoon 35. One-bar formed police units contribute 150 to the separate FPU component. HQ, individual police and observer symbols are not military companies. Unsized military police and QRF symbols are recorded as unresolved rather than assigned 150 or zero. A zero sized-military component at Beni means that no sized military symbol was counted in its reviewed box; it is **not verified deployment absence**. Existing geosplit allocations are not divided again.

All 90 numerical military and FPU components match the corresponding current source-map entries after independent transcription. This agreement is a check of selected symbol interpretation, not validation of total military strength, every site, every locality, or observation timing. Fourteen rows contain unsized military symbols whose headcounts remain unknown. Uvira illustrates a change in map representation: revision 40 separately labels Kavimvira's company, while later maps show a battalion and company in the Uvira box. The components are preserved as drawn; no unverified locality-level troop increase is inferred.

The two December 2020 checks clarify the recovered-vintage differences:

| Site | Recovered 2.1 military | Current 2.3 military | Independently read sized component | Unresolved element |
|---|---:|---:|---:|---|
| Sake | 800 | 300 | 300: India infantry company plus Guatemala SF company | Unsized Bangladesh MP |
| Bunia | 2,050 | 1,900 | 1,900: two infantry battalions plus four support companies | Unsized Bangladesh MP |

The Sake map has one size bar over India's infantry symbol. Bunia's four sized support companies are Bangladesh transport and aviation, Morocco L2 hospital and Nepal engineering. Both sites' unsized MPs remain outside the component sum. These readings support the current *sized-component* values but do not establish actual personnel totals or the historical coders' reasons. The archived 2.1 values remain the information available in that release; they must not be silently overwritten when reconstructing its training data.

## Reproduction and limits

Run `Rscript scripts/audit_post2019_map_coding.R` from the repository root. Static inputs are `data/post2019_map_coding_sources.csv` and `data/post2019_map_coding_transcription.csv`; the current comparison uses `data/raw/geo_pko/2.3/location_map.rds`. Missing PDFs are fetched from the manifest and checked against size and SHA-256. The script regenerates the public aggregate `data/post2019_map_coding_audit.csv` and private `outputs/post2019_map_coding/site_map_comparison.csv` and `partial_site_histories.csv`. PDF page extraction and rendering used pypdf and Poppler because they provide readable page evidence; numerical auditing uses R. Rendering files are not needed to rerun the numerical audit, but the source PDFs and static readings are required to repeat visual inspection.

The private chronological output is a **map-observation series**. It does not interpolate monthly values, carry observations across unknown maps, equate missing sites with zero, or claim complete administrative-area coverage. Combining these readings with the existing 2023 transcription extends selected-site evidence through 2021–2023; full locality training histories after 2020 still require every relevant unit, geographic allocation, timing rule and absence status to be reconciled. Revision 46's public availability and revision 45.1's reference timing need further evidence. No independent human transcription was received, and this supplement does not mark human review complete.
