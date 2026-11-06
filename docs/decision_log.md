# Decision log

Append decisions and deviations; preserve superseded choices and reasons.

| ID | Recorded date | Status | Decision or open question | Evidence / next action |
|---|---|---|---|---|
| D001 | 2026-11-05 | confirmed | Current task is save the four-week plan and prepare Week 1 | User scope clarification; no empirical execution in this step |
| D002 | 2026-11-05 | confirmed | Primary outcome is recorded one-sided violence event count; interpretation is associational/predictive | Research protocol |
| D003 | 2026-11-05 | provisional | 2015–2023 window | Verify source coverage and obtain pre-period history |
| D004 | 2026-11-05 | open | Provinces and stable administrative unit | Compare boundary candidates and deployment variation |
| D005 | 2026-11-05 | open | Secondary civilian fatality definition and available bounds | Inspect version-specific codebook; keep other violence categories separate |
| D006 | 2026-11-05 | open | Monthly versus quarterly primary timing | Inspect independent map intervals and carry-forward ages |
| D007 | 2026-11-05 | open | Source versions and terms | Landing-page candidates are not pinned acquired releases |
| D008 | 2026-11-05 | open | Independent-assignment and null-effect simulation cases | Extend generator before the favorable-scenario validation gate |
| D009 | 2026-11-05 | open | Forecast-origin information availability | Lagged event occurrence does not guarantee historical publication availability; label retrospective forecasting if release vintages are unavailable |

For each new decision record its date, affected files, rationale, evidence and whether substantive estimates had already been inspected. Timestamp the frozen protocol separately from this preparation record.

## Week 1 audit update — 2026-11-05

The user authorized acquisition and the coverage/measurement audit. Twenty source artifacts were acquired and hashed. D004 has a leading candidate: 19 fixed SALB city–territory composites in North Kivu, South Kivu and Ituri. D005 is defined as `deaths_civilians` within retained one-sided events; other categories stay separate. D006 recommends quarterly timing for the next design without treating it as eliminating map uncertainty. The original 2015–2023 window was audited; 2016–2023 is proposed next because early Djugu geometry equivalence is unresolved. These recommendations do not silently change the model protocol.

Decision: **revise**, driven by unverified deployment absence and sparse binary changes. No deployment association was estimated. See `docs/feasibility_decision.md`. Original inputs and row-level outputs remain local and ignored.

## Quarterly revision authorized — 2026-11-05

The user authorized 2016–2023 quarterly work, absence investigation and common-strength-slope simulation before empirical fitting. Protocol revision 1 fixes exposure as the preceding quarter's mean listed military personnel per 1,000; unlisted is unknown. Complete exposure histories select nine of nineteen composites, yielding 288 synthetic-design rows. Two endpoint source maps were reviewed, without certifying absence across intervening maps. The core simulation uses synthetic outcomes on actual deployment schedules; it does not validate dynamic history adjustment or remove selection bias. No empirical models have been fitted.

Validation outcome: 200 replicates in each of four scenarios, all 800 fits usable. Favorable bias -0.0002 with 96% coverage; null bias -0.0097 with 94% coverage and 6% false nonzero intervals. Core gates pass; stress scenarios fail structural coverage. Summary aggregation was corrected and independently rechecked without changing fits or thresholds. Empirical fitting remains disabled. See `quarterly_validation_results.md`.

## Parallel validation and initial estimation — 2026-11-06

The quarterly panel reconciled 608 rows/2,166 events; the nine-locality sample has 288 rows / 1,248 events, complete observed histories and second strength lag. Freshness sensitivity showed no complete localities at a three-month limit. Predictor checks found lag correlation 0.954 and a rank-deficient initial-adjusted alternative. These findings were recorded before empirical fitting.

The ordinary dynamic model passed all prespecified favorable/null and correlated-prehistory gates across 1,400 retained fits including diagnostic alternatives. An overlapping-seed null extension was superseded with a disjoint-seed run; its records remain local and excluded. Independent recomputation confirmed all retained summaries. Selection/reporting stress results retain material bias.

A documented measurement decision permitted the two bounded baseline/history fits under the unchanged five-month rule. Both converged with positive Hessians. The common within-strength estimate is −0.1326 (95% Wald interval −0.7695 to 0.5043); this is an inconclusive conditional association. Full diagnostics, sensitivity and prediction remain open. See quarterly_empirical_results.md. Raw data and row-level outputs remain local.
