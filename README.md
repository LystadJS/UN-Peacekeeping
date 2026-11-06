# Protection or Apparent Protection?

**Multilevel Models of Local Violence and Observation Uncertainty around MONUSCO**

This project asks how the association between peacekeeping presence and subsequent recorded violence varies across localities after accounting for prior conflict histories. Simulation will assess whether multilevel models recover heterogeneity when deployment responds to violence and recording probabilities vary.

## Status

Research scaffold: no empirical data have been acquired, audited, or analyzed. The simulation generator and checks run independently of empirical inputs. No findings or causal peacekeeping effects are claimed.

The provisional study is eastern DRC, 2015–2023, at a consistent administrative area–month level. The primary outcome is recorded UCDP one-sided violence event counts; civilian fatalities are a separate secondary outcome. These are qualifying lethal organized violence events, not all civilian harm.

## Start here

1. Read [the full four-week plan](docs/project_plan.md), [Week 1 runbook](docs/week_1_runbook.md), and [research protocol](docs/research_protocol.md). The immediate scope is Week 1 preparation, not empirical execution.
2. Open `un_peacekeeping.Rproj`, or run R from the repository root.
3. Run `source("scripts/check_environment.R")` to inspect dependencies.
4. Run `source("tests/run_checks.R")` for synthetic-data checks.
5. Run `source("scripts/run_simulation.R")` to generate all eight design cells locally under `outputs/simulation/`. This generates data and known truth, **not fitted model performance**.

For Week 1 setup, run `source("scripts/prepare_week_1.R")`. It creates ignored working directories, checks the audit-template structure and records the current package environment. It does not download data or fit models. The [feasibility gate](docs/feasibility_decision.md) remains pending.

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
