# Starter backend-api

Pre-assembled templates for a project with one `backend-api` surface (Routing Decision: `overlays: [backend-api]`, `starter: backend-api`). Each file is a core template in `core/` with its slots replaced by the content of the [`backend-api`](../../overlays/backend-api/OVERLAY.md) overlay. The starter is not tied to a stack profile: the `PROFILE-SLOT` lines and the `Profile`-sourced placeholders are kept so that the agent fills them with the profile chosen in the Intake.

## Files in the starter

| File | Assembled from | Output in the project | Stage |
| --- | --- | --- | --- |
| [SRS_Template.md](SRS_Template.md) | `core/01_SRS_Template.md` + `overlays/backend-api/srs-sections.md` | `docs/srs/SRS.md` or a modular SRS | 1 |
| [ARCHITECTURE_Template.md](ARCHITECTURE_Template.md) | `core/02_Architecture_Core_Template.md` + `overlays/backend-api/architecture-sections.md` | `docs/ARCHITECTURE.md` | 2 |
| [SPEC_Template.md](SPEC_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/backend-api/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` | 3 |
| [CLAUDE.md.template](CLAUDE.md.template) | `core/06_Agent_Context_Template.md` + `overlays/backend-api/verify-commands.md` + the overlay rule (Appendix A.3) | `CLAUDE.md`, `.claude/rules/` | 0 and 2 |

Templates used straight from core, not through the starter: [Intake](../../core/00_Project_Intake_Template.md), [ADR](../../core/03_ADR_Template.md), [Roadmap](../../core/08_Roadmap_Template.md), [Implementation Plan](../../core/05_Implementation_Plan_Template/plan.md).

## Usage

1. Install the kit into `specflow/` per PLAYBOOK §1.4; the starter is at `specflow/starters/backend-api/`.
2. Run the prompts of `PROMPTS.md`; the prompts pick the starter files by themselves when the Routing Decision has `starter: backend-api`.
3. When copying a starter file into the project, apply the chosen stack profile (PLAYBOOK §4, step 3): replace each `PROFILE-SLOT` line with the `PROFILE-CONTENT` block of the same ID in the profile, replace the `Profile`-sourced placeholders with the table "Placeholder values", and add the profile to `assembled_from`.

## Maintenance

- Do not edit the files in the starter. Edit `core/` or `overlays/backend-api/`, then re-assemble the starter per CONVENTIONS §2; the frontmatter of the starter (`overlays`, `assembled_from`, `template_version`) is also a result of the assembly.
- `scripts/check-templates.sh` re-assembles each starter file from the sources declared in `assembled_from` and `overlays`, and reports an error when a file in the starter differs from the assembly result by even one character. If you change a source without re-assembling the starter, the checker does not pass.
