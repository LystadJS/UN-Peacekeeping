# What could be known on 1 October 2023?

**A partial historical information set can be reconstructed, but the complete input set for the existing forecast cannot yet be authenticated.** The cutoff is 2023-10-01 at 00:00 UTC, predicting 2023 Q4. It was fixed before examining the new count contrasts. This supplement changes no pilot observations, estimates or forecasts.

## What the reconstruction establishes

The [release evidence](forecast_origin_release_evidence.md) documents pre-origin use of the July Candidate release: a later European Commission report records acquiring it on 22 August 2023. This supports the version's existence then, not identity between that historical copy and today's downloaded bytes. Equivalent pre-origin evidence was not established for August or September.

The [deployment reconstruction](forecast_origin_deployment.md) recovered three original UN reports with map revisions 49, 50 and 51, dated March, June and September 2023. The covers and map pages were inspected, and the report files are hashed. These sources support availability of the relevant map identities before the origin. They do not independently authenticate every modern Geo-PKO personnel estimate, coordinate, unit conversion or revision.

The [event reconstruction](forecast_origin_event_comparison.md) applies the same filters and fixed geography to each release's own records. Missing months are not replaced with zeros. These are same-occurrence-window comparisons:

| Window | Archived / current events, all 19 localities | Archived / current events, existing nine-locality sample | Interpretation |
|---|---:|---:|---|
| July | 30 / 39 | 21 / 23 | Version-level pre-origin use supported; historical byte identity unverified |
| July–August | 62 / 78 | 40 / 50 | Conditional comparison; August publication availability unverified |
| July–September | 85 / 112 | 53 / 71 | Retrospective full-quarter benchmark, not an as-of predictor |

Sixteen of the 85 full-quarter archived events have all dated listed sources after the cutoff. Thus the September-containing archive cannot simply be treated as the historical prior-quarter input. The counts also differ because Candidate and later GED are different products with revised records and precision; the gaps do not measure reporting delay alone. One implausible 2032 source date in a raw July record lies outside the retained sample and remains flagged, not corrected or interpreted as genuine publication evidence.

The full-quarter current counts reconcile to the existing Q4 lag field for all 19 localities. Rebuilding both deployment lags from retained lineage also reproduces all 19 current values and their missingness. Fourteen localities have numeric current strengths; five remain unknown. These reconciliations verify the comparator, not its historical availability. The nine fitted localities are shown only as the current sample, not a newly established historical population.

## What still prevents an authenticated forecast

| Required input | Current disposition | Evidence needed |
|---|---|---|
| Complete prior-quarter event count | Unknown at the cutoff; July is only a partial window | Verified available releases, their historical contents, and a rule for the unreleased last month |
| Q2 and Q3 personnel strength | Relevant dated maps recovered; numeric vintage coding unverified | Contemporaneous Geo-PKO files or independent full symbol/unit-size/coordinate recoding |
| Earlier event histories and violent spells | Not reconstructed in this bounded exercise | Compatible historical annual/Candidate releases, deduplication and revision reconciliation |
| Training data, centering means and fitted locality effects | Current retrospective versions are insufficient | Rebuild the entire pre-origin training set, then refit under the historical information set |
| Boundaries and locality eligibility | Fixed modern composites used for comparability | Historically available geography and a prospectively applied entry rule |
| Exact first publication and byte identity | Partly documented, not fully authenticated | Dated archived copies, provider version logs or contemporaneous checksums |

Calendar time and season are known at the origin. Their availability does not resolve missing empirical predictors. Certified full-quarter event counts and both certified strength fields remain missing in the exported comparisons. No operational forecast is issued, and no unavailable input is silently borrowed from the final-release panel.

The next defensible step is to resolve the last-month information rule and obtain the historical numeric deployment coding, then reconstruct training histories for this same origin. A delayed forecast origin or a model designed around a longer reporting lag would change the forecasting task and requires a separately stated design. This one-origin exercise does not validate the other 19 folds.

## Reproduction

After the original panel has been built, run:

```r
source("scripts/acquire_forecast_origin_inputs.R")
source("scripts/reconstruct_forecast_origin_events.R")
source("scripts/audit_forecast_origin_deployment.R")
source("tests/run_forecast_origin_checks.R")
```

Acquisition verifies six pinned originals and downloads only missing files. Changed upstream bytes cause failure. The comparisons retain row-level provenance locally; published CSVs contain aggregate counts, evidence and locality summaries. Cross-checks verify 11 analysis/report input hashes, unique comparison keys, current-panel reconciliation, unknown certified fields and the unchanged 18-file analysis snapshot. See [the protocol](forecast_origin_reconstruction_protocol.md) and [check receipt](../data/forecast_origin_checks.json). Human review remains skipped by user instruction, not completed.
