# Week 1 coverage and measurement audit

**Result: revise the design before estimating deployment associations.** Data and codebooks were obtained, boundary candidates assessed, and provisional coverage panels audited. Sparse binary deployment changes and unresolved absence coding prevent clearance of the proposed varying-slope model. No empirical model was fitted.

Recorded 2026-11-05 (America/New_York). Manifest timestamps are UTC. Numerical results come from the pinned files and reproducible R scripts.

## Sources and provenance

[The manifest](../data/source_manifest.csv) records 20 artifacts with download URLs, versions/snapshots, timestamps, byte counts and SHA-256 hashes. These include GED 26.1 and its codebook; Geo-PKO 2.3 map/month products and codebook; four historical SALB geometries, change workbook, specifications and terms; and version-pinned geoBoundaries geometry. Originals are preserved in ignored `data/raw/`; extracted files remain in `data/interim/`.

The official HDX metadata was acquired, but two geometry downloads returned empty files. Those responses are not counted as acquired data. Current HDX geometry was not inspected or selected.

The [UCDP download center](https://ucdp.uu.se/downloads/) states CC BY 4.0 terms and release-specific citations. The [Geo-PKO page](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset) supplies the research citation; explicit redistribution permission was not established in the reviewed material. Raw files are not committed. SALB allows attributed non-commercial aggregation; original geometry was not repaired or edited. Geographic attribution: **from SALB Data, United Nations; Institut Géographique du Congo**.

[Package versions](../data/audit_package_versions.csv) and local session records document the R environment. These are snapshots, not a tested renv lockfile.

## Scope and definitions

The source audit covers DRC (`country_id = 490`), 2014–2023, with 2014 reserved for history. The primary outcome window is 2015–2023 in North Kivu, South Kivu and Ituri. The strict retained-event rule is `type_of_violence = 3`, `where_prec = 1`, one polygon match, and a date interval wholly inside one month. Exact-place precision does not guarantee error-free coordinates.

The secondary measure is `deaths_civilians` in retained one-sided events. Civilian deaths in other violence categories stay separate. GED `low` and `high` concern total event fatalities, not independently supplied civilian-specific bounds.

Geo-PKO `no.troops` includes formed police units. Listed military strength is numeric `no.troops - fpu.no`, with unknown values preserved. Headquarters or observer presence alone does not establish troop presence. Source publication months are preserved via `source_year/source_month`; geosplit allocations are used as published.

## Boundary assessment

| Candidate | Evidence | Assessment |
|---|---|---|
| HDX COD-AB | Metadata describes 164 units including added city units for health-geography alignment | Geometry retrieval failed; not selected |
| geoBoundaries commit `9469f09` | 189 units; 2019 representation; RGC/OCHA provenance | Useful comparator; different urban definitions |
| UN SALB | 219 units in the 2018-validity file; four historical vintages and change table | Leading candidate with aggregation and temporal caveats |

The initial selection has 26 SALB units. It produces 137 multiply matched one-sided events: 107 Beni city/territory, 27 Bunia/Irumu, two Baraka/Fizi and one Djugu/Irumu. Taking the first polygon would conceal the problem.

The [city-aggregation crosswalk](../config/city_aggregation.csv) combines seven city–territory pairs into 19 analytical areas and resolves 136 ambiguities. The remaining Djugu/Irumu point is excluded. These composites are research areas, not new legal administrative units. All 2,189 retained composite-geography events also have exactly one match in the comparison geoBoundaries file, although locality definitions differ.

Reconstructed composite footprints agree between July 2015 and 2018 to numerical precision (maximum relative symmetric-difference area below 2e-14). Earlier Djugu geometry is invalid in both the 2013 and January 2015 files. It was not repaired; early Djugu equivalence is unverified. A small valid city footprint cannot substitute for the missing territory comparison. This supports considering a 2016 start.

Three UCDP events labeled Beni share a Vido I coordinate outside the selected SALB geography. They remain flagged without moving coordinates. Other outside-target rows are not automatically errors.

## Integrity and retention

- Global GED: **417,968 events; zero duplicate IDs**.
- DRC 2014–2023: **5,511 events**; zero impossible coordinate ranges, invalid/reversed dates or fatality-component sum mismatches.
- MONUSCO 2014–2023: **1,342 location-map rows** and **3,917 monthly rows**; zero duplicate normalized location–time keys.
- All monthly rows reconcile to map attributes. An initial 31 unmatched 2014 rows were traced to the June 2013 source map; including that map resolved them.
- List-based polygon matching preserves source row counts; no ambiguity duplicates a counted event.

Mutually exclusive accounting, in filtering order:

| Disposition | DRC records |
|---|---:|
| Other violence category | 2,247 |
| One-sided pre-period history | 71 |
| Outside target or unmatched | 275 |
| Multiple target polygon matches | 1 |
| Non-exact location precision | 719 |
| Cross-month date interval | 9 |
| Retained primary audit events | **2,189** |

All 5,511 records are accounted for. The preceding country/year selection is reproducible from the original global archive. Of 2,917 uniquely assigned one-sided events during 2015–2023, 2,189 pass the strict precision/timing rules; exclusions may be selective and require sensitivity analysis.

The grid has **2,052 unique composite-months**, with totals reconciling exactly to retained event IDs. Zero means no retained recorded event, not no underlying violence or complete reporting. This is a **feasibility panel**, not frozen model input.

## Deployment timing and support

There are **39 source-map updates in 2015–2023** versus 108 months. Gaps from preceding maps range from one to six months (median three). Of 3,504 mission-wide monthly location rows in that window, **63.7% carry an earlier source month**; maximum age is five months. These are not independent monthly deployment observations.

In the 19 composites, nine have positive listed military strength throughout, three never have a positive listed estimate, and seven change positive-listing status one to three times **if unlisted months are assumed zero**. **823 of 2,052 composite-months are unlisted, with absence unverified.** No such zero recoding was used in the feasibility panel.

Listed strength varies across maps in ten of the sixteen ever-positive localities, suggesting a possible alternative common-slope contrast. That changes the estimand and requires separate validation.

Sixty-four map rows carry geosplit flags; published allocations were not multiplied or reassigned. One unknown-strength row is outside the target. Unique location-map keys rule out simple duplicate rows, but persistent unit IDs are unavailable for independent unit-level reconciliation. Original map completeness and symbols still need review before absence coding.

## Outputs and verification

`outputs/week_1/audit/` holds the 26-unit assessment; `outputs/week_1/audit_aggregated/` holds the 19-composite assessment. Outputs include record-level lineage/exclusions, join reconciliation, historical crosswalks, footprint checks, precision inventories, map freshness and locality variation. Four inspected figures in `outputs/week_1/figures_aggregated/` show deployment evidence, retained event counts, map freshness and geographic precision.

The UCDP archive hash was independently matched with PowerShell. Runtime checks enforce unique keys, exact count reconciliation and valid selected geometry. Locale warnings were logged; UTF-8 names were retained and rendered figures inspected. Unresolved measurement checks remain qualified or unresolved in [the audit table](../data/audit_checks.csv).

Reproduce from the repository root with the recorded dependencies installed:

```r
source("scripts/acquire_week_1.R")
Sys.unsetenv("AUDIT_AGGREGATE_CITIES")
source("scripts/audit_week_1.R")
Sys.setenv(AUDIT_AGGREGATE_CITIES = "true")
source("scripts/audit_week_1.R")
source("scripts/finalize_week_1.R")
Sys.unsetenv("AUDIT_AGGREGATE_CITIES")
```

Follow the [revise-design decision](feasibility_decision.md) before modeling. Quarterly timing, a shorter window and a common strength slope are candidates for validation, not approved conclusions. Reporting probabilities and causal peacekeeping effects have not been estimated.
