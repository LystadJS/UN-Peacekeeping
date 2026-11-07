# Run the active pilot from verified originals in a new, isolated project.
# PowerShell supervises independent R jobs on Windows; all scientific work is R.
# A prepared project must contain no derived data or cached model outputs.
param(
    [string]$RunDirectory = 'outputs/clean_rebuild_20261106',
    [string]$Rscript = 'C:/Program Files/R/R-4.5.3/bin/Rscript.exe',
    [switch]$Prepared
)
$ErrorActionPreference = 'Stop'
$sourceProject = (Get-Location).Path
$runRoot = [IO.Path]::GetFullPath((Join-Path $sourceProject $RunDirectory))
if (-not $runRoot.StartsWith($sourceProject + [IO.Path]::DirectorySeparatorChar)) {
    throw 'Run directory must be inside the repository.'
}
$cleanProject = Join-Path $runRoot 'project'
$logDirectory = Join-Path $runRoot 'logs'
if (-not $Prepared) {
    if (Test-Path -LiteralPath $runRoot) { throw 'Choose a new run directory; existing runs are never erased.' }
    New-Item -ItemType Directory -Path $cleanProject, $logDirectory | Out-Null
    foreach ($folder in @('scripts','R','tests','config','docs')) {
        Copy-Item -LiteralPath $folder -Destination $cleanProject -Recurse
    }
    New-Item -ItemType Directory -Path (Join-Path $cleanProject 'data'), (Join-Path $cleanProject 'portfolio') | Out-Null
    Copy-Item -LiteralPath 'data/raw' -Destination (Join-Path $cleanProject 'data') -Recurse
    Copy-Item -LiteralPath 'data/source_manifest.csv' -Destination (Join-Path $cleanProject 'data/source_manifest.csv')
    Copy-Item -LiteralPath 'data/quarterly_data_dictionary.csv' -Destination (Join-Path $cleanProject 'data/quarterly_data_dictionary.csv')
    foreach ($file in @('research_memo.md','discussion_outline.md')) {
        Copy-Item -LiteralPath (Join-Path 'portfolio' $file) -Destination (Join-Path $cleanProject 'portfolio')
    }
    & $Rscript --vanilla scripts/prepare_isolated_environment.R $cleanProject
    if ($LASTEXITCODE -ne 0) { throw 'Isolated environment preparation failed.' }
}
if (Test-Path -LiteralPath (Join-Path $cleanProject 'outputs')) { throw 'Prepared project already contains outputs.' }
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
# Refresh code only, before recording inputs or running any scientific stage.
foreach ($folder in @('scripts','R','tests')) {
    Copy-Item -Path (Join-Path $folder '*') -Destination (Join-Path $cleanProject $folder) -Recurse -Force
}
$env:R_LIBS = Join-Path $cleanProject '.local_library'
$env:R_LIBS_USER = $env:R_LIBS
$env:R_LIBS_SITE = $env:R_LIBS
$env:OMP_NUM_THREADS = '1'
$env:OPENBLAS_NUM_THREADS = '1'
$env:REPRODUCE_APPROVED_PROTOCOL = 'quarterly_2016_2023_common_strength'
$ledger = [System.Collections.Generic.List[object]]::new()
function Start-RStage([string]$script) {
    $name = [IO.Path]::GetFileNameWithoutExtension($script)
    $started = [DateTime]::UtcNow
    $process = Start-Process -FilePath $Rscript -ArgumentList @('--vanilla','scripts/run_isolated.R',$script) `
        -WorkingDirectory $cleanProject -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $logDirectory "$name.out.log") `
        -RedirectStandardError (Join-Path $logDirectory "$name.err.log")
    return [pscustomobject]@{script=$script; process=$process; started=$started}
}
function Complete-RStage($job, [switch]$DeferFailure) {
    $job.process.WaitForExit()
    $job.process.Refresh()
    $code = $job.process.ExitCode
    $ledger.Add([pscustomobject]@{stage=$job.script; exit_code=$code; started_utc=$job.started.ToString('o'); seconds=($job.process.ExitTime.ToUniversalTime()-$job.started).TotalSeconds})
    $ledger | Export-Csv -LiteralPath (Join-Path $runRoot 'stage_execution.csv') -NoTypeInformation
    if ($code -ne 0) {
        if ($DeferFailure) { return }
        throw "Stage failed: $($job.script); see $logDirectory"
    }
    Write-Output "Completed $($job.script)"
}
function Run-RStage([string]$script) { Complete-RStage (Start-RStage $script) }
function Complete-RBatch($jobs) {
    # Do not abandon sibling processes if one parallel stage fails. Retain each
    # exit status, wait for all writers to finish, and then report the failure.
    foreach ($job in $jobs) { Complete-RStage $job -DeferFailure }
    $failures = @($jobs | Where-Object { $_.process.ExitCode -ne 0 })
    if ($failures.Count) { throw "Parallel stages failed: $($failures.script -join ', '); see $logDirectory" }
}

# Raw-input entry point refuses copied intermediates and verifies source hashes.
& $Rscript --vanilla scripts/rebuild_original_inputs.R $cleanProject --prepared-project --execute
if ($LASTEXITCODE -ne 0) { throw 'Original-input rebuild failed.' }
Run-RStage 'scripts/check_quarterly_source_records.R'
Run-RStage 'scripts/record_analysis_snapshot.R'
# Empty state: successful flags are reconstructed, never inherited from main.
[IO.File]::WriteAllText((Join-Path $cleanProject 'data/pilot_validation_status.json'), '{}')
Run-RStage 'tests/run_checks.R'
$simulationJobs = @(
    (Start-RStage 'scripts/validate_quarterly_simulation.R'),
    (Start-RStage 'scripts/validate_dynamic_quarterly.R'),
    (Start-RStage 'scripts/validate_dynamic_quarterly_null.R')
)
Complete-RBatch $simulationJobs
Run-RStage 'scripts/archive_simulation_panels.R'
foreach ($script in @('scripts/recheck_simulation_summary.R','scripts/check_dynamic_generated_data.R',
    'scripts/summarize_dynamic_quarterly.R','scripts/update_quarterly_validation_status.R',
    'scripts/plot_dynamic_validation.R','scripts/reaffirm_reproduction_gate.R',
    'scripts/fit_quarterly_empirical.R','scripts/summarize_quarterly_empirical.R',
    'scripts/record_evaluation_inputs.R')) { Run-RStage $script }
$evaluationJobs = @(
    (Start-RStage 'scripts/diagnose_quarterly_models.R'),
    (Start-RStage 'scripts/analyze_quarterly_sensitivity.R'),
    (Start-RStage 'scripts/validate_quarterly_prediction.R')
)
Complete-RBatch $evaluationJobs
foreach ($script in @('tests/run_quarterly_diagnostic_checks.R','scripts/summarize_quarterly_variance.R',
    'tests/run_quarterly_sensitivity_checks.R','tests/run_quarterly_prediction_checks.R',
    'scripts/check_quarterly_evaluation.R','scripts/record_quarterly_evaluation_status.R',
    'scripts/build_portfolio_figures.R','scripts/build_descriptive_panel_figures.R')) { Run-RStage $script }
Push-Location $cleanProject
try {
    & ./scripts/build_portfolio_artifacts.ps1
    if ($LASTEXITCODE -ne 0) { throw 'Artifact rebuild failed.' }
} finally { Pop-Location }
Write-Output 'Scientific and artifact rebuild complete. Compare results and inspect rendered outputs before promotion.'
