# Rebuilding the quarterly panel from original inputs

`scripts/rebuild_original_inputs.R` is the clean raw-to-panel entry point. Without `--execute`, it prints the ordered plan and performs no copying or pipeline work. With `--execute`, it requires a new target directory, checks every original against `data/source_manifest.csv`, copies only raw originals and an explicit code/configuration allowlist, and runs each step in a fresh R process. Existing targets are never deleted or overwritten.

For an environment already staged by the parent orchestration, use `--prepared-project --execute` with its target path. This mode requires no output/interim/processed directories and allows only raw files and the source manifest under data. It verifies raw hashes in place, does not copy inputs, and forces subprocess library paths to the target `.local_library` plus R's base library. The target may contain the explicitly allowed code, configuration, documentation, tests and portfolio sources. This mode supports an independently restored package environment without inheriting the user's package library.

## Dependency order

1. Acquisition is separate: `scripts/acquire_week_1.R` retrieves pinned sources and verifies saved hashes. A rebuild must not refresh changing landing pages or source releases. Preserve the original manifest and all 20 catalogued artifacts locally, including codebooks and terms. Source rights and original geographic caveats still apply.
2. `scripts/audit_week_1.R`, with `AUDIT_AGGREGATE_CITIES=true`, extracts the original GED ZIP into a newly empty interim directory, reads original Geo-PKO map/month RDS files, applies `config/city_aggregation.csv`, and rebuilds spatial assignments and event/deployment lineage. It also reads the historic SALB vintages and alternative geoBoundaries polygons for geographic comparisons.
3. `scripts/build_quarterly_exposure.R` consumes that regenerated deployment lineage, locality inventory and original monthly RDS; `tests/run_quarterly_checks.R` validates the resulting exposure design.
4. `scripts/build_quarterly_panel.R` consumes the regenerated event ledger, extracted GED, exposure audit and deployment lineage; `tests/run_quarterly_panel_checks.R` independently checks counts, keys, fatalities and histories.
5. Freshness/design audits, descriptive figures and the panel manifest are regenerated last. Logs record each subprocess's exit status and timing. Copy-input hashes identify code/configuration as well as original data.

The ordinary runbook previously required a completed geographic audit. In addition, the Week 1 audit reuses an extracted GED CSV if it already exists. A new isolated target is essential for demonstrating that extraction and geographic assignments were rebuilt rather than borrowed from checkpoints.

## Boundaries of this check

The entry point copies no interim data, processed data, output directories, simulation summaries, fitted models, or validation-status flags. It does not enable empirical readiness. Package binaries are reused from explicitly recorded installed library paths; no packages are installed. This is not a package lockfile or a demonstration on another operating system/GDAL build. The output manifest is a rebuilt audited snapshot, not an empirical-model freeze.

Human source-review conclusions, deployment-absence adjudication, protocol decisions and source-use permissions are not reproducible numeric transforms. The city-composite crosswalk is a versioned analytical input and is hashed alongside code; it is not inferred afresh from boundary names. These decisions must remain documented rather than being represented as automatically rediscovered.

This entry point ends at the quarterly panel and descriptive audit. Full simulation, empirical fitting, diagnostics, prediction, sensitivities and portfolio regeneration are separate downstream work with their own status and input requirements. A successful panel rebuild alone does not certify that full workflow. At preparation time the runner was parsed and dry-run only; execution requires the explicit `--execute` argument.

The static quarterly dictionary is now an allowed input alongside original files and the source manifest. It contains field definitions, not cached observations or readiness flags. The main clean workflow uses it for independent six-case source reconciliation after panel construction.
