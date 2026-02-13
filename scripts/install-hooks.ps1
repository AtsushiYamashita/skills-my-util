<#
.SYNOPSIS
    Install git hooks that prevent direct commits to main.

.DESCRIPTION
    Copies pre-commit and pre-push hooks from this monorepo into the target
    repository's .git/hooks/ directory, or sets core.hooksPath.

    Can be run against ANY repository — not just this one.

.PARAMETER RepoPath
    Path to the target git repository. Defaults to the current directory.

.PARAMETER UseHooksPath
    Set core.hooksPath instead of copying files. The hooks remain in this
    monorepo and are shared across repos. Useful for personal machines.

.PARAMETER Remove
    Remove previously installed hooks.

.EXAMPLE
    .\scripts\install-hooks.ps1                                    # This repo, copy
    .\scripts\install-hooks.ps1 -RepoPath D:\project\my-app       # Another repo
    .\scripts\install-hooks.ps1 -UseHooksPath                     # Use core.hooksPath
    .\scripts\install-hooks.ps1 -Remove                           # Remove hooks
#>
param(
    [Parameter(Position = 0)]
    [string]$RepoPath = ".",

    [Parameter()]
    [switch]$UseHooksPath,

    [Parameter()]
    [switch]$Remove
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---- Resolve paths ----
$RepoPath = (Resolve-Path $RepoPath -ErrorAction Stop).Path
$sourceHooksDir = (Resolve-Path (Join-Path $PSScriptRoot "..\scripts\hooks") -ErrorAction Stop).Path

# ---- Validate target is a git repo ----
if (-not (Test-Path (Join-Path $RepoPath ".git"))) {
    Write-Error "Not a git repository: $RepoPath"
}

$hookFiles = @("pre-commit", "pre-push")

# ---- Remove mode ----
if ($Remove -and $UseHooksPath) {
    git -C $RepoPath config --unset core.hooksPath 2>$null
    Write-Host "Reset: core.hooksPath for $RepoPath" -ForegroundColor Yellow
    Write-Host "Hooks removed from $RepoPath" -ForegroundColor Cyan
    return
}

if ($Remove) {
    $targetHooksDir = Join-Path $RepoPath ".git\hooks"
    foreach ($hook in $hookFiles) {
        $hookPath = Join-Path $targetHooksDir $hook
        if (-not (Test-Path $hookPath)) { continue }
        Remove-Item $hookPath -Force
        Write-Host "  Removed: $hook" -ForegroundColor Yellow
    }
    Write-Host "Hooks removed from $RepoPath" -ForegroundColor Cyan
    return
}

# ---- Install mode: core.hooksPath ----
if ($UseHooksPath) {
    $current = git -C $RepoPath config --get core.hooksPath 2>$null
    if ($current -eq $sourceHooksDir) {
        Write-Host "Already configured: core.hooksPath" -ForegroundColor DarkGray
    }
    else {
        git -C $RepoPath config core.hooksPath $sourceHooksDir
        Write-Host "Set: core.hooksPath -> $sourceHooksDir" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "Hooks installed for $RepoPath" -ForegroundColor Cyan
    return
}

# ---- Install mode: copy ----
$targetHooksDir = Join-Path $RepoPath ".git\hooks"
if (-not (Test-Path $targetHooksDir)) {
    New-Item -ItemType Directory -Path $targetHooksDir -Force | Out-Null
}

foreach ($hook in $hookFiles) {
    $src = Join-Path $sourceHooksDir $hook
    if (-not (Test-Path $src)) { Write-Warning "Source hook not found: $src"; continue }
    Copy-Item -Path $src -Destination (Join-Path $targetHooksDir $hook) -Force
    Write-Host "  Installed: $hook" -ForegroundColor Green
}

Write-Host ""
Write-Host "Hooks installed for $RepoPath" -ForegroundColor Cyan
Write-Host "  Prevents direct commits to main." -ForegroundColor DarkGray
Write-Host "  Bypass (emergency): git commit --no-verify" -ForegroundColor DarkGray
