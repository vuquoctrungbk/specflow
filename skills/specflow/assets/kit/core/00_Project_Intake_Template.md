---
doc_type: intake
status: draft
version: 0.1.0
template_version: 1.6.0
language: en
overlays: []
assembled_from: []
---

# Project Intake: {{PROJECT_NAME}}

<!-- fill: Copy this file to docs/intake/PROJECT_INTAKE.md. Fill it from the user's brief; information the brief does not give is recorded as an assumption or a question in §13, never invented. §14 (Routing Decision) is the input of PLAYBOOK §3; fill it last, after the other sections are clear. Frontmatter: overlays records exactly the list in §14, assembled_from records "core/00_Project_Intake_Template.md@<template_version>". The document language: set the language key of this Intake per the Language Confirmation section, and every document generated afterwards carries the same value. -->

## 1. Project Identity

| Field | Value |
| --- | --- |
| Project name | {{PROJECT_NAME}} |
| Short name (slug) | `{{PROJECT_SLUG}}` |
| Project owner | <!-- fill: the person or role with the final decision right --> |
| Created | {{DATE}} |
| Author | {{AUTHOR}} |
| Original brief | <!-- fill: summary of the brief in 3 to 5 sentences, keeping the figures and constraints the user gave exactly --> |

## 2. Problem & Goals

### 2.1. Problem Statement

<!-- fill: who has what problem, how it is solved today, why the current way is not enough. Do not describe a technical solution here. -->

### 2.2. Measurable Goals

| GOAL ID | Goal | Metric | Target threshold | Deadline |
| --- | --- | --- | --- | --- |
| GOAL-01 | <!-- fill: business goal; IDs numbered continuously, the SRS cites this ID in the Source column of FR and NFR (CONVENTIONS §4) --> | <!-- fill: measurable quantity --> | <!-- fill: a concrete number, using ≤ ≥ --> | <!-- fill: date or milestone --> |

### 2.3. Known Non-goals

<!-- fill: what the brief or the project owner has clearly excluded; one item per line. Write "None yet" if the brief does not say. -->

## 3. Project Type & Surfaces

Mark every surface the project has; for each chosen surface, record the evidence from the brief. The table of existing overlays is in PLAYBOOK §3.

| Select | Surface | Indicators | Evidence from brief |
| :---: | --- | --- | --- |
| [ ] | `backend-api` | HTTP or RPC API, data storage, background jobs | <!-- fill: or N/A --> |
| [ ] | `frontend-web` | User interface that runs in a browser | <!-- fill: or N/A --> |
| [ ] | `mobile-app` | Application installed on a phone or tablet | <!-- fill: or N/A --> |
| [ ] | `ai-llm-app` | Feature based on a large language model: prompt, evaluation, guardrail | <!-- fill: or N/A --> |
| [ ] | Other | A surface without an overlay (command-line tool, library, data pipeline, infrastructure) | <!-- fill: describe; handle per PLAYBOOK §3 rule 4, or N/A --> |

## 4. Starting State

| Field | Value |
| --- | --- |
| Mode | <!-- fill: choose one: greenfield \| brownfield. brownfield when the project already has running source code whose behavior must be kept; after Gate 0 a brownfield project goes through specflow/brownfield/PLAYBOOK_BROWNFIELD.md before Stage 1 --> |
| Existing repository | <!-- fill: path or URL, with the HEAD commit at the start (the BASE of the leftover check before there is a Codebase Summary); greenfield: write N/A --> |
| Size of existing code | <!-- fill: estimated lines of code, main language, whether there are tests and a test tool; greenfield: write N/A --> |
| System to replace or integrate with | <!-- fill: or N/A --> |
| REG tests at Stage 0R | <!-- fill: choose one: allowed \| allowed, run on a disposable environment (record the environment) \| allowed, with an added test tool (record name and version) \| not allowed. Brownfield only, default allowed; a repo without a test tool chooses to add a tool or not allowed; if not allowed, the Regression Baseline uses a manual procedure with an accepted risk (specflow/brownfield/PLAYBOOK_BROWNFIELD.md §5.1). Before choosing, read the default test configuration (the configuration files and fixtures of the test runner, defaults in the code; do not open env files) and record whether it points at a running service or database; if it does, choose a disposable environment or not allowed, and record a question in §13; this choice wins over the word "allowed" in the brief because it is a safety condition, and the reason is recorded in §13. Greenfield: write N/A --> |
| Test coverage tool | <!-- fill: choose one: available (record name and version) \| installed temporarily in the measurement worktree (record name and version; no change to the manifest or lockfile) \| added as a dev-dependency in the REG commit (record name and version; approved at Gate 0; the figure at the measured commit still uses the temporary install) \| measured another way (record the method and its limits, for example lines only, no branches). Brownfield only: Regression Baseline §2 needs the coverage figure at the measured commit and after the REG test commit; this row exists since Intake template 1.2.0. Greenfield: write N/A --> |
| Agent documents and configuration already in the repo | <!-- fill: brownfield: CLAUDE.md, AGENTS.md, .claude/, .mcp.json, docs/ already present, each with the proposed handling per specflow/brownfield/PLAYBOOK_BROWNFIELD.md §5.5 and the hooks disabled in Stage 0R. Also list the git hooks that are enabled (.pre-commit-config.yaml, .husky/, hooks in .git/hooks without the .sample suffix, core.hooksPath) with the command each hook runs, because hooks run at once on the commit of the repo preparation step (Prompt B0); the proposed handling is recorded in §13 for approval at Gate 0. Greenfield: write N/A --> |

## 5. Scale Estimate

| Quantity | Estimate | Basis |
| --- | --- | --- |
| Number of modules | <!-- fill: number --> | <!-- fill --> |
| Number of communication units (endpoints, screens, commands) | <!-- fill: number --> | <!-- fill --> |
| Concurrent users at peak | <!-- fill: number --> | <!-- fill --> |
| Data volume after 12 months | <!-- fill: number + unit --> | <!-- fill --> |
| SRS storage mode | `{{DOCS_MODE}}` | <!-- fill: apply the criteria of PLAYBOOK §5 to the numbers above; cross-cutting and shared libraries do not count as modules; brownfield reconsiders at Gate 0R per PLAYBOOK §5 --> |

## 6. Constraints

| Type | Constraint | Source | Negotiable? |
| --- | --- | --- | --- |
| Required technology | <!-- fill: languages, frameworks, services that must be used or are banned; "None" if free --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| Infrastructure and hosting | <!-- fill: provider, data region, on-premise or cloud --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| Budget | <!-- fill: development budget and monthly operating budget --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| Timeline | <!-- fill: launch date, intermediate milestones, and the names of the planned releases in order (for example R1, R2), each release with a milestone and a one-sentence goal. SRS §6.1 uses exactly these labels in the Release column; SPECs and plans are made per release (PLAYBOOK §2). If not yet split into releases, write one release R1 --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| Organization | <!-- fill: internal processes, company security rules; "None" if there are none --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |

## 7. Compliance

| Applies | Compliance framework | Reason it applies | Consequence for the SRS |
| :---: | --- | --- | --- |
| [ ] | Data protection law of the project's country | <!-- fill: name the law and say whether the project processes personal data of the people it covers, or N/A --> | NFR-LEGAL, NFR-DATA |
| [ ] | GDPR | <!-- fill: users in the EU, or N/A --> | NFR-LEGAL, NFR-DATA |
| [ ] | PCI DSS | <!-- fill: stores, processes or transmits payment card data, or N/A --> | NFR-SEC, NFR-LEGAL |
| [ ] | Other | <!-- fill: industry standards, contracts with customers, or N/A --> | <!-- fill --> |

Types of data the system processes: <!-- fill: list personal data, sensitive personal data, financial data, trade secrets; "No personal data" if that is the case -->

## 8. External Integrations

| External system | Purpose | Protocol | Data direction | Required in the first release? |
| --- | --- | --- | --- | --- |
| {{EXTERNAL_SYSTEM}} | <!-- fill --> | <!-- fill: for example REST, webhook, SMTP, SDK --> | <!-- fill: choose one: in \| out \| both ways --> | <!-- fill: choose one: Yes \| No --> |

## 9. Team & Approvers

| Role | Person | Responsibility |
| --- | --- | --- |
| Project owner | <!-- fill --> | Decides scope, approves Gate 0 |
| Tech lead | <!-- fill --> | <!-- fill --> |

| Gate | What is approved | Approver |
| --- | --- | --- |
| Gate 0 | Intake and Routing Decision | {{APPROVER}} |
| Gate 0R | Codebase Summary, As-Is Architecture, Regression Baseline <!-- fill: brownfield only; greenfield deletes this row --> | {{APPROVER}} |
| Gate 1 | SRS | {{APPROVER}} |
| Gate 1W | Wireframe: index, screen pages and the cross-check table with the SRS | {{APPROVER}} <!-- fill: default is the Gate 1 approver; record the product or user experience owner if different. If no surface has a UI (§14 says Stage 1W: No), replace the whole cell with N/A and a reason --> |
| Gate 2 | ARCHITECTURE and ADR | {{APPROVER}} |
| Gate 3 | Every SPEC of a release | {{APPROVER}} |
| Gate 4 | Implementation Plan of the release and DoR | {{APPROVER}} |
| Gate 5 | DoD of each SPEC | {{APPROVER}} |

## 10. Language Confirmation

The language of the project documents is the `language` key in the frontmatter of this Intake (one code from `scripts/locales/`, for example `en` or `vi`); every document of the project carries the same value. The agent sets it when creating the Intake and asks the project owner at Stage 0.

- [ ] The project owner confirmed the language of the project documents.

## 11. Success Metrics

| Metric | Current value | Target | How measured | When measured |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: or "None yet" --> | <!-- fill --> | <!-- fill: tool or procedure of measurement --> | <!-- fill --> |

## 12. Version History

| Version | Date | Edited by | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version from the brief | Created by the pipeline | Not approved |

## 13. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill: a question that touches the contract but does not block the Routing Decision also says "answer before Gate 1" (PLAYBOOK §7 rule 3); brownfield: a proposal that needs approval before the repo preparation step says "approved at Gate 0" (specflow/brownfield/PLAYBOOK_BROWNFIELD.md §6.1) --> | <!-- fill: choose one: Yes \| No. Yes is for a question that blocks the Routing Decision; Gate 0 does not allow any remaining Yes --> | <!-- fill --> |

## 14. Routing Decision

<!-- fill: This block decides which templates are used at every later stage. Every field MUST have a value before Gate 0. -->

| Field | Value |
| --- | --- |
| `overlays` (in assembly order) | `{{OVERLAYS}}` |
| `starter` | <!-- fill: name of the directory in starters/ that matches the overlays combination exactly (PLAYBOOK §3), or none --> |
| `mode` | <!-- fill: choose one: greenfield \| brownfield, matching §4 --> |
| `docs_mode` | `{{DOCS_MODE}}` |
| Stage 1W (Wireframe) | <!-- fill: choose one: Yes, with full HTML \| Yes, Markdown only: <reason> \| No. Default is Yes, with full HTML when overlays has frontend-web or mobile-app, or another surface that has screens; for No, Gate 1W in §9 says N/A (PLAYBOOK §2) --> |
| Tag format | `{release}-{feature-key}` <!-- fill: the tag name pattern the agent applies when a SPEC passes Gate 5 (CONVENTIONS §11); keep the default or record another project pattern in backticks, for example `v{release}-{feature-key}` --> |
| Project size | <!-- fill: choose one: standard \| small. small when the project has at most 15 FR, one approver for every gate and no compliance constraint in §7; the gates are then presented merged per PLAYBOOK §5 --> |
| High-risk areas | <!-- fill: directories or words in a path such that any SPEC touching them is risk: high, each in backticks, for example `apps/billing/`, `ledger`; write None when the project has no area of its own beyond the general list in CONVENTIONS §3 --> |
| Approver | Per §9 |

| Overlay | Stack profile | Reason for choice |
| --- | --- | --- |
| <!-- fill: one row for each overlay, in the same order as overlays --> | `{{STACK_PROFILE}}` | <!-- fill: the profile that matches by the criteria in PLAYBOOK §3, with the constraint in §6 or a technical reason; if no profile matches, the Stack profile cell says none, and this column names the base components that do not match and records "proposed at ARCHITECTURE §2" per PLAYBOOK §3 rule 5 --> |
