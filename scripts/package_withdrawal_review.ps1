# Assemble a self-contained, small review packet without raw GED redistribution.
# Existing analysis outputs are copied, never removed or modified by packaging.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$packetFolder = Join-Path $projectRoot 'portfolio/withdrawal_review_20261112'
New-Item -ItemType Directory -Force -Path $packetFolder | Out-Null
$copies = @{
    'docs/withdrawal_followup_review.md' = 'review_brief.md'
    'data/withdrawal_feasibility/closure_phase_review_2017.csv' = 'closure_phase_review_2017.csv'
    'docs/withdrawal_records_request_specifications.txt' = 'external_records_request_specifications.txt'
}
foreach ($entry in $copies.GetEnumerator()) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $entry.Key) -Destination (Join-Path $packetFolder $entry.Value) -Force
}
Get-ChildItem -LiteralPath (Join-Path $projectRoot 'outputs/withdrawal_review') -File |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $packetFolder -Force }
@'
MONUSCO WITHDRAWAL REVIEW - 12 NOVEMBER 2026

Start with review_brief.txt (about five minutes), then open luhanga_boundary_review.png.
The Markdown copy has clickable source links in compatible viewers.

Please respond to the three items in review_decisions.csv, or simply send your
answers in chat. You do NOT need to adjudicate 85 incidents individually.

1. Geography: review the recommended handling of the Luhanga discrepancy.
2. Scope: review the descriptive framing for the class project.
3. Records: share any patrol/monitoring replies you have received.

The July closure-date correction is already documented; it is not a request to
choose a date based on results. No primary outcome data have been overwritten.
The Luhanga scenario uses historical broad-envelope windows solely to isolate
geographic reassignment. The closure comparison table distinguishes July from
the unsupported October report-date anchor. Do not combine those as effect estimates.

Supporting files:
- closure_phase_review_2017.csv: dates, evidence status and source links.
- closure_vs_report_date_comparison.csv: existing counts with corrected labels.
- luhanga_reassignment_scenario.csv: same total deaths, alternative assignment.
- geography_review_all_conflicts.csv: consistent 85-record diagnostic queue.
- all_boundary_assignments.csv: results across five saved boundary layers.
- acceptance_checks.csv: four automated checks, all passed.
- external_records_request_specifications.txt: records still needed, not proof of sending.
- session_info.txt: R software environment.
- file_manifest.csv: SHA256 checksums of the packaged files.

No manuscript or PowerPoint was changed. No email was sent. No causal model was
fitted. Full regeneration uses scripts/audit_withdrawal_geography_review.R in
the project and its existing GED/boundary inputs; this ZIP is a review packet.
'@ | Set-Content (Join-Path $packetFolder 'START_HERE.txt') -Encoding utf8
@'
item,recommendation,your_decision,your_comments
geographic_assignment,"Retain original reproducible point coding and named Luhanga sensitivity; seek source clarification before changing primary assignment under a consistent rule",,
class_project_scope,"Use descriptive fixed-base closure and continued mobile-coverage framing; do not claim causal withdrawal effects",,
external_records,"Share any replies or dated patrol and monitoring-coverage records already received; unknown coverage stays unknown",,
'@ | Set-Content (Join-Path $packetFolder 'review_decisions.csv') -Encoding utf8
Copy-Item -LiteralPath (Join-Path $packetFolder 'review_brief.md') -Destination (Join-Path $packetFolder 'review_brief.txt') -Force
# Hash all payload files. The manifest itself is excluded to avoid circularity.
Get-ChildItem -LiteralPath $packetFolder -File | Where-Object Name -ne 'file_manifest.csv' |
    ForEach-Object { [pscustomobject]@{file=$_.Name;bytes=$_.Length;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash} } |
    Export-Csv -LiteralPath (Join-Path $packetFolder 'file_manifest.csv') -NoTypeInformation -Encoding utf8
$archivePath = "$packetFolder.zip"
Compress-Archive -Path (Join-Path $packetFolder '*') -DestinationPath $archivePath -Force
# Read every ZIP entry and verify its bytes against the delivered folder.
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    foreach ($entry in $archive.Entries) {
        $stream = $entry.Open()
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        try { $entryHash = [BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-','') }
        finally { $stream.Dispose(); $hasher.Dispose() }
        $expected = (Get-FileHash -LiteralPath (Join-Path $packetFolder $entry.FullName) -Algorithm SHA256).Hash
        if ($entryHash -ne $expected) { throw "ZIP checksum mismatch: $($entry.FullName)" }
    }
    Write-Output "Verified $($archive.Entries.Count) ZIP entries: $archivePath"
} finally { $archive.Dispose() }
