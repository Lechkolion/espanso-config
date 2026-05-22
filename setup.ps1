# Espanso setup script - run once on a new machine
# Usage: irm https://raw.githubusercontent.com/Lechkolion/espanso-config/master/setup.ps1 | iex

$repoUrl = "https://github.com/Lechkolion/espanso-config.git"
$configDir = "$env:USERPROFILE\espanso-config"
$espansoLink = "$env:APPDATA\espanso"

# 1. Install Espanso if missing
if (-not (Get-Command espanso -ErrorAction SilentlyContinue) -and
    -not (Test-Path "$env:LOCALAPPDATA\Programs\Espanso\espanso.cmd")) {
    Write-Host "Installing Espanso..." -ForegroundColor Cyan
    winget install --id=Espanso.Espanso -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Espanso already installed." -ForegroundColor Green
}

# 2. Clone or pull the config repo
if (Test-Path "$configDir\.git") {
    Write-Host "Pulling latest config..." -ForegroundColor Cyan
    git -C $configDir pull
} else {
    Write-Host "Cloning config repo..." -ForegroundColor Cyan
    git clone $repoUrl $configDir
}

# 3. Create junction if not already pointing to our repo
$existing = Get-Item $espansoLink -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -eq "Junction" -and $existing.Target -eq $configDir) {
    Write-Host "Junction already correct." -ForegroundColor Green
} else {
    if (Test-Path $espansoLink) {
        Write-Host "Removing existing espanso config dir..." -ForegroundColor Yellow
        Remove-Item $espansoLink -Recurse -Force
    }
    cmd /c "mklink /J `"$espansoLink`" `"$configDir`"" | Out-Null
    Write-Host "Junction created." -ForegroundColor Green
}

Write-Host "`nDone. Espanso is reading config from $configDir" -ForegroundColor Green
