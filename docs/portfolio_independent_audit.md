# Independent scientific audit of the discussion portfolio

Historical audit of the 6 November portfolio. The corrected-panel refresh on 7 November changes the memo, deck and figures; this audit is not acceptance of those revised artifacts. Current checks are documented in [portfolio validation](portfolio_validation.md).

Reviewed 2026-11-06 by a separate agent. Scope: consequential claims in the editable memo and its four-page PDF, discussion outline and five-slide PPTX including speaker notes, and scientific figure data. This is not independent human interpretation, native PowerPoint application testing, or a claim that residual limitations have been resolved. No models were fitted or artifacts modified by this audit.

## Assessment

The numerical findings and principal uncertainty statements are supported by the retained analytical outputs. Two narrow wording repairs were identified: distinguish the bundled history model from the incremental contribution of conflict history alone, and describe observed exposure schedules as the simulation's base rather than unchanged in every scenario. Both repairs were propagated to regenerated artifacts and verified. The clean run passed its scientific and artifact checks; the portfolio can be shared with its stated methodological caveats.

## Reproducible numerical checks

`scripts/audit_portfolio_claims.R` runs independently of the summarization helpers and performs no estimation. It passed on the saved outputs. It checks:

- The nine-locality panel contains 288 quarters and 1,248 retained recorded events.
- Every one of the 360 held-out forecast means is reconstructed from its saved fold model and independently computed training-only locality strength means. All 40 saved folds have the expected training sample size. Recorded log scores and 95% NB2 bounds match direct distribution calculations.
- Forecast means, absolute errors, coverage, interval widths, paired quarter/locality comparisons and the geographic concentration claim reproduce. Overall gain is 0.04289534; omitting Irumu's scores gives -0.01473459. Four of nine locality averages and fourteen of twenty quarter averages improve. This is score reaggregation, not refitting.
- All ordinary-scenario simulation figure points, Monte Carlo intervals and coefficient-interval coverages agree with the retained fit records. The dynamic record total is 1,400 fits; 200 correlated-prehistory panels each receive two estimators, giving 1,200 generated panels rather than 1,400 independent datasets.
- The reporting figure is exactly the saved primary coefficient minus the assumed log recording ratio; its conditional bounds retain the primary standard error. The threshold directions in the memo are correct.
- All eleven measurement/secondary/monthly coefficient summaries match saved model objects. Their intervals include zero. The empirical figure's coefficients, bounds and sample sizes match those summaries.
- All seventeen history-model deletion coefficients and standard errors agree with saved model objects; all intervals include zero. The full deletion table contains 34 usable fits. Separate checks confirm that the 44 sensitivity fits comprise 11 specifications, 3 linear-offset checks, 21 nonlinear-reporting fits and 9 joint-reporting fits, all marked numerically usable.
- Reported dependence medians and reference bounds reproduce from saved observed-randomization and conditional-reference draws. This confirms the 0.140 lag-two median and 0.114 upper reference bound; it does not calibrate these descriptive comparisons as hypothesis tests.

The script should also be run against the coordinator's clean-rerun products before declaring the rerun concordant. Passing against the original saved outputs alone does not establish a clean end-to-end rerun.

## Artifact consistency

Read the actual PDF text and all slide/notes XML, rather than relying only on their builders. The PDF has four pages and carries the reviewed Markdown's substantive claims. The slide tables report the correct primary, early-switch and midpoint estimates and bounds. Parsed all three chart caches and their three embedded workbook datasets; all numbers match the controlling analytical CSVs, including all 81 recording ratios and each of the three curve series. The scatter workbook uses interleaved X/Y columns, which were verified accordingly.

This audit's PDF/PPTX inspection was textual and numerical. Visual layout review is a separate task; no claim of native PowerPoint execution or unaided human interpretation follows from XML or PDF text extraction. Python was used only for PDF/OOXML inspection because those artifact formats have appropriate bundled parsing libraries; analytical verification remains in R.

## Concrete wording findings

1. **Incremental contribution is not isolated.** The opening memo sentence says that recorded conflict history improves prediction. The baseline omits both deployment and history, while the history model adds both. The result supports a gain for the **history model**, not an isolated contribution from the conflict-history variables. Replace that sentence with model-level wording and use "history model" for corresponding shorthand in the README, outline and deck. No additional fit is needed for this repair; an isolated history contribution would require an additional comparator.
2. **Selection modifies the exposure schedule.** Slide 2 notes say the dynamic simulation preserves the observed exposure schedule. The selection generator adds a function of previous counts and latent risk to observed strength. Use "uses the observed exposure schedule as a base" and, where helpful, state that the selection scenario perturbs it. Favorable and reporting scenarios do retain the original schedule. The simulated known-truth interpretation itself is supported.

No other material numerical discrepancy was found in the reviewed portfolio. Small wording changes must be propagated to the PDF/PPTX exports; editing Markdown or JavaScript alone does not update delivered binaries.

## Scientific limits that must remain

The common within-locality coefficient remains imprecise; the analysis does not recover or rank locality-specific protection effects. The five-month map-age rule and retrospective nine-locality selection remain consequential. The fixed-history count simulations are conditional reference checks, not dynamically evolving predictive trajectories. Nominal forecast intervals omit parameter and random-effect estimation uncertainty. The recording sensitivity curve assumes a mechanism rather than estimating it or removing deployment confounding. Reporting and responsive-selection scenarios show substantial recovery failures despite numerical convergence. The monthly and fatality analogues change the estimand and lack matching simulation validation. These limits are present in the reviewed memo and notes.

The sequence-history connection was checked against the [Bicocca repository abstract](https://boa.unimib.it/handle/10281/624421), and the uncertainty/heterogeneity connection against [NYU's project description](https://steinhardt.nyu.edu/priism/what-when-and-whom). The practical-software connection agrees with the [thinkCausal article](https://doi.org/10.1080/00031305.2026.2627264). These support the bounded methodological connection; they do not establish Scott's specialization in peacekeeping or selective conflict recording. No outreach or supervisory agreement is implied.

Independent human reading and native PowerPoint application behavior remain outstanding acceptance items.

## Clean-rebuild follow-up

The coordinator applied both wording repairs to the editable memo, outline/README and deck builder. The artifact agents subsequently verified the wording in all four regenerated memo pages and all five slides; the parent rechecked the affected memo pages after the final Cairo-renderer change. The isolated scientific rebuild at `outputs/clean_rebuild_20261106/project` was then compared with the retained reference outputs using `scripts/compare_clean_rebuild.R`: all 383 checks passed, with no missing expected scientific outputs. Panel/source-lineage cells, coverage, gates and integer-valued quantities matched exactly; numerical model outputs matched within maximum absolute tolerance 1e-8. Only named runtime fields and artifact fingerprint metadata were excluded. Model environments were not byte-compared; scientifically interpreted model summaries and numerical status flags were checked instead. Detailed results are in `clean_rebuild_comparison.csv` and the accompanying Markdown report.

Ran `audit_portfolio_claims.R` again inside the rebuilt project through its isolated `--vanilla` launcher, using the exact copied audit script (matching SHA-256). It passed against the newly generated models, forecasts, simulation records, diagnostic draws and figure data. This establishes concordance of the scientific rerun without feeding reference results into fitting. Human interpretation and native PowerPoint behavior remain unverified.
