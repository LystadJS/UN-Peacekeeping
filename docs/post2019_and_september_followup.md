# Post-2019 deployment and September reporting follow-up

Completed 2026-11-07 for the unchanged **1 October 2023, 00:00 UTC** forecast cutoff. The archived deployment prefix is longer and selected later map components can now be reconstructed. **A complete historical forecast information set is still unavailable.** The panel, empirical fits, memo's numerical findings and forecast origin are unchanged.

## What the deployment archive adds

A pinned provider dashboard copy of Geo-PKO 2.1 recovers numeric deployment coding through December 2020. Its June 2021 Git commit and matching blob support pre-cutoff availability of those bytes; it is a dashboard transformation, not a newly recovered original workbook. Missing deployments remain unknown. [Source, coding and reconstruction details](post2019_deployment_reconstruction.md)

| Coverage measure | Earlier 2.0 reconstruction | Extended 2.1 reconstruction |
|---|---:|---:|
| Known first-lag locality-quarters | 164 | 208 |
| Complete joint event/deployment training rows, of 570 | 162 | 204 |
| Joint rows in the current nine-locality sample | 153 | 189 |
| Joint rows outside that sample | 9 | 15 |
| Latest archived deployment month | December 2019 | December 2020 |
| Latest available first-lag outcome quarter | 2020 Q1 | 2021 Q1 |

All 164 shared first-lag values are unchanged between the two archived reconstructions. Of 208 extended values, 206 match the current panel and two differ: Masisi and Irumu including Bunia in 2021 Q1. The differences trace to December 2020 Sake and Bunia source coding. The original archived values are preserved, rather than replaced by current values. A second lag may extend through 2021 Q2, but this does not supply that quarter's missing first lag or a complete model row. Full-window deployment centering remains unavailable. [Joint coverage](../data/post2019_deployment_joint_coverage.csv)

The [map supplement](post2019_map_coding.md) covers nine 2021–2022 revisions at ten selected sites, plus two December 2020 discrepancy checks: **92 reviewed rows, 90 numerical components, two unnamed Eringeti observations left unknown, and 14 rows with unsized military units**. The numerical sized military/FPU components match current source-map coding. Sake's sized component is 300 and Bunia's 1,900, but both contain unsized military police; these are not verified full personnel totals. Agent readings were unblinded and are not independent human verification.

Revision 45.1 says May 2022 in its title and June in its footer; current Geo-PKO assigns May. The June report's production date does not justify historical availability in May. Revision 46 has a September 2022 PDF creation date but no verified first public posting. Selected site components do not establish complete administrative-area strengths or verified absence. No new monthly interpolation or extrapolation was performed.

## What September reporting can establish

Archived official download pages still advertise August on 6 October 2023 and advertise September on 30 October. These observations establish advertisement **by 30 October**, not the exact first release or proof that an alternative route was unavailable earlier. No contemporaneous September coded snapshot before the cutoff was recovered. [September investigation](september_2023_availability.md)

Seven of 23 eligible September Candidate records across the 19 localities have at least one listed source before the cutoff; five are in the current nine-locality sample. Two publisher copies corroborate dated earlier reporting, while remaining current copies rather than archived contemporaneous bytes. Those seven records are selected using later coded data: they are neither a complete historical count nor a defensible bound on one. **Do not add seven to the 62 July–August events.** The 62 remain a partial-quarter count; certified September totals and complete Q3/Q4 event-history predictors remain missing.

## Reproduction and remaining decision

The new R stages are `audit_september_2023.R`, `reconstruct_post2019_deployment.R` and `audit_post2019_map_coding.R` and `assemble_post2019_training.R`, following their documented prior stages. Static manifests and map readings are inputs; downloaded originals and detailed reconstructed histories remain ignored/private. Generated public summaries retain source-vintage differences and unresolved observations. See the [runbook](quarterly_runbook.md) and [clean-run instructions](clean_rebuild_runbook.md). These additive checks do not imply another full fitting run or a newly validated forecast.

Four new stages, including joint-history assembly, and the new checks ran in the retained isolated project. **Twelve generated public tables and nine private tables matched exactly; 21 input hashes per project, the historical Git blob and all 18 frozen analysis files were verified.** The [validation receipt](../data/post2019_followup_checks.json) records the additive scope. This was not a full model or estimation rerun.

The next evidentiary requirements are a contemporaneous September coded information snapshot, complete later unit/location histories with defensible availability dates, and historically available geography. Absence certification remains unresolved. No model refit, forecast-performance claim, new sample inclusion rule or operational deployment recommendation follows from this supplement. Human review remains **skipped at the user's request, not completed**.
