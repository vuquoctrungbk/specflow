# specflow

[Tiếng Việt](README.vi.md) · English

**specflow** is an agent skill that writes the documents of a software project
before any code is written, following a spec-first method. You describe
what you want, attach whatever you have (a brief, meeting notes, a spreadsheet
of requirements), and specflow:

1. reads your request and the attachments,
2. drafts the document from its template,
3. asks you the questions it cannot settle, each with ready-made options and a
   recommendation,
4. completes the document, checks it against the stage's exit gate,
5. and stops for your approval before the next stage.

```text
/specflow write the SRS for an internal meeting-room booking app for a 50-person company:
staff see free slots, book and cancel; admins manage rooms; sign-in with the company Google Workspace
```

It runs in **Claude Code**, **Codex** (CLI, IDE extension and ChatGPT Codex),
**OpenCode** and **Google Antigravity**.

## Why specflow

AI coding agents write code fast, and they write the wrong thing just as fast
when the requirement is vague. A longer prompt does not fix that, and neither
does a PRD nobody keeps current: the intent stays in a chat, not in documents
that the next session, the reviewer and the tests can all point at.

specflow moves the decisions into documents before any code, and keeps them
connected:

- **One chain, no gaps.** Requirement → screen → SPEC → test case → roadmap
  row. Every FR traces both ways, and the checker reports a requirement with no
  screen, a SPEC with no test, or a roadmap row with no evidence.
- **A person approves each step.** Each gate names its approver; `gate.py`
  records the approval with a version and a history row, so the agent cannot
  mark its own work approved.
- **Designed once.** The wireframe stage produces a full HTML screen from a
  design system, and the coding stage rebuilds that screen instead of making up
  a second design.
- **Process sized to risk.** A small, low-risk change takes a short path; work
  on identity, money, personal data or public contracts keeps every gate and an
  independent review.
- **Fits your setup.** Markdown plus a few `python3` scripts, in the agent you
  already use. No service, no account.

It does not write your application code and it does not replace your reviewer;
it makes sure both work from the same approved documents.

Also known as: spec-driven development, PRD and SRS generator, requirements to
architecture to plan workflow for AI coding agents.

## What it produces

The method is a three-step pipeline; each stage ends at a gate that a named
person approves.

| Step | Stage | Document | Gate |
| --- | --- | --- | --- |
| 1. Requirements | 0 Intake | `docs/intake/PROJECT_INTAKE.md`: goals, scope, routing (surfaces, stack profile), releases, approvers | Gate 0 |
| | 0R Brownfield baseline | Codebase Summary, As-Is Architecture, Regression Baseline (existing code only) | Gate 0R |
| | 1 SRS | `docs/srs/SRS.md`: ISO/IEC/IEEE 29148 structure, FR in EARS form, NFR mapped to ISO/IEC 25010, use cases, acceptance criteria; once approved, `docs/ROADMAP.md` lists every FR and Must NFR to build, in order | Gate 1 |
| | 1W Wireframe | `docs/wireframes/`: one page per screen, FR ↔ screen traceability, a design system (visual direction, tokens, component catalog), priority information, primary action and edge content per page, numbered layout zones, WCAG 2.2 and Nielsen heuristic checks, deceptive-pattern check. By default each page also gets a **full HTML screen** built from the design system (tokens only, every UI state reachable with `:target`, responsive on the web), so the reviewer approves what the product will look like, not a sketch. `Markdown only` is an option for projects that prefer it | Gate 1W |
| 2. Design | 2 Architecture | `docs/ARCHITECTURE.md` and ADRs in `docs/adr/` | Gate 2 |
| | 3 SPEC | `docs/specs/SPEC_*.md`: one executable contract per part of a release | Gate 3 (per release) |
| 3. Plan | 4a Plan | `plans/<date>-<slug>/`: phases per SPEC, test tables, Definition of Ready | Gate 4 |
| Execution | 4b, 5 | TDD coding in plan order; a phase that builds a screen **rebuilds the approved HTML** instead of designing it again; roadmap updated after each phase and reconciled at each stop, verification, docs sync; at Gate 5 the SPEC's roadmap rows are confirmed and tagged | Gate 5 (per SPEC) |

The process scales with the change. Every SPEC carries `risk: high` or `risk: normal` (identity and permissions, tenant isolation, money, personal data, data-holding schemas and public contracts are `high`). A `high` SPEC keeps the independent review and a stop at each gate; a `normal` feature on a project that already has a baseline takes a small-change path: the requirement, SPEC and plan phase are drafted in one turn and presented to their gates together, then coded and verified before Gate 5. The kit ships small scripts for this (the document checker, the index, and `gate.py`, which records a gate approval); they need `python3`.

**Language.** The kit's rules, templates and the documents it produces are
written in Vietnamese, with English technical terms and identifiers; specflow
talks to you in the language you write in. A document set written entirely in
another language is not supported yet: headings, fixed values such as the gate
and roadmap states, and the approval phrase are in Vietnamese, and the
Intake's language exception only changes the prose. Multi-language output is
planned.

## Install

Pick one method. All of them install the same `skills/specflow/` folder.

specflow is Markdown only, so it runs wherever the agent runs: Windows 10 and
11, macOS and Linux (tested on Ubuntu). In the paths below, `~` is your home
folder: `/home/<you>` on Linux, `/Users/<you>` on macOS, and `%USERPROFILE%`
(`C:\Users\<you>`) on Windows. Every agent uses these same folders on all
three systems; none of them uses `AppData` or `~/Library` for skills.

### Any agent, one command (skills CLI)

Needs Node.js. Installs into every agent you name:

```bash
npx skills add vuquoctrungbk/specflow -a claude-code -a codex -a opencode -a antigravity
```

Add `-g` to install for your user instead of the current project. The CLI
links by default (a junction on Windows, which needs no admin rights); add
`--copy` to copy the files. OpenCode also reads the
folders of Claude Code and Codex, so when you install for either of them, leave
out `-a opencode` to avoid two skills with the same name, and add the OpenCode
command file by hand (see "By hand"). For Antigravity with `-g`, check that the
skill landed in `~/.gemini/config/skills/`, the global folder Antigravity's
documentation names; move it there if not.

### Any agent, from a clone (install script)

macOS and Linux (bash; macOS's built-in bash 3.2 works):

```bash
git clone https://github.com/vuquoctrungbk/specflow.git
cd specflow
./install.sh --agent all                                   # every agent, for your user
./install.sh --agent claude --scope project --project-dir ~/code/my-app   # one agent, one project
```

Windows (Windows PowerShell 5.1 or PowerShell 7):

```powershell
git clone https://github.com/vuquoctrungbk/specflow.git
cd specflow
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent all
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent claude -Scope project -ProjectDir C:\code\my-app
```

`-ExecutionPolicy Bypass` applies to this one run only; it is needed because
Windows blocks unsigned scripts by default. Downloaded the ZIP instead of
cloning? Run `Unblock-File .\install.ps1` first.

Both scripts take the same options: the agent (`claude`, `codex`, `opencode`,
`antigravity` or `all`; `--agent` can be repeated, `-Agent` takes a
comma-separated list), the scope (`user` by default, or `project` with a
project folder), and force. An existing install is kept unless you force,
which replaces it (use it to upgrade). When OpenCode is installed together with
Claude Code or Codex, the scripts give OpenCode only its command file, because
OpenCode already reads their skill folders.

### Claude Code plugin marketplace

```text
/plugin marketplace add vuquoctrungbk/specflow
/plugin install specflow@specflow
```

Plugin skills are namespaced, so the command becomes `/specflow:specflow`.
Install with the script or the skills CLI if you want the plain `/specflow`.

### By hand

Copy `skills/specflow/` (the whole folder) to the agent's skills directory:

| Agent | For your user | For one project | Invoke with |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills/specflow/` | `.claude/skills/specflow/` | `/specflow …` |
| Codex | `~/.agents/skills/specflow/` | `.agents/skills/specflow/` | `$specflow …` or `/skills` |
| OpenCode | `~/.config/opencode/skills/specflow/` | `.opencode/skills/specflow/` | `/specflow …` (needs the command file below) |
| Antigravity | `~/.gemini/config/skills/specflow/` | `.agents/skills/specflow/` | `/specflow …` |

OpenCode also reads skills from `.claude/skills/` and `.agents/skills/`. To get
the `/specflow` slash command there, copy
`adapters/opencode/commands/specflow.md` to `~/.config/opencode/commands/`
(user) or `.opencode/commands/` (project). Without it OpenCode still uses the
skill when you ask for it by name. Some Codex versions look in
`~/.codex/skills/` instead of `~/.agents/skills/`; if `$specflow` is not
listed, copy the folder there.

Restart the agent (or open a new session) after installing.

## Use it

Start a session at the root of your project and call the skill with what you
want. Attach or paste any material you have; specflow treats it as facts about
the project.

| Agent | Example |
| --- | --- |
| Claude Code | `/specflow write the SRS from the attached meeting notes` |
| Codex | `$specflow write the intake for a field inspection mobile app, notes attached` |
| OpenCode | `/specflow draft the architecture for the approved SRS` |
| Antigravity | `/specflow make wireframes for release R1` |

More requests it understands:

- `/specflow start a new project: <brief>`: stage 0, the Intake.
- `/specflow adopt specflow on this repository`: brownfield stages 0 and 0R.
- `/specflow write the SPECs for release R1`: stage 3, one SPEC per turn.
- `/specflow plan release R1`: stage 4a.
- `/specflow continue`: resumes the stage in progress in a new session.
- `approve gate 1, reviewer: Lan`: records the approval, with the reviewer's
  name, and offers the next stage. The kit's own documents write this reply as
  `Duyệt Gate N`; both forms work.

### What a session looks like

1. **First run in a project.** specflow asks before copying its kit (rules and
   templates) into a `specflow/` folder in your repository. Commit it with your documents: the
   documents cite it and later sessions read it.
2. **Missing earlier stages.** Asking for an SRS in a project without an
   approved Intake gives you two options: write the Intake first (recommended;
   the details you gave for the SRS are kept for it), or supply an Intake you
   already have. Each stage still passes its own gate.
3. **Questions.** After a first draft, specflow asks at most five questions per
   round, blocking and contract questions first. Each has two to four options,
   the recommended one first with its reason. Claude Code shows clickable
   choices; OpenCode uses its question tool; elsewhere you get a numbered list
   and can answer `1a, 2c, 3: <your text>`.
4. **The gate.** specflow ends with the files it changed, the exit-gate
   checklist (which rows hold, which do not) and the open questions. The
   approver named in the Intake reviews and replies `approve gate N` with their
   name; only then is the document marked `approved` and the next stage
   started.

### Files in your project

| Path | Written by | Notes |
| --- | --- | --- |
| `specflow/` | specflow, on first run | The rules, templates and scripts; not edited afterwards |
| `docs/…`, `plans/…` | each stage | The documents above |
| `CLAUDE.md` | stage 0 | Project context for later sessions, in every agent |
| `.claude/rules/` | stage 2 | Coding rules for the chosen stack |
| `AGENTS.md` | stage 0, on Codex, OpenCode, Antigravity | A short pointer to `CLAUDE.md`; an existing `AGENTS.md` is never overwritten |

## Upgrade

Reinstall with `./install.sh --agent … --force` or
`npx skills add vuquoctrungbk/specflow …` again. A new specflow may carry a
newer rules than the `specflow/` folder of a project; specflow tells you and
leaves the choice to you, because changing the rules in the middle of a
release can affect documents under review. See `CHANGELOG.md`.

## Repository layout

```text
skills/specflow/
  SKILL.md                 how the skill works
  references/              routing, interview protocol, project setup
  assets/kit/              rules, templates and scripts (VERSION names the rules version)
adapters/opencode/commands/specflow.md   /specflow command for OpenCode
.claude-plugin/            Claude Code plugin and marketplace manifests
install.sh                 installer for macOS and Linux
install.ps1                installer for Windows
```

## Troubleshooting

- **`/specflow` is not listed.** Start a new session; check the folder sits
  directly under the skills directory (`…/skills/specflow/SKILL.md`). In
  Codex use `$specflow`. In OpenCode install the command file.
- **The agent writes code or skips a gate.** Reply with the gate rule: code
  waits for an approved plan, and each stage waits for `approve gate N`. The
  kit's rules are in `specflow/PLAYBOOK.md` sections 1.2 and 7.
- **Questions arrive as plain text instead of clickable options.** Your agent
  has no question tool in the current mode; answer in the `1a, 2b` form.
- **Windows: the agent's shell is PowerShell.** Codex on Windows, and some
  other agents, run commands in PowerShell rather than a POSIX shell. specflow
  runs the kit's checks with PowerShell equivalents, so no setup is needed;
  installing Git for Windows lets agents that prefer Git Bash use it.
- **Windows: `install.sh` fails with `$'\r': command not found`.** Use
  `install.ps1` instead, or run `install.sh` from a fresh clone in Git Bash
  (the repository keeps shell scripts with LF line endings).

## License

MIT, including the kit in `skills/specflow/assets/kit/`.
See [LICENSE](LICENSE).
