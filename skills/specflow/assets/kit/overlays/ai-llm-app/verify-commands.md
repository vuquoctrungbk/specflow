---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: ai-llm-app
---

# Overlay ai-llm-app: lệnh verify

<!-- SLOT-CONTENT: playbook.verify-commands -->
| Hạng mục | Lệnh | Điều kiện pass |
| --- | --- | --- |
| Sinh mã | `{{CODEGEN_CMD}}` | Exit code 0; chạy trước mọi lệnh khác |
| Lint | `{{LINT_CMD}}` | 0 lỗi, 0 cảnh báo |
| Typecheck | `{{TYPECHECK_CMD}}` | 0 lỗi |
| Unit test | `{{UNIT_TEST_CMD}}` | 100% pass |
| Integration test | `{{INTEGRATION_TEST_CMD}}` | 100% pass với nhà cung cấp mô hình giả lập |
| E2E test | `{{E2E_TEST_CMD}}` | 100% pass; tính năng không có giao diện hay API riêng thì ghi N/A kèm lý do |
| Đánh giá prompt | `{{EVAL_CMD}}` | Chỉ chạy trong job đánh giá của CI (cần khóa API của môi trường đánh giá), không chạy trong vòng commit của coding agent: mọi lần chạy đạt ngưỡng của Prompt Spec cho `EVAL`, `INJ`, `COST`; bắt buộc khi đổi prompt, guard, client mô hình, mô hình hoặc tham số, và chạy theo lịch |
| Coverage | `{{COVERAGE_CMD}}` | ≥ ngưỡng của NFR-MAINT |
| Build | `{{BUILD_CMD}}` | Exit code 0 |
| Dependency audit | `{{AUDIT_CMD}}` | Không còn lỗ hổng high hoặc critical chưa có ADR chấp nhận rủi ro |
<!-- /SLOT-CONTENT -->
