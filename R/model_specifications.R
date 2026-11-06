# Candidate descriptive formulas, not fitted or validated models.
# glmmTMB::nbinom2(link = "log") is the intended family.
model_formulas <- list(
  baseline = recorded_events ~ factor(month_index) + province_id +
    (1 | locality_id),
  history = recorded_events ~ factor(month_index) + province_id +
    presence_within + presence_between + log1p(events_lag) +
    violent_spell_lag + presence_lag2 + (1 | locality_id),
  heterogeneity = recorded_events ~ factor(month_index) + province_id +
    presence_within + presence_between + log1p(events_lag) +
    violent_spell_lag + presence_lag2 + (1 + presence_within | locality_id)
)

# For future-month prediction replace saturated calendar effects with an
# extrapolatable structure. Recompute centering using training observations only.
prediction_formula <- recorded_events ~ month_index + month_of_year +
  province_id + presence_within + presence_between + log1p(events_lag) +
  violent_spell_lag + presence_lag2 + (1 | locality_id)
