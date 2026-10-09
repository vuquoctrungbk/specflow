---
doc_type: overlay-section
status: stable
version: 1.0.0
language: en
surface: frontend-web
---

# Overlay frontend-web: verify commands

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Item | Command | Pass condition |
| --- | --- | --- |
| Code generation | `{{CODEGEN_CMD}}` | Exit code 0; runs before every other command |
| Lint | `{{LINT_CMD}}` | 0 errors, 0 warnings |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 errors |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass with a mock API that matches OpenAPI |
| E2E, accessibility and visual | `{{E2E_TEST_CMD}}` | 100% pass, 0 accessibility violations at the WCAG level of NFR-USAB, screenshots match the baseline |
| Coverage | `{{COVERAGE_CMD}}` | ≥ the threshold of NFR-MAINT |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | No high or critical vulnerability left without an ADR accepting the risk |
<!-- /SLOT-CONTENT -->
