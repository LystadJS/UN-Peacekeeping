# Descriptive quarterly panel checks

The frozen 2016-2023 panel contains **19 candidate localities and 608 candidate quarters**. The common-slope analysis retains nine localities with complete audited exposure, each contributing 32 quarters (288 total). Ten other areas contribute no rows to this complete-locality analysis, even where some individual quarters have known exposure. Unknown exposure is not deployment absence.

The existing coverage heatmap, produced by `scripts/plot_quarterly_coverage.R` at `outputs/quarterly_pilot/quarterly_coverage.png`, already shows usable exposure quarters for all 19 areas, highlights the nine retained localities, and distinguishes unknown/incomplete exposure from listed strength. It was re-inspected rather than duplicated.

## Outcome and strength distributions

The new [descriptive figure](../portfolio/figures/descriptive_panel_distributions.pdf) shows recorded-event and lagged-strength distributions for all nine retained localities in alphabetical order. These boxplots complement the existing time trajectories: neither the ordering nor the distributions are estimates of protection success. Locality labels report their usable observation counts. The [aggregate summary](../portfolio/figures/descriptive_panel_summary.csv) preserves all 19 candidate areas, their known lagged-exposure counts, retained counts and outcome summaries; strength summaries are deliberately unavailable for the ten excluded areas.

- There are **1,248 recorded events**, with quarter counts ranging from zero to 48. **132 of 288 quarters (45.8%)** have zero recorded events. A zero means no retained UCDP record under the audit rules, not known absence of underlying qualifying violence.
- Dispersion differs substantially: Beni has median 13.5 events per quarter and 496 total events; Shabunda has median zero and two total events. This is descriptive sample composition, not a comparative deployment-effect estimate.
- Lagged strength is the **prior-quarter mean listed military personnel divided by 1,000**, excluding formed police units. Shabunda's value is constant at 0.15 (150 personnel), so it contributes no within-locality strength variation. The other eight retained localities have 11-20 changes between consecutive quarterly lagged-strength values. These changes are numerical quarterly changes, not independently observed deployment decisions or source-map changes.
- For retained areas, the full observed range of lagged strength is 0.15-3.05 thousand listed military personnel. Boxplots display each locality's middle 50%, median and 1.5-IQR whiskers; points beyond whiskers denote more extreme quarters, not inferential uncertainty.

## Reproduction and verification

Run `Rscript scripts/build_descriptive_panel_figures.R` from the repository root after panel construction. The script reads the two frozen panel RDS files, asserts the 19/608 and nine/288 dimensions and unique retained locality-quarter keys, and writes one PNG/PDF pair plus an aggregate CSV. R/ggplot2 use explicit base Cairo PNG and Cairo PDF devices, avoiding optional-renderer drift. It does not fit models, change the panel or overwrite the original portfolio figure manifest.

The PNG was visually inspected and the PDF independently rendered with bundled Poppler at 100 dpi and inspected. Labels and captions fit without clipping or overlap. Source rows remain in the ignored analysis outputs; only locality-level summaries and scientific figures are published. This is agent visual review; no independent human-reader review is claimed.
