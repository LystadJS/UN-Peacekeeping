# Release evidence and reconstructed training histories

Completed 2026-11-07 for **1 October 2023 at 00:00 UTC**, preserving the original forecast date and fitted pilot. The available historical event sequence and an early deployment sequence are now reconstructed. **The complete information set for a Q4 forecast is still missing.** No replacement forecast or model was fitted.

## What is newly resolved

An [archived official UCDP download page](https://web.archive.org/web/20230930030400id_/https://ucdp.uu.se/downloads/) captured on **30 September 2023 at 03:04 UTC** explicitly advertises annual GED 23.1, cumulative January–June Candidate and August Candidate 23.0.8. The retrieved HTML, archive response timestamp and links were verified. This resolves the earlier lack of pre-cutoff public-advertisement evidence for August; it does not establish an exact first-release time or authenticate today's CSV bytes. The full JRC report documenting earlier annual/cumulative/July use was also obtained. [Release investigation and provenance](forecast_origin_release_followup.md)

The provider's pinned December 2020 Git repository supplies Geo-PKO 2.0 with a matching Git blob hash. It covers MONUSCO through December 2019. Four superseded map revisions had to be excluded before aggregation; otherwise the same deployments would be counted more than once. This reconstructs a real older numeric deployment sequence, rather than substituting the current release. [Deployment coding investigation](forecast_origin_coding_followup.md)

## Training histories and current-panel comparison

GED 23.1 supplies event histories from 2014 through 2022; cumulative Candidate supplies January–June 2023. Each vintage's own dates, coordinates and precision are used. The same fixed geography isolates record differences but remains a retrospective geographic choice. Prior counts, transformed counts, violent spells and left-censor flags were rebuilt; independent run-length checks verify the spell calculations. [Event reconstruction](forecast_training_reconstruction.md)

| Complete outcome quarters, 2016 Q1–2023 Q2 | All 19 localities | Current nine-locality sample |
|---|---:|---:|
| Locality-quarters compared | 570 | 270 |
| Archived / current recorded events | 1,979 / 2,016 | 1,119 / 1,147 |
| Changed outcome-count rows | 57 | 36 |
| Changed prior-count rows | 49 | 31 |
| Changed full spell-length rows | 7 | 3 |

July–August supplies **62 partial-quarter events across all 19 localities, 40 in the current nine**. These are not full Q3 totals. September remains excluded; full Q3 counts and the Q4 event-history predictors remain missing. The available event history provides 30 complete training outcome quarters, compared with 31 used in the existing retrospective fold. Changes between products combine later information, classification, precision and other coding revisions; they are not a clean estimate of reporting delay.

The older deployment file supplies **164 known first-lag locality-quarters**, all matching the current panel over their overlap. In the current nine-locality sample it supplies 153 cells: 17 outcome quarters per locality through 2020 Q1. Later first-lag exposure is not extrapolated from the final 2019 map. Thirty selected sized-unit and FPU components on the 2023 maps also match current coding under the historical codebook's conversion rules; ambiguous and unsized components remain unresolved. These selected, unblinded agent checks are not a comprehensive recoding or measured troop census.

Joining the reconstructed event histories with both archived deployment lags produces **162 populated training rows across the 19 candidates, including 153 in the current nine**. The [joint-coverage table](../data/forecast_training_joint_coverage.csv) gives their bounds. These rows are a partial overlap, not an authenticated full training sample or a new inclusion rule. Full-window deployment centering remains unavailable for every locality.

## What remains unresolved

- **September information and the target-quarter lags:** a complete prior-quarter event count cannot be inferred from July–August or substituted from GED 26.1.
- **Later deployment coding:** the recovered older release does not cover 2020–September 2023. Selected symbol checks do not replace complete unit, police, geosplit and coordinate reconstruction.
- **Complete model training:** earlier event histories are rebuilt, but the full joint event/deployment sequence, centering means and a historical refit remain incomplete.
- **Historical identity and geography:** current downloaded event CSVs are pinned but not matched to preserved 2023 bytes; fixed SALB composites are not authenticated historical digital inputs.
- **Interpretation:** none of these repairs establishes a causal protection effect, complete reporting or verified military absence.

The new evidence supports a longer partial reconstruction and narrows the missing inputs. It does not justify changing the original estimates, treating unavailable months as zeros, or declaring operational validation complete. No provider was contacted. Human review remains skipped, not completed.

## Reproduction and checks

After the original panel and prior one-origin supplement exist, run:

```r
source("scripts/reconstruct_forecast_training.R")
source("scripts/audit_forecast_origin_coding.R")
source("scripts/assemble_forecast_training_availability.R")
source("tests/run_forecast_training_checks.R")
```

The first two scripts verify pinned inputs and download missing dataset/codebook originals. Preserve the seven release-evidence artifacts at their ledger paths for the archive-response and hash checks; these include locally recorded response metadata, not just remotely downloadable datasets. Raw files and detailed histories remain ignored. Static source and symbol-transcription ledgers are distinguished from generated comparisons in the clean workflow. The additive stages were rerun in the isolated project, without repeating model estimation. See [check receipt](../data/forecast_training_checks.json).
