# Frozen research forecast specification: 2027 Q1

Prepared 16 November 2026, before the target quarter. This is an experimental forecast comparison, not an operational warning system or an established peacekeeping-effect model.

Target: strict-definition recorded one-sided attack counts in the existing 19 eastern DRC locality composites during 1 January-31 March 2027. Surge = count >= ceiling(max(m+2,2m)), where m is the 2025 Q4-2026 Q3 quarterly average. This retains the existing numerical candidate following the user's choice of a sharp relative increase. No constants are selected using 2027 outcomes.

Information freeze: annual GED26.1 through 2025 plus the archived Candidate26.01.26.09 for January-September2026, using their own coordinates, dates and precision. Same SALB2018 geometry and city crosswalk. Exclude cross-month intervals, non-exact location precision and non-one-sided events. Preserve incomplete 2026 Q4 as unknown; do not use its partial events. Record file hashes and source-date anomalies. No claim that Candidate and final GED are interchangeable.

Candidate model: NB2 count GLMM with locality random intercept, province, season, linear quarter index, lag2 activity and log(1+lag2 prior-four-quarter total). Train 2016 Q1-2026 Q3 with 2014-2015 prehistory. This is the same older-history formula already evaluated, not a new model search.

Benchmark: empirical locality count distribution with ten global-training pseudo-observations. Compute both count means and surge probabilities at identical fixed thresholds. Save NB2 conditional 90% count intervals, model parameters, convergence checks and input provenance. Do not revise issued predictions after new releases or target events arrive.

Scoring: primary surge Brier score, paired on the same 19 rows. Secondary count CRPS, mean squared error, log score for NB2, observed/mean predicted surge frequency, and conditional interval coverage/width. No tuned alarm threshold or review budget. Do not select a model from a single quarter. The prior retrospective failures remain part of the study.

Outcome revision policy: use the FIRST cumulative UCDP Candidate release explicitly covering all January-March2027 as the preliminary score, and annual GED28.1 covering2027 as a separate final-release score if published. Never silently replace preliminary scores. Use the fixed geography and eligibility rule for both. Unknown release availability is not zero events. If release version naming changes, document the publisher-designated coverage and identifier without choosing a favorable version.

Before calling this externally registered, publish the specification, input hashes and forecast table in a timestamped archive and retain its URL/commit. Local file timestamps alone are not independent registration. No prospective performance claim is possible until outcomes exist. A single future quarter is only an initial prospective test.

Handover branch: no replies/records yet, per user. Keep descriptive and documentary conclusions; do not infer maintained protection from these forecasts.
