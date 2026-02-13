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
    If omitted with -Unlink: all symlinked skills are removed.

.PARAMETER Unlink
    Remove symlinks instead of creating them. Combine with -SkillNames to
    remove specific skills only.

.PARAMETER List
    Show currently installed skills for the target platform.

.EXAMPLE
    .\scripts\setup.ps1 -t antigravity                          # Install all
    .\scripts\setup.ps1 -t antigravity -s change-sync           # Install one
    .\scripts\setup.ps1 -t antigravity -List                    # Show installed
    .\scripts\setup.ps1 -t antigravity -Unlink -s ui-ux-pro-max # Remove one
    .\scripts\setup.ps1 -t antigravity -Unlink                  # Remove all
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
    [switch]$Unlink,

    [Parameter()]
    [Alias("l")]
    [switch]$List
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ===========================================================================
# Constants
# ===========================================================================

$SKILL_MANIFEST = "SKILL.md"
$GLOBAL_CONFIG = "GEMINI.md"
$BACKUP_SUFFIX = ".bak"
$COZODB_SKILL = "cozodb"
$COZODB_URLS = @(
    "https://github.com/AtsushiYamashita/mcp-cozodb"
    "https://github.com/AtsushiYamashita/skills-cozodb-connector"
)

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

# Worktree guard: symlink targets diverge from $repoSkillsDir in worktrees
$gitPath = Join-Path $repoRoot ".git"
if ((Test-Path $gitPath) -and -not (Test-Path $gitPath -PathType Container)) {
    Write-Error "setup.ps1 must be run from the main repository, not from a worktree."
}

# ===========================================================================
# Load modules
# ===========================================================================

. "$PSScriptRoot\lib\symlink-ops.ps1"
. "$PSScriptRoot\lib\skill-discovery.ps1"
. "$PSScriptRoot\lib\config-sync.ps1"

# ===========================================================================
# Main
# ===========================================================================

if ($List) {
    Show-InstalledSkills $targetDir $Target $SKILL_MANIFEST $repoSkillsDir
    exit 0
}

$skillDirs = @(Get-SkillsToProcess $Unlink.IsPresent $SkillNames $targetDir $repoSkillsDir $SKILL_MANIFEST)
if ($skillDirs.Count -eq 0) {
    Write-Warning "No skills found to process."
    exit 0
}

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "Created target directory: $targetDir" -ForegroundColor Cyan
}

foreach ($skill in $skillDirs) {
    if ($Unlink) { Remove-SkillLink $skill $targetDir }
    else { Install-SkillLink $skill $targetDir $BACKUP_SUFFIX }
}

$action = if ($Unlink) { "Removed" } else { "Installed" }
Write-Host ""
Write-Host "$action $($skillDirs.Count) skill(s) for $Target" -ForegroundColor Cyan
Write-Host "Target: $targetDir" -ForegroundColor DarkGray

if (-not $Unlink) { Show-CozoDbHint $targetDir $COZODB_SKILL $COZODB_URLS }
Sync-GeminiMd $repoRoot $GLOBAL_CONFIG $BACKUP_SUFFIX $Unlink.IsPresent ($null -ne $SkillNames -and $SkillNames.Count -gt 0)
