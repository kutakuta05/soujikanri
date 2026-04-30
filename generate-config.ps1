# generate-config.ps1
# Reads .env in same directory and generates config.js.
# Usage: cd to this folder and run `.\generate-config.ps1`

$ErrorActionPreference = "Stop"

$envPath = Join-Path $PSScriptRoot ".env"
$outPath = Join-Path $PSScriptRoot "config.js"

if (-not (Test-Path $envPath)) {
  Write-Error ".env not found: $envPath. Copy .env.example to .env and fill in real values."
  exit 1
}

$kv = @{}
$lines = Get-Content $envPath -Encoding utf8
foreach ($line in $lines) {
  $t = $line.Trim()
  if ($t -eq "" -or $t.StartsWith("#")) { continue }
  if ($t -match '^([^=]+)=(.*)$') {
    $kv[$Matches[1].Trim()] = $Matches[2].Trim()
  }
}

$required = @("GOOGLE_MAPS_API_KEY","FIREBASE_API_KEY","FIREBASE_AUTH_DOMAIN","FIREBASE_PROJECT_ID","FIREBASE_STORAGE_BUCKET","FIREBASE_MESSAGING_SENDER_ID","FIREBASE_APP_ID")
$missing = @()
foreach ($k in $required) {
  if (-not $kv.ContainsKey($k) -or $kv[$k] -eq "") { $missing += $k }
}
if ($missing.Count -gt 0) {
  Write-Error ("Missing keys in .env: " + ($missing -join ', '))
  exit 1
}

$config = @"
// AUTO-GENERATED from .env by generate-config.ps1. Do not edit directly.
window.APP_CONFIG = {
  googleMapsApiKey: "$($kv.GOOGLE_MAPS_API_KEY)",
  firebase: {
    apiKey: "$($kv.FIREBASE_API_KEY)",
    authDomain: "$($kv.FIREBASE_AUTH_DOMAIN)",
    projectId: "$($kv.FIREBASE_PROJECT_ID)",
    storageBucket: "$($kv.FIREBASE_STORAGE_BUCKET)",
    messagingSenderId: "$($kv.FIREBASE_MESSAGING_SENDER_ID)",
    appId: "$($kv.FIREBASE_APP_ID)"
  }
};
"@

Set-Content -Path $outPath -Value $config -Encoding utf8
Write-Output "config.js generated: $outPath"
