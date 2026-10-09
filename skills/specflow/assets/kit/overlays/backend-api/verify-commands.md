---
doc_type: overlay-section
status: stable
version: 1.0.0
language: en
surface: backend-api
---

# Overlay backend-api: verify commands

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Item | Command | Pass condition |
| --- | --- | --- |
| Code generation | `{{CODEGEN_CMD}}` | Exit code 0; run before every other command |
| Lint | `{{LINT_CMD}}` | 0 errors, 0 warnings |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 errors |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass on a real database running in isolation |
| E2E test | `{{E2E_TEST_CMD}}` | 100% pass |
| Coverage | `{{COVERAGE_CMD}}` | ≥ the NFR-MAINT threshold |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | No high or critical vulnerability left without an ADR accepting the risk |
| Migration | `{{MIGRATION_CHECK_CMD}}` | Schema is valid and the migration directory matches the schema |
| OpenAPI document | `{{OPENAPI_LINT_CMD}}` | 0 errors |
<!-- /SLOT-CONTENT -->
