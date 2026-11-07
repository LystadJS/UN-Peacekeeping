# Typeset the final portfolio only after its scientific figure inputs exist.
# This uses the recorded Windows document runtime; it does not fit any model.
param(
    [string]$RuntimeRoot = 'C:/Program Files/WindowsApps/OpenAI.CodexPrimaryRuntime.v26-1104-2876-0_26.1104.2876.0_x64__3k8sg7r9htsxt/dependencies'
)
$ErrorActionPreference = 'Stop'
$python = Join-Path $RuntimeRoot 'python/python.exe'
$node = Join-Path $RuntimeRoot 'node/bin/node.exe'
$poppler = Join-Path $RuntimeRoot 'native/poppler/Library/bin/pdftoppm.exe'
$env:RUNTIME_NODE_MODULES = Join-Path $RuntimeRoot 'node/node_modules'
foreach ($tool in @($python,$node,$poppler)) {
    if (-not (Test-Path -LiteralPath $tool)) { throw "Recorded artifact runtime unavailable: $tool" }
}
New-Item -ItemType Directory -Path 'outputs/portfolio_memo' -Force | Out-Null
& $python scripts/build_research_memo.py
if ($LASTEXITCODE -ne 0) { throw 'Memo build failed.' }
& $poppler -png -r 125 portfolio/research_memo.pdf outputs/portfolio_memo/page
if ($LASTEXITCODE -ne 0) { throw 'Memo rendering failed.' }
& $node scripts/build_discussion_deck.mjs
if ($LASTEXITCODE -ne 0) { throw 'Deck build/finalization failed.' }
& $python scripts/check_portfolio_artifacts.py
if ($LASTEXITCODE -ne 0) { throw 'Portfolio structural/hash checks failed.' }
# Versions and font bytes supplement, but do not imply portability beyond this
# runtime. Native PowerPoint and independent human review remain outstanding.
$versions = & $python -c 'import json,sys,reportlab,pypdf; print(json.dumps(dict(python=sys.version,reportlab=reportlab.Version,pypdf=pypdf.__version__)))'
$package = Get-Content -LiteralPath (Join-Path $RuntimeRoot 'node/node_modules/@oai/artifact-tool/package.json') -Raw | ConvertFrom-Json
$fonts = foreach ($name in @('calibri.ttf','calibrib.ttf','calibrii.ttf','calibriz.ttf','arial.ttf')) {
    $path = Join-Path 'C:/Windows/Fonts' $name
    [ordered]@{file=$name; sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()}
}
$receipt = [ordered]@{
    runtime_root=$RuntimeRoot
    python=($versions | ConvertFrom-Json)
    node=(& $node --version)
    artifact_tool=$package.version
    figure_png_device='grDevices::png(type="cairo-png")'
    fonts=$fonts
    human_review=$false
    native_powerpoint_tested=$false
}
$receipt | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath 'outputs/portfolio_memo/artifact_runtime.json' -Encoding utf8
Write-Output 'Portfolio artifacts rebuilt. Inspect the rendered pages and slides before publication.'
