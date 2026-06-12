# First-time project setup on Windows
# Requires Flutter SDK: https://docs.flutter.dev/get-started/install/windows

Write-Host "Checking Flutter..." -ForegroundColor Cyan
flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter not found. Install SDK and add to PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Generating ios and android folders..." -ForegroundColor Cyan
flutter create . --org com.goalpath --project-name goal_path --platforms=ios,android,web

Write-Host "Installing packages..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "Done. Test UI in browser:" -ForegroundColor Green
Write-Host "  flutter run -d chrome"
Write-Host ""
Write-Host "IPA build: use Codemagic. See BUILD.md" -ForegroundColor Green
