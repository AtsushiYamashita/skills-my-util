<#
.SYNOPSIS
    Manage skills from this monorepo for a target AI agent platform.

.DESCRIPTION
    Creates/removes symlinks from skills/ to the target platform's skill
    discovery path. Supports: claude-code, gemini-cli, antigravity.

    Symlinks ensure that edits in this repo are immediately reflected in the
    target platform without manual copying.

.PARAMETER Target
    Target platform: claude-code, gemini-cli, or antigravity.

.PARAMETER SkillNames
    Optional. Specific skill names to install or remove.
    If omitted with install: all skills are installed.
    If omitted with -Remove: all symlinked skills are removed.

.PARAMETER Remove
    Remove symlinks instead of creating them. Combine with -SkillNames to
    remove specific skills only.

.PARAMETER List
    Show currently installed skills for the target platform.

.EXAMPLE
    .\scripts\setup.ps1 -t antigravity                          # Install all
    .\scripts\setup.ps1 -t antigravity -s change-sync           # Install one
    .\scripts\setup.ps1 -t antigravity -List                    # Show installed
    .\scripts\setup.ps1 -t antigravity -Remove -s ui-ux-pro-max # Remove one
    .\scripts\setup.ps1 -t antigravity -Remove                  # Remove all
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("claude-code", "gemini-cli", "antigravity")]
    [Alias("t")]
    [string]$Target,

    [Parameter()]
    [Alias("s")]
    [string[]]$SkillNames,

    [Parameter()]
    [switch]$Remove,

    [Parameter()]
    [Alias("l")]
    [switch]$List
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ===========================================================================
# Paths
# ===========================================================================

$platformPaths = @{
    "claude-code" = Join-Path (Join-Path $env:USERPROFILE ".claude") "skills"
    "gemini-cli"  = Join-Path (Join-Path $env:USERPROFILE ".gemini") "skills"
    "antigravity" = Join-Path (Join-Path (Join-Path $env:USERPROFILE ".gemini") "antigravity") "skills"
}

$targetDir = $platformPaths[$Target]
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$repoSkillsDir = Join-Path $repoRoot "skills"

# Worktree 内からの実行を拒否 — symlink の指す先と $repoSkillsDir がずれるため
$gitPath = Join-Path $repoRoot ".git"
if ((Test-Path $gitPath) -and -not (Test-Path $gitPath -PathType Container)) {
    Write-Error "setup.ps1 はメインリポジトリから実行してください（worktree 内では実行できません）。"
}

# ===========================================================================
# Helpers
# ===========================================================================

function Test-MonorepoSymlink([System.IO.DirectoryInfo]$Item) {
    <# このリポジトリへの symlink かどうかを判定する #>
    if (-not ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
    $t = $Item.Target
    return ($null -ne $t) -and ($t.StartsWith($repoSkillsDir))
}

# ===========================================================================
# Functions
# ===========================================================================

function Show-InstalledSkills {
    <# インストール済みスキルの一覧を表示する #>
    if (-not (Test-Path $targetDir)) {
        Write-Host "No skills directory found for $Target" -ForegroundColor Yellow
        Write-Host "Expected: $targetDir" -ForegroundColor DarkGray
        return
    }

    $items = Get-ChildItem -Path $targetDir -Directory -Force -ErrorAction SilentlyContinue
    if (-not $items -or $items.Count -eq 0) {
        Write-Host "No skills installed for $Target" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Installed skills for $Target" -ForegroundColor Cyan
    Write-Host "Path: $targetDir" -ForegroundColor DarkGray
    Write-Host ""

    foreach ($item in $items) {
        $isSymlink = $item.Attributes -band [IO.FileAttributes]::ReparsePoint
        $hasSkillMd = Test-Path (Join-Path $item.FullName "SKILL.md")
        $isLocal = Test-MonorepoSymlink $item

        $icon = if ($isLocal) { "📦" } elseif ($isSymlink) { "🔗" } else { "📁" }
        $source = if ($isLocal) { "monorepo" } elseif ($isSymlink) { "external" } else { "direct" }
        $skillMdTag = if ($hasSkillMd) { "" } else { " [no SKILL.md]" }

        Write-Host "  $icon $($item.Name)" -ForegroundColor White -NoNewline
        Write-Host " ($source)$skillMdTag" -ForegroundColor DarkGray
    }

    $localCount = @($items | Where-Object { Test-MonorepoSymlink $_ }).Count
    $externalCount = $items.Count - $localCount
    Write-Host ""
    Write-Host "Total: $($items.Count) skill(s) — $localCount monorepo, $externalCount other" -ForegroundColor Cyan
}

function Get-SkillsToProcess {
    <# パラメータに応じて処理対象スキルを解決する #>
    if ($Remove -and $SkillNames) {
        $result = @()
        foreach ($name in $SkillNames) {
            $path = Join-Path $targetDir $name
            if (-not (Test-Path $path)) {
                Write-Warning "Not installed: $name"
                continue
            }
            $result += Get-Item $path -Force
        }
        return $result
    }
    elseif ($Remove) {
        if (Test-Path $targetDir) {
            return @(Get-ChildItem -Path $targetDir -Directory |
                Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })
        }
        return @()
    }
    elseif ($SkillNames) {
        $result = @()
        foreach ($name in $SkillNames) {
            $path = Join-Path $repoSkillsDir $name
            if (-not (Test-Path $path)) {
                Write-Error "Skill not found in repo: $name (expected at $path)"
            }
            $result += Get-Item $path
        }
        return $result
    }
    else {
        return @(Get-ChildItem -Path $repoSkillsDir -Directory |
            Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") })
    }
}

function Install-SkillLink([System.IO.DirectoryInfo]$Skill) {
    <# 1つのスキルの symlink を作成する（競合処理・フォールバック含む） #>
    $linkPath = Join-Path $targetDir $Skill.Name

    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            if ($item.Target -eq $Skill.FullName) { return }              # 既にリンク済み
            $item.Delete()                                                # 古い symlink → 再作成
            Write-Host "  Relinked: $($Skill.Name) (was -> $($item.Target))" -ForegroundColor Yellow
        }
        else {
            $backupPath = "$linkPath.bak"                                 # 通常ディレクトリ → バックアップ
            if (Test-Path $backupPath) { Remove-Item $backupPath -Recurse -Force }
            Move-Item $linkPath $backupPath -Force
            Write-Host "  Replacing directory with symlink: $($Skill.Name) (backup: $backupPath)" -ForegroundColor Yellow
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $Skill.FullName | Out-Null
        Write-Host "  Linked: $($Skill.Name) -> $($Skill.FullName)" -ForegroundColor Green
    }
    catch {
        Copy-Item -Path $Skill.FullName -Destination $linkPath -Recurse -Force
        Write-Host "  Copied (symlink failed): $($Skill.Name)" -ForegroundColor Cyan
    }
}

function Remove-SkillLink([System.IO.DirectoryInfo]$Skill) {
    <# 1つのスキルの symlink を削除する #>
    $linkPath = if ($Skill.FullName.StartsWith($targetDir)) {
        $Skill.FullName
    }
    else {
        Join-Path $targetDir $Skill.Name
    }

    if (-not (Test-Path $linkPath)) {
        Write-Host "  Not found: $($Skill.Name)" -ForegroundColor DarkGray
        return
    }

    $item = Get-Item $linkPath -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        $item.Delete()
        Write-Host "  Removed: $($Skill.Name)" -ForegroundColor Yellow
    }
    else {
        Write-Warning "  Skipped (not a symlink): $linkPath"
    }
}

function Sync-GeminiMd {
    <# GEMINI.md のグローバル symlink を設定/解除する #>
    $repoGeminiMd = Join-Path $repoRoot "GEMINI.md"
    $globalGeminiMd = Join-Path $env:USERPROFILE (Join-Path ".gemini" "GEMINI.md")

    if (-not (Test-Path $repoGeminiMd)) { return }

    if ($Remove -and -not $SkillNames) {
        if (Test-Path $globalGeminiMd) {
            $item = Get-Item $globalGeminiMd -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $item.Delete()
                Write-Host "  Unlinked: GEMINI.md" -ForegroundColor Yellow
            }
        }
        return
    }

    if ($Remove) { return }

    if (Test-Path $globalGeminiMd) {
        $item = Get-Item $globalGeminiMd -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return }

        $backupPath = "$globalGeminiMd.bak"
        Move-Item $globalGeminiMd $backupPath -Force
        try {
            New-Item -ItemType SymbolicLink -Path $globalGeminiMd -Target $repoGeminiMd | Out-Null
            Write-Host "  Linked: GEMINI.md (backup: $backupPath)" -ForegroundColor Green
        }
        catch {
            Copy-Item -Path $repoGeminiMd -Destination $globalGeminiMd -Force
            Write-Host "  Copied: GEMINI.md (backup: $backupPath)" -ForegroundColor Cyan
        }
    }
    else {
        try {
            New-Item -ItemType SymbolicLink -Path $globalGeminiMd -Target $repoGeminiMd | Out-Null
            Write-Host "  Linked: GEMINI.md -> $repoGeminiMd" -ForegroundColor Green
        }
        catch {
            Copy-Item -Path $repoGeminiMd -Destination $globalGeminiMd -Force
            Write-Host "  Copied: GEMINI.md -> $repoGeminiMd" -ForegroundColor Cyan
        }
    }
}

function Show-CozoDbHint {
    <# CozoDB 依存のヒントを表示する #>
    $cozoSkillPath = Join-Path $targetDir "cozodb-connector"
    if (Test-Path $cozoSkillPath) {
        Write-Host "  CozoDB: detected" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "=== CozoDB not detected ===" -ForegroundColor Yellow
        Write-Host "  task-state (orphan detection, decision prediction) requires CozoDB." -ForegroundColor DarkGray
        Write-Host "  To enable:" -ForegroundColor DarkGray
        Write-Host "    1. https://github.com/AtsushiYamashita/mcp-cozodb" -ForegroundColor White
        Write-Host "    2. https://github.com/AtsushiYamashita/skills-cozodb-connector" -ForegroundColor White
        Write-Host "  Then re-run this script." -ForegroundColor DarkGray
        Write-Host "  (CozoDB is optional. Core skills work without it.)" -ForegroundColor DarkGray
    }
}

# ===========================================================================
# Main
# ===========================================================================

if ($List) {
    Show-InstalledSkills
    exit 0
}

$skillDirs = Get-SkillsToProcess
if ($skillDirs.Count -eq 0) {
    Write-Warning "No skills found to process."
    exit 0
}

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "Created target directory: $targetDir" -ForegroundColor Cyan
}

foreach ($skill in $skillDirs) {
    if ($Remove) { Remove-SkillLink $skill }
    else { Install-SkillLink $skill }
}

$action = if ($Remove) { "Removed" } else { "Installed" }
Write-Host ""
Write-Host "$action $($skillDirs.Count) skill(s) for $Target" -ForegroundColor Cyan
Write-Host "Target: $targetDir" -ForegroundColor DarkGray

if (-not $Remove) { Show-CozoDbHint }
Sync-GeminiMd
