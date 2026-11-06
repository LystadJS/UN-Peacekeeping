# Implementation roadmap

The [full four-week acceptance plan](project_plan.md) is the controlling task checklist. Begin with the [Week 1 runbook](week_1_runbook.md); its preparation templates do not count as completed audits. The concise implementation sequence below supplements that plan.

1. **Freeze scope and provenance.** Choose geography, releases and licensing; populate source manifest. Deliver a coverage and precision audit before panel construction.
2. **Build the panel.** Implement version-specific adapters, spatial reconciliation, complete calendar, history construction and map-age diagnostics. Validate totals and distinguish zeros from unknowns.
3. **Fit the common-slope model.** Install/test glmmTMB, freeze an renv environment, implement calendar alternatives and rolling validation. Deliver diagnostics and count predictions before varying slopes.
4. **Assess heterogeneity recovery.** Fit all three specifications to repeated synthetic datasets and oracle variants; retain failed fits, compute Monte Carlo uncertainty, and match simulation sparsity to the empirical panel. Gate empirical random slopes on recovery and variation.
5. **Run sensitivity analyses.** Monthly versus quarterly timing, event precision, deployment strength versus presence, recording offsets and conflict-history alternatives.
6. **Write the memo.** Three figures, estimand, assumptions, failures and limits; no causal or locality-ranking claims beyond evidence.

Completed in scaffold: protocol, data gates, source-manifest template, simulation generator, candidate model formulas, runnable simulation entry point and deterministic checks. Model fitting, recovery metrics, empirical adapters, figures, and final memo are intentionally still to be implemented.
