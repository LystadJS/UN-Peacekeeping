# Independent review of the quarterly pilot

Review date: 2026-11-06 (America/New_York). This is a separate-agent code and methodology review, not external peer review or the portfolio's unaided human-reader check. Existing files were reviewed without changing them or fitting empirical outcomes.

## Conclusion

The reported static common-slope recovery results are supported by the saved fit records. The scope is appropriately narrow: a nine-locality, fixed-exposure-design simulation with synthetic outcomes, not validation of the full history-adjusted empirical model or of causal identification. No new material numerical error was found in the completed core results. Empirical fitting should remain behind the dynamic-history and panel gates currently being developed.

## Checks performed

- Independently recomputed bias and coverage from all 800 records in `outputs/quarterly_pilot/simulation_fits.csv`, without using the published summary. Results match: favorable bias -0.000196 and coverage 0.960; null bias -0.009656 and coverage 0.940; differential-recording bias 0.275891 and coverage 0.200; latent-confounding bias 0.346764 and coverage 0.085. Each scenario has 200 usable fits.
- Confirmed 608 candidate locality-quarter rows, 246 missing lagged strengths and 288 rows in the complete-history design. There are no negative lagged strengths in the current saved design.
- Checked the deployment-lineage `source_row` references against the original Geo-PKO monthly file: recorded source names and `no.troops` values agree. The FPU subtraction therefore uses the intended original row references in the reviewed files.
- Inspected quarterly averaging, lag creation, centering, the synthetic generator, fitting formula, failed-fit handling, corrected summary computation, protocol gates and measurement interpretations.
- Confirmed the selected design has one Ituri locality, four North Kivu localities and four South Kivu localities. Shabunda has zero within-locality strength variation; eight localities contribute direct within-strength contrast.

## Required next gates and changes

### Dynamic history and initial conditions

The current favorable generator has no lagged outcomes, violent-spell effect or deployment response to past violence. Its success cannot clear those extensions. A dynamic generator needs an explicit initialization/burn-in strategy and a clear conditioning argument for initial outcomes and random intercepts. Treating an arbitrary initial zero as a stationary conflict history would not supply that argument.

For panel construction, the first 2016 Q1 outcome needs 2015 Q4 event history and exposure; a two-quarter deployment lag additionally needs 2015 Q3. A violent spell already underway at the beginning of available source history is left-censored and must not be presented as an exact duration. In the existing event audit, `preperiod_history` is assigned before precision/geographic exclusions; using that reason alone to include 2014 history would be incorrect. Apply the actual strict event rules again to pre-period records.

### Forecasting must keep its target population explicit

`build_quarterly_exposure.R` uses full-window means and selects localities whose lagged exposure is complete through 2023. This is deliberate and disclosed for a retrospective conditional-on-design study. It must not be reused unchanged as evidence of prospective availability.

Rolling validation should recompute centering and other preprocessing in each training window. Either retain the nine-locality population explicitly as a retrospectively selected forecasting target, or define eligibility using training-time information and document how later missing exposures are handled. These are different forecasting targets. Future availability cannot be silently used to claim general prospective performance.

### Distinguish listed-strength measurement from true-strength recovery

The core simulation treats the observed exposure schedule as the true covariate. Event-recording and latent-risk stress tests do not test deployment measurement error, delayed source maps, or changes in which bases appear on a map. A future timing sensitivity should move plausible deployment changes within source-map intervals and distinguish assumed true strength from recorded strength. A quarterly mean reduces temporal resolution but does not make a three-month-old source map contemporaneous.

The two-map absence review is appropriately labeled a spot check. It cannot certify absence across all unlisted quarters, nor prove completeness of troop totals within listed localities. Keep the contrast named **listed military strength**, preserve unknown status and avoid interpreting a missing base symbol as no operational presence.

### Harden exposure validity without changing current results

The current `acceptable` predicate tests nonmissing strength and map age <=5. Before accepting additional releases or changed inputs, also require finite nonnegative military strength, finite map age >=0, exactly three months per quarter and the expected unique monthly keys. The present audited files have no negative saved lagged strengths and previously passed negative-map-age checks; this is a fail-closed maintenance improvement, not evidence that current results are invalid.

### Align the checklist with the authorized revision

`docs/project_plan.md` still describes the original monthly and eight-cell heterogeneity design and leaves several now-completed core simulation items unchecked. Preserve it as historical intent, but add or substitute a current quarterly/common-slope milestone section with evidence links. Do not mark slope-variance recovery, dynamic selection or varying-slope validation complete merely because the static common slope passed.

The initial geography checkbox should now reflect the explicitly authorized 2016–2023 composite pilot. The dictionary and absence items should distinguish completed definitions/unknown-status handling from unresolved absence certification. This avoids presenting a failed or deliberately deferred gate as simply forgotten work.

## Interpretation limits that should remain visible

The 288 observations are repeated quarters in nine localities, not 288 independent clusters. One Ituri locality cannot establish province-wide generalizability, and Shabunda does not identify the within-strength coefficient. The successful fixed-design simulation is useful evidence about this precise model and scale; it is not broad small-cluster robustness evidence. The large adverse-scenario failures are scientifically useful and should remain in the portfolio, even if subsequent empirical estimates are stable.

No external human-reader acceptance item is completed by this review. No empirical deployment coefficient was inspected or estimated.

## Coordination update

After this review, the panel agent reported implementing the strict 2014 event filters, the additional deployment-history quarter and censored-spell safeguards. The simulation agent reported running both explicit zero-start and correlated-prehistory scenarios. These reports describe work in progress; final execution checks and the resulting validation reports should determine which gates can be closed. They do not change the independently checked static results above.

## Follow-up review: dynamic implementation and panel checks

Reviewed `R/dynamic_quarterly_simulation.R`, `scripts/validate_dynamic_quarterly.R`, `docs/dynamic_quarterly_protocol.md`, `scripts/build_quarterly_panel.R` and both new test scripts while the full dynamic run was in progress. Independently executed the panel and dynamic test scripts; both passed (R emitted locale startup warnings). A separate numerical check confirmed the within/between algebra and compared all 288 core lag-2 strengths with the history-grid quarter exactly two quarters earlier; all agreed.

The favorable/null generator's `beta * strength + (0.15 - beta) * locality_mean` equals the fitted within/between parameterization. Constant binomial thinning preserves its conditional mean form because this particular generator uses previous recorded counts. That agreement does not extend to the differential-reporting stress, which intentionally uses previous latent counts. The selection scenario also changes strength and its observed mean; comparison with the structural slope is deliberately a stress assessment rather than a claim of conditional regression identification.

The 40-quarter prehistory produces correlation with the same locality intercept used during follow-up. It is explicitly not proof of stationarity. Adding initial counts and spells is an approximate adjustment, not an exact demonstrated conditional distribution for the random intercept. Recovery results must therefore determine whether this estimator is usable for the specified simulation, with remaining extrapolation limits stated.

**Material gate gap:** the current run fits `initial_adjusted` only for the nonnull correlated-prehistory scenario. Favorable and null checks test `ordinary_history`. If the ordinary estimator fails correlated prehistory but the adjusted variant passes, this does not demonstrate the adjusted estimator's null false-direction performance. Moreover, even the ordinary estimator has no null run with correlated prehistory: its fixed-zero null check does not directly establish false-direction control with endogenous initial states. Prespecify an additional correlated-prehistory null run of the exact proposed estimator before enabling empirical fitting. Existing nonnull recovery evidence remains useful and bounded; this adds validation coverage without changing the existing thresholds. This finding was discussed with the simulation agent and coordinator before completion of the run. The selected estimator should be explicit in the gate record; do not combine a favorable result from one estimator with a null result from another.

Current per-scenario gate arithmetic agrees with the written thresholds, and failed fits remain in the fit-rate and success-and-coverage denominators. A final gate should require an explicit true result and all required scenario/estimator rows, rather than allowing absent or `NA` results to imply success. The runner writes summaries only after the complete run; intermediate `fit_records.csv` checkpoints are not validation completion.

The panel now reapplies the strict primary filter to prehistory and preserves censored spell durations as missing, with observed lower bounds. The saved initial-condition table does not yet include initial spell; that field is available as the 2016 Q1 lagged spell. Export it and its censor flag explicitly if preparing the adjusted estimator's panel input. No empirical fit was run for this review.

## Matched-null extension and workflow review

The added `effect_override = 0` changes the current-strength slope consistently in both prehistory and follow-up while preserving the specified between coefficient. The extension fits the same ordinary history estimator and leaves the adjusted estimator diagnostic. The panel agent subsequently added initial spell and censoring to the initial-condition export and hardened the exposure rebuild's finite-value and three-month requirements.

Review caught a seed collision before extension completion: the initially proposed `20271107 + replication` equals the original favorable scenario's `20261107 + 10000 + replication`. This contradicted the distinct-seed claim. The simulation agent was asked to document and restart with disjoint seeds, updating the independent verifier and metadata as well. Shared seeds would not by themselves invalidate each marginal recovery calculation, but would invalidate the stated independence between experiments.

Review also caught a runbook dependency error: the combined summary verifier now reads the matched-null outputs, so it must run after both simulation scripts. The coordinator was notified. Quarterly dictionary definitions otherwise align with the panel and preserve the distinction between zero recorded events and unknown underlying violence.

The validation-status updater keeps empirical fitting disabled even when simulation gates pass. Before recording a passed history gate, it should also explicitly require the matched-null estimator to be `ordinary_history`, complete unique scenario rows, and finite internally consistent summary metrics. Missing files or unfinished checkpoints cannot constitute a passed gate. Final numerical review of completed dynamic records remains pending at this point in the review.

The coordinator corrected the runbook ordering and added the status checks above. The simulation agent prospectively amended and reran the extension in `outputs/dynamic_quarterly_null_disjoint/` with base `20361107`, preserving the superseded records separately. Independent recomputation of the completed replacement's 200 records confirmed: all usable, bias 0.04207940, RMSE 0.32478923, coverage 0.955, coverage MCSE 0.01465862, and false-direction rate 0.045. All match the published local summary and meet the prespecified null thresholds. Truth zero, ordinary estimator, expected seed sequence and absence of seed overlap were independently checked. The finite-replication bias estimate is near its 0.05 gate; passing should not be described as proof of negligible bias in other settings.

Also reviewed the prepared empirical entrypoint and protocol without executing it. The history formula, NB2 family and default estimator match the ordinary dynamic experiment exactly. Its dual explicit-true guard, fixed-design rank check, gate snapshot, panel fingerprint and computational diagnostic labeling are appropriate for a bounded descriptive fit. The protocol explicitly discloses lagged-strength collinearity and defers temporal/spatial dependence, influence, forecast validation and reporting/timing sensitivities; successful execution cannot be represented as completion of those tasks.

## Final dynamic numerical verification

After the original run completed, independently recomputed all six scenario/estimator summaries from all 1,200 fit records. Verified unique scenario/estimator/replicate keys and agreement for attempted/usable fits, fit rates, bias, bias MCSE, RMSE, coverage, coverage MCSE, all-attempt success-and-coverage, and directional error. All fits were usable and all reported metrics matched within numerical tolerance.

| Required ordinary-history scenario | Bias | Coverage | Confidently wrong direction |
| --- | ---: | ---: | ---: |
| Fixed-zero favorable | -0.0339721 | 0.955 | 0.000 |
| Fixed-zero null | -0.0280702 | 0.940 | 0.060 |
| Correlated-prehistory nonnull | -0.0038106 | 0.935 | 0.005 |
| Disjoint correlated-prehistory null | 0.0420794 | 0.955 | 0.045 |

The ordinary history model passes all required numerical tolerances under these assumed generators. This closes the specifically tested simulation gate, not the independent measurement decision or broader empirical diagnostic tasks. The reporting and selection stress biases remain large, respectively 0.3122421 and 0.3129245, with coverage 0.810 and 0.680; retain them prominently. The adjusted model remains diagnostic despite its nonnull recovery result. No empirical fitting was performed by the reviewer.

## Saved empirical model review — 2026-11-06

Following the coordinator's documented measurement decision and execution of the two bounded fits, inspected both saved model objects without refitting. Independently verified every exported fixed-effect estimate, standard error and 95% Wald bound against the model objects. Recomputed NB2 size, Pearson residual sum per residual degree of freedom, observed zero fraction and fitted conditional zero fraction; all matched the tracked diagnostic table. Both objects have 288 observations, convergence code zero and positive-definite Hessians. The saved gate at fitting has both required flags explicitly true.

The history model's within-strength coefficient is -0.1325903, SE 0.3249609, interval [-0.7695019, 0.5043213]; exponentiation gives 0.8758238 [0.4632438, 1.655861]. The figures and diagnostics are rounded correctly in `docs/quarterly_empirical_results.md`. That memo appropriately calls these initial conditional descriptive fits and explicitly leaves dependence, tails, influence, sensitivity and predictive validation unfinished. This verification establishes saved-output consistency, not full empirical model adequacy. The reviewer did not fit or refit empirical models.
