---
title: "{{PROJECT_NAME}} đợt {{RELEASE}}: Implementation Plan"
description: "Triển khai mọi SPEC của đợt {{RELEASE}} theo TDD"
status: pending
priority: "{{PRIORITY}}"
effort: "{{EFFORT}}"
tags: []
created: "{{DATE}}"
doc_type: implementation-plan
version: 0.1.0
template_version: 1.3.0
language: vi-en
release: "{{RELEASE}}"
spec_ids: ["{{SPEC_ID}}"]
parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}} đợt {{RELEASE}}: Implementation Plan

<!-- fill: Một plan cho mọi SPEC của một đợt phát hành (PLAYBOOK mục 2.5). Chép cả thư mục thành plans/{YYMMDD-HHmm}-release-<release-slug>/ theo định dạng ở CONVENTIONS mục 9 (không cần công cụ riêng), <release-slug> là nhãn đợt viết kebab-case, ví dụ {{RELEASE_SLUG}}. release là nhãn đợt ở cột Bản phát hành của SRS §6.1; spec_ids liệt kê mọi SPEC approved của đợt, mỗi SPEC có file trong docs/specs/ và mọi FR ở SPEC §1.5 có Bản phát hành bằng release; SPEC có khóa release thì khóa đó bằng release của plan (CONVENTIONS mục 9); plan.md không có khóa spec_id. parent liệt kê file SPEC của mọi phần tử spec_ids. Mỗi pha một file phase-NN-<slug>.md chép từ phase-01-example-phase.md, NN liên tục từ 01; spec_id của pha là một phần tử của spec_ids, một pha chỉ thuộc một SPEC, pha của cùng một SPEC đứng liền nhau, SPEC cung cấp contract đứng trước SPEC tiêu thụ contract đó, và ở mỗi bề mặt pha của SPEC mang nền tảng dùng chung của bề mặt đó (khung dự án, cấu hình, thư viện dùng chung, hạ tầng test; PLAYBOOK mục 2.4) đứng trước pha của SPEC khác cùng bề mặt. Bảng Phases có đúng một dòng cho mỗi file pha, cột Status khớp status của pha. Các pha phủ mọi SPEC của đợt và File Diff của từng SPEC: mỗi SPEC trong spec_ids có ít nhất một pha, và các pha có spec_id của một SPEC cộng lại MUST phủ hết File Diff và mọi TC ở §9 của SPEC đó. Frontmatter assembled_from của plan và của từng pha ghi "core/05_Implementation_Plan_Template/<file>@<template_version>". Status: plan pending, in-progress hoặc completed (completed khi mọi SPEC trong spec_ids đã implemented); pha todo, in-progress hoặc done. Dự án có Intake cũ hơn 1.3.0 lập plan cho một SPEC theo COMPATIBILITY.md mục 3. -->

## Tổng quan (Overview)

- Đợt phát hành: `{{RELEASE}}`; SPEC của đợt ở bảng dưới, cùng tập với `spec_ids`.
- Cách tiếp cận: <!-- fill: 2 đến 3 câu tóm tắt thứ tự thực hiện các SPEC và lý do, ví dụ SPEC của API trước SPEC của giao diện dùng API đó -->
- Lệnh verify: theo mục lệnh verify trong `CLAUDE.md`.

## SPEC của đợt (Release SPECs)

<!-- fill: Một hàng cho mỗi phần tử của spec_ids, theo thứ tự thực hiện. Cột Pha ghi số các pha có spec_id của SPEC đó, liền nhau, ví dụ 1 đến 3. Các pha phủ mọi SPEC của đợt và File Diff của từng SPEC. -->

| SPEC ID | File | Tính năng | Bề mặt | Pha |
|---------|------|-----------|--------|-----|
| {{SPEC_ID}} | `docs/specs/SPEC_{{FEATURE_KEY}}.md` | {{FEATURE_NAME}} | <!-- fill: overlay của SPEC --> | <!-- fill --> |

## Mục tiêu (Goals)

| # | Mục tiêu | Ưu tiên |
|---|----------|---------|
| 1 | <!-- fill: mục tiêu đo được, gắn AC hoặc INV của một SPEC của đợt --> | {{PRIORITY}} |

## Các pha (Phases)

| # | Phase | Status |
|---|-------|--------|
| 1 | [{{PHASE_TITLE}}](./phase-01-example-phase.md) | todo |

Pha nhóm theo SPEC: pha của một SPEC đứng liền nhau, SPEC cung cấp contract đứng trước SPEC tiêu thụ contract đó. Thứ tự pha mặc định trong một SPEC (overlay có thể thay, ghi lý do nếu đổi); có Giai đoạn 1W thì pha của lớp giao tiếp (mục 3 dưới) theo thứ tự của sơ đồ điều hướng ở chỉ mục wireframe. Trong mọi pha, test của pha được viết và chạy thấy đỏ trước, rồi mới viết code tới khi xanh; pha kết thúc khi lệnh verify đạt và đã commit.

1. Migration, kiểu dữ liệu dùng chung, contract, DTO và schema validate, kèm test của chúng.
2. Logic nghiệp vụ và truy cập dữ liệu: test đơn vị và test `CONC` của SPEC §9 đỏ rồi xanh, sau đó refactor.
3. Lớp giao tiếp (controller, màn hình, command) và test tích hợp, e2e.

## Tiêu chí thành công (Success Criteria)

Bằng Definition of Done ở §12 của từng SPEC trong `spec_ids`; Giai đoạn 5 xét theo từng SPEC khi mọi pha của SPEC đó xong:

- [ ] Mọi lệnh verify trong `CLAUDE.md` đạt điều kiện pass của bảng lệnh verify (PLAYBOOK mục 11).
- [ ] 100% test ở §9 của mỗi SPEC pass, đúng file và tên ghi trong bảng.
- [ ] Mã nguồn của mỗi pha chỉ thay đổi trong File Diff của SPEC theo `spec_id` của pha; ngoài ra chỉ có tài liệu và plan được cập nhật.
- [ ] Mọi lỗi trả về theo envelope ARCHITECTURE §6.2 với mã trong §7.1 (bề mặt có request/response).
- [ ] Không có dependency mới ngoài ARCHITECTURE §2 hoặc ADR `accepted`.
- [ ] Mọi SPEC trong `spec_ids` ở status `implemented`, mọi pha ở status `done`.

## Rủi ro (Risks)

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|--------|-----------|------------|
| <!-- fill --> | <!-- fill --> | <!-- fill --> |

## Lịch sử phiên bản (Version History)

<!-- fill: Duyệt Gate 4 đặt version: 1.0.0 và thêm một hàng ghi tên người duyệt ở cột Người duyệt. Duyệt lại theo PLAYBOOK mục 8 quy tắc 7 (thêm pha vào một đợt còn dở) tăng MINOR và thêm một hàng mới, người duyệt Gate 4 duyệt lại. -->

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline | Chưa duyệt |

## Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
|----|------|----------|----------------------|:--------:|---------------|
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |
