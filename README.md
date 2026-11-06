# Protection or Apparent Protection?

**Multilevel Models of Local Violence and Observation Uncertainty around MONUSCO**

This project asks how the association between peacekeeping presence and subsequent recorded violence varies across localities after accounting for prior conflict histories. Simulation will assess whether multilevel models recover heterogeneity when deployment responds to violence and recording probabilities vary.

## Status

Week 1 acquisition and measurement audit are complete, with a **revise-design** decision before modeling. Read [the findings](docs/week_1_audit.md) and [feasibility decision](docs/feasibility_decision.md). Sparse binary deployment changes and unverified absence coding require attention. No empirical model or causal peacekeeping effect is claimed.

The authorized revision is the [2016–2023 quarterly pilot](docs/quarterly_protocol.md), using a common within-locality listed-strength slope. See the [absence investigation](docs/deployment_absence_review.md). Empirical fitting remains disabled while the revised gates are assessed.

The [core simulation validation](docs/quarterly_validation_results.md) passed favorable/null recovery checks across 800 total fits. Reporting and hidden-risk stress tests show large failures of structural-effect recovery. Dynamic history adjustment and the full empirical workflow remain behind separate gates.

The provisional study is eastern DRC, 2015–2023, at a consistent administrative area–month level. The primary outcome is recorded UCDP one-sided violence event counts; civilian fatalities are a separate secondary outcome. These are qualifying lethal organized violence events, not all civilian harm.

## Start here

1. Read [the full four-week plan](docs/project_plan.md), [Week 1 audit](docs/week_1_audit.md), and [research protocol](docs/research_protocol.md). Resolve the revised-design gate before empirical fitting.
2. Open `un_peacekeeping.Rproj`, or run R from the repository root.
3. Run `source("scripts/check_environment.R")` to inspect dependencies.
4. Run `source("tests/run_checks.R")` for synthetic-data checks.
5. Run `source("scripts/run_simulation.R")` to generate all eight design cells locally under `outputs/simulation/`. This generates data and known truth, **not fitted model performance**.

For initial setup, `source("scripts/prepare_week_1.R")` creates ignored directories and records the environment. Acquisition and audit commands are in the findings. The [feasibility gate](docs/feasibility_decision.md) requires design revision; `empirical_ready` remains false.

Only dplyr is required for the initial simulation. Planned packages are ggplot2 (figures), glmmTMB (negative-binomial mixed models), sf (spatial joins), and renv (a versioned environment once fitting dependencies are installed and tested). No lockfile is supplied or reproducibility of an untested package environment implied.

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
