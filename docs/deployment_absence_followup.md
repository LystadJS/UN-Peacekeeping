# Deployment absence follow-up — 7 November 2026

**Official UN reporting documents military presence in Djugu despite no Geo-PKO listing assigned to that territory in the pilot.** This resolves a concrete instance of the ambiguity: unlisted cannot mean operationally absent. It does not recover a quarterly troop-strength series or establish completeness elsewhere.

## Evidence and scope

The [Geo-PKO provider](https://www.uu.se/en/department/peace-and-conflict-research/research/research-data/geo-pko-dataset) describes deployments coded from UN maps, troop strength estimated using standard unit sizes, and monthly expansion using the last source map. The observational object is mapped deployments, not an exhaustive log of patrols or short-lived combat deployments. Its distinction between location-map observations and expanded monthly rows remains essential.

| Official source | Evidence relevant to the pilot | What it resolves |
|---|---|---|
| [S/2022/252, paragraph 38, page 8](https://documents.un.org/api/symbol/access?l=en&s=S%2F2022%2F252&t=pdf) | Describes a standing combat deployment established at Drodro on 7 January 2022, alongside military interventions in Djugu. | Positive military deployment evidence within the study window, independently of a Geo-PKO row. |
| [S/2023/574, paragraph 19, page 5](https://digitallibrary.un.org/record/4017644/files/S_2023_574-EN.pdf?version=1) | Identifies temporary operating bases at Bayoo, Fataki, Rhoo and Jina, and standing combat deployments at Drodro and Amee, in Djugu territory. | Multiple named deployments show that the discrepancy is not limited to one brief incident. It still does not establish continuous quarterly staffing. |
| [MONUSCO article dated 15 January 2022](https://monusco.unmissions.org/fr/news/djugu-une-base-temporaire-de-la-monusco-a-drodro-pour-favoriser-le-retour-des-deplaces) | Reports the 7 January installation at Drodro, explicitly located in Djugu territory. | Corroborates the deployment date and geographic description; it provides no adequate strength series. |

These sources were investigated on **2026-11-07** through search-indexed text from the official UN pages. Direct browser opens returned access errors (403 or inaccessible endpoint), and direct local download attempts failed DNS resolution. No new full-source PDF or HTML snapshot was obtained; no file hash or complete-document inspection is claimed. The paragraph-level report excerpts were available in the search results. The reports and mission article are institutional corroboration, not independent field verification. Search-engine crawl/upload ages are not treated as original publication dates. No external person was contacted.

The [evidence ledger](../data/absence_followup_evidence.csv) preserves source URLs, report locators, access method and the explicit missing full-source hashes.

## Reproducible checks against the retained data

Run `Rscript scripts/audit_absence_followup.R` after the existing Week 1 and quarterly exposure stages. It writes [locality summaries](../data/absence_followup_localities.csv) and [place-name checks](../data/absence_followup_place_checks.csv), leaving the frozen analysis inputs unchanged.

The script audits all 19 candidate localities over the 96 months from January 2016 through December 2023. Djugu, Aru, Idjwi and Mahagi have no assigned listing in those months. Mahagi nevertheless has one eligible **outcome** quarter because 2016 Q1 uses the deployment observations from 2015 Q4; listing-month counts and lagged outcome-quarter eligibility are different quantities. The ten incomplete-history localities are not collectively absent: several have intermittent mapped listings. Nine localities remain complete under the existing lag/freshness rule.

For Djugu, the retained spatial lineage assigns zero monthly rows and the quarterly exposure ledger reports zero eligible quarters. Checks of the original MONUSCO map and month files for 2016–2023 find no exact names (with the explicit limited spelling variants recorded in the CSV) for the six places named in S/2023/574. This checks both source levels, not just a monthly panel join. It is not a comprehensive alias, coordinate or map-symbol adjudication, and does not by itself prove a coding error in Geo-PKO. The cause may involve the underlying maps' scope, omissions, coding or geographic representation. The official narrative evidence establishes the narrower point that military activity existed in an unlisted territory.

`verified_zero_months = 0` records the investigation's certification status, not an estimate that zero-deployment months never occurred. Listed-month counts are not counts of independent maps, and a listed row need not have a usable numeric military strength.

## Decisions and remaining evidence gaps

| Question | Disposition |
|---|---|
| Can unlisted Djugu be treated as no military deployment throughout 2016–2023? | **No.** Official reports supply positive counterexamples in 2022 and 2023. |
| Can the reports fill Djugu's missing quarterly strength? | **No.** Personnel numbers, complete start/end intervals and redeployment accounting are insufficient. No zero, positive constant or carry-forward value is imputed. |
| Can absence in Aru, Idjwi or other missing months be certified? | **Unresolved.** A bounded search did not yield evidence adequate for full-period military-absence certification. A 2014 Idjwi mission-presence discussion is outside the pilot and cannot establish 2016–2023 military status. |
| Does positive narrative evidence justify changing the fitted panel now? | **No.** It supports the current unknown/excluded rule and narrows interpretation, but does not supply comparable strength measurements. |
| What would permit expansion? | A complete locality-by-date source inventory reconciling original deployment maps, temporary-base opening/closure records, personnel/unit-size evidence, aliases/coordinates and reassignments. For operational reach, patrol/activity records would be needed separately. |

The common slope remains an association with **listed military strength within continuously observed localities**. The follow-up strengthens the warning that the selected sample excludes places with real military presence. Even the retained localities' listed strength need not measure all temporary activity or effective protective reach. It does not establish the direction or magnitude of selection bias and does not change the empirical estimate.

Human review remains skipped at the user's request, not completed. This automated/source-based investigation is not a substitute label for human review.
