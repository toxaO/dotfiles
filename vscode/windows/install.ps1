$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$settingsFile = Join-Path $repoDir "vscode/common/settings.json"
$extensionsFile = Join-Path $repoDir "vscode/windows/extensions.txt"
$userDir = Join-Path $env:APPDATA "Code\User"
$targetSettings = Join-Path $userDir "settings.json"

if (-not (Test-Path $userDir)) {
    New-Item -ItemType Directory -Path $userDir -Force | Out-Null
}

if (Test-Path $targetSettings) {
    Remove-Item -LiteralPath $targetSettings -Force
}

try {
    New-Item -ItemType SymbolicLink -Path $targetSettings -Target $settingsFile -Force | Out-Null
    Write-Host "linked $targetSettings -> $settingsFile"
}
catch {
    Copy-Item -LiteralPath $settingsFile -Destination $targetSettings -Force
    Write-Host "copied $targetSettings <- $settingsFile"
}

$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if (-not $codeCmd) {
    $codeCmd = Get-Command code-insiders -ErrorAction SilentlyContinue
}

if (-not $codeCmd) {
    Write-Warning "skip extension install: code command not found"
    exit 0
}

Get-Content $extensionsFile | ForEach-Object {
    $ext = $_.Trim()
    if ($ext -and -not $ext.StartsWith("#")) {
        & $codeCmd.Path --install-extension $ext --force | Out-Null
    }
}
