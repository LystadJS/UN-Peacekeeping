# Protection or Apparent Protection?

**Multilevel Models of Local Violence and Observation Uncertainty around MONUSCO**

This project asks how the association between peacekeeping presence and subsequent recorded violence varies across localities after accounting for prior conflict histories. Simulation will assess whether multilevel models recover heterogeneity when deployment responds to violence and recording probabilities vary.

## Status

Week 1 acquisition and measurement audit are complete, with a **revise-design** decision before modeling. Read [the findings](docs/week_1_audit.md) and [feasibility decision](docs/feasibility_decision.md). Sparse binary deployment changes and unverified absence coding require attention. Initial empirical baseline/history fits are now saved; no causal peacekeeping effect is claimed.

The authorized revision is the [2016–2023 quarterly pilot](docs/quarterly_protocol.md), using a common within-locality listed-strength slope. See the [absence investigation](docs/deployment_absence_review.md). The required ordinary-history gates have passed; bounded empirical fits follow the documented measurement decision.

The [core simulation validation](docs/quarterly_validation_results.md) passed favorable/null recovery checks across 800 total fits. Reporting and hidden-risk stress tests show large failures of structural-effect recovery. The subsequent 1,400-fit dynamic validation also passed its required ordinary-model gates. The requested follow-up empirical evaluation is now complete, with unresolved limitations documented rather than treated as passed diagnostics.

The active pilot covers eastern DRC, 2016–2023, at a consistent composite-locality–quarter level. The primary outcome is recorded UCDP one-sided violence event counts; civilian fatalities are a separate secondary outcome. These are qualifying lethal organized violence events, not all civilian harm. The earlier monthly design is retained as historical planning context.

The [quarterly panel audit](docs/quarterly_panel_audit.md) reconciles 608 rows and 2,166 retained events; the nine-locality complete-exposure sample contains 288 rows and 1,248 events. See the [independent computational review](docs/quarterly_independent_review.md) and [dynamic validation protocol](docs/dynamic_quarterly_protocol.md). Complete exposure depends on permitting source maps up to five months old: a three-month limit leaves no locality with uninterrupted coverage. Unknown deployment remains missing.

Start with the [combined evaluation findings](docs/quarterly_evaluation_findings.md). All 17 history-model deletion intervals and all 11 measurement/secondary/monthly specification intervals include zero. Residual temporal structure remains. Across 20 rolling forecast quarters, history has a small mean log-score gain (+0.0429), but removing Irumu's scores reverses that average advantage. Reporting sensitivity remains assumption-dependent; no causal protection effect or operational forecasting readiness is established.

The [research discussion portfolio](portfolio/README.md) now includes a four-page memo, five-slide editable deck, and final figures using the saved findings. Human figure review was skipped at the user's request; prospective validation remains unperformed.

The [clean rebuild](docs/clean_rebuild_results.md) reproduced the active workflow from retained originals in an isolated, hash-verified Windows/R package environment. All 383 scientific comparisons passed. Use the [clean-run instructions](docs/clean_rebuild_runbook.md); human review is skipped at the user's request, not completed.

## Start here

The [one-origin reconstruction](docs/forecast_origin_reconstruction.md) examines what could be known on **1 October 2023**. Three dated UN reports support the relevant deployment-map identities; archived event counts differ from the current panel. July version availability has historical-use evidence, while August/September availability and historical numeric coding remain incomplete. The full-quarter archive benchmark includes post-cutoff source material and is not an authenticated forecast input. Reproducible comparisons and explicit remaining gaps are provided; no model was refitted.

The [deployment-absence follow-up](docs/deployment_absence_followup.md) and [historical-availability investigation](docs/historical_data_availability.md) document what additional sources can resolve. UN reports provide positive deployment evidence for an unlisted locality; archived UCDP releases provide a route to a future as-of reconstruction. Neither certifies zero deployment or real-time availability for the current panel. The [code audit](docs/historical_availability_code_audit.md) separates occurrence-time checks from publication availability. These follow-ups leave the fitted sample and model estimates unchanged.

For the active revision, use the [quarterly runbook](docs/quarterly_runbook.md), [freshness audit](docs/quarterly_freshness_audit.md), and [predictor-design diagnostics](docs/quarterly_design_diagnostics.md). The older starter commands below remain useful for the original scaffold, not as evidence that its full model has been validated.

1. Read [the full four-week plan](docs/project_plan.md), [Week 1 audit](docs/week_1_audit.md), and [research protocol](docs/research_protocol.md). Resolve the revised-design gate before empirical fitting.
2. Open `un_peacekeeping.Rproj`, or run R from the repository root.
3. Run `source("scripts/check_environment.R")` to inspect dependencies.
4. Run `source("tests/run_checks.R")` for synthetic-data checks.
5. Run `source("scripts/run_simulation.R")` to generate all eight design cells locally under `outputs/simulation/`. This generates data and known truth, **not fitted model performance**.

For initial setup, `source("scripts/prepare_week_1.R")` creates ignored directories and records the environment. Acquisition and audit commands are in the findings. The original [feasibility gate](docs/feasibility_decision.md) led to the authorized quarterly revision; current readiness is recorded in `data/pilot_validation_status.json`.

Only dplyr is required for the initial simulation. The active pilot uses ggplot2, glmmTMB and sf, among the dependencies pinned in config/environment_packages.csv. An isolated offline copy of the exact installed Windows/R packages has been tested; fresh source installation, renv restoration and cross-platform portability have not.

## Repository structure

- `R/`: readable, commented simulation and model specifications.
- `config/`: explicit provisional analysis choices.
- `data/`: source manifest; raw and derived empirical files stay local and ignored.
- `docs/`: protocol, audit gates, and implementation milestones.
- `scripts/`: environment checks and reproducible entry points.
- `tests/`: deterministic checks of synthetic data and timing.
- `outputs/`: ignored generated files, with synthetic outputs clearly separated.

The intended portfolio comprises an audited panel, one justified multilevel analysis, a simulation recovery assessment, and a short memo with local trajectories, partially pooled associations, and recording-sensitivity curves. Weak recovery or inconclusive empirical estimates are valid results.

## Source anchors

- [UCDP methodology](https://www.uu.se/en/department/peace-and-conflict-research/research/ucdp/ucdp-methodology.html): event eligibility and reporting limitations.
- [Geo-PKO](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset): source maps normally span 3–6 months; monthly data carry the last available map forward. Troop strength is inferred from mapped units, adding measurement uncertainty.

Data versions, licenses, checksums, boundary choices, and precision rules must be recorded before empirical use. No redistribution rights are assumed. Software licensing remains an owner decision.
