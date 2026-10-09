---
doc_type: agent-context
status: draft
version: 0.1.0
template_version: 2.8.0
language: en
parent: [docs/intake/PROJECT_INTAKE.md]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}}: guide for Claude Code

## Documentation Layout

<!-- BEGIN: docs-layout-override -->
This project uses the specflow document layout. Ignore the global rule's set of document names `project-overview-pdr.md`, `system-architecture.md`, `code-standards.md`, `deployment-guide.md`, `codebase-summary.md`, `project-roadmap.md` and do not create those files. Their roles are replaced as follows:

| Name in the global rule | Replaced by in the specflow layout |
| --- | --- |
| `project-overview-pdr.md` | `docs/intake/PROJECT_INTAKE.md` and the SRS in `docs/srs/` |
| `system-architecture.md` | `docs/ARCHITECTURE.md` |
| `code-standards.md` | ARCHITECTURE §1 (Golden Rules), §7 (conventions) and `.claude/rules/` |
| `deployment-guide.md` | ARCHITECTURE §8 (Deployment) and §11 (CI/CD) |
| `codebase-summary.md` | ARCHITECTURE §4 (layout); a brownfield project uses `docs/brownfield/CODEBASE_SUMMARY.md` |
| `project-roadmap.md` | `docs/ROADMAP.md`, the Implementation Plan in `plans/` and the scope in SRS §1.2 |

```text
specflow/                                 # the specflow template set, read-only
docs/
├── intake/PROJECT_INTAKE.md
├── ROADMAP.md                        # work to do, progress, milestones (CONVENTIONS §11)
├── INDEX.md                          # index built by specflow/scripts/project-index.py, never edited by hand
├── gates/GATE-N.md                   # approval ledger of each gate, written by specflow/scripts/gate.py, never edited by hand
├── srs/SRS.md                        # monolithic
├── srs/00_SRS_MASTER.md              # modular: overview, NFRs, shared data model
├── srs/SRS_MODULE_<NAME>.md          # modular: the use cases of one module
├── wireframes/00_WIREFRAME_INDEX.md  # when there is a UI (Stage 1W): index, FR traceability
├── wireframes/SCR-<MOD>-NN.md        # one page per screen
├── wireframes/html/SCR-<MOD>-NN.html # a static HTML screen per page, when the Intake asks for HTML
├── ARCHITECTURE.md
├── architecture/                     # companion files of ARCHITECTURE (CONVENTIONS §7)
├── adr/NNNN-<slug>.md
├── specs/SPEC_<FEATURE_KEY>.md
├── specs/SPEC_<FEATURE_KEY>.*        # companion files of a SPEC, not .md (CONVENTIONS §7)
├── prompts/PROMPT_<NAME>.md          # only with the ai-llm-app overlay
├── design-system/DESIGN_SYSTEM.md    # when there is a UI (Stage 1W): the design system
├── design-system/tokens.json         # source tokens, DTCG format
└── brownfield/                       # brownfield projects only
    ├── CODEBASE_SUMMARY.md
    ├── AS_IS_ARCHITECTURE.md
    ├── REGRESSION_BASELINE.md
    ├── GAP_ANALYSIS.md
    └── MIGRATION_PLAN.md
plans/{YYMMDD-HHmm}-{slug}/plan.md    # Implementation Plan, format in CONVENTIONS §9
plans/{YYMMDD-HHmm}-{slug}/phase-NN-<slug>.md
plans/reports/                        # agent reports
CLAUDE.md
.claude/rules/*.md
```

The Implementation Plan and reports live in `plans/` in the format of CONVENTIONS §9 (no separate tool needed); do not create `IMPLEMENTATION_PLAN.md` at the root. When the global rule and the specflow documents disagree about the layout or the documentation process, the specflow documents win within this project. The other global rules (development rules, git, process management) stay in force.
<!-- END: docs-layout-override -->

SRS storage mode of the project: `{{DOCS_MODE}}` (PLAYBOOK §5).

<!-- fill: Copy this file to CLAUDE.md at the project root; keep the Documentation Layout section as the first section and keep the block between the two marker lines verbatim (including the two marker lines). Stage 0 creates the initial version: a section that lacks data is replaced by the line "Complete at Stage 2."; Stage 2 completes everything and creates the files in Appendix A. If there is a starter, use the starter's CLAUDE.md.template in place of this file. Do not copy Appendix A into CLAUDE.md: Stage 2 reads Appendix A from the template in specflow/ to create the rule files. The frontmatter assembled_from records the sources per CONVENTIONS §3. -->

## 1. Project

| Field | Value |
| --- | --- |
| Name | {{PROJECT_NAME}} |
| Goal | <!-- fill: 1 to 2 sentences from Intake §2 --> |
| Surfaces (overlays) | `{{OVERLAYS}}` |
| Stack profile per surface | <!-- fill: overlay and profile, per Intake §14 --> |
| Mode | <!-- fill: choose one: greenfield \| brownfield --> |
| Intake | `docs/intake/PROJECT_INTAKE.md` |

## 2. Documentation Workflow

- The process and gates follow `specflow/PLAYBOOK.md`; prompts follow `specflow/PROMPTS.md`; the format contract follows `specflow/CONVENTIONS.md`. These files and every file in `specflow/` are read-only.
- The process has 3 steps and an execution stage (PLAYBOOK §2): 1. Requirements (Stage 0 Intake, 1 SRS, 1W Wireframe when there is a UI); 2. Design (Stage 2 Architecture and ADR, 3 every SPEC of the release); 3. Plan (Stage 4a plan of the release); execution (4b Coding TDD, 5 Verify and Sync Docs per SPEC). Stage 1W of this project: <!-- fill: choose one: Yes | No, per Intake §14 -->.
- Do not write code until the Definition of Ready (PLAYBOOK §10.1) is met. Stop at every gate for the approver to decide.
- The roadmap `docs/ROADMAP.md` (CONVENTIONS §11) is the list of work to do: read it at the start of each session; when coding, follow the phase order of the plan and do not skip over any `Not started` line; update it after each phase (PLAYBOOK §2.5); record a new requirement in section 3 of the roadmap and do not act on it immediately; set `Confirmed` and tag only on receiving "Approved at Gate 5" (PLAYBOOK §2.7).
- Document lookup: read `docs/INDEX.md` before opening any other document. Find where an ID or an error code is defined with `python3 specflow/scripts/project-index.py .` plus `--where` and that ID; see the sections of a document with their line ranges with `--outline` and the file path; then read only the line range you need. Do not scan the whole `docs/` directory with a search command to find an ID.
- After editing a document: run `python3 specflow/scripts/project-index.py .` to rebuild the index and `bash specflow/scripts/check-templates.sh --project .` to check; fix every error it reports in the document you just edited. Do not write your own script to check what the checker already checks.
- SPEC and ARCHITECTURE stay within the size ceiling of CONVENTIONS §7; a long machine-readable block (API contract, data schema, sample code) goes in a companion file and is opened only when the work in hand needs its content.
- New project and new release: one stage per turn. A change on a project that already has a baseline: one turn edits every document the change needs and presents the gates merged (specflow/PLAYBOOK.md §8). End the turn with the list of changed files, the exit gate checklist and Open Questions.
- Details: `.claude/rules/docs-workflow.md`.
<!-- fill: A brownfield project keeps the three lines below; a greenfield project deletes these three lines. -->
- Brownfield: follow `specflow/brownfield/PLAYBOOK_BROWNFIELD.md`, which holds the additions for each prompt in §6.1; §5 of that file wins over other repo rules in a conflict. Stage 0R does not modify product code; the only exception to the rule of no code before DoR and the rule of committing only files in the File Diff is the `REG` test in its own commit per §5.1 when Intake §4 allows it. At Stage 0R, project commands run only in a clean worktree, when every data store and external service points to a local or disposable target (`docs/brownfield/CODEBASE_SUMMARY.md` §2); from Stage 1, commands run in the working directory with those variables set explicitly per §5.4 rule 6. Do not open env files that are not template files; do not write secrets or personal data into documents.
- Brownfield: do not refactor outside the File Diff of the SPEC in progress, even when the code looks like it needs improvement; record the proposal in the `Assumptions & Open Questions` section.
- Brownfield: keep every behavior in `docs/brownfield/REGRESSION_BASELINE.md` unchanged, except behavior approved for change in `docs/brownfield/GAP_ANALYSIS.md` §5; run the `REG` tests before and after each phase.

## 3. Context Loading

| Current work | Read | Do not read |
| --- | --- | --- |
| Write or edit the SRS | Intake, the SRS template of the stage, the chosen overlay and profile | Architecture and Spec templates, source code |
| Write or edit wireframes (Stage 1W) | Per `specflow/PLAYBOOK.md` §6, row 1W | Stack profile, Architecture and Spec templates, source code |
| Write or edit ARCHITECTURE, ADR | Intake, SRS, the wireframe index when there is Stage 1W, the Architecture template of the stage, profile, `specflow/core/03_ADR_Template.md` | Spec template, source code |
| Write the SPECs of the release | `docs/ARCHITECTURE.md`, the part of the SRS that holds the FRs, the FR ID and Release columns in SRS §6.1, the frontmatter of every SPEC and §1.5 of the SPECs in the release (key `release`; for a SPEC without the key, read its §1.5, the release follows the Release of the FR, PLAYBOOK §2.4), the TC ID column in §9 of every SPEC with the same module code (to number the next TC, CONVENTIONS §4), the wireframe index and the wireframe pages of the `SCR-*` that the FRs cite, related ADRs, the source code of the module | The rest of the SRS of other modules, the content of other SPECs beyond the frontmatter, §1.5 and the TC ID column in §9, other wireframe pages, the source code of other modules |
| Plan the release | Every SPEC in the release's `spec_ids`, the SRS §6.1 rows of the FRs in the release and the SRS §8 rows of the ACs that the release's SPECs cite, the wireframe index and the pages of the `SCR-*` that the release's SPECs cite (when there is Stage 1W), ARCHITECTURE §1, §4, §5, §7, `specflow/core/05_Implementation_Plan_Template/` | The full SRS (read only the rows named), wireframe pages not cited by the release's SPECs, SPECs outside the release |
| Code | `docs/ROADMAP.md` when present, the plan and the phase in progress, the SPEC per the phase's `spec_id`, ARCHITECTURE §1, §4 to §7, the files in the File Diff | Files outside the File Diff, other SPECs |
| All work | This file | The `examples/` of the template set, the old template set |

Full table: `specflow/PLAYBOOK.md` §6.

## 4. Build, Test & Verify

Run before every commit; the pass condition follows PLAYBOOK §11. When a command reports an error, stop, fix it, and rerun the whole set. If the same test or verify command still fails with the same error after 3 consecutive fixes, including inside the red-to-green loop, stop and report the error, the approaches tried and the options (PLAYBOOK §7 rule 11).

<!-- SLOT: playbook.verify-commands -->
<!-- slot-hint: The overlay provides the verify command table of the surface; the concrete commands come from the chosen stack profile. -->

## 5. Golden Rules

<!-- fill: summarize the 5 to 8 most important rules from docs/ARCHITECTURE.md §1.2, one rule per line. Full version: docs/ARCHITECTURE.md §1.2 and .claude/rules/coding-golden-rules.md. -->

## 6. Ambiguity

- Record every assumption in the `Assumptions & Open Questions` section of the document in progress; do not resolve ambiguity silently.
- Ambiguity that touches scope, API, schema, security or personal data: stop and ask. Minor ambiguity: pick the safest assumption, record it, continue.
- When a SPEC conflicts with existing code or with ARCHITECTURE: stop, report `file:line` and the document section, give options; do not choose on your own.
- Batch questions into one turn, at most 5 questions, each with a proposed option.

## 7. Language

Documents are written in the language of the project (the language key of the Intake frontmatter). Technical terms stay in English; code identifiers, file names, table and column names, error codes, requirement IDs, commit messages and test names are always English (CONVENTIONS §5). Do not change language midway through a document.

## 8. Git

- Conventional Commits in English; one commit per phase of the Implementation Plan; the message describes behavior and contains no process ID.
- Do not commit secrets, real environment variable files or personal data.
- Commit only files in the File Diff of the SPEC in progress, plus the updated documents and plan.
- A SPEC that passes Gate 5: an annotated tag on the last phase commit of the SPEC per the Tag format line in Intake §14; push the tag when the approver allows it.

## 9. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill: assumption about the environment, commands, conventions not yet settled --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## Appendix A: files in `.claude/rules/`

<!-- fill: This appendix does not belong in CLAUDE.md. At Stage 2, create each file below from the corresponding block (drop the opening and closing code fence lines), fill the placeholders (paths lists one glob per source directory), set assembled_from to "core/06_Agent_Context_Template.md@<template_version>" and the rule's template_version equal to the template_version of this template, then add the rules of each overlay: a starter already includes them in sections A.3 onward; without a starter, copy from specflow/overlays/<surface>/agent-rules/. -->

### A.1. `.claude/rules/docs-workflow.md`

```markdown
---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 2.2.0
language: en
parent: [CLAUDE.md]
overlays: []
assembled_from: []
---

# Documentation Workflow

- The pipeline has 3 steps and an execution stage (specflow/PLAYBOOK.md §2): step 1 Requirements covers Stage 0 Intake, 1 SRS, 1W Wireframe when there is a UI; step 2 Design covers Stage 2 Architecture and ADR, 3 every SPEC of the release; step 3 Plan covers Stage 4a plan of the release; execution covers 4b coding TDD and 5 Verify and Sync Docs per SPEC, which may be merged for a SPEC with risk: normal (specflow/PLAYBOOK.md §2.6). Each stage stops at a gate, except for the merged presentations in specflow/PLAYBOOK.md §5 and §8; do not move to the next stage without an approval.
- Each stage uses the exact prompt in specflow/PROMPTS.md and the exact context loading list in §6.
- After assembling a template, run the leftover check in specflow/PLAYBOOK.md §4; the result MUST be empty.
- Document changes follow specflow/PLAYBOOK.md §8: edit freely while the document is draft or in-review; raise the version once when presenting a gate with specflow/scripts/gate.py; stop for approval only when the change touches a public contract, schema, security, scope or a SPEC with risk: high; edit only downstream documents whose content really changes. TCs are recorded only in SPEC §9 and the phase file.
- A discrepancy found while coding: for a SPEC with risk: normal, fix the SPEC on the same branch as the code; for an architecture change or a SPEC with risk: high, record an ADR before merging. An accepted ADR does not change its decision content; create a new ADR and set the old ADR to superseded.
- Do not create documents outside the layout in the Documentation Layout section of CLAUDE.md.
```

### A.2. `.claude/rules/coding-golden-rules.md`

```markdown
---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 2.2.0
language: en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# Coding Golden Rules

- Follow the Golden Rules in docs/ARCHITECTURE.md §1.2, the directory tree in §4 and the schema in §5.
- Modify or create only files in the File Diff of the SPEC being executed; if another file is needed, stop and propose a SPEC change.
- TDD: write the tests per SPEC §9 first, run them red, then write the logic. Use the exact file and test name from the SPEC §9 table; a test name describes behavior and contains no TC ID or process ID.
- Every error leaving the system follows the envelope in docs/ARCHITECTURE.md §6.2 with a code from §7.1; do not invent a new error code.
- Use only libraries in docs/ARCHITECTURE.md §2.1; if a new library is needed, propose an ADR and stop.
- Do not hardcode secrets; do not log secrets, tokens or unmasked personal data.
```
