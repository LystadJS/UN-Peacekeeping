# Release evidence for the 1 October 2023 forecast origin

Investigated 2026-11-07 for the fixed cutoff **2023-10-01 00:00 UTC**, the beginning of the existing 2023 Q4 forecast fold. The cutoff was selected before examining event-count contrasts. The question is which source releases can be supported as available by that cutoff, not which files are downloadable today.

Updated after the [release follow-up](forecast_origin_release_followup.md): an authenticated archive response for UCDP's 30 September 2023 download page supports pre-origin public advertisement of August 23.0.8, GED 23.1 and cumulative January–June. The full JRC report has also been recovered and inspected. Earlier access failures below describe the initial investigation, not the current evidence inventory. Exact first-release timestamps and historical CSV byte identity remain unverified.

## Evidence hierarchy and result

The official UCDP archive lists GED 23.1 and Candidate 23.0.7, 23.0.8 and 23.0.9. This verifies present archive access paths, not first-publication dates or historical byte identity. The [machine-readable evidence ledger](../data/forecast_origin_release_evidence.csv) separates these claims. Exact historical release timestamps remain unverified. [UCDP historical downloads](https://ucdp.uu.se/downloads/olddw.html)

| Release | Evidence relevant to the cutoff | Admissible interpretation |
|---|---|---|
| GED 23.1 | A European Commission JRC source table records a UCDP download on 2023-08-22 at 15:00:27 containing this version. | Named-version use before the cutoff is supported; exact first release and identity of today's archived bytes are not certified. |
| Candidate 23.0.7 | The same JRC record explicitly includes 23.0.7, together with cumulative 23.01.23.06. | July has stronger dated historical-use evidence than a current archive listing alone. It remains a version reconstruction rather than authenticated historical bytes. |
| Candidate 23.0.8 | The official download page captured 2023-09-30 at 03:04 UTC explicitly advertises this version and links its CSV. The retained HTML and response timestamp are verified. | Pre-origin public advertisement is supported. July–August is a supported-version content reconstruction, still conditional on historical CSV byte identity. |
| Candidate 23.0.9 | The archive lists it, but no evidence verifies publication by the instant the following quarter began. | Exclude September from the supported origin information set; use it only as a separate retrospective comparison. Missing September information is not a zero event count. |

The JRC report is *Stats in the City – the GHSL Urban Centre Database 2025*, JRC139768, published **2024-11-05**. Its conflict-indicator source table gives its own recorded 2023 retrieval, so it is retrospective primary evidence from a downstream data user, not a contemporaneous web capture or UCDP release announcement. The timestamp's timezone is unspecified; the August-to-October separation makes that immaterial for this cutoff. It is an upper bound on availability if that recorded retrieval is accurate, not the release time. No claim is made that the current CSV matches JRC's downloaded file. [JRC publication record](https://publications.jrc.ec.europa.eu/repository/handle/JRC139768), [official report](https://publications.jrc.ec.europa.eu/repository/bitstream/JRC139768/JRC139768_01.pdf)

## What does not settle the missing dates

Uppsala's press release dated **2023-06-07** discusses the annual 2022 violence results, supporting that those findings were public before the cutoff. It does not identify a first release timestamp for the GED 23.1 CSV, so it is not used to assign one. [Uppsala press release](https://www.uu.se/en/press/press-releases/2023/2023-06-07-ucdp-number-of-deaths-in-armed-conflicts-has-doubled)

The current UCDP download center describes monthly Candidate updates with a lag of no more than a month. This makes August availability before October plausible under the stated release practice; it does not authenticate that particular historical file's publication. The quarter-start instant cannot automatically include September's full monthly release. [UCDP download center](https://ucdp.uu.se/downloads/)

VIEWS' FAQ identifies `fatalities002_2023_08_t01` as informed through August 2023 and forecasting September 2023–August 2026. Its current documentation does not supply the original publication timestamp or an immutable input manifest for Candidate 23.0.8. A model's forecast-period label is not proof that its predictions or input file were publicly available at the start of that period. This is supporting context only. [VIEWS FAQ](https://viewsforecasting.org/faq/)

## Initial access record and remaining gaps

The UCDP archive, Uppsala press release and JRC publication record were opened through the web tool. The JRC source-table passage was obtained as indexed text from the official PDF. Direct PDF access timed out; local retrieval failed DNS resolution and then ended prematurely on a permitted retry. The empty failed download was discarded. No complete PDF inspection or PDF hash is claimed. Search-engine upload/crawl ages were not interpreted as historical release dates. The event reconstruction separately records hashes of the actual Candidate CSVs retrieved now.

A strict as-of reconstruction still needs independently dated original releases or preserved historical snapshots, including revisions and byte-level identity. No provider was contacted. Failure to verify a date in this bounded search does not prove the release was unavailable. The present reconstruction can identify supported historical use and conditional comparisons, but cannot authenticate every input needed for a complete quarter-start forecast. Human review remains skipped at the user's request, not completed.
