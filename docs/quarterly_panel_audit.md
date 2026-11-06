# Quarterly outcome and history panel audit

Built 2026-11-06 (America/New_York), without fitting any empirical model. This completes construction and accounting checks; it does **not** override the dynamic-simulation or remaining measurement gates.

## Scope and retained sample

The panel follows quarterly protocol revision 1: 2016 Q1–2023 Q4, fixed 19 city–territory composites, one-sided recorded violence, exact-place coding, one unique polygon assignment, and event dates contained in a single calendar month. Moving to quarters does not silently restore previously excluded cross-month events. Civilian fatalities use `deaths_civilians` for those same retained events; other categories and total-fatality uncertainty bounds are not substituted.

| Panel | Rows | Recorded events | Recorded civilian fatalities |
|---|---:|---:|---:|
| All 19 localities, including unknown exposure | 608 | 2,166 | 7,440 |
| Existing nine-locality complete-exposure sample | 288 | 1,248 | 4,467 |

All-source event lineage covers the same 5,511 DRC 2014–2023 records as the initial audit. Outcome and prehistory eligibility rules are applied explicitly to every row. Event IDs remain unique, counts reconcile exactly, and no join expands rows. The nine-locality sample is inherited from exposure availability; no outcome threshold selects localities.

The 2015–2023 audit had 2,189 retained events. Its reduction to 2,166 reflects the authorized 2016 start, not an unrecorded new precision rule. A zero denotes no retained event in the source under these rules, not an absence of underlying violence or established reporting completeness. Unknown deployment stays missing in the all-locality panel.

## Prehistory and censoring

Recorded-event history is built on a complete 2014 Q1–2023 Q4 grid. The previous audit's `preperiod_history` disposition was assigned before all precision rules; this builder therefore reapplies the full source/precision/location/date predicate to 2014 records rather than automatically including them.

Fields include `events_lag`, `log1p_events_lag`, `violent_spell_lag_observed`, `violent_spell_left_censored`, and `violent_spell_lag`. A violent spell counts consecutive positive recorded-event quarters ending at t−1. If a positive run is already active at the start of the available history, its observed duration is only a lower bound. The full-duration field is NA until an observed zero establishes a new run. No unknown onset is recoded as a zero-duration spell.

Deployment history is reconstructed from monthly source-row provenance beginning in 2014. This provides **2015 Q3** for `strength_lag2` in the 2016 Q1 outcome row. As with current exposure, quarter means require all three numeric monthly strength estimates and source ages between zero and five months. The rebuilt lag-1 values exactly match the previously audited exposure file.

All 288 complete-exposure sample rows have a numeric prior-event count, uncensored lagged spell duration, and numeric lag-2 strength. Thus no additional core rows are removed by the history-completeness rule. Flags, lower bounds and unknown values are preserved for the full 19-locality coverage panel.

**Initial conditions are not universally zero.** Beni's 2015 Q4 recorded count is five; Irumu's is two. The other seven complete-exposure localities have zero in that quarter. The exported initial-condition table makes this explicit. A dynamic simulation starting every locality at zero does not, by itself, validate these empirical initial conditions or rule out dependence between prehistory and locality random intercepts.

Lagged event dates refer to retrospective GED records. The release used here includes later-reported/revised events; these histories do not establish what was known in real time at a forecast origin. Any subsequent temporal validation must be described as retrospective prediction unless release vintages or publication-availability rules are added.

## Source trace review and tests

Six deterministic source-event examples were inspected against original GED IDs/dates/locality labels and their resulting quarter. The saved sample includes IDs 207395, 342792, 414852, 440115, 466429 and 612058. For example, event 207395 falls on 2016-01-07 in Lubero and is the sole retained event in that locality's 2016 Q1 cell, with 16 civilian fatalities. The sample spans 2016–2023 and both complete- and incomplete-exposure localities.

Beni's five 2015 Q4 source events were also inspected: 210960, 210962, 211146, 211564 and 357379. One date interval spans two days in December but stays within the same month, consistent with inclusion. These are trace checks against the released dataset, not independent verification of underlying news reports or every source record.

`tests/run_quarterly_panel_checks.R` independently reconstructs quarterly counts and fatalities from the event ledger using base R, checks unique keys and lag alignment, and recomputes spell lower bounds/censoring from every prior count sequence. The RDS panel preserves quarter-of-year as a four-level factor; CSV users must preserve that categorical interpretation rather than fit season as a linear integer trend.

## Outputs and use

Run from the repository root:

```r
source("scripts/build_quarterly_panel.R")
source("tests/run_quarterly_panel_checks.R")
```

Local outputs are under `outputs/quarterly_pilot/panel/`: the all-locality and nine-locality panels (CSV and RDS), event lineage, annual retention flow, 2014–2023 history grid, 2015 Q4 initial conditions, locality summaries, source-trace sample, compact totals and session metadata. All remain ignored by Git.

For subsequent work, use `quarterly_panel_complete_exposure.rds` while retaining the full coverage panel for selection/measurement reporting. Descriptive exposure centering is inherited from the existing audit. Rolling prediction must recompute centering from training data and must not use full-period means. This panel is structurally ready for a matched history-model validation decision; it is not independently cleared for empirical fitting or causal interpretation.
