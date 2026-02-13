<#
.SYNOPSIS
    skills-my-util の rules/workflows/GEMINI.md を ~/.gemini/ および各ワークスペースに配布する

.PARAMETER TargetWorkspace
    配布先ワークスペースのパス（省略時はグローバルのみ）

.PARAMETER Mode
    "symlink" (デフォルト) または "copy"

.EXAMPLE
    # グローバルだけ同期
    .\scripts\sync-env.ps1

    # 特定プロジェクトにも配布
    .\scripts\sync-env.ps1 -TargetWorkspace "D:\project\my-app"
#>
param(
    [string[]]$TargetWorkspace = @(),
    [ValidateSet("symlink", "copy")]
    [string]$Mode = "symlink"
)

$ErrorActionPreference = "Stop"
$SourceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)  # skills-my-util のルート
if (-not (Test-Path "$SourceRoot\GEMINI.md")) {
    $SourceRoot = Split-Path -Parent $PSScriptRoot
    if (-not (Test-Path "$SourceRoot\GEMINI.md")) {
        Write-Error "GEMINI.md が見つかりません。スクリプトを skills-my-util/scripts/ から実行してください。"
        exit 1
    }
}

$GeminiHome = Join-Path $env:USERPROFILE ".gemini"

# --- ヘルパー関数 ---

function Sync-Item {
    param(
        [string]$Source,
        [string]$Destination,
        [bool]$IsDirectory = $false
    )

    # 既存のリンク/ファイルを削除
    if (Test-Path $Destination) {
        $item = Get-Item $Destination -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # シンボリックリンクを削除
            $item.Delete()
            Write-Host "  削除: 既存リンク $Destination" -ForegroundColor Yellow
        }
        else {
            if ($IsDirectory) { Remove-Item $Destination -Recurse -Force }
            else { Remove-Item $Destination -Force }
            Write-Host "  削除: 既存ファイル $Destination" -ForegroundColor Yellow
        }
    }

    # 親ディレクトリを作成
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ($Mode -eq "symlink") {
        try {
            if ($IsDirectory) {
                New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
            }
            else {
                New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
            }
            Write-Host "  リンク: $Destination -> $Source" -ForegroundColor Green
        }
        catch {
            Write-Warning "  シンボリックリンク作成失敗（開発者モードが必要）。コピーにフォールバックします。"
            if ($IsDirectory) {
                Copy-Item -Path $Source -Destination $Destination -Recurse -Force
            }
            else {
                Copy-Item -Path $Source -Destination $Destination -Force
            }
            Write-Host "  コピー: $Source -> $Destination" -ForegroundColor Cyan
        }
    }
    else {
        if ($IsDirectory) {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        }
        else {
            Copy-Item -Path $Source -Destination $Destination -Force
        }
        Write-Host "  コピー: $Source -> $Destination" -ForegroundColor Cyan
    }
}

# --- 1. グローバル同期 (~/.gemini/) ---

Write-Host "`n=== グローバル同期 ($GeminiHome) ===" -ForegroundColor White

# GEMINI.md
Write-Host "`n[GEMINI.md]"
Sync-Item -Source "$SourceRoot\GEMINI.md" -Destination "$GeminiHome\GEMINI.md"

# グローバル rules (存在すれば)
if (Test-Path "$SourceRoot\.agent\rules") {
    Write-Host "`n[rules]"
    $rules = Get-ChildItem "$SourceRoot\.agent\rules\*.md"
    foreach ($rule in $rules) {
        Sync-Item -Source $rule.FullName -Destination "$GeminiHome\rules\$($rule.Name)"
    }
}

# --- 2. ワークスペース同期 ---

foreach ($ws in $TargetWorkspace) {
    if (-not (Test-Path $ws)) {
        Write-Warning "ワークスペースが見つかりません: $ws"
        continue
    }

    Write-Host "`n=== ワークスペース同期 ($ws) ===" -ForegroundColor White

    # .agent/rules/
    if (Test-Path "$SourceRoot\.agent\rules") {
        Write-Host "`n[rules]"
        $rules = Get-ChildItem "$SourceRoot\.agent\rules\*.md"
        foreach ($rule in $rules) {
            Sync-Item -Source $rule.FullName -Destination "$ws\.agent\rules\$($rule.Name)"
        }
    }

    # .agent/workflows/
    if (Test-Path "$SourceRoot\.agent\workflows") {
        Write-Host "`n[workflows]"
        $workflows = Get-ChildItem "$SourceRoot\.agent\workflows\*.md"
        foreach ($wf in $workflows) {
            Sync-Item -Source $wf.FullName -Destination "$ws\.agent\workflows\$($wf.Name)"
        }
    }

    # GEMINI.md (ワークスペースレベル)
    Write-Host "`n[GEMINI.md]"
    Sync-Item -Source "$SourceRoot\GEMINI.md" -Destination "$ws\GEMINI.md"
}

Write-Host "`n=== 同期完了 ===" -ForegroundColor Green
Write-Host "ソース: $SourceRoot"
Write-Host "モード: $Mode"
if ($TargetWorkspace.Count -eq 0) {
    Write-Host "ヒント: -TargetWorkspace でプロジェクトにも配布できます" -ForegroundColor DarkGray
}
