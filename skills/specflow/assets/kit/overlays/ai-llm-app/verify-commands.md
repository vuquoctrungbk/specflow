---
doc_type: overlay-section
status: stable
version: 1.0.0
language: en
surface: ai-llm-app
---

# Overlay ai-llm-app: verify commands

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Item | Command | Pass condition |
| --- | --- | --- |
| Code generation | `{{CODEGEN_CMD}}` | Exit code 0; runs before every other command |
| Lint | `{{LINT_CMD}}` | 0 errors, 0 warnings |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 errors |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass with a fake model provider |
| E2E test | `{{E2E_TEST_CMD}}` | 100% pass; a feature with no UI or API of its own records N/A with the reason |
| Prompt evaluation | `{{EVAL_CMD}}` | Runs only in the CI evaluation job (needs the API key of the evaluation environment), not in the coding agent's commit loop: every run meets the Prompt Spec thresholds for `EVAL`, `INJ`, `COST`; required when the prompt, guard, model client, model or parameters change, and runs on a schedule |
| Coverage | `{{COVERAGE_CMD}}` | ≥ the NFR-MAINT threshold |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | No high or critical vulnerability left without an ADR accepting the risk |
<!-- /SLOT-CONTENT -->
