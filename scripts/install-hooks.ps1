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
$sourceHooksDir = Join-Path (Join-Path $PSScriptRoot "..") "scripts\hooks"
$sourceHooksDir = (Resolve-Path $sourceHooksDir -ErrorAction Stop).Path

# ---- Validate target is a git repo ----
$gitDir = Join-Path $RepoPath ".git"
if (-not (Test-Path $gitDir)) {
    # worktree の場合、.git はファイル（ポインタ）
    if (Test-Path $gitDir -PathType Leaf) {
        # OK — worktree
    }
    else {
        Write-Error "Not a git repository: $RepoPath"
    }
}

$hookFiles = @("pre-commit", "pre-push")

if ($Remove) {
    # ---- Remove mode ----
    if ($UseHooksPath) {
        git -C $RepoPath config --unset core.hooksPath 2>$null
        Write-Host "Reset: core.hooksPath for $RepoPath" -ForegroundColor Yellow
    }
    else {
        $targetHooksDir = Join-Path $RepoPath ".git\hooks"
        foreach ($hook in $hookFiles) {
            $hookPath = Join-Path $targetHooksDir $hook
            if (Test-Path $hookPath) {
                Remove-Item $hookPath -Force
                Write-Host "  Removed: $hook" -ForegroundColor Yellow
            }
        }
    }
    Write-Host "Hooks removed from $RepoPath" -ForegroundColor Cyan
}
else {
    # ---- Install mode ----
    if ($UseHooksPath) {
        # core.hooksPath: hooks をこの monorepo から直接参照する
        $current = git -C $RepoPath config --get core.hooksPath 2>$null
        if ($current -eq $sourceHooksDir) {
            Write-Host "Already configured: core.hooksPath" -ForegroundColor DarkGray
        }
        else {
            git -C $RepoPath config core.hooksPath $sourceHooksDir
            Write-Host "Set: core.hooksPath -> $sourceHooksDir" -ForegroundColor Green
        }
    }
    else {
        # Copy: hooks を対象リポの .git/hooks/ にコピーする
        $targetHooksDir = Join-Path $RepoPath ".git\hooks"
        if (-not (Test-Path $targetHooksDir)) {
            New-Item -ItemType Directory -Path $targetHooksDir -Force | Out-Null
        }

        foreach ($hook in $hookFiles) {
            $src = Join-Path $sourceHooksDir $hook
            $dst = Join-Path $targetHooksDir $hook
            if (-not (Test-Path $src)) {
                Write-Warning "Source hook not found: $src"
                continue
            }
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "  Installed: $hook" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "Hooks installed for $RepoPath" -ForegroundColor Cyan
    Write-Host "  Prevents direct commits to main." -ForegroundColor DarkGray
    Write-Host "  Bypass (emergency): git commit --no-verify" -ForegroundColor DarkGray
}
