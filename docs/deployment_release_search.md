# Deployment release evidence for the 1 October 2023 cutoff

Investigation completed 7 November 2026. **Geo-PKO 2.2 has been recovered from an official download, but its numeric coding is not authenticated as available before the forecast cutoff.** It is retained for retrospective comparison only. This is separate from reconstructing information on contemporaneous UN maps.

## New evidence

The provider's archived page on [1 May 2023](https://web.archive.org/web/20230501080938id_/https://www.pcr.uu.se/data/geo-pko/) advertises version 2.1, covering 1994–2020. The [6 December 2023 capture](https://web.archive.org/web/20231206141424id_/https://www.pcr.uu.se/data/geo-pko/) still advertises that version. The [13 April 2024 capture](https://web.archive.org/web/20240413090009id_/https://www.pcr.uu.se/data/geo-pko/) changes the heading to 2.2 and announces an update through 2022. It retains some older 2.1 descriptive paragraphs, so the explicit heading, news announcement and download section take precedence for identifying the advertised release. Saved response metadata confirms each requested capture timestamp through its Memento-Datetime header.

These captures establish what the inspected page advertised on those dates. They do **not** identify the exact first release date, prove that 2.2 was inaccessible through another route earlier, or certify the bytes of today's download as the original release. In particular, the evidence does not support treating 2021–2022 coverage as proof of pre-October-2023 availability.

A [pinned PRIO-GRID source catalog](https://github.com/prio-data/priogrid/blob/29648937d8b740c1c39d22febc2cd71ea3eca25a/data_raw/sources.csv) supplies a still-working [official 2.2 RDS link](https://www.uu.se/download/18.24f546b0193ac54c49a1b400/1734082829555/Geo_PKO_v.2.2.rds). Its catalog row is dated December 2024, so it is a discovery route, not pre-cutoff evidence. The downloaded file contains 20,057 source-map/location rows and 113 fields, ending in 2022. MONUSCO has 155 rows across four maps in 2021 and 178 rows across five maps in 2022; no 2023 records are present. These are map observations, not independently measured monthly strengths. The [coverage table](../data/deployment_release_2_2_coverage.csv) preserves this distinction.

## Consequences for reconstruction

The recovered 2.2 coding can help compare later published interpretations with contemporaneous source maps. It cannot silently replace missing historical training values. A reconstruction made now from a dated map is also distinct from a contemporaneous machine-readable dataset: source availability, map interpretation, geolocation, unit sizes and missing listings must remain auditable separately. Unlisted absence and unsized units are not resolved by finding another release. The 2023 history still needs direct source reconstruction because 2.2 ends in 2022.

No new pre-cutoff full numeric release was established by this bounded search. That finding is not a claim that no further archive exists. No provider or researcher was contacted, and no model or frozen analysis panel was changed.

## Reproduction

`data/deployment_release_evidence.csv` records nine retained originals/evidence artifacts, URLs, roles, retrieval date, sizes and SHA256 hashes. The RDS, three archived HTML pages, three locally recorded response-metadata files, bounded archive index response and pinned catalog remain private under `outputs/deployment_release_search/`. These evidence artifacts must be retained: later live requests are not guaranteed to return identical bytes.

Run `scripts/audit_deployment_release.R` to verify all nine artifacts, archive headings and response times, then regenerate `data/deployment_release_advertisement.csv` and `data/deployment_release_2_2_coverage.csv`. Every coverage row explicitly marks the recovered release as not admitted to the cutoff information set. Human review remains skipped at the user's direction, not completed.
