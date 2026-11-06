# MONUSCO Multilevel Research Pilot

**Goal:** Produce an audited dataset, validated simulation, defensible multilevel analysis, and concise research portfolio suitable for discussing research-assistant work with Dr. Scott.

**Plan recorded:** 2026-11-05 (America/New_York). Weeks indicate sequence and approximate effort, not scheduled dates. Week 1 acquisition and audit were subsequently authorized and executed; see [findings](week_1_audit.md). Decision: revise the design. Empirical fitting and full simulation evaluation remain pending.

Checked items have evidence in the current repository. Unchecked items may have scaffolding but have not met their acceptance conditions. Change status only when an evidence path can be recorded. See [Week 1 runbook](week_1_runbook.md), [research protocol](research_protocol.md), and [decision log](decision_log.md).

**Authorized scope revision:** the active pilot is 2016–2023 quarterly, with a common listed-strength slope in 19 candidate composites and nine complete-history localities. Monthly binary-presence models, the original eight-cell heterogeneity design and locality-specific slope recovery are deferred extensions, not requirements that have already been satisfied. The [quarterly protocol](quarterly_protocol.md) controls current modeling. The core and ordinary dynamic simulation gates passed, panel checks passed, and the bounded baseline/history fits are complete. The requested residual, influence, sensitivity and retrospective prediction evaluation is complete; unresolved model limitations and portfolio tasks remain open. See quarterly_evaluation_findings.md. An independent review and parallel follow-up work began on 2026-11-06.

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
- [ ] Create a data dictionary documenting variable definitions, units, missing values and transformations.
- [ ] Establish an R project with relative paths, fixed random seeds and recorded package versions. Project and seed exist; a tested, locked analysis environment remains pending.

### Coverage and measurement audit

- [x] Inventory observations by locality, month and source. Evidence: Week 1 audit outputs.
- [x] Check duplicate identifiers, invalid dates, impossible coordinates and inconsistent locality names. Evidence: source checks and name/discrepancy ledgers.
- [x] Audit administrative boundary changes and document the geographic crosswalk. Evidence: four vintages and footprint comparison; early Djugu equivalence remains unresolved.
- [ ] Distinguish observed deployment absence from unknown deployment status.
- [x] Preserve deployment-map dates and identify months populated through carry-forward. Evidence: monthly-to-map reconciliation and freshness table.
- [x] Inspect conflict-event date and location precision; define exclusion or aggregation rules. Evidence: strict feasibility rules and event ledger; model protocol not yet frozen.
- [x] Identify localities with sufficient deployment changes to support within-locality analysis. Assessment completed: sparse support and unverified zeros prevent approval of varying presence slopes.

### Outputs and visualizations

- [x] Produce a source inventory, data dictionary and machine-readable audit table. Audit field mappings populated; quarterly model predictors are now constructed and checked in the panel audit.
- [x] Create a locality-by-time coverage heatmap. Evidence: deployment and retained-event heatmaps in local figure outputs.
- [x] Plot deployment observation freshness and intervals between source maps. Evidence: freshness figure with update lines and map schedule table.
- [x] Create a geographic overview showing retained localities and uncertain event locations. Evidence: inspected geographic overview.

### Evaluation and progress gate

- [x] Resolve every duplicate analysis key and unexplained join expansion. No duplicate feasibility keys or join expansion; final model panel remains pending.
- [x] Account for every excluded record with a documented reason. Evidence: all 5,511 DRC audit records accounted for; global country/year filter reproducible.
- [x] Confirm that retained observations can be traced to their sources. Evidence: event IDs and deployment source-row/map references.
- [x] Decide whether monthly timing is defensible or quarterly aggregation should be primary. Recommend quarterly for revised pilot; monthly sensitivity remains necessary.
- [x] Record the feasibility decision: **revise the design**. Evidence: `feasibility_decision.md`; empirical estimation is not cleared.

## 2. Minimal simulation and model validation — Weeks 1–2

### Minimal data-generating process

- [x] Simulate repeated quarterly observations within localities. Evidence: core quarterly generator; monthly design is deferred.
- [x] Generate locality-specific baseline violence and overdispersed event counts. Evidence: NB2 core simulation.
- [x] Specify a known common deployment effect under a favorable exposure design. The core conditions on observed strength schedules; dynamic assignment is a separate scenario.
- [ ] Fit the proposed baseline count model.
- [ ] Verify that simulated deployment, violence and locality differences match their intended distributions.
- [x] Confirm that core coefficients and truth share the log-count scale per 1,000 listed personnel. Dynamic extension checked separately.

The common-strength core passed its favorable/null gate. This does not validate history adjustment or endogenous deployment. The baseline without strength has no strength coefficient; recovery uses the corresponding strength model. The original binary generator is retained as historical scaffolding.

### Challenging scenarios

- [x] Add deployment responding to prior violence. Evidence: dynamic selection scenario.
- [x] Add a controlled hidden-risk confounding stress case. Evidence: core stress simulation; temporal selection remains a separate requirement.
- [x] Add constant versus deployment- and risk-dependent recording probabilities. Evidence: core simulation; not estimated DRC reporting rates.
- [ ] Deferred: compare common versus heterogeneous effects after common-slope recovery is defensible.
- [ ] Deferred: implement the original eight-cell selection/reporting/heterogeneity design if heterogeneity is reinstated.
- [x] Include a null-effect scenario to assess spurious directional conclusions. Evidence: core null scenario.
- [ ] Preserve latent event counts, recorded counts, deployment assignments and true parameters.

### Performance evaluation

- [x] Run initial replications: 200 per core scenario, 800 total; dynamic runs reported separately.
- [x] Track convergence, failed fits and runtime in core evaluation; retain all attempts.
- [x] Measure core coefficient bias, RMSE and interval coverage.
- [ ] Deferred: measure between-locality slope-variation recovery if varying slopes return to scope.
- [x] Measure confidently incorrect directional conclusions in core scenarios.
- [ ] Increase replications until Monte Carlo uncertainty is sufficiently small for the planned comparisons.
- [x] Set core tolerances before the validation run; dynamic tolerances recorded independently before that run.

### Outputs and visualizations

- [x] Plot common-strength estimates against known truth. Evidence: inspected core recovery figure.
- [x] Create coverage and directional-error panels by scenario. Evidence: inspected dynamic interval-performance figure.
- [x] Produce a core success/failure table. Evidence: quarterly validation results; dynamic conclusions remain separate.

### Evaluation and progress gate

- [x] Verify favorable common-strength core recovery. Ordinary history-adjusted recovery subsequently passed its required gates; see dynamic results.
- [ ] Investigate unexpected failures before interpreting adverse scenarios.
- [ ] Distinguish computational failure, finite-sample limitations and structural bias.
- [ ] Freeze a manageable model set for the empirical analysis.

## 3. Analysis panel and protocol — Week 2

### Panel construction

- [x] Construct the complete eligible locality–time grid.
- [x] Aggregate conflict events using the audited geographic and temporal rules.
- [ ] Distinguish zero recorded events from unavailable or ineligible observations.
- [x] Aggregate deployments without counting repeated representations of the same unit twice.
- [x] Calculate lagged deployment, prior violence and recent conflict-history variables.
- [x] Calculate within-locality deployment deviations and between-locality deployment averages.
- [ ] Ensure every predictor uses information available before the relevant outcome period.
- [ ] Verify selected locality–time records manually against their source records.

### Analysis commitments

- [ ] Specify baseline, history-adjusted and varying-slope models.
- [ ] Define the primary deployment contrast and coefficient interpretation.
- [ ] Prespecify temporal validation windows, predictive scores and interval levels.
- [ ] Define how sparse localities, uncertain locations and stale deployments will be handled.
- [ ] Specify criteria for simplifying unsupported random slopes.
- [ ] Separate confirmatory analyses from exploratory extensions.
- [ ] Timestamp the protocol before examining substantive deployment estimates.

### Outputs and visualizations

- [x] Save the analysis panel with a reproducible construction script.
- [x] Produce a sample-flow table showing retention and exclusions.
- [ ] Plot outcome distributions, deployment variation and usable observations by locality.

### Evaluation and progress gate

- [x] Confirm unique locality–time keys and reconciled event totals.
- [x] Verify that joins have not duplicated events or deployments.
- [ ] Confirm adequate within-locality deployment variation.
- [ ] Freeze the panel and protocol; log subsequent changes explicitly.

## 4. Multilevel estimation and predictive evaluation — Week 3

### Model fitting

- [x] Fit the locality and calendar baseline model. Evidence: initial empirical results.
- [x] Add deployment and prespecified conflict-history variables. Evidence: initial empirical results.
- [x] Distinguish within-locality deployment associations from between-locality differences. Evidence: fitted history formula.
- [ ] Fit locality-specific deployment slopes only where the design supports them.
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

- [ ] Create small-multiple locality trajectories with observed deployment dates and predictive intervals.
- [ ] Plot partially pooled deployment coefficients with uncertainty and deployment-change information.
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

- [ ] Write a 3–4-page memo covering the question, data, model, simulation, findings and limitations.
- [ ] Explain what the simulation establishes and what the empirical analysis cannot establish.
- [ ] Connect the work specifically to Scott’s interests in histories, heterogeneity, uncertainty and usable methods.
- [ ] Distinguish methodological application from any genuinely new contribution.
- [ ] Identify one bounded follow-on research question suitable for supervision.

Verify the intended Scott's identity and relevant publications before attributing research interests in the memo; no outreach is authorized by this plan.

### Figures and presentation

- [ ] Finalize the coverage, simulation-recovery, trajectory, heterogeneity and sensitivity figures.
- [ ] Use ggplot2 with consistent typography, scales, uncertainty displays and accessible colors.
- [ ] Label counts, time units, sample sizes and exclusions clearly.
- [ ] Produce a five-slide discussion deck using actual results.
- [ ] Remove or prominently label any remaining simulated presentation examples.

### Real-world relevance

- [ ] Identify which findings could improve monitoring or evaluation practice.
- [ ] Identify specific information gaps that better records could address.
- [ ] Explain how reporting differences could distort assessments of civilian protection.
- [ ] State what prospective validation would be required before operational forecasting.
- [ ] Avoid translating uncertain locality associations into deployment recommendations or success rankings.

### Reproducibility and final acceptance

- [ ] Run the workflow from original inputs through final tables and figures.
- [ ] Confirm source versions, random seeds and package environments are recorded.
- [ ] Verify every numerical statement against the saved analysis outputs.
- [ ] Document failed models, exclusions, deviations and unresolved discrepancies.
- [ ] Have another reader interpret the central figures without coaching.
- [ ] Prepare a concise explanation of the skills demonstrated: data auditing, multilevel modeling, simulation and uncertainty analysis.
- [ ] Prepare two focused questions for Scott about the findings and a possible research extension.

Independent reader review is an external acceptance step; a self-check cannot mark it complete.
