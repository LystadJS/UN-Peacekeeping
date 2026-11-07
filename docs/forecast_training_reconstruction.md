# Event training histories at 1 October 2023

Completed 2026-11-07 under the [fixed-origin training protocol](forecast_training_protocol.md). **Thirty complete training outcome quarters can be reconstructed at the named-version level, but the full information set for an authenticated Q4 forecast remains incomplete.** No model was fitted and no original pilot panel was changed.

## Available versions and scope

The reconstruction uses GED 23.1 for occurrence dates from January 2014 through December 2022 and cumulative Candidate 23.01.23.06 for January–June 2023. Both were downloaded from the [official archive](https://ucdp.uu.se/downloads/olddw.html), parsed and pinned by SHA-256. July and August Candidate files are included as partial Q3 observations. The [release follow-up](forecast_origin_release_followup.md) recovered a 30 September 2023 capture of the official download page advertising annual GED 23.1, cumulative January–June and August 23.0.8. The full JRC report also records pre-origin use of the annual, cumulative and July versions. These sources support version availability, not identity between today's downloaded bytes and an original 2023 copy.

The annual release contains 316,818 global rows, including 7,220 DRC rows; the cumulative file has 10,504 global rows, including 598 DRC rows. The annual and cumulative **admitted occurrence windows are disjoint**. Each release is filtered independently using its own coordinates, event type, dates and precision. The same fixed 19 SALB-derived composites and strict one-sided-violence rules are used for comparability. Current boundary availability and the current nine-locality sample are not presented as authenticated historical choices.

The source inventory and ordered exclusion ledger account for all DRC rows. Retained events number 1,689 from GED 23.1 during 2014–2022 and 336 from January–June Candidate. There are no shared DRC IDs across the four input files. Globally, cumulative/July share 26 IDs and July/August share 16; these are not extra DRC events. The July–August window retains the last monthly representation before filtering, preserving discarded copies in a local ledger. No cross-source record is silently selected by membership in current GED.

All retained annual, cumulative and partial-month events have valid listed source dates, with no listed material after the forecast origin. This is a content sanity check, not proof of exact release dates or historical byte identity. The existing July raw-file 2032 date anomaly remains outside the retained sample and is not corrected here. [Input inventory](../data/forecast_training_source_inventory.csv), [exclusions](../data/forecast_training_event_flow.csv), [duplicates](../data/forecast_training_duplicate_audit.csv), [source-date checks](../data/forecast_training_source_dates.csv).

## Rebuilt histories and comparison

The local grid contains 760 locality-quarter rows from 2014 Q1 through 2023 Q4. It provides 722 covered complete-quarter rows through 2023 Q2, including prehistory. Counts in covered quarters are zero only when no eligible record survives the fixed filter; this does not establish complete reporting or no underlying violence. Q3 and Q4 counts remain missing.

Prior counts, `log1p` counts, consecutive positive-quarter spell lengths and left-censor flags are rebuilt from the archive-derived sequence. A violent spell already active at the beginning of 2014 is explicitly left-censored until a zero; unknown full lengths are not replaced by the observed lower bound. Missing Q3 propagates to the Q4 event-history predictors rather than becoming a zero or carrying July forward.

The comparison covers **2016 Q1–2023 Q2**, 30 quarters per locality:

| Comparison | All 19 candidate localities | Existing nine-locality sample |
|---|---:|---:|
| Locality-quarters compared | 570 | 270 |
| Archived / current recorded events | 1,979 / 2,016 | 1,119 / 1,147 |
| Rows with a changed outcome count | 57 | 36 |
| Rows with a changed prior-quarter count | 49 | 31 |
| Rows with a changed full violent-spell length | 7 | 3 |
| Rows with changed left-censor status | 0 | 0 |

The current comparator reconciles against both the retained history grid and the frozen analysis panel. The same-date-window differences demonstrate that using final-release histories can alter count and sequence predictors. They combine product differences, later additions or exclusions, revisions, coding and precision changes; they are not an estimate of reporting delay alone. The existing sample marker is descriptive, not a new prospective locality eligibility decision. [Quarter comparisons](../data/forecast_training_quarter_comparison.csv), [locality summaries](../data/forecast_training_locality_comparison.csv), [field comparison](../data/forecast_training_field_comparison.csv).

## What remains unavailable

July contains 30 retained events across all 19 localities (21 in the current nine); July–August contains 62 (40). These are **partial Q3 observations**, even though August version availability is now supported. September remains excluded from the supported information set. No partial sum is used as a full-quarter outcome or prior-quarter predictor. The public [availability mask](../data/forecast_training_availability.csv) keeps Q3 totals and Q4 event-count/spell inputs missing for every locality.

The latest complete training outcome quarter in this event reconstruction is therefore Q2. A Q3 row has a known preceding Q2 history but no complete supported Q3 outcome, so it is not admitted as a complete training response. Current retrospective validation trained through Q3; repeating that fit with these files would silently require information that has not been established here.

This extension reconstructs **event histories**, not a complete historical training design. The parallel [deployment follow-up](forecast_origin_coding_followup.md) supplies an early numeric prefix, and [joint coverage](forecast_training_followup.md) identifies its overlap. Later deployment histories, full-window within/between centering means, complete 2023 numeric coding, historical geographic choices and fitted locality effects remain unresolved. No modern exposure sequence is silently substituted. No origin forecast is issued, and the existing estimates and human-review disposition remain unchanged.

## Reproduction and checks

Run `Rscript scripts/reconstruct_forecast_training.R` after the current panel build. The script downloads missing pinned originals, rejects changed bytes, extracts the verified annual ZIP, and rebuilds all event histories. It does not overwrite the pilot's inputs. The [ten-input manifest](../data/forecast_training_inputs.csv) identifies originals, extracted annual data, fixed geography and comparison inputs. Four originals are used; only the annual ZIP and cumulative Candidate file are new downloads in this extension.

The script checks within-file ID uniqueness, source-specific exclusion accounting, disjoint retained training IDs, zero shared DRC IDs, 19-locality joins, 570 unique comparison keys, all missing-quarter masks, and exact equality between current-history and current-panel fields to numerical tolerance. Event-level provenance, duplicate ledgers, the reconstructed 760-row grid and row-level comparisons stay in ignored `outputs/forecast_training/`. Nine public CSVs contain aggregate evidence, comparisons and provenance. No human review is inferred from these computational checks.
