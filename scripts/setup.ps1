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

Set-StrictMode -Version Latest                                           # 厳格モードで実行
$ErrorActionPreference = "Stop"                                          # エラー時に即停止

# ---- Platform paths ----
$platformPaths = @{                                                      # 各プラットフォームのスキル配置先
    "claude-code" = Join-Path (Join-Path $env:USERPROFILE ".claude") "skills"
    "gemini-cli"  = Join-Path (Join-Path $env:USERPROFILE ".gemini") "skills"
    "antigravity" = Join-Path (Join-Path (Join-Path $env:USERPROFILE ".gemini") "antigravity") "skills"
}

$targetDir = $platformPaths[$Target]
$repoSkillsDir = Join-Path (Join-Path $PSScriptRoot "..") "skills"       # このリポジトリの skills/ ディレクトリ
$repoSkillsDir = (Resolve-Path $repoSkillsDir).Path

# ---- List mode ----
if ($List) {
    if (-not (Test-Path $targetDir)) {
        Write-Host "No skills directory found for $Target" -ForegroundColor Yellow
        Write-Host "Expected: $targetDir" -ForegroundColor DarkGray
        exit 0
    }

    $items = Get-ChildItem -Path $targetDir -Directory -ErrorAction SilentlyContinue
    if (-not $items -or $items.Count -eq 0) {
        Write-Host "No skills installed for $Target" -ForegroundColor Yellow
        exit 0
    }

    Write-Host ""
    Write-Host "Installed skills for $Target" -ForegroundColor Cyan
    Write-Host "Path: $targetDir" -ForegroundColor DarkGray
    Write-Host ""

    foreach ($item in $items) {
        $isSymlink = $item.Attributes -band [IO.FileAttributes]::ReparsePoint
        $hasSkillMd = Test-Path (Join-Path $item.FullName "SKILL.md")
        $linkTarget = if ($isSymlink) { $item.Target } else { $null }

        # Check if it's from this repo
        $isLocal = $linkTarget -and $linkTarget.StartsWith($repoSkillsDir)

        $icon = if ($isLocal) { "📦" } elseif ($isSymlink) { "🔗" } else { "📁" }
        $source = if ($isLocal) { "monorepo" } elseif ($isSymlink) { "external" } else { "direct" }
        $skillMdTag = if ($hasSkillMd) { "" } else { " [no SKILL.md]" }

        Write-Host "  $icon $($item.Name)" -ForegroundColor White -NoNewline
        Write-Host " ($source)$skillMdTag" -ForegroundColor DarkGray
    }

    $localCount = ($items | Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -and $_.Target -and $_.Target.StartsWith($repoSkillsDir) }).Count
    $externalCount = $items.Count - $localCount
    Write-Host ""
    Write-Host "Total: $($items.Count) skill(s) — $localCount monorepo, $externalCount other" -ForegroundColor Cyan
    exit 0
}

# ---- Discover skills (install/remove) ----
if ($Remove -and $SkillNames) {
    # Per-skill removal: target specific skills in the target dir
    $skillDirs = @()
    foreach ($name in $SkillNames) {
        $path = Join-Path $targetDir $name
        if (-not (Test-Path $path)) {
            Write-Warning "Not installed: $name"
            continue
        }
        $skillDirs += Get-Item $path -Force
    }
}
elseif ($Remove) {
    # Remove all: find all symlinks in target dir
    if (Test-Path $targetDir) {
        $skillDirs = Get-ChildItem -Path $targetDir -Directory |
        Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }
    }
    else {
        $skillDirs = @()
    }
}
elseif ($SkillNames) {
    # Install specific skills from repo
    $skillDirs = @()
    foreach ($name in $SkillNames) {
        $path = Join-Path $repoSkillsDir $name
        if (-not (Test-Path $path)) {
            Write-Error "Skill not found in repo: $name (expected at $path)"
        }
        $skillDirs += Get-Item $path
    }
}
else {
    # Install all skills from repo
    $skillDirs = Get-ChildItem -Path $repoSkillsDir -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }
}

if ($skillDirs.Count -eq 0) {
    Write-Warning "No skills found to process."
    exit 0
}

# ---- Ensure target directory exists ----
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "Created target directory: $targetDir" -ForegroundColor Cyan
}

# ---- Process each skill ----
foreach ($skill in $skillDirs) {
    if ($Remove) {
        # ---- Remove mode ----
        $linkPath = if ($skill.FullName.StartsWith($targetDir)) {
            $skill.FullName                                              # Already a path in targetDir
        }
        else {
            Join-Path $targetDir $skill.Name
        }

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
        $linkPath = Join-Path $targetDir $skill.Name

        if (Test-Path $linkPath) {
            $item = Get-Item $linkPath -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                # symlink が正しいリンク先を指しているか検証
                if ($item.Target -eq $skill.FullName) {
                    Write-Host "  Already linked: $($skill.Name)" -ForegroundColor DarkGray
                    continue
                }
                else {
                    # 古い/別リポの symlink → 削除して再作成
                    $item.Delete()
                    Write-Host "  Relinked: $($skill.Name) (was -> $($item.Target))" -ForegroundColor Yellow
                }
            }
            else {
                # 通常ディレクトリ → バックアップして symlink に置き換え
                $backupPath = "$linkPath.bak"
                if (Test-Path $backupPath) {
                    Remove-Item $backupPath -Recurse -Force
                }
                Move-Item $linkPath $backupPath -Force
                Write-Host "  Replacing directory with symlink: $($skill.Name) (backup: $backupPath)" -ForegroundColor Yellow
            }
        }
        try {
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $skill.FullName | Out-Null
            Write-Host "  Linked: $($skill.Name) -> $($skill.FullName)" -ForegroundColor Green
        }
        catch {
            # シンボリックリンク失敗時はコピーにフォールバック
            Copy-Item -Path $skill.FullName -Destination $linkPath -Recurse -Force
            Write-Host "  Copied (symlink failed): $($skill.Name)" -ForegroundColor Cyan
        }
    }
}

# ---- Summary ----
$action = if ($Remove) { "Removed" } else { "Installed" }
Write-Host ""
Write-Host "$action $($skillDirs.Count) skill(s) for $Target" -ForegroundColor Cyan
Write-Host "Target: $targetDir" -ForegroundColor DarkGray

# ---- CozoDB dependency check ----
if (-not $Remove) {
    $cozoSkillPath = Join-Path $targetDir "cozodb-connector"
    $hasCozoSkill = Test-Path $cozoSkillPath
    
    if (-not $hasCozoSkill) {
        Write-Host ""
        Write-Host "=== CozoDB not detected ===" -ForegroundColor Yellow
        Write-Host "  task-state (orphan detection, decision prediction) requires CozoDB." -ForegroundColor DarkGray
        Write-Host "  To enable:" -ForegroundColor DarkGray
        Write-Host "    1. https://github.com/AtsushiYamashita/mcp-cozodb" -ForegroundColor White
        Write-Host "    2. https://github.com/AtsushiYamashita/skills-cozodb-connector" -ForegroundColor White
        Write-Host "  Then re-run this script." -ForegroundColor DarkGray
        Write-Host "  (CozoDB is optional. Core skills work without it.)" -ForegroundColor DarkGray
    }
    else {
        Write-Host "  CozoDB: detected" -ForegroundColor Green
    }
}

# ---- Git hooks ----
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path              # リポジトリのルート
$repoHooksDir = Join-Path $repoRoot "scripts\hooks"

if (Test-Path $repoHooksDir) {
    if ($Remove -and -not $SkillNames) {
        # Full remove: reset hooksPath
        git -C $repoRoot config --unset core.hooksPath 2>$null
        Write-Host "  Reset: core.hooksPath" -ForegroundColor Yellow
    }
    elseif (-not $Remove) {
        # Install: set core.hooksPath to repo hooks
        $currentHooksPath = git -C $repoRoot config --get core.hooksPath 2>$null
        if ($currentHooksPath -eq $repoHooksDir) {
            Write-Host "  Already set: core.hooksPath" -ForegroundColor DarkGray
        }
        else {
            git -C $repoRoot config core.hooksPath $repoHooksDir
            Write-Host "  Set: core.hooksPath -> $repoHooksDir" -ForegroundColor Green
        }
    }
}

# ---- GEMINI.md global link ----
$repoGeminiMd = Join-Path (Join-Path $PSScriptRoot "..") "GEMINI.md"
$repoGeminiMd = (Resolve-Path $repoGeminiMd -ErrorAction SilentlyContinue).Path
$globalGeminiMd = Join-Path $env:USERPROFILE (Join-Path ".gemini" "GEMINI.md")

if ($repoGeminiMd -and (Test-Path $repoGeminiMd)) {
    if ($Remove -and -not $SkillNames) {
        # Full remove: unlink GEMINI.md too
        if (Test-Path $globalGeminiMd) {
            $item = Get-Item $globalGeminiMd -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $item.Delete()
                Write-Host "  Unlinked: GEMINI.md" -ForegroundColor Yellow
            }
        }
    }
    elseif (-not $Remove) {
        # Install: link GEMINI.md
        if (Test-Path $globalGeminiMd) {
            $item = Get-Item $globalGeminiMd -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Write-Host "  Already linked: GEMINI.md" -ForegroundColor DarkGray
            }
            else {
                # Backup existing non-symlink GEMINI.md
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
}

