$ErrorActionPreference = "Stop"

$sourceProfile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile.ps1"
$escapedSourceProfile = $sourceProfile.Replace("'", "''")
$loaderContent = @"
. '$escapedSourceProfile'
"@

$profileTargets = @(
    (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
    (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
)

foreach ($target in $profileTargets) {
    $directory = Split-Path -Parent $target
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if (Test-Path $target) {
        Remove-Item -LiteralPath $target -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $sourceProfile -Force | Out-Null
        Write-Host "linked $target -> $sourceProfile"
    }
    catch {
        Set-Content -LiteralPath $target -Value $loaderContent -Encoding UTF8
        Write-Host "loader  $target -> $sourceProfile"
    }
}
