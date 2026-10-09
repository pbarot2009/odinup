$ErrorActionPreference = "Stop"

# Helper for formatted output
function Write-Color([string]$Text, [ConsoleColor]$Color, [switch]$NoNewline) {
    if ($NoNewline) { Write-Host $Text -ForegroundColor $Color -NoNewline }
    else { Write-Host $Text -ForegroundColor $Color }
}

Write-Color "🚀 OdinUP Installer" -Color Cyan
Write-Color "The Native Odin Version Manager`n" -Color DarkGray

# 1. System Profiling
$Arch = if ($env:PROCESSOR_ARCHITECTURE -match "ARM") { "arm64" } else { "amd64" }
$Target = "odinup-windows-$Arch.zip"
Write-Host "🔎 Detected System: " -NoNewline; Write-Color "windows-$Arch" -Color Cyan

# 2. Interrogate GitHub API
Write-Host "🌐 Querying GitHub for latest release..."
$ApiUrl = "https://api.github.com/repos/pbarot2009/odinup/releases/latest"
try {
    $Release = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing
} catch {
    Write-Color "✖ Error: Failed to fetch latest release from GitHub API." -Color Red
    exit 1
}

$LatestTag = $Release.tag_name
$Asset = $Release.assets | Where-Object { $_.name -eq $Target }

if (-not $Asset) {
    Write-Color "✖ Error: Could not find a release asset for $Target." -Color Red
    exit 1
}

# 3. State Check & Version Comparison
$OdinupHome = if ($env:ODINUP_HOME) { $env:ODINUP_HOME } else { "$env:USERPROFILE\.odinup" }
$BinDir = "$OdinupHome\bin"
$VersionFile = "$OdinupHome\.version"
$Updating = $false

if (Test-Path "$BinDir\odinup.exe") {
    $LocalVersion = "unknown"
    if (Test-Path $VersionFile) { $LocalVersion = Get-Content $VersionFile -Raw }

    if ($LocalVersion.Trim() -eq $LatestTag) {
        Write-Color "`n✔ You already have the latest version of OdinUP ($LatestTag)." -Color Green
        Write-Host "Aborting installation."
        exit 0
    } else {
        Write-Color "`n✨ A new version of OdinUP is available!" -Color Yellow
        Write-Host "Current: " -NoNewline; Write-Color "$LocalVersion" -Color Red -NoNewline
        Write-Host " -> Latest: " -NoNewline; Write-Color "$LatestTag" -Color Green

        $Choice = Read-Host "Do you want to update now? [y/N]"
        if ($Choice -match "^[yY]") {
            Write-Color "`nProceeding with update..." -Color Cyan
            $Updating = $true
        } else {
            Write-Host "Update aborted."
            exit 0
        }
    }
} else {
    Write-Host "Target Version: " -NoNewline; Write-Color $LatestTag -Color Green
}

# 4. Download & Extraction
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "odinup_install_$([guid]::NewGuid().ToString().Substring(0,8))"  # Fix 1: wrapped GetTempPath() in parens
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null
Set-Location $TmpDir

Write-Host "📦 Downloading $Target..."
Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile "odinup.zip"

Write-Host "📂 Extracting archive..."
Expand-Archive -Path "odinup.zip" -DestinationPath . -Force

# 5. Binary Placement & State Update
if (-not (Test-Path $BinDir)) { New-Item -ItemType Directory -Force -Path $BinDir | Out-Null }
Move-Item -Path "odinup.exe" -Destination "$BinDir\odinup.exe" -Force
Set-Content -Path $VersionFile -Value $LatestTag

# 6. Persistent PATH Injection (Skipped if updating)
if (-not $Updating) {
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($UserPath -notmatch [regex]::Escape($BinDir)) {
        $NewPath = "$BinDir;$UserPath"
        [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
        $env:PATH = "$BinDir;$env:PATH"
        Write-Color "✔ Permanently added OdinUP to Windows User PATH" -Color Green
    } else {
        Write-Color "✔ OdinUP is already configured in Windows User PATH" -Color Green
    }
}

# 7. Cleanup
Set-Location $env:USERPROFILE
Remove-Item -Recurse -Force $TmpDir

Write-Host "`n✨ " -NoNewline
Write-Color "OdinUP $LatestTag successfully installed!" -Color Green
Write-Host "Type " -NoNewline; Write-Color "odinup help" -Color Cyan -NoNewline; Write-Host " to get started."