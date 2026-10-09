---
phase: 1
title: "Phase 1: {{PHASE_TITLE}}"
status: todo
priority: "{{PRIORITY}}"
effort: "{{EFFORT}}"
dependencies: []
doc_type: implementation-phase
version: 0.1.0
template_version: 1.3.0
language: en
spec_id: "{{SPEC_ID}}"
parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]
overlays: []
assembled_from: []
---

# Phase 1: {{PHASE_TITLE}}

<!-- fill: Copy to phase-NN-<slug>.md, NN increasing, and edit phase, title and dependencies (the list of phase numbers that must be done first). spec_id is the SPEC that the phase implements, one element of spec_ids in plan.md; a phase belongs to one SPEC only, the phases of the same SPEC are adjacent; parent is the file of that SPEC. A phase is one committable unit: after the phase, every test of the phase is green and the verify commands pass. The document language: set the language key of the phase to the language of the project (the language key of the Intake). -->

## Overview

- SPEC: `{{SPEC_ID}}` at `docs/specs/SPEC_{{FEATURE_KEY}}.md`, one element of `spec_ids` in `plan.md`.
- Goal of the phase: <!-- fill: 1 to 2 sentences, naming the AC or INV that this phase makes pass -->

## Read First

<!-- fill: One line per document and the sections the agent must read to do this phase, in the form path §section, §section. Get the section numbers with: python3 <kit directory>/scripts/project-index.py . --outline <file>. Keep the three lines below if they are correct, add other SPEC or ARCHITECTURE sections that the phase needs; a phase that builds a screen also cites the wireframe page of the screen and, when the project has HTML, the file `docs/wireframes/html/SCR-<MOD>-NN.html` (read the whole file, no §section), because the phase rebuilds exactly the approved screen (PLAYBOOK §2.5) (for example §3 for a DTO phase, §5 for a migration phase), and delete this note. Companion files are listed only when the phase needs their content -->

- `docs/specs/SPEC_{{FEATURE_KEY}}.md` §1.5, §2, §9
- `docs/ARCHITECTURE.md` §4

## Requirements

- [ ] <!-- fill: verifiable result of the phase -->

## Files

A subset of the File Diff in §2 of SPEC `{{SPEC_ID}}`; MUST NOT touch files outside this table.

| Path | Action | Content |
|------|--------|---------|
| <!-- fill: path in inline code --> | <!-- fill: choose one: create \| edit --> | <!-- fill --> |

## Tests

| TC ID | Type | Test file |
|-------|------|-----------|
| TC-{{MODULE_CODE}}-UNIT-01 | <!-- fill --> | <!-- fill --> |

## Implementation Steps

1. Write or update the tests of the phase per the table above; run them and confirm they are red for the right reason.
2. <!-- fill: concrete implementation step, in order -->
3. Run the tests until green, refactor while the tests stay green.
4. Run the verify commands in `CLAUDE.md`.
5. Commit per the convention in the section below.

## Todo

- [ ] Tests of the phase written and red for the right reason
- [ ] <!-- fill: implementation work -->
- [ ] Tests of the phase green, verify commands pass
- [ ] Commit

## Verification

<!-- fill: list the verify commands that apply to the phase (taken from CLAUDE.md) and the expected result, for example the number of passing tests, exit code 0. -->

## Commit

Conventional Commits in English, one commit for the phase, in the form `type(scope): summary` where type is `feat`, `fix`, `test`, `refactor`, `build` (migration, dependency, build configuration) or `chore` (other changes that do not touch behavior). The message describes the behavior change, contains no process ID (SPEC, TC, phase number) and no secret.

## Success Criteria

- [ ] Every TC in the Tests section is green.
- [ ] No file outside the Files section of the phase is edited.

## Rollback

<!-- fill: how to undo the phase if a later phase finds a design error: revert the commit, reverse the migration, data that needs cleaning. -->

## Risk Assessment

<!-- fill: risks specific to the phase and how to mitigate them; write "No significant risk" if that is the case. -->
