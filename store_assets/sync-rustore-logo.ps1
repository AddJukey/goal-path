# Copy launcher icon to RuStore logo (512x512)
$src = Join-Path $PSScriptRoot "..\assets\icon\app_icon.png"
$dst = Join-Path $PSScriptRoot "rustore-logo-512.png"
Copy-Item $src $dst -Force
Write-Host "OK: $dst"
