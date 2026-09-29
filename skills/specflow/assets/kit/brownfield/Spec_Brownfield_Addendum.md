---
doc_type: spec-addendum
status: stable
version: 1.1.0
language: vi-en
---

# Phụ lục SPEC cho dự án brownfield (Spec Brownfield Addendum)

Dùng cùng Spec của giai đoạn ([core/04](../core/04_Spec_Core_Template.md) hoặc file SPEC của starter) khi Intake có `mode: brownfield`. Phụ lục không thay template SPEC; nó thêm ba phần vào SPEC để mọi thay đổi trên mã đang chạy đối chiếu được với file hiện hữu và giữ hành vi ở [Regression Baseline](02_Regression_Baseline_Template.md). Agent chép từng khối dưới đây vào đúng vị trí trong SPEC, rồi điền như mọi khối khác.

## 1. Thay bảng File sửa ở SPEC §2.1

Bảng §2.1 của SPEC brownfield có thêm hai cột. Đọc mã hiện có trước khi điền; mỗi hàng ghi đúng hàm hoặc lớp bị đổi.

```markdown
| Đường dẫn | Hiện trạng file | Hàm hoặc lớp bị ảnh hưởng | Thay đổi |
| --- | --- | --- | --- |
| <!-- fill: đường dẫn trong inline code --> | <!-- fill: số dòng hiện tại, có test hay không --> | <!-- fill: tên hàm, lớp, route; kèm file:dòng --> | <!-- fill --> |
```

## 2. Thêm vào cuối SPEC §9

Khối dưới đứng sau mọi mục con khác của §9, kể cả mục do overlay cung cấp.

```markdown
### 9.2. Hành vi phải giữ (Regression Behaviors)

<!-- fill: Mỗi RB ở cột RB phải pass của bước tương ứng trong docs/brownfield/MIGRATION_PLAN.md §2 và mỗi RB có bằng chứng nằm trong file ở §2.1 một hàng. RB trạng thái Giữ: test pass trước và sau khi đổi mã, không sửa test. RB trạng thái Đổi đã duyệt: test cũ pass trước khi đổi; file test nằm trong §2, test được cập nhật theo hành vi mới và có hàng ở §9.1 gắn AC mới; cột cuối ghi hành vi mới và TC ID của test đã cập nhật. RB trạng thái Bỏ đã duyệt: test cũ pass trước khi đổi, file hoặc hàm test bị xóa trong §2, cột Pass sau khi đổi ghi N/A. RB chỉ có thủ tục thủ công: thêm test REG mới vào §2 và vào bảng này, dùng mã phân hệ as-is của hành vi được bảo vệ theo docs/brownfield/GAP_ANALYSIS.md §1.2 và số tiếp theo sau số lớn nhất của cặp mã phân hệ và REG ở SRS §8, docs/brownfield/REGRESSION_BASELINE.md §6.1 và các SPEC (CONVENTIONS mục 4). -->

| TC ID | RB ID | File test | Tên test | Pass trước khi đổi | Pass sau khi đổi | Hành vi sau thay đổi |
| --- | --- | --- | --- | :---: | :---: | --- |
| TC-{{MODULE_CODE}}-REG-01 | RB-001 | <!-- fill --> | <!-- fill: tên test mô tả hành vi --> | [ ] | [ ] | <!-- fill: Không đổi, hành vi mới kèm TC ID ở §9.1, hoặc Bỏ --> |
```

## 3. Thêm vào Definition of Done ở SPEC §12

```markdown
- [ ] Mọi test ở §9.2 pass trên mã hiện tại trước khi đổi mã; sau khi đổi, test của RB Giữ và test đã cập nhật của RB Đổi đã duyệt pass, test của RB Bỏ đã duyệt đã xóa.
- [ ] Không thay đổi hành vi nào ngoài RB đã được duyệt đổi ở `docs/brownfield/GAP_ANALYSIS.md` §5; contract bên ngoài khớp ảnh chụp ở `docs/brownfield/REGRESSION_BASELINE.md` §5, trừ khác biệt đã duyệt.
- [ ] Mốc kiểm tra hồi quy của bước ở `docs/brownfield/MIGRATION_PLAN.md` §6 đạt.
- [ ] Không refactor ngoài File Diff, kể cả khi thấy mã cần cải thiện; đề xuất ghi vào mục Giả định và câu hỏi mở.
```

## 4. Quy tắc khi viết và thực thi SPEC brownfield

- Frontmatter SPEC thêm `docs/brownfield/MIGRATION_PLAN.md` và `docs/brownfield/REGRESSION_BASELINE.md` vào `parent`, và thêm đường dẫn phụ lục này kèm `version` ở frontmatter của nó vào `assembled_from` (CONVENTIONS mục 3).
- File Diff chỉ gồm file thuộc mã phân hệ của bước tương ứng ở Migration Plan §2 (đường dẫn theo ARCHITECTURE §4.1), cộng file test của RB Đổi đã duyệt, RB Bỏ đã duyệt và test REG mới ở §9.2; test của RB Giữ chỉ được chạy, không nằm trong File Diff.
- TC của RB Bỏ đã duyệt có cột Pass sau khi đổi là N/A và không tính vào tiêu chí "mọi TC ở §9 pass" của PLAYBOOK mục 10.2 và Prompt 5.
- Test mới cho hành vi hiện có dùng TYPE `REG` (CONVENTIONS mục 4); test cho hành vi mới dùng TYPE như dự án greenfield. Như ở Regression Baseline §6.1, mọi test bảo vệ một RB ở §9.2 mang loại `REG`, kể cả test đã có; một test tham số hóa là một TC; TC dùng mã phân hệ của hành vi được bảo vệ (`brownfield/PLAYBOOK_BROWNFIELD.md` mục 5.3).
- Thứ tự thực thi: chạy test ở §9.2 trên mã hiện tại và ghi kết quả vào cột Pass trước khi đổi; test ở §9.2 phải xanh ngay, không theo bước đỏ. Sau đó mới viết test ở §9.1, chạy thấy đỏ, rồi viết logic như quy trình ở SPEC §12. Pha đầu tiên của Implementation Plan ghi bước chạy này.
- Sync Docs của SPEC cập nhật Regression Baseline §3 (hàng của RB được đổi hoặc bỏ, cột Bảo vệ bởi của RB có test REG mới), §6.1 (hàng cho test REG mới) và cột Trạng thái của bước ở Migration Plan §2.
