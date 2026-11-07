# Release-date follow-up for 1 October 2023

Investigated 2026-11-07. **A contemporaneous archive capture now supports public advertisement of Candidate 23.0.8 before the forecast origin.** This resolves the earlier gap at the named-version availability level. It does not establish its exact first release or authenticate today's CSV bytes as the historical file.

## The new evidence

The Internet Archive's CDX index returned a capture of the official UCDP download page at **2023-09-30 03:04:00 UTC**, before the fixed cutoff of 2023-10-01 00:00 UTC. The captured HTML was retrieved in original-content mode. Its final response URL remained at that capture, and both `Memento-Datetime` and `X-Archive-Orig-Date` identified the same 30 September timestamp. The HTML, index responses and a record of these response fields were retained and hashed. This is a retrieved contemporaneous page, not a current-page statement or search-engine crawl age. [Archived UCDP download page](https://web.archive.org/web/20230930030400id_/https://ucdp.uu.se/downloads/)

The page explicitly advertises August 2023 Candidate version 23.0.8 and links to `GEDEvent_v23_0_8.csv`. It also advertises annual GED 23.1 with `ged231-csv.zip` and the January–June 2023 cumulative release with `GEDEvent_v23_01_23_06.csv`. The visible availability wording and exact version links support availability by the capture date, subject to the usual limitation that a listing is not a verified successful download of those bytes. They do not date the first appearance of any release.

| Version | Updated disposition at the origin | Remaining limitation |
|---|---|---|
| GED 23.1 | Publicly advertised before the origin; independently supported by the JRC acquisition record | Exact first release and identity of today's downloaded CSV remain unverified |
| Candidate 23.01.23.06 | Publicly advertised before the origin; JRC also records its prior use | Current cumulative file is a version reconstruction, not authenticated historical bytes |
| Candidate 23.0.7 | JRC records its use on 22 August 2023 | The new capture advertises August, not July; prior July-use evidence remains the supporting route |
| Candidate 23.0.8 | **Pre-origin public advertisement now documented** | Historical CSV contents are not recovered from this page capture |
| Candidate 23.0.9 | Not admitted to the supported information set | No pre-origin release evidence was recovered; its retained-content audit includes post-cutoff source material |

The exact August CSV URL was separately queried in the CDX index for successful 2023 captures and returned an empty array. This bounded query does not establish that no capture exists under another URL or that the release was unavailable. It means this investigation did not recover archived CSV bytes through that query. The page capture is positive evidence of advertisement; the empty CSV search is not negative proof of release absence.

## Full JRC report recovered

The official Copernicus host supplied a complete copy of *Stats in the City – the GHSL Urban Centre Database 2025*, JRC139768. It has 633 PDF pages; the conflict-source tables on printed pages 328–332 (PDF pages 332–336) record acquisition on **2023-08-22 at 15:00:27**, naming GED 23.1, cumulative Candidate 23.01.23.06 and Candidate 23.0.7. The timestamp's timezone is unspecified, but its distance from the October cutoff makes that immaterial here. The downloaded title and publication identifiers match JRC139768. Relevant text was extracted and the table on printed page 330 was rendered and visually inspected. [Official report copy](https://human-settlement.emergency.copernicus.eu/documents/GHSL_UCDB_R2024.pdf)

This supersedes the earlier access limitation that only indexed report text had been inspected. It remains a later institutional record of historical use, not an original 2023 download manifest with dataset hashes. The recovered PDF itself is now fingerprinted; this does not fingerprint the datasets JRC possessed. Python was used only for the bundled PDF reader and metadata extraction because it was practical for this document; evidence-ledger construction and checks used R.

## Summary-map metadata: useful but weaker evidence

Two official UCDP monthly summary PDFs were downloaded and hashed. The August summary has embedded creation time **2023-09-20 09:59:23 +02:00** and modification time 10:04:51 on the same date. The September summary has creation time **2023-10-20 00:58:41 +02:00**. [August summary](https://ucdp.uu.se/downloads/candidateged/maps/GEDEvent_v23_0_8.pdf), [September summary](https://ucdp.uu.se/downloads/candidateged/maps/GEDEvent_v23_0_9.pdf)

These metadata concern document generation, are mutable, and do not prove when a CSV was first distributed. August's metadata are consistent with the independently retrieved September page capture. September's later document date is not converted into a claimed first-release date for Candidate 23.0.9. The existing event-content evidence remains the more direct reason not to treat the downloaded September product as an authenticated cutoff-time input.

## Consequence for training histories

The version-supported history route can now include annual GED 23.1 through 2022, cumulative Candidate January–June 2023, and the July and August monthly products. With the established event filters, the last two provide a **partial Q3 window**, not a complete Q3 outcome or lag. September remains missing. Version reconciliation, duplicate handling, source-date anomalies and the fixed retrospective geography still require explicit audit. A cumulative release is not automatically identical to concatenating monthly files.

The [nine-row evidence ledger](../data/forecast_origin_release_followup.csv) records seven distinct retained artifacts, their URLs, access date, byte counts, SHA-256 values, inspected locations and limitations. Raw PDFs, HTML and archive responses stay under ignored `outputs/forecast_origin/release_followup/`. No provider was contacted, no model was fitted, and human review remains skipped rather than completed. The new evidence narrows the release gap without certifying a complete historical information set.
