# Quarterly deployment freshness audit

The 2016–2023 design was re-evaluated on 2026-11-06 without fitting outcomes. `scripts/audit_quarterly_freshness.R` reconstructs monthly listed military strength from source-row lineage, requires three usable months per quarter, and applies the one-quarter exposure lag. Unknown listing is never recoded to zero.

| Maximum source-map age (months) | Eligible locality–quarters out of 608 | Localities with all 32 quarters |
|---|---:|---:|
| 0 | 0 | 0 |
| 1 | 105 | 0 |
| 2 | 275 | 0 |
| 3 | 343 | 0 |
| 5 | 362 | 9 |

The nine-locality complete-exposure sample therefore depends on allowing maps up to five months old. Quarterly aggregation does not eliminate deployment timing uncertainty. A three-month threshold retains many individual quarters but no uninterrupted locality series; this is not equivalent to having no usable information.

Five months is the existing pilot rule, not a freshness standard established by this audit. An unbalanced-panel alternative would require a separately documented eligibility and missingness strategy, with matching simulation checks. It must not silently replace the complete-exposure sample after seeing deployment estimates. Source-map timing perturbations remain a separate uncompleted sensitivity analysis.

Machine-readable results are saved in `data/quarterly_freshness_sensitivity.csv`. The exposure builder additionally rejects nonfinite or negative strength, nonfinite or negative map age, duplicate locality-month keys, and quarters without exactly three months. These safeguards preserve the existing audited design.
