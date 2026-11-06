# Clean rebuild and portfolio audit — 6 November 2026

**Share with caveats: the active pilot was reproduced from retained original files in an isolated Windows/R environment.** All 383 scientific comparison checks passed. The original findings and their limitations are unchanged. Independent human review remains outstanding.

## What ran

The clean project at `outputs/clean_rebuild_20261106/project` began with code, configuration, narrative sources, the original data and their provenance manifest. It contained no intermediate panels, fitted models, simulated records, predictions, derived figures or successful validation status. Twenty source-manifest originals were hash-verified. Ten raw-to-panel stages and 23 subsequent scientific stages completed successfully, using fresh R processes and an isolated library.

The run repeated 800 core simulation fits, 1,400 dynamic simulation fits, two primary empirical models, 34 deletion fits, 44 sensitivity fits and 40 rolling prediction fits. The simulation gates were recalculated before the existing empirical protocol was explicitly reaffirmed. All requested scientific fits were numerically usable. This does not resolve the already documented residual dependence, measurement uncertainty or confounding.

The [independent comparison](clean_rebuild_comparison.md) required exact agreement for panels, source identities, coverage, gates and convergence flags. Other scientific values used an absolute tolerance of 1e-8. It compared all required aggregate tables, private fit records and saved model content. Only explicit timing and artifact-hash metadata were excluded. A separate portfolio audit independently reconstructed forecasts, simulation metrics, sensitivity coefficients and residual summaries from the rebuilt objects. References entered only this post-generation comparison, never the fitting workflow.

The final figures, four-page memo and five-slide editable deck were rebuilt from regenerated results. All eight PNG designs and eight independently rendered PDFs passed visual review. All memo pages and slides were reviewed, with the two memo pages containing figures rechecked after the final renderer change. Structural checks confirmed four pages, five slides and notes, three native charts and workbooks, two native tables, and sixteen matching figure hashes. These are agent and automated checks, not human-reader acceptance or native PowerPoint application testing.

## Discrepancies repaired

1. **Prediction attribution:** the baseline-to-history comparison adds deployment variables and conflict history together. The memo and deck now attribute the gain to the history-adjusted model, not to conflict history alone.
2. **Simulation description:** the observed exposure schedule is a base; the responsive-selection scenario modifies it. The memo and slide notes now state that distinction.
3. **Implicit graphics dependency:** inferred PNG rendering changed when optional `ragg` was absent from the isolated environment. The final-figure builder now explicitly uses `grDevices::png(type = "cairo-png")`. Figure data are unchanged; the regenerated exports and their hashes were promoted after review.
4. **Parallel failure handling:** the supervisor now waits for and records every job in a failed batch before raising an error. A focused test using one failed process and one delayed writer confirmed that both finished and both exit codes were retained. This repair does not change the successful scientific run.

The first clean deck export encountered Windows access denial while its packaged validator replaced a temporary chart workbook. Repeating the unchanged build with normal filesystem permissions succeeded, with every validator still enabled. This was a resolved local build-permission issue, not a scientific discrepancy. The final figures and memo were regenerated once more after making the graphics device explicit; no model was refitted for presentation changes.

## Reproduction scope and outstanding acceptance

The R environment records 85 copied packages and 19 R-bundled dependencies. Their versions and complete package-tree SHA256 hashes were verified, including a read-only recheck against the recorded lock. Future preparation rejects drift. This is an exact offline copy of installed Windows packages, **not** a fresh source installation, a tested renv restore, or cross-platform validation. The local archive cache is incomplete. Python, Node, artifact-tool and font versions/hashes are separately recorded in `config/artifact_runtime.json`.

The [runbook](clean_rebuild_runbook.md) provides the complete command and comparison procedure. Private logs, original files, row-level outputs and models remain ignored. Original aggregate tables are retained because the scientific results match; nondeterministic elapsed times are not substituted for substantive findings. The public portfolio contains the newly rebuilt and reviewed presentation artifacts.

Independent human interpretation, native PowerPoint application testing, prospective forecasting validation and causal identification remain outstanding. No protection ranking or deployment recommendation follows from this reproduction.
