---
doc_type: playbook
status: stable
version: 4.0.0
language: en
---

# Prompts for Claude Code (specflow Prompts)

Run each prompt in a Claude Code session at the project root. Each prompt names the files to read, the files to produce and the stop condition. You replace the placeholders (CONVENTIONS §1) before sending; `<starter>`, `<surface>`, `<NAME>`, `<slug>`, `{YYMMDD-HHmm}` and the placeholder `{{RELEASE_SLUG}}` are values the agent determines itself from the Routing Decision, `{{RELEASE}}` and the current date and time; you do not replace them. "The stage's" is as defined in PLAYBOOK §4. A brownfield project applies the additions for each prompt in §6.1 of `brownfield/PLAYBOOK_BROWNFIELD.md` and uses Prompts B0 to B4 in §6 of that file.

The opening sentence "X approved" of the prompts below, and the Intake, SPEC and Plan rows with status `approved` in the Definition of Ready (PLAYBOOK §10.1), all follow the gate approval procedure in PLAYBOOK §2.7.

## Prompt 0: Intake

```text
Start a new project using the specflow template set installed in the specflow/ directory.

Project description:
{{PROJECT_BRIEF}}

Read: specflow/PLAYBOOK.md §1 to 7, specflow/CONVENTIONS.md, specflow/core/00_Project_Intake_Template.md.

Tasks:
1. Create docs/intake/PROJECT_INTAKE.md from the Intake template, fill every section; a section that does not apply says N/A with a reason. Set `language` and ask me to confirm it (Intake §10) before any other document.
2. Decide the Routing Decision block: overlays in order, the stack profile of each overlay (a profile matches per PLAYBOOK §3, read the Tech Stack section of the profile before deciding; if no profile matches, write none), starter, mode, docs_mode, whether there is Stage 1W (PLAYBOOK §2), the approver of each gate including Gate 1W. Record the names of the planned releases in the Timeline row of Intake §6.
3. Create the initial CLAUDE.md from the stage's Agent Context (specflow/starters/<starter>/CLAUDE.md.template if there is a starter; otherwise specflow/core/06_Agent_Context_Template.md) and apply the stack profile per PLAYBOOK §4 (stack profile none: follow specflow/CONVENTIONS.md §2). Copy the Documentation Layout section verbatim; a section without enough data yet is replaced with the line "Complete at Stage 2." (brownfield project: the verify commands section per PLAYBOOK §2.1); do not copy Appendix A.
4. Record assumptions and questions in Assumptions & Open Questions per PLAYBOOK §7 rule 3. Create a draft of the two files, then ask once, merging at most 5 questions: questions that block the Routing Decision first, then questions that touch scope, API, security or personal data. A remaining question that touches the contract is recorded as BLOCKING: No with "answer before Gate 1"; other questions are recorded as assumptions.

Stop when: the two files are created, the leftover check command in PLAYBOOK §4 returns empty (a brownfield project uses the command in specflow/brownfield/PLAYBOOK_BROWNFIELD.md §5.5 instead of the command in §4) and the exit gate in §2.1 has been self-checked. Do not create the SRS, do not write code.
```

## Prompt 1: SRS

```text
Intake approved. Start Stage 1.

Read: per specflow/PLAYBOOK.md §6, row "1. SRS" and the line that applies to every row.
Template: the stage's SRS (specflow/starters/<starter>/SRS_Template.md if there is a starter; otherwise specflow/core/01_SRS_Template.md assembled with specflow/overlays/<surface>/srs-sections.md after reading specflow/overlays/<surface>/OVERLAY.md), applying the stack profile of each surface per PLAYBOOK §4.

Tasks:
1. Create the SRS per the docs_mode of the Intake (monolithic: docs/srs/SRS.md; modular: docs/srs/00_SRS_MASTER.md and docs/srs/SRS_MODULE_<NAME>.md).
2. Fill every section: context diagram, actors, constraints (including operations, memory, adaptation to the deployment site), standards to comply with, external interfaces, logical data model, Business Rules, FR with EARS statements per specflow/CONVENTIONS.md §8 and use cases with exception flows and error codes, measurable NFR with verification method, the FR → AC matrix and the NFR table in §8 (TC is not recorded in the SRS).
3. A surface with a UI: the User Interfaces table in SRS §3 lists every screen, each screen with one SCR ID of the form SCR-{MOD}-NN per specflow/CONVENTIONS.md §4; the FR column lists every FR the screen realizes, including shared components such as the Logout button in the header. The Release column in §6.1 uses exactly the release names in Intake §6; split the FRs so that each release is a vertical slice of 1 to 3 SPECs, the first release containing the foundation and one end-to-end flow (specflow/PLAYBOOK.md §2), and propose more releases in the Intake when a release is too large.
4. Copy into SRS §9 with BLOCKING: Yes, citing the Intake ID, every question in the Assumptions & Open Questions section of the Intake that says "answer before Gate 1" and has no answer yet (PLAYBOOK §7 rule 3).
5. Self-check the Overlay applied checklist for the 3 SRS slots and run the leftover check command in PLAYBOOK §4.

Stop when: the SRS is in status in-review, the exit gate in §2.2 has been self-checked. Do not create wireframes, do not create ARCHITECTURE, do not write code.
```

## Prompt 1W: Wireframe

```text
SRS approved. Start Stage 1W.

Read: per specflow/PLAYBOOK.md §6, row "1W. Wireframe" and the line that applies to every row.
Template: specflow/core/07_Wireframe_Template/.

Tasks:
1. Propose 2 to 3 visual directions per specflow/CONVENTIONS.md §10.7 (based on the brand, users, domain and tone from the Intake, the SRS and your answers), stating clearly that the default theme of the UI library is one direction like any other. Record the proposed directions in docs/design-system/DESIGN_SYSTEM.md (status draft, only §1, the Chosen column says No on every row) so that Prompt Resume sees the trace, then stop and ask you to choose exactly one direction (one question within the stage, not a gate).
2. After you choose: create docs/design-system/DESIGN_SYSTEM.md, docs/design-system/tokens.json and the mode file (when needed) from specflow/core/07_Wireframe_Template/, record the reason for the chosen direction, foundations, the three token tiers, primitives and the component catalog, patterns, templates; compute the contrast table yourself per specflow/CONVENTIONS.md §10.7.
3. Create docs/wireframes/00_WIREFRAME_INDEX.md: the screen catalog with exactly the set of SCR IDs in the User Interfaces table of SRS §3, the navigation diagram, a cross-check table with exactly one row for each FR in SRS §6.1 whose priority is not Won't (a Won't FR has no row), recording SCR-* or "No UI" with a reason; a brownfield project records "Unchanged" for a screen that does not change.
4. A screen with a write action, a permission-dependent display, or personal data: its own page. Other screens: drawn in the mockup of the flow in the index and recorded as In flow in the screen catalog (specflow/PLAYBOOK.md §2.2.1). The own page is in docs/wireframes/, the file name is the SCR ID plus the suffix .md: purpose, priority information, primary action, FR and AC, a low-fi layout in a text block with numbered zones per specflow/CONVENTIONS.md §7 with an edge content line, choose exactly one Template and cite Patterns and Components that are already in the design system catalog, a component table with Component IDs, the five UI states with AC, navigation in and out, an Authentication screen line, accessibility notes per specflow/CONVENTIONS.md §10.2 and the figures in OVERLAY.md. Do not add screens outside SRS §3.
5. HTML: when Intake §14 says Stage 1W "Yes, with full HTML" (default), each page has one file docs/wireframes/html/SCR-*.html per specflow/CONVENTIONS.md §7 and 10.7; "Yes, Markdown only" means no HTML is created.
6. A mismatch with the SRS (screens added, removed or changed; missing FR; AC that does not match a state) per PLAYBOOK §2.2.1: a wireframe drawn wrong or missing something compared with the SRS is fixed in the wireframe. If the SRS is missing or wrong, do not edit the wireframe to cover the mismatch; record a BLOCKING question in the index with a proposed SRS fix; when I agree, fix the SRS per PLAYBOOK §8 so that the Gate 1 approver approves again.
7. In the index, fill the heuristic evaluation table per specflow/CONVENTIONS.md §10.3 and the deceptive pattern check table per §10.4 for the whole index and the pages; fix Critical problems and remove deceptive patterns before stopping. If the SRS must change to fix one, do it as in task 6.
8. Run the leftover check command in PLAYBOOK §4.

Stop when: the index, the pages and the design system documents are in status in-review, the exit gate in §2.2.1 has been self-checked. Do not create ARCHITECTURE, do not write code.

Intake §14 says Stage 1W: No: do not run this prompt; after Gate 1 run Prompt 2.
```

## Prompt 2: Architecture and ADR

```text
SRS approved; wireframe approved at Gate 1W when the project has Stage 1W. Start Stage 2.

Read: per specflow/PLAYBOOK.md §6, row "2. Architecture + ADR" and the line that applies to every row.
Template: the stage's Architecture (specflow/starters/<starter>/ARCHITECTURE_Template.md if there is a starter; otherwise specflow/core/02_Architecture_Core_Template.md assembled with specflow/overlays/<surface>/architecture-sections.md) and the stage's Agent Context, applying the stack profile per PLAYBOOK §4.

Tasks:
1. Create docs/ARCHITECTURE.md, fill every section; §2.1 is copied from the Tech Stack section of the stack profile; the Error Code Registry §7.1 receives every code in SRS §6.3. With Stage 1W: the route table (web) or navigation table (mobile) in §3 has an SCR ID column, and each SCR-* of the wireframe index has at least one row. With `docs/design-system/`: record how tokens map into code (web: CSS variables and Tailwind @theme, shadcn theme through variables; mobile: theme object) per OVERLAY.md and the profile in the UI conventions section, written by hand or generated with a tool the project chooses (Style Dictionary is one option, not required), the theme of the library is set through tokens.
2. Create ADRs in docs/adr/NNNN-<slug>.md per PLAYBOOK §2.3; build the ADR index in §12.
3. Complete CLAUDE.md (replace the lines "Complete at Stage 2.", record the NFR-MAINT threshold figure in the Pass condition cell of the Coverage row) and create .claude/rules/ from Appendix A of the stage's Agent Context and the agent-rules of each overlay; the token-only rule (specflow/CONVENTIONS.md §10.7) is already in the golden rule of the UI overlay, keep one copy and do not add a second.
4. Self-check the Overlay applied checklist for the arch.* slots and playbook.verify-commands, run the leftover check command.

Stop when: ARCHITECTURE is in status in-review, ADRs are in status proposed, the exit gate in §2.3 has been self-checked. Do not create SPECs, do not write code.
```

## Prompt 3: Spec of a release, one SPEC per turn

```text
ARCHITECTURE approved. Write the next SPEC of release {{RELEASE}}: feature {{FEATURE_NAME}} (module {{MODULE_CODE}}).

Read: per specflow/PLAYBOOK.md §6, row "3. Spec" and the line that applies to every row.
Template: the stage's Spec for the right surface (the SPEC file in specflow/starters/<starter>/ if there is a starter; otherwise specflow/core/04_Spec_Core_Template.md assembled with specflow/overlays/<surface>/spec-contract-sections.md), applying the stack profile per PLAYBOOK §4.

Tasks:
1. Create docs/specs/SPEC_{{FEATURE_KEY}}.md with ID {{SPEC_ID}} and the frontmatter key release: {{RELEASE}}. Every FR in §1.5 has Release {{RELEASE}} in SRS §6.1.
2. Lock the File Diff and the MUST NOT touch table. The first SPEC of each surface in the release receives the shared foundation of that surface (project skeleton, configuration, shared library, test infrastructure) in its File Diff; the first SPEC of the whole release is a SPEC that does not consume the contract of another SPEC of the same release. A later SPEC of the same surface does not repeat it, and if it must edit that file it records this in §2.1 (PLAYBOOK §2.4). Fill in the contract, migration, algorithm with a sequence diagram, transaction boundary and idempotency, authorization matrix, events, observability, rollout.
3. A surface with a UI: the Screens table in §3 cites the SCR-* and the wireframe page of the screen, or the mockup of the flow in the index for a screen marked In flow; do not redefine the screen.
4. The test table ties AC to TC and records the file and name of each test; each Core Invariant has one CONC test; test names describe behavior and do not contain TC IDs.
5. Error codes use the Error Code Registry exactly; a missing code is recorded as an Open Question, not added to ARCHITECTURE by yourself.
6. Keep the SPEC within the size ceiling of CONVENTIONS §7; a long machine-readable block goes in a companion file next to the SPEC. Take the next TC number from docs/INDEX.md §3 when the project has an index.
7. A feature that calls a language model (overlay ai-llm-app): before the SPEC, write or update the Prompt Spec docs/prompts/PROMPT_<NAME>.md from specflow/overlays/ai-llm-app/Prompt_Spec_Template.md and the dataset in evals/; the SPEC references the Prompt Spec.
8. At the end of the turn, from the Release column in SRS §6.1 and §1.5 of the SPECs of release {{RELEASE}} (including this SPEC), list the FRs with Release {{RELEASE}} that are not yet in §1.5 of any SPEC of the release, with a proposal for the next SPEC (feature, module, surface).

Stop when: the SPEC and the Prompt Spec are in status in-review, the exit gate of the SPEC in §2.4 has been self-checked. Do not write code. Run this prompt again for the next SPEC until the list in task 8 is empty; then self-check the Gate 3 per-release table in §2.4 and stop at Gate 3.
```

## Prompt 4: Implementation Plan of the release and TDD Coding

```text
Every SPEC of release {{RELEASE}} approved at Gate 3.

Part A, make the plan. Read: per specflow/PLAYBOOK.md §6, row "4a. Plan" and the line that applies to every row.
Create plans/{YYMMDD-HHmm}-release-{{RELEASE_SLUG}}/ (suggested name per CONVENTIONS §9) containing plan.md and the phase-NN-<slug>.md files. plan.md has release: {{RELEASE}} and spec_ids listing every SPEC of the release (a SPEC that has a release key has that key equal to {{RELEASE}}); each phase has a spec_id belonging to spec_ids and a Read First section listing the SPEC and ARCHITECTURE sections the phase needs (get the section numbers with specflow/scripts/project-index.py --outline); the phases of one SPEC are adjacent, a SPEC that provides a contract comes before the SPEC that consumes it, and on each surface the SPEC that carries the shared foundation of that surface comes before other SPECs of that surface (PLAYBOOK §2.4, 2.5). With Stage 1W, the order of UI and e2e phases follows the navigation flow of the wireframe index; each FR of the release has a phase that implements it through the SPEC containing it. The phases of each SPEC cover the whole File Diff and every TC in §9 of that SPEC. Each phase: a subset of the File Diff, the TCs that must pass, the verify commands, the commit message. The plan follows the format in specflow/CONVENTIONS.md §9; run the leftover check command in PLAYBOOK §4.
Stop after part A for me to approve the plan and the DoR (Gate 4, PLAYBOOK §2.5 and 10.1).

Part B, run only when I have approved the plan. Read: per specflow/PLAYBOOK.md §6, row "4b. Coding" and the line that applies to every row. Execute in order the phases of the first SPEC that is not yet implemented. Each phase: write red tests, write code until green, refactor, run the verify commands, tick the checkbox, commit per Conventional Commits in English. Edit only files in the File Diff of the SPEC given by the spec_id of the phase. If docs/ROADMAP.md is missing, report it and build it per PLAYBOOK §2.7 first. Before each phase read docs/ROADMAP.md and check that the next phase of the plan does not jump over any Not started line; after each phase update the roadmap per PLAYBOOK §2.5; a new requirement is recorded in roadmap §3, not worked on.
Stop when: every phase of that SPEC is done, the verify commands in CLAUDE.md all pass and (with a roadmap) the line of the SPEC is Done with evidence, and the result of the roadmap reconciliation in PLAYBOOK §2.6 is pasted into the stop report. SPEC risk: high, or no risk recorded: stop; you run Prompts 5 and 6 for that SPEC and then send part B again for the next SPEC. SPEC risk: normal: do the verify per the checklist and the docs sync (Prompts 5 and 6) in this turn and then stop and wait for "Approved at Gate 5". Also stop on a conflict per PLAYBOOK §7, or when the same test or verify command fails with the same error after 3 fixes (PLAYBOOK §7 rule 11).
```

## Prompt 5: Verify and Review

```text
The phases with spec_id {{SPEC_ID}} of plans/{{PLAN_DIR}} are done. Verify this SPEC before closing it.

Read: per specflow/PLAYBOOK.md §6, row "5. Verify and Sync" and the line that applies to every row; SPEC {{SPEC_ID}}, the plan.

Risk level (PLAYBOOK §2.6): SPEC risk: normal does tasks 1, 2, 4, 5, 6 per the checklist and then does Prompt 6 in the same turn. SPEC risk: high, or a SPEC with no risk recorded, does all of 1 to 5 with a fresh-context agent, adds mutation testing for every permission and scope condition, and stops before Prompt 6.

Tasks:
1. Run all the verify commands in CLAUDE.md; report the result of each command with its exit code.
2. Determine the commit range of the SPEC per PLAYBOOK §2.6: from the parent of the first phase commit to the last phase commit with spec_id {{SPEC_ID}}. Compare git diff over that range with the File Diff of the SPEC (ignore documents and the plan); list extra or missing files.
3. Compare the code with the SPEC: contract, error codes, algorithm, authorization matrix, events; list every difference with file:line.
4. Check that every TC in SPEC §9 has a test in the file and with the name recorded in the table, and that it passes.
5. With a roadmap: run the reconciliation in PLAYBOOK §2.6; report pass or mismatch.
6. A surface with a UI and with approved HTML (otherwise write N/A): compare the built screen with the HTML file of the screen in docs/wireframes/html/ on zones, components, states and tokens; list the differences.

Stop when: there is a pass or fail report for every DoD criterion (§10.2), except rows marked "completed at Prompt 6" (Prompt 6 is what updates the document status). Do not edit documents at this step; edit code only when I agree.
```

## Prompt 6: Sync Docs

```text
Verify passed for SPEC {{SPEC_ID}} of plans/{{PLAN_DIR}}. Sync the documents. Several SPECs with risk: normal of the same release are synced in one turn.

Read: per specflow/PLAYBOOK.md §6, row "5. Verify and Sync" and the line that applies to every row; SPEC {{SPEC_ID}}, the plan, the verify report, the source documents to fix in task 3.

Tasks:
1. SPEC: the test table in §9 records the correct test file and test name; then run python3 specflow/scripts/gate.py . implemented with --note describing the change and the SPEC path, to set status implemented, raise the version and write the Version History (add --bump minor when the change exceeds the PATCH level of PLAYBOOK §8).
2. Plan: the phases with spec_id {{SPEC_ID}} move to done in the frontmatter and in the Status column of the Phases table (specflow/CONVENTIONS.md §9); the status of the plan is completed when every SPEC in spec_ids is implemented, otherwise in-progress.
3. Each accepted difference from the SPEC or ARCHITECTURE: create an ADR, update the source document per PLAYBOOK §8.
4. Run specflow/scripts/check-templates.sh --project . and fix every error it reports in the documents just edited.
5. A feature that calls a language model: record the result of the evaluation job (prompt version, model, metrics, tokens, pass or not) in Prompt Spec §9.1.
6. With a roadmap: the line whose SPECs are all done is Done (not yet Confirmed), §4 has evidence by the TCs fixed in §9, §1 matches the counts (specflow/CONVENTIONS.md §11). The SPEC is the last SPEC of a release: each NFR line whose Closing release is that release and which already has evidence in SRS §8 moves to Done with a row in §4; an NFR line without evidence yet stays Not started and is listed in the stop report. Do not set Confirmed and do not create a tag: that is done on receiving "Approved at Gate 5" (PLAYBOOK §2.7).
7. Commit the documents and roadmap just edited as one documents commit, outside the commit range of the SPEC.

Stop when: the documents match the code, the DoD §10.2 passes for this SPEC, the list of document changes has been reported. Stop and wait for "Approved at Gate 5" for this SPEC (PLAYBOOK §2.6, 2.7).
```

## Prompt Resume: continue in a new session

```text
Continue project {{PROJECT_NAME}} in a new session.

Read: per specflow/PLAYBOOK.md §6, row "Resume"; a brownfield project also reads specflow/brownfield/PLAYBOOK_BROWNFIELD.md §2, 4 and 5.

Tasks:
1. Determine the stage in progress: a document in docs/ (including docs/wireframes/ of Stage 1W) still in status draft or in-review, or a plan in plans/ with a phase still in-progress or todo. Determine the release in progress: the release of the plan in progress, or the release of a SPEC still draft or in-review.
2. Read the latest gate page in docs/gates/ and the previous session's state record in plans/reports/ when there is one, then the document or plan in progress; for a phase in progress read the sections in its Read First. Read upstream documents only for the sections needed, looked up through docs/INDEX.md. Summarize the state: what is done, which SPECs of the release are implemented, what remains, the Open Questions.
3. If at Stage 4b: run the verify commands in CLAUDE.md to confirm the real state; a [x] checkbox whose verify fails is reported before continuing.
4. Gate 1 passed but docs/ROADMAP.md is missing: report it, then build it per specflow/PLAYBOOK.md §2.7. With docs/ROADMAP.md: run the reconciliation in specflow/PLAYBOOK.md §2.6, report progress per §1 and every mismatch before continuing; the next work is the first todo phase of the plan, provided it does not jump over any Not started line (PLAYBOOK §2.5).
5. Continue the first unfinished step following the prompt of that stage in specflow/PROMPTS.md; a brownfield project also follows §6 of specflow/brownfield/PLAYBOOK_BROWNFIELD.md.

Stop when: you reach the stop condition of the prompt of that stage, or a conflict per PLAYBOOK §7.
```

## Work packet for a sub-agent (Work Packet)

Use when handing a part of Prompt 3, 4B, 5 or 6 to a sub-agent (PLAYBOOK §7 rule 13). A sub-agent knows only what the packet says, so the packet must be self-contained and short: about 40 lines, citing the paths of files to read rather than copying their content into the packet.

```text
Goal: <goal, one sentence>
Read (reading slice, look up section numbers in docs/INDEX.md or the Read First section of the phase): <the `file §section` entries>
May edit only: <list of files> (or "no file")
Stop when: <stop condition>
Budget: <number> tool calls; when exceeded, stop and report what exists
Final report:
Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
Summary: one to two sentences
Concerns: optional
```

| Prompt | Goal | Reading slice | May edit only | Stop when |
| --- | --- | --- | --- | --- |
| 3 | Write one SPEC of the release | Row "3. Spec" in PLAYBOOK §6, by section | That SPEC and its companion file | The SPEC has every section, is within the size ceiling, and the orchestrator has run `check-templates.sh --project .` |
| 4B | Do one phase | The Read First section of the phase | The Files table of the phase | The tests of the phase are green, the verify commands pass, one commit |
| 5 | Review and verify one SPEC | Row "5. Verify and Sync" in PLAYBOOK §6 | No file | A findings report with `file:line` |
| 6 | Sync the documents of one SPEC | Row "5. Verify and Sync" in PLAYBOOK §6, the change table in §8 | The documents that the §8 table names for this change | Every cross-check row matches; the orchestrator runs `gate.py implemented` |
