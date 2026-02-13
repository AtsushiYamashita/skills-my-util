<#
.SYNOPSIS
    Synchronize global configuration files (GEMINI.md, rules, workflows).
#>

function Sync-GeminiMd(
    [string]$RepoRoot,
    [string]$GlobalConfig,
    [string]$BackupSuffix,
    [bool]$IsUnlink,
    [bool]$HasSkillNames
) {
    <# GEMINI.md のグローバル symlink を設定/解除する #>
    $repoGeminiMd = Join-Path $RepoRoot $GlobalConfig
    $globalGeminiMd = Join-Path $env:USERPROFILE (Join-Path ".gemini" $GlobalConfig)

    if (-not (Test-Path $repoGeminiMd)) { return }
    if ($IsUnlink -and $HasSkillNames) { return }                        # 個別スキル削除時は触らない

    # ---- Unlink mode ----
    if ($IsUnlink) {
        if (-not (Test-Path $globalGeminiMd)) { return }
        $item = Get-Item $globalGeminiMd -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return }
        $item.Delete()
        Write-Host "  Unlinked: GEMINI.md" -ForegroundColor Yellow
        return
    }

    # ---- Install mode ----
    if (Test-Path $globalGeminiMd) {
        $item = Get-Item $globalGeminiMd -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return }  # 設定済み
        $backupPath = "${globalGeminiMd}${BackupSuffix}"
        Move-Item $globalGeminiMd $backupPath -Force
        New-SymlinkOrCopy $globalGeminiMd $repoGeminiMd "GEMINI.md (backup: $backupPath)"
        return
    }

    New-SymlinkOrCopy $globalGeminiMd $repoGeminiMd "GEMINI.md -> $repoGeminiMd"
}
