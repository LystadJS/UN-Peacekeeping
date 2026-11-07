# Clean reproduction of the active quarterly pilot

The active workflow starts from the retained original files, not saved panels or fitted models. Run from the repository root with R 4.5.3 on the recorded Windows platform:

```powershell
./scripts/run_clean_workflow.ps1 -RunDirectory outputs/clean_rebuild_new
```

Choose a directory that does not exist. The orchestrator never deletes an old run. It creates a separate project, copies code and the original data, prepares an isolated R library, verifies the source hashes, and then rebuilds the audit, quarterly panel, all 2,200 simulation fits, empirical models, diagnostics, influence checks, sensitivities, rolling forecasts, figures, memo and deck. Independent simulation jobs and independent evaluation jobs run in parallel. Each R entry point uses a fresh `--vanilla` process. Logs and fitted objects stay under the ignored run directory.

The original-input stage rejects pre-existing derived-data directories. Readiness starts as an empty state and is reconstructed from the new simulation checks. A separate, explicit reproduction decision reaffirms the already authorized empirical protocol; it does not treat a successful simulation as authorization for a new model or measurement rule. Unknown deployment remains unknown, the five-month freshness rule stays unchanged, and no locality-specific slopes are introduced.

The package preparer checks the recorded versions and package-tree hashes before copying installed packages. It rejects drift. The launcher restricts package lookup to the isolated library and R's standard library and checks loaded namespace paths before and after each stage. To verify an existing environment without changing files:

```powershell
& 'C:/Program Files/R/R-4.5.3/bin/Rscript.exe' --vanilla scripts/prepare_isolated_environment.R outputs/clean_rebuild_new/project --verify-only
```

This route reproduces an exact installed Windows package environment offline. It is not a fresh source installation, a tested renv restore, or proof of cross-platform portability. The complete dependency archive is not locally available. See [environment details](reproducibility_environment.md). The memo and deck additionally require the recorded bundled Python/Node runtime and Windows fonts; their builder records versions and font hashes separately.

After completion, compare the new results with the retained reference outputs:

```powershell
& 'C:/Program Files/R/R-4.5.3/bin/Rscript.exe' --vanilla scripts/compare_clean_rebuild.R outputs/clean_rebuild_new/project
```

This comparison is deliberately downstream of generation. No reference panel, model, prediction or simulation record is supplied to the clean fitting workflow. Panel and lineage values must match exactly; model quantities use an absolute tolerance of 1e-8. Timings and named artifact metadata are excluded explicitly, not silently treated as scientific discrepancies.

Inspect the rebuilt PDF pages and slide previews, and run `scripts/audit_portfolio_claims.R` through the isolated launcher in the clean project. Rendering, structural checks and agent interpretation do not complete independent human review. Human review was subsequently skipped at the user's request; keep its completion flag false rather than treating agent checks as a human response. Never promote a partial run merely because some figures or summaries exist.

The `-Prepared` option exists for a project whose code, originals and verified library have already been staged. It still rejects derived outputs. It is a preparation convenience, not permission to resume from cached scientific results.

The workflow now also copies the static quarterly dictionary, checks six source-record cases, verifies the current analysis snapshot, materializes the existing 2,000 simulation panels, and builds the descriptive supplement. These additive stages were separately tested against the retained clean project; they do not change the recorded earlier full-run receipt or imply another complete refitting run.

## One-origin reconstruction supplement

Before a new full clean run, run `scripts/acquire_forecast_origin_inputs.R` in the source project to obtain or verify the six additional pinned originals. The orchestrator copies only these original CSV/PDF downloads and their evidence manifests after the original-input guard, then regenerates the one-origin event and deployment comparisons and runs `tests/run_forecast_origin_checks.R`. It does not copy derived supplement ledgers or use them for fitting. The two analysis stages and checks were also tested in the retained isolated project; this additive check is not another full model run. See [the single-origin reconstruction](forecast_origin_reconstruction.md).

## Training-history extension

The [training follow-up](forecast_training_followup.md) adds archived annual/cumulative event data, a pinned older Geo-PKO release and static release/symbol evidence. Before a full clean run, retain or acquire the originals listed in data/forecast_training_inputs.csv and data/forecast_origin_coding_sources.csv, and preserve the seven evidence artifacts in data/forecast_origin_release_followup.csv. The latter includes locally recorded archive-response metadata and query results; their exact bytes cannot be assumed reproducible from a later live request.

The orchestrator copies only original artifacts and static evidence/transcriptions, regenerates histories and comparisons, then runs independent history and availability checks. It does not copy reference training panels or use the supplement to fit models. Fifteen generated tables and four private histories were compared against a rerun in the retained isolated project; this is additive validation, not a repeat of the entire fitting workflow.

## Post-2019 and September evidence — 2026-11-07

The [new reconstruction](post2019_and_september_followup.md) adds four R audit/assembly stages and their original artifacts. Preserve originals listed in `data/september_2023_evidence.csv`, `data/post2019_deployment_sources.csv` and `data/post2019_map_coding_sources.csv`, plus static `data/post2019_map_coding_transcription.csv`. Archive-response metadata and query results are retained evidence, not artifacts whose exact historical bytes can be recreated by a later live request. The map numerical audit needs PDFs but not rendered preview images.

Regenerate September source-date summaries, extended deployment histories and map comparisons from those originals, following the quarterly runbook's dependencies. No derived history is an original input and none is used to refit models. An additive isolated rerun must be reported separately from the earlier 383-comparison full fitting run; do not update the full-run completion receipt merely because these extra audits pass. Human review remains skipped, not completed.

The completed additive isolated check matched 12 generated public tables and nine private histories exactly, verified 21 input hashes per project and the historical Git blob, and rechecked all 18 frozen analysis files. See [the receipt](../data/post2019_followup_checks.json). This is not a new full estimation run.

## Expanded completion audit — 2026-11-07

The orchestrator now stages the originals listed in `deployment_release_catalog_sources.csv`, `deployment_release_evidence.csv`, and `september_reporting_gap_sources.csv`, plus static `deployment_2021_2023_added_transcription.csv`, all under `data/`. Four new stages and the independent completion test run after the earlier post-2019 checks. Derived histories are regenerated rather than copied. The comparator requires the six new private histories and all nine generated public tables.

An additive run in the retained isolated project matched all those tables exactly and verified all 18 frozen analysis files. See [completion receipt](../data/deployment_history_completion_checks.json). The earlier full-fitting receipt is unchanged; human review remains skipped.

## Adjudication validation — 2026-11-07

The clean workflow stages static decision/source inputs and the eight distinct originals named across `deployment_coding_conventions_sources.csv`, `nyamilima_geography_sources.csv` and `deployment_symbol_adjudication_sources.csv`. It regenerates four public tables and three private audit files and runs the independent adjudication checks. The retained isolated project reproduced all seven tables exactly; the original 18-file analysis snapshot and untouched project-plan hash were verified. See [adjudication receipt](../data/deployment_adjudication_checks.json). No full model or corrected-panel run is claimed. PDF font-weight warnings did not prevent extraction or visual inspection of the UN locality evidence.

## Corrected-panel fitting reproduction — 2026-11-07

The orchestrator stages the originals named by `data/mavivi_subtotal_sources.csv`, then resolves the analysis subtotal and builds separately versioned panels after adjudication. New model fits and checks run only after the original empirical coefficients and influence results have been generated. Reference derived panels are not copied as corrected inputs.

The retained isolated environment repeated the three new stages and independent checks: all 13 fits were usable. Eleven generated public tables, 17 private CSV tables, six panel objects and 13 model objects matched under the protocol's tolerances. Only elapsed seconds and hash/size metadata in specifically named input manifests are excluded from cross-run table comparison; their paths remain checked and each run verifies its own source fingerprints. See [receipt](../data/corrected_panel_reproduction_checks.json). This is a bounded fitting rerun, not a repeat of the original full simulation and rolling forecast workflow. The original snapshot and project-plan hash were verified unchanged.
