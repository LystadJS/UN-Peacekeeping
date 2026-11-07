# Event information at the 1 October 2023 origin

Completed 2026-11-07 under the [single-origin protocol](forecast_origin_reconstruction_protocol.md). The target is the existing 2023 Q4 forecast, with a cutoff of **2023-10-01 00:00 UTC**. The exercise reconstructs archived event content, compares it with the frozen current-release panel, and keeps unavailable inputs unknown. No prediction or model is refitted.

## What was reconstructed

Three official UCDP Candidate CSVs, versions 23.0.7, 23.0.8 and 23.0.9, were downloaded, parsed and hashed. These are monthly information products, not snapshots of the full annual GED. The [input manifest](../data/forecast_origin_event_inputs.csv) records their official URLs and all eight inputs used by the comparison. Original files and event-level audit ledgers remain ignored under `outputs/forecast_origin/`.

The [release-evidence investigation](forecast_origin_release_evidence.md) supports the existence of the July version before the origin through a later official report documenting its August download. The subsequent [release follow-up](forecast_origin_release_followup.md) recovered a 30 September archived UCDP page advertising August 23.0.8. July–August now has supported **version-level** availability; this supersedes the initial unverified-August classification. Today's downloaded CSV bytes are still not authenticated against historical copies, and September is not admitted to the supported information set. The full-quarter comparison remains retrospective. None supplies a certified complete prior-quarter count.

The same 19 fixed SALB city–territory composites and the same event inclusion rules are applied independently to the coordinates, event types, precision and dates in each release: one-sided violence, exact-place precision, valid coordinates and dates, one unique polygon match, and an event interval contained within one calendar month. Holding geography fixed isolates record differences; it does not authenticate this boundary file's historical availability.

For a window using multiple monthly files, duplicated IDs are resolved using the last representation **within that window**, before event filtering. Every source row and duplicate rank is preserved locally. There are 16 duplicate global rows removed from July–August and 46 from July–September; these are global file counts, not duplicate DRC retained events. Unique DRC records number 72, 140 and 179 in the respective windows. An ID overlap is a diagnostic, not an exhaustive adjudication of event renumbering, splitting or merging.

## Comparison with current GED 26.1

Counts below apply identical occurrence windows and filters. The nine-locality column is a marker of the **current** fitted sample, not a newly certified historical eligibility decision.

| Occurrence window and information scope | Archived events, all 19 localities | Current events, all 19 | Archived events, current nine-locality sample | Current events, current nine-locality sample |
|---|---:|---:|---:|---:|
| July; version existence supported, byte identity unverified | 30 | 39 | 21 | 23 |
| July–August; versions supported before origin, historical bytes unverified | 62 | 78 | 40 | 50 |
| July–September; retrospective sensitivity benchmark, not an as-of predictor | 85 | 112 | 53 | 71 |

The full-quarter current counts reconcile exactly with `events_lag` for **all 19 locality rows** in the frozen 2023 Q4 panel. The current panel's 71 events in its nine retained localities should therefore not be substituted for what was known at the historical cutoff. Nor should 21 July events be presented as a full-quarter count: later months are unverified or unavailable, not zero.

For the retrospective full-quarter benchmark, 78 IDs are eligible in both products, seven appear only in the eligible archived set, and 34 only in the eligible current set. All 78 shared IDs retain the same assigned locality. Of the 34 current-only eligible IDs, three existed in the selected archived DRC files but failed the exact-location precision filter; the other 31 IDs were not found there. The seven archived-only eligible IDs were not found in the current DRC records. Those facts do not establish why the records differ or whether some represent reidentified events. They must not be labeled 34 newly discovered events and seven erroneous old events without case adjudication. See [ID-status aggregates](../data/forecast_origin_event_transitions.csv).

## Source-date sanity check

The [source-date audit](../data/forecast_origin_event_source_dates.csv) splits semicolon-separated dates, treats `1753-01-01` as missing, and verifies calendar formatting. The latest listed source among the 30 retained July events is 2023-08-09; among the 62 retained July–August events it is 2023-09-19. Neither retained set contains a listed source dated after the origin. That is compatible with pre-origin information, but is not proof of dataset publication or historical byte identity.

In the retrospective full-quarter benchmark, **16 of 85 retained events have every dated listed source after the origin**, with a maximum source date of 2023-10-18. This materially undercuts treating the September-containing archive as an authenticated 1 October input. It does not exclude earlier unlisted information or establish each event's first GED availability date.

The raw July file contains one DRC source date of **2032-07-15**, outside the retained sample. It is a calendar-valid but implausibly future value relative to retrieval. It is flagged and left unchanged; it may be a coding error and is not evidence of actual publication in 2032 or proof of a late archive revision. Two July global records have no valid listed source date, including one DRC record. Missing and implausible dates are not silently converted into availability evidence.

## Reproduction and unresolved inputs

The subsequent [training reconstruction](forecast_training_reconstruction.md) now supplies annual and early-2023 histories, and the [coding follow-up](forecast_origin_coding_followup.md) supplies an older deployment prefix. The bounded event-window comparison below remains unchanged numerically; its original exclusions and unreconstructed-input scope describe this stage, not the entire later supplement.

Run `Rscript scripts/reconstruct_forecast_origin_events.R` after the existing panel build. Missing Candidate files are downloaded from their official URLs and must match the recorded hashes; a changed upstream file causes failure instead of silent substitution. The script writes six CSVs, including the input manifest, under `data/forecast_origin_event*`, with full rows and lineage kept locally. It checks unique IDs within each file, deterministic cross-file deduplication, 19 unique locality keys per comparison, exhaustive ordered exclusion ledgers, and exact reconciliation with the current Q4 lag counts. Full-quarter certified as-of counts remain `NA` in every comparison row.

This is a bounded content reconstruction, not the full model input set. It does not reconstruct annual training releases, all earlier spell-history quarters, historical within-locality deployment means, authentic prior-quarter strength or lag-2 strength, contemporaneous boundary availability, or prospective eligibility. These gaps prevent generating an authenticated one-step model forecast from this exercise. The difference between Candidate and GED 26.1 combines later information, coding/precision changes and product differences; it cannot be interpreted as reporting delay alone.

The source-based evidence is useful despite these limits: current-release event histories materially differ from archived products, and the missing last-month information is explicit. Human review remains skipped by user instruction, not completed.
