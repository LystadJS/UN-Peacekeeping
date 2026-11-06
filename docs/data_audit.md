# Empirical data audit and release gates

No empirical model should run until each gate has evidence in an audit record.

| Gate | Required evidence |
|---|---|
| Provenance | Exact version, retrieval date, local path, SHA-256, terms, source codebook and citation in the manifest |
| Scope | Explicit province list, administrative level, dates, mission identifiers, pre-period coverage |
| UCDP eligibility | Version-specific one-sided violence filter, actor eligibility rules, event identifiers, date precision and geographic precision distribution |
| Event counting | Deduplication by source event identifier; policy for events spanning months; exclusion ledger and alternative date assignments |
| Fatalities | Separate best/low/high fields and aggregation rules; never equate the event count with civilian fatality totals |
| Boundaries | Version, CRS, stable IDs, crosswalk for changes, point-on-boundary handling, ambiguous/unmatched join counts |
| Deployment | Mission filter; units versus troop estimates; duplicate unit/location-map handling; map identifier, map date, age and carry-forward flags |
| Timing | Reproduce monthly carry-forward; compare quarterly aggregation and early/mid/late change timing between observed maps without treating those assumptions as observed dates |
| Coverage | Distinguish true observed absence, out-of-scope periods, unavailable maps and missing source coverage |
| Panel | Unique locality-month key, complete calendar skeleton, reconciliation to source totals and explicit exclusion counts |
| Identifiability | Deployment transitions, independent map updates and within-locality variance; slope feasibility assessed with synthetic designs resembling the audited panel |

Quarterly outcomes sum events, but deployment aggregation and lag alignment must be defined explicitly (e.g., preceding-quarter mean presence). Do not merely sum monthly troop stocks. Source-map interpolation using later maps is a retrospective sensitivity assumption and must not leak into prospective forecasting.

Suggested panel fields: locality_id, province_id, month, recorded_events, civilian_fatalities_best/low/high, deployment_presence, deployment_strength, source_map_id, source_map_date, map_age_months, carried_forward, event_coverage_complete, deployment_coverage_complete, boundary_version. Preserve event-level and deployment-level join audit tables locally.

Zero-fill event counts only within audited source coverage; exclude or flag low-precision locations according to a frozen rule, and assess alternative precision thresholds. Coordinate uncertainty is not resolved by a deterministic spatial join.

Official sources checked during setup:
- https://www.uu.se/en/department/peace-and-conflict-research/research/ucdp/ucdp-methodology.html
- https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset

The current Geo-PKO landing page advertises v2.3 through 2024, but the manifest remains unpinned until files and codebook are acquired. UCDP and boundary versions remain open choices.
