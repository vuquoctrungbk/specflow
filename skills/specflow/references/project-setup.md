# Project setup

specflow documents are written against a copy of the kit inside the project, at
`specflow/`, and every stage prompt and loading-manifest row names files there.
This file covers installing or upgrading that copy and wiring the project's
agent-context file for the runtime in use.

## Installing the kit

Ask before the first write: installing adds a directory to the user's
repository. When they agree, copy the contents of this skill's
`assets/kit/` directory into `<project>/specflow/`, leaving out
`assets/kit/VERSION` (it records which rules version the skill carries,
not project content). The result is the file set `specflow/PLAYBOOK.md`
section 1.4 lists: `PLAYBOOK.md`, `PROMPTS.md`, `COMPATIBILITY.md`,
`CONVENTIONS.md`, `CHANGELOG.md`, `core/`, `overlays/`, `starters/`,
`brownfield/`, `scripts/`.

Suggest committing `specflow/` with the documents, because approvers and later
sessions review the documents against the rules that were in force when they
were written.

The project's documents then live where CONVENTIONS section 6 puts them
(`docs/`, `plans/`, the agent-context file), never inside `specflow/`. PLAYBOOK
section 7 rule 8 says the agent does not edit `specflow/`; installing it, or
replacing it whole in an upgrade the user agreed to, is the one exception, and
no single file in it is ever changed.

Before treating an existing `specflow/` as the kit, check that it holds
`PLAYBOOK.md` and `CHANGELOG.md`; before removing it in an upgrade, check the
same, so a folder of the same name that is not the kit is never deleted.

## Upgrading the kit

When the skill carries newer rules than the project's `specflow/`, tell the
user and let them decide; an upgrade in the middle of a release can change the
rules of documents already under review. To upgrade, replace `specflow/`
entirely (remove the old directory, then copy), as PLAYBOOK section 1.4 says,
and read `specflow/CHANGELOG.md` for the versions skipped. Documents already
approved stay valid: newer rules apply to documents created from newer
templates, and `specflow/COMPATIBILITY.md` says what older documents keep.

## The agent-context file in each runtime

The kit writes the project's agent context as `CLAUDE.md` at stage 0 and adds
`.claude/rules/*.md` at stage 2 (template
`specflow/core/06_Agent_Context_Template.md` or a starter's
`CLAUDE.md.template`). Keep those names in every runtime: the
loading manifest, later prompts and approvers all refer to them. What changes
between runtimes is which file the runtime loads by itself at the start of a
session.

| Runtime | Loads by itself | What to add at stage 0 |
| --- | --- | --- |
| Claude Code | `CLAUDE.md`, and rules in `.claude/rules/` | Nothing |
| Codex | `AGENTS.md` | `AGENTS.md` pointing to `CLAUDE.md` and `.claude/rules/` |
| OpenCode | `AGENTS.md`, falling back to `CLAUDE.md` | `AGENTS.md` pointing to `CLAUDE.md` and `.claude/rules/`, so the rules files are read too |
| Antigravity | `AGENTS.md`, `GEMINI.md`, `.agents/rules/*.md` | `AGENTS.md` pointing to `CLAUDE.md` and `.claude/rules/` |

A pointer `AGENTS.md` needs only a short paragraph, in the project's document
language, saying that the project follows specflow and that the agent reads
`CLAUDE.md` and every file in `.claude/rules/` before working. List the file in
the stage 0 output so the approver sees it.

If `AGENTS.md` already exists, as it often does in a brownfield repository,
do not overwrite it (`specflow/brownfield/PLAYBOOK_BROWNFIELD.md` section 5.5):
propose the paragraph to the user and let them add it.

## Where specflow itself is installed

For reference when a user asks why `/specflow` is missing. Skill folders:

| Runtime | User scope | Project scope | How it is invoked |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills/specflow/` | `.claude/skills/specflow/` | `/specflow <request>`; installed as a plugin it is `/specflow:specflow <request>` |
| Codex | `~/.agents/skills/specflow/` (some installers use `~/.codex/skills/`) | `.agents/skills/specflow/` | `$specflow <request>`, or pick it from `/skills` |
| OpenCode | `~/.config/opencode/skills/specflow/` | `.opencode/skills/specflow/`; also reads `.claude/skills/` and `.agents/skills/` | `/specflow <request>` through a command file `commands/specflow.md` next to the skills directory, or by asking for the specflow skill |
| Antigravity | `~/.gemini/config/skills/specflow/` | `.agents/skills/specflow/` | `/specflow <request>` |

The repository README keeps the install commands; runtimes change these paths
over time, so check the runtime's documentation when a path does not work.
