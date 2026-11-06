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

## Follow-up evaluation completed — 2026-11-06

The user authorized parallel residual diagnostics, influence checks, sensitivity analysis, and predictive evaluation. Detailed protocols were recorded before the main runs; auxiliary Pearson residuals, score-concentration summaries and the joint reporting grid are explicitly documented as follow-up additions. No more favorable primary specification or sample was selected after results.

All 34 deletion fits, 44 sensitivity fits, and 40 rolling prediction fits met their numerical checks. The history model retains a lag-2 residual warning. All 17 history deletion intervals and all 11 measurement/secondary/monthly intervals include zero, but deployment-timing alternatives reverse the point estimate. Reporting-offset conclusions depend on assumed recording mechanisms; linear-offset thresholds are algebraic rather than estimated reporting rates.

History improves mean held-out log score by 0.0429 across 180 forecasts, with 14 of 20 favorable quarters but only four of nine favorable locality averages. Removing Irumu scores reverses the mean gain. Both plug-in 95% intervals cover 171/180 outcomes. This is retrospective prediction in the selected sample, not full predictive uncertainty or operational validation.

Independent checks reconstructed prediction means and probabilities, verified training-only information, confirmed primary-input hashes, checked saved model summaries, and audited timing/source boundaries. A source-map summary-ordering check was repaired without changing numerical findings. See quarterly_evaluation_findings.md and quarterly_evaluation_peer_review.md. Remaining work concerns scientific refinement, external/human review and portfolio preparation rather than unexecuted checks in this requested evaluation scope.

## Research discussion portfolio prepared — 2026-11-06

Parallel agents prepared a four-page research memo, final ggplot2 figures, and a five-slide editable discussion deck from the saved evaluation at analysis commit 36f4b09adcddb954db3de59975155fc95659f513. No new models were fitted or more favorable specifications selected for presentation. The memo and deck retain the inconclusive common association, residual temporal warning, concentrated retrospective predictive gains, and conditional reporting sensitivity.

The proposed local-effect figure was replaced with evidence about the common association and simulation recovery because locality-specific slopes were not fitted. Scott's research connections were checked against primary institutional/publication sources and are bounded in docs/scott_research_connection.md. The package includes two discussion questions and one prespecified-history extension.

PDF pages, figure exports and all five slides were visually reviewed; package and numeric checks are recorded in docs/portfolio_validation.md. These are agent checks, not the independent human interpretation required for final acceptance. A clean locked-environment end-to-end rebuild, human review and prospective operational validation remain open. No outreach was sent.

## Clean reproduction and portfolio repairs — 2026-11-06

The user authorized parallel final-portfolio auditing and an end-to-end clean run. The isolated run reconstructed original-file audits, panels, all 2,200 simulation fits, primary models and follow-up evaluations; 383 scientific comparisons passed. Presentation wording, PNG device selection and parallel failure handling were repaired without changing scientific estimates. The regenerated figures, memo and deck passed structural and agent visual review. Exact Windows installed-package hashes and non-R artifact runtime details are recorded. Fresh source installation and independent human review remain untested; the latter is explicitly false in status. See docs/clean_rebuild_results.md.
