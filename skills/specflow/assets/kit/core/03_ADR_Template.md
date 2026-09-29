---
doc_type: adr
status: proposed
version: 0.1.0
template_version: 1.0.1
language: vi-en
adr_id: "ADR-{{ADR_NUMBER}}"
date: "{{DATE}}"
deciders: []
parent: [docs/ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# ADR-{{ADR_NUMBER}}: {{ADR_TITLE}}

<!-- fill: Chép thành docs/adr/NNNN-<slug>.md, NNNN tăng dần, slug kebab-case tiếng Anh. Theo MADR 4.0.0 có điều chỉnh: giữ khóa deciders (MADR 4.0.0 gọi là decision-makers) và bố cục mục gọn hơn. Status: proposed khi chờ duyệt; accepted khi được duyệt; rejected khi người duyệt không chấp nhận, giữ file để ghi lại phương án đã loại; deprecated hoặc superseded khi không còn hiệu lực. Một ADR có thể gom nhiều lựa chọn cùng chủ đề (PLAYBOOK mục 2.3). ADR đã accepted không sửa nội dung quyết định; khi đổi quyết định, tạo ADR mới, đặt ADR này status superseded và thêm khóa superseded_by vào frontmatter. Ghi deciders là danh sách người quyết định; assembled_from ghi "core/03_ADR_Template.md@<template_version>". Thêm ADR vào ARCHITECTURE §12. -->

## 1. Bối cảnh và vấn đề (Context and Problem Statement)

<!-- fill: tình huống buộc phải quyết định, ràng buộc liên quan, câu hỏi cần trả lời. Viết để người đọc sau một năm vẫn hiểu vì sao phải chọn. -->

## 2. Yếu tố quyết định (Decision Drivers)

<!-- fill: mỗi dòng một yếu tố, gắn ID nếu có (NFR, FR, BR, ràng buộc ở Intake mục 6). -->

## 3. Phương án đã xét (Considered Options)

<!-- fill: tối thiểu hai phương án, trong đó có phương án đơn giản nhất hoặc không làm gì. Mỗi phương án một hàng. -->

| Phương án | Mô tả | Ưu điểm | Nhược điểm |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. Quyết định (Decision Outcome)

- Phương án được chọn: <!-- fill -->
- Lý do: <!-- fill: đối chiếu với từng yếu tố ở mục 2 -->
- Lựa chọn bắt buộc được ADR này bao phủ: <!-- fill: placeholder buộc chọn trong ARCHITECTURE và giá trị đã chọn, ví dụ phương thức ký token; ghi "Không có" nếu không có -->

## 5. Hệ quả (Consequences)

| Loại | Hệ quả |
| --- | --- |
| Tốt | <!-- fill --> |
| Xấu hoặc chi phí chấp nhận | <!-- fill --> |
| Việc phải làm tiếp | <!-- fill: tài liệu, SPEC, cấu hình cần cập nhật; ghi "Không có" nếu không có --> |

## 6. Kiểm chứng tuân thủ (Confirmation)

<!-- fill: cách phát hiện khi code đi ngược quyết định: test cụ thể (TC ID), rule của linter, kiểm tra trong CI, điểm kiểm trong review. -->

## 7. Liên kết (Links)

| Loại | Tham chiếu |
| --- | --- |
| Yêu cầu | <!-- fill: FR, NFR, BR ID --> |
| Mục kiến trúc | <!-- fill: mục trong ARCHITECTURE --> |
| SPEC liên quan | <!-- fill: SPEC ID hoặc "Không có" --> |
| Thay thế ADR | <!-- fill: ADR ID bị ADR này thay thế, hoặc "Không có" --> |

## 8. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |
