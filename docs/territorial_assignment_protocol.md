# Territorial-assignment sensitivity specification

Set 11 November 2026 before fitting the expanded-outcome model.

Keep the corrected military exposure panel, nine localities, model formula,
NB2 distribution, and original 2016-2023 observation schedule. Add only existing
GED one-sided records; no unmatched news reports enter the outcome.

Apply the rule to all 19 fixed study localities and to 2014-2015 prehistory as
well as 2016-2023. Preserve the existing valid-coordinate, valid-date,
unique-polygon, and within-month date-interval requirements. Preserve original
eligible events. For additions require spatial precision 2 or 3; a single GED
ADM2 mapped to the same fixed city-territory locality as the coordinate; and
either explicit locality naming in the location description or precision 3
(the codebook's territory-known category). Screen narratives for contradictory
or multi-territory locations; ambiguous cases remain excluded. Precision 4-7
remains excluded even if a representative coordinate falls inside a locality.
Location descriptions are used, not headlines mentioning neighboring events.
Any externally adjudicated exceptions must be documented before model fitting.

Before fitting, narrative screening tightened explicit naming to containment
language (territory/district, in the locality, or its named Beni-Mbau sector),
rather than distance from a town alone. Five conflicting/ambiguous narratives
were excluded. Two previously reconciled source reports explicitly establish
the territory (499579 and 502510). The exceptions register records both kinds
of decisions. No coefficient was inspected during this review.

This deliberately conservative rule uses concordant administrative and narrative
evidence; it is not an assertion of independent geolocation verification. Do not
admit vague precision-2 records solely because a proxy coordinate lies inside a
polygon. City aliases refer only to the existing composite boundaries.

Rebuild counts, lagged counts, and active-spell histories from 2014. Preserve
left-censoring. If rebuilding creates missing histories, compare both outcomes
on identical complete rows and report losses rather than invent durations.
Refit the original reference first and verify its coefficient. Report within-
and between-locality count ratios and conditional Wald intervals, convergence,
and added records by locality/year. Do not compare AIC across changed outcomes.
No significance-driven rule changes, extra model families, or trend searches.
