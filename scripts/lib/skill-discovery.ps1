<#
.SYNOPSIS
    Skill discovery, resolution, and display.
#>

function Write-SkillInfo(
    [System.IO.DirectoryInfo]$Item,
    [string]$SkillManifest,
    [string]$RepoSkillsDir
) {
    <# 1つのスキルの情報を1行で表示する #>
    $isSymlink = $Item.Attributes -band [IO.FileAttributes]::ReparsePoint
    $hasSkillMd = Test-Path (Join-Path $Item.FullName $SkillManifest)
    $isLocal = Test-MonorepoSymlink $Item $RepoSkillsDir

    $icon = if ($isLocal) { "📦" } elseif ($isSymlink) { "🔗" } else { "📁" }
    $source = if ($isLocal) { "monorepo" } elseif ($isSymlink) { "external" } else { "direct" }
    $skillMdTag = if ($hasSkillMd) { "" } else { " [no $SkillManifest]" }

    Write-Host "  $icon $($Item.Name)" -ForegroundColor White -NoNewline
    Write-Host " ($source)$skillMdTag" -ForegroundColor DarkGray
}

function Show-InstalledSkills(
    [string]$TargetDir,
    [string]$Target,
    [string]$SkillManifest,
    [string]$RepoSkillsDir
) {
    <# インストール済みスキルの一覧を表示する #>
    if (-not (Test-Path $TargetDir)) {
        Write-Host "No skills directory found for $Target" -ForegroundColor Yellow
        Write-Host "Expected: $TargetDir" -ForegroundColor DarkGray
        return
    }

    $items = Get-ChildItem -Path $TargetDir -Directory -Force -ErrorAction SilentlyContinue
    if (-not $items -or $items.Count -eq 0) {
        Write-Host "No skills installed for $Target" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Installed skills for $Target" -ForegroundColor Cyan
    Write-Host "Path: $TargetDir" -ForegroundColor DarkGray
    Write-Host ""

    foreach ($item in $items) { Write-SkillInfo $item $SkillManifest $RepoSkillsDir }

    $localCount = @($items | Where-Object { Test-MonorepoSymlink $_ $RepoSkillsDir }).Count
    $externalCount = $items.Count - $localCount
    Write-Host ""
    Write-Host "Total: $($items.Count) skill(s) — $localCount monorepo, $externalCount other" -ForegroundColor Cyan
}

function Get-SkillsToProcess(
    [bool]$IsUnlink,
    [string[]]$Names,
    [string]$TargetDir,
    [string]$RepoSkillsDir,
    [string]$SkillManifest
) {
    <# パラメータに応じて処理対象スキルを解決する #>
    $hasNames = $null -ne $Names -and $Names.Count -gt 0
    $mode = if ($IsUnlink -and $hasNames) { "UnlinkSpecific" }
    elseif ($IsUnlink) { "UnlinkAll" }
    elseif ($hasNames) { "InstallSpecific" }
    else { "InstallAll" }

    switch ($mode) {
        "UnlinkSpecific" {
            $result = @()
            foreach ($name in $Names) {
                $path = Join-Path $TargetDir $name
                if (-not (Test-Path $path)) { Write-Warning "Not installed: $name"; continue }
                $result += Get-Item $path -Force
            }
            return $result
        }
        "UnlinkAll" {
            if (-not (Test-Path $TargetDir)) { return @() }
            return @(Get-ChildItem -Path $TargetDir -Directory |
                Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })
        }
        "InstallSpecific" {
            $result = @()
            foreach ($name in $Names) {
                $path = Join-Path $RepoSkillsDir $name
                if (-not (Test-Path $path)) { Write-Error "Skill not found in repo: $name (expected at $path)" }
                $result += Get-Item $path
            }
            return $result
        }
        "InstallAll" {
            return @(Get-ChildItem -Path $RepoSkillsDir -Directory |
                Where-Object { Test-Path (Join-Path $_.FullName $SkillManifest) })
        }
    }
}

function Show-CozoDbHint(
    [string]$TargetDir,
    [string]$CozoDbSkill,
    [string[]]$CozoDbUrls
) {
    <# CozoDB 依存のヒントを表示する #>
    $cozoSkillPath = Join-Path $TargetDir $CozoDbSkill
    if (Test-Path $cozoSkillPath) {
        Write-Host "  CozoDB: detected" -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "=== CozoDB not detected ===" -ForegroundColor Yellow
    Write-Host "  task-state (orphan detection, decision prediction) requires CozoDB." -ForegroundColor DarkGray
    Write-Host "  To enable:" -ForegroundColor DarkGray
    for ($i = 0; $i -lt $CozoDbUrls.Count; $i++) {
        Write-Host "    $($i + 1). $($CozoDbUrls[$i])" -ForegroundColor White
    }
    Write-Host "  Then re-run this script." -ForegroundColor DarkGray
    Write-Host "  (CozoDB is optional. Core skills work without it.)" -ForegroundColor DarkGray
}
