<#
.SYNOPSIS
    新しいスキルのひな形を skills/ ディレクトリに作成します。

.DESCRIPTION
    テンプレートリポジトリ (AtsushiYamashita/my-skills-template-20260201) から
    必要なファイルを取得し、skills/<SkillName>/ にスキルの骨格を生成します。
    テンプレートの .git ディレクトリは除外されます。

    【永続的変更】
    - skills/<SkillName>/ ディレクトリを新規作成
    - SKILL.md, docs/ 等のファイルを生成

.PARAMETER SkillName
    作成するスキルの名前（ディレクトリ名に使用）

.EXAMPLE
    .\scripts\new-skill.ps1 -SkillName "my-awesome-skill"
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')]
    [string]$SkillName
)

$ErrorActionPreference = "Stop"

# ---- Configuration ----
$RepoRoot = Split-Path -Parent $PSScriptRoot                          # リポジトリルートを取得
$SkillDir = Join-Path $RepoRoot "skills" $SkillName                   # 出力先パス
$TemplateRepo = "https://github.com/AtsushiYamashita/my-skills-template-20260201.git"
$TempDir = Join-Path $env:TEMP "skill-template-$([guid]::NewGuid().ToString('N').Substring(0,8))"

# ---- Pre-checks ----
if (Test-Path $SkillDir) {
    # 既存スキルとの衝突を防止
    Write-Error "Error: skills/$SkillName already exists."
    exit 1
}

# ---- Clone template ----
Write-Host "[1/4] Cloning template..." -ForegroundColor Cyan
git clone --depth 1 --quiet $TemplateRepo $TempDir                    # 浅いクローンで高速化
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to clone template repository."
    exit 1
}

# ---- Copy files ----
Write-Host "[2/4] Creating skill directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null        # skills/<name>/ を作成

# スキルに必要なファイルのみコピー（テンプレートのメタ設定は除外）
$filesToCopy = @(
    @{ Src = "SKILL.md"; Dst = "SKILL.md" }
    @{ Src = "docs"; Dst = "docs" }
)

foreach ($file in $filesToCopy) {
    $src = Join-Path $TempDir $file.Src
    $dst = Join-Path $SkillDir $file.Dst
    if (Test-Path $src) {
        if ((Get-Item $src).PSIsContainer) {
            Copy-Item -Path $src -Destination $dst -Recurse           # ディレクトリの場合は再帰コピー
        }
        else {
            Copy-Item -Path $src -Destination $dst                    # ファイルの場合は直接コピー
        }
    }
}

# ---- Initialize SKILL.md ----
Write-Host "[3/4] Initializing SKILL.md..." -ForegroundColor Cyan
$skillMdContent = @"
---
description: TODO - Describe when and why this skill should be activated
---

# $SkillName

## Overview

TODO: Describe what this skill does.

## Usage

TODO: Describe how to use this skill.
"@
Set-Content -Path (Join-Path $SkillDir "SKILL.md") -Value $skillMdContent -Encoding UTF8

# ---- Cleanup ----
Write-Host "[4/4] Cleaning up..." -ForegroundColor Cyan
Remove-Item -Recurse -Force $TempDir                                  # 一時ディレクトリを削除

# ---- Done ----
Write-Host ""
Write-Host "✓ Skill '$SkillName' created at: skills/$SkillName/" -ForegroundColor Green
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "  1. Edit skills/$SkillName/SKILL.md to define your skill"
Write-Host "  2. Add scripts/ or examples/ as needed"
Write-Host "  3. Commit with: git add skills/$SkillName && git commit"
