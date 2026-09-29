<#
.SYNOPSIS
Install the specflow skill for one or more coding agents (Windows PowerShell 5.1 or PowerShell 7).

.EXAMPLE
.\install.ps1 -Agent all
.\install.ps1 -Agent claude,codex -Scope project -ProjectDir C:\code\my-app
.\install.ps1 -Agent claude -Force

.DESCRIPTION
User scope (default) installs for every project of the current user; project scope installs into
ProjectDir (default: the current directory) so the team gets the skill from the repository. An
existing specflow install is replaced only with -Force, so an upgrade is always a deliberate step.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('claude', 'codex', 'opencode', 'antigravity', 'all')]
  [string[]] $Agent,
  [ValidateSet('user', 'project')]
  [string] $Scope = 'user',
  [string] $ProjectDir,
  [switch] $Force
)
$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$skillSrc = Join-Path $here 'skills/specflow'
$opencodeCmdSrc = Join-Path $here 'adapters/opencode/commands/specflow.md'
if (-not (Test-Path (Join-Path $skillSrc 'SKILL.md'))) { throw "skill source not found at $skillSrc" }

if ($ProjectDir -and $Scope -ne 'project') { throw '-ProjectDir needs -Scope project' }
if ($Scope -eq 'project') {
  if (-not $ProjectDir) { $ProjectDir = (Get-Location).Path }
  if (-not (Test-Path $ProjectDir -PathType Container)) { throw "project dir not found: $ProjectDir" }
  $ProjectDir = (Resolve-Path $ProjectDir).Path
}
if ($Agent -contains 'all') { $Agent = @('claude', 'codex', 'opencode', 'antigravity') }

# OpenCode also loads skills from the Claude Code and Codex folders, and it wants skill names to be
# unique. When one of those agents is installed in the same run, OpenCode gets only its command file.
$opencodeSkill = -not (($Agent -contains 'claude') -or ($Agent -contains 'codex'))

$userHome = [Environment]::GetFolderPath('UserProfile')
$configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $userHome '.config' }

# Where each runtime discovers skills for the chosen scope.
function Get-SkillDir([string] $name) {
  if ($Scope -eq 'user') {
    switch ($name) {
      'claude' { return Join-Path $userHome '.claude/skills' }
      'codex' { return Join-Path $userHome '.agents/skills' }
      'opencode' { return Join-Path $configHome 'opencode/skills' }
      'antigravity' { return Join-Path $userHome '.gemini/config/skills' }
    }
  }
  switch ($name) {
    'claude' { return Join-Path $ProjectDir '.claude/skills' }
    'codex' { return Join-Path $ProjectDir '.agents/skills' }
    'opencode' { return Join-Path $ProjectDir '.opencode/skills' }
    'antigravity' { return Join-Path $ProjectDir '.agents/skills' }
  }
}

# Copy a file or directory, replacing an older copy only with -Force.
function Install-Item([string] $src, [string] $dest) {
  if (Test-Path -LiteralPath $dest) {
    if (-not $Force) {
      Write-Host "  skip: $dest exists (rerun with -Force to replace it)"
      return
    }
    Remove-Item -LiteralPath $dest -Recurse -Force
  }
  $parent = Split-Path -Parent $dest
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  Copy-Item -LiteralPath $src -Destination $dest -Recurse
  Write-Host "  installed: $dest"
}

$doneDirs = @()
foreach ($name in $Agent) {
  $dir = Get-SkillDir $name
  Write-Host "$name ($Scope scope)"
  # Codex and Antigravity share .agents/skills in project scope; copy once.
  if ($doneDirs -contains $dir) {
    Write-Host "  already installed in $dir"
  } elseif ($name -eq 'opencode' -and -not $opencodeSkill) {
    Write-Host '  skill: OpenCode reads the copy installed for Claude Code or Codex'
  } else {
    Install-Item $skillSrc (Join-Path $dir 'specflow')
    $doneDirs += $dir
  }
  if ($name -eq 'opencode') {
    # OpenCode loads skills through its skill tool; a command file gives the /specflow slash command.
    Install-Item $opencodeCmdSrc (Join-Path (Split-Path -Parent $dir) 'commands/specflow.md')
  }
}

Write-Host ''
Write-Host 'Done. Start a new session of your agent in a project and type:'
Write-Host '  Claude Code, OpenCode, Antigravity:  /specflow <your request>'
Write-Host '  Codex:                               $specflow <your request>'
