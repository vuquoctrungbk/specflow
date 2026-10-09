---
doc_type: overlay-section
status: stable
version: 1.0.0
language: en
surface: mobile-app
---

# Overlay mobile-app: verify commands

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Item | Command | Pass condition |
| --- | --- | --- |
| Code generation | `{{CODEGEN_CMD}}` | Exit code 0; runs before every other command |
| Lint | `{{LINT_CMD}}` | 0 errors, 0 warnings |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 errors |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass on a real local database with a mock API that matches OpenAPI |
| E2E test | `{{E2E_TEST_CMD}}` | Runs only in CI: 100% pass on iOS and Android emulators; the coding agent does not run this command before commit |
| Coverage | `{{COVERAGE_CMD}}` | ≥ the NFR-MAINT threshold |
| Platform check | `{{PLATFORM_CHECK_CMD}}` | 0 issues in configuration and SDK version compatibility |
| Build | `{{BUILD_CMD}}` | Exit code 0 for both iOS and Android |
| Dependency audit | `{{AUDIT_CMD}}` | No high or critical vulnerability left without an ADR accepting the risk |
<!-- /SLOT-CONTENT -->
