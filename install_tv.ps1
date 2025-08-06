# install_tv.ps1: set up TV app on Windows
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $RepoDir '.venv'
$TvRepo  = 'https://github.com/TheZedxD/codexTest.git'
$TvDir   = Join-Path $RepoDir 'tv'

Write-Host 'Checking dependencies...' -ForegroundColor Green
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git is required but was not found in PATH.'
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error 'Python 3 is required but was not found in PATH.'
}

if (Test-Path $TvDir) { Remove-Item -Recurse -Force $TvDir }

git clone $TvRepo $TvDir

python -m venv $VenvDir
$VenvPython = Join-Path $VenvDir 'Scripts\python.exe'
& $VenvPython -m pip install --upgrade pip
& $VenvPython -m pip install pyqt5 yt-dlp ffmpeg-python flask
if (Test-Path (Join-Path $TvDir 'requirements.txt')) {
    & $VenvPython -m pip install -r (Join-Path $TvDir 'requirements.txt')
}

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Warning 'FFmpeg was not detected in PATH. Video playback may not work.'
}

$Shell = New-Object -ComObject WScript.Shell
$ShortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'TVPlayer.lnk'
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $VenvPython
$entry = @('app.py','main.py','tv.py') | ForEach-Object {
    $p = Join-Path $TvDir $_
    if (Test-Path $p) { $p }
}
if (-not $entry) { $entry = Join-Path $TvDir 'app.py' }
$Shortcut.Arguments = $entry
$icon = Join-Path $TvDir 'logo.png'
if (Test-Path $icon) { $Shortcut.IconLocation = $icon }
$Shortcut.Save()

Write-Host 'TV application environment ready. Use the TVPlayer shortcut on your Desktop to launch.' -ForegroundColor Green
