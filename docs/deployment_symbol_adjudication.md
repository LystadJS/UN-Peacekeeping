# Adjudication of the ten deployment-symbol discrepancies

Reviewed 7 November 2026 against the original 2023 UN maps, the retained Geo-PKO 2.3 source rows and the historical version 2.0 codebook. **The ten previously reported discrepancies now have explicit source-level decisions.** Three were errors in our earlier visual transcription; one is an internally inconsistent FPU field; six involve site assignment. This adjudicates the coded components, not actual troop headcounts, provider publication timing or the complete historical panel.

The [ten-row decision table](../data/deployment_symbol_adjudication.csv) preserves the earlier reading, current coded military value and adjudicated component. Earlier static transcriptions remain unchanged so the correction is auditable. The [source manifest](../data/deployment_symbol_adjudication_sources.csv) fingerprints all five retained originals used here.

## Mavivi: correct the earlier transcription, retain the coded total

The enlarged originals of revisions 49, 50 and 51 show two infantry battalions and six sized companies: one Indonesian engineering company, four QRF companies and one South African TIU company. The South African helicopter-support symbol has **no size bar**. The Bangladesh MP is also unsized. The correct sized-component arithmetic is therefore 2 × 650 + 6 × 150 = **2,200**, matching the current `no.troops` value.

The earlier 2,350 reading incorrectly added a company for helicopter support. It was not evidence that TIU had been excluded. The provider's `comment.on.unit` and `comments` fields explicitly describe helicopter support and MP as unsized on all three maps. For revisions 49 and 50, South Africa's coded 950 is consistent with its 650-person infantry battalion, 150-person QRF company and 150-person TIU company. The historical codebook includes known-strength support units in total troop estimates; it does not provide a basis for inventing a company size for the unsized helicopter symbol.

**A separate revision-51 inconsistency remains:** South Africa's TCC field rises to 1,100, making the sum of known TCC values 2,350, while the total remains 2,200, the unit fields remain two battalions and six companies, and the comments still call helicopter support unsized. The source map and unit arithmetic support 2,200 as the sized component, but the reason for the inconsistent TCC field has not been established. Do not silently rewrite the retained provider row or describe its complete internal consistency as resolved.

## Bukavu revision 49: identify the FPU subtraction inconsistency

The February map shows two sized Chinese support companies and an Egyptian FPU company. The provider row has three companies and `no.troops = 450`; its TCC fields allocate 300 to China and 150 to Egypt. It also includes troop type 12 (FPU), but has `fpu.no = 0`. Its comments explicitly mark the Bangladesh MP as unsized. Thus the earlier conjecture that the extra 150 represented MP coding is not supported.

The historical codebook states that FPU strength is included in total troop strength and separately recorded. Applying this project's military-only definition to the mapped Egyptian FPU gives **450 − 150 = 300**. Revisions 50 and 51 already record `fpu.no = 150` with the same total and are useful consistency checks, not substitutes for the February source. The decision resolves the military-component inconsistency, without claiming known actual MP personnel or a corrected provider release.

## Rwindi and Nyamilima: retain the source-map assignments

On all three 2023 maps, the Indian two-bar infantry symbol connects to the western point, and the Moroccan one-bar symbol connects to the eastern point. Independent geographic investigation identifies Rwindi with the western location and Nyamilima with the eastern location. Accordingly, the adjudicated map components are **Rwindi 650** and **Nyamilima 150**, while current source coding assigns the reverse values. The six decisions concern map-site assignment; the original provider's reason for the reversal is unknown.

The geographic adjudication must accompany these decisions: the current Nyamilima coordinate does not join the research locality set. Merely swapping values without correcting and documenting its location would not yield a complete locality subtotal. The companion geography and subtotal audits record the independently supported geographic candidate and the effect of separate and combined changes; no frozen panel is changed by this table.

## Evidence and limits

The three originals are page 18 of [S/2023/208](https://digitallibrary.un.org/record/4007100/files/S_2023_208-EN.pdf), [S/2023/451](https://digitallibrary.un.org/record/4013932/files/S_2023_451-EN.pdf) and [S/2023/691](https://digitallibrary.un.org/record/4022183/files/S_2023_691-EN.pdf). The retained [version 2.0 codebook](https://www.uu.se/download/18.3f2acc1b18f157bd287131/1714053575165/Codebook-v-2-0.pdf), pages 4–8, supplies the unit conversions, FPU inclusion and support-unit rules. The codebook itself predates the forecast cutoff, while the inspected 2.3 coding is a retrospective comparison.

Original PDF pages were rendered at 300 dpi with Poppler and inspected in enlarged crops. Python was used only for PDF text extraction and image cropping because those tools provide suitable inspection support; numerical checks use R. Inspection copies and detailed source rows remain private under `outputs/deployment_symbol_adjudication/`; they are derived aids, not new primary evidence.

These are unblinded agent adjudications. They do not constitute independent human review, which remains skipped at the user's direction. Unknown actual personnel, the revision-51 TCC inconsistency, other unresolved map sites, historical release availability and September outcome information remain separate limitations. No empirical model, original analysis panel or historical transcription was overwritten.
