---
doc_type: conventions
status: stable
version: 4.0.0
language: en
---

# specflow Conventions

The mandatory technical contract for every template, overlay, stack profile, starter, example and every document an agent generates from the template set. This is the only place that defines placeholders, slots, frontmatter, the ID scheme, the language policy, the layout of project documents, formatting rules and the UI/UX standard for wireframes (§10); other files only refer to it and do not define these again. Every change here MUST raise `version` and be recorded in `CHANGELOG.md`. The keywords MUST, MUST NOT, SHOULD, MAY are read as in RFC 2119 and RFC 8174: they carry this meaning only when written in capitals. MUST is equivalent to `shall` of ISO/IEC/IEEE 29148, SHOULD to `should`.

## 1. Placeholder

- A placeholder of the template set has exactly one form, `{{UPPER_SNAKE}}`, that is, a string matching the expression `\{\{[A-Z][A-Z0-9_]*\}\}`. The `{{` sign in other syntax (the `${{ }}` expression of CI, JSX, Mermaid, template engines) is not a placeholder.
- The upper-case form is reserved for the template set. A variable in a product's prompt (the prompt spec of the `ai-llm-app` overlay) is written `{{lower_snake}}`.
- Do not use `[...]`, `<...>` or descriptive words as a placeholder. Pattern notation such as `{MOD}`, `NNN`, `<slug>`, `{YYMMDD-HHmm}` only describes the format of names and IDs in infrastructure files, `README.md`, the Documentation Layout block and `fill` comments; content that will be copied into a project document does not use this notation outside a `fill` comment.
- A placeholder is only for a single-line value. Free content uses a `<!-- fill: ... -->` comment placed exactly where the text is to be written; the guidance for a placeholder goes right after it in this comment.
- A placeholder that forces a choice states the set of valid values: `<!-- fill: choose one: A | B | C -->`. A generated document MUST NOT keep the form "A or B". A choice with an architectural consequence is marked `has ADR` (in the `fill` comment or in the format column of the catalog) and MUST be covered by an ADR; other choices only need the value recorded.
- YAML frontmatter: a placeholder is put in double quotes, also inside a list (`title: "{{FEATURE_NAME}}"`, `parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]`). List keys (`parent`, `overlays`, `assembled_from`) are always a YAML list; the template writes the fixed value when there is one (for example the `parent` of the SRS always contains the Intake), and otherwise leaves `[]` for the agent to fill when it creates the document.
- A section that does not apply: keep the heading, write `N/A: <reason>`, and MUST NOT delete the section. A table with a sample row: duplicate the row as needed and delete the unused sample row.
- A generated document MUST NOT keep a placeholder, a `fill` comment (in the form `<!-- fill: ... -->` or `<!-- fill -->`), `<!-- slot-hint:`, a `<!-- SLOT` line or a `<!-- PROFILE-SLOT` line.
- A new placeholder MUST be added to the catalog below before use. `scripts/check-templates.sh` treats every row whose first cell is a placeholder as the catalog. The "Source" column says who supplies the value: `Intake`, `Agent` (the agent decides when it writes the document), `User` (replaced before the prompt is sent), `Profile` (the "Placeholder values" table of the stack profile of the surface that holds the placeholder). A placeholder with source `Profile` is only used in an overlay file, not in core and not in a block for a `srs.*` slot (the concrete version is fixed at ARCHITECTURE).

| Placeholder | Meaning | Format or valid value | Source |
| --- | --- | --- | --- |
| `{{PROJECT_NAME}}` | Project name | Free text | Intake |
| `{{PROJECT_SLUG}}` | Short name used in paths | `kebab-case` | Intake |
| `{{PROJECT_BRIEF}}` | Description of the project idea sent with Prompt 0 | Free text | User |
| `{{DATE}}` | Date | `YYYY-MM-DD` | Agent |
| `{{AUTHOR}}` | Person or agent who writes | Free text | Agent |
| `{{APPROVER}}` | Person who approves the gate | Name or role | Intake |
| `{{MODULE_ID}}` | Module ID | `MOD-NN` | Agent |
| `{{MODULE_CODE}}` | Module code in the requirement ID | See §4, for example `AUTH`, `UI-AUTH` | User, Agent |
| `{{MODULE_NAME}}` | Module name | Free text | Agent |
| `{{MODULE_SLUG}}` | Name of the source directory of the module | `kebab-case`; backend uses plural nouns; a stack profile is allowed to prescribe another spelling when the language requires it (for example a Python package uses `snake_case`) | Agent |
| `{{PROMPT_ID}}` | ID of a prompt in the Prompt Spec (`ai-llm-app` overlay) | `PROMPT-{MOD}-NNN`, see §4 | Agent |
| `{{ROLE_CODE}}` | Role code in the actor ID `ACT_<ROLE>` | `UPPER_SNAKE` | Agent |
| `{{ACTOR_NAME}}` | Actor name in diagrams and tables | Free text | Agent |
| `{{EXTERNAL_SYSTEM}}` | Name of an external system in diagrams and tables | Free text | Agent |
| `{{COMPONENT_NAME}}` | Component name in a diagram | Free text | Agent |
| `{{ENTITY_NAME}}` | Entity name in the ERD and schema | `UPPER_SNAKE` in the ERD, per the DSL convention in the schema | Agent |
| `{{RESOURCE_PATH}}` | API resource path after the version prefix | `kebab-case`, plural nouns | Agent |
| `{{ROUTE_PATH}}` | Page path of a web UI or screen of a mobile app, without a leading `/` | `kebab-case` segments separated by `/`; a dynamic segment follows the syntax of the framework, for example `[itemId]` | Agent |
| `{{STATE_NAME}}` | State name in a state machine | `UPPER_SNAKE` | Agent |
| `{{EVENT_NAME}}` | Name of an event, transition or domain event | Free text or `dot.case` | Agent |
| `{{MESSAGE}}` | Edge label or message in a diagram (purpose, protocol, call) | Free text | Agent |
| `{{FEATURE_NAME}}` | Feature name | Free text | User, Agent |
| `{{FEATURE_KEY}}` | Feature key in the SPEC file name | `UPPER_SNAKE` | User, Agent |
| `{{FEATURE_SLUG}}` | Feature key in the plan directory name | `kebab-case` | User, Agent |
| `{{PLAN_DIR}}` | Name of the plan directory in `plans/` | `{YYMMDD-HHmm}-<slug>` | User |
| `{{RELEASE}}` | Label of the release that the SPEC and the plan implement; the value of the `release` key (§3) | A label in the Release column of SRS §6.1, for example `R1`; the names of the planned releases are recorded at the Intake | User, Agent |
| `{{RELEASE_SLUG}}` | Release label in the plan directory name of the release | `kebab-case` of `{{RELEASE}}`, for example `r1` | Agent |
| `{{PHASE_TITLE}}` | Name of a phase of the Implementation Plan | Free text | Agent |
| `{{PRIORITY}}` | Priority of the plan or phase | `P1` \| `P2` \| `P3` | Agent |
| `{{EFFORT}}` | Effort estimate | Number + `h` or `d` | Agent |
| `{{SPEC_ID}}` | Spec ID | `SPEC-{MOD}-NNN` | User, Agent |
| `{{SCR_ID}}` | Screen ID of a wireframe | `SCR-{MOD}-NN`, see §4 | Agent |
| `{{COMPONENT_ID}}` | Component ID of the design system | `CMP-NN`, see §4 | Agent |
| `{{PATTERN_ID}}` | Pattern ID of the design system | `PAT-NN`, see §4 | Agent |
| `{{TEMPLATE_ID}}` | Template ID of the design system | `TPL-NN`, see §4 | Agent |
| `{{SCREEN_NAME}}` | Screen name in wireframes and navigation diagrams | Free text | Agent |
| `{{ENTRY_POINT}}` | Entry point of a screen | Web: route in the form `/{{ROUTE_PATH}}`; mobile: deep link or screen name in the navigator | Agent |
| `{{ADR_NUMBER}}` | ADR number | `NNNN` | Agent |
| `{{ADR_TITLE}}` | Name of the architectural decision | Free text | Agent |
| `{{OVERLAYS}}` | List of surfaces as text | Overlay names, separated by commas | Intake |
| `{{STACK_PROFILE}}` | Stack profile of the surface that holds the placeholder | File name in `stack-profiles/`, without extension; or `none` when no profile matches under PLAYBOOK §3, with the reason recorded in the Reason for choice column of Intake §14 | Intake |
| `{{DOCS_MODE}}` | SRS storage mode | `monolithic` \| `modular` | Intake |
| `{{SOURCE_GLOB}}` | Glob of the source directory that a rule in `.claude/rules/` applies to | Glob from the project root; for several directories, one glob per list element | Agent |
| `{{WCAG_LEVEL}}` | WCAG 2.2 conformance level | `A` \| `AA` \| `AAA` | Agent |
| `{{COVERAGE_THRESHOLD}}` | Coverage threshold of NFR-MAINT | Integer percentage; the stack profile suggests a default | Agent |
| `{{HTTP_OR_DOMAIN_ERROR}}` | Error code of an exception flow | HTTP status + error code, or a domain error code | Agent |
| `{{TOKEN_FORMAT}}` | Access token format | One value, has ADR | Agent |
| `{{SIGNING_ALG}}` | Token signing algorithm | One value, has ADR | Agent |
| `{{ACCESS_TTL}}` | Access token lifetime | Number + unit | Agent |
| `{{REFRESH_TTL}}` | Refresh token lifetime | Number + unit | Agent |
| `{{REFRESH_STORE}}` | Where the refresh token is stored | Exactly one place, has ADR | Agent |
| `{{PAGINATION_STYLE}}` | Pagination style | `offset` \| `cursor`, has ADR | Agent |
| `{{ID_FORMAT}}` | Resource ID format | One value, for example `UUIDv7`, has ADR | Agent |
| `{{ISOLATION_LEVEL}}` | Default transaction isolation level | One value | Profile |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | Strict typing rule of the language | One sentence | Profile |
| `{{RENDER_BOUNDARY_RULE}}` | Rule for the boundary between server-side render code and code that runs in the browser | One sentence | Profile |
| `{{CODEGEN_CMD}}` | Code generation command before typecheck, test, build (ORM client, API client) | One command line, or `N/A: <reason>` | Profile |
| `{{LINT_CMD}}` | Lint command | One command line | Profile |
| `{{TYPECHECK_CMD}}` | Typecheck command | One command line, or `N/A: <reason>` | Profile |
| `{{UNIT_TEST_CMD}}` | Unit test command | One command line | Profile |
| `{{INTEGRATION_TEST_CMD}}` | Integration test command | One command line | Profile |
| `{{E2E_TEST_CMD}}` | E2E test command | One command line, or `N/A: <reason>` | Profile |
| `{{EVAL_CMD}}` | Command that runs the prompt evaluation tests with a real model (`EVAL`, `INJ`, `COST`) | One command line | Profile |
| `{{COVERAGE_CMD}}` | Coverage measurement command | One command line | Profile |
| `{{BUILD_CMD}}` | Build command | One command line | Profile |
| `{{AUDIT_CMD}}` | Dependency vulnerability check command | One command line | Profile |
| `{{MIGRATION_CHECK_CMD}}` | Command that checks that the schema and the migrations match | One command line | Profile |
| `{{MIGRATION_DEPLOY_CMD}}` | Command that applies migrations at deployment | One command line | Profile |
| `{{OPENAPI_LINT_CMD}}` | Command that checks the OpenAPI document of the API | One command line | Profile |
| `{{PLATFORM_CHECK_CMD}}` | Command that checks the platform configuration and the compatibility of dependency versions with the SDK of the mobile app | One command line | Profile |

## 2. Slot & Assembly

| Marker line | Placed in | Meaning |
| --- | --- | --- |
| `<!-- SLOT: <slot.id> -->` | Core, PLAYBOOK | Insertion point for overlay content; always the last part of the section that holds it |
| `<!-- slot-hint: ... -->` | At most two lines right after the SLOT line | Describes the expected content; deleted when assembled |
| `<!-- SLOT-CONTENT: <slot.id> -->` and `<!-- /SLOT-CONTENT -->` | Section file of an overlay | Open and close the block of overlay content for a slot |
| `<!-- PROFILE-SLOT: <slot.id> -->` | Inside the SLOT-CONTENT block with the same ID | Insertion point for stack profile content |
| `<!-- PROFILE-CONTENT: <slot.id> -->` and `<!-- /PROFILE-CONTENT -->` | Stack profile | Open and close the block of profile content for the PROFILE-SLOT with the same ID |

- Each marker line stands on a line of its own; syntax shown as an illustration in a code block is not counted. Do not nest blocks of the same kind.
- An overlay is a directory `overlays/<surface>/` with an `OVERLAY.md`. Each overlay MUST provide every slot in the catalog, each slot exactly one SLOT-CONTENT block, placed in a file outside `stack-profiles/`. A slot that does not apply to the surface still has a block, whose content is `N/A: <reason>` or a reference.
- A stack profile is `overlays/<surface>/stack-profiles/<profile>.md`, and supplies concrete values in three ways: (1) a "Placeholder values" section with a table of rows `` `{{NAME}}` `` and a single-line value, enough for every placeholder with source `Profile` that the overlay uses; (2) one PROFILE-CONTENT block for each PROFILE-SLOT line of the overlay, no more and no fewer; (3) a section whose heading contains `(Tech Stack)` with a technology table that has the same columns as ARCHITECTURE §2.1 (except the Surface column), for the agent to copy into §2.1. A profile MUST NOT contain a SLOT-CONTENT block.
- A heading inside a block is not numbered. The highest heading level in a SLOT-CONTENT block equals the "Block level" column of the catalog; a PROFILE-CONTENT block uses a level equal to or deeper than the level of the PROFILE-SLOT line in the block that holds it.
- A PROFILE-CONTENT block may contain a `<!-- fill: ... -->` comment that marks a sample part (for example an illustrative schema) which the agent replaces with real content; a part without a `fill` comment is copied verbatim.
- Assembly rules:
  1. Reading order: the core file, `OVERLAY.md`, the section file of the overlay, the stack profile of the surface.
  2. The content of a surface for slot X is the part between the opening line and the closing line of the SLOT-CONTENT X block, in which each PROFILE-SLOT line is replaced by the part between the opening line and the closing line of the PROFILE-CONTENT block with the same ID in the profile of the surface.
  3. One overlay: replace the SLOT line and the slot-hint lines with the content of the surface.
  4. Several overlays provide the same slot: concatenate the content in the order of `overlays` declared in the Intake. Each surface opens with a heading with the name of the surface at the block level (for example `### Backend API`); every heading inside is lowered by one level.
  5. Replace each placeholder with source `Profile` with the value in the profile of the surface that holds the placeholder. When the content of a surface has had its headings lowered at step 4, the headings of the PROFILE-CONTENT block inserted into that surface are lowered by the same number of levels.
  6. Write `overlays` and `assembled_from` into the frontmatter (§3).
- A surface without a stack profile (the Intake records `none`). Step 2 and step 5 have no profile source, so each PROFILE-SLOT line is replaced by content written for the project and each placeholder with source `Profile` by a value of the project, taken from: for a greenfield project, the proposal in ARCHITECTURE §2 with an ADR (PLAYBOOK §3 rule 5); for a brownfield project, Codebase Summary §7 (commands) and As-Is Architecture §2 (tech stack, structure). When that source does not exist yet (for example the `CLAUDE.md` created at Stage 0), the section that holds that content is written per PLAYBOOK §2.1. The document records the name of that surface in the frontmatter key `stack_profile_none` (§3); `assembled_from` records the core or starter source and the overlay as usual, without an entry in `stack-profiles/` for that surface.
- A starter is the core assembled with the overlays, not bound to a profile: a starter has no SLOT line any more but keeps the PROFILE-SLOT lines and the placeholders with source `Profile`. When a starter is used, the agent does step 2 and step 5 with the profile chosen in the Intake. The `CLAUDE.md.template` of a starter also appends to the end of Appendix A, in the order of `overlays`, a section for each file in the `agent-rules/` of the overlay, `### A.N. \`.claude/rules/<file>\`` (N continuing after A.2), that holds the file verbatim in a `markdown` code block.
- A starter is the mechanical result of the rules above: `scripts/check-templates.sh` reassembles every starter file from the declared sources (the first entry of `assembled_from`, and `overlays`) and reports an error when it differs by even one character. When the core or an overlay is changed, reassemble the starter; do not edit a starter by hand.
- Surface display names: `backend-api` is Backend API, `frontend-web` is Frontend Web, `mobile-app` is Mobile App, `ai-llm-app` is AI/LLM App.

| Marker line | Location | Block level | Overlay provides |
| --- | --- | --- | --- |
| `<!-- SLOT: srs.constraints.technical -->` | `core/01_SRS_Template.md` §2.5 | `####` | Technical constraints of the surface: data types, platform, browser or OS, transaction integrity |
| `<!-- SLOT: srs.external-interfaces -->` | `core/01_SRS_Template.md` §3 | `###` | Detailed sections for each type of external interface that applies to the surface (User, Hardware, Software, Communications Interfaces, Interfaces with Services per ISO/IEC/IEEE 29148 §9.6.4), headings named after the type |
| `<!-- SLOT: srs.data-model -->` | `core/01_SRS_Template.md` §4.1 | `####` | Logical data model: ERD, view model, local store or dataset |
| `<!-- SLOT: arch.views -->` | `core/02_Architecture_Core_Template.md` §3 | `###` | C4 Level 2, Level 3 or an equivalent diagram of the surface, and the deployment view |
| `<!-- SLOT: arch.layout -->` | `core/02_Architecture_Core_Template.md` §4 | `###` | Directory tree by layer and location of test files |
| `<!-- SLOT: arch.schema -->` | `core/02_Architecture_Core_Template.md` §5 | `###` | Physical schema or data schema in the DSL of the profile |
| `<!-- SLOT: arch.conventions -->` | `core/02_Architecture_Core_Template.md` §7 | `###` | Communication conventions of the surface and how the error codes of the Error Code Registry (§7.1) map onto the surface |
| `<!-- SLOT: arch.deployment -->` | `core/02_Architecture_Core_Template.md` §8 | `###` | Topology, build, release, migration at deployment, rollback |
| `<!-- SLOT: spec.contract -->` | `core/04_Spec_Core_Template.md` §3 | `###` | Shape of the contract: endpoint and DTO, screen and UI state, prompt spec |
| `<!-- SLOT: spec.test-types -->` | `core/04_Spec_Core_Template.md` §9 | `###` | Test types specific to the surface, the `CONC` test form of the surface, tools, file locations |
| `<!-- SLOT: playbook.verify-commands -->` | `PLAYBOOK.md` §11 and `core/06_Agent_Context_Template.md` | `###` | Verify commands per stack profile and the pass conditions |

## 3. Frontmatter

Every `.md` file of the template set (except `README.md`, `CHANGELOG.md`) and every generated document MUST start with YAML frontmatter.

- An infrastructure file (a `doc_type` in the infrastructure group at the end of the section) uses `version` for itself.
- A template is a file in `core/`, `brownfield/`, `starters/` or `overlays/` that has a `doc_type` of a project document or a brownfield document. A template carries the frontmatter of the output document so that the agent can copy the whole file and then fill it, so in a template `version` is always `0.1.0` (the initial version of the output) and the version of the template itself is written in `template_version`.
- A generated document keeps the `template_version` copied from the template and records `assembled_from`: the `path@version` of every source that was assembled, counted from the root of the template set. A source that is a template (has `template_version`, including a template located in `overlays/`) contributes its `template_version`; a source that is an infrastructure file (overlay section, stack profile) contributes its `version`. A starter records the core and overlay sources in advance; the agent adds the stack profile. `scripts/check-templates.sh` warns when the current source is newer than the `assembled_from` entry at the MINOR or MAJOR level, and reports an error when that entry is newer than the source. A PATCH release of a source only fixes wording, without changing structure or rules, so it does not require the document to be assembled again.

| Key | Required for | Value |
| --- | --- | --- |
| `doc_type` | Every file | See the list below the table |
| `status` | Every file | Per the table of valid status by `doc_type` at the end of the section |
| `version` | Every file | SemVer. A generated document starts at `0.1.0`; `1.0.0` is the first approved version |
| `language` | Every file | The language code of the project, the same value in every document (§5): `en`, `vi` |
| `template_version` | Template, starter | Template: the version of the template itself. Starter: equal to the `template_version` of the source core file (the first entry of `assembled_from`), because a starter is assembled mechanically from its sources; a change of an overlay in the starter shows through the overlay entries of `assembled_from` |
| `assembled_from` | Starter, generated document | YAML list `path@version` |
| `parent` | Generated document, except the intake | YAML list of paths (from the project root) to the upstream documents |
| `overlays` | Generated document | YAML list of surfaces, for example `[backend-api, frontend-web]` |
| `module_id` | Optional | `MOD-NN` |
| `surface` | Overlay, overlay-section, profile | Overlay name |
| `profile` | Profile | Profile name |
| `stack_profile_none` | A generated document whose sources need a stack profile (ARCHITECTURE, SPEC, `CLAUDE.md`, a rule in `.claude/rules/`) when at least one of its surfaces has no matching profile; not used in other documents | List of the names of the overlays (surfaces) that have no matching profile, for example `[backend-api]`. Other surfaces of the same document still record their profile in `assembled_from`. `scripts/check-templates.sh` does not require an entry in `stack-profiles/` for a surface whose name is in the list, and reports an error when a surface named in the list still has its profile in `assembled_from` |
| `spec_id` | Spec, implementation phase | `SPEC-{MOD}-NNN`. In a phase of a release-based plan, `spec_id` is one element of `spec_ids` of `plan.md` |
| `release` | Implementation plan, spec | Exactly one label in the Release column of SRS §6.1, for example `R1`. Plan: the release that the plan implements (§9). Spec: the release of the SPEC; every FR in SPEC §1.5 has a Release equal to this label (PLAYBOOK §2.4), except a `superseded` SPEC (PLAYBOOK §8). |
| `risk` | Spec | `high` or `normal`. `high` when the SPEC touches authentication or authorization, isolation between tenants, money or quotas, personal data, a schema that already holds data, or an approved public contract; otherwise `normal`. The agent proposes the level, the approver of Gate 3 confirms it and may change it. A `normal` SPEC has at §1.1 a line `- Risk level:` that states the reason, and keeps the File Diff at §2 of its own, with paths in backticks. `scripts/check-templates.sh` is a minimum safety net, not a replacement for the approver: it rejects `normal` when a path in the File Diff carries a word of the areas above (for example `auth`, `login`, `session`, `tenant`, `billing`, `payment`, `personal`), lies in an area that Intake §14 declares in the row `High-risk areas`, or is a schema file, a migration or a public contract with a description of a destructive change (delete, rename, change type, `NOT NULL`). This level decides how a SPEC is closed (PLAYBOOK §2.6) and whether to stop for approval on a change (PLAYBOOK §8) |
| `spec_ids` | Implementation plan | YAML list `SPEC-{MOD}-NNN`: every SPEC of the `release` that the plan implements (§9) |
| `prompt_id` | Prompt spec | `PROMPT-{MOD}-NNN` |
| `paths` | Rule in `.claude/rules/` | List of globs that the rule applies to (a Claude Code key) |
| `adr_id`, `date`, `deciders`, `superseded_by` | ADR (`superseded_by` when status is `superseded`) | `ADR-NNNN`, `YYYY-MM-DD`, list of decision makers, `ADR-NNNN`. MADR 4.0.0 calls this key `decision-makers`; specflow keeps `deciders` on purpose so that existing ADRs do not have to change the key |
| `title`, `description`, `priority`, `effort`, `tags`, `created` | Implementation plan | Per §9 |

Valid `doc_type` values:

- Project documents: `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `adr`, `spec`, `prompt-spec`, `implementation-plan`, `implementation-phase`, `agent-context`, `agent-rule`, `roadmap`.
- Brownfield documents: `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan`.
- Template-set infrastructure files: `playbook`, `conventions`, `overlay`, `overlay-section`, `profile`, `spec-addendum`.

`wireframe-index` is the wireframe index `docs/wireframes/00_WIREFRAME_INDEX.md`; the index is not named `README.md` because `README.md` is exempt from frontmatter. `wireframe-screen` is the page of one screen, `docs/wireframes/SCR-<MOD>-NN.md`. These two types belong to Stage 1W (PLAYBOOK §2.2.1). `design-system` is the design system document `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS §10.7); it belongs to Stage 1W.

Valid status by `doc_type` (`scripts/check-templates.sh` reads this table). A document with `status: approved` has a `version` of `1.0.0` or higher.

| `doc_type` | Status |
| --- | --- |
| `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `prompt-spec`, `agent-context`, `agent-rule`, `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan` | `draft`, `in-review`, `approved`, `superseded` |
| `spec` | `draft`, `in-review`, `approved`, `implemented`, `superseded` |
| `adr` | `proposed`, `accepted`, `rejected`, `deprecated`, `superseded` |
| `implementation-plan` | `pending`, `in-progress`, `completed` |
| `implementation-phase` | `todo`, `in-progress`, `done` |
| `roadmap` | `active` |
| `playbook`, `conventions`, `overlay`, `overlay-section`, `profile`, `spec-addendum` | `draft`, `stable`, `deprecated` |

## 4. ID Scheme & Traceability

`{MOD}` is the module code: 2 to 6 capital letters, optionally followed by exactly one sub-segment of 2 to 6 capital letters after a hyphen (`AUTH`, `UI-AUTH`). `N` is a digit, padded with zeros on the left. A project that calls the API of another project uses a module code different from the module code of that API (for example with a `UI-` prefix added), so that the IDs of the two projects do not collide when documents cross-reference. A brownfield project sets the module code in Codebase Summary §3; the to-be SRS reuses that code for a module that remains (`brownfield/PLAYBOOK_BROWNFIELD.md` §5.3).

| Kind | Pattern | Defined at |
| --- | --- | --- |
| Project goal | `GOAL-NN` | Intake §2.2 |
| Module | `MOD-NN` | SRS §1.2 |
| Actor | `ACT_<ROLE>` | SRS §2.2 |
| Business rule | `BR-NNN` | SRS §5 |
| Functional requirement | `FR-{MOD}-NNN` | SRS §6 |
| Screen (wireframe) | `SCR-{MOD}-NN`, file `docs/wireframes/SCR-<MOD>-NN.md` | SRS §3, column `SCR ID` of the User Interfaces table; the wireframe page at Stage 1W details it |
| Component (design system) | `CMP-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS §10.7) |
| Pattern (design system) | `PAT-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS §10.7) |
| Template (design system) | `TPL-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS §10.7) |
| Non-functional requirement | `NFR-{CAT}-NN`, CAT is one of `PERF`, `SEC`, `RELI`, `MAINT`, `USAB`, `FLEX`, `SAFE`, `I18N`, `LEGAL`, `OBS`, `DATA`, `COMPAT`, `COST`; mapped to ISO/IEC 25010 in §8 | SRS §7 |
| Acceptance criterion | `AC-{MOD}-NN` | SRS §8 |
| Test case | `TC-{MOD}-{TYPE}-NN`, TYPE is one of `UNIT`, `INT`, `E2E`, `CTR`, `CONC`, `LOAD`, `A11Y`, `VIS`, `EVAL`, `INJ`, `COST`, `SMOKE`, `REG` | SPEC §9; `REG` in Regression Baseline §6.1 |
| Architectural decision | `ADR-NNNN`, file `docs/adr/NNNN-<slug>.md` | ARCHITECTURE §12 |
| Spec | `SPEC-{MOD}-NNN`, file `docs/specs/SPEC_<FEATURE_KEY>.md` | SPEC frontmatter and §1 |
| Prompt (`ai-llm-app` overlay) | `PROMPT-{MOD}-NNN`, file `docs/prompts/PROMPT_<NAME>.md` | SRS §4.1 (evaluation dataset table); the Prompt Spec frontmatter and §1 reuse it |
| Core Invariant | `INV-NN`, numbered separately in each SPEC | SPEC §1.2 |
| Behavior to preserve (brownfield) | `RB-NNN` | Regression Baseline §3 |
| Assumption or open question | `AQ-NN`, numbered separately in each document | The `Assumptions & Open Questions` section |
| Error code | `UPPER_SNAKE` | Error Code Registry in ARCHITECTURE §7.1 |

Screen ID `SCR-{MOD}-NN`: `{MOD}` is the owning module code of the screen, that is, the module whose main FR the screen implements; NN is unique per MOD across the whole project, even when web and mobile share one module code (the table at SRS §3 records the surface of each screen). The ID is assigned at Stage 1, in the User Interfaces table at SRS §3, column `SCR ID`, so that an SRS approved at Gate 1 does not have to be edited only to fill in IDs after Stage 1W; only a screen newly discovered at Stage 1W makes the SRS change, per PLAYBOOK §8. A brownfield project: a screen that does not change under the Gap Analysis has no ID; the `SCR ID` cell records `Unchanged` (`brownfield/PLAYBOOK_BROWNFIELD.md` §5.3). A screen ID that is dropped is not reused.

Meaning of TYPE: `CTR` contract test; `CONC` verifies an invariant under concurrent or interleaved operations, the concrete form being defined by the overlay (parallel requests, double submit, two devices editing while offline); `EVAL` evaluates a model on a dataset; `INJ` prompt injection and red-team; `COST` token or cost budget; `SMOKE` smoke test of an environment or device; `REG` regression of a `RB-*` behavior.

Required traceability chain:

- `GOAL → FR, NFR`: the Source column of the FR (attribute table of SRS §6.1) and of the NFR (SRS §7) cites `GOAL-NN` when the requirement serves a goal; every `GOAL-NN` in the Intake is cited by at least one FR or NFR.
- `FR → SCR` (a project with Stage 1W): the FR column of the User Interfaces table at SRS §3 and the mapping table of the wireframe index. The list of screens has one source, SRS §3. The wireframe index repeats that list in the screen catalog, and the approver of Gate 1W compares the two places (`scripts/check-templates.sh` checks this on the examples of the template set); a SPEC only cites `SCR-*` and does not define screens. The mapping table has exactly one row for each FR in SRS §6.1 whose priority is not `Won't` (a `Won't` FR is not to be built, so it has no row), recording one of: the `SCR-*` that implement the FR; `No UI` with a reason; or, in a brownfield project, `Unchanged` with a citation of the screenshot in Regression Baseline §5. A wireframe page cites at least one real FR; an AC that the page cites exists in SRS §8 and belongs to an FR of the page. The FR column in the row of a screen in the User Interfaces table at SRS §3 lists exactly the FRs that the screen implements, that is, exactly the FRs whose cross-reference row records the `SCR ID` of the screen; when the two places differ, fix the SRS per PLAYBOOK §8.
- `FR → AC` in SRS §8; `AC → TC → test file → test name` in SPEC §9, the only place that records a TC together with the phase file. The lookup table from AC and NFR to TC for the whole project is generated by `scripts/project-index.py` in `docs/INDEX.md` §5. SPEC §9 records the exact file and test name of each TC. A test name describes behavior in English, for example `rejects an expired access token`; do not put a TC ID or a process ID in a test name, a code comment, a migration name or a commit message, because these IDs belong to documents and are traced through the table.
- Every Core Invariant `INV-NN` of a spec has at least one `TC-{MOD}-CONC-NN`.
- `NFR → TC`: SPEC §9 accepts `NFR-*` in the column "AC or INV". An NFR in SPEC §1.5 whose verification method is `Test` in the NFR table of SRS §8 has a test that records the NFR in §9 of that SPEC (an NFR shared by several modules may be verified by the test of another SPEC that records that NFR in its §9). An NFR verified by `Inspection`, `Demo` or `Analysis` needs no TC. A TC that runs on a real environment (load, smoke) is scheduled in the plan like any other TC: the phase writes the test script and checks that the script runs; the run on staging is recorded in ARCHITECTURE §11 and blocks the production deployment step, but does not block the Definition of Done of the feature.
- TC numbering: NN of `TC-{MOD}-{TYPE}-NN` is unique per pair (MOD, TYPE) across the whole project. A new SPEC takes the next number in `docs/INDEX.md` §3 (when writing several SPECs in one pass, rebuild the index after each SPEC so that two SPECs do not take the same number), counted over every SPEC and Regression Baseline §6.1; a brownfield `REG` test follows the same rule (`brownfield/PLAYBOOK_BROWNFIELD.md` §5.3). In Regression Baseline §6.1, every test that protects an `RB-*` carries type `REG`, including a test that already existed before Stage 0R, because the type records the role of protecting behavior and not the kind of test; a parameterized test is one TC; a TC uses the module code of the behavior being protected, not the module code that holds the test file. An approved ID is not renumbered.
- `NFR → tactic → ADR` in ARCHITECTURE §8; `MOD → component → directory` in ARCHITECTURE §4.
- `FR, NFR → roadmap row → SPEC → phase → commit → tag` in `docs/ROADMAP.md` (§11).
- Every error code that appears in an SRS or SPEC MUST be in the Error Code Registry.

## 5. Language Policy

- The language of a project is the `language` key in the frontmatter of its Intake: a code of a folder of `scripts/locales/` (`en`, `vi`). Every document of the project carries the same value, and `scripts/check-templates.sh` refuses a document that states another one. The agent asks for the language at Stage 0 and writes it in the Intake before it writes any other document.
- Headings, prose and the labels that the scripts read (column names, line prefixes, cell values, roadmap statuses) are written in that language. The labels are the exact strings of `scripts/locales/<language>/`; the agent copies them and never rephrases them. A heading keeps its section number.
- The rules, prompts and templates of the kit are written in English. When the language of the project is not English, the agent writes the headings and the text of a template in the project language while copying it, keeping the section numbers, tables, IDs and labels. A heading is written `<title in the project language> (<English title of the template>)`, for example `## 1. Giới thiệu (Introduction)`; the English part is the key that the scripts match. A project in English uses the title of the template, without parentheses.
- To find a label, search the English string of the template in `scripts/locales/en/*.tsv` and use the value of the same key in `scripts/locales/<language>/`. Never translated: IDs, priorities (`Must`, `Should`, `Could`, `Won't`), verification methods (`Test`, `Inspection`, `Demo`, `Analysis`), test type names (`Unit`, `Integration`), standard codes and RFC 2119 keywords. A label value MUST NOT contain `/`, `&` or `\`, which break the scripts' `sed`.
- Do not translate widely used technical terms: idempotency, transaction, middleware, race condition, endpoint, payload.
- Always use English for: code identifiers, file names, table and column names, error codes, requirement IDs (FR, NFR, AC, TC, ADR), commit messages, test names, branch names. RFC 2119 keywords are written in English capitals.
- Adding a language is not a supported path of this release. A new language folder has the same keys as `en`, defines `docs_high_names_match` in `lists.tsv`, and keeps `(`, `)` and `.` out of label values, as it does `/`, `&` and `\`, because the scripts put labels into `sed` and `grep -E`.
- An agent MUST NOT switch midway through a document to another language.

## 6. specflow Standard Layout

The template set is installed into the `specflow/` directory at the project root (read-only; an agent MUST NOT edit files in `specflow/`). The `CLAUDE.md` of the project MUST copy verbatim both marker lines below and all the content between them into the section `## Documentation Layout`; `scripts/check-templates.sh` compares character by character in the templates, starters and examples of the template set.

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

## 7. Formatting

- Do not use LaTeX. Use the characters `≤ ≥ ≠ × Σ →` and put formulas in inline code, for example `total = Σ line_amount`.
- Every diagram uses Mermaid (`flowchart`, `sequenceDiagram`, `erDiagram`, `stateDiagram-v2`); C4 is drawn with `flowchart`. Do not draw ASCII frames. A directory tree uses a `text` block.
- A markdown table always has a header row. A code block always has a language label. Do not use emoji.
- Size ceiling of project documents: a SPEC is at most 500 lines long, an ARCHITECTURE document at most 800 lines, and one line of these two kinds of document at most 1,000 characters. A document over the ceiling MUST move machine-readable blocks out to a companion file per the bullet below; a long table cell is split into several rows or into a list under the table. `scripts/check-templates.sh` reports an error when a SPEC or ARCHITECTURE exceeds the ceiling. The line ceiling counts lines inside code blocks and the frontmatter.
- Companion file, used only for a SPEC and ARCHITECTURE: a machine-readable block of a SPEC or ARCHITECTURE (API contract, data schema, sample code, directory tree, long Mermaid diagram) is allowed to live in a file of its own instead of a code block in the document. In place of the block, the document writes a line that starts with `Companion file:`, followed by the path from the project root in inline code and a sentence saying what the file holds. A companion file is not a markdown file. The companion file of a SPEC sits next to the SPEC, and its name is the SPEC file name without the `.md` extension, plus a short name and the extension of the format, for example `docs/specs/SPEC_ORDER_CREATE.openapi.yaml`; the companion file of ARCHITECTURE sits in `docs/architecture/`, for example `docs/architecture/schema.prisma`. A companion file is part of the document that cites it: the same version, the same approval, and editing the file is editing the document per PLAYBOOK §8. Each companion file is cited by exactly one document; `scripts/check-templates.sh` checks that the file exists, is in the right place and is cited by exactly one document.
- File names: core templates and brownfield templates `NN_Name_Template.md`; the Implementation Plan template is the directory `core/05_Implementation_Plan_Template/` per §9; the wireframe template is the directory `core/07_Wireframe_Template/` with `00_Wireframe_Index_Template.md` (index), `SCR_Screen_Template.md` (screen page), `Design_System_Template.md` (design system document) and `Design_Tokens_Template.json` (sample tokens); the additional templates of an overlay `Name_Template.md`; the section files of an overlay `kebab-case.md`, except `OVERLAY.md`; stack profile `stack-profiles/<profile>.md`; starter `<DOC>_Template.md` and `CLAUDE.md.template`; infrastructure files in capitals such as `PLAYBOOK.md`, `PROMPTS.md`, `PLAYBOOK_BROWNFIELD.md`, `Spec_Brownfield_Addendum.md`.
- Headings of core and brownfield templates are numbered (`## N.`, `### N.M.`), except the Implementation Plan template (per §9), the section `## Documentation Layout` and the appendices of the Agent Context; headings inside SLOT-CONTENT and PROFILE-CONTENT blocks are not numbered.
- Required sections by `doc_type` (the heading must contain the exact string; the script reads the lines below):
  - `Assumptions & Open Questions`: every template and generated document, except `implementation-phase`, `agent-rule`, `roadmap` (questions are recorded in the source document, new requirements in the New Requests section of the roadmap).
  - `Version History`: `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `spec`, `prompt-spec`, `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan`.
  - `Failure Modes`, `Eval Metric`: `prompt-spec`.
- A template contains no business example; examples live in `examples/<overlay>/`.
- The low-fi layout of a wireframe page is written in one `text` block, with no images or drawing tools. The block divides the screen into zones stacked from top to bottom; each zone opens with a line `== Zone name ==` (for example `== Header ==`, `== Content ==`), zones side by side are written on the same opening line, separated by ` | `. Under the opening line, each component takes one line indented by two spaces: `[Label]` for a button, `Label: [____]` for an input field, `( ) Label` and `[ ] Label` for choices, `...` for the repeated part of a list; a line of plain text is static text or a label; a child component is indented two more spaces under its parent (for example the fields of a list row); a dialog or overlay is a zone `== Dialog: Name ==` placed after the zone that it covers. A page numbers its zones: the opening line is `== N. Zone name ==`, zones side by side `== 2. List | 3. Detail ==`, a dialog `== 4. Dialog: Name ==`; the numbers run consecutively from 1 on the page in reading order (top to bottom, left to right), are not part of the zone name, and feedback on a wireframe records the SCR ID plus the zone number. The HTML of the page records the same number in the zone heading when the HTML has zone headings, and otherwise in the HTML comment right before the block of the zone. A label matches the Component column of the component table on the page. The block draws only the `Success` state; the other four states are described in the state table of the page. A form screen whose `Success` leaves the screen (a page change, or a message replacing the form) has the block draw the `Initial` state and says so right under the block.
- The HTML of a wireframe: one static file `docs/wireframes/html/SCR-<MOD>-NN.html` for each page, required when Intake §14 records Stage 1W as `Yes, with full HTML` (the default), absent when it records `Yes, Markdown only`. It is a full screen from the design system: real sample content, visual values taken from tokens (§10.7), each component of the component table is an element `data-cmp="CMP-NN"` (exactly the set of Component IDs of the table), each UI state that is not N/A is an element `id="state-initial"` (or `loading`, `empty`, `success`, `error`), the state that the layout block draws (Success, or Initial when Success leaves the screen) is shown by default, the other states are shown with `:target` through `#state-…` links on the page; it has a viewport meta, a `frontend-web` page has `@media` for the smallest and the largest breakpoint of SRS §2.5; the title does not call it low-fi. The file MUST use only CSS written in the `<style>` tag of the file itself, self-made sample data (no data of real people, secrets or internal URLs) and have the tag `<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; img-src data:">` placed in `<head>`. The file MUST NOT have a script tag, an event attribute `on...=`, an `iframe`, `object`, `embed` or `base` tag, a form that submits, an external stylesheet or `@import`, an external CSS library, a `\` sign in the `<style>` tag or in a `style` attribute (CSS escape), or `&` in a `style` attribute (HTML entity); and MUST NOT have a URL `http:`, `https:` or starting with `//` in any attribute that takes a URL (`src`, `srcset`, `href`, `poster`, `background`, `ping`, `cite`, `data`), `url(` or another CSS function that takes a URL such as `image-set(`. A link only points to a `SCR-*.html` file in the same directory, or to an `#id` in the same file, including the form `SCR-*.html#id`.
- A markdown link is only used in infrastructure files and `README.md`, pointing to a file of the template set with an existing relative path. Content that will be copied into a project document (templates, starters, SLOT-CONTENT and PROFILE-CONTENT blocks) writes paths in inline code and does not use links; the only exception is the link from `plan.md` to a phase file `phase-NN-<slug>.md` in the same directory in the Phases table of the Implementation Plan.

## 8. Requirement Quality

Reference standards: ISO/IEC/IEEE 29148:2018 §5.2 for how to write requirements, ISO/IEC 25010:2023 for the NFR groups.

Requirement Statement. Each FR has one sentence in the column `Requirement statement` of the catalog table of SRS §6.1. The subject is the system or a module; the sentence contains exactly one keyword `MUST` or `MUST NOT` and states one verifiable behavior. The sentence is written in one of the five EARS (Easy Approach to Requirements Syntax) patterns:

| Pattern | Sentence template |
| --- | --- |
| Ubiquitous | `<system> MUST <response>` |
| Event-driven | `When <event>, <system> MUST <response>` |
| State-driven | `While <state>, <system> MUST <response>` |
| Optional feature | `Where <feature> is present, <system> MUST <response>` |
| Unwanted behaviour | `If <condition>, then <system> MUST <response>` |

An FR states one behavior (the singular characteristic). An accompanying secondary behavior goes in a use case (§6.2) or a Business Rule (§5), and several behaviors are not combined in one sentence. An approved FR that merges two independent behaviors keeps the old ID for the main behavior, and a new FR with the next number is added for the other behavior; do not renumber.

Requirement Attributes. The catalog table of §6.1 records Priority (MoSCoW), Release (the allocation of requirements per 29148 §9.6.9, a label such as `R1`) and Verification method. The attribute table of §6.1 records Prerequisite, Rationale, Source and Risk, one of `High | Medium | Low`. Of the sample attribute list of 29148 §5.2.8, specflow uses ID, priority, risk, rationale and type (FR, NFR, BR); the version follows the version of the document; owner and difficulty are not used. Release, source, prerequisite and verification method are attributes that specflow adds.

Verification Method (29148 §6.5.2): one of `Test | Inspection | Demo | Analysis`, shared by FR, BR and NFR.

NFR. The Requirement cell is a short label; the measurable part sits in Metric, Measurement method and Threshold. A non-applicable NFR has a Requirement cell that starts with `N/A:` and a reason; do not write "Not applicable". Each applicable NFR has one row in the NFR table of SRS §8. The NFR groups map onto ISO/IEC 25010:2023 as follows:

| ISO/IEC 25010:2023 characteristic | specflow NFR group |
| --- | --- |
| Functional suitability | Not an NFR: FR and AC in SRS §6, §8 |
| Performance efficiency (time behaviour, resource utilization, capacity) | `PERF` |
| Compatibility (co-existence, interoperability) | `COMPAT` |
| Interaction capability (formerly usability) | `USAB` |
| Reliability (faultlessness, availability, fault tolerance, recoverability) | `RELI` |
| Security (confidentiality, integrity, non-repudiation, accountability, authenticity, resistance) | `SEC`; the audit log that serves accountability is recorded under `OBS` |
| Maintainability | `MAINT` |
| Flexibility (adaptability, installability, replaceability, scalability) | `FLEX` |
| Safety | `SAFE` |

`I18N`, `LEGAL`, `OBS`, `DATA` and `COST` are extension groups of specflow and do not correspond to a 25010 characteristic.

Vague Terms (29148 §5.2.7). The Requirement statement column of an FR and the Requirement and Threshold columns of an NFR do not contain a word from the table below. `scripts/check-templates.sh` reads this table and matches without regard to case; documents are stored in Unicode NFC. A context-dependent vague word (for example "supports", "minimum" next to a number) is judged by the approver at Gate 1 and is not in the table.

| Vague term | Reason | Rewrite as |
| --- | --- | --- |
| `user-friendly` | Subjective | State the operation and a measurable metric |
| `easy to use` | Subjective | Number of steps, completion rate in a test with users |
| `fast` | Not measurable | A time threshold with a unit |
| `optimal` | Implicit comparison, no baseline | A concrete threshold |
| `efficient` | Subjective | A metric and a threshold |
| `flexible` | Not verifiable | State the allowed changes and how they are made |
| `better` | Comparison without a baseline | The baseline for comparison and a number |
| `if possible` | Loophole | A clear condition, or lower the priority to Should |
| `when appropriate` | Loophole | A clear condition |
| `and/or` | Ambiguous logic | Split into two requirements or choose one |
| `etc.` | Incomplete list | List everything |
| `but not limited to` | Open scope | List everything |

## 9. Implementation Plan Format

This format is plain markdown and needs no dedicated tool. It is compatible with the `ak plan` command of AgentKit, but the template set does not require installing `ak`. In a project, the approver of Gate 4 checks the rules below; `scripts/check-templates.sh` checks them on the examples of the template set.

- Each plan is a directory `plans/{YYMMDD-HHmm}-<slug>/` that holds `plan.md` and the phase files `phase-NN-<slug>.md`, NN being two digits running continuously from `01`, `<slug>` being `kebab-case`.
- `plan.md` has frontmatter with `title` and the keys of `implementation-plan` in §3; `status` is `pending`, `in-progress` or `completed`.
- Each phase file has frontmatter with `phase` equal to the number NN in the file name, `title` and the keys of `implementation-phase` in §3; `status` is `todo`, `in-progress` or `done`.
- `plan.md` has a Phases table: each phase file has exactly one row, the Phase column is a relative link to that file, and the Status column matches the `status` of the phase. The Status column is matched without regard to case; `Pending` is equivalent to `todo`, `In progress` to `in-progress`, `Completed` to `done`.
- No link in the Phases table points to a phase file that does not exist.
- `plan.md` has a `Version History` section.
- A phase file has a `Read First` section: each line is a project document in inline code, followed by the sections to read in the form `§1.5, §2, §9`. `scripts/check-templates.sh` reports an error when the document does not exist, when a line has no section, or when the document has no heading that carries that section number. A phase loads only these sections of the SPEC and ARCHITECTURE, not the full text (PLAYBOOK §6, row 4b).

Release Plan. One plan implements every SPEC of a release (PLAYBOOK §2.5):

- The plan directory of a release follows the general rule `plans/{YYMMDD-HHmm}-<slug>/`; the slug should be `release-<release-slug>`, with `<release-slug>` being the release label in `kebab-case`. The directory name is not a condition: the release is identified by the `release` key.
- `plan.md` has the key `release` (the release label in the Release column of SRS §6.1) and `spec_ids` (a YAML list of every SPEC of the release that the plan implements), and has no `spec_id`.
- Each phase file has a `spec_id` that is one element of `spec_ids`; a phase belongs to only one SPEC. Phases of the same SPEC stand next to each other.
- Each element of `spec_ids` has at least one phase and has a SPEC file in `docs/specs/`.
- The `release` key (§3) of a SPEC in `spec_ids` equals the `release` of the plan.
- Every FR that a SPEC in `spec_ids` cites in SPEC §1.5 has a Release equal to `release`; any SPEC that cites an FR of the release is in `spec_ids`, except a `superseded` SPEC (PLAYBOOK §8).

## 10. UI/UX Standards

This section is the only source of the interface design rules that wireframes at Stage 1W (PLAYBOOK §2.2.1) must follow. An overlay keeps only the numbers and the way of filling in that are specific to a platform; templates, the PLAYBOOK and rules for agents point back to this section and do not restate the rules.

### 10.1. Foundation

- Process: human-centred design per ISO 9241-210:2019. Understand the context of use in the SRS, design in the wireframe, evaluate with the heuristic table (10.3) and the deceptive pattern table (10.4) before Gate 1W, then fix and evaluate again.
- Interaction quality: the Interaction capability characteristic of ISO/IEC 25010:2023, which is the NFR group `USAB` (§8). The eight sub-characteristics are considered at the following places of the wireframe; there is no separate checklist for each characteristic.

| ISO/IEC 25010:2023 sub-characteristic | Where it is considered on the wireframe |
| --- | --- |
| Appropriateness recognizability | Purpose of the page; labels in the component table |
| Learnability | `Initial` state of the page; navigation diagram of the index |
| Operability | Low-fi layout, component table, accessibility section of the page (keyboard, focus, touch targets) |
| User error protection | `Error` state and ACs of the page; heuristics `H5`, `H9` |
| User engagement | Visual direction and motion in the design system (10.7); not considered on a low-fi page |
| Inclusivity | Accessibility section of the page; the self-review questions in 10.5 |
| User assistance | Accessibility section of the page; the help entry in the navigation diagram (criterion 3.2.6) |
| Self-descriptiveness | Labels in the component table and the low-fi layout; heuristics `H2`, `H6` |

- Accessibility: WCAG 2.2 (a W3C Recommendation) at the level that the NFR-USAB of the SRS chooses (`A`, `AA` or `AAA`). WCAG 3.0 is not used yet because it is still a Working Draft; the template set revisits it when it becomes a Candidate Recommendation.

### 10.2. WCAG 2.2 Criteria at Wireframe Level

The table below lists the success criteria that can be seen on a low-fi wireframe. A criterion applies to a project when the level in NFR-USAB is equal to or higher than the level of the criterion (`A` < `AA` < `AAA`); a criterion that does not apply records N/A with a reason at its recording place. Other WCAG criteria still apply under NFR-USAB and are checked by `A11Y` tests in SPEC §9; this table only states what the approver of Gate 1W can judge on a wireframe. The platform numbers (touch targets, breakpoints) are in the Stage 1W section of the `OVERLAY.md` of the surface (10.6).

| WCAG 2.2 criterion | Level | Where recorded on the wireframe |
| --- | --- | --- |
| `1.1.1` Non-text Content | A | Accessibility section of the page: the alternative label of each element without text (icon buttons, images) |
| `1.4.4` Resize Text | AA | Accessibility section of the page: the layout when text is enlarged or follows the system font size |
| `1.4.10` Reflow | AA | The low-fi layout is drawn at the smallest width of the surface; no horizontal scrolling, except for content that needs two dimensions such as a large table or a map |
| `2.1.1` Keyboard | A | Accessibility section of the page: every operation in the component table can be done with the keyboard, or with the assistive technology of the operating system on mobile |
| `2.4.3` Focus Order | A | Accessibility section of the page: the focus order or reading order follows the layout |
| `2.4.6` Headings and Labels | AA | Component table: labels and headings state the function accurately |
| `2.4.7` Focus Visible | AA | Accessibility section of the page: the element that has focus is visible |
| `2.4.11` Focus Not Obscured (Minimum) | AA | Accessibility section of the page: a fixed element (header, footer, banner, tab bar) does not fully cover the element that has focus |
| `2.5.7` Dragging Movements | AA | Component table: a drag operation has an alternative with a single tap or click |
| `2.5.8` Target Size (Minimum) | AA | Accessibility section of the page: touch or click targets follow the numbers of the overlay |
| `3.2.6` Consistent Help | A | Navigation diagram of the index: a help entry repeated on several screens sits at the same relative position; recorded once in the index |
| `3.3.1` Error Identification | A | `Error` state of the page: the error names the field or the operation at fault |
| `3.3.2` Labels or Instructions | A | Component table: each input field has a label or instructions |
| `3.3.7` Redundant Entry | A | `Initial` state of a later step in a multi-step flow: data already entered in an earlier step is pre-filled or can be selected again, not asked for again |
| `3.3.8` Accessible Authentication (Minimum) | AA | A page with the line `Authentication screen: Yes`: the authentication method does not rely on a cognitive test (memorizing, transcribing, solving a puzzle) or has an alternative; paste is allowed and password managers can auto-fill |
| `4.1.2` Name, Role, Value | A | Component table and accessibility section: each interactive element has a name and a role that a screen reader can read |
| `4.1.3` Status Messages | AA | Accessibility section of the page: status messages (sending, success, error) are read by a screen reader without moving focus |

### 10.3. Heuristic Evaluation

The wireframe index has one evaluation table based on the 10 heuristics of Nielsen (Nielsen Norman Group), with exactly one row for each key in the table below, in key order. The keys `H1` to `H10` are stable matching keys; the English names are recorded exactly as in the source. The wireframe author evaluates the whole flow of the index and the pages by themselves, without scoring. Each row records a problem level; the problem level is one of `Critical | Minor | None`:

- `Critical`: the user cannot complete the task of an FR, may lose data or money without knowing, or a criterion in 10.2 that applies is violated.
- `Minor`: the user still completes the task but more slowly or with a risk of confusion.
- `None`: no problem is seen; the evaluation cell states the basis.

A `Critical` problem is fixed before Gate 1W. The Problem level column records the level that remains after handling; a problem that was found is stated in the Evaluation column and the fix made in the Handling column, so a problem that was fully fixed is recorded as `None`. A row that remains `Minor` records in the Handling column an `AQ-NN` entry in the Assumptions and Open Questions part, or the reason for accepting it. An index with several surfaces uses one shared table; a problem that belongs to only one surface records the name of the surface in the Handling column. A brownfield project evaluates only screens that have a page; an `Unchanged` screen has no page and so has no evaluation of its own.

| Heuristic key | Name | Considered on the wireframe |
| --- | --- | --- |
| `H1` | Visibility of System Status | The `Loading`, `Success`, `Error` states say what is happening; amounts, quantities and status appear before the user decides |
| `H2` | Match Between the System and the Real World | Labels and the order of steps use the language of the user in the SRS, not internal words |
| `H3` | User Control and Freedom | The navigation diagram has a way to go back, cancel or undo for each flow |
| `H4` | Consistency and Standards | The same operation has the same label and position across pages; follows the conventions of the platform in the overlay |
| `H5` | Error Prevention | An operation that cannot be undone has a confirmation step; input constraints appear before submitting |
| `H6` | Recognition Rather than Recall | Information needed for a later step is shown on the screen, without forcing the user to remember it from an earlier step |
| `H7` | Flexibility and Efficiency of Use | A frequently used flow has a short path; the user is not forced through extra steps |
| `H8` | Aesthetic and Minimalist Design | Each zone of the low-fi layout contains only the components that the FRs of the page need |
| `H9` | Help Users Recognize, Diagnose, and Recover from Errors | The `Error` state says what the error is and how to fix it, tied to the field or operation at fault |
| `H10` | Help and Documentation | A help entry when the flow needs explanation; position per criterion 3.2.6 |

### 10.4. Deceptive Patterns

The five patterns below, named after the categories of deceptive.design, can be seen on a low-fi wireframe. The wireframe index has a check table with exactly one row for each key `DP1` to `DP5`, in key order. The result is `None` with evidence (the page, component or edge of the navigation diagram that was examined), or `Found` with the location. Gate 1W blocks while a `Found` row remains. A pattern belongs to the presentation; when removing a pattern requires changing a business rule (for example the moment a fee is shown), fix the SRS first per PLAYBOOK §8. A brownfield project checks only screens that have a page, as in 10.3.

| Deceptive pattern key | Name | Sign on the wireframe |
| --- | --- | --- |
| `DP1` | Preselection | A consent box, a newsletter box or a choice that benefits the provider is pre-selected in the component table or layout (`[x] Label`, `(x) Label`) |
| `DP2` | Obstruction | In a flow, the way to decline, skip or leave takes more steps, is hidden or is less prominent than the way to agree (compare the number of edges in the navigation diagram and the components in the layout) |
| `DP3` | Hidden costs | A fee, a total or a binding term appears only at the last step or after ordering, not at the step where the user chooses |
| `DP4` | Hard to cancel | A plan, subscription or account can be started in the app but has no way to cancel, or the way to cancel goes through another channel, in the navigation diagram |
| `DP5` | Confirmshaming | The label of the option to decline shames the user or makes the user feel guilty |

The boundary between `DP2` and `DP4`: `DP2` looks at a flow that is being carried out (payment, sign-up, granting permission); `DP4` looks at ending a long-lasting relationship (a paid plan, a mailing subscription, an account).

### 10.5. Self-review Questions

The questions below do not block a gate and have no row in the index; the wireframe author asks them before submitting to Gate 1W, and changes that arise are recorded like any other change to the wireframe.

- Inclusive design (Microsoft Inclusive Design): who is excluded from this flow (a permanent, temporary or situational disability, such as one busy hand or bright sunlight)? Does the solution for that group also help all other users?
- Screen structure: does any information appear in two places on the same screen (between a list and a detail panel, between the header and the page title)? Do two signals compete for the same meaning (two buttons with the same emphasis without intent, color and an icon reporting one state in two ways)? Peer choices that are intentional, recorded in the Primary action line, do not count. Does the priority information of the page come first and stand out most?
- Cognitive accessibility (W3C COGA "Making Content Usable"): do labels and messages use simple, familiar words? Do icons come with text? Does the flow force the user to remember information, or impose time limits or needless pressure? Are the steps consistent and predictable?

### 10.6. Platform Guidance

- The numbers and structural guidance of a platform (minimum touch targets, breakpoints, safe areas, navigation patterns, back gestures) are recorded in the Stage 1W section of the `OVERLAY.md` of the surface, because Stage 1W reads that file and does not read the section files of the overlay.
- Visual style belongs to the design system in 10.7.
- An application that does not run on the web applies the WCAG criteria written in web terms (page, page title) according to W3C WCAG2ICT, without inventing its own interpretation.

### 10.7. Design System

This section is the only source of the rules of the layered design system used at Stage 1W.

Seven layers, from foundation to experience:

| Layer | Content | Where recorded |
| --- | --- | --- |
| Foundation | Colors by role, typography, spacing, grid and breakpoints, iconography, elevation, radius, motion, content voice | `docs/design-system/DESIGN_SYSTEM.md` |
| Token | Machine-readable values of the Foundation, per DTCG, three tiers `primitive`, `semantic`, `component` | `docs/design-system/tokens.json` (and the mode files) |
| Primitive | The smallest visual element that uses tokens directly (background color, font size, spacing) | `docs/design-system/DESIGN_SYSTEM.md` |
| Component | A unit of interface with its own anatomy, variants and states, assembled from primitives and tokens | `docs/design-system/DESIGN_SYSTEM.md` |
| Pattern | A way to solve an interaction problem, assembling several components | `docs/design-system/DESIGN_SYSTEM.md` |
| Template | A zone structure shared by several pages, assembling patterns and components | `docs/design-system/DESIGN_SYSTEM.md` |
| Experience | One concrete screen, choosing one Template and citing Patterns and Components | `SCR-*` page |

Visual direction: the agent proposes 2 to 3 directions, each citing the grounds in the brand, users, domain and tone of the project; the project owner chooses exactly one direction, and the document records the reason for the choice. The default theme of a UI library (for example Material 3, Apple Human Interface Guidelines, Fluent 2) is a direction like any other, used only when chosen on purpose, not the default of the template set; the document has the line "Library default theme" recording `Not used` or `Used on purpose` with a reason. Material 3, Apple HIG and Fluent 2 are only references or a direction that was chosen, not mandatory rules.

Foundations: colors by role (not by color name), typography (type scale, weight, line height), spacing, grid and breakpoints (platform numbers refer to `OVERLAY.md`, see 10.6), iconography, elevation, radius, motion with a reduced motion mode, content voice.

Token (Design Token), per the DTCG Format Module 2025.10 (Design Tokens Community Group):

- The set of `$type` kinds that the template set accepts, exactly the 13 types of DTCG:

  | DTCG type | Note |
  | --- | --- |
  | `color` | `$value` is an object with `colorSpace`, `components`, `hex` |
  | `dimension` | `$value` is an object with `value`, `unit` |
  | `fontFamily` | |
  | `fontWeight` | |
  | `duration` | |
  | `cubicBezier` | |
  | `number` | |
  | `strokeStyle` | |
  | `border` | Composite |
  | `transition` | Composite |
  | `shadow` | Composite |
  | `gradient` | Composite |
  | `typography` | Composite |

- Three fixed tier groups, one alias rule for each tier:

  | Tier group | Alias rule |
  | --- | --- |
  | `primitive` | Has a direct value, no alias |
  | `semantic` | Alias to a `primitive` token; a composite token is allowed when every sub-value is an alias down to `primitive` |
  | `component` | Alias to a `semantic` token; a composite token is allowed when every sub-value is an alias down to `semantic` |

- An alias is written only in the form `{a.b.c}`; the template set does not use `$ref`, `$extends` or `$root` of DTCG. `$type` is resolved in exactly this order: that of the token itself, then that of the target token when the token is an alias, then that of the nearest group that contains the token.
- `color`: `$value` is an object with `colorSpace` equal to `srgb`, `components` matching `hex` with a deviation of no more than 1/255 per channel, and `hex`; `hex` is the only source for contrast, for CSS and for other token generation tools.
- `dimension`: `$value` is an object with `value` (a number) and `unit` (`px` or `rem`).
- A token name does not start with `$` and does not contain `{`, `}`, `.`.
- Mode (light, dark, per platform): `tokens.json` is the default mode of the project. Each other mode is a file `tokens.<mode>.json` that only redeclares the `semantic` tokens that already exist in `tokens.json`, keeping the same `$type`; there is no separate resolver file. A project with both web and mobile that use one token system: `semantic` tokens are shared, and modes are distinguished by platform when needed.
- The CSS variable name of a token is the token path without the tier group name, with the remaining segments joined by `-` (for example `semantic.color.text.default` becomes `--color-text-default`); two different tokens must not produce the same variable name.
- Code and HTML only use `semantic` and `component` tokens, and do not use `primitive` tokens directly.

Contrast per pair: the document has a table of color pairs, each row recording the foreground color token (text or graphic), the background color token, the typography token of the text (column Text token; record `None` on a non-text row), the mode, the kind (`text` or `non-text`), the computed contrast ratio and the threshold that applies. Large text per the WCAG definition is derived from the typography token in the Text token column, not declared by the writer: `fontSize` from 24px, or from 18.66px when `fontWeight` is 700 or higher; `rem` is computed with 16px = 1rem. Thresholds per WCAG 2.2: criterion `1.4.3` (normal text 4.5:1, large text 3:1) and `1.4.11` (non-text 3:1), always at level AA regardless of the level in NFR-USAB; computed separately for each mode from the `hex` value of the token. The computation, one source for every place: resolve the aliases of each token in the mode of the row down to an opaque color (no `alpha` below 1); divide each channel `c` of `hex` (0 to 255) by 255, then take `c / 12.92` when `c` is not more than 0.04045, otherwise `((c + 0.055) / 1.055)^2.4`; relative luminance `L = 0.2126·R + 0.7152·G + 0.0722·B`; ratio `(L light + 0.05) / (L dark + 0.05)`, truncated down to 2 digits, never rounded up (4.499 is recorded as 4.49, which does not reach 4.5). Self-checking needs nothing in `scripts/`: compute each row of the table with a command that runs (`awk`, `python3` or `node`), not in your head; the checker of the template set is only an option when the project has it.

Catalog of components, patterns, templates: IDs of the form `CMP-NN`, `PAT-NN`, `TPL-NN` (CONVENTIONS §4), numbered within the project. Minimum content of each entry: component (anatomy, variants, states, keyboard behavior per the WAI-ARIA APG pattern, tokens used, surfaces it applies to); pattern (problem solved, when to use, when not to use, components used, flow, states); template (zone structure, patterns used, components used, surfaces it applies to, change per breakpoint). The catalog lists only entries that at least one page uses, directly or indirectly through the Components used column of another entry that is in use; it does not list unused entries.

Page (Experience): each page chooses exactly one `TPL-*`; the Pattern line records `PAT-*` or `None`; each row of the component table has a column `Component ID` that cites a `CMP-*` that exists in the catalog. The zones of the low-fi layout (CONVENTIONS §7) follow exactly the zones that the chosen Template defines. The page also records three lines: `Priority information` (1 to 3 pieces of information the user needs most to do the main task, in order, separated by `;`; each item is a field in SRS §4.2 or a label in the component table; the first piece comes first and stands out most in the layout), `Primary action` (exactly one action, a label in backticks that matches a cell in the Component column of the component table, or `None` with a reason when the screen is view-only or when peer actions are intentional) and `Edge content` (edge cases taken from constraints that already exist in the SRS, such as the data dictionary §4.2, business rules or the flow of an FR, and how each case is displayed; no new limit is set; or `None` with a reason when the screen shows no data or the SRS has no constraint for that data); the zones of the low-fi layout are numbered per §7.

Token-only use: the HTML of a page declares CSS variables in a `:root` block, following the values of the mode whose Applies when column records the surface of the page; a page that records no mode has its `:root` follow the default mode. Outside the `:root` block, the value part declared in `<style>` must not contain a raw color (`#…`, `rgb(`, `hsl(`, `oklch(`, `oklab(`); the spacing properties (`margin`, `padding`, `gap`, `row-gap`, `column-gap`, `inset`, `top`, `right`, `bottom`, `left`, including shorthand forms such as `margin-top`), radius (`border-radius` and its corner variants) and `font-size` may only use `var(--…)` or one of the keywords `0`, `auto`, `100%`, `inherit`, `initial`, `unset`. Other properties (a device frame such as `max-width`, border thickness) may still be written with a raw `px` value. Code (outside the HTML of the wireframe) uses only tokens per the golden rule of the overlay, applying when the project has `docs/design-system/`: raw color, spacing, radius and font size sit only in the token mapping file in the code (CSS variables or a theme object). That file is a mapping from `tokens.json`, written by hand following the mapping table of the stack profile or generated by a tool the project chooses (the template set does not install a token build tool), and changed at the same time as `tokens.json`; everywhere else uses only tokens.

### 10.8. References

The documents below are only for reference when a deeper explanation is needed; they are not a source of MUST rules, because their content is already covered by the standards in 10.1 to 10.4.

- ISO 9241-11 (definition of usability), ISO 9241-110 (interaction principles), ISO 9241-112 (presentation of information), ISO 9241-125 (visual presentation), ISO 9241-171 (software accessibility).
- ISO/IEC 40500: the ISO edition of WCAG 2.2, with technical content identical to WCAG 2.2.
- Shneiderman's eight golden rules: they mostly overlap with the 10 heuristics in 10.3.
- EN 301 549 V4.1.1 and the laws on accessibility or deceptive patterns of a region: only examples; a project chooses the standards or laws it must follow in Intake §7, and the template set does not make the law of any region a rule.

## 11. Roadmap Format

The roadmap `docs/ROADMAP.md` is the list of work to do for the project that the coding agent follows (PLAYBOOK §2, 2.5 to 2.7). In a project, the agent checks the rules below by the reconciliation in PLAYBOOK §2.6; `scripts/check-templates.sh` checks them on the examples of the template set, except for commits and tags that really exist in git.

- The file is copied from `core/08_Roadmap_Template.md`, `doc_type: roadmap`, `status: active`; it has all of §1 Progress, 2 Work Queue (2.1 Functional Requirements, 2.2 Must NFRs), 3 New Requests, 4 Done, 5 Milestones. The roadmap does not pass a gate of its own and has no Version History; its history is git.
- Intake §14 has a row `Tag format`, whose value is a tag name pattern in backticks; the default is `{release}-{feature-key}`, in which `{release}` is the release label in lower case and `{feature-key}` is the `<FEATURE_KEY>` of the SPEC file in lower case, with underscores changed to hyphens, for example `r1-order-create`.
- Status of a row: `Not started`, `In progress`, `Done`, `Confirmed`, `Dropped`. `Dropped` is used only for a row whose requirement the SRS has dropped or moved to `Won't` (PLAYBOOK §8); a `Dropped` row is not counted in §1.

Part 2.1, Functional Requirements:

- Exactly one row for each FR in SRS §6.1 whose Priority is not `Won't`; no row for other FRs, except a `Dropped` row. Brownfield project: an FR whose Work needed is `Unchanged` in Gap Analysis §2 has no row (`brownfield/PLAYBOOK_BROWNFIELD.md` §5.3 rule 6). The row of an FR that the SRS still requires to be built must not be in status `Dropped`.
- Name, Priority and Release equal the columns Function name, Priority and Release of the FR in SRS §6.1.
- SPEC and Phase count only documents that have passed a gate: a SPEC has a `version` from `1.0.0` (passed Gate 3), a plan has a `version` from `1.0.0` (passed Gate 4). A SPEC or plan that is still a `0.x` draft is not yet recorded in the roadmap, consistent with the SPEC column being filled on receiving "Approved at Gate 3" and the Phase column on receiving "Approved at Gate 4" (PLAYBOOK §2.7).
- SPEC lists the `spec_id` of every non-`superseded` SPEC that has the FR in §1.5, separated by commas, ordered by the first phase number of the SPEC (a SPEC with no phase comes after, ordered by file name); `Not yet` when there is no SPEC. A `Done` or `Confirmed` row must have a SPEC, and every phase of every such SPEC has `status: done`.
- Phase is the phase numbers of the plan that have the `spec_id` of those SPECs: `N` for a single phase, `N to M` for consecutive phases, ranges separated by commas when not consecutive; `Not yet` when there is no phase.
- Order: by release (the order of the rows in §1); within a release, rows that have a Phase are ordered by the first phase number in the plan of that release, the same SPEC following the order of the FRs in SPEC §1.5; rows without a Phase come after, ordered by Priority `Must`, `Should`, `Could` and then the order in SRS §6.1 (SRS `modular`: the order of modules in the table of §6 of the master file, then the order inside the module file). A `Dropped` row is not considered in the order. The column `#` is numbered continuously from 1.
- Work in order: no row is `Done` or `Confirmed` while a row before it in the same release is still `Not started`.
- A release that has an approved plan (`plan.md` has `release` equal to that release and `version` from `1.0.0`): every row of the release has a SPEC and a Phase.

Part 2.2, Must Non-functional Requirements:

- Exactly one row for each NFR in SRS §7 whose Priority is `Must`, in the order of SRS §7; no row for other NFRs, except a `Dropped` row; the row of a Must NFR that is still in force must not be in status `Dropped`. Name copies the Group column; Verification method equals the Verification method column of the NFR in SRS §7.
- SPEC lists the `spec_id` of every non-`superseded` SPEC that has the NFR in §1.5, separated by commas, in the order the SPECs first appear in §2.1; `None` when no SPEC cites it.
- Closing release is a release in §1: the first release for NFRs that exist from Gate 1, the release in progress for a Must NFR added later (PLAYBOOK §8). An NFR row is `Confirmed` only when every FR row of its Closing release is `Confirmed`.

Parts 3, 4, 5 and part 1:

- Part 3: the Decision column is `Pending`, `Raise change request` with the document to be changed, or `Dropped` with a reason. If there is no new request, one row `None`.
- Part 4: each `Done` or `Confirmed` row in §2 has exactly one row, and there is no row for other rows. Evidence: an FR row records the IDs of the TCs that are in §9 of the SPEC of the row; an NFR row records evidence per SRS §8; when the Verification method is `Test`, it records the IDs of the TCs in SPEC §9 that name that NFR. Commit is a short or full hash (7 to 40 hexadecimal characters). Tag is `Not yet` when the row is `Done`.
- A `Confirmed` row has a tag in §4, that tag has a row in §5 (for an FR row: the row of one SPEC of the row), and every SPEC of the FR row has `status: implemented`.
- Part 5: one row each time a SPEC passes Gate 5: Tag (not repeated; from the second time of the same SPEC onward, add the suffix `-2`, `-3`), the SPEC of the project, Commit (hexadecimal as in §4), Date, Approver, Rollback method. The newest row of each SPEC has a tag that is the tag of at least one row in §4, unless the SPEC is being reworked per PLAYBOOK §8 (its row has returned to `Not started`); older rows are kept so that rollback is still possible.
- Part 1: one row for each release in SRS §6.1, none missing, none repeated, in the order of releases in the Intake (the Timeline section). Total is the number of FR rows of the release plus the number of NFR rows whose Closing release is that release, not counting `Dropped` rows; Done counts `Done` or `Confirmed` rows; Confirmed counts `Confirmed` rows; Complete is Confirmed divided by Total times 100, rounded down, with `%`. The line `- In progress:` records `None` when no row is `In progress`, otherwise it records the ID of every `In progress` row, with the SPEC and phase.
- A roadmap table cell that contains the character `|` is written `\|`, like the tables of the SRS; the checker reads `\|` as a character in the cell.
