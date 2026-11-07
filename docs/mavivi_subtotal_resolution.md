# Mavivi subtotal: analysis resolution and retained uncertainty

Completed 7 November 2026. **The source-consistent analysis decision is a South African sized subtotal of 950 and a total sized military component of 2,200 on revision 51.** This reconciles the mapped units and the aggregate coding. The original provider field of 1,100 remains preserved, and the cause of that field's discrepancy is not verified. No provider-confirmed amendment or actual troop headcount is claimed.

## What the additional audit establishes

The [original August 2023 map, S/2023/691 page 18](https://digitallibrary.un.org/record/4022183/files/S_2023_691-EN.pdf), shows one South African infantry battalion, one South African QRF company and one South African TIU company at Mavivi. The helicopter-support symbol has no size bar. This was inspected again in the enlarged original-page rendering. Under the retained [historical unit-size conventions](https://www.uu.se/download/18.3f2acc1b18f157bd287131/1714053575165/Codebook-v-2-0.pdf), those sized units imply 650 + 150 + 150 = **950**. Assigning a further 150 to the unsized helicopter symbol would add an unsupported company. Bangladeshi military police also remain unsized; their actual personnel are not assumed to be zero.

The provider's other known country components sum to **1,250**: Tanzania 800, and Indonesia, Kenya and Nepal 150 each. Thus 950 + 1,250 = **2,200**, agreeing with the provider's total and its two-battalion/six-company fields. The inconsistent revision-51 South African value of 1,100 is the sole source of the 2,350 known-contributor sum.

The new [transition audit](../data/mavivi_subtotal_transition_audit.csv) checks every Mavivi source row from revision 48 through 57, November 2022–November 2024. All ten rows have total 2,200, two battalions, six companies and comments identifying helicopter support as unsized. The other nine rows—including the immediately preceding and following revisions—record South Africa as 950. Only revision 51 records 1,100. This localizes the inconsistency to a single contributor field rather than a documented aggregate force change.

These adjacent rows are corroboration, not the controlling basis for reconstructing August. In particular, November 2023 and 2024 rows are after the forecast cutoff, and the entire inspected release is retrospective. Their agreement does not authenticate information available on 1 October 2023. The audit marks which reference months are after that date.

## Resolution for sensitivity analysis

The [machine-readable decision](../data/mavivi_subtotal_adjudication.csv) records both the retained provider values and the local analysis choice:

| Quantity | Source-consistent analysis | Retained alternative |
|---|---:|---:|
| South African sized component, revision 51 | 950 | Original field 1,100 |
| Total sized military component, revision 51 | 2,200 | Known contributor sum 2,350 |

The primary corrected-panel sensitivity should keep 2,200. It therefore makes no primary aggregate Mavivi adjustment beyond correcting our earlier interpretation. A separate sensitivity can substitute 2,350 **only for revision 51**, carrying its effect through the declared monthly-to-quarterly construction, lags and centering. This is a measurement stress scenario, not a second equally established troop total or a confidence interval for actual staffing. It must not add 150 to every Mavivi map or confuse the unknown-sized units with known zero personnel.

The decision resolves how to use the inconsistent source for this analysis. It does not establish whether the original value arose from transcription, an undocumented rule or another cause; that causal history remains unverified. Provider bytes and earlier audit tables are not overwritten. The original panel and fit are not changed by this audit script.

## Reproduction

Run `scripts/resolve_mavivi_subtotal.R`. Static [source provenance](../data/mavivi_subtotal_sources.csv) fingerprints three retained originals: the provider map-level RDS, the version-2.0 codebook and the August 2023 UN report. The script verifies their hashes, reads the ten transition rows, reconstructs all known contributor sums, checks the single-field discrepancy, and regenerates the two public tables. Detailed source rows remain private under `outputs/mavivi_subtotal_resolution/`.

The enlarged map reading remains an unblinded agent adjudication. Numerical checks support its arithmetic and internal consistency; they are not human review or independent evidence of actual staffing. Human review remains skipped at the user's direction, not completed.
