# Scoring the frozen 2027 Q1 research forecast

This workflow consumes an independently audited outcome panel. It does NOT fetch future data, classify raw GED events or certify the release's coverage. No genuine 2027 outcomes have been scored.

Run from the repository root:

Rscript scripts/score_prospective_2027_q1.R outcomes.csv release_metadata.csv

The existing .local_library and readr/digest packages are used. R/prospective_scoring.R contains the pure scoring functions.

## Outcome CSV

Exactly the frozen 19 locality IDs, one row each, with:
- locality_id
- target_quarter: 2027 Q1
- recorded_events: nonnegative integer; missing stays unknown
- coverage_complete: TRUE only after confirming full publisher-designated January-March coverage

Complete release coverage does not assert that every real-world incident was reported. Zero is a measured count under the retained inclusion rule, not a substitute for missing data.

Reconstruct outcomes from the first eligible Candidate cumulative release and, later, the specified annual final release using the frozen SALB2018 composites, type3, exact location precision and same-month interval rule. Preserve an event-level inclusion ledger and verify event IDs, dates, matches and totals before producing this CSV. This scorer alone does not perform that raw-event audit.

## Release metadata CSV

One row with:
- stage: preliminary or final
- release_id: publisher identifier
- release_date: YYYY-MM-DD
- coverage_start and coverage_end: publisher-declared occurrence coverage
- source_url: HTTPS evidence supporting the release/coverage
- eligibility_audit_path: existing local audit file
- release_selection_note: explain evidence that this is the first eligible preliminary release, or the specified final release; document any version-name change

The program verifies required declarations and timing, not the truth of a URL or note. A file's maximum event date cannot establish complete coverage. Later releases must not be selected for favorable results.

## Safeguards

The runner pins SHA256 hashes of the published forecast table, benchmark distribution and specification. It refuses a changed archive, pre-completion scoring, unavailable or incomplete declared releases, unmatched localities, unknown/noninteger/negative counts, or an existing stage output directory. A corrected score requires a separately documented version, never silent overwrite.

Outputs go to outputs/prospective_2027_q1_scores/preliminary or final. Both retain per-locality paired scores, summary scores, release metadata and hashes of the outcome/audit inputs. Forecast parameters and surge thresholds are never updated from observed outcomes.

Primary: Brier score for the fixed relative-surge definition. Secondary: discrete count CRPS, squared error, NB2 log loss, mean risks versus observed frequency, and conditional interval coverage/width. These are descriptive for one quarter; no precise independence-based significance claims are produced. CRPS includes a numerical tail-truncation check.

## Verification

Rscript scripts/test_prospective_scoring.R

Synthetic checks cover zero counts, exact surge thresholds, just-below thresholds, reordered rows, missing/duplicate localities, unknown/fractional/negative counts, incomplete coverage, wrong target period, premature release use, and a severe count beyond the empirical benchmark's support. These checks passed on 16 November 2026. They validate software behavior, not model accuracy or outcome measurement. No actual outcome score files were written.

The immutable forecast archive remains commit f8f04ab35cf38433b980adf67dbf478710d38d28. The scoring code is a later separately versioned addition; it does not alter that archive or retrospectively establish a new prediction.

## Raw-release preparation (added 16 November 2026)

A separate converter now implements the frozen geography and event rule:

Rscript scripts/build_prospective_outcomes.R release.csv release_metadata.csv

Use the extracted publisher CSV, not a concatenation of monthly releases. The
input IDs must be unique; duplication requires an explicit reconciliation.
The builder verifies the pinned boundary/crosswalk hashes, assigns each event
using that release's coordinates, and retains all DRC exclusion reasons.
It writes a 19-row panel only after the metadata timing/coverage checks pass.

Set eligibility_audit_path exactly to:
outputs/prospective_2027_q1_outcomes/preliminary/event_ledger.csv
or the corresponding final/event_ledger.csv.
The builder refuses to overwrite an existing stage or audit.

Inspect that ledger and publisher evidence, then pass the resulting outcomes.csv
and release_metadata.csv to the scorer. Preliminary and final releases are
built and scored separately. The pipeline does not automatically certify the
first eligible release or detect reporting omissions.

Run scripts/test_prospective_outcomes.R for verification. It reproduces all 19
strict 2023 Q4 locality counts (38 total events) from GED26.1 and tests the
quarter edges, cross-month intervals, precision exclusions, violence type and
duplicate-ID rejection using explicitly synthetic records. No 2027 outcome
panel or score has been created.
