$ErrorActionPreference = "Stop"

$GitHubUser = "enricm93-cmyk"
$RepoName = "GYMBROS"
$PageName = "CALCULADORA.html"

$gitExe = $null
if (Test-Path "C:\Program Files\Git\cmd\git.exe") {
    $gitExe = "C:\Program Files\Git\cmd\git.exe"
} elseif (Get-Command git -ErrorAction SilentlyContinue) {
    $gitExe = (Get-Command git).Source
} else {
    Write-Host "Git no está instalado o no está en PATH." -ForegroundColor Red
    Write-Host "Instálalo desde: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$indexPath = Join-Path $scriptDir "index.html"
$pagePath = Join-Path $scriptDir $PageName

if (-not (Test-Path $indexPath)) {
    Write-Host "No existe index.html en la carpeta del proyecto." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $pagePath)) {
    Copy-Item $indexPath $pagePath
    Write-Host "Se ha copiado index.html como $PageName" -ForegroundColor Green
}

$repoUrl = "https://github.com/$GitHubUser/$RepoName.git"

& $gitExe config --global user.name $GitHubUser
& $gitExe config --global user.email "$GitHubUser@users.noreply.github.com"

if (-not (Test-Path ".git")) {
    & $gitExe init | Out-Null
}

& $gitExe add .
& $gitExe status --short

try {
    & $gitExe commit -m "Primer commit" 2>$null
} catch {
    Write-Host "No había cambios nuevos para confirmar." -ForegroundColor Yellow
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "No había cambios nuevos para confirmar." -ForegroundColor Yellow
}

& $gitExe branch -M main

$existingRemote = (& $gitExe remote get-url origin 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($existingRemote)) {
    & $gitExe remote add origin $repoUrl
} else {
    & $gitExe remote set-url origin $repoUrl
}

Write-Host "" 
Write-Host "Subiendo a GitHub..." -ForegroundColor Green
& $gitExe push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "" 
    Write-Host "Hubo un problema con el push. Revisa que el repositorio exista en GitHub y vuelve a ejecutarlo." -ForegroundColor Red
    exit 1
}

Write-Host "" 
Write-Host "Publicado correctamente." -ForegroundColor Green
Write-Host "Repositorio: $repoUrl" -ForegroundColor Cyan
Write-Host "URL principal: https://$GitHubUser.github.io/$RepoName/" -ForegroundColor Cyan
Write-Host "URL calculadora: https://$GitHubUser.github.io/$RepoName/$PageName" -ForegroundColor Cyan
