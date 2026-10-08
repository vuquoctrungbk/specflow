# Changelog

All notable changes to specflow. Versions follow Semantic Versioning. The
version of the rules and templates that a release carries is in
`skills/specflow/assets/kit/VERSION`.

## [2.2.0] - 2026-10-08

The kit carries rules 3.2.0. The approved screen now binds the coding stage, so
a screen is designed once instead of twice.

### Changed

- A phase that builds a screen reads the approved HTML of that screen and
  rebuilds it — zones, components, states and tokens — instead of designing a
  second version; a different design means changing the wireframe and having it
  approved again. The Read First section of such a phase names the screen page
  and its HTML file, and the checker refuses a phase that names the page but not
  the drawing.
- The Definition of Done and the verify prompt compare the built screen with the
  approved HTML.
- The screen page owns structure, components, states, acceptance criteria and
  navigation; the HTML owns the visual decisions the page cannot express.

## [2.1.0] - 2026-10-08

The kit carries rules 3.1.0. A wireframe stage now produces a full screen in
HTML by default, not an optional low-fidelity sketch.

### Changed

- The Intake records stage 1W as one of `Có, kèm HTML đầy đủ` (the default for a
  project with a UI), `Có, chỉ Markdown: <reason>` or `Không`. With the default,
  every screen page gets `docs/wireframes/html/SCR-<MOD>-NN.html`: a full screen
  built from the design system, with every visual value taken from a token, one
  `data-cmp="CMP-NN"` element per row of the component table, one element per UI
  state that the reviewer reaches with `:target`, a viewport meta tag, and a
  media query on a web page. A screen drawn inside a flow has no HTML file.
- An Intake from an earlier template keeps the older choices (`Có`, `Có, kèm
  HTML low-fi`), where the HTML stays optional.
- The kit ships `scripts/check-full-html.py`, which the checker runs, and the
  worked web and mobile examples now carry a full HTML file for every screen.

## [2.0.0] - 2026-10-07

The kit carries rules 3.0.0. The process now scales with what a change touches
and how risky it is, not with the number of documents. This is a major release
because the rules for changing and closing documents differ from 1.x.

### Added

- `risk: high|normal` on every SPEC. The agent proposes the level, the Gate 3
  reviewer confirms it, and the checker refuses `normal` when the File Diff
  touches identity, tenancy, money, personal data, a schema that holds data or
  a published contract. `high` keeps the independent review with mutation
  testing; `normal` is verified by checklist and synced in the same turn.
- A small-change path: one request on a project that already has a baseline,
  whose SPEC is `normal`, is drafted in one turn, presented to its gates once,
  then coded, verified and synced before Gate 5.
- `scripts/gate.py` records a gate approval (status, version, history row,
  `docs/gates/GATE-N.md`, index) and refuses a batch with an open `BLOCKING`
  question, a wrong status, or a checker error in the presented document.
  `approve --bump --note` raises a version once, when the change is presented.
- Releases are vertical slices of one to three SPECs; the checker enforces the
  order of releases. Spikes, flow-based wireframes (`Theo luồng`), a `small`
  project size that merges stops, and a Read First section in each plan phase.

### Changed

- A `draft` or `in-review` document is edited freely; its version rises once,
  at the gate. Only a change to a public contract, a schema, security, scope
  or a `high` SPEC stops for approval; other changes are approved once, with
  the pull request.
- Test cases live only in SPEC section 9; `docs/INDEX.md` section 5 maps
  AC and NFR to them. The SRS no longer carries a TC column.
- Acceptance run on one small feature: a probe run with a `normal` SPEC cost
  about half of the 2.10.1 baseline, but two later runs, where the agent rated
  the same feature `high`, cost 7% less on average and read 30% more cache
  (the independent review is extra work the old rules did not require). The
  saving of the light path rests on one run.
- The kit carries rules 3.0.0 and its scripts: the checker, the index, the
  gate script.

## [1.3.1] - 2026-10-03

### Fixed

- The roadmap counts only SPECs and plans that passed their gate (version
  1.0.0 or later). Before, a draft SPEC or plan made a correct roadmap look out
  of date between writing the SPECs and approving Gate 3, or between writing
  the plan and approving Gate 4.
- With a modular SRS, FRs without a phase follow the module order of the
  master file's section 6 table.
- The kit carries rules 2.10.1.

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
