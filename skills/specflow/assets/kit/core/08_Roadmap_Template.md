---
doc_type: roadmap
status: active
version: 0.1.0
template_version: 1.0.0
language: vi-en
parent: [docs/srs/SRS.md]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}}: Roadmap

<!-- fill: Chép thành docs/ROADMAP.md khi nhận "Duyệt Gate 1" (PLAYBOOK mục 2.7), cho dự án có Intake tạo từ template Intake 1.4.0 trở lên. Roadmap là danh sách việc phải làm dẫn xuất từ SRS: lệch thì SRS thắng. Quy tắc của từng mục, trạng thái dòng (Chưa làm, Đang làm, Xong, Đã xác nhận, Bỏ), thứ tự và bằng chứng ở CONVENTIONS mục 11; chú thích dưới chỉ nêu cách điền. Coding agent cập nhật roadmap theo PLAYBOOK mục 2.5, đối soát theo mục 2.6, và chỉ đặt Đã xác nhận khi nhận "Duyệt Gate 5". Frontmatter: parent liệt kê file SRS; overlays chép từ Intake; assembled_from ghi "core/08_Roadmap_Template.md@<template_version>". Roadmap không qua gate riêng và không có Version History: lịch sử của nó là git. -->

## 1. Tiến độ (Progress)

<!-- fill: Một hàng cho mỗi đợt, theo thứ tự đợt ở Intake (mục Mốc thời gian). Số đếm và dòng Đang làm theo CONVENTIONS mục 11. -->

| Đợt | Tổng | Xong | Đã xác nhận | Hoàn thành |
| --- | --- | --- | --- | --- |
| {{RELEASE}} | <!-- fill --> | 0 | 0 | 0% |

- Đang làm: Không

## 2. Hàng việc (Work Queue)

### 2.1. Yêu cầu chức năng (Functional Requirements)

<!-- fill: Một dòng cho mỗi FR ở SRS §6.1 có Ưu tiên khác Won't; Tên, Ưu tiên, Đợt chép từ SRS §6.1. SPEC ghi Chưa có trước Gate 3, Pha ghi Chưa có trước Gate 4; định dạng hai cột này và thứ tự dòng theo CONVENTIONS mục 11. -->

| # | ID | Tên | Ưu tiên | Đợt | SPEC | Pha | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | FR-{{MODULE_CODE}}-001 | <!-- fill: tên ngắn ở SRS §6.1 --> | Must | {{RELEASE}} | Chưa có | Chưa có | Chưa làm |

### 2.2. Yêu cầu phi chức năng mức Must (Must NFRs)

<!-- fill: Một dòng cho mỗi NFR ở SRS §7 có Ưu tiên Must, theo thứ tự ở SRS §7; Tên chép cột Nhóm, Cách kiểm chứng chép SRS §7. SPEC liệt kê các SPEC dẫn NFR hoặc ghi Không có. Đợt đóng và cách xác nhận theo CONVENTIONS mục 11 và PLAYBOOK mục 2.7. -->

| # | ID | Tên | SPEC | Cách kiểm chứng | Đợt đóng | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | NFR-SEC-01 | <!-- fill: cột Nhóm ở SRS §7 --> | Không có | Test | {{RELEASE}} | Chưa làm |

## 3. Yêu cầu mới (New Requests)

<!-- fill: Ý tưởng hoặc yêu cầu phát sinh sau Gate 1. Agent chỉ ghi, không làm. Người duyệt của gate gần nhất quyết: Đưa vào change request (ghi tài liệu bị đổi, rồi đi theo PLAYBOOK mục 8) hoặc Bỏ (kèm lý do); chưa quyết thì Chờ. Không có yêu cầu thì giữ một hàng Không có. -->

| Ngày | Nội dung | Người nêu | Quyết định |
| --- | --- | --- | --- |
| Không có | Không có | Không có | Không có |

## 4. Đã hoàn thành (Done)

<!-- fill: Một hàng cho mỗi dòng Xong hoặc Đã xác nhận ở mục 2: bằng chứng (ID TC, hoặc bằng chứng theo SRS §8 với NFR), commit, tag (Chưa có tới khi Đã xác nhận), theo CONVENTIONS mục 11. Chưa có dòng nào xong thì giữ một hàng Không có. -->

| ID | Bằng chứng | Commit | Tag |
| --- | --- | --- | --- |
| Không có | Không có | Không có | Không có |

## 5. Mốc version (Milestones)

<!-- fill: Một hàng cho mỗi lần một SPEC qua Gate 5, theo thứ tự duyệt; tên tag theo dòng Định dạng tag ở Intake mục 14, lần thứ hai trở đi của cùng SPEC thêm hậu tố -2, -3 (PLAYBOOK mục 2.7). Rollback: revert khoảng commit của SPEC (PLAYBOOK mục 2.6) về tag trước; pha có migration theo mục hoàn tác của pha. Chưa có mốc thì giữ một hàng Không có. -->

| Tag | SPEC | Commit | Ngày | Người duyệt | Cách rollback |
| --- | --- | --- | --- | --- | --- |
| Không có | Không có | Không có | Không có | Không có | Không có |
