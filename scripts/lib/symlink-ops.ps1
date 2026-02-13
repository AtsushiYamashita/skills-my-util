<#
.SYNOPSIS
    Symlink CRUD operations with copy fallback.
#>

function New-SymlinkOrCopy([string]$LinkPath, [string]$TargetPath, [string]$Label) {
    <# symlink を作成し、失敗時はコピーにフォールバックする #>
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
        Write-Host "  Linked: $Label" -ForegroundColor Green
    }
    catch {
        Copy-Item -Path $TargetPath -Destination $LinkPath -Force
        Write-Host "  Copied: $Label" -ForegroundColor Cyan
    }
}

function Test-MonorepoSymlink([System.IO.DirectoryInfo]$Item, [string]$RepoSkillsDir) {
    <# このリポジトリへの symlink かどうかを判定する #>
    if (-not ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
    $t = $Item.Target
    return ($null -ne $t) -and ($t.StartsWith($RepoSkillsDir))
}

function Install-SkillLink(
    [System.IO.DirectoryInfo]$Skill,
    [string]$TargetDir,
    [string]$BackupSuffix
) {
    <# 1つのスキルの symlink を作成する（競合処理・フォールバック含む） #>
    $linkPath = Join-Path $TargetDir $Skill.Name

    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -Force
        $isSymlink = $item.Attributes -band [IO.FileAttributes]::ReparsePoint

        if ($isSymlink -and $item.Target -eq $Skill.FullName) { return }  # 既にリンク済み

        if ($isSymlink) {
            $item.Delete()                                                # 古い symlink → 再作成
            Write-Host "  Relinked: $($Skill.Name) (was -> $($item.Target))" -ForegroundColor Yellow
        }

        if (-not $isSymlink) {
            $backupPath = "${linkPath}${BackupSuffix}"                    # 通常ディレクトリ → バックアップ
            if (Test-Path $backupPath) { Remove-Item $backupPath -Recurse -Force }
            Move-Item $linkPath $backupPath -Force
            Write-Host "  Replacing directory with symlink: $($Skill.Name) (backup: $backupPath)" -ForegroundColor Yellow
        }
    }

    New-SymlinkOrCopy $linkPath $Skill.FullName "$($Skill.Name) -> $($Skill.FullName)"
}

function Remove-SkillLink(
    [System.IO.DirectoryInfo]$Skill,
    [string]$TargetDir
) {
    <# 1つのスキルの symlink を削除する #>
    $linkPath = if ($Skill.FullName.StartsWith($TargetDir)) { $Skill.FullName }
    else { Join-Path $TargetDir $Skill.Name }

    if (-not (Test-Path $linkPath)) {
        Write-Host "  Not found: $($Skill.Name)" -ForegroundColor DarkGray
        return
    }

    $item = Get-Item $linkPath -Force
    if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        Write-Warning "  Skipped (not a symlink): $linkPath"
        return
    }

    $item.Delete()
    Write-Host "  Removed: $($Skill.Name)" -ForegroundColor Yellow
}
