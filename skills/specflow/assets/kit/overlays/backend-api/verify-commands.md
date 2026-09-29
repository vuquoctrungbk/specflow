---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: backend-api
---

# Overlay backend-api: lệnh verify

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Hạng mục | Lệnh | Điều kiện pass |
| --- | --- | --- |
| Sinh mã | `{{CODEGEN_CMD}}` | Exit code 0; chạy trước mọi lệnh khác |
| Lint | `{{LINT_CMD}}` | 0 lỗi, 0 cảnh báo |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 lỗi |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass trên cơ sở dữ liệu thật chạy cô lập |
| E2E test | `{{E2E_TEST_CMD}}` | 100% pass |
| Coverage | `{{COVERAGE_CMD}}` | ≥ ngưỡng của NFR-MAINT |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | Không còn lỗ hổng high hoặc critical chưa có ADR chấp nhận rủi ro |
| Migration | `{{MIGRATION_CHECK_CMD}}` | Schema hợp lệ và thư mục migration khớp schema |
| Tài liệu OpenAPI | `{{OPENAPI_LINT_CMD}}` | 0 lỗi |
<!-- /SLOT-CONTENT -->
