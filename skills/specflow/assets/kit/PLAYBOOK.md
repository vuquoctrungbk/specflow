---
doc_type: playbook
status: stable
version: 4.0.0
language: en
---

# AI Coding Playbook

## 1. Purpose & Principles

### 1.1. Purpose

The mandatory process for the coding agent (Claude Code by default) and for engineers building software with the specflow templates: from idea to verified code, through a chain of documents that narrows the context and raises the level of detail step by step (Top-Down Specification). The chain is a 3-step process followed by execution: step 1 Requirements (Intake, SRS, and a wireframe checked against the SRS when there is a UI), step 2 Design (Architecture and ADR, the release's SPECs), step 3 Plan (the release's implementation plan); execution is TDD coding, verify, and docs sync (§2). This playbook defines the process; the format contract (placeholders, slots, frontmatter, IDs, document layout) is in [CONVENTIONS.md](CONVENTIONS.md).

### 1.2. Non-negotiable principles

1. Do not generate source code until the document chain `PROJECT_INTAKE → SRS → WIREFRAME → ARCHITECTURE + ADR → SPEC → Implementation Plan` is complete and approved per the Definition of Ready (§10.1). WIREFRAME exists only in projects that have Stage 1W (§2.2.1). The only exception: the `REG` tests of a brownfield project at Stage 0R ([brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md) §5.1).
2. Every stage ends at an exit gate that has an approver; the agent stops at the gate and does not move to the next stage on its own.
3. Documents are the Single Source of Truth. When code and documents differ, fix one of the two through the §8 process; never leave them out of sync.
4. Every ambiguity is recorded in the `Assumptions & Open Questions` section, never resolved silently.
5. TDD: tests are written from the scenarios in the SPEC before the logic.

### 1.3. Language

Per [CONVENTIONS.md](CONVENTIONS.md) §5: prose in the language of the project's documents, technical terms kept in English, identifiers always in English. Agent MUST NOT switch language midway.

### 1.4. Installation and paths

The template set is copied into the `specflow/` folder at the project root: `PLAYBOOK.md`, `PROMPTS.md`, `CONVENTIONS.md`, `CHANGELOG.md`, `core/`, `overlays/`, `starters/`, `brownfield/`, `scripts/`; when upgrading, delete the old `specflow/` before copying. Do not copy `examples/`. Template paths in this document are counted from the root of the template set (for example `core/01_SRS_Template.md`); in a project, add the prefix `specflow/`. The prompts in `PROMPTS.md` are already written with project paths.

## 2. Document Pipeline

The process has 3 steps plus the execution stages. Each step groups one or more stages and closes with the gate of its last stage; the numbers and names of the stages and gates stay as they were.

The `Prompt` column below is the single table that maps step, stage, gate, and prompt; other places point to this table instead of repeating it.

| Step | Stage | Gate | Prompt | Result when passed |
| --- | --- | --- | --- | --- |
| 1. Requirements | 0 Intake; 0R when brownfield; 1 SRS; 1W Wireframe when there is a UI | Gate 0; Gate 0R; Gate 1; Gate 1W | Prompt 0; Prompt B0 to B2 (brownfield); Prompt 1; Prompt 1W | SRS, wireframe, and design system document `approved`, the FR ↔ SCR mapping table matches |
| 2. Design | 2 Architecture and ADR; 3 the release's SPECs | Gate 2; Gate 3 per release | Prompt 2; Prompt 3 (one SPEC per turn) | ARCHITECTURE, ADR, and every SPEC of the release `approved` |
| 3. Plan | 4a the release's plan | Gate 4 | Prompt 4 part A | The release's plan covers every SPEC of the release, DoR passed |
| Execution | 4b TDD Coding; 5 Verify and Sync Docs | Gate 5 per SPEC | Prompt 4 part B, 5, 6 | Each SPEC `implemented`; plan `completed` when the last SPEC of the release is done |
| New session | The stage in progress when a new session opens | Per the stage in progress | Prompt Resume | Continue exactly the step left unfinished, without repeating gates already passed |

- Stage 1W applies when the project has a UI surface: overlay `frontend-web` or `mobile-app`, or another surface that has screens. Intake §14 records whether Stage 1W applies; a project without a UI (only `backend-api`, `ai-llm-app`) records No, and Gate 1W records N/A at Intake §9.
- A release is the label in the Release column of SRS §6.1, for example `R1`; the names of the planned releases are recorded in the Intake. Step 2 and step 3 run per release, in order: Stage 2 runs once at the first release, and later releases only update ARCHITECTURE and ADR per §8 when needed; Stage 3 writes every SPEC of the release; Stage 4a produces one plan for the whole release. Execution goes SPEC by SPEC in the plan; when the release is done, repeat from Stage 3 for the next release.
- Each release is a vertical slice, so that running code arrives early. The first release holds the shared foundation and one end-to-end flow; each release has 1 to 3 SPECs, never more than 5. SRS §6.1 splits the FRs across releases that way from Stage 1; the FRs of later releases only need a statement and AC, no SPEC yet. Do not write the SPEC of a later release while an earlier release still has a SPEC that is not `implemented` (`scripts/check-templates.sh` reports an error, and warns when a release has more than 5 SPECs).
- Roadmap: `docs/ROADMAP.md`, following `core/08_Roadmap_Template.md` and CONVENTIONS §11, is the to-do list that the coding agent follows. The agent builds it on receiving "Approved at Gate 1", fills it in progressively at Gate 3 and Gate 4, updates it after every phase, reconciles it in §2.6, and marks `Confirmed` on receiving "Approved at Gate 5" (§2.7). The roadmap is derived from the SRS: when they differ, the SRS wins.
- Brownfield project: Stage 1W runs after the Gap Analysis and draws the to-be UI ([brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md) §2).

The Verification column of the exit gate tables states where the approver checks. A row that says "checker on the examples" is a rule that `scripts/check-templates.sh --examples` checks on the template set's examples; in a project, `bash specflow/scripts/check-templates.sh --project .` checks the same rules on the project's documents (it needs `python3` for the index, companion files, and roadmap), and the approver checks the rows the checker does not; the parenthesis after it, if any, states the part the checker checks when it does not check the whole row.

| Stage | Question answered | Template | Output in the project | Gate approver |
| --- | --- | --- | --- | --- |
| 0. Intake | What project, which surfaces, scale, constraints | `core/00_Project_Intake_Template.md`; the stage's Agent Context | `docs/intake/PROJECT_INTAKE.md`, initial `CLAUDE.md` | Project owner |
| 1. SRS | WHAT: business, actors, logical data, use cases, NFRs, screen list | The stage's SRS; `core/08_Roadmap_Template.md` on receiving "Approved at Gate 1" | `docs/srs/`; `docs/ROADMAP.md` (§2.7) | Per Intake |
| 1W. Wireframe | How each screen looks and navigates, which FR is realized on which screen, the shared design system | `core/07_Wireframe_Template/` | `docs/wireframes/`, `docs/design-system/` | Per Intake (Gate 1W) |
| 2. Architecture + ADR | WHERE and HOW: stack, C4, layout, schema, cross-cutting | The stage's Architecture, `core/03_ADR_Template.md`, the stage's Agent Context | `docs/ARCHITECTURE.md`, `docs/adr/`, `CLAUDE.md`, `.claude/rules/` | Per Intake |
| 3. Spec | The execution contract for one piece of the release's work; every SPEC of the release is approved at Gate 3 | The stage's Spec | `docs/specs/SPEC_<FEATURE_KEY>.md` | Per Intake |
| 4a. Implementation Plan | Split the work of every SPEC in the release into committable phases | `core/05_Implementation_Plan_Template/` | `plans/{YYMMDD-HHmm}-{slug}/` | Per Intake |
| 4b. TDD Coding | Source code and tests | None | Source code in the File Diff | No gate of its own |
| 5. Verify and Sync Docs | Does the code of one SPEC match the SPEC, and are the documents still correct | None | SPEC `implemented`; plan `completed` when every SPEC of the release is done; ADR for deviations | Per Intake |

A brownfield project (Intake `mode: brownfield`) takes the extra steps in [brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md): recovery of the current state and Gate 0R before Stage 1, Gap Analysis after the SRS and before Stage 1W, the Migration Plan together with Stage 2, the SPEC appendix at Stage 3, and the additions to the prompts, Definition of Ready, and Definition of Done at every later stage.

"The stage's template" is defined in §4. Reference standards: SRS follows ISO/IEC/IEEE 29148:2018, NFR groups follow ISO/IEC 25010:2023; Architecture references ISO/IEC/IEEE 42010:2022 (the view and rationale concepts are recorded through ADRs; no compliance is claimed) and uses the C4 model; ADR follows MADR 4.0.0 with adjustments (keeps the `deciders` key, a more compact section layout); Spec uses the RFC 2119 and RFC 8174 keywords.

### 2.1. Stage 0: Intake

- Collect: project identity; the problem and measurable goals; surfaces and overlays; greenfield or brownfield; scale estimate; constraints (mandatory stack, hosting, budget, deadlines, and the planned releases); compliance (the data protection law of the project's country; GDPR; PCI DSS; others); external integrations; the team and the approver of each gate; success metrics.
- Settle the `Routing Decision` block: `overlays` in order, the stack profile for each overlay, starter, `mode`, `docs_mode`, approvers, whether Stage 1W applies (§2).
- Create the initial `CLAUDE.md` from the stage's Agent Context: copy the `Documentation Layout` section verbatim; a section without enough data yet (for example the summarized Golden Rules) is replaced with the line `Complete at Stage 2.`; do not copy Appendix A (used at Stage 2); leave no marker line, placeholder, or `fill`. Purpose: the specflow layout is in force before the first document is generated.
- Brownfield project: the verify-commands section of the initial `CLAUDE.md` does not say `Complete at Stage 2.` but `Complete at Stage 0R (Prompt B1).`, even when a profile matches; do not copy the profile's commands into this section. Prompt B1 fills the commands from Codebase Summary §7 following `brownfield/PLAYBOOK_BROWNFIELD.md`, because a command that already runs on the repo beats the profile's command.
- Exit gate: the Routing Decision has every field, the project owner confirmed `language` (Intake §10), no `BLOCKING` question remains, the project owner approves. A question that touches the contract, has no answer yet, but does not block routing is recorded as `BLOCKING: No` with "answer before Gate 1" (§7 rule 3); such questions do not block Gate 0 and are copied by Prompt 1 into SRS §9.

### 2.2. Stage 1: SRS

- Clarify the problem, the In-scope and Out-of-scope boundary, the list of modules `MOD-NN`.
- Draw the context diagram (`flowchart`), build the actor matrix `ACT_*`, the stakeholders.
- Fill in the technical constraints, external interfaces, and the logical data model per overlay. A surface with relational storage MUST have a Crow's foot `erDiagram` and a Data Dictionary.
- A surface with a UI: the User Interfaces table in §3 lists every screen, one `SCR ID` per screen in the form `SCR-{MOD}-NN` per CONVENTIONS §4. SRS §3 is the only source of the screen list; Stage 1W details it and does not add IDs.
- Fill in the operating, memory, and deployment-adaptation constraints (§2.4) and the standards to comply with (§2.7).
- Write the Business Rules `BR-NNN`. Each FR has a requirement statement following the EARS pattern in CONVENTIONS §8, with priority, release (the release label from the Intake), verification method, and risk. A Must-level FR has a use case with full Pre-conditions, Main flow, Alternative flow, Exception flow with concrete error codes, and Post-conditions.
- NFRs have a metric, a measurement method, a threshold, and a verification method; the Given-When-Then matrix links `FR → AC`, the NFR table records the verification method and the evidence of each NFR; TCs are not recorded in the SRS (CONVENTIONS §4).
- Exit gate: every criterion in the table below is met. Criteria 1 to 3 come from ISO/IEC/IEEE 29148 §5.2.5 to 5.2.7 and CONVENTIONS §8; the approver reads each FR and NFR and does not rely only on the checker.

| Criterion | Verification |
| --- | --- |
| Each requirement is necessary, appropriate to the SRS level, unambiguous, complete, singular, feasible, verifiable, correct, and conforming to the pattern in CONVENTIONS §8 | The approver reads §5, §6.1, §7 |
| The set of requirements is complete, consistent, feasible, comprehensible, and validatable with the stakeholders; no TBD remains | §9 has no `BLOCKING` question; §1.2 and §6.1 match |
| The FR statement and the Requirement, Threshold cells of the NFR use no vague term from CONVENTIONS §8, including context-dependent words such as "supports" without a behavior | The approver; checker on the examples |
| Each FR, BR, and NFR has a verification method; each applicable NFR has a row in the NFR table of §8 | §5, §6.1, §7, §8 |
| Every applicable item of §2.4, §2.7, and §3 is filled in; a non-applicable item is marked N/A with a reason | §2, §3; cross-check §10.3 |
| With a UI: every screen in the User Interfaces table of §3 has a unique `SCR ID`, and the FRs in the FR column exist in §6.1 | §3, §6.1 |
| SRS `approved`, version `1.0.0` | Frontmatter and Version History |

### 2.2.1. Stage 1W: Wireframe

Applies to a project whose Intake §14 records Stage 1W as applicable (§2). Runs after Gate 1; a brownfield project runs it after Gate 1 has approved both the to-be SRS and the Gap Analysis, and draws the to-be UI.

- The design system comes first, per CONVENTIONS §10.7: the agent proposes 2 to 3 visual directions, and the project owner picks exactly one (a stop in the middle of the stage, an exception to §7 rule 3; the directions are recorded in `DESIGN_SYSTEM.md` `draft` before stopping); then write the foundations, tokens (`tokens.json` and the mode files), primitives, and the catalog of components, patterns, and templates into `docs/design-system/` from `core/07_Wireframe_Template/`, before building the screen pages.
- Task: draw every screen in SRS §3, with no screen added or removed, at a level of detail based on the risk of the screen. A screen with a write action, permission-dependent display, or personal data gets its own page. The other screens are drawn in the mockup of the flow they belong to in the index (one low-fi block per flow), and the screen catalog records `In flow` in the HTML File column; the Gate 1W approver can switch a screen to its own page. A dedicated page `docs/wireframes/SCR-<MOD>-NN.md` from `core/07_Wireframe_Template/` contains: purpose, FR and AC, the low-fi layout (a `text` block per CONVENTIONS §7), the page picks exactly one Template and cites the Patterns and Components that exist in the design system catalog, the component table, the five UI states with AC, navigation in and out, accessibility notes.
- The index `docs/wireframes/00_WIREFRAME_INDEX.md`: the screen catalog repeats exactly the set of `SCR ID`s in SRS §3, the navigation diagram (`flowchart`), and the mapping table has exactly one row for each FR in SRS §6.1 whose priority is not `Won't` (merging master and modules when `docs_mode` is `modular`) following the `FR → SCR` chain in CONVENTIONS §4.
- UI/UX standards per CONVENTIONS §10: a page has an `Authentication screen` line and accessibility notes following the WCAG 2.2 criteria in CONVENTIONS §10.2 with the platform's figures in `OVERLAY.md`; the index has a heuristic evaluation table (CONVENTIONS §10.3) and a deceptive design pattern checklist (CONVENTIONS §10.4). The wireframe author self-assesses, fixes `Critical` problems and removes deceptive patterns before submitting to Gate 1W; the self-check questions in CONVENTIONS §10.5 do not block the gate.
- HTML in `docs/wireframes/html/`: each screen page has one file when Intake §14 records Stage 1W as `Yes, with full HTML` (the default); `Yes, Markdown only` with a reason means no HTML is created; a screen marked `In flow` has no HTML. The content and rules are in CONVENTIONS §7 and §10.7. Changing the choice after Gate 0 means editing Intake §14 per §8 first. The Markdown page owns the structure, components, states, AC, and navigation; the HTML owns the visual decisions, the things a Markdown page cannot record.
- The index and each page use the same status set as the SRS (CONVENTIONS §3); version and changes after approval follow §8.
- A mismatch between the wireframe and the SRS (a screen added, removed, or changed; a missing FR; an AC that does not match the screen's states) has two cases:
  - The wireframe is drawn wrongly or incompletely against the approved SRS (a page forgot a state that has an AC, lacks a component the FR needs, wrong navigation): fix the wireframe to match the SRS; the SRS does not change.
  - Building the wireframe shows that the SRS is missing or wrong (a new screen is needed, an FR is missing, an AC cannot be carried out on the screen): do not edit the wireframe to cover the mismatch. The SRS is fixed per §8 (adding a new screen is MINOR, with a new `SCR ID`), the Gate 1 approver re-approves, and only then is Gate 1W considered. A brownfield project also fixes the Gap Analysis per §8.
- Gate 1W exit gate: every criterion in the table below is met. The approver is recorded at Intake §9.

| Criterion | Verification |
| --- | --- |
| The index, every wireframe page, and the design system document `approved`, version from `1.0.0` | Frontmatter and Version History; checker on the examples (an `approved` document has a version from `1.0.0`) |
| The set of `SCR ID`s in SRS §3, the index's screen catalog, and the mapping table are identical; each `SCR ID` has a page or is marked `In flow`; no screen with a write action, permission, or personal data is marked `In flow`, and each `In flow` screen appears in a flow mockup | SRS §3, index, `docs/wireframes/`; checker on the examples (an `In flow` screen appears in a mockup, its name and entry point carry no risk keyword, no `risk: high` SPEC uses it; the approver judges the rest) |
| The mapping table covers every FR in SRS §6.1 whose priority is not `Won't`, each FR has exactly one row that records `SCR-*`, `No UI` with a reason, or (brownfield) `Unchanged` with a reference to Regression Baseline §5 | Index, SRS §6.1; checker on the examples (except the reference to Regression Baseline §5) |
| Every page cites at least one real FR; the AC the page cites exist in SRS §8 and belong to an FR of the page | Page, SRS §6.1, §8; checker on the examples |
| Each page has all five UI states; a non-applicable state is marked N/A with a reason | Page; checker on the examples (has a row for all five states) |
| When the Intake records `Yes, with full HTML`, each page has an HTML file per CONVENTIONS §7 (safe, tokens, `data-cmp`, states, responsive) | `docs/wireframes/html/`; checker on the examples |
| Every mismatch found is handled: a drawing error is fixed in the wireframe; a missing or wrong SRS is fixed (brownfield: also the Gap Analysis) per §8 and re-approved | Wireframe page; Version History of the SRS and Gap Analysis |
| No `BLOCKING` question remains in the index and the pages | Assumptions & Open Questions section; checker on the examples (`approved` documents) |
| Index: the heuristic evaluation table has exactly one row for each key `H1` to `H10` in CONVENTIONS §10.3, no row has the level `Critical`; a `Minor` problem has a resolution | Index, pages; checker on the examples (all rows present, valid levels, no `Critical` left in an `approved` index) |
| Index: no deceptive design pattern remains; the checklist has exactly one row for each key `DP1` to `DP5` in CONVENTIONS §10.4, every `None` row has evidence | Index, pages, navigation diagram; checker on the examples (all rows present, every `None` row in an `approved` index) |
| Page: has an Authentication screen line; the accessibility section records each criterion in CONVENTIONS §10.2 or N/A with a reason | Page; checker on the examples (the Authentication screen line, `3.3.8` when Yes) |
| Visual direction: 2 to 3 directions with rationale, the project owner picked one, the reason is recorded in the document; the library default theme only when chosen on purpose | Design system document; checker on the examples (shape of the direction table) |
| Tokens: `tokens.json` and the mode files follow DTCG per CONVENTIONS §10.7, three tiers; every pair in the contrast table meets `1.4.3`, `1.4.11` in every mode | `docs/design-system/`; recompute each row of the contrast table per CONVENTIONS §10.7 (not by mental arithmetic); checker on the examples |
| Catalog: each page has exactly one Template, every Template, Pattern, and Component the page cites is in the catalog, the catalog has no unused component, pattern, or template | Page, design system document; checker on the examples |
| Page HTML: the CSS variables in `:root` match the tokens of the mode applied to the page's surface; outside `:root`, color, spacing, radius, and `font-size` use only `var(--…)` or the keywords allowed in CONVENTIONS §10.7 | `docs/wireframes/html/`; checker on the examples |

### 2.3. Stage 2: Architecture + ADR

- Settle the tech stack with exact versions: copy the table in the `(Tech Stack)` section of the stack profile into ARCHITECTURE §2.1; every deviation from the profile gets an ADR.
- Draw C4 Level 1, Level 2, Level 3 or an equivalent diagram of the surface, and the deployment view; fix the folder layout with a `MOD → component → folder` table.
- Write the complete physical schema (concrete types, keys, indexes, delete constraints) if the surface has storage.
- Settle the cross-cutting concerns: auth, error envelope, logging, config and env, observability, i18n, cache, jobs; communication conventions and the Error Code Registry. The registry receives every error code in SRS §6.3.
- Build the `NFR → tactic → ADR` table, security architecture, test strategy, CI/CD.
- ADR: the architecture style (ARCHITECTURE §1.3) has its own ADR; each choice marked `has ADR` (CONVENTIONS §1) and each deviation from the stack profile is covered by an ADR, and one ADR may group several choices of the same topic (for example the token model). A choice not marked only needs its value recorded.
- Complete `CLAUDE.md` (verify commands, summarized Golden Rules) and `.claude/rules/`; the Pass condition cell of the Coverage row in the verify-commands table records the threshold figure of `NFR-MAINT` (SRS §7) in place of the generic phrase "≥ threshold of `NFR-MAINT`".
- With Stage 1W: record in ARCHITECTURE how tokens are generated into code per overlay and profile; the library theme is set through tokens.
- Exit gate: every criterion in the table below is met. The approver checks each row (the Verification column per §2).

| Criterion | Verification |
| --- | --- |
| Each applicable NFR in SRS §7 has a row in ARCHITECTURE §8.1, or one row that says "no tactic needed" with a reason | ARCHITECTURE §8.1 checked against SRS §7 |
| Every error code in SRS §6.3 is in the Error Code Registry with its HTTP status and per-surface mapping | ARCHITECTURE §7.1; checker on the examples |
| The architecture style, each choice marked `has ADR`, and each deviation from the stack profile have an `accepted` ADR; every cited ADR has a file | ARCHITECTURE §1.3, §12, `docs/adr/`; checker on the examples (a cited ADR has a file) |
| The tech stack in §2.1 matches the `(Tech Stack)` section of the stack profile, or the deviation has an ADR | ARCHITECTURE §2.1 |
| Each module in SRS §1.2 has a component and folder in the `MOD → component → folder` table | ARCHITECTURE §4 |
| The schema matches the logical data model; the enum value sets match the SRS state machine | ARCHITECTURE §5, SRS §4, §10.1; checker on the examples (enum matches state machine) |
| With Stage 1W: each `SCR-*` of the wireframe index has a row in the route table (web) or the navigation table (mobile) of ARCHITECTURE, in the `SCR ID` column | ARCHITECTURE §3, wireframe index |
| No `BLOCKING` question remains; ARCHITECTURE `approved`, every related ADR `accepted` | Frontmatter; Assumptions & Open Questions section; checker on the examples (`BLOCKING` question in an `approved` document) |
| With `docs/design-system/`: ARCHITECTURE records the token source `docs/design-system/tokens.json` and the token mapping file in code | ARCHITECTURE, the UI conventions section |

### 2.4. Stage 3: Spec

- One SPEC per feature: goal, Core Invariant, out-of-scope, FR table, AC, the BRs satisfied.
- Per release: Stage 3 writes every SPEC of one release, one SPEC per turn (Prompt 3). The SPEC records its release in the frontmatter key `release` (CONVENTIONS §3); every FR in SPEC §1.5 has a Release equal to that release. A multi-surface project has a separate SPEC for each surface the release's FRs need. The SPEC of a surface with a UI cites `SCR-*` and the wireframe page in the Screens table of §3 and does not redefine screens.
- Read the module's existing source code (per ARCHITECTURE §4) to lock the File Diff (modify, create, migration) and the MUST NOT touch table.
- A question that can only be answered by running code (an SQL statement not yet run on the real database, library behavior, a timeout not yet measured) is not kept across several turns: it becomes a spike, which is the first phase of the SPEC in the plan, with a time limit and one concrete question. The spike result is recorded in `plans/reports/`, then the SPEC is fixed per §8 and the question is closed. Such a question is recorded as `BLOCKING: No` with "answer by spike", so it does not block Gate 3.
- The release's shared foundation: each surface has its own shared foundation (the project skeleton, config, shared libraries, and test infrastructure of that surface). A surface's foundation sits in File Diff §2 of the first SPEC of that surface in the release; a single-surface project has exactly one such SPEC. The first SPEC of the whole release is one that consumes no contract of another SPEC in the same release, so it does not violate the contract order rule in §2.5. The phase of the SPEC that carries the foundation comes before the phases of other SPECs of the same surface in the release's plan (§2.5). A SPEC written later for the same surface does not repeat those files, and when it needs to modify one of them it records that file in its own §2.1 (Modified files).
- Fill in the contract per overlay, migration, the algorithm with a sequence diagram (`sequenceDiagram`), transaction boundaries, atomic updates and idempotency, authorization matrix, event contract, observability, rollout.
- The test table links `AC-*`, `INV-*`, `NFR-*` to `TC-*`; each Core Invariant has a `CONC` test in the form the overlay defines. TCs take the next number in `docs/INDEX.md` §3 (CONVENTIONS §4).
- A feature that calls a language model (overlay `ai-llm-app`): each new or content-changed prompt has a Prompt Spec `docs/prompts/PROMPT_<NAME>.md` from `overlays/ai-llm-app/Prompt_Spec_Template.md` and an evaluation dataset in `evals/`, written before the SPEC; the prompt's ID was set in SRS §4.1. The SPEC references the Prompt Spec and does not copy the prompt content.
- Exit gate of each SPEC: every criterion in the table below is met.

| Criterion | Verification |
| --- | --- |
| Every FR, AC, BR, NFR in §1.5 exists in the SRS | SPEC §1.5; checker on the examples |
| Each AC in §1.5 has a TC in §9; each Core Invariant has a `CONC` test | SPEC §9; checker on the examples |
| Each NFR in §1.5 verified by Test has a TC that names the NFR in §9 of this SPEC or of another SPEC of the project; an NFR verified another way has its evidence recorded in SRS §8 | SPEC §9, SRS §8; checker on the examples |
| Each test file in §9 is in the File Diff | SPEC §2, §9; checker on the examples |
| TCs do not collide with another SPEC; every error code of the SPEC is in the Error Code Registry | SPEC §9, ARCHITECTURE §7.1; checker on the examples |
| The Prompt Spec of every prompt the SPEC uses is `approved`; no `BLOCKING` question remains; SPEC `approved` | Frontmatter; Assumptions & Open Questions section |
| With Stage 1W: each screen in the Screens table of §3 cites an `SCR-*` that exists in the wireframe index | SPEC §3, wireframe index |

Gate 3 per release is met when every SPEC of the release meets the table above and every criterion in the table below is met. The approver checks every row; the checker on the examples checks only the last row, through the SPEC's `release` key, so it does not need a plan.

| Criterion | Verification |
| --- | --- |
| Every FR whose Release equals the release is in SPEC §1.5 of at least one `approved` SPEC of the release | The approver checks SRS §6.1 against SPEC §1.5 |
| Multi-surface project: each surface that the release's FRs need has a SPEC for the release; each `SCR-*` that the release's FRs cite has a SPEC of the UI surface that cites it | The approver; SPEC §3, wireframe index |
| Every SPEC of the release has `release` equal to the release; every FR that a SPEC of the release cites in §1.5 has a Release equal to the release | Frontmatter and §1.5 of the SPEC, SRS §6.1; checker on the examples (the SPEC has the `release` key) |

### 2.5. Stage 4: Implementation Plan and TDD Coding

- 4a. Build the plan in `plans/{YYMMDD-HHmm}-{slug}/` following `core/05_Implementation_Plan_Template/`. Each phase states: the File Diff subset, the TCs that must pass, the verify command, the commit message; each phase ends green and committable. Default order (an overlay may change it): migration, shared types and contract; business logic (red then green test in the same phase); the interface layer (controller, screen) and e2e. Stop at Gate 4.
- Per-release plan: one plan for every SPEC of the release, in the format in CONVENTIONS §9 (`release`, `spec_ids`, `spec_id` on each phase). Phases are grouped by SPEC, the phases of one SPEC sit together; the SPEC that provides a contract comes before the SPEC that consumes it. The `release` key of each SPEC in `spec_ids` equals the plan's `release`. On each surface, the phase of the SPEC that carries that surface's foundation (§2.4) comes before the phases of other SPECs of the same surface; the first SPEC of the release can stand at the head of the plan (§2.4). A later SPEC that modifies a file belonging to the File Diff of an earlier SPEC in the same release records that file in its own SPEC §2.1 (Modified files), and the later SPEC's phase comes after the phase that creates the file.
- Branches: one branch per phase or group of phases, from the main branch, and merge before opening a dependent branch; do not stack branches, because each fix to a lower branch requires merging and re-verifying every branch above it. Independent phases run in parallel in separate worktrees.
- Gate 4 exit gate: every criterion in the table below is met.

| Criterion | Verification |
| --- | --- |
| The plan has the correct format in CONVENTIONS §9 | `plans/`; checker on the examples |
| The release's plan covers every SPEC of the release: `spec_ids` contains every `approved` SPEC of the release, each SPEC in it has at least one phase, and the `release` key matches the rule in §2.5 | `plan.md`, phase files, `docs/specs/`; checker on the examples (each element of `spec_ids` has a SPEC file, a `release` equal to the plan's, and a phase; a SPEC that cites FRs of the release is in `spec_ids`) |
| The phases of each SPEC cover the whole File Diff and every TC in §9 of that SPEC | Phase files, SPEC §2, §9 |
| Definition of Ready (§10.1) met | DoR table |

- 4b. Execute the phases in order, SPEC by SPEC in the plan: run the red test first, write code until green, refactor, run verify, update the phase's checkbox, commit once per phase following Conventional Commits in English.
- Only modify files in the File Diff of the SPEC the phase belongs to (the phase's `spec_id`). When another file is needed, stop and propose a SPEC change.
- A phase that builds a screen: open the screen's HTML file in `docs/wireframes/html/` and rebuild exactly that screen (regions, components, states, tokens), without designing it again. To differ, stop and fix the wireframe per §8 first.
- With a roadmap (§2): the phase order is decided by the plan; the roadmap checks that no item is skipped. Before each phase, the agent reads `docs/ROADMAP.md`: the plan's next phase must not jump over a line, meaning no `Not started` line stands before the lines the phase implements; if the first line that is still `Not started` or `In progress` has no Phase yet, stop and report (an FR has no SPEC or phase). When a phase starts, every line the phase implements moves to `In progress` and §1 records them together with the SPEC and phase. A line moves to `Done` when every phase of every SPEC in its SPEC column is done and verify passes; §4 gets an evidence row (the TCs that passed, the commit of the last phase) and §1 updates the counts. Roadmap edits after the last phase's commit are committed together with the docs at Prompt 6. An idea or new requirement that arises is recorded in roadmap §3, not worked on. The limit on the number of fix attempts follows §7 rule 11.

### 2.6. Stage 5: Verify and Sync Docs

- Stage 5 runs for each SPEC when every phase with that SPEC's `spec_id` is done; Gate 5 is judged per SPEC. The SPEC's commit range goes from the parent of the first phase commit to the last phase commit that has that `spec_id`.
- Run the full verify gate in §11; check the code against the SPEC (contract, algorithm, error codes) and check `git diff` over the SPEC's commit range against that SPEC's File Diff.
- Update: SPEC `implemented`, the SPEC's phases to `done`, plan `completed` when every SPEC in `spec_ids` is `implemented` (otherwise `in-progress`), the test table in SPEC §9 records the correct test file and test name, the document version is raised per §8. A feature that calls a language model: the result of the evaluation job is recorded in Prompt Spec §9.1; this record does not change the prompt, so it does not raise the Prompt Spec's version.
- Every difference from the SPEC or ARCHITECTURE needs an ADR.
- Roadmap reconciliation (with a roadmap, §2): run `specflow/scripts/check-templates.sh --project .` here and at Prompt Resume; it compares the roadmap with the SRS, SPECs, and plans per CONVENTIONS §11. The agent only checks by itself the two things the script cannot see: the commits in §4 exist in `git log`, the tags in §4 and 5 exist in `git tag`. Paste the result into the stop report. On a mismatch, report the location and do not fix the SRS or SPEC yourself; when the roadmap is wrong against the SRS, fix the roadmap. A closed release (plan `completed`): a line not yet `Confirmed` is reported together with the reason.
- The order for closing a SPEC follows its `risk` (CONVENTIONS §3). `high`: Prompt 5 is an independent review by an agent with fresh context, with mutation testing for every authorization and scope condition, then a separate Prompt 6 for that SPEC. `normal`: verify by checklist (verify commands, File Diff, TCs in §9) and sync docs in the same turn, which can be batched across `normal` SPECs of the same release; review happens at the pull request level. Then stop and wait for "Approved at Gate 5"; Gate 5 is judged after Prompt 6 because part of the Definition of Done is completed at Prompt 6.
- Exit gate: Definition of Done (§10.2) met.

### 2.7. Gate Approval

The approver of each gate is recorded in the Gate table of Intake §9. The agent stops at the gate and sends the list of files created or modified together with the exit gate checklist it has self-checked (§7 rule 9). One turn may be submitted to several gates when one change touches several documents (§8); the submission names each gate. The approver checks against the exit gate table; if it passes, they send "Approved at Gate N" with their name, if it does not, they send back the rows that did not pass. On receiving the approval, the agent runs `python3 specflow/scripts/gate.py . approve --gate N --approver "approver name"` with the paths of the gate's documents (adding `--bump` and `--note` when approving a change to an already approved document, §8) and does not hand-edit the places the script writes. The script sets `approved` (the related ADRs at Gate 2: `accepted`; the plan at Gate 4 stays `pending` because the plan status table in CONVENTIONS §3 has no `approved`), sets `version: 1.0.0` at the first approval, writes one history line, writes `docs/gates/GATE-N.md`, and rebuilds `docs/INDEX.md`; it rejects the whole batch when a submitted document still has a `BLOCKING` question, has a wrong status, or is reported as an error by the checker (phases are counted per the plan). The work in the roadmap, in the plan's phases, and the Gate 5 tag is still done by the agent. Agent MUST NOT set `approved` or `accepted` by itself before receiving the approval (principle 2, §1.2).

With a roadmap (§2), a gate approval also triggers work in `docs/ROADMAP.md` (CONVENTIONS §11):

| Received | Roadmap work |
| --- | --- |
| "Approved at Gate 1" | Build the roadmap from `core/08_Roadmap_Template.md`: §1 one row for each release in the order in the Intake, §2.1 one line for each FR whose Priority is not `Won't`, §2.2 one line for each Must-level NFR with the closing release set to the first release, the SPEC and Phase columns record `Not yet`, every line `Not started`. The order is already fixed by the SRS at this point (release, priority, order in §6.1), so it needs no separate approval |
| "Approved at Gate 3" | Fill in the SPEC column per §1.5 of the SPECs just approved, including the SPEC column of §2.2 |
| "Approved at Gate 4" | Fill in the Phase column per the plan, reorder §2.1 by phase order and reorder the SPEC column of §2.2 by the new order |
| "Approved at Gate 5" for a SPEC | Only do this when the SPEC is `implemented` (Prompt 6 has run); otherwise report and wait. Create an annotated tag on the SPEC's last phase commit following the Tag format line in Intake §14 (from the second pass through Gate 5 of the same SPEC onward add the suffix `-2`, `-3`), push only when the approver allows it; add a row in §5. Each `Done` line whose every SPEC in its SPEC column is `implemented` moves to `Confirmed`, and the Tag in §4 records the tag just created. A `Done` NFR line whose closing release is the SPEC's release and for which every FR line of that release is `Confirmed`: moves to `Confirmed` with the same tag. Commit these fixes as a separate docs commit after the tag |

Agent MUST NOT set `Confirmed` before receiving "Approved at Gate 5" for the SPEC that contains that line.

## 3. Overlay Routing

The Intake declares the project's surfaces; each surface maps to one overlay and one matching stack profile, or `none` when no profile matches. A project may have several surfaces.

Profile match. A stack profile matches a surface when every foundation component that the profile's `(Tech Stack)` section fixes agrees with the project's choice (greenfield: the constraints in Intake §6; brownfield: the running code):

- the same language;
- the same major version of the main framework;
- the same major version of the data access layer, meaning the ORM, SDK, or store that the profile's Tech Stack section names;
- the same storage engine, when the surface has storage;
- the same test runner.

Major version follows SemVer; a component still at `0.x` has the minor in the major position (FastAPI `0.139` and `0.141` are different majors). The storage engine and test runner are compared by name only, and a different version is a deviation as described below. A foundation component that the profile's Tech Stack section does not name is not considered. The remaining differences (folder tree, minor or patch version, authentication method, error envelope, auxiliary libraries) do not break the match: a greenfield project that keeps any difference records the deviation with an ADR at Stage 2 (§2.3); a brownfield project handles it per `brownfield/PLAYBOOK_BROWNFIELD.md` §5.5. When no profile matches, the Stack profile cell in Intake §14 records `none`, the Reason for choice column names the foundation component that does not match, and rule 5 applies. To decide this at Stage 0, the agent reads the `(Tech Stack)` section of the profiles belonging to the overlay under consideration (§6).

| Surface | Choose when the project has | Overlay | Available stack profiles | Status |
| --- | --- | --- | --- | --- |
| `backend-api` | HTTP or RPC API, database, background jobs | [overlays/backend-api/](overlays/backend-api/OVERLAY.md) | [node-nestjs-prisma](overlays/backend-api/stack-profiles/node-nestjs-prisma.md), [python-fastapi-sqlalchemy](overlays/backend-api/stack-profiles/python-fastapi-sqlalchemy.md) | Yes |
| `frontend-web` | A web UI running in the browser | [overlays/frontend-web/](overlays/frontend-web/OVERLAY.md) | [nextjs-app-router](overlays/frontend-web/stack-profiles/nextjs-app-router.md) | Yes |
| `mobile-app` | An app installed on a phone or tablet, working offline | [overlays/mobile-app/](overlays/mobile-app/OVERLAY.md) | [react-native-expo](overlays/mobile-app/stack-profiles/react-native-expo.md) | Yes |
| `ai-llm-app` | A feature that calls a large language model: classification, extraction, summarization, document-grounded answers, an agent that calls tools | [overlays/ai-llm-app/](overlays/ai-llm-app/OVERLAY.md) | [typescript-anthropic-sdk](overlays/ai-llm-app/stack-profiles/typescript-anthropic-sdk.md) | Yes |
| Other surface | A surface without an overlay yet | None | None | Assemble manually, see rule 4 |

| `overlays` combination | Starter | Status |
| --- | --- | --- |
| `[backend-api]` | [starters/backend-api/](starters/backend-api/README.md) | Yes |
| `[backend-api, frontend-web]` | [starters/fullstack-web/](starters/fullstack-web/README.md) | Yes |
| Other combination | None, assemble manually per §4 | Not applicable |

Routing rules:

1. Read the Intake's `Routing Decision` block: `overlays` (ordered), the stack profile of each overlay, `starter`, `mode`, `docs_mode`.
2. When there is a starter for the exact combination, use the starter's files (already merged core with overlay, no profile attached yet). Shared templates (Intake, Wireframe, ADR, Implementation Plan) are taken directly from `core/`.
3. When there is no starter, assemble manually per §4.
4. A surface without an overlay yet: the agent records a proposal for the content of the 11 slots in the Intake's `Assumptions & Open Questions`, the project owner approves at Gate 0; from then on assemble as with a normal overlay.
5. An overlay exists but there is no matching stack profile (Intake records `none`): the agent proposes the placeholder values and the profile content in ARCHITECTURE §2 together with an ADR; approved at Gate 2. A brownfield project takes the proposal from Codebase Summary §7 and As-Is Architecture §2. How to assemble documents without a profile follows CONVENTIONS §2.

## 4. Assembly

The stage's template is the corresponding file in `starters/<starter>/` if the Routing Decision has a starter (SRS, ARCHITECTURE, SPEC per surface, `CLAUDE.md.template`); if there is no starter, it is the core file merged with the overlay. Without a starter, the Agent Context uses `core/06_Agent_Context_Template.md` plus the `agent-rules/` of each overlay. Assemble per [CONVENTIONS.md](CONVENTIONS.md) §2:

1. Copy the template (the starter file, or the core file) to the target path.
2. Without a starter: for each line `<!-- SLOT: ... -->`, read `OVERLAY.md` and take the SLOT-CONTENT block with the same ID from each overlay in `overlays` order; with one overlay insert it verbatim, with several overlays each surface gets a heading with the surface name and the headings inside are demoted.
3. Apply the stack profile of each surface: replace each line `<!-- PROFILE-SLOT: ... -->` with the PROFILE-CONTENT block of the same ID (demote headings if the surface was demoted in step 2, replace the sample part that has a `fill` note with real content); replace the placeholders whose source is `Profile` with the profile's "Placeholder values" table. A surface with stack profile `none`: follow CONVENTIONS §2.
4. Replace the remaining placeholders, fill in content following `<!-- fill: ... -->`.
5. Frontmatter: `status: draft`, `version: 0.1.0`, `parent`, `overlays`, `assembled_from` (the source of the starter or core and the overlay, plus the stack profile); a surface without a profile records the surface name in `stack_profile_none` (CONVENTIONS §3).
6. Run the leftover check command, the result MUST be empty:

```bash
grep -rnE '<!-- (SLOT|PROFILE-SLOT|slot-hint|fill)[ :-]|\{\{[A-Z][A-Z0-9_]*\}\}|"\$description": *"fill:' docs/ plans/ CLAUDE.md .claude/ 2>/dev/null
```

The "Overlay applied" checklist, self-checked at the exit gate of the corresponding stage; a box is ticked only when both the overlay content and the profile content are in the document:

| Slot | Target document | Stage | Applied |
| --- | --- | --- | --- |
| `srs.constraints.technical` | SRS §2.5 | 1 | [ ] |
| `(Tech Stack)` section of the stack profile | ARCHITECTURE §2.1 | 2 | [ ] |
| `srs.external-interfaces` | SRS §3 | 1 | [ ] |
| `srs.data-model` | SRS §4.1 | 1 | [ ] |
| `arch.views` | ARCHITECTURE §3 | 2 | [ ] |
| `arch.layout` | ARCHITECTURE §4 | 2 | [ ] |
| `arch.schema` | ARCHITECTURE §5 | 2 | [ ] |
| `arch.conventions` | ARCHITECTURE §7 | 2 | [ ] |
| `arch.deployment` | ARCHITECTURE §8 | 2 | [ ] |
| `playbook.verify-commands` | `CLAUDE.md` verify-commands section | 0 or 2; brownfield 0R (Prompt B1) | [ ] |
| `spec.contract` | SPEC §3 | 3 | [ ] |
| `spec.test-types` | SPEC §9 | 3 | [ ] |

## 5. Docs by Scale

Chosen at the Intake (`docs_mode`), paths per [CONVENTIONS.md](CONVENTIONS.md) §6.

| Mode | When | SRS structure |
| --- | --- | --- |
| `modular` | From 5 modules, or more than 20 interface units (endpoints, screens, commands), or an SRS expected to exceed 800 lines | `docs/srs/00_SRS_MASTER.md` holds §1 to §5, §7, the shared data model; each `docs/srs/SRS_MODULE_<NAME>.md` holds the FRs, use cases, and §8 matrix of one module, `parent` points to the master |
| `monolithic` | Meets none of the `modular` conditions | A single file `docs/srs/SRS.md` |

Counting modules: cross-cutting parts (authentication, rate limiting, logging) and shared libraries do not count as modules, unless they have their own data or their own API. A brownfield project settles `docs_mode` at Gate 0 from the estimate in Intake §5, then reconsiders it at Gate 0R when Codebase Summary §3 has fixed the module codes. If the result changes, Intake §5 and §14 are updated as a MINOR change per §8; the Gate 0 approver recorded at Intake §9 re-approves the Intake at the same time as approving Gate 0R.

Project size `small` (Intake §14; at most 15 FRs, one approver for every gate, no compliance constraints): the document set stays the same, the number of stops is reduced. The Intake and SRS are drafted in one turn and submitted together for Gate 0 and Gate 1; ARCHITECTURE, the `risk: normal` SPECs of the first release, and the plan are drafted in one turn and submitted together for Gates 2, 3, 4. ADRs are written only for hard-to-reverse decisions (changing the stack, the data model, the authentication method); other decisions get one line in ARCHITECTURE §2. A `risk: high` SPEC still stops at its own Gate 3. If the project exceeds the thresholds during the work, change the Scale to `standard` per §8.

ARCHITECTURE is always one file. A SPEC is always one file per feature. These two document types have size ceilings in CONVENTIONS §7 (SPEC 500 lines, ARCHITECTURE 800 lines); long machine-readable blocks go in the companion file per the same section. The goal of the `modular` mode and of the size ceilings: the agent loads only the relevant part, avoiding context overflow and wrong inference.

## 6. Context Loading Manifest

The agent loads exactly what the stage needs. "The stage's" is as defined in §4; "profile" is the stack profile of the chosen surfaces.

| Stage | MUST read | MUST NOT read |
| --- | --- | --- |
| 0. Intake | Brief, `specflow/PLAYBOOK.md` §1 to 7, `specflow/CONVENTIONS.md` §1 to 7, `specflow/core/00_Project_Intake_Template.md`; before settling routing: the `(Tech Stack)` section of every stack profile belonging to the overlays under consideration, to judge the profile match (§3); after settling routing: the stage's Agent Context, `OVERLAY.md`, and the chosen profile | The overlay's section files and the rest of the profile before routing is settled, the SRS, Architecture, Spec templates |
| 1. SRS | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.2 and 4 to 7, `specflow/CONVENTIONS.md` §1 to 8, Intake, the stage's SRS, `OVERLAY.md` | Overlays and profiles not chosen, the profile (the SRS does not use the `Profile`-source placeholders), the Architecture and Spec templates, source code |
| 1W. Wireframe | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.2.1 and 4 to 8, `specflow/CONVENTIONS.md` §1, 3, 4, 6, 7, 10, Intake, SRS (§1.2, §2.2, §2.4, §2.5, §3, §4, §5, §6, §7, §8, §9, §10.2; master and every module if `modular`), `specflow/core/07_Wireframe_Template/`, the `OVERLAY.md` of the surface with a UI, `docs/design-system/` when revising | Stack profile, the overlay's section files, the Architecture and Spec templates, source code |
| 2. Architecture + ADR | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.3 and 4 to 7, `specflow/CONVENTIONS.md` §1 to 7 (add §10.7 when there is `docs/design-system/`), Intake, SRS (master and the shared data model if `modular`; then add §6.3 of every module file), the wireframe index `docs/wireframes/00_WIREFRAME_INDEX.md` when there is Stage 1W, `docs/design-system/tokens.json`, the mode files and the Tokens section of `DESIGN_SYSTEM.md` when there is `docs/design-system/`, the stage's Architecture and Agent Context, `OVERLAY.md`, profile, `specflow/core/03_ADR_Template.md`, `specflow/overlays/<surface>/agent-rules/` when there is no starter | Overlays and profiles not chosen, the Spec template, source code |
| 3. Spec | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.4 and 4 to 7, `specflow/CONVENTIONS.md` §1, 3, 4, `docs/ARCHITECTURE.md`, the part of the SRS that holds the FRs of the SPEC being written, the FR ID and Release columns in SRS §6.1 (master and every module when `modular`), the frontmatter of every SPEC in `docs/specs/` and §1.5 of the SPECs of the release (the `release` key), `docs/INDEX.md` §3 (the next TC number, CONVENTIONS §4), the wireframe index and the wireframe pages of the `SCR-*` that the FRs being written cite, the design system catalog entries (`CMP-*`, `PAT-*`, `TPL-*`) that those pages cite, the referenced ADRs, the stage's Spec, profile, the module's existing source code per ARCHITECTURE §4; overlay `ai-llm-app`: the Prompt Specs of the prompts the feature uses, or `specflow/overlays/ai-llm-app/Prompt_Spec_Template.md` when writing a new Prompt Spec | The rest of the SRS of other modules, the content of other SPECs beyond the frontmatter, §1.5 and the TC ID column in §9 (except the dependent SPECs listed in §1), other wireframe pages, source code of other modules |
| 4a. Plan | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.4, 2.5, 4, 6, 7, 10.1, `specflow/CONVENTIONS.md` §3, 4, 9, every SPEC in the release's `spec_ids`, the SRS §6.1 rows of the FRs whose Release equals the release and the SRS §8 rows of the AC that the release's SPECs cite; with Stage 1W: the wireframe index and the pages of the `SCR-*` that the release's SPECs cite in §3; ARCHITECTURE §1, §4, §5, §7, `specflow/core/05_Implementation_Plan_Template/` | The SRS in full (read only the rows named), wireframe pages not cited by the release's SPECs, SPECs outside the release |
| 4b. Coding | `CLAUDE.md`, `specflow/PLAYBOOK.md` §7, the plan and the phase being worked, the sections listed in the phase's `Read First`, files in the File Diff, dependency files listed in SPEC §1, the wireframe page and HTML file of the screen the phase builds, the design system catalog entries that page cites, `docs/design-system/tokens.json` when the phase has a token file in the File Diff; overlay `ai-llm-app`: the Prompt Specs of the prompts the SPEC uses | Files outside the File Diff and outside the dependency list; files in `specflow/` other than PLAYBOOK and CONVENTIONS |
| 5. Verify and Sync | `CLAUDE.md`, `specflow/PLAYBOOK.md` §2.6, 2.7, 4, 8, 10.2, 11, `specflow/CONVENTIONS.md` §9, the SPEC being closed, the plan, `git diff` over the SPEC's commit range, the verify results, ARCHITECTURE §2.1, §12, the related ADRs, the `NFR-MAINT` row of SRS §8 (coverage threshold); when Sync Docs: the Prompt Specs of the prompts the SPEC uses (overlay `ai-llm-app`: §9.1 to record evaluation results), the source documents to fix per §8 and `specflow/core/03_ADR_Template.md` when creating an ADR; brownfield: `specflow/brownfield/PLAYBOOK_BROWNFIELD.md` §7 | No further limit |
| Resume | `CLAUDE.md`, the page in `docs/gates/` that has the row with the latest date and the previous session's state record in `plans/reports/` when there is one, `specflow/PLAYBOOK.md` §2 (the opening part and the subsection of the stage in progress), 2.7, 7, the section of the stage in progress in `specflow/PROMPTS.md`, the document or plan in progress; for a phase in progress also the sections in the phase's `Read First` | Upstream documents in full (read by section, through `docs/INDEX.md`), documents of closed stages |

A combined submission (§5 scale `small`, §8 step 8) loads the rows of the stages it covers; when the MUST NOT column of one row forbids something that another row requires reading, the row that requires reading wins, and it is still read by section through `docs/INDEX.md`.

A project whose `language` is not `en` also loads `specflow/scripts/locales/<language>/` in every row, including 4b, whose MUST NOT file ban does not apply to it (CONVENTIONS §5).

Every row ends at a gate: when stopping at a gate or receiving "Approved at Gate N", the agent additionally loads `specflow/PLAYBOOK.md` §2.7 and §8.

With a roadmap (§2): rows 4b, 5, Resume and the moments of receiving "Approved at Gate 1", "Approved at Gate 3", "Approved at Gate 4", "Approved at Gate 5" additionally load `docs/ROADMAP.md`, `specflow/CONVENTIONS.md` §11 and `specflow/PLAYBOOK.md` §2.5, 2.6; on receiving "Approved at Gate 5" also load the Tag format line in Intake §14.

Index and companion files: when the project has `docs/INDEX.md`, every row reads that file before other documents and looks up IDs with `specflow/scripts/project-index.py` (the command is at the top of the index) instead of scanning the whole `docs/` folder. A row that loads a section of a SPEC or ARCHITECTURE loads only the companion file that the section cites (CONVENTIONS §7) when the work in progress needs the file's content: writing or editing that block itself, implementing it, or checking against it.

Every stage: MUST NOT read `examples/` or the old template set when generating project documents, to avoid leaking example content. A brownfield project additionally uses the table in §4 of `brownfield/PLAYBOOK_BROWNFIELD.md`.

## 7. Agent Rules

1. Every document has an `Assumptions & Open Questions` section. Each assumption records the reason and the impact; a blocking question is marked `BLOCKING`. The `BLOCKING` cell holds exactly the yes or no word of the project language (`Yes`/`No`, `Có`/`Không`); another value is an error.
2. Agent MUST NOT resolve an ambiguity without recording it. An ambiguity that touches the contract (scope, API, schema, security, personal data) means stop and ask; at Stage 0 follow rule 3. A minor ambiguity: choose the safest assumption, record it, continue.
3. Batch questions into one turn at the end of a stage, at most 5 questions, each with a proposed option. At Stage 0, the 5 questions are chosen in this order: questions that block the Routing Decision first, then questions that touch the contract per rule 2, ranked by risk. A question that touches the contract but does not block routing, including any beyond the 5, is recorded as `BLOCKING: No` and adds "answer before Gate 1" in the Reason or impact column. A question that does not touch the contract is recorded as the safest assumption. Gate 0 still does not allow a `BLOCKING` question to remain. Prompt 1 copies every unanswered "answer before Gate 1" question into SRS §9 with `BLOCKING: Yes`, so the Gate 1 approver blocks them like any other blocking question (on the template set's examples, `scripts/check-templates.sh` reports a `BLOCKING` question left in an `approved` document).
4. Agent MUST NOT add a dependency outside the approved tech stack table. When one is needed, propose a `proposed` ADR and wait for approval.
5. When coding: only modify and create files in the File Diff of the SPEC being executed.
6. When a SPEC conflicts with existing code or with ARCHITECTURE: stop, report the location (`file:line`, document section) and the options; do not choose on your own.
7. Do not generate code before the Definition of Ready is met.
8. Do not modify files in `specflow/`. Do not renumber an approved ID; a retired ID is marked `deprecated` and never reused.
9. New project and new release: each turn generates the documents of one stage, except the combined drafting of scale `small` (§5). A change on a project that already has a baseline: one turn may modify and create every changed document needed, then submit them together (§8). End the turn with: the list of files created or modified, the exit gate checklist self-checked, the remaining Open Questions. The agent self-checks exactly the exit gate rows (including the DoR in §10.1) that it can read under the context loading manifest of §6; a row that needs a document the stage's manifest does not load (for example the full SRS at Stage 4a) is left for the approver to check.
10. On receiving "Approved at Gate N": follow §2.7.
11. The same test or verify command fails with the same error after 3 consecutive fix attempts in one phase (including the red-to-green loop of TDD): stop, report the command, the error, the approaches tried, and the options; do not keep fixing until the user gives direction. The counter returns to 0 only after the user has given direction.
12. With a roadmap (§2): only work on items that have a line in the roadmap, in the order in §2.5; a new requirement is recorded in roadmap §3 and then wait for a decision, do not act on it right away. A requirement made by the person who decides scope (Intake §9) together with an instruction to proceed is already a decision: record `Raise change request` and continue per §8. A project that has passed Gate 1 but lacks `docs/ROADMAP.md`: report, then build it per §2.7 before continuing.
13. Delegating to a subagent (when the runtime has them): for each delegation write a work packet following the Work packet section of `specflow/PROMPTS.md`, containing the goal, the read slice (the `file §section` entries taken from `docs/INDEX.md` or the phase's Read First section), the files allowed to be modified, the stop conditions, the tool-call budget, and the format of the final report. A subagent does not receive the conversation history. The orchestrating agent keeps merging results, running `specflow/scripts/check-templates.sh --project .`, and every user approval; a subagent MUST NOT modify files outside the assigned list and MUST NOT set `approved` or `accepted` by itself.
14. Keep the orchestrating session's context lean, because every call re-reads the whole context: do not paste long reports into the conversation, read only the part needed; after each gate, or when more than half the context window has been used, record the state (work in progress, decisions not yet in the documents) in `plans/reports/` and open a new session with Prompt Resume. Mechanical work (docs sync, consistency review, git operations) is delegated to a smaller model. Within the working loop of a phase run only lint, typecheck, and tests of the part being modified; the full verify suite runs once at the end of the phase.

## 8. Change Management

The ritual of a change is proportional to what it touches, not to the number of documents it edits. Versions follow SemVer:

| Level | When | Stop for approval |
| --- | --- | --- |
| MAJOR | Changes scope or a contract so that approved downstream documents are no longer correct (deleting an FR, changing a schema that holds data, changing a public contract) | Yes; with an ADR if it is an architecture decision |
| MINOR | Adds an FR, NFR, section, endpoint without breaking an approved contract | Yes when the change touches a public contract, schema, security, scope, or belongs to a `risk: high` SPEC. Otherwise no stop: the document is edited on the same branch as the code and approved once when the phase's pull request is merged |
| PATCH | Fixes a typo, clarifies, does not change the meaning | No |

A new document always goes through the gate of its stage (§2). The process for a change:

1. While editing: set `status: draft` (a never-approved document) or `in-review` (an approved document) and edit freely. Do not raise the version and do not write history for each edit; the detailed history is git.
2. On submission: run `specflow/scripts/check-templates.sh --project .`, then on receiving the approval `gate.py approve --bump <patch|minor|major> --note "main content of the change"` (§2.7) raises the version once and writes one history line with that content. A change that touches several documents is done in one turn and submitted together; the submission names each gate being requested and the exit checklist of each gate.
3. Downstream documents: only edit the documents that the table below names for that change and only when their content really changes; a document whose content does not change keeps its `status` and version.
4. A difference discovered while coding: a `risk: normal` SPEC is fixed on the same branch as the code, without stopping and without changing `status`; the change is recorded when closing the SPEC with `gate.py implemented --bump minor --note "..."` (PATCH when the meaning does not change), and the Gate 5 approver is the one who approves it. An architecture change, or a `risk: high` SPEC, records an ADR before merge and resubmits the gate of the changed document.
5. An `accepted` ADR does not have its decision content edited: create a new ADR, set the old ADR to `superseded` with `superseded_by`.
6. A fix after review of an `implemented` SPEC: when the change lies within the SPEC's commit range and has TCs covering it, the SPEC goes `implemented → in-review → implemented` (`gate.py implemented --after-review --note "..."`), with no new phase and no return to Gate 4; the next Gate 5 approval records the approver's name for that version.
7. Changing the behavior of an `implemented` SPEC: the SPEC is raised MINOR and receives a new phase in the plan of the release still in progress, inserted right after that SPEC's phases (CONVENTIONS §9); Gate 5 for the change judges the commit range of the new phase. A finished release (plan `completed`): the change goes through a new SPEC of a later release. Do not reopen the SRS or ARCHITECTURE when the change does not touch their content.
8. Small-change path, for one requirement on a project that already has a baseline whose SPEC is `risk: normal`: in one turn, the agent adds the FR and AC to the SRS (when the requirement is a new behavior), writes or fixes the SPEC, adds phases to the plan, then submits the corresponding gates together once. After approval, the agent codes the phases, verifies by checklist and syncs docs in one turn, then stops and waits for "Approved at Gate 5". A change that touches architecture, or a `risk: high` SPEC, does not take this path: it stops at each gate like a new release.

| Change in | Documents to review | Action |
| --- | --- | --- |
| SRS: FR, AC, use case | The SPEC that holds that FR, the wireframe page and mapping row that cite that FR, the plan, tests | Update SPEC §1, §3, §9 and the wireframe; add phases to the plan if needed |
| SRS §3: add, remove, or change a screen (`SCR ID`) | The wireframe index, the screen's page, the route or navigation table in ARCHITECTURE §3, the SPECs that cite that `SCR-*` | Update the index and pages; a retired ID is not reused |
| Wireframe: layout, components, states, navigation, after the SPEC that cites that `SCR-*` is `approved` | The SPEC that cites that `SCR-*` (§3, §9), the plan, UI tests and e2e | The wireframe is raised MINOR (PATCH when only clarifying, no change of meaning). The SPEC is updated per this section and a plan that has passed Gate 4 gets phases added or fixed; whether to stop for re-approval follows the level table at the start of this section. An `implemented` SPEC follows step 7 above |
| SRS §6.1: change the Release of an FR | The SPEC that cites the FR in §1.5 (the `release` key), the plan of the old release and of the new release | Remove the FR from §1.5 of the old release's SPEC, or set that SPEC to `superseded` when all its FRs move away; add the FR to §1.5 of the SPEC whose `release` equals the new release. Update `spec_ids` and the phases in the plans of both releases; changing release is changing scope, so the Gate 3 and Gate 4 approvers of each release re-approve. An FR that an `implemented` SPEC has already realized does not change release; the change follows step 7 above |
| Design system: tokens, mode files, component, pattern, template catalog, after Gate 1W | The pages that cite the changed item, the HTML, the token mapping file in code, the ARCHITECTURE Design token row, the SPECs that cite the pages | `DESIGN_SYSTEM.md` raises its version and records Version History for every change of itself and of `tokens.json` (the JSON file has no frontmatter, and no extra field is added to a token); changing a token means recomputing the contrast table in every mode; the affected pages follow the Wireframe row above; changing the visual direction means re-approving Gate 1W |
| SRS: NFR | ARCHITECTURE §8 (`NFR → tactic`), ADR | Update the tactic, record an ADR if the decision changes |
| SRS §6.1 or §7 (with a roadmap): add or remove an FR or Must NFR, change Priority, Release, or Verification method | `docs/ROADMAP.md` | Add a `Not started` line (a Must NFR added after Gate 1 gets the release in progress as its closing release), set the line of a removed requirement or one moved to `Won't` to `Dropped` (keep the line so history stays visible), fix the cells copied from the SRS, reorder, and update §1 |
| An `implemented` SPEC changed per step 7 above (with a roadmap) | `docs/ROADMAP.md` | The SPEC's FR lines go back to `Not started`, remove their rows from §4; keep the old rows in §5. The next pass through Gate 5 tags with the suffix `-2`, `-3` (§2.7) |
| Roadmap §3: the approver decides "Raise change request" | The document recorded in the Decision column | Follow the change request process above, starting from that document; the roadmap changes per the row above when the SRS changes |
| SRS: data model | ARCHITECTURE §5, SPEC §4 (migration) | Update the schema, add a migration |
| ARCHITECTURE: schema, conventions, Error Code Registry | Every SPEC that references it | Update the contract and the error table |
| ARCHITECTURE: tech stack | ADR, `CLAUDE.md`, `.claude/rules/` | Record an ADR, update the verify commands |
| SPEC: contract | The SPEC of the surface that consumes that contract, the plan | Update the consuming SPEC and the plan |
| Prompt Spec (overlay `ai-llm-app`): prompt, examples, output schema, parameters, guardrails, thresholds | The SPEC that uses the prompt, the prompt module in code, the evaluation dataset | Raise the Prompt Spec's version and the version constant in code, rerun the evaluation gate, update SPEC §3 if the schema or budget changes |

## 9. Prompts

The prompts are in [PROMPTS.md](PROMPTS.md).

## 10. Definition of Ready, Definition of Done

### 10.1. Definition of Ready (DoR)

Checked at Gate 4, before allowing the first line of code of the plan to be written: the release's plan. The SPEC rows apply to every SPEC the plan implements.

| Item | Criterion | Passed? |
| --- | --- | :---: |
| Intake | The Routing Decision has every field (overlays, stack profile, starter, mode, docs_mode, approvers, Stage 1W), status `approved` | [ ] |
| Overlay | The "Overlay applied" checklist in §4 is complete for the SRS, ARCHITECTURE, and every SPEC of the plan; the leftover check command returns empty | [ ] |
| SRS | Logical data model per surface; a surface with relational storage has a Crow's foot `erDiagram` | [ ] |
| SRS | Every use case has an Exception flow with an error code that exists in the Error Code Registry | [ ] |
| SRS | The Given-When-Then matrix links `FR → AC`; NFRs have a metric, measurement method, threshold; status `approved` | [ ] |
| Wireframe | Without Stage 1W (no UI) record N/A. Gate 1W met: every criterion in the exit gate table of §2.2.1, including the Authentication screen row, the page accessibility section, and the design system document | [ ] |
| ARCHITECTURE | The tech stack records exact versions, no "A or B" remains | [ ] |
| ARCHITECTURE | The physical schema is complete, migratable immediately (if there is storage) | [ ] |
| ARCHITECTURE | A clearly layered layout, with the `MOD → component → folder` table; has the Error Code Registry and the `NFR → tactic` table; status `approved` | [ ] |
| ADR | The architecture style, each choice marked `has ADR`, and each deviation from the stack profile is covered by an `accepted` ADR, listed in ARCHITECTURE §12 | [ ] |
| Agent Context | `CLAUDE.md` has `## Documentation Layout` as the first section, has the verify commands, no longer has the line "Complete at Stage 2." or "Complete at Stage 0R (Prompt B1)."; `.claude/rules/` is created | [ ] |
| SPEC | The File Diff is locked, has the MUST NOT touch table, no extra files | [ ] |
| SPEC | The SPEC §9 test table covers every AC and INV; an NFR in §1.5 that SRS §8 verifies by Test has a TC per CONVENTIONS §4; each Core Invariant has a `CONC` test; status `approved` | [ ] |
| SPEC | With Stage 1W: the SPEC of an FR with a UI cites that FR's `SCR-*` in the Screens table of §3; otherwise record N/A | [ ] |
| Prompt Spec | A surface that does not call a language model records N/A. Each prompt the SPEC uses has an `approved` Prompt Spec with the ID set in SRS §4.1 and a dataset with enough samples in `evals/` | [ ] |
| Roadmap | `docs/ROADMAP.md` exists; every FR line of the release has a SPEC, and each such SPEC has a phase in the plan (the Phase column is filled on receiving "Approved at Gate 4"); the reconciliation in §2.6 shows no mismatch | [ ] |
| Plan | The plan in `plans/` has the correct format in CONVENTIONS §9, the phases cover the whole File Diff, approved. Per-release plan: `release` and `spec_ids` contain every SPEC of the release, the `release` key of the SPECs matches the rule in §2.5, each SPEC has phases, the phases of each SPEC cover that SPEC's File Diff | [ ] |
| Brownfield | Greenfield records N/A. The DoR criteria in `brownfield/PLAYBOOK_BROWNFIELD.md` §7 are met: Gate 0R, Gap Analysis, and Migration Plan `approved`, the SPEC applies the brownfield appendix | [ ] |
| Open Questions | No `BLOCKING` question remains in any upstream document | [ ] |

### 10.2. Definition of Done (DoD)

DoD is judged per SPEC at Gate 5, over the SPEC's commit range (§2.6). The plan is `completed` when every SPEC of the release meets DoD.

| Criterion | Passed? |
| --- | --- |
| Every command in the verify gate (§11) meets its pass condition, locally and on CI; a command that the verify-commands table marks as CI-only (e2e on a virtual machine, prompt evaluation) passes on CI | [ ] |
| A feature that calls a language model (other surfaces record N/A): Prompt Spec §9.1 records a passing evaluation result for the released prompt version | [ ] |
| Every TC in SPEC §9 has a test in the exact file and name recorded in the table, and passes | [ ] |
| Coverage meets the threshold of `NFR-MAINT` | [ ] |
| Source code in `git diff` over the SPEC's commit range lies only in that SPEC's File Diff; otherwise only documents and the plan are updated | [ ] |
| No new dependency outside the approved tech stack or an `accepted` ADR | [ ] |
| SPEC `implemented`, the SPEC's phases `done`; plan `completed` when every SPEC in `spec_ids` is `implemented` (a single-SPEC plan: the plan is complete); an ADR for every deviation, the document versions raised (completed at Prompt 6) | [ ] |
| A surface with a UI and an approved HTML (otherwise record N/A): the built screen matches the screen's HTML in `docs/wireframes/html/` in regions, components, states, and tokens; a difference has an ADR, or the wireframe was fixed and re-approved per §8 | [ ] |
| The leftover check command in §4 returns empty | [ ] |
| Roadmap: the SPEC's lines are `Done` with evidence in §4; the reconciliation in §2.6 shows no mismatch; the plan is `completed` only when no `Not started` line of the release remains | [ ] |
| Brownfield (greenfield records N/A): the DoD criteria in `brownfield/PLAYBOOK_BROWNFIELD.md` §7 are met | [ ] |
| Open Questions resolved or deferred with an owner | [ ] |

## 11. Verify Gate

The minimum list every project must have; the overlay provides the concrete commands per stack profile.

| Item | Pass condition |
| --- | --- |
| Code generation (when the stack has an auto-generated client) | Exit code 0; runs before every other item |
| Lint | 0 errors, 0 warnings |
| Typecheck (languages with type checking) | 0 errors |
| Unit test | 100% pass |
| Integration test | 100% pass |
| E2E test | 100% pass; a surface without a UI or its own API records N/A with a reason |
| Prompt evaluation (when the project calls a language model) | Every run meets the Prompt Spec's threshold; runs in the CI evaluation job |
| Coverage | ≥ threshold of `NFR-MAINT` |
| Build | Exit code 0 |
| Dependency audit | No high or critical vulnerability remains without an ADR accepting the risk |

<!-- SLOT: playbook.verify-commands -->
<!-- slot-hint: The overlay provides the command table for each item above per stack profile. In a project, the assembled commands are in the verify-commands section of CLAUDE.md. -->
