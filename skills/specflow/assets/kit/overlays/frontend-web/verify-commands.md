---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: frontend-web
---

# Overlay frontend-web: lệnh verify

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Hạng mục | Lệnh | Điều kiện pass |
| --- | --- | --- |
| Sinh mã | `{{CODEGEN_CMD}}` | Exit code 0; chạy trước mọi lệnh khác |
| Lint | `{{LINT_CMD}}` | 0 lỗi, 0 cảnh báo |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 lỗi |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass với API giả lập khớp OpenAPI |
| E2E, trợ năng và visual | `{{E2E_TEST_CMD}}` | 100% pass, 0 vi phạm trợ năng ở mức WCAG của NFR-USAB, ảnh chụp khớp ảnh gốc |
| Coverage | `{{COVERAGE_CMD}}` | ≥ ngưỡng của NFR-MAINT |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | Không còn lỗ hổng high hoặc critical chưa có ADR chấp nhận rủi ro |
<!-- /SLOT-CONTENT -->
