# Withdrawal descriptive work status

Started 12 November 2026. Morning report scheduled for 13 November at 10:00 America/New_York.

The authorized work is a descriptive evidence package, not a new effect model.

| Task | Status |
|---|---|
| Fixed 24-month baseline and six-month follow-up timelines | Complete: 27 deduplicated territorial/date displays in 10 provisional clusters |
| Severe-episode and source audit | Complete for saved data; consequential Luhanga discrepancy independently checked and flagged |
| Baseline-only comparison assessments | Complete: all 19 candidates profiled; none approved as a causal control |
| Inclusion, timing and missing-death scenarios | Complete: two inclusion rules, timing endpoints, largest-event removal and uniform geographic-conflict exclusion |
| Validation and evidence packet | Complete: 126 independent checks; figures inspected and text-rendering issue repaired |
| GitHub delivery | Complete: research package pushed on codex/withdrawal-descriptive-evidence; [PR 1](https://github.com/LystadJS/UN-Peacekeeping/pull/1) records delivery and merge status |

Scope: use the saved corrected outcomes, register and documentary evidence. Preserve uncertainty about protection catchments and reporting completeness. Deduplicate identical territorial series; component handovers are not independent assignments. No emails are sent by this work package.

Initial issue: the data-request specification listed Bukavu separately while omitting Walungu. The actual panel combines Bukavu with Kabare and contains eight South Kivu units including Walungu. Correct the saved specification; previously drafted email requests did not list these units and do not require correction.

## Findings for the morning report

- South Kivu: 71 strict-definition deaths over 24 baseline months versus eight over six follow-up months (2.96 versus 1.33 per month). Territorial inclusion gives 73 versus 11. These are recorded counts, not withdrawal effects.
- Ten hypothetical additional post-period deaths would erase the strict decline relative to the baseline monthly mean; eight would erase the territorial-definition decline. These are arithmetic sensitivity thresholds, not estimated missing deaths.
- Walikale: a 34-death Luhanga event dominates the baseline. The polygon assigns it to Walikale, while GED ADM2, AFP/VOA and Radio Okapi identify Lubero. Removing it changes the descriptive direction. Fatality reports also disagree.
- Lubero: the 2017 direction changes when the documented transition month is July versus October. The broad timing uncertainty is substantively consequential.
- Bunyakiri/Kalehe: six strict follow-up deaths include four at Numbi; the territorial count does not establish exposure to Bunyakiri protection. Kavumu/Kabare follow-up records refer to Katana and Bukavu. Sange/Uvira has zero retained follow-up events, not verified absence of violence.
- Baseline comparison evidence is weak: April 2022-March 2024 strict deaths total 832 in Beni and 955 in Djugu versus seven each in Kalehe and Kabare, with different actor composition and conflict context. No matching or effect regression was fitted.

## Issues requiring review or external records

1. Luhanga event 234588: adjudicate coordinate/boundary versus administrative location and competing fatality reports. Primary coding was preserved; all 19 unique geographic conflicts in displayed windows received the same exclusion sensitivity.
2. Actual patrol catchments and continuity, and historical incident-monitoring coverage, remain unresolved. Local request specifications exist. No email was sent by this work package, and receipt of any response was not assumed.
3. Same-decision component handovers and shared territorial series are not independent experiments. Comparative causal analysis remains closed pending stronger design evidence.

## Validation and deliverables

[Evidence packet](withdrawal_descriptive_evidence_packet.md), [timeline PDF](../outputs/withdrawal_descriptive/all_case_timelines.pdf), and [validation results](../outputs/withdrawal_descriptive/validation_checks.csv).

All 608 original locality-quarter outcomes and 12 earlier daily handover windows reproduce. Case-month counts reconcile against event lineage; the 24/6-month windows, geographic inclusion nesting and minimal integer missing-death thresholds pass checks. The upstream input hashes match. Main plots, baseline comparison figure and sensitivity figure were visually checked. Local R reports startup locale warnings, but no remaining parsing or analytical warnings occurred in final validation. No original outcomes, manuscript or PowerPoint were changed.

GitHub package: initial analysis commit bc515db, with a separate status-record update. The repository has no configured workflow in the local checkout and the initial commit had no posted status checks; validation here refers to executed local R checks, not CI. Unrelated historical work remains outside this commit. Source-derived CSV whitespace is preserved; whitespace checks pass for code, documentation and curated source registers.

Full regeneration requires the existing raw GED/boundary files and baseline audit artifacts. Rebuild upstream audit manifests after a new checkout if line-ending normalization changes byte hashes. Committed derived outputs support inspection without redistributing the complete raw GED download.
