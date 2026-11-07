# Historical data availability investigation

Investigated 2026-11-07. **Historical releases exist, but the present pilot has not reconstructed what an analyst could actually have known at each forecast origin.** The existing 2019 Q1–2023 Q4 validation remains retrospective. This investigation identifies a feasible follow-on route and specific gaps; it does not revise any panel, predictor, model or score.

## Four different dates

| Date | Meaning | What it cannot establish |
|---|---|---|
| Event occurrence or deployment-map reference date | When violence occurred or the depicted deployment situation applied | When information became public or entered a coded dataset |
| Source publication date | When a report or article was published | When UCDP or Geo-PKO coded, revised or released the corresponding row |
| Dataset release / revision date | When a particular information set was distributed | That every event or deployment was observable in real time |
| Repository retrieval date | When this project acquired and hashed the file | Its historical first-publication date |

The project's original inputs were retrieved on 2026-11-06, as recorded in [source provenance](../data/source_manifest.csv). Their hashes establish the files used, not availability during 2016–2023.

## UCDP: a concrete archive route, with limits

The official historical download page lists annual GED releases 17.1 through 25.1, earlier numbered releases, and monthly Candidate releases beginning with 18.0.1. Africa is covered in 2018–2019, including DRC; the later expansion to global coverage does not create a DRC gap. Thus historical files are not simply unavailable. This review verified two linked Candidate files by downloading and parsing them: January 2019 contains 234 rows, including 22 with DRC country code 490; December 2023 contains 1,887 rows, including 21 DRC rows. These are all violence types and locations, not retained pilot event totals. The [evidence ledger](../data/historical_availability_evidence.csv) records links, bytes and SHA-256 hashes. The files remain locally under `outputs/historical_availability/`. Other historical links were inventoried on the page, not exhaustively downloaded or validated. [UCDP archive](https://ucdp.uu.se/downloads/olddw.html)

Candidate is a distinct information product: monthly releases precede the final annual GED, some events can subsequently disappear, and others can be added. The codebook describes downloadable monthly versions from 18.0.1 and warns that an event spanning months can appear in more than one monthly file. A future reconstruction therefore needs version-aware deduplication and reconciliation, not concatenation. [Candidate codebook, pp. 2–3](https://ucdp.uu.se/downloads/candidateged/ucdp-candidate-codebook1.5.pdf)

The current download page describes a monthly release cycle with no more than a month's lag. That is a release-policy description, **not verified first-publication timestamps for each archived file**. For a quarter-start forecast, one cannot assume the immediately preceding month's Candidate data were already released. Either prove availability at the chosen origin or choose a delayed origin and record the resulting forecasting target. Current download accessibility does not establish historical availability dates. [UCDP download center](https://ucdp.uu.se/downloads/)

GED's `date_start` and `date_end` describe occurrence intervals. `source_date` describes publication of source material; multiple source dates may occur, and the codebook identifies 1753-01-01 as a missing-date default. Sources can postdate events by months or years. Consequently, filtering by the earliest source date alone would not reproduce the information in a historical GED release: later coding, revisions, geolocation and classification may still enter the row. These fields support a reporting-delay audit, not certification of dataset availability. [GED 26.1 codebook, pp. 9, 12 and 19–20](https://ucdp.uu.se/downloads/ged/ged261.pdf)

## Geo-PKO: the release history is only partially public

The provider dates the first Geo-PKO release to 2019 and version 2.0 completion to 2020. The retained version 2.3 covers through December 2024; the current page is marked last modified 2025-06-17. Neither page modification nor a timestamp embedded in a download URL is treated as an exact dataset release date. The provider directs users to request older versions; no such request was sent.

The location-month file carries the last map forward, and revised maps replace earlier maps for the same period. Thus a map reference date and five-month freshness rule do not ensure that the map—or that revision—was available then. Individual UN report publication dates could establish availability for particular maps, but the pilot's two endpoint map checks do not constitute a complete release ledger. A historical reconstruction needs map identities, reference dates, publication evidence, supersession dates and the coding rule available at each origin. No complete Geo-PKO vintage series was verified here. [Geo-PKO provider page](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset)

## Boundaries: validity does not mean publication

The retained SALB page labels temporal validity intervals beginning 2013-06-13, 2015-01-09, 2015-07-22 and 2018-05-30. These describe geographic applicability. The retained metadata for the 2018 geometry item records `created=1724454910126`, or **2024-08-23 23:15:10.126 UTC**. This is the current item's creation time, not proof that no equivalent geometry existed earlier. The live SALB page returned HTTP 403 during this review; this finding is based on the hashed 2026-11-06 page and item snapshots already retained, not a successful new page retrieval. [SALB country page](https://salb.un.org/en/data/cod), [UN item metadata](https://geoportal.un.org/arcgis/sharing/rest/content/items/fc8e0a8497e14a29803cfaab572e2016?f=pjson)

The retained geoBoundaries alternative separately records represented year 2019, source update January 2023 and build December 2023. These distinctions reinforce that a stable retrospective geography is defensible for this association study but cannot be described as an authenticated historical information set. It was an assessed alternative, not the pilot's adopted geometry. [geoBoundaries metadata](https://www.geoboundaries.org/api/current/gbOpen/COD/ADM2/)

## Decision and bounded next step

The complementary [local source-date and eligibility audit](historical_availability_code_audit.md) makes the timing limitation concrete: among 1,107 retained events used in immediate prior-quarter histories for the validation period, 300 have their earliest listed source publication strictly after the quarter-start forecast origin. These are comparisons using currently listed sources, not first GED availability dates. Its past-only coverage check also reproduces the nine-locality sample at all 20 origins under the existing complete-since-2016 exposure rule. That narrows this specific future-coverage selection concern in the retained data, while leaving contemporaneous knowledge of exposure and publication availability unresolved.

Resolved: historical UCDP releases have an official archive, two Candidate files are readable and contain DRC records, and source-publication dates are distinguishable from event dates. Partly resolved: Geo-PKO release history and SALB item metadata identify retrospective construction, but do not yield complete vintage histories. Unresolved: actual first availability and all later revisions for every required predictor, contemporaneous map completeness, and prospective locality eligibility.

Keep current results labeled retrospective and retain unknown deployment as unknown. A bounded follow-on could reconstruct one forecast origin using the then-available GED/Candidate files and individually dated UN maps, define eligible localities without later coverage, and compare those inputs with the final-release panel. First record exact publication evidence and the forecast cutoff; explicitly flag uncertain dates rather than assigning guessed release dates. A single-origin demonstration would establish feasibility only, not validate all 20 existing folds. Full operational validation remains outside the completed pilot. Human review remains skipped at the user's request, not completed.
