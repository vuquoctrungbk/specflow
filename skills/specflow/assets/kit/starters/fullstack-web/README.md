# Starter fullstack-web

Pre-assembled templates for a project with two surfaces, `backend-api` and `frontend-web`, in one set of documents (Routing Decision: `overlays: [backend-api, frontend-web]`, `starter: fullstack-web`). Each file is a core template in `core/` with its slots replaced by the content of the [`backend-api`](../../overlays/backend-api/OVERLAY.md) and [`frontend-web`](../../overlays/frontend-web/OVERLAY.md) overlays per the multiple-overlay rule in CONVENTIONS §2: a slot that has blocks from both surfaces separates them with the headings `Backend API` and `Frontend Web` at the block level of the slot, and the headings inside are lowered by one level. The starter is not tied to a stack profile: the `PROFILE-SLOT` lines and the `Profile`-sourced placeholders are kept so that the agent fills them with the profile of each surface chosen in the Intake.

## Files in the starter

| File | Assembled from | Output in the project | Stage |
| --- | --- | --- | --- |
| [SRS_Template.md](SRS_Template.md) | `core/01_SRS_Template.md` + `srs-sections.md` of the two overlays | `docs/srs/SRS.md` or a modular SRS | 1 |
| [ARCHITECTURE_Template.md](ARCHITECTURE_Template.md) | `core/02_Architecture_Core_Template.md` + `architecture-sections.md` of the two overlays | `docs/ARCHITECTURE.md` | 2 |
| [SPEC_Backend_Template.md](SPEC_Backend_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/backend-api/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` for an API feature | 3 |
| [SPEC_Frontend_Template.md](SPEC_Frontend_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/frontend-web/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` for a screen | 3 |
| [CLAUDE.md.template](CLAUDE.md.template) | `core/06_Agent_Context_Template.md` + `verify-commands.md` of the two overlays + the rules of the two overlays (Appendix A.3, A.4) | `CLAUDE.md`, `.claude/rules/` | 0 and 2 |

Templates used straight from core, not through the starter: [Intake](../../core/00_Project_Intake_Template.md), [Wireframe](../../core/07_Wireframe_Template/00_Wireframe_Index_Template.md) (Stage 1W, for the `frontend-web` surface), [Design system](../../core/07_Wireframe_Template/Design_System_Template.md) and [tokens](../../core/07_Wireframe_Template/Design_Tokens_Template.json) (also Stage 1W), [ADR](../../core/03_ADR_Template.md), [Roadmap](../../core/08_Roadmap_Template.md), [Implementation Plan](../../core/05_Implementation_Plan_Template/plan.md).

## Usage

1. Install the kit into `specflow/` per PLAYBOOK §1.4; the starter is at `specflow/starters/fullstack-web/`.
2. Run the prompts of `PROMPTS.md`; the prompts pick the starter files by themselves when the Routing Decision has `starter: fullstack-web`. The SPEC of an API feature uses `SPEC_Backend_Template.md`; the SPEC of a screen uses `SPEC_Frontend_Template.md`. A feature that touches both surfaces has two SPECs; the UI SPEC records the API SPEC in `parent` and in Dependencies (§1.4).
3. When copying a starter file into the project, apply the stack profile of each surface (PLAYBOOK §4, step 3): each `PROFILE-SLOT` line under the heading of a surface is replaced by the `PROFILE-CONTENT` block of the same ID in the profile of that surface, with the heading of the block lowered by one level; the `Profile`-sourced placeholders take their values from the profile of the surface that contains them, so the same placeholder such as `{{LINT_CMD}}` has different values under `Backend API` and under `Frontend Web`.
4. Two surfaces in one repo put their source code in two separate directories, recorded in ARCHITECTURE §4; the verify commands of each surface run in the directory of that surface, and the `paths` of the rules in `.claude/rules/` point to that directory. The web surface generates its API types from `openapi/openapi.yaml` of the API surface; if the profile of the web surface reads another path, the generation step copies this file to that path and ARCHITECTURE §5 records how.

## Maintenance

- Do not edit the files in the starter. Edit `core/` or the overlays, then re-assemble the starter per CONVENTIONS §2; the frontmatter of the starter (`overlays`, `assembled_from`, `template_version`) is also a result of the assembly.
- `scripts/check-templates.sh` re-assembles each starter file from the sources declared in `assembled_from` and `overlays`, and reports an error when a file in the starter differs from the assembly result by even one character.
