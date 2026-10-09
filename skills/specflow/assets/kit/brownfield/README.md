# Brownfield Kit

Entry point for a project that already has running source code (Intake `mode: brownfield`). This kit shares the core templates, overlays, stack profiles and starters with a greenfield project; it only adds the steps that recover the current state, measure the regression baseline, analyse the gap, plan the migration, the addendum for SPEC and the additions to the PLAYBOOK prompts. The full workflow is in [PLAYBOOK_BROWNFIELD.md](PLAYBOOK_BROWNFIELD.md).

## Files in the kit

The sequence number in a template name is the order of execution.

| File | Type | Output in the project | Step |
| --- | --- | --- | --- |
| [PLAYBOOK_BROWNFIELD.md](PLAYBOOK_BROWNFIELD.md) | Supplementary playbook | None | Every step |
| [00_Codebase_Summary_Template.md](00_Codebase_Summary_Template.md) | Template | `docs/brownfield/CODEBASE_SUMMARY.md` | 0a |
| [01_As_Is_Architecture_Recovery_Template.md](01_As_Is_Architecture_Recovery_Template.md) | Template | `docs/brownfield/AS_IS_ARCHITECTURE.md` | 0b |
| [02_Regression_Baseline_Template.md](02_Regression_Baseline_Template.md) | Template | `docs/brownfield/REGRESSION_BASELINE.md` | 0c |
| [03_Gap_Analysis_Template.md](03_Gap_Analysis_Template.md) | Template | `docs/brownfield/GAP_ANALYSIS.md` | 0d, after the to-be SRS |
| [04_Migration_Plan_Template.md](04_Migration_Plan_Template.md) | Template | `docs/brownfield/MIGRATION_PLAN.md` | 0e, together with the to-be Architecture |
| [Spec_Brownfield_Addendum.md](Spec_Brownfield_Addendum.md) | SPEC addendum | Three blocks inserted into every SPEC | Stage 3 |

## Usage

1. Before Prompt 0, review and disable any Claude Code hook already in the repo if the hook runs a project command (PLAYBOOK_BROWNFIELD §5.1 rule 6).
2. Run Prompt 0 of PROMPTS.md with `mode: brownfield`, plus the addition in PLAYBOOK_BROWNFIELD §6.1. At Gate 0, the project owner decides whether `REG` tests may be written in Stage 0R (allowed by default; if the repo has no test tool, approve adding one or use the manual procedure) and how to handle the existing `CLAUDE.md`, `.claude/` and `docs/` in the repo.
3. Run Prompt B0 (repo preparation), open a new session, run B1 and then B2 in PLAYBOOK_BROWNFIELD §6; approve Gate 0R. Project commands run only in a clean worktree, when every data store and external service points to a local or disposable target (PLAYBOOK_BROWNFIELD §5.1).
4. Run Prompt 1 (to-be SRS) of PROMPTS.md plus the addition, then Prompt B3; approve Gate 1.
5. Run Prompt 2 (to-be Architecture) of PROMPTS.md plus the addition, then Prompt B4; approve Gate 2.
6. From Stage 3, run the PLAYBOOK prompt plus the addition; every SPEC applies the brownfield addendum.

## Maintenance

- Do not copy the content of `core/` or `overlays/` here; only reference it.
- `scripts/check-templates.sh` checks the frontmatter, required sections, placeholders, links, numbered headings and stack neutrality of this kit as it does for `core/`, and checks the Gate 0R self-check table of the Regression Baseline against the wording of PLAYBOOK_BROWNFIELD §3.1.
