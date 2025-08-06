# run_tv.ps1: launch TV application on Windows
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $RepoDir '.venv'
$TvDir   = Join-Path $RepoDir 'tv'

$entry = @('app.py','main.py','tv.py') | ForEach-Object {
    $p = Join-Path $TvDir $_
    if (Test-Path $p) { return $_ }
}
if (-not $entry) {
    Write-Error "No entry script found in $TvDir"
    exit 1
}
& (Join-Path $VenvDir 'Scripts\python.exe') (Join-Path $TvDir $entry) $args
