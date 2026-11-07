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

## Human-review packet prepared — 2026-11-06

Prepared a versioned reviewer guide, second-pass checklist and blank feedback form for the memo, figures and deck. The guide collects unaided interpretation before presenting diagnostic prompts, records partial coverage and requested revisions, and separates feedback receipt from acceptance. No feedback has been received, no outreach was sent, and all human-review flags remain false.

## Human review skipped; bounded task completion — 2026-11-06

The user explicitly requested skipping human review and continuing parallel work. Review status is now skipped_by_user; feedback_received and human_review_complete remain false. The optional packet is retained. No human approval, response or PowerPoint test is inferred.

Parallel follow-up completed the 36-field quarterly dictionary, six original-source computer reconciliations, and a descriptive distribution/variation supplement. All 2,000 synthetic datasets from the existing 2,200 fit attempts were materialized locally from their original seeds, with no refitting. A current 18-file analysis snapshot was recorded and verified; it is post-results documentation, not retroactive preregistration. Stale plan checkboxes were reconciled against evidence while unverified real-time release availability, unperformed human work and unsupported varying slopes remain explicitly limited or deferred.

## Absence and historical availability investigated — 2026-11-07

Parallel source and code investigations found positive official deployment evidence for unlisted Djugu, verified two archived UCDP Candidate files, and distinguished map/occurrence dates from source publication, dataset release and retrieval dates. No missing strength was imputed, no locality was added and no model was refitted. Official UN report passages were accessible through indexed text; direct full-document retrieval failed and no full-source hash is claimed.

Of 1,107 immediate-history events for the 20 validation origins, 300 have earliest listed source dates after the next quarter begins. This concerns dated listed sources, not exact first GED availability or absence of earlier unlisted reports. A complete-since-2016 rule using only earlier exposure quarters selects the same nine localities at every fold; contemporaneous data availability still cannot be certified. The older blanket claim that historical releases are unavailable has been replaced with a bounded archive-reconstruction route.

Both new R audits passed in the working and isolated clean projects. Their four aggregate outputs matched exactly; the 18 frozen analysis files remain verified. These were additive checks, not a new full fitting run. Historical evidence ledgers are static provenance; the clean workflow now includes the two generated-audit stages. Human review remains skipped by user instruction, not completed. See deployment_absence_followup.md, historical_data_availability.md and historical_availability_code_audit.md.

## One historical forecast origin investigated — 2026-11-07

The origin was fixed at 2023-10-01 00:00 UTC before examining new archived-event contrasts. Parallel agents recovered release evidence, compared three monthly Candidate files with current GED records using each vintage's own fields, and acquired three original UN reports carrying all maps underlying Q2/Q3 deployment lags. No new model was fitted. July version existence is supported by a later institutional record of pre-origin use; exact historical bytes remain unauthenticated. August publication remains unverified, and the full-Q3 benchmark includes 16 retained events with all dated listed sources after the origin.

Across all 19 candidate localities, July archived/current counts are 30/39; the retrospective Q3 benchmark is 85/112. In the current nine-locality sample these are 21/23 and 53/71. The current full-quarter counts and both strength lags reconcile to the frozen panel. These comparisons do not certify the historical inputs: full-quarter certified counts and strengths remain missing, earlier training histories are unreconstructed, and fixed-geography availability remains unresolved. A raw July source-date anomaly in 2032 lies outside the retained sample and was not corrected or treated as proof of publication.

The supplement's acquisition, two analysis stages and independent cross-check passed in working/isolated environments; eight generated CSVs matched exactly. Eleven source/analysis hashes and the 18-file analysis snapshot were verified. This is an additive reconstruction check, not a new full estimation run. See forecast_origin_reconstruction.md and data/forecast_origin_checks.json. Human review remains skipped, not completed.
