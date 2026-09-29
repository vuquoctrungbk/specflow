# Request routing

Use this file to turn a request and the project's state into one stage of the
specflow pipeline and its prompt. The stage table in `specflow/PLAYBOOK.md`
section 2 is the authority for stages, gates and prompts; this file adds how
to recognise them from what a user types.

## Recognising the stage

| The user asks for | Stage | Prompt in `specflow/PROMPTS.md` | Upstream gate that must have passed |
| --- | --- | --- | --- |
| A new project, an idea, a brief, "intake", "khởi tạo dự án" | 0 Intake | Prompt 0 | None |
| Adopting specflow on existing code, "brownfield", "dự án có sẵn" | 0 then 0R | Prompt 0 with the brownfield additions, then B0 to B2 in `specflow/brownfield/PLAYBOOK_BROWNFIELD.md`; later B3 (Gap Analysis, after the SRS) and B4 (Migration Plan, with stage 2) | None |
| Requirements, "SRS", "đặc tả yêu cầu", use cases, FR or NFR | 1 SRS | Prompt 1 | Intake |
| Screens, "wireframe", UI flow, mockups for the SRS | 1W Wireframe | Prompt 1W | SRS (and the Intake says stage 1W runs) |
| "Architecture", tech stack, ADR, data model, deployment | 2 Architecture and ADR | Prompt 2 | SRS, and wireframes when stage 1W runs |
| "SPEC", API contract, a feature spec of a release | 3 Spec, one SPEC per turn | Prompt 3 | ARCHITECTURE and its ADRs |
| "Plan", implementation plan, phases of release R*n* | 4a Plan | Prompt 4 part A | Every SPEC of the release |
| Code a phase of an approved plan | 4b Coding TDD | Prompt 4 part B | The plan, with the Definition of Ready met |
| Verify, review, check a SPEC against the code | 5 Verify | Prompt 5 | The SPEC's phases coded |
| Update the documents after code changed | 5 Sync Docs | Prompt 6 | The SPEC's verify report from Prompt 5 passed |
| "Continue", "tiếp tục", a new session on an existing project | The stage in progress | Prompt Resume | As for that stage |
| "Duyệt Gate N", "approve gate N", or a list of failed rows | The stage of gate N | `specflow/PLAYBOOK.md` section 2.7 | Gate N's documents |

When one request names several documents ("write the SRS and the
architecture"), run the earliest stage whose gate has not passed, and say
which stages follow. The kit produces one stage per turn (PLAYBOOK section 7
rule 9) because each stage's approved output is the next stage's input.

## Reading the project's state

A gate has passed when its documents carry the approval that PLAYBOOK section
2.7 records: a Version History row naming the approver and, by document type,
`status: approved` (Intake, SRS, wireframes, ARCHITECTURE, SPEC), `accepted`
(ADR) or `version: 1.0.0` or later with `status` still `pending` or beyond (the
plan, whose status list has no `approved`). A SPEC that is `implemented`
passed Gate 3 earlier. A document in `draft` or `in-review` has not passed.

Read, in this order: `docs/intake/PROJECT_INTAKE.md`,
`docs/srs/`, `docs/wireframes/00_WIREFRAME_INDEX.md`, `docs/ARCHITECTURE.md`
and `docs/adr/`, `docs/specs/`, `plans/`. The Intake's Routing Decision tells
you the overlays, the starter, whether stage 1W runs, and the planned
releases; its section 9 names the approver of each gate.

## When the upstream gate has not passed

The request that motivates this skill is often "write the SRS" in a project
with no Intake. The kit builds the SRS on an approved Intake because the
Intake fixes the overlays, the SRS sections they add, the releases and the
approvers; Prompt 1 starts from "Intake đã duyệt", and each turn produces one
stage (PLAYBOOK section 1.2 principle 2, section 7 rule 9). Explain that in a
sentence, then ask one question with these options:

1. **Intake first (recommended).** Draft the Intake from the request and
   attachments now, run its question round and stop at Gate 0. Keep the SRS
   details the user already gave in the Intake (scope, goals, notes) so the SRS
   starts from them right after "Duyệt Gate 0".
2. **The user supplies the missing upstream document.** If they already have
   an Intake (or SRS, architecture) elsewhere, place it at the expected path
   and check it against the template. A document that is not yet `approved`
   with an approver row in its Version History still goes through its gate
   (PLAYBOOK section 2.7) before the next stage starts.

Never mark a document `approved` to unblock a later stage, and never start
stage 4b (code) before the Definition of Ready holds: those two rules are what
make the documents trustworthy for the people who build from them.

## Brownfield

A repository with source code but no specflow documents runs stage 0 with the
brownfield additions, then stage 0R (Prompts B0 to B2) before the SRS, as
`specflow/brownfield/PLAYBOOK_BROWNFIELD.md` describes. Its safety rules in
section 5.1 apply from the first command: never touch production data or
running services. Its section 5.5 adds that an existing `CLAUDE.md`,
`AGENTS.md`, `.claude/` or `docs/` is never overwritten.
