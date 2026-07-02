# Сравни подпись APK с keystore (для RuStore / обновлений).
param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [string]$KeystorePath,
    [string]$KeystorePassword,
    [string]$KeyAlias = "upload"
)

$ErrorActionPreference = "Stop"
$buildTools = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending | Select-Object -First 1

if (-not $buildTools) {
    Write-Host "Android SDK build-tools не найден. Установи Android Studio или SDK." -ForegroundColor Red
    exit 1
}

$apksigner = Join-Path $buildTools.FullName "apksigner.bat"
if (-not (Test-Path $apksigner)) {
    Write-Host "apksigner не найден: $apksigner" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Подпись APK ===" -ForegroundColor Cyan
& $apksigner verify --print-certs $ApkPath

if ($KeystorePath) {
    Write-Host "`n=== Сертификат keystore ===" -ForegroundColor Cyan
    if (-not $KeystorePassword) {
        $KeystorePassword = Read-Host "Пароль keystore" -AsSecureString
        $KeystorePassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeystorePassword))
    }
    keytool -list -v -keystore $KeystorePath -alias $KeyAlias -storepass $KeystorePassword |
        Select-String "SHA1:|SHA-256:"
    Write-Host "`nSHA1 и SHA-256 должны совпадать с APK выше." -ForegroundColor Yellow
}
