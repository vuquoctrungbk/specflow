---
phase: 1
title: "Phase 1: {{PHASE_TITLE}}"
status: todo
priority: "{{PRIORITY}}"
effort: "{{EFFORT}}"
dependencies: []
doc_type: implementation-phase
version: 0.1.0
template_version: 1.3.0
language: vi-en
spec_id: "{{SPEC_ID}}"
parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]
overlays: []
assembled_from: []
---

# Phase 1: {{PHASE_TITLE}}

<!-- fill: Chép thành phase-NN-<slug>.md, NN tăng dần, sửa phase, title và dependencies (danh sách số pha phải xong trước). spec_id là SPEC mà pha thực hiện, một phần tử của spec_ids ở plan.md; một pha chỉ thuộc một SPEC, pha của cùng một SPEC đứng liền nhau; parent là file của SPEC đó. Một pha là một đơn vị commit được: sau pha, mọi test của pha xanh và lệnh verify đạt. -->

## Tổng quan (Overview)

- SPEC: `{{SPEC_ID}}` tại `docs/specs/SPEC_{{FEATURE_KEY}}.md`, một phần tử của `spec_ids` ở `plan.md`.
- Mục tiêu của pha: <!-- fill: 1 đến 2 câu, nêu AC hoặc INV mà pha này làm cho đạt -->

## Đọc trước (Read First)

<!-- fill: Mỗi dòng một tài liệu và các mục agent phải đọc để làm pha này, dạng `đường dẫn` §mục, §mục. Lấy số mục bằng `python3 <thư mục kit>/scripts/project-index.py . --outline <tệp>`. Giữ ba dòng dưới nếu đúng, thêm mục SPEC hay ARCHITECTURE khác mà pha cần (ví dụ §3 cho pha DTO, §5 cho pha migration), và xóa chú thích này. Tệp đi kèm chỉ ghi khi pha cần nội dung của nó -->

- `docs/specs/SPEC_{{FEATURE_KEY}}.md` §1.5, §2, §9
- `docs/ARCHITECTURE.md` §4

## Yêu cầu (Requirements)

- [ ] <!-- fill: kết quả kiểm chứng được của pha -->

## File của pha (Files)

Tập con của File Diff trong §2 của SPEC `{{SPEC_ID}}`; MUST NOT chạm file ngoài bảng này.

| Đường dẫn | Thao tác | Nội dung |
|-----------|----------|----------|
| <!-- fill: đường dẫn trong inline code --> | <!-- fill: chọn một: tạo \| sửa --> | <!-- fill --> |

## Test phải pass (Tests)

| TC ID | Loại | File test |
|-------|------|-----------|
| TC-{{MODULE_CODE}}-UNIT-01 | <!-- fill --> | <!-- fill --> |

## Các bước thực hiện (Implementation Steps)

1. Viết hoặc cập nhật test của pha theo bảng trên; chạy và xác nhận test đỏ vì đúng lý do.
2. <!-- fill: bước triển khai cụ thể, theo thứ tự -->
3. Chạy test tới khi xanh, refactor khi test vẫn xanh.
4. Chạy lệnh verify trong `CLAUDE.md`.
5. Commit theo quy ước ở mục dưới.

## Việc cần làm (Todo)

- [ ] Test của pha viết xong và đỏ đúng lý do
- [ ] <!-- fill: việc triển khai -->
- [ ] Test của pha xanh, lệnh verify đạt
- [ ] Commit

## Kiểm chứng (Verification)

<!-- fill: liệt kê lệnh verify áp dụng cho pha (lấy từ CLAUDE.md) và kết quả mong đợi, ví dụ số test pass, exit code 0. -->

## Commit

Conventional Commits bằng tiếng Anh, một commit cho pha, dạng `type(scope): summary` với type là `feat`, `fix`, `test`, `refactor`, `build` (migration, dependency, cấu hình build) hoặc `chore` (thay đổi khác không chạm hành vi). Message mô tả hành vi thay đổi, không chứa ID quy trình (SPEC, TC, số pha) và không chứa secret.

## Tiêu chí thành công (Success Criteria)

- [ ] Mọi TC ở mục Test phải pass đều xanh.
- [ ] Không file nào ngoài mục File của pha bị sửa.

## Quay lui (Rollback)

<!-- fill: cách hoàn tác pha nếu pha sau phát hiện lỗi thiết kế: revert commit, migration đảo ngược, dữ liệu cần dọn. -->

## Rủi ro (Risk Assessment)

<!-- fill: rủi ro riêng của pha và cách giảm thiểu; ghi "Không có rủi ro đáng kể" nếu đúng. -->
