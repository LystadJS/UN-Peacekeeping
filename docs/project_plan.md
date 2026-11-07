# MONUSCO Multilevel Research Pilot

**Goal:** Produce an audited dataset, validated simulation, defensible multilevel analysis, and concise research portfolio suitable for discussing research-assistant work with Dr. Scott.

**Plan recorded:** 2026-11-05 (America/New_York). Weeks indicate sequence and approximate effort, not scheduled dates. Week 1 acquisition and audit were subsequently authorized and executed; see [findings](week_1_audit.md). Decision: revise the design. The revised quarterly model, bounded simulation evaluation and follow-up diagnostics are now complete; see the active revision below.

Checked items have evidence in the current repository. On 2026-11-06 the user skipped human review; unchecked items explicitly marked skipped, deferred or unresolved are not unexecuted routine work. See [remaining-task assessment](remaining_task_assessment.md). Unchecked items may have scaffolding but have not met their acceptance conditions. Change status only when an evidence path can be recorded. See [Week 1 runbook](week_1_runbook.md), [research protocol](research_protocol.md), and [decision log](decision_log.md).

**Authorized scope revision:** the active pilot is 2016–2023 quarterly, with a common listed-strength slope in 19 candidate composites and nine complete-history localities. Monthly binary-presence models, the original eight-cell heterogeneity design and locality-specific slope recovery are deferred extensions, not requirements that have already been satisfied. The [quarterly protocol](quarterly_protocol.md) controls current modeling. The core and ordinary dynamic simulation gates passed, panel checks passed, and the bounded baseline/history fits are complete. The requested residual, influence, sensitivity and retrospective prediction evaluation is complete; unresolved model limitations remain; the research portfolio is now prepared. See quarterly_evaluation_findings.md. An independent review and parallel follow-up work began on 2026-11-06.

## 1. Data audit and feasibility — Week 1

### Research scope

- [x] Define the primary question: how does the association between deployment and subsequent recorded violence vary across localities? Evidence: README and research protocol.
- [x] Define the methodological question: when do deployment selection and incomplete reporting distort that association? Evidence: README and research protocol.
- [x] Set recorded UCDP one-sided violence event counts as the primary outcome. Evidence: research protocol and analysis config.
- [x] Define civilian fatalities as a secondary outcome, distinguishing targeted killings from other civilian deaths. Evidence: Week 1 audit; `deaths_civilians` within one-sided events is separate from other categories.
- [x] Confirm the revised 2016–2023 quarterly scope and fixed city–territory composites. Complete-history restriction and generalization limits are explicit in the quarterly protocol.
- [x] Record the intended interpretation: observational associations and predictive performance. Evidence: research protocol.

### Source collection and provenance

- [x] Obtain Geo-PKO deployment data, UCDP GED, their codebooks and suitable administrative boundaries. Evidence: 20-artifact manifest; SALB and geoBoundaries acquired; HDX geometry download failed.
- [x] Record source URLs, versions, retrieval dates, file hashes and applicable use requirements. Evidence: source manifest; unresolved Geo-PKO redistribution permission is documented.
- [x] Preserve original files separately from processed data. Evidence: ignored `data/raw/` and `data/interim/`.
- [x] Complete the active quarterly data dictionary: all 36 exported fields have definitions, units, missingness and transformation rules. Evidence: data/quarterly_data_dictionary.csv and docs/quarterly_source_spotchecks.md.
- [x] Establish an R project with relative paths, fixed seeds and recorded packages. The clean run verified exact installed-package versions and hashes in an isolated Windows/R library; source reinstall and cross-platform restoration remain untested.

### Coverage and measurement audit

- [x] Inventory observations by locality, month and source. Evidence: Week 1 audit outputs.
- [x] Check duplicate identifiers, invalid dates, impossible coordinates and inconsistent locality names. Evidence: source checks and name/discrepancy ledgers.
- [x] Audit administrative boundary changes and document the geographic crosswalk. Evidence: four vintages and footprint comparison; early Djugu equivalence remains unresolved.
- [x] Keep unknown listing status separate from zero; do not certify absence from missing listings. Evidence: deployment_absence_review.md and source spot checks. Verified absence remains unavailable.
- [x] Preserve deployment-map dates and identify months populated through carry-forward. Evidence: monthly-to-map reconciliation and freshness table.
- [x] Inspect conflict-event date and location precision; define exclusion or aggregation rules. Evidence: strict feasibility rules and event ledger; primary model protocol and current snapshot are documented.
- [x] Identify localities with sufficient deployment changes to support within-locality analysis. Assessment completed: sparse support and unverified zeros prevent approval of varying presence slopes.

### Outputs and visualizations

- [x] Produce a source inventory, data dictionary and machine-readable audit table. Audit field mappings populated; quarterly model predictors are now constructed and checked in the panel audit.
- [x] Create a locality-by-time coverage heatmap. Evidence: deployment and retained-event heatmaps in local figure outputs.
- [x] Plot deployment observation freshness and intervals between source maps. Evidence: freshness figure with update lines and map schedule table.
- [x] Create a geographic overview showing retained localities and uncertain event locations. Evidence: inspected geographic overview.

### Evaluation and progress gate

- [x] Resolve every duplicate analysis key and unexplained join expansion. No duplicate feasibility or quarterly analysis keys or unexplained join expansion; panel tests and clean reproduction passed.
- [x] Account for every excluded record with a documented reason. Evidence: all 5,511 DRC audit records accounted for; global country/year filter reproducible.
- [x] Confirm that retained observations can be traced to their sources. Evidence: event IDs and deployment source-row/map references.
- [x] Decide whether monthly timing is defensible or quarterly aggregation should be primary. Quarterly is primary; the explicitly exploratory monthly sensitivity was completed.
- [x] Record the feasibility decision: **revise the design**. Evidence: `feasibility_decision.md`; the later authorized quarterly revision completed bounded empirical estimation.

## 2. Minimal simulation and model validation — Weeks 1–2

### Minimal data-generating process

- [x] Simulate repeated quarterly observations within localities. Evidence: core quarterly generator; monthly design is deferred.
- [x] Generate locality-specific baseline violence and overdispersed event counts. Evidence: NB2 core simulation.
- [x] Specify a known common deployment effect under a favorable exposure design. The core conditions on observed strength schedules; dynamic assignment is a separate scenario.
- [x] Fit the common-strength simulation count model and the separate empirical baseline. Evidence: quarterly_validation_results.md and quarterly_empirical_results.md.
- [x] Check the declared generators and all dynamic generated panels for valid counts, thinning and history distributions. Evidence: dynamic_quarterly_generated_audit.csv and generator checks; simulations remain illustrative rather than calibrated to the DRC.
- [x] Confirm that core coefficients and truth share the log-count scale per 1,000 listed personnel. Dynamic extension checked separately.

The common-strength core passed its favorable/null gate. This does not validate history adjustment or endogenous deployment. The baseline without strength has no strength coefficient; recovery uses the corresponding strength model. The original binary generator is retained as historical scaffolding.

### Challenging scenarios

- [x] Add deployment responding to prior violence. Evidence: dynamic selection scenario.
- [x] Add a controlled hidden-risk confounding stress case. Evidence: core stress simulation; temporal selection remains a separate requirement.
- [x] Add constant versus deployment- and risk-dependent recording probabilities. Evidence: core simulation; not estimated DRC reporting rates.
- [ ] Deferred: compare common versus heterogeneous effects after common-slope recovery is defensible.
- [ ] Deferred: implement the original eight-cell selection/reporting/heterogeneity design if heterogeneity is reinstated.
- [x] Include a null-effect scenario to assess spurious directional conclusions. Evidence: core null scenario.
- [x] Preserve all 2,000 unique generated panels, their full returned objects, seeds, generator sources and hashes locally. They cover all 2,200 fit attempts. Evidence: simulation_archive.md.

### Performance evaluation

- [x] Run initial replications: 200 per core scenario, 800 total; dynamic runs reported separately.
- [x] Track convergence, failed fits and runtime in core evaluation; retain all attempts.
- [x] Measure core coefficient bias, RMSE and interval coverage.
- [ ] Deferred: measure between-locality slope-variation recovery if varying slopes return to scope.
- [x] Measure confidently incorrect directional conclusions in core scenarios.
- [x] Assess Monte Carlo precision for the bounded comparisons. Required gate coverage MCSEs meet the prespecified threshold; stress-case intervals establish large recovery failures. A tight claim about near-threshold null bias remains unsupported. No additional fits were selected to force a pass.
- [x] Set core tolerances before the validation run; dynamic tolerances recorded independently before that run.

### Outputs and visualizations

- [x] Plot common-strength estimates against known truth. Evidence: inspected core recovery figure.
- [x] Create coverage and directional-error panels by scenario. Evidence: inspected dynamic interval-performance figure.
- [x] Produce a core success/failure table. Evidence: quarterly validation results; dynamic conclusions remain separate.

### Evaluation and progress gate

- [x] Verify favorable common-strength core recovery. Ordinary history-adjusted recovery subsequently passed its required gates; see dynamic results.
- [x] Investigate numerical/initial-condition problems and keep adverse-scenario failures visible. Evidence: dynamic_quarterly_results.md and quarterly_evaluation_findings.md.
- [x] Separate fit usability, finite-sample uncertainty and structural recovery failures. Evidence: dynamic_quarterly_results.md and research memo.
- [x] Restrict estimation to the documented baseline and ordinary common-slope history model; no locality-specific slopes or estimator search. Evidence: empirical_quarterly_protocol.md.

## 3. Analysis panel and protocol — Week 2

### Panel construction

- [x] Construct the complete eligible locality–time grid.
- [x] Aggregate conflict events using the audited geographic and temporal rules.
- [x] Separate zero retained events from unknown deployment/ineligible rows. Evidence: quarterly panel dictionary, panel tests and six source spot checks.
- [x] Aggregate deployments without counting repeated representations of the same unit twice.
- [x] Calculate lagged deployment, prior violence and recent conflict-history variables.
- [x] Calculate within-locality deployment deviations and between-locality deployment averages.
- [ ] Unresolved: real-time information availability cannot be certified for the current panel. The 2026-11-07 investigation located archived UCDP releases, so blanket unavailability is no longer claimed; a complete as-of reconstruction across event, deployment and boundary sources has not been performed. Lag construction and training-only centering are verified. See [historical availability](historical_data_availability.md) and the [code audit](historical_availability_code_audit.md).
- [x] Reconstruct the available histories for the fixed 1 October 2023 origin: 570 event-training rows through Q2, an early deployment prefix and 162 jointly populated rows. Verify pre-origin advertisement of August and retain missing Q3 totals/later deployment coding. This completes the bounded [training follow-up](forecast_training_followup.md), not operational validation.
- [ ] Skipped with human review: manual source verification. A separate automated reconstruction of six fixed cases passed against original GED and Geo-PKO files; see quarterly_source_spotchecks.md.

### Analysis commitments

- [x] Specify baseline and history-adjusted common-slope models; explicitly defer varying slopes under the revised scope. Evidence: empirical_quarterly_protocol.md.
- [x] Define the conditional within-locality association per 1,000 prior-quarter listed military personnel. Evidence: empirical_quarterly_protocol.md.
- [x] Record the rolling windows, log scores and conditional 80%/95% count intervals before the main validation run. Evidence: quarterly_prediction_protocol.md; local protocol records are not external preregistration.
- [x] Document complete-history selection, strict primary event precision and five-month map freshness, with sensitivity alternatives. Evidence: quarterly_protocol.md and quarterly_sensitivity_protocol.md.
- [x] Defer locality slopes because the revised design does not establish recoverable heterogeneity. Evidence: quarterly_design_diagnostics.md and empirical_quarterly_protocol.md.
- [x] Distinguish the declared primary comparison from follow-up diagnostics and exploratory timing/outcome/reporting alternatives. Evidence: quarterly_evaluation_scope.md and decision_log.md.
- [ ] Historical limit: protocols report local pre-fit preparation, but no external preregistration or independently verifiable pre-results freeze exists. Do not backdate the current snapshot.

### Outputs and visualizations

- [x] Save the analysis panel with a reproducible construction script.
- [x] Produce a sample-flow table showing retention and exclusions.
- [x] Plot retained outcome/strength distributions and publish a 19-locality coverage/variation summary. Evidence: descriptive_panel_results.md and portfolio/figures/descriptive_panel_distributions.pdf.

### Evaluation and progress gate

- [x] Confirm unique locality–time keys and reconciled event totals.
- [x] Verify that joins have not duplicated events or deployments.
- [x] Assess variation: eight of nine retained localities vary in strength, one is constant, and adjacent lags are highly correlated. Common-slope precision is limited; varying slopes remain unsupported. Evidence: quarterly_design_diagnostics.md.
- [x] Record the current reviewed analysis snapshot with 18 file hashes and verify it. Evidence: config/analysis_snapshot.json and scripts/record_analysis_snapshot.R. This is a post-results snapshot, not retrospective preregistration.

## 4. Multilevel estimation and predictive evaluation — Week 3

### Model fitting

- [x] Fit the locality and calendar baseline model. Evidence: initial empirical results.
- [x] Add deployment and prespecified conflict-history variables. Evidence: initial empirical results.
- [x] Distinguish within-locality deployment associations from between-locality differences. Evidence: fitted history formula.
- [ ] Deferred: locality-specific slopes are outside the current approved common-slope pilot and are not supported merely by computational convergence.
- [x] Document estimator settings, convergence information and uncertainty calculations.

### Diagnostics and validation

- [x] Examine overdispersion, zero counts and extreme-event reproduction.
- [x] Examine residual temporal and spatial dependence.
- [x] Inspect random-intercept variance, numerical boundary flags and locality/year influence. No near-zero SD among 36 inspected fits; material variance shifts and small-cluster uncertainty remain.
- [x] Evaluate predictions using rolling temporal validation.
- [x] Compare predictive log scores and interval coverage against the baseline.
- [x] Assess performance in high-violence periods, alongside aggregate performance.
- [x] Exclude held-out outcomes and future exposure means from fitting. Full-period locality selection and retrospective release availability remain explicit limitations; this is not fully prospective validation.
- [x] Describe validation as forecasting recorded violence, not unobserved violence.

### Outputs and visualizations

- [x] Create three-locality trajectories with source-map dates and held-out intervals, plus an all-nine supplement. Evidence: portfolio/figures/figure_1_trajectories.pdf and portfolio_figure_notes.md.
- [ ] Deferred: no locality-specific deployment coefficients were fitted. Common-association sensitivity and simulation-recovery figures replace this unsupported display.
- [x] Show predictive performance across validation periods.
- [x] Retain the inconclusive common association; locality-specific heterogeneity remains deferred, not estimated.

### Evaluation and progress gate

- [x] Resolve computational issues and disclose material diagnostic limitations within the evaluated scope. Residual temporal structure and concentrated predictive gains remain.
- [x] Assess locality/year influence. All deletion intervals remain inconclusive, but point estimates shift; the predictive gain reverses when Irumu scores are omitted. Uniform stability is not established.
- [x] Assess history prediction: a small average gain is concentrated geographically. Varying slopes remain deferred and unvalidated.
- [x] Avoid interpreting prediction gains or adjusted coefficients as causal identification.

## 5. Observation uncertainty and robustness — Week 3

### Reporting sensitivity

- [x] Define the assumed relationship between underlying and recorded events.
- [x] Specify hypothetical recording probabilities and their dependence on deployment and risk.
- [x] Explain which assumptions are externally informed and which are illustrative.
- [x] Recalculate conclusions across the prespecified scenarios.
- [x] Identify assumptions under which estimated associations change direction or become inconclusive.
- [x] Separate uncertainty within each scenario from differences across scenarios.
- [x] State explicitly that reporting sensitivity does not resolve deployment confounding.

### Timing and geographic sensitivity

- [x] Compare an exploratory monthly analogue with quarterly results. Different exposure/history horizons and unvalidated monthly uncertainty prevent treating it as the same estimand.
- [x] Test alternative deployment-change timing assumptions consistent with source-map intervals.
- [x] Repeat analyses excluding especially stale deployment observations.
- [x] Test sensitivity to uncertain event dates and locations.
- [x] Compare primary and secondary outcomes without treating them as interchangeable measures.

### Outputs and visualizations

- [x] Plot deployment associations against assumed relative recording probabilities.
- [x] Create a specification comparison showing estimates under the main timing and inclusion rules.
- [x] Produce a robustness table distinguishing stable findings, assumption-dependent findings and unresolved results.

### Evaluation and progress gate

- [x] Identify which conclusions survive the prespecified alternatives.
- [x] Label sensitivity results as conditional, rather than corrections known to recover truth.
- [x] Document additional evidence that would most reduce the remaining uncertainty.

## 6. Research portfolio and practical impact — Week 4

### Research memo

- [x] Write a 3–4-page memo covering the question, data, model, simulation, findings and limitations.
- [x] Explain what the simulation establishes and what the empirical analysis cannot establish.
- [x] Connect the work specifically to Scott’s interests in histories, heterogeneity, uncertainty and usable methods.
- [x] Distinguish methodological application from any genuinely new contribution.
- [x] Identify one bounded follow-on research question suitable for supervision.

Evidence: portfolio/research_memo.pdf (four pages), portfolio/scott_discussion.pptx (five slides), portfolio/figures/, and docs/scott_research_connection.md. The primary sources identify Marc A. Scott; no outreach is authorized by this plan.

### Figures and presentation

- [x] Finalize simulation-recovery, trajectory, common-association and sensitivity figures. Existing coverage figures remain audit artifacts; locality-specific heterogeneity is deferred by the revised design.
- [x] Use ggplot2 with consistent typography, scales, uncertainty displays and accessible colors.
- [x] Label counts, time units, sample sizes and exclusions clearly.
- [x] Produce a five-slide discussion deck using actual results.
- [x] Remove or prominently label any remaining simulated presentation examples.

### Real-world relevance

- [x] Identify which findings could improve monitoring or evaluation practice.
- [x] Identify specific information gaps that better records could address.
- [x] Explain how reporting differences could distort assessments of civilian protection.
- [x] State what prospective validation would be required before operational forecasting.
- [x] Avoid translating uncertain locality associations into deployment recommendations or success rankings.

### Reproducibility and final acceptance

- [x] Run the active revised workflow from retained original inputs through final tables, figures, memo and deck in an isolated environment. Evidence: docs/clean_rebuild_results.md; 383 scientific comparisons passed. This is an installed-binary environment reproduction, not a fresh source installation.
- [x] Confirm source versions, random seeds and package environments are recorded.
- [x] Verify every numerical statement against the saved analysis outputs.
- [x] Document failed models, exclusions, deviations and unresolved discrepancies.
- [ ] Skipped at the user's request on 2026-11-06: independent human interpretation. The optional packet is retained; no feedback was received and human review is not marked complete.
- [x] Prepare a concise explanation of the skills demonstrated: data auditing, multilevel modeling, simulation and uncertainty analysis.
- [x] Prepare two focused questions for Scott about the findings and a possible research extension.

Independent reader review was waived by the user for continuation. It remains unperformed; agent checks do not convert it into completed human review.
