# Revision 46 catalogue timing

The current [UN catalogue export](https://digitallibrary.un.org/record/3988906/export/xm), retrieved 7 November 2026, records `220928` at MARC 008/00–05: **28 September 2022**. Under the [Library of Congress definition](https://www.loc.gov/marc/bibliographic/bd008a.html), this is the bibliographic record's creation date. It provides stronger evidence of a pre-cutoff catalogue record than the PDF's creation metadata alone.

It is not an archived 2022 catalogue response or proof of when the PDF became publicly downloadable. Field 005 reports a later transaction in December 2025; the present PDF link cannot automatically be attributed to the original catalogue state. The exact first public release and historical identity of the attached bytes remain unverified.

The catalogue also contains conflicting descriptive dates: its title and publication field identify August 2022, while field 269 contains June 2022. The map itself is labelled August. Preserve this discrepancy rather than using June as a release date. The existing conditional-availability designation remains unchanged.

The source manifest fingerprints the current XML and the field-definition page. `scripts/audit_deployment_release_catalog.R` verifies those inputs and regenerates the public audit row. This evidence does not supply missing deployment strengths or license a historical forecast claim.
