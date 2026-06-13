# Sync RuStore logo with APK launcher icon (run after flutter_launcher_icons)
$src = Join-Path $PSScriptRoot "..\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
$dst = Join-Path $PSScriptRoot "rustore-logo-512.png"

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path $src))
$bmp = New-Object System.Drawing.Bitmap 512, 512
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, 0, 0, 512, 512)
$g.Dispose()
$img.Dispose()
$bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "OK: $dst ($((Get-Item $dst).Length) bytes)"
