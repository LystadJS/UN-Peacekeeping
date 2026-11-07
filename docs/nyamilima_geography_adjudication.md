# Nyamilima geography adjudication

Investigated 7 November 2026. **Nyamilima's settlement/locality assignment is resolved for a correction scenario: Rutshuru, North Kivu (study ID `COD009015`).** The current Geo-PKO point is inconsistent with independently documented settlement geography. No frozen panel or source coordinates have been overwritten.

## Independent evidence

The primary [OpenStreetMap node history](https://www.openstreetmap.org/api/0.6/node/1158948544/history) contains four versions dated 18 February 2011, twice on 13 May 2015, and 11 January 2020. All retain latitude **−0.8831012**, longitude **29.5665210**, and identify Nyamilima in Rutshuru/Bwisha. Their source tags attribute the point to the Référentiel Géographique Commun, identify GPS as the method, and give a source date of 21 November 2007. The original RGC survey was not separately recovered, so those tags are provenance claims, not an independently verified survey record. OSM's version history provides a primary historical edit record; it is not an archived download made at the forecast origin. [OSM attribution and licence](https://www.openstreetmap.org/copyright)

An independent UN publication, [Échos de la MONUSCO no. 42, February 2015, page 15](https://monusco.unmissions.org/sites/default/files/echos_monusco_42_1.pdf), explicitly places Nyamilima in Rutshuru territory, North Kivu. The page's text and rendered image were inspected. This supports the administrative identification without relying on Geo-PKO's coordinates or the crowded deployment-map labels.

## Spatial adjudication

The R audit uses the same fixed SALB 2018 composites as the pilot. The current Geo-PKO point, **−0.5490497, 27.4723982**, intersects Lubutu in Maniema in the national boundary file and none of the 19 study localities. The historical OSM settlement point intersects Rutshuru uniquely. It is **235.782 km** from the current point and **2.799 km** from the nearest Rutshuru boundary under spherical distance calculations. That margin establishes that the candidate is not a rounding-level boundary ambiguity; it does not establish the boundaries' historical digital availability.

The current wrong-locality point appears in all 12 reviewed maps from February 2021 to August 2023. It also appears in all **17 Nyamilima source-map rows in the full 2016–2023 pilot window**, beginning in 2020 and including the later November 2023 map. A future corrected-panel analysis must therefore audit the broader source lineage rather than fix only the three 2023 discrepancy maps.

The [adjudication table](../data/nyamilima_geography_adjudication.csv) retains both points, their geographic assignments and distances. The [correction proposal](../data/nyamilima_geography_correction_proposal.csv) records the candidate coordinate and locality, affected row counts, historical version timestamps and limitations. This supports a named settlement-to-locality correction scenario. **The exact MONUSCO compound coordinate remains unverified.** The settlement point is not a surveyed base footprint or an estimate of operational reach. The geographic decision does not itself determine which unit symbols or personnel amounts belong to either Nyamilima or Rwindi.

## Reproduction and limits

Run `scripts/adjudicate_nyamilima_geography.R`. Static `data/nyamilima_geography_sources.csv` fingerprints two original inputs: the OSM history XML and the UN magazine PDF. The script verifies hashes, reads the four coordinate versions, checks the UN locality text, and independently repeats geographic joins and distance calculations. Original files and the coordinate-version ledger stay under ignored `outputs/nyamilima_adjudication/`; only aggregate decisions and the proposal are public. Derived PDF text and preview images are not numerical inputs.

Some polygons outside the study region contain duplicate vertices. The audit applies `st_make_valid()` only to an in-memory national lookup used to identify the misplaced original point. The 19-locality research geometry retains the existing construction, and no boundary file is modified. The PDF extractor reports font-weight warnings; page 15 remains readable and was visually checked.

The evidence is sufficient to resolve the settlement/locality mismatch for correction planning. It does not certify contemporaneous download bytes, the exact base point, all deployment strengths, or a complete historical forecast information set. Human review remains skipped, not completed.
