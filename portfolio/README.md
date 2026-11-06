# Research discussion portfolio

Prepared on 6 November 2026 for discussion with Marc A. Scott. The portfolio presents the completed quarterly pilot and its limitations; it is not a causal evaluation of MONUSCO or a validated operational forecasting system.

## Read and present

- [Research memo](research_memo.pdf): a four-page account of the question, audit, model, simulation, empirical findings and a bounded follow-on. [Editable text source](research_memo.md).
- [Five-slide discussion deck](scott_discussion.pptx): editable evidence and speaker notes for a short discussion. [Discussion outline](discussion_outline.md).
- [Final figures](figures/): publication-ready PNG and PDF exports with aggregate chart data.

The central finding is an inconclusive common deployment-strength association. The history model improves retrospective prediction modestly on average, with gains concentrated in a few localities. Timing and recording assumptions remain consequential. No locality-specific deployment slopes or protection rankings are presented.

## Figure guide

1. Recorded violence, held-out predictions and source-map timing for three explicitly selected localities; an all-nine-locality supplement is supplied.
2. Recovery of the known coefficient in the dynamic simulation, separating Monte Carlo uncertainty from coefficient-interval coverage.
3. Sensitivity to assumed recording probabilities, clearly labeled as an algebraic change under assumptions.
4. The common empirical coefficient under alternative measurement specifications.
5. Retrospective predictive performance across localities, without a protection-success ranking.

The original proposal's locality-specific association figure was replaced after the design revision. The final figures show the common model and its limitations rather than inventing unsupported heterogeneity estimates. See [figure notes](../docs/portfolio_figure_notes.md) for the selection rules and uncertainty definitions.

## Evidence and reproduction

The [combined evaluation findings](../docs/quarterly_evaluation_findings.md) link the detailed analyses and aggregate tables. The [Scott source brief](../docs/scott_research_connection.md) bounds the connection to his documented work. Analysis inputs and fitted objects remain in their original local directories; this portfolio publishes summaries and presentation artifacts.

Rebuild figures with `scripts/build_portfolio_figures.R`. The memo and deck have separate artifact builders under `scripts/`; they use the bundled document/presentation runtime recorded in their instructions. R remains the language for scientific calculations; Python handles PDF typesetting and JavaScript handles editable slide authoring.

No outreach is included. Independent human interpretation of the central figures remains a separate acceptance step. Automated checks and agent review do not satisfy that requirement.

See the [validation record](../docs/portfolio_validation.md) and [artifact manifest](artifact_manifest.json). Run the bundled Python interpreter on scripts/check_portfolio_artifacts.py to recheck page/object counts and hashes. The deck builder depends on the recorded Codex presentation runtime; native PowerPoint behavior has not been tested.

The [clean reproduction and final audit](../docs/clean_rebuild_results.md) rebuilt the scientific workflow and presentation artifacts. It corrected model-attribution wording, the responsive-selection description, and implicit PNG-renderer selection. Scientific findings are unchanged; human review remains outstanding.
