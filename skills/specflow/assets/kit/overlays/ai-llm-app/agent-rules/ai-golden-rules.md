---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.0.0
language: vi-en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [ai-llm-app]
assembled_from: []
---

# Quy tắc tính năng AI (AI Golden Rules)

<!-- fill: Chép thành .claude/rules/ai-golden-rules.md ở Giai đoạn 2. paths liệt kê thư mục prompt, client mô hình, guard, mọi thư mục test (unit, integration, đánh giá, giả lập) và bộ dữ liệu theo ARCHITECTURE §4, mỗi glob một phần tử. assembled_from ghi "overlays/ai-llm-app/agent-rules/ai-golden-rules.md@<template_version>" và stack profile đã dùng. -->

- Chỉ client mô hình gọi SDK của nhà cung cấp; MUST NOT gọi mô hình từ nơi khác trong mã.
- Mỗi prompt là một module chép đúng Prompt Spec đã duyệt, hằng phiên bản trùng `version` của Prompt Spec. MUST NOT đổi prompt, ví dụ mẫu, schema đầu ra, mô hình hay tham số khác Prompt Spec; cần đổi thì dừng và đề xuất sửa Prompt Spec theo PLAYBOOK mục 8.
- Đầu ra của mô hình luôn qua schema và quy tắc nghiệp vụ trước khi dùng; MUST NOT tách JSON từ văn bản tự do hay sửa đoán đầu ra sai.
- Nội dung không tin cậy chỉ nằm trong cặp thẻ phân cách mà prompt hệ thống khai báo là dữ liệu; guard đầu vào thay dấu ngoặc nhọn trong nội dung để nó không thể mở hay đóng thẻ phân cách. MUST NOT ghép nội dung không tin cậy vào phần chỉ dẫn.
- Che dữ liệu cá nhân trước khi gửi tới nhà cung cấp theo SRS §2.5; MUST NOT đưa secret vào prompt, log hay thông báo lỗi.
- Dùng đúng ID mô hình và tham số ở ARCHITECTURE §2.1 và Prompt Spec; đổi mô hình cần ADR.
- Bộ dữ liệu đánh giá chỉ chứa mẫu tổng hợp hoặc đã ẩn danh không đảo ngược; MUST NOT sửa nhãn mong đợi để test đánh giá đạt.
- Test unit và integration không gọi mô hình thật; mô hình thật chỉ chạy trong project đánh giá.
- {{LANGUAGE_STRICT_MODE_RULE}}
