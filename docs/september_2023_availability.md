# September reporting at the 1 October 2023 cutoff

Investigated 2026-11-07 for **2023-10-01 at 00:00 UTC**. **Some September violence was reported before the cutoff, but a complete September UCDP information set is still not authenticated.** This investigation distinguishes public reporting, a dataset's public advertisement and the contents of a historical coded release. It changes no event totals, training inputs or fitted model.

## Release advertisement can now be bounded more concretely

The retained [30 September download-page capture](https://web.archive.org/web/20230930030400id_/https://ucdp.uu.se/downloads/) advertises August Candidate 23.0.8. A new [6 October capture](https://web.archive.org/web/20231006144416id_/https://ucdp.uu.se/downloads/) still advertises August, while the [30 October capture](https://web.archive.org/web/20231030090549id_/https://ucdp.uu.se/downloads/) explicitly advertises September Candidate 23.0.9 and links its CSV. Both new HTML files were downloaded and hashed. Their final URLs remained at the requested captures, and response `Memento-Datetime` fields match 6 October 14:44:16 UTC and 30 October 09:05:49 UTC.

This establishes September's public advertisement **by 30 October**, not an exact first-release date. The intervening snapshots describe the advertised page state; a stale page cannot prove that a CSV was unavailable through another route. A bounded CDX query for successful captures of the exact September CSV URL during September returned an empty array. That is not proof that no early file, alternative URL or uncaptured update existed. The current [UCDP historical archive](https://ucdp.uu.se/downloads/olddw.html) lists September and a cumulative January–September product, but present accessibility does not establish pre-cutoff release.

The previously obtained September summary PDF has an October creation date, and the downloaded Candidate file includes sources dated after the cutoff. These support keeping that file outside the authenticated origin information set. Neither is converted into a guessed first-publication date. The exact release time and preserved pre-cutoff CSV bytes remain unresolved. [Earlier release evidence](forecast_origin_release_followup.md)

## September source material was not entirely absent

Two original publishers' dated articles were retrieved and hashed as direct checks of material listed in Candidate's provenance:

- [Radio Okapi, dated 23 September 2023](https://www.radiookapi.net/2023/09/23/actualite/securite/vive-tension-au-quartier-majengo-de-goma-2-morts), reports unrest following a civilian killing in the Majengo/Goma area. Its title and date correspond to the source listed for Candidate ID 494612. The article discusses a civilian death and a police death in related events; its headline must not be turned into two qualifying one-sided-violence events.
- [Bunia Actualité's Ruvinga report](https://buniaactualite.cd/mahagi-ruvinga-sous-menace-une-autre-attaque-fait-denormes-degats/) describes early-September attacks and deaths and corresponds to a source listed for Candidate ID 490477. The publisher page and structured metadata date it to 2 September, whereas Candidate lists that source on 3 September. This discrepancy does not change its pre-cutoff placement, but was left unresolved rather than silently correcting the source record.

These are current publisher copies bearing pre-cutoff publication dates, not contemporaneous archived article bytes. They corroborate that dated reporting existed, not that UCDP had already classified, geolocated and released those records. The search was bounded and the two examples are not a comprehensive September source review. No provider was contacted.

## Reproducible listed-source timing audit

The audit uses the already retained, version-specific event ledgers from the one-origin comparison, restricting to eligible events whose occurrence interval lies wholly in September. It splits all source-date tokens, preserves missing-date sentinels, and uses a strict **before 1 October** rule. Day-of-cutoff reports would require within-day evidence and are counted separately; none occurs here. Geography and the nine-locality marker remain the current retrospective comparison definitions.

| Product and population | Eligible September events | At least one listed source before cutoff | At least one listed source after cutoff | All dated listed sources after cutoff |
|---|---:|---:|---:|---:|
| Candidate 23.0.9, all 19 localities | 23 | 7 | 16 | 16 |
| Candidate 23.0.9, current nine-locality sample | 13 | 5 | 8 | 8 |
| GED 26.1, all 19 localities | 34 | 9 | 27 | 25 |
| GED 26.1, current nine-locality sample | 21 | 7 | 16 | 14 |

The before/after columns are **not generally disjoint**: two current GED events in each population have both pre- and post-cutoff listed material. In this Candidate subset they happen to be disjoint. Every included event has a valid listed source date. The differences between Candidate and current GED also involve eligibility and coding revisions; the table is not a first-reporting survival curve or an estimate of exact GED availability.

Seven Candidate events with earlier listed material are a **retrospective source-timing proxy**, not a reconstructed historical coded count. Later sources may have supplied final coordinates, actor assignments or precision, and the current eligible set itself depends on later coding. Earlier unlisted sources may also exist for events whose listed material is later. Thus these counts neither identify nor provide a defensible bound on the complete historical GED count. Adding seven to July–August would not solve the missing September predictor. All certified September totals remain missing, including in localities with no eligible record in this particular product.

## Reproduction and disposition

Run `Rscript scripts/audit_september_2023.R` after `scripts/reconstruct_forecast_origin_events.R`. The script verifies the seven retrieved evidence artifacts and the archive headings, then publishes [population summaries](../data/september_2023_summary.csv), [locality summaries](../data/september_2023_locality_summary.csv) and [input fingerprints](../data/september_2023_inputs.csv). Detailed records stay in ignored `outputs/september_2023/`. The static [evidence ledger](../data/september_2023_evidence.csv) records URLs, dates, hashes, inspected claims and limits; it is an input to the audit, not a generated claim of historical availability.

The remaining requirement is a contemporaneous coded information snapshot, or a separately designed and documented source-coding process using only reports actually available by the cutoff. Neither has been reconstructed here. A reporting-lag model or delayed forecast origin would change the forecasting task and requires an explicit design. The fixed-origin complete Q3/Q4 lag fields stay unknown. No model was refitted, and human review remains skipped rather than completed.
