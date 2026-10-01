# Changelog

All notable changes to specflow. Versions follow Semantic Versioning. The
version of the rules and templates that a release carries is in
`skills/specflow/assets/kit/VERSION`.

## [1.1.0] - 2026-10-01

### Added

- Design system step in stage 1W: before the screen pages, specflow proposes two
  or three visual directions, you pick one, and it builds `docs/design-system/`
  (foundations, DTCG `tokens.json`, component, pattern and template catalogs).
  Each screen page names one template, its patterns and component IDs; the HTML
  wireframes read the tokens through CSS custom properties. Gate 1W gains rows
  for the chosen direction, token contrast (WCAG 2.2 1.4.3 and 1.4.11) and the
  catalog.
- Stage 2 maps the tokens into code (Tailwind, shadcn variables, React Native
  theme) and adds a golden rule that forbids raw color, spacing, radius and font
  size values outside the token mapping file.

### Changed

- The kit carries rules 2.8.0. The new rules apply only to projects whose Intake
  is 1.3.0 or newer and to wireframes from the new templates; older documents
  stay valid (see `COMPATIBILITY.md` in the kit). Adding a page to an older
  wireframe means upgrading the whole wireframe first.

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
