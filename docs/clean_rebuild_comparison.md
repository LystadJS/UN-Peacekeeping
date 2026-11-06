# Independent clean-rebuild comparison

Rebuilt project: C:/Users/John/Documents/ChatGPT/UN-Peacekeeping/outputs/clean_rebuild_20261106/project
Checks: 383 ; passed: 383 ; failed: 0

Scientific numeric tolerance: absolute 1e-8. Panel/source-lineage cells, integer-valued fields, coverage, gates and convergence flags require exact equality.
Only seconds/elapsed_seconds and explicitly named manifest recorded_utc/sha256/bytes fields are omitted. Relative paths and scientific identifiers remain checked.
Non-generated documentation/provenance CSVs are not required outputs; any that exist in both roots are compared. Explicit list:
- audit_checks.csv
- audit_package_versions.csv
- data_dictionary.csv
- map_review.csv
- pilot_package_versions.csv
- pilot_protocol_version.csv
- pilot_source_manifest.csv
- quarterly_data_dictionary.csv
- source_manifest.csv

All retained reference scientific CSVs and selected private RDS objects are required; a missing rebuilt file fails. Model object environments are not byte-compared; fixed coefficients, SEs, dispersion, random-effect variance, sample size and convergence flags are compared.
This script reads reference outputs only for post-generation comparison. It does not feed them into the clean workflow, fit models, alter scientific tables, or complete independent human interpretation.

All specified comparisons passed.
