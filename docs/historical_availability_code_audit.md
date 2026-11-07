# Historical availability: code and retained-source checks

Completed 2026-11-07. This additive audit changes no panel, protocol, estimator or prediction. Run `Rscript scripts/audit_historical_source_dates.R` after the retained-input panel build. The two published aggregate outputs are [source-date counts](../data/historical_source_date_audit.csv) and [eligibility checks](../data/historical_eligibility_audit.csv).

## What the current code establishes

The exposure builder keeps unlisted grid cells missing, requires three numeric monthly strength observations, and rejects map ages outside zero to five months (`scripts/build_quarterly_exposure.R`, lines 16–26). Unknown deployment is not changed to zero. The full-window locality selection is explicit at lines 26 and 32. The panel's event lags and spell histories are built from earlier occurrence quarters (`scripts/build_quarterly_panel.R`, lines 61–82); this establishes temporal occurrence ordering, not historical availability of released records.

The predictive loop uses training rows strictly before the held-out quarter, replaces full-period centering with training-only locality means, and estimates locality effects on training data (`scripts/validate_quarterly_prediction.R`, lines 25–40 and 48–69). No new fitting or centering bug was identified in this review. It remains retrospective because these operations use the current retained releases.

## A bounded eligibility concern can be narrowed

For each of the 20 existing forecast folds, an alternative rule was evaluated: retain a locality only if every lagged exposure from 2016 Q1 through that fold's training end is nonmissing. **All 20 resulting locality sets are identical to the same nine localities selected by the existing full-window rule.** The first test quarter is 2019 Q1 after 12 training quarters; the last is 2023 Q4 after 31 training quarters.

This shows that this particular past-only completeness rule would not change the evaluated populations in these data. It does not turn retrospective records into historically available records, validate selection based on a different starting window or entry rule, establish generalizability to excluded localities, or remove dependence on listing completeness. The original implemented selection remains a full-window rule and is not relabeled prospective.

## Listed article dates provide direct evidence of delayed information

The script joins retained event IDs to `source_date` in the pinned GED 26.1 input. It splits semicolon-separated dates, rejects malformed nonmissing tokens, and treats the sentinel `1753-01-01` as missing. These conventions follow the [GED 26.1 codebook](https://ucdp.uu.se/downloads/ged/ged261.pdf), pages 9 and 19–20, reviewed 2026-11-07. The codebook distinguishes source-material publication from event occurrence and permits source dates before an event for attribution. Earliest and latest refer to the listed valid article dates for an event, not independently verified first discovery or the date the event entered GED. No retained event has a missing or invalid date token.

| Population | Events with valid listed dates / all events | Earliest listed date strictly after next quarter starts | Latest listed date strictly after next quarter starts |
|---|---:|---:|---:|
| Retained nine-locality events, 2016–2023 | 1,248 / 1,248 | 350 | 470 |
| Immediate prior-quarter events for the 20 forecast folds, 2018 Q4–2023 Q3 | 1,107 / 1,107 | 300 | 406 |

The comparison date is the first calendar day of the following quarter, interpreted as the candidate start-of-quarter forecast origin. Strictly later dates are counted separately from ties: in the forecast-history subset, two events have their earliest listed date on that day and none have their latest listed date on it. Day-level dates do not establish within-day availability. The broader 2016–2023 row has two earliest-date ties and one latest-date tie.

For the 300 immediate-history events whose earliest listed date is later than the candidate origin, every dated listed article is later. This is concrete evidence against assuming all released prior-quarter event information was observable from those listed articles at quarter start. It does not prove that no earlier unlisted information existed. For the 406 with a later latest date, at least one listed article is later; another article may already have existed. These counts are not estimates of the exact number of unavailable GED records or their earlier fatality/precision coding.

An article available by the origin does **not** establish that the event was already coded, included, geolocated with its final precision, or distributed in a GED release. The audit does not reconstruct release vintages, account for subsequent revisions or all earlier spell-history quarters, or refit a date-filtered model. Filtering the latest release by article dates alone would not recreate an authentic historical dataset. Release-specific records and a declared operational forecast origin would be needed for that task.

## Map dates need a separate interpretation

The lineage records `source_row`, represented month, map month, map age, source and strength; it contains no independently verified public-availability timestamp. `map_age` is calculated from the represented month and `source_year/source_month` (`scripts/audit_week_1.R`, lines 34–38). A month-to-map age is not a publication delay or a guarantee that the map was public at the modeled origin.

The legacy Week 1 figure label at `scripts/audit_week_1.R:269` says “Months since source-map publication”, and `docs/week_1_audit.md` uses the same shorthand. Read these as months since the **coded source-map date**, not verified publication timing. The current quarterly freshness figure already uses source-map-age wording (`scripts/plot_quarterly_coverage.R`, lines 42–46). The frozen legacy generator is not silently altered by this follow-up. No current portfolio prediction or causal claim is upgraded on the basis of these checks.
