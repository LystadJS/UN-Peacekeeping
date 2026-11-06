# Final portfolio figure plan

Recorded 2026-11-06 before the portfolio plots were generated. These figures use completed analyses; they do not add fits, select a more favorable model, or change the primary sample.

The three core figures are trajectories, simulation recovery, and reporting sensitivity. Beni, Irumu and Masisi are named in advance for a compact trajectory display: Beni illustrates a high-count series, while Irumu and Masisi are the localities identified in the completed predictive-concentration analysis. They are not representative estimates of all 19 candidate areas and are not ranked as protection successes. An all-nine-locality trajectory supplement retains the remaining series.

The original proposal requested partially pooled locality deployment associations. That model was deferred because the common-slope pilot and source coverage do not establish recoverable locality-specific slopes. No such estimates are manufactured. A supporting figure instead displays the actual common association under the primary, timing, freshness and location-precision specifications, with their conditional intervals.

## Deliverables and interpretation

- `figure_1_trajectories`: three selected localities, recorded quarterly events and held-out history predictions alongside monthly listed stocks. Orange stock markers identify actual source-map months; monthly stock steps between markers are carried forward. The model uses prior-quarter mean strength, not contemporaneous stock. Panels have independent vertical scales.
- `figure_1_all_localities`: all nine observed-event and held-out prediction trajectories, with independent count scales. Prediction bands are conditional plug-in 95% NB2 count intervals from expanding windows, not parameter-inclusive forecast uncertainty.
- `figure_2_simulation_recovery`: average estimated coefficients for ordinary-model synthetic scenarios. Negative-effect and null truths are separated. Bars quantify Monte Carlo uncertainty in the estimated mean, while labels report coverage of the individual model-based coefficient intervals. These are different uncertainty quantities.
- `figure_3_reporting_sensitivity`: the exact algebraic shift under assumed log-linear recording probabilities. The ribbon is conditional coefficient uncertainty, not uncertainty about the recording mechanism. The primary interval already includes zero.
- `figure_4_empirical_sensitivity`: the actual common coefficient and conditional Wald intervals under five quarterly specifications. It is not a distribution of locality effects.
- `figure_5_prediction_comparison`: alphabetical locality mean log-score differences, plus the aggregate mean. This compares forecasting procedures, not protection outcomes; it is not a locality-success ranking.

Memo-sized versions of figures 2 and 3 are exported at 6.5 by 2.8 inches. Full versions provide more caption space. Scientific PNG and PDF figures are intentional public portfolio outputs; chart-ready aggregate summaries accompany them. Source-row and locality-quarter plotting tables remain in ignored `outputs/portfolio_figures/`. No raw maps, source files, or event records are redistributed.

Sources are the existing audited panel, held-out prediction records, deployment lineage and source-row FPU fields, dynamic simulation summaries, and empirical sensitivity aggregates. The companion R script contains paths, assertions and all transformations. Every visual is checked against the saved results and inspected after export.

## Export verification

The script ran successfully on 2026-11-06. All eight PNG designs (including the two compact memo variants) were visually inspected. All eight companion PDFs were independently rendered with Poppler and inspected; labels, interval displays and captions fit their pages. Export review corrected initial text-encoding and label-spacing problems. `portfolio/figures/figure_manifest.csv` records dimensions and SHA-256 hashes for the 16 final files. The four public chart-data CSVs contain only aggregate simulation, sensitivity and predictive summaries; private trajectory and prediction plotting records stay under ignored `outputs/portfolio_figures/`.

These figures reuse saved results without fitting new models. The primary coefficient interval includes zero, simulation uncertainty is distinguished from coefficient uncertainty, and forecast intervals remain explicitly conditional plug-in intervals. No locality-specific deployment effects or protection rankings are implied.
