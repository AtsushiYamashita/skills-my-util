<#
.SYNOPSIS
    Install skills from this monorepo to a target AI agent platform.

.DESCRIPTION
    Creates symlinks from skills/ to the target platform's skill discovery path.
    Supports: claude-code, gemini-cli, antigravity.

    Symlinks ensure that edits in this repo are immediately reflected in the
    target platform without manual copying.

.PARAMETER Target
    Target platform: claude-code, gemini-cli, or antigravity.

.PARAMETER Skills
    Optional. Specific skill names to install. If omitted, all skills are installed.

.PARAMETER Remove
    If specified, removes the symlinks instead of creating them.

.EXAMPLE
    .\scripts\setup.ps1 -Target gemini-cli
    .\scripts\setup.ps1 -Target claude-code -Skills change-sync
    .\scripts\setup.ps1 -Target antigravity -Remove
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("claude-code", "gemini-cli", "antigravity")]
    [Alias("t")]
    [string]$Target,

    [Parameter()]
    [string[]]$Skills,

    [Parameter()]
    [switch]$Remove
)

Set-StrictMode -Version Latest                                           # 厳格モードで実行
$ErrorActionPreference = "Stop"                                          # エラー時に即停止

# ---- Platform paths ----
$platformPaths = @{                                                      # 各プラットフォームのスキル配置先
    "claude-code" = Join-Path $env:USERPROFILE ".claude" "skills"
    "gemini-cli"  = Join-Path $env:USERPROFILE ".gemini" "skills"
    "antigravity" = Join-Path $env:USERPROFILE ".gemini" "antigravity" "skills"
}

$targetDir = $platformPaths[$Target]
$repoSkillsDir = Join-Path $PSScriptRoot ".." "skills"                   # このリポジトリの skills/ ディレクトリ
$repoSkillsDir = (Resolve-Path $repoSkillsDir).Path

# ---- Discover skills ----
if ($Skills) {
    $skillDirs = @()
    foreach ($name in $Skills) {
        $path = Join-Path $repoSkillsDir $name
        if (-not (Test-Path $path)) {
            Write-Error "Skill not found: $name (expected at $path)"
        }
        $skillDirs += Get-Item $path
    }
}
else {
    $skillDirs = Get-ChildItem -Path $repoSkillsDir -Directory |         # skills/ 直下のディレクトリ全て
    Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }    # SKILL.md を持つものだけ
}

if ($skillDirs.Count -eq 0) {
    Write-Warning "No skills found to process."
    exit 0
}

# ---- Ensure target directory exists ----
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null      # 配置先が無ければ作成
    Write-Host "Created target directory: $targetDir" -ForegroundColor Cyan
}

# ---- Process each skill ----
foreach ($skill in $skillDirs) {
    $linkPath = Join-Path $targetDir $skill.Name                         # symlink の配置先

    if ($Remove) {
        # ---- Remove mode ----
        if (Test-Path $linkPath) {
            $item = Get-Item $linkPath -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $item.Delete()                                           # symlink を削除
                Write-Host "  Removed: $($skill.Name)" -ForegroundColor Yellow
            }
            else {
                Write-Warning "  Skipped (not a symlink): $linkPath"
            }
        }
        else {
            Write-Host "  Not found: $($skill.Name)" -ForegroundColor DarkGray
        }
    }
    else {
        # ---- Install mode ----
        if (Test-Path $linkPath) {
            $item = Get-Item $linkPath -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Write-Host "  Already linked: $($skill.Name)" -ForegroundColor DarkGray
                continue
            }
            else {
                Write-Warning "  Skipped (path exists, not a symlink): $linkPath"
                continue
            }
        }
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $skill.FullName | Out-Null
        Write-Host "  Linked: $($skill.Name) -> $($skill.FullName)" -ForegroundColor Green
    }
}

# ---- Summary ----
$action = if ($Remove) { "Removed" } else { "Installed" }
Write-Host ""
Write-Host "$action $($skillDirs.Count) skill(s) for $Target" -ForegroundColor Cyan
Write-Host "Target: $targetDir" -ForegroundColor DarkGray
