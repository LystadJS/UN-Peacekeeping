# Week 1 preparation and execution runbook

**Status: prepared; empirical audit not run.** Follow the [full plan](project_plan.md). The current scope is preparation only. This runbook does not approve a dataset, choose boundaries, or authorize conclusions.

## Preparation available now

- `data/source_manifest.csv`: one row per future downloaded artifact, including codebooks.
- `data/data_dictionary.csv`: draft target fields; source mappings remain pending codebook inspection.
- `data/audit_checks.csv`: machine-readable check specifications; every result is `not_run`.
- `data/templates/exclusion_ledger.csv`: record-level exclusion schema.
- `data/templates/boundary_crosswalk.csv`: crosswalk schema.
- `data/templates/join_audit.csv`: reconciliation schema.
- `docs/feasibility_decision.md`: explicit pending gate.
- `docs/decision_log.md`: open decisions and change history.
- `scripts/prepare_week_1.R`: creates ignored local working directories and captures the current R/package environment without installing packages or downloading data.

Run from the repository root:

```r
source("scripts/prepare_week_1.R")
```

## Execution order when Week 1 begins

1. **Scope and codebooks.** Read source definitions before selecting fields. Decide province list, stable administrative level, 2015–2023 coverage and pre-period history. Record decisions before mapping events. A candidate to assess is territory/city geography within North Kivu, South Kivu and Ituri; this is not a confirmed geographic definition. Check whether those units provide deployment variation without discarding spatial precision.
2. **Source acquisition.** Obtain official versioned data, codebooks and boundaries. Store untouched originals under `data/raw/<source>/<version>/`. Never overwrite an original; revised releases receive separate directories. Fill download URL, version, retrieval timestamp, SHA-256, terms and citation for each artifact. Landing-page discovery is not file acquisition.
3. **Schema and outcome mapping.** Replace draft field mappings in the dictionary using the actual releases. Primary count: qualifying one-sided events. Secondary candidate: civilian fatalities within those events. Civilian fatalities in state-based/non-state events must be a separate series. Do not call all recorded civilian fatalities targeted killings, or treat unknown victims as confirmed civilians. Confirm which fields supply best/low/high estimates before promising civilian-specific bounds.
4. **Source-level audit.** Inventory years, dates, identifiers, coordinate ranges, precision codes, mission coverage and source maps. Store every check result with denominator, affected rows, evidence file and resolution. An unusual count is not automatically an error. Preserve rejected records and reasons locally.
5. **Spatial and temporal reconciliation.** Validate CRS and stable boundary IDs. Count unmatched and multiply matched points; do not silently choose among polygons. For each join retain input/output row counts and unique event/unit counts. Preserve map dates and source-map IDs before any monthly expansion. Do not infer deployment absence merely because a location is missing from a table.
6. **Coverage outputs.** Produce source-specific locality–month coverage heatmaps, map-age and map-gap plots, and a map of retained/ambiguous locations. Plot missing status separately from zero; distinguish source-map observation from carried-forward values. Show denominators and exclusion totals with each display.
7. **Feasibility gate.** Summarize deployment changes and independent map updates by locality. Document monthly versus quarterly feasibility, geographic precision losses and unresolved coverage. Complete the decision template with evidence: proceed, narrow, or revise. Keep `empirical_ready = FALSE` until a usable panel and protocol also pass their later gates.

## Week 1 definition of done

An audit-ready source inventory and dictionary, check results with evidence, exclusion and join ledgers, boundary decisions, three audit figures and a written feasibility decision. Templates alone satisfy none of those empirical acceptance conditions.

## Source discovery notes

Landing pages reviewed on 2026-11-05 (America/New_York):

- [UCDP download center](https://ucdp.uu.se/downloads/) advertises GED 26.1, codebook and CC BY 4.0 use with required citations. Confirm the acquired files and preserve the applicable terms.
- [Geo-PKO](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset) advertises v2.3 through 2024, both location-map and expanded location-month products. Prefer retaining both for timing reconciliation; independently verify their terms and schemas.
- Administrative boundary provider and version remain unselected. Evaluate stable IDs, territory/city coverage, historical validity, CRS, provenance and reuse terms before choosing.

Source pages may change. The source manifest is authoritative only after actual file retrieval and verification.
