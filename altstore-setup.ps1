# AltServer setup helper for Windows
# Run: right-click -> Run with PowerShell (as Administrator)

Write-Host "=== AltServer Setup Check ===" -ForegroundColor Cyan

$appleX86 = "C:\Program Files (x86)\Common Files\Apple"
$appleAlt = "C:\AppleAltStore"
$itunesExe = "C:\Program Files\iTunes\iTunes.exe"

function Test-AppleFolder($path) {
    $aas = Join-Path $path "Apple Application Support"
    $is = Join-Path $path "Internet Services"
    return (Test-Path $aas) -and (Test-Path $is)
}

if (Test-Path $itunesExe) {
    Write-Host "[OK] iTunes from Apple: $itunesExe" -ForegroundColor Green
} else {
    Write-Host "[!!] iTunes not found. Install from https://www.apple.com/itunes/download/win64" -ForegroundColor Red
}

if (Test-AppleFolder $appleX86) {
    Write-Host "[OK] Apple folder: $appleX86" -ForegroundColor Green
} else {
    Write-Host "[!!] Apple folder incomplete at $appleX86" -ForegroundColor Red
}

if (-not (Test-AppleFolder $appleAlt)) {
    Write-Host "Creating $appleAlt ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $appleAlt | Out-Null
    foreach ($folder in @("Apple Application Support", "Internet Services")) {
        $from = Join-Path $appleX86 $folder
        $to = Join-Path $appleAlt $folder
        if (Test-Path $from) {
            Copy-Item $from $to -Recurse -Force
        }
    }
}

if (Test-AppleFolder $appleAlt) {
    Write-Host "[OK] AltStore folder ready: $appleAlt" -ForegroundColor Green
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open iTunes once (Wi-Fi sync ON for your iPhone)"
Write-Host "2. Open iCloud once and sign in"
Write-Host "3. Start AltServer AS ADMINISTRATOR"
Write-Host "4. When dialog appears click CHOOSE FOLDER (not Download!)"
Write-Host "5. Select this folder: $appleAlt"
Write-Host ""
Write-Host "Opening folder..." -ForegroundColor Green
explorer.exe $appleAlt
