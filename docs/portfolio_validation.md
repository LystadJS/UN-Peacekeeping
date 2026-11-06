# Portfolio validation

Validation performed 6 November 2026. This is automated checking and agent review, not independent human-reader acceptance. No empirical or simulation model was refitted for this check.

## Independent numeric checks

An R audit read the exported figure CSVs separately from their owning saved analysis tables. It matched source keys before comparing every source column, with numeric tolerance `1e-12`. All checks passed.

| Portfolio data | Owning analysis output | Evidence |
|---|---|---|
| `figure_2_simulation_data.csv` | `data/dynamic_quarterly_simulation_summary.csv` and `data/dynamic_quarterly_null_summary.csv` | All source columns match for six ordinary-history scenarios. Known truths were independently assigned as -0.30 or zero. Mean estimates equal truth plus bias; Monte Carlo limits equal mean plus/minus `qnorm(.975) * bias_mcse`. |
| `figure_3_reporting_data.csv` | `data/quarterly_sensitivity_reporting_curve.csv` | All columns and all 81 rows match. |
| `figure_4_empirical_data.csv` | `data/quarterly_sensitivity_specifications.csv` | All source columns match for the five displayed scenario keys; the added column is a display label. |
| `figure_5_prediction_data.csv` | `data/quarterly_prediction_localities.csv` | All columns match for all nine localities after key alignment. |

The locality means independently reproduce the overall log-score gain of **0.04289534** and the mean of **-0.01473459** after omitting Irumu's scores. The latter is an aggregation check, not a refitted model. Equal averaging is appropriate here because each locality contributes 20 held-out quarters.

All 16 file hashes in `portfolio/figures/figure_manifest.csv` were recomputed with SHA-256 from current file bytes and matched. The manifest has 16 unique paths, covering eight PNG/PDF pairs. These checks establish consistency with saved results, not independent replication of the upstream scientific analyses.

## Visual and artifact review

The figures agent inspected all eight PNG designs and independently rendered all eight PDFs with Poppler for visual inspection. Encoding, facet-label spacing and caption alignment issues were corrected before the final review. No clipped labels or captions remained. The two compact memo figures are 6.5 by 2.8 inches. Figure selection, uncertainty definitions and retained limitations are documented in `docs/portfolio_figure_notes.md`.

The memo and deck reviews below are agent reviews of the finished artifacts. They do not substitute for a reader interpreting the central figures without coaching.

- **Memo:** the memo agent rendered the final PDF with bundled Poppler at 125 dpi and inspected all four pages individually. It reported no clipping, overlap or missing glyphs, and readable figures and linked sources. The coefficient-ratio wording, coverage label and historical-data-vintage limitation were corrected before that final render. The delivered PDF has four pages, 1,424 extracted words and six links.
- **Discussion deck:** the deck agent visually reviewed all five rendered slides. The parent agent also inspected the latest slides 1-4 and an earlier render of slide 5. The final package has five slides, three native charts with three workbooks, two native tables and five notes parts. The package/layout validation receipt is `outputs/portfolio_deck/validation-1793982498966.json`; the final PPTX SHA-256 is `ea1ce76bed11e4373839970d77f17c9c6dbcbbee5cf6d258fd0a08f77b59c59f`. Structural checks passed. Native Microsoft PowerPoint opening and native font rendering were not tested; rendered previews and package checks do not establish that application-specific behavior.

## Scientific limits retained

The portfolio presents an inconclusive common deployment-strength association, not a causal effect or locality-specific protection ranking. Simulation Monte Carlo intervals are distinguished from coverage of coefficient intervals. Predictive intervals are conditional plug-in count intervals; uncertainty from estimated parameters and real-time data release is not represented. Reporting curves vary assumptions rather than estimating recording probabilities, and do not resolve deployment confounding. Source-level and locality-quarter plotting records remain in ignored `outputs/portfolio_figures/`; only aggregate chart data accompany the public figures.

Independent human interpretation of the central figures and discussion materials remains outstanding. Automated consistency checks and agent visual review do not complete that acceptance item.
