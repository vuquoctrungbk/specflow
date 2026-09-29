# Changelog

All notable changes to specflow. Versions follow Semantic Versioning. The
version of the rules and templates that a release carries is in
`skills/specflow/assets/kit/VERSION`.

## [1.0.0] - 2026-09-29

### Added

- The `specflow` skill: writes a project's documents stage by stage (Intake,
  baseline of an existing codebase, SRS, wireframes, architecture and ADRs,
  SPECs of a release, implementation plan, verification and docs sync) through
  an interview with options, and stops at each approval gate.
- The specflow kit (rules 2.7.0): playbook, prompts, conventions, templates,
  surface overlays, starters and the brownfield guide, installed into a
  project's `specflow/` folder.
- Installation for Claude Code, Codex, OpenCode and Google Antigravity on
  Windows, macOS and Linux: `install.sh` (bash, including macOS's bash 3.2),
  `install.ps1` (Windows PowerShell 5.1 and PowerShell 7), the skills CLI, a
  Claude Code plugin marketplace, and an OpenCode `/specflow` command file.
- On agents whose shell is PowerShell, the kit's POSIX checks run as
  PowerShell equivalents.
