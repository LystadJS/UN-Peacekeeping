# Quarterly coverage figures

Run `Rscript scripts/plot_quarterly_coverage.R` after the panel builder. The script saves PNG and PDF figures plus their 608-row plotting table under `outputs/quarterly_pilot/`.

`quarterly_coverage` shows availability of the previous-quarter strength predictor for all 19 localities over 2016 Q1 through 2023 Q4: 362 available quarters and 246 unknown/incomplete quarters. Crosses reinforce that missing exposure is not troop absence. Stars identify the nine complete-exposure localities (288 quarters).

`quarterly_freshness` shows maximum month-to-source-map age across listed deployment rows in the preceding quarter. Observed ages range from zero to five months. This measure can be present even when strength coverage is incomplete; it must not be interpreted as the number of independent deployment observations. Both figures use the same locality order and time axis.

PNG exports were visually inspected for labels, legends, missing-state marks, and clipping. An initial platform encoding problem in the date-range subtitle was repaired by using an ASCII hyphen. The figures describe source coverage, not protection effects or violence-reporting completeness.
