# Changelog

All notable changes to specflow. Versions follow Semantic Versioning. The
version of the rules and templates that a release carries is in
`skills/specflow/assets/kit/VERSION`.

## [1.3.0] - 2026-10-03

### Added

- Project roadmap. Once the SRS passes Gate 1, specflow builds
  `docs/ROADMAP.md`: every FR other than `Won't` and every Must NFR, in the
  order the work will be done, with its SPEC, phases, status, evidence and the
  tag of each confirmed SPEC. The coding agent follows the plan's phase order,
  never skips a row that is still `Chưa làm`, updates the roadmap after each
  phase, reconciles it with the SRS, SPECs, plans and git at every stop, and
  only marks rows `Đã xác nhận` (with an annotated tag) when the reviewer
  approves Gate 5. New ideas raised while coding go to the roadmap's New
  Requests section and wait for a decision.
- The Intake gains a `Định dạng tag` row (default `{release}-{feature-key}`);
  a SPEC that passes Gate 5 again gets a `-2`, `-3` suffix.
- The coding agent stops when the same test or verify command fails with the
  same error after three fixes in a row, and reports what it tried.

### Changed

- The kit carries rules 2.10.0. Gate 5 is approved after Prompt 6, once the
  SPEC is `implemented`. The roadmap rules apply to projects whose Intake is
  1.4.0 or newer; older projects stay valid and can upgrade as described in
  `COMPATIBILITY.md` in the kit.

## [1.2.0] - 2026-10-02

### Added

- Each wireframe page now states its priority information (one to three items,
  the first one at the top of the layout), its primary action (a label from the
  page's component table, or `Không` with a reason), and its edge content (edge
  cases taken from the SRS constraints and how the page shows them).
- Low-fi layouts number their zones (`== 1. Header ==`, side by side
  `== 2. List | 3. Detail ==`, dialogs `== 4. Hộp thoại: Name ==`), so review
  comments can point at a screen ID plus a zone number. The HTML wireframe
  carries the same numbers.

### Changed

- The kit carries rules 2.9.1. The new lines apply to pages from screen
  template 1.5.0; pages from 1.4.0 stay valid, and one wireframe set may mix
  both (see `COMPATIBILITY.md` in the kit).

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
