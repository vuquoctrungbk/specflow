---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.0.0
language: vi-en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [backend-api]
assembled_from: []
---

# Quy tắc backend (Backend Golden Rules)

<!-- fill: Chép thành .claude/rules/backend-golden-rules.md ở Giai đoạn 2. paths liệt kê thư mục mã nguồn backend theo ARCHITECTURE §4, mỗi glob một phần tử. assembled_from ghi "overlays/backend-api/agent-rules/backend-golden-rules.md@<template_version>" và stack profile đã dùng. -->

- Tách tầng: controller chỉ nhận request, validate bằng schema runtime, gọi service và map response; MUST NOT import ORM client hay repository vào controller.
- Transaction mở ở service; repository nhận transaction client từ service, không tự mở transaction.
- Bất biến chịu thao tác đồng thời giữ ở cơ sở dữ liệu bằng cập nhật nguyên tử có điều kiện, ràng buộc duy nhất, hoặc khóa lấy trong transaction trước bước kiểm tra; MUST NOT kiểm tra rồi ghi ở tầng ứng dụng khi chưa giữ khóa đó.
- Mọi phản hồi theo envelope ARCHITECTURE §6.2; mọi lỗi mang mã có trong ARCHITECTURE §7.1 và HTTP status theo bảng ánh xạ ở ARCHITECTURE §7.
- {{LANGUAGE_STRICT_MODE_RULE}}
- Không tin giá trị tính toán từ client (giá, số tiền, quyền, trạng thái); service tính lại từ cơ sở dữ liệu.
- Migration chỉ sinh bằng công cụ của stack; không sửa migration đã chạy; mọi thay đổi schema đi kèm migration trong File Diff.
- Log qua logger có cấu trúc với correlation ID; không log secret, token, mật khẩu, dữ liệu cá nhân chưa che.
