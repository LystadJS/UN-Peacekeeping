# Deployment absence investigation

The revised pilot does **not** recode unlisted locality-months as zero. The outcome of this investigation is a narrower observation rule, not certification of military absence.

Reviewed original sources: January 2016 map 4412 Rev.18, page 18 of S/2016/233; and November 2023 map 4412 Rev.52. Both were downloaded from UN sources, rendered and visually inspected. Paths, URLs and hashes are in `data/pilot_source_manifest.csv`; observations are in `data/map_review.csv`. This is an endpoint spot check of two maps, not a review of every intervening revision.

The maps distinguish headquarters, formed police and other mission symbols from military units. Troop symbols are visible around several continuously listed bases, including Beni, Goma, Shabunda and Uvira. This supports treating listed positive military estimates as evidence of mapped presence. It does not validate exact unit-size conversion or completeness of all local postings.

No guarantee of exhaustive zero deployment for each unmarked administrative area was identified. In particular, a missing local base symbol cannot establish no patrols, temporary deployments or protection activity. Djugu, Aru and Idjwi remain unlisted/unknown in the source-derived panel, not verified military absences. Map coverage, source omissions and the difference between base location and operational reach remain material limitations.

The quarterly exposure script requires three numeric monthly strength observations per exposure quarter and map age no greater than five months. It retains missing quarters and excludes them from the complete-history simulation design. Nine localities satisfy the full lag-history requirement for 2016–2023; the other ten remain in the coverage ledger. Conditioning on complete listing is a retrospective selection rule, not evidence that missingness is ignorable.

The common slope therefore concerns **changes in listed strength within continuously observed localities**, not protection versus nondeployment. Broadening the population requires an explicit source-map completeness review or an observation model; neither is supplied by the current spot checks. The raw three-source additions remain local, with no data redistribution assumed.
