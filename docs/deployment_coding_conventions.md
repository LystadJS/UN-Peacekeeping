# Deployment coding conventions and internal component checks

Adjudication dated 7 November 2026. This audit checks the published source-row fields underlying the ten proposed 2023 discrepancies. It does not change the original panel or authenticate a historical release.

## Rules and evidence

The [December 2020 codebook](https://www.uu.se/download/18.3f2acc1b18f157bd287131/1714053575165/Codebook-v-2-0.pdf), pp. 4–7, defines estimated strength from unit sizes, separates military units from headquarters and observers, and includes FPU within total strength. Its conversion is 650 per battalion, 150 per company and 35 per platoon; other sizes require explicit treatment. Unsized units must not be assigned a company merely because they appear on the map. The codebook does not state a general rule that any mixed sized/unsized location must have its entire numeric strength discarded.

The [February 2025 codebook](https://www.uu.se/download/18.74301a071971546b354496ad/1749556887803/Codebook_v.2.3.pdf), pp. 4–7, explicitly lists Tactical Intelligence Unit (TIU) under reconnaissance and identifies this as a troop category included in the numerical strength when available. That wording is current-version evidence, not proof the 2025 document existed in 2023. Both codebooks and the retained 2.3 map data are hashed in the [source manifest](../data/deployment_coding_conventions_sources.csv).

## Bukavu: the extra 150 is not an inferred MP headcount

Revision 49's raw row has three companies, total strength 450, infantry indicator 1 and infantry strength 150, but FPU indicator 0 and FPU strength 0. Its combined troop-type field nevertheless lists category 12, FPU. The country allocation is China 300, Egypt 150 and Bangladesh unknown. The comments explicitly say the Bangladeshi MP unit has no size given.

This combination identifies an internal FPU-versus-infantry classification inconsistency. Egypt's FPU symbol and country allocation account for the 150 in the total; the unknown MP is not the extra company. Under the research definition excluding FPU, the map-consistent military component is 450 minus 150, or **300**. Revisions 50 and 51 already code FPU 150 and yield that military component. Original coder intent is not established, but the proposed mechanism of assigning MP a default 150 is contradicted by the published components.

## Mavivi: TIU is included, helicopter support is explicitly unsized

All three rows have two battalions and six companies, implying **2,200**. Their comments identify four QRF companies and explicitly leave the South African helicopter-support unit and Bangladeshi MP unsized. The troop-type field includes reconnaissance. For revisions 49 and 50, the South African subtotal is 950: the battalion, QRF company and TIU company account for it. Other known country components add to 1,250, giving the same 2,200 total. A seventh company must not be attributed to TIU omission; it would instead count the separately documented unsized helicopter-support unit.

Revision 51 contains an additional unresolved internal inconsistency: its South African subtotal is 1,100 and all known country values sum to **2,350**, although unit counts, total strength 2,200 and the unsized-helicopter comment remain unchanged. The source does not explain this 150-person difference. Resolving the earlier map-reading error does not resolve this separate TCC-subtotal inconsistency, and the larger subtotal is not silently substituted for the total.

## Rwindi and Nyamilima

Across all three maps, the current source codes Nyamilima as one Indian battalion (650) and Rwindi as one Moroccan company (150). These are explicit country and unit-size assignments, not FPU subtraction or geosplit arithmetic. Their correctness depends on the original map leaders and independently established place locations; the companion symbol and geography adjudications supply that evidence.

## Reproduction

Run `scripts/audit_deployment_coding_conventions.R`. It verifies three original source hashes, retains the twelve affected source rows privately, and generates [the component audit](../data/deployment_coding_conventions_audit.csv). Known TCC subtotals are labelled as such and never treated as full headcounts when another country's strength is unknown. The original sources, analysis panel and fitted results remain unchanged. Human review remains skipped, not completed.
