# Synthetic panel archive

`scripts/archive_simulation_panels.R` materializes the existing simulation seeds without fitting models or adding scenarios. It preserves every full generator-return object: deployment covariates, true and recorded counts, recording probabilities, latent risk and intercept draws, histories where applicable, structural coefficient, scenario and seed. Fixed DGP parameters and initialization rules are preserved in verbatim generator-source copies with input hashes.

The archive contains 800 core panels, 1,000 dynamic panels and 200 matched-prehistory null panels. The initial-adjusted estimator reuses 200 dynamic panels; it does not create another 200 datasets. Thus 2,000 unique panels represent all 2,200 fit attempts. Seeds from unusable fits remain included; no usable-fit filter is applied.

Full RDS objects and the per-file SHA256 manifest remain ignored under `outputs/simulation_archive/`. The input manifest fingerprints both generator files, the exposure design, and all three per-fit record tables. The tracked `data/simulation_archive_summary.csv` records only family-level totals. Each generated panel is checked against fit-record seed and truth, and all ten existing first-replication examples are compared at zero numerical tolerance. Existing archive files are validated rather than silently overwritten.

These are synthetic outcome panels conditional on the empirical deployment design, not anonymized empirical violence records. An archive does not improve the model's demonstrated performance or remove selection/reporting limitations. No fitted model, empirical panel, or original source is modified by this workflow.
