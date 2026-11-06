# Exercise the actual supervisor completion functions without running science.
$ErrorActionPreference = 'Stop'
$workflow = Join-Path (Get-Location) 'scripts/run_clean_workflow.ps1'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($workflow, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw "Supervisor parser errors: $parseErrors" }
foreach ($name in @('Complete-RStage', 'Complete-RBatch')) {
    $definition = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
        Where-Object Name -EQ $name
    if (@($definition).Count -ne 1) { throw "Expected one actual function: $name" }
    # Only these extracted function definitions are evaluated; workflow body is not.
    . ([scriptblock]::Create($definition.Extent.Text))
}
$runRoot = Join-Path (Get-Location) ('outputs/supervisor_test_' + [guid]::NewGuid().ToString('N'))
$logDirectory = $runRoot
New-Item -ItemType Directory -Path $runRoot | Out-Null
$ledger = [System.Collections.Generic.List[object]]::new()
$shell = (Get-Process -Id $PID).Path
$marker = Join-Path $runRoot 'sibling_finished.txt'
$jobs = @()
$commands = @('exit 7', "Start-Sleep -Milliseconds 800; [IO.File]::WriteAllText('$($marker.Replace("'", "''"))', 'finished'); exit 0")
for ($index = 0; $index -lt 2; $index++) {
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($commands[$index]))
    $started = [DateTime]::UtcNow
    $process = Start-Process -FilePath $shell -ArgumentList @('-NoProfile', '-EncodedCommand', $encoded) `
        -WindowStyle Hidden -PassThru
    $jobs += [pscustomobject]@{script="fixture_$index"; process=$process; started=$started}
}
$failure = $null
try { Complete-RBatch $jobs } catch { $failure = $_.Exception.Message }
if ($null -eq $failure -or $failure -notmatch 'Parallel stages failed: fixture_0') { throw 'Expected deferred batch failure was not reported.' }
if (-not (Test-Path -LiteralPath $marker)) { throw 'Sibling had not completed before batch threw.' }
if (@($jobs | Where-Object { -not $_.process.HasExited }).Count) { throw 'A sibling process was left running.' }
if ($ledger.Count -ne 2 -or $ledger[0].exit_code -ne 7 -or $ledger[1].exit_code -ne 0) { throw 'Both final exit statuses were not recorded.' }
$saved = @(Import-Csv -LiteralPath (Join-Path $runRoot 'stage_execution.csv'))
if ($saved.Count -ne 2) { throw 'Persisted ledger omitted a sibling.' }
Write-Output 'PASS: actual supervisor parsed, waited for sibling, persisted both exits, then threw for failed job.'
