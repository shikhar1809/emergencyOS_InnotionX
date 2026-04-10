# Run after: flutter build web (staff_app). Injects unique cache-bust id into build/web/index.html.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$html = Join-Path $root "build\web\index.html"
if (-not (Test-Path $html)) {
  Write-Error "Missing $html - run flutter build web from staff_app first."
}
$id = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds().ToString()
$raw = Get-Content -Path $html -Raw -Encoding UTF8
$token = '__BUILD_ID__'
$raw = $raw.Replace($token, $id)
[System.IO.File]::WriteAllText($html, $raw, [System.Text.UTF8Encoding]::new($false))
Write-Host ('Stamped build/web/index.html with build id ' + $id)
