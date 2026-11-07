# Quarterly dictionary and original-source spot checks

`scripts/check_quarterly_source_records.R` validates dictionary coverage for all 36 distinct fields across the active quarterly panel, history grid and initial-condition export. Definitions include units, missingness rules and transformations. The checks reject duplicate dictionary names or undocumented exported fields.

Six cases are fixed in code before reconstruction: Beni 2016 Q1, Rutshuru 2023 Q4, Shabunda 2016 Q1, Aru 2016 Q1, Fizi 2019 Q2 and Lubero 2018 Q3. They cover the initial and final analysis periods, positive and zero recorded counts, constant deployment and unlisted exposure, and changing exposure availability. This is a purposive accounting check rather than a random-sample estimate of error prevalence.

The script extracts the original GED ZIP afresh into its own ignored directory. It independently reapplies the declared event filters and spatial assignment using original SALB geometry and the versioned composite crosswalk. It also reads original monthly Geo-PKO rows, reassigns their coordinates, subtracts FPU counts, and reconstructs prior-quarter military strength. It checks event totals, civilian fatalities, prior counts, deployment means, and agreement of original deployment row identifiers with the existing lineage.

All six cases passed, including Aru's unknown strength (not zero) and Shabunda's zero recorded events. Aggregate results are tracked in `data/quarterly_source_spotcheck_summary.csv`; source records and case details remain ignored under `outputs/quarterly_pilot/source_spotchecks/`. No empirical model was fitted. These are reproducible computer checks against source datasets, not independent verification of the underlying news reports or human review.

Supported plan updates: the quarterly data dictionary is complete for current exported fields; selected locality-quarter records have been reconciled to original source records by a reproducible check. The separate request to verify records **manually** should be marked skipped under the user's decision to omit human review, not relabelled as completed manual review.
