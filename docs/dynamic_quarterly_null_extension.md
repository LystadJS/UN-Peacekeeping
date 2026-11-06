# Correlated-prehistory null extension

Prespecified 2026-11-06 during the original run, after fixed-zero favorable/null fits and before this extension's generation or estimation. The original scenarios, thresholds and estimator are unchanged. Review identified that the fixed-zero null cannot establish false-direction behavior when the initial outcome depends on locality risk.

Generate 200 independent correlated-prehistory panels with the same 40-quarter prehistory, nine-locality exposure schedules, history terms, recording probability and remaining coefficients as `stationary_initial`, but set the current common strength coefficient to zero. This changes the between-strength algebra consistently, preserving its coefficient 0.15. Seeds are `20361107 + replication`, distinct from all original seeds. Fit only the ordinary history estimator. Save records separately under `outputs/dynamic_quarterly_null_disjoint/`; do not overwrite original outputs.

Apply unchanged null thresholds: usable fits >=95%, absolute bias <=0.05, 95% Wald coverage >=90%, coverage MCSE <=0.02 and false-direction rate <=10%. Report failures over all attempts, conditional metrics and MCSE. An empirical gate requires the original ordinary favorable/null and correlated-prehistory nonnull checks, plus this matched null check. The initial-adjusted estimator remains diagnostic; this extension cannot validate it.

Passing would remain a finite-sample check for these assumed DGPs, not a stationarity proof, correction for selective recording, or causal identification. No empirical model will be fitted by either validation script.

Seed amendment recorded 2026-11-06 before the replacement run: the initially specified 20271107 base accidentally overlapped the original favorable scenario because 20261107 + 10000 = 20271107. The initial extension records remain in ignored outputs/dynamic_quarterly_null/ as superseded diagnostics and do not enter the validation gate. This replacement uses disjoint base 20361107; the exporter explicitly checks that no seed overlaps the original run. No numerical results from the overlapping extension informed this amendment or changed the DGP, estimator, or tolerances.

