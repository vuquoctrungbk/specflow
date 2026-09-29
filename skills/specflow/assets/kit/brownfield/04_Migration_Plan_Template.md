---
doc_type: migration-plan
status: draft
version: 0.1.0
template_version: 1.0.0
language: vi-en
parent: [docs/ARCHITECTURE.md, docs/brownfield/GAP_ANALYSIS.md, docs/brownfield/REGRESSION_BASELINE.md]
overlays: []
assembled_from: []
---

# Kế hoạch chuyển đổi (Migration Plan): {{PROJECT_NAME}}

<!-- fill: Chép thành docs/brownfield/MIGRATION_PLAN.md ở bước 0e, cùng Giai đoạn 2 (brownfield/PLAYBOOK_BROWNFIELD.md). Kế hoạch đưa hệ thống từ hiện trạng tới ARCHITECTURE to-be qua các bước nhỏ; mỗi bước chạy lại toàn bộ test REG và test bảo vệ, giữ mọi RB chưa được duyệt đổi ở Gap Analysis §5. Mỗi bước thành một hoặc vài SPEC ở Giai đoạn 3. Tài liệu được cập nhật suốt quá trình chuyển đổi: bước Sync Docs của mỗi SPEC cập nhật cột Trạng thái ở §2. Frontmatter assembled_from ghi "brownfield/04_Migration_Plan_Template.md@<template_version>". -->

## 1. Chiến lược (Strategy)

| Hạng mục | Quyết định |
| --- | --- |
| Chiến lược chuyển đổi | <!-- fill: chọn một, có ADR: strangler fig (thay dần từng phần sau một lớp định tuyến) \| big-bang (thay toàn bộ một lần) \| chạy song song (hệ cũ và mới cùng chạy, so kết quả); nêu lý do --> |
| ADR | <!-- fill: ADR ID; ADR MUST accepted trước Gate 2 --> |
| Điều kiện hoàn tất | <!-- fill: hệ cũ tắt được khi nào, đo bằng gì --> |

## 2. Các bước theo thứ tự (Ordered Steps)

<!-- fill: Cột RB phải pass gồm mọi RB có bằng chứng nằm trong phạm vi của bước (Regression Baseline §3) và mọi RB mà bước đổi hoặc bỏ theo Gap Analysis §5. SPEC của bước chép danh sách này vào §9.2 theo brownfield/Spec_Brownfield_Addendum.md. -->

| Bước | Mã phân hệ | Việc làm (Gap Analysis §6) | Điều kiện bắt đầu | Điều kiện xong | RB phải pass | SPEC dự kiến | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `{{MODULE_CODE}}` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: RB ID --> | SPEC-{{MODULE_CODE}}-001 | <!-- fill: chọn một: chưa làm \| đang làm \| xong --> |

## 3. Công tắc ngắt và cờ tính năng (Kill Switch & Feature Flags)

| Bước | Cơ chế chuyển về hệ cũ | Ai được bật tắt | Thời gian có hiệu lực |
| --- | --- | --- | --- |
| 1 | <!-- fill: cờ tính năng, định tuyến, cấu hình --> | <!-- fill --> | <!-- fill --> |

## 4. Quay lui theo bước (Rollback per Step)

| Bước | Cách quay lui | Dữ liệu có mất không | Thời gian dự kiến |
| --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 5. Di chuyển dữ liệu (Data Migration)

<!-- fill: Ghi N/A kèm lý do nếu Gap Analysis §4 không có thực thể cần di chuyển. Chạy thử trên bản sao không phải production dùng dữ liệu tổng hợp hoặc đã ẩn danh không đảo ngược trước khi chạy thật. -->

| Dữ liệu | Nguồn | Đích | Cách chuyển | Đối soát sau chuyển | Chạy lại an toàn |
| --- | --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: migration, script, đồng bộ hai chiều --> | <!-- fill: số bản ghi, tổng kiểm tra --> | <!-- fill: chọn một: Có \| Không --> |

## 6. Mốc kiểm tra hồi quy (Regression Checkpoints)

- Trước và sau mỗi bước ở §2: chạy toàn bộ test bảo vệ ở Regression Baseline §6.1; mọi RB chưa được đổi hoặc bỏ ở bước này hay bước trước MUST pass, kể cả RB đã duyệt đổi nhưng thuộc bước sau. RB chỉ có thủ tục thủ công chạy theo Regression Baseline §6.2.
- So contract bên ngoài với ảnh chụp ở Regression Baseline §5; khác biệt ngoài Gap Analysis §5 là lỗi.

| Bước | Lệnh kiểm tra | Người xác nhận |
| --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> |

## 7. Giao tiếp và cửa sổ bảo trì (Communication & Maintenance Windows)

| Bước | Ai cần biết | Thời điểm thông báo | Cửa sổ bảo trì |
| --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill: hoặc Không cần --> |

## 8. Phạm vi tối thiểu cho repo nhỏ (Minimal Scope)

<!-- fill: Repo dưới 5.000 dòng mã (Codebase Summary §1) được phép: §2 chỉ một bước; §3 và §7 ghi N/A kèm lý do khi thay đổi phát hành một lần ngoài giờ sử dụng. §1, §4, §6 luôn đầy đủ. Ghi quyết định vào bảng; repo lớn hơn ghi Không. -->

| Áp dụng phạm vi tối thiểu | Căn cứ |
| --- | --- |
| <!-- fill: chọn một: Có \| Không --> | <!-- fill: số dòng mã ở Codebase Summary §1 --> |

## 9. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## 10. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline brownfield | Chưa duyệt |
