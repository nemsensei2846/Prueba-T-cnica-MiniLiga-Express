Param()
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.PATH
Set-Location (Join-Path $scriptDir '..')

if (Get-Command wsl -ErrorAction SilentlyContinue) {
  Write-Host "Usando WSL para ejecutar bash..."
  wsl bash scripts/init_web.sh
} elseif (Get-Command bash -ErrorAction SilentlyContinue) {
  Write-Host "Usando bash (Git Bash) para ejecutar script..."
  bash scripts/init_web.sh
} else {
  Write-Host "No se encontró WSL ni bash en PATH."
  Write-Host "Instala WSL o Git Bash, o ejecuta manualmente los pasos en web/README.md"
}