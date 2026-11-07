# Portfolio validation

The 7 November 2026 corrected-panel refresh supersedes the older artifact-specific claims below. The earlier sections remain a dated record of the original portfolio; current bytes and source version are in portfolio/artifact_manifest.json. See the refresh section at the end.

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

- **Memo:** the memo agent rendered the final PDF with bundled Poppler at 125 dpi and inspected all four pages individually. It reported no clipping, overlap or missing glyphs, and readable figures and linked sources. The coefficient-ratio wording, coverage label and historical-data-vintage limitation were corrected before that final render. The delivered PDF has four pages, 1,435 extracted words and six links.
- **Discussion deck:** the deck agent visually reviewed all five rendered slides. All five slides were re-inspected after the clean rebuild. The final package has five slides, three native charts with three workbooks, two native tables and five notes parts. The package/layout validation receipt is `outputs/clean_rebuild_20261106/project/outputs/portfolio_deck/validation-1793987219040.json`; the final PPTX SHA-256 is `64c1c5368d021a14a2ea3c6265c7700d31aa237177dccf8fb8cdeeac009553d3`. Structural checks passed. Native Microsoft PowerPoint opening and native font rendering were not tested; rendered previews and package checks do not establish that application-specific behavior.

## Scientific limits retained

The portfolio presents an inconclusive common deployment-strength association, not a causal effect or locality-specific protection ranking. Simulation Monte Carlo intervals are distinguished from coverage of coefficient intervals. Predictive intervals are conditional plug-in count intervals; uncertainty from estimated parameters and real-time data release is not represented. Reporting curves vary assumptions rather than estimating recording probabilities, and do not resolve deployment confounding. Source-level and locality-quarter plotting records remain in ignored `outputs/portfolio_figures/`; only aggregate chart data accompany the public figures.

Independent human interpretation of the central figures and discussion materials remains outstanding. Automated consistency checks and agent visual review do not complete that acceptance item.

## Clean-rebuild final verification

The isolated original-input run passed all 383 scientific comparisons. The two wording corrections in the independent audit were verified in the rebuilt PDF/PPTX. The final figure builder now specifies the Cairo PNG device explicitly; all eight new PNGs and eight rendered PDFs were inspected, and the two affected memo pages were rechecked after the renderer fix. Current artifact hashes are in portfolio/artifact_manifest.json. See clean_rebuild_results.md for the environment scope and resolved chart-workbook permission retry. Human review remains outstanding.

## Corrected-panel refresh — 7 November 2026

The current memo, figures and deck incorporate the separately versioned corrected-panel findings at analysis commit `8510728538026e8e3da1910360c0671b96dd0c2c`. The supported common slope is −0.188535 (conditional 95% Wald interval −0.829557 to 0.452487); the original and Mavivi-alternative intervals also include zero. This is not equivalence or a causal estimate.

The updated R claim audit passed against retained fitted objects, row-level original forecasts, simulation records and diagnostic draws. Figure 4's three rows match the corrected model comparison and retained coefficient matrices. Figure 3's 81 rows equal the corrected coefficient and interval minus the assumed log recording ratio. Its feasible probability range was independently recalculated over corrected exposure support. The reporting process is assumed, not estimated, and no model is refitted by this figure. Original prediction and simulation displays are explicitly labeled as not rerun on corrected exposures.

Agent visual review covered all four memo pages, all five deck slides, the six changed PNG designs and all eight independently rendered figure PDFs. A separate agent compared the final memo, outline, extracted PPTX notes and figure documentation with the saved corrected results; no outstanding discrepancy remained. Automated artifact checks passed: four memo pages; five slides and notes; three native charts and workbooks; two native tables; all sixteen figure hashes and two descriptive-supplement hashes matched. Current PDF/PPTX hashes are in `portfolio/artifact_manifest.json`. Deck package/layout validation is recorded locally at `outputs/portfolio_deck/validation-1794090035083.json`. The current presentation runtime is bundle 26.1104.22356, dependency runtime v26-1104-2876-0.

The corrected-panel source/lag/model checks were rerun and passed, including verification of all eighteen frozen original-analysis files. The unchanged project-plan SHA-256 is `e6a030f560f682facab30843f298731e69b85c8cb523021c2ce0341ac609d4b9`. The clean workflow now constructs and fits corrected panels before building portfolio figures. No full end-to-end scientific run, new simulation or rolling forecast was performed for this presentation refresh; the previous full-run receipt is not extended. Human review remains skipped by the user, not completed; native PowerPoint opening remains untested.

A final read-only PPTX check compared all 486 chart-cache numbers across the three 81-point reporting series with the corrected saved coefficients and log recording ratios: maximum rounding difference 4.94e-12 (tolerance 1e-10). Embedded workbook values match chart caches exactly, and all three coefficient-table rows match at displayed precision. The private receipt is outputs/portfolio_deck/independent_corrected_value_check.json.
