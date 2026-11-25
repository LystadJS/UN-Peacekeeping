# Technical appendix

## Panel and source definitions

The unit is an ADM2 territory observed in calendar months. OCHA v01 fixes those boundaries for the full study period. A single qualifying coordinate and compatible administrative labels are required for primary ACLED geography. Primary counts use day-level time precision and geographic precision 1 or 2. The exact-location sensitivity uses geographic precision 1. The narrower event-type series uses the same geographic and date screens. UCDP one-sided incidents use location precision 1 or 2 and intervals contained within a single calendar month. UCDP counts and deaths describe a distinct, lethal organized-violence series.

The monthly peacekeeping input is traced to its original map by source, date, place, coordinate and listing measures. Military strength is the provider's listed troop estimate less listed formed police personnel. Conflicting co-located entries are flagged and strength remains missing. A positive linked military estimate supports listed presence. Coverage evidence plus the absence of a known or indeterminate military listing supports a map-listing zero. A zero makes no inference about incident monitoring, patrol reach, or other security activity. WorldPop populations use exact fractional raster extraction and report missing-cell share and the country raster total as checks.

## Association

The frequentist conditional mean uses a log link with a population offset. The within-territory term centers preceding-month presence on its territory average within the analysis sample. The territory average also enters the model, alongside the territory random intercept, province and calendar-month fixed effects, and preceding-month incident and battle history. The negative binomial specification uses the quadratic mean–variance relationship. The matched Poisson model and sensitivity analysis use the same term definitions. The fitted rate ratio is an observed estimate of a fixed unknown conditional association. The reported 95% interval uses model-based standard errors. Confounding, spatial spillovers, map carry-forwards, and differential recording can all alter its interpretation.

Predictive count checks, Pearson residual correlation over adjacent months, a territory-level spatial permutation diagnostic, territory and map omissions, and refitted simulations document model limitations. Simulations illustrate departures from the fitted reference under hypothesized recording differences and selection. Those scenarios provide no estimate of actual reporting bias.

## Forecasts

The response is the next month's count in a territory. Each fit uses only earlier months. The smoothed benchmark pools territory history with six months of study-wide average history. The recency benchmark averages the smoothed estimate with the territory's latest observed monthly count. Poisson and negative binomial mixed models use the same event-history predictors in matched comparisons. Count distributions use fitted means and dispersion conditional on model estimates and territory effects. Their quantiles describe count variation under those fits. Parameter uncertainty is assessed indirectly through empirical calibration and paired uncertainty in scores.

Development ends in December 2022. The retained evaluation months are 2023–2024 for matched deployment comparisons and 2023–2025 for outcome history, with 2025 summarized separately. Model selection uses development log scores. Score differences use circular six-month blocks, resampling all territories jointly within each month. The criterion requires a negative 95% interval upper bound for both paired log-score contrasts, plus deployment model empirical 90% interval coverage from 85% to 95%. For incomplete or nonconsecutive score months, the uncertainty gate stays unresolved.

## South Kivu

The case windows describe recorded outcomes in the full territory containing the site. They omit the milestone month and flag overlap. Province figures distinguish cessation of operations and completion of withdrawal. A documented facility handover establishes neither protection coverage before departure nor replacement protection afterward. The province changed as a single policy cluster. Documentary evidence of uneven incident reporting, unresolved protection reach, and unresolved comparison areas currently rules out an effect or noninferiority conclusion.

The prior quarterly project uses different geography, periods and filters. Its adjusted associations and historical forecast evidence serve as interpretation checks. Event totals should be compared only after reconciling the source version, date filter, boundary, and precision rules.
