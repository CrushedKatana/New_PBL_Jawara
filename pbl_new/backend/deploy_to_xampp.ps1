Param(
  [string]$Dest = "C:\\xampp\\htdocs\\jawara\\backend"
)

$src = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "=== Deploy Jawara Backend to XAMPP ==="
Write-Host "Source: $src"
Write-Host "Dest  : $Dest"

if (!(Test-Path $Dest)) {
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
}

Copy-Item -Force -Path (Join-Path $src '*.php') -Destination $Dest
Copy-Item -Force -Path (Join-Path $src '*.sql') -Destination $Dest -ErrorAction SilentlyContinue
Copy-Item -Force -Path (Join-Path $src '.gitignore') -Destination $Dest -ErrorAction SilentlyContinue

Write-Host "Done. Restart Apache in XAMPP."
