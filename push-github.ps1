# Push Goal Path project to GitHub
# Run from: C:\Programming\пприложение\goal_path

param(
    [string]$RepoUrl = "https://github.com/AddJukey/goal-path.git"
)

Write-Host "=== Goal Path -> GitHub ===" -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    Write-Host "ERROR: Run this script inside goal_path folder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path ".github/workflows/build-ios.yml")) {
    Write-Host "ERROR: Missing .github/workflows/build-ios.yml" -ForegroundColor Red
    exit 1
}

Write-Host "Workflow file OK: .github/workflows/build-ios.yml" -ForegroundColor Green

$currentRemote = git remote get-url origin 2>$null
if ($currentRemote -ne $RepoUrl) {
    Write-Host "Setting remote to: $RepoUrl" -ForegroundColor Yellow
    git remote remove origin 2>$null
    git remote add origin $RepoUrl
}

Write-Host ""
Write-Host "Before push, create repo on GitHub:" -ForegroundColor Yellow
Write-Host "  1. https://github.com/new"
Write-Host "  2. Name: goal-path"
Write-Host "  3. Public (recommended for free Actions minutes)"
Write-Host "  4. Do NOT add README / .gitignore (repo must be empty)"
Write-Host ""

Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "Open Actions:" -ForegroundColor Green
    Write-Host "  https://github.com/AddJukey/goal-path/actions/workflows/build-ios.yml"
    Write-Host ""
    Write-Host "Click: Run workflow -> Run workflow" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Push FAILED. Common fixes:" -ForegroundColor Red
    Write-Host "  - Create empty repo goal-path on GitHub first"
    Write-Host "  - Check username (AddJukey) is correct"
    Write-Host "  - Login: Git Credential Manager will ask for GitHub login"
    Write-Host "  - Or use Personal Access Token as password"
    Write-Host ""
    Write-Host "GitHub token for MCP needs scopes: repo, workflow" -ForegroundColor Yellow
}
