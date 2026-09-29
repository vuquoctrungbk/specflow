---
doc_type: gap-analysis
status: draft
version: 0.1.0
template_version: 1.0.0
language: vi-en
parent: [docs/srs/SRS.md, docs/brownfield/CODEBASE_SUMMARY.md, docs/brownfield/AS_IS_ARCHITECTURE.md, docs/brownfield/REGRESSION_BASELINE.md]
overlays: []
assembled_from: []
---

# Phân tích khoảng cách (Gap Analysis): {{PROJECT_NAME}}

<!-- fill: Chép thành docs/brownfield/GAP_ANALYSIS.md ở bước 0d, sau khi SRS to-be đã viết (brownfield/PLAYBOOK_BROWNFIELD.md). SRS modular thì parent thay docs/srs/SRS.md bằng docs/srs/00_SRS_MASTER.md và các SRS module. SRS to-be mô tả toàn bộ hệ thống đích, kể cả phần giữ nguyên, nên mọi FR và NFR của SRS to-be có một hàng ở §2 hoặc §3. Mỗi hàng so một yêu cầu to-be với hiện trạng có bằng chứng; kết luận của tài liệu là danh sách việc cần làm ở §6 cho Architecture to-be và Migration Plan. Sau Gate 1, tài liệu chỉ đổi qua quy trình thay đổi ở PLAYBOOK mục 8. Frontmatter assembled_from ghi "brownfield/03_Gap_Analysis_Template.md@<template_version>". -->

## 1. Phạm vi so sánh (Comparison Scope)

### 1.1. Nguồn so sánh (Sources)

| Hạng mục | Giá trị |
| --- | --- |
| SRS to-be | <!-- fill: đường dẫn và version --> |
| Hiện trạng | <!-- fill: Codebase Summary, As-Is Architecture và Regression Baseline, version của từng tài liệu và commit đo --> |

### 1.2. Ánh xạ phân hệ (Module Mapping)

<!-- fill: Mỗi mã phân hệ ở Codebase Summary §3 và mỗi phân hệ ở SRS to-be §1.2 có mặt ít nhất một lần. Phân hệ giữ nguyên dùng lại đúng mã as-is; phân hệ mới có mã mới; phân hệ tách hoặc gộp ghi một hàng cho mỗi cặp mã. Test REG giữ mã as-is trong TC ID, không đánh số lại; cột cuối cho biết test REG của mã as-is nay thuộc phân hệ to-be nào. -->

| Mã as-is (Codebase Summary §3) | Mã to-be (SRS §1.2) | Quan hệ | Test REG thuộc phân hệ to-be |
| --- | --- | --- | --- |
| `{{MODULE_CODE}}` | `{{MODULE_CODE}}` | <!-- fill: chọn một: giữ nguyên \| tách \| gộp \| mới \| bỏ --> | <!-- fill: mã to-be, hoặc N/A khi không có test REG --> |

## 2. Yêu cầu chức năng (Functional Gaps)

| FR ID | Hiện trạng | Bằng chứng | Việc cần làm | Rủi ro | RB bị ảnh hưởng |
| --- | --- | --- | --- | --- | --- |
| FR-{{MODULE_CODE}}-001 | <!-- fill: chọn một: Có \| Một phần \| Không --> | <!-- fill: file:dòng hoặc RB ID --> | <!-- fill: chọn một: Giữ nguyên \| Sửa \| Viết mới \| Bỏ; kèm mô tả ngắn --> | <!-- fill --> | <!-- fill: RB ID, hoặc Không có --> |

## 3. Yêu cầu phi chức năng (Non-functional Gaps)

| NFR ID | Ngưỡng to-be | Đo hiện tại | Cách đo | Khoảng cách | Việc cần làm |
| --- | --- | --- | --- | --- | --- |
| NFR-PERF-01 | <!-- fill: lấy từ SRS §7 --> | <!-- fill: số đo thật, hoặc Chưa đo --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. Dữ liệu (Data Gaps)

| Thực thể to-be (SRS §4) | Hiện trạng (As-Is Architecture §5) | Khác biệt | Cần di chuyển dữ liệu |
| --- | --- | --- | :---: |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: bảng, cột, kiểu, ràng buộc khác nhau --> | <!-- fill: chọn một: Có \| Không --> |

## 5. Hành vi hiện có sẽ thay đổi (Behavior Changes)

<!-- fill: Mỗi RB mà SRS to-be đổi hoặc bỏ một hàng. Hàng ở đây cần chủ dự án duyệt ở Gate 1; RB không có mặt ở bảng này MUST giữ nguyên. Sau khi Gate 1 duyệt, bước đầu của Giai đoạn 2 ghi trạng thái Đổi đã duyệt hoặc Bỏ đã duyệt cho các RB này ở Regression Baseline §3. RB bị đổi mà SRS to-be không nêu lý do: ghi câu hỏi BLOCKING ở §8. -->

| RB ID | Loại | Hành vi hiện tại | Hành vi to-be | Lý do | Người dùng hay hệ thống bị ảnh hưởng |
| --- | --- | --- | --- | --- | --- |
| RB-001 | <!-- fill: chọn một: Đổi \| Bỏ --> | <!-- fill --> | <!-- fill: hoặc Không còn --> | <!-- fill: FR, NFR hoặc BR liên quan --> | <!-- fill --> |

## 6. Tổng hợp ưu tiên (Prioritized Summary)

| # | Việc cần làm | Nguồn (FR, NFR, dữ liệu, RB) | Ưu tiên | Phụ thuộc |
| --- | --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: P1 \| P2 \| P3 --> | <!-- fill --> |

## 7. Phạm vi tối thiểu cho repo nhỏ (Minimal Scope)

<!-- fill: Repo dưới 5.000 dòng mã (Codebase Summary §1) được phép: §3 chỉ gồm NFR có ngưỡng khác hiện trạng; §4 ghi N/A kèm lý do khi schema không đổi. §1, §2, §5, §6 luôn đầy đủ. Ghi quyết định vào bảng; repo lớn hơn ghi Không. -->

| Áp dụng phạm vi tối thiểu | Căn cứ |
| --- | --- |
| <!-- fill: chọn một: Có \| Không --> | <!-- fill: số dòng mã ở Codebase Summary §1 --> |

## 8. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## 9. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline brownfield | Chưa duyệt |
