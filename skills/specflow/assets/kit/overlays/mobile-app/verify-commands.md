---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: mobile-app
---

# Overlay mobile-app: lệnh verify

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Hạng mục | Lệnh | Điều kiện pass |
| --- | --- | --- |
| Sinh mã | `{{CODEGEN_CMD}}` | Exit code 0; chạy trước mọi lệnh khác |
| Lint | `{{LINT_CMD}}` | 0 lỗi, 0 cảnh báo |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 lỗi |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass trên cơ sở dữ liệu cục bộ thật với API giả lập khớp OpenAPI |
| E2E test | `{{E2E_TEST_CMD}}` | Chỉ chạy trong CI: 100% pass trên máy ảo iOS và Android; coding agent không chạy lệnh này trước commit |
| Coverage | `{{COVERAGE_CMD}}` | ≥ ngưỡng của NFR-MAINT |
| Kiểm tra nền tảng | `{{PLATFORM_CHECK_CMD}}` | 0 vấn đề về cấu hình và độ tương thích phiên bản của SDK |
| Build | `{{BUILD_CMD}}` | Exit code 0 cho cả iOS và Android |
| Dependency audit | `{{AUDIT_CMD}}` | Không còn lỗ hổng high hoặc critical chưa có ADR chấp nhận rủi ro |
<!-- /SLOT-CONTENT -->
