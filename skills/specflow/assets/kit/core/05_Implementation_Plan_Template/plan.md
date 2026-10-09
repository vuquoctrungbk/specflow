---
title: "{{PROJECT_NAME}} release {{RELEASE}}: Implementation Plan"
description: "Implement every SPEC of release {{RELEASE}} with TDD"
status: pending
priority: "{{PRIORITY}}"
effort: "{{EFFORT}}"
tags: []
created: "{{DATE}}"
doc_type: implementation-plan
version: 0.1.0
template_version: 1.3.0
language: en
release: "{{RELEASE}}"
spec_ids: ["{{SPEC_ID}}"]
parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}} release {{RELEASE}}: Implementation Plan

<!-- fill: One plan for every SPEC of a release (PLAYBOOK §2.5). Copy the whole directory to plans/{YYMMDD-HHmm}-release-<release-slug>/ in the format of CONVENTIONS §9 (no separate tool needed), where <release-slug> is the release label in kebab-case, for example {{RELEASE_SLUG}}. release is the release label in the Release column of SRS §6.1; spec_ids lists every approved SPEC of the release, each SPEC has a file in docs/specs/ and every FR in SPEC §1.5 has a Release equal to release; a SPEC that has a release key has that key equal to the release of the plan (CONVENTIONS §9); plan.md has no spec_id key. parent lists the SPEC files of every element of spec_ids. Each phase is one file phase-NN-<slug>.md copied from phase-01-example-phase.md, NN continuous from 01; the spec_id of a phase is one element of spec_ids, a phase belongs to one SPEC only, the phases of the same SPEC are adjacent, a SPEC that provides a contract comes before the SPEC that consumes that contract, and on each surface the phases of the SPEC that carries the shared foundation of that surface (project skeleton, configuration, shared library, test infrastructure; PLAYBOOK §2.4) come before the phases of other SPECs of the same surface. The Phases table has exactly one line for each phase file, and the Status column matches the status of the phase. The phases cover every SPEC of the release and the File Diff of each SPEC: each SPEC in spec_ids has at least one phase, and the phases that carry the spec_id of one SPEC together MUST cover the whole File Diff and every TC in §9 of that SPEC. The frontmatter assembled_from of the plan and of each phase records "core/05_Implementation_Plan_Template/<file>@<template_version>". The document language: set the language key of the plan and of each phase to the language of the project (the language key of the Intake). Status: plan is pending, in-progress or completed (completed when every SPEC in spec_ids is implemented); phase is todo, in-progress or done. -->

## Overview

- Release: `{{RELEASE}}`; the SPECs of the release are in the table below, the same set as `spec_ids`.
- Approach: <!-- fill: 2 to 3 sentences summarizing the order in which the SPECs are implemented and why, for example the API SPEC before the UI SPEC that uses that API -->
- Verify commands: per the verify commands section in `CLAUDE.md`.

## Release SPECs

<!-- fill: One row for each element of spec_ids, in implementation order. The Phase column gives the numbers of the phases that carry the spec_id of that SPEC, adjacent, for example 1 to 3. The phases cover every SPEC of the release and the File Diff of each SPEC. -->

| SPEC ID | File | Feature | Surface | Phase |
|---------|------|---------|---------|-------|
| {{SPEC_ID}} | `docs/specs/SPEC_{{FEATURE_KEY}}.md` | {{FEATURE_NAME}} | <!-- fill: overlay of the SPEC --> | <!-- fill --> |

## Goals

| # | Goal | Priority |
|---|------|----------|
| 1 | <!-- fill: measurable goal, tied to an AC or INV of a SPEC of the release --> | {{PRIORITY}} |

## Phases

| # | Phase | Status |
|---|-------|--------|
| 1 | [{{PHASE_TITLE}}](./phase-01-example-phase.md) | todo |

Phases are grouped by SPEC: the phases of one SPEC are adjacent, and a SPEC that provides a contract comes before the SPEC that consumes that contract. The default order of phases within a SPEC (an overlay may replace it, give the reason if changed); with Stage 1W, the phases of the interface layer (§3 below) follow the order of the navigation diagram in the wireframe index. In every phase, the tests of the phase are written and run red first, then code is written until green; the phase ends when the verify commands pass and it is committed.

1. Migration, shared data types, contract, DTO and validation schema, with their tests.
2. Business logic and data access: the unit tests and the `CONC` tests of SPEC §9 red then green, then refactor.
3. Interface layer (controller, screen, command) and integration and e2e tests.

## Success Criteria

Equal to the Definition of Done in §12 of each SPEC in `spec_ids`; Stage 5 is judged per SPEC when all phases of that SPEC are done:

- [ ] Every verify command in `CLAUDE.md` meets the pass condition of the verify command table (PLAYBOOK §11).
- [ ] 100% of the tests in §9 of each SPEC pass, in the file and with the name given in the table.
- [ ] The source code of each phase changes only within the File Diff of the SPEC given by the `spec_id` of the phase; otherwise only documents and the plan are updated.
- [ ] Every returned error uses the envelope of ARCHITECTURE §6.2 with a code from §7.1 (surfaces with request/response).
- [ ] No new dependency outside ARCHITECTURE §2 or an `accepted` ADR.
- [ ] Every SPEC in `spec_ids` is in status `implemented`, every phase is in status `done`.

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| <!-- fill --> | <!-- fill --> | <!-- fill --> |

## Version History

<!-- fill: Approval at Gate 4 sets version: 1.0.0 and adds a row with the approver's name in the Approver column. A re-approval per PLAYBOOK §8 rule 7 (adding a phase to a release still in progress) raises MINOR and adds a new row, and the Gate 4 approver approves again. -->

| Version | Date | Edited by | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the pipeline | Not approved |

## Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
|----|------|---------|----------------------|:--------:|---------------|
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |
