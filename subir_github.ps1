param(
    [string]$GitHubUser = "",
    [string]$RepoName = "GYMBROS",
    [string]$PageName = "CALCULADORA.html"
)

$ErrorActionPreference = "Stop"

if (-not $GitHubUser) {
    Write-Host "" 
    Write-Host "Debes pasar tu usuario de GitHub:" -ForegroundColor Yellow
    Write-Host "Ejemplo: .\subir_github.ps1 -GitHubUser tuusuario" -ForegroundColor Cyan
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git no está instalado o no está en PATH." -ForegroundColor Red
    Write-Host "Instálalo desde: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$indexPath = Join-Path $scriptDir "index.html"
$pagePath = Join-Path $scriptDir $PageName

if (-not (Test-Path $pagePath)) {
    if (Test-Path $indexPath) {
        Copy-Item $indexPath $pagePath
        Write-Host "Se ha copiado index.html como $PageName" -ForegroundColor Green
    }
    else {
        Write-Host "No se encontró index.html ni $PageName. Revisa la carpeta del proyecto." -ForegroundColor Red
        exit 1
    }
}

$repoUrl = "https://github.com/$GitHubUser/$RepoName.git"

if (-not (Test-Path ".git")) {
    git init | Out-Null
}

git add .
git commit -m "Primer commit" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "No había cambios nuevos para confirmar o Git no está configurado." -ForegroundColor Yellow
}

git branch -M main

$existingRemote = git remote get-url origin 2>$null
if (-not $existingRemote) {
    git remote add origin $repoUrl
} else {
    git remote set-url origin $repoUrl
}

Write-Host "" 
Write-Host "Repositorio listo para subir:" -ForegroundColor Green
Write-Host $repoUrl -ForegroundColor Cyan
Write-Host "" 
Write-Host "Ahora ejecuta este comando manualmente si GitHub te pide iniciar sesión:" -ForegroundColor Yellow
Write-Host "git push -u origin main" -ForegroundColor Cyan
Write-Host "" 
Write-Host "Cuando esté publicado, la URL será:" -ForegroundColor Green
Write-Host "https://$GitHubUser.github.io/$RepoName/$PageName" -ForegroundColor Cyan
Write-Host "" 
Write-Host "Si quieres la página principal en la raíz, usa index.html y la URL será:" -ForegroundColor Yellow
Write-Host "https://$GitHubUser.github.io/$RepoName/" -ForegroundColor Cyan
