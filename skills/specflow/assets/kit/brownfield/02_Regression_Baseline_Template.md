---
doc_type: regression-baseline
status: draft
version: 0.1.0
template_version: 1.1.0
language: vi-en
parent: [docs/brownfield/CODEBASE_SUMMARY.md, docs/brownfield/AS_IS_ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# Mốc hồi quy (Regression Baseline): {{PROJECT_NAME}}

<!-- fill: Chép thành docs/brownfield/REGRESSION_BASELINE.md ở bước 0c (brownfield/PLAYBOOK_BROWNFIELD.md). Tài liệu chốt hành vi hiện có phải giữ trước khi đổi mã và được cập nhật suốt quá trình chuyển đổi: cột Trạng thái ở §3 đổi khi Gap Analysis §5 duyệt đổi hoặc bỏ một hành vi. Số liệu lấy từ lệnh đã chạy thật trên commit ở §1. Chưa đạt Gate 0R (brownfield/PLAYBOOK_BROWNFIELD.md mục 3) thì không viết SRS to-be. Frontmatter assembled_from ghi "brownfield/02_Regression_Baseline_Template.md@<template_version>". -->

## 1. Môi trường đo (Measurement Context)

| Hạng mục | Giá trị |
| --- | --- |
| Commit đo | <!-- fill: mã commit đầy đủ, khớp Codebase Summary §1 (HEAD sau commit của Prompt B0) --> |
| Commit chứa test REG | <!-- fill: commit riêng duy nhất chỉ thêm file test, dữ liệu test, cấu hình và dependency test đã duyệt; là hậu duệ của commit đo, không bắt buộc là con trực tiếp (commit ở giữa chỉ đổi tài liệu và cấu hình agent). Ghi thêm git hook đã bỏ qua và kết quả quét secret của commit này (brownfield/PLAYBOOK_BROWNFIELD.md mục 5.1 quy tắc 8). Ghi N/A nếu không thêm test --> |
| Ngày đo | {{DATE}} |
| Lệnh test | <!-- fill: lệnh, lấy từ Codebase Summary §7 --> |
| Công cụ đo độ phủ test | <!-- fill: chọn một theo hàng cùng tên ở Intake §4: có sẵn (tên và phiên bản) \| cài tạm trong worktree đo (tên và phiên bản; không vào manifest hay lockfile) \| thêm vào dev-dependency ở commit REG (tên và phiên bản; số ở commit đo vẫn đo bằng cài tạm) \| đo bằng cách khác (phương pháp và giới hạn, ví dụ chỉ đo dòng). Intake không có hàng này thì ghi cách đã được chủ dự án chọn và câu hỏi ở §11 --> |
| Lệnh đo coverage | <!-- fill: lệnh ở commit đo và lệnh ở commit chứa test REG nếu khác; cài tạm thì ghi cả lệnh cài --> |
| Kết quả test | <!-- fill: số pass, fail, skip; test hỏng sẵn liệt kê ở §7 --> |

## 2. Coverage hiện tại theo module (Current Coverage)

<!-- fill: Đo hai lần bằng công cụ và lệnh ở §1: trên commit đo (chỉ test đã có) và trên commit chứa test REG. Không thêm test REG thì cột sau ghi N/A. Công cụ không đo được nhánh (ví dụ đo bằng cách khác chỉ đo dòng) thì cột Nhánh được phủ ghi N/A kèm lý do. -->

| Mã phân hệ (Codebase Summary §3) | Dòng được phủ, commit đo | Dòng được phủ, commit chứa test REG | Nhánh được phủ | Ghi chú |
| --- | --- | --- | --- | --- |
| `{{MODULE_CODE}}` | <!-- fill: phần trăm --> | <!-- fill: phần trăm, hoặc N/A --> | <!-- fill: phần trăm, hoặc N/A kèm lý do --> | <!-- fill --> |

## 3. Hành vi phải giữ (Behaviors to Preserve)

<!-- fill: Mỗi hành vi quan sát được từ bên ngoài (response của API, màn hình, file xuất, sự kiện, dữ liệu ghi) mà người dùng hay hệ thống khác đang dựa vào một hàng RB-NNN. Nguồn lấy từ luồng chính ở Codebase Summary §5. Cột Bảo vệ bởi ghi TC ID ở §6.1 (test REG mới viết hoặc test đã có được gán TC ID), hoặc "thủ tục thủ công" ở §6.2; RB mức Should không có test ghi Không có. Cột Trạng thái: Giữ khi mới lập; Đổi đã duyệt hoặc Bỏ đã duyệt khi Gap Analysis §5 được duyệt, kèm version của Gap Analysis. Khi SPEC thực hiện thay đổi đó chuyển implemented, bước Sync Docs cập nhật hàng: RB đổi ghi hành vi mới, test mới ở cột Bảo vệ bởi và trở lại Giữ; RB bỏ ghi deprecated, giữ hàng, không dùng lại ID. -->

| RB ID | Mã phân hệ | Hành vi | Nguồn bằng chứng | Bảo vệ bởi | Ưu tiên | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- |
| RB-001 | `{{MODULE_CODE}}` | <!-- fill: phát biểu kiểm chứng được, gồm đầu vào và kết quả --> | <!-- fill: file:dòng hoặc bản ghi request và response --> | TC-{{MODULE_CODE}}-REG-01 | <!-- fill: chọn một: Must \| Should --> | <!-- fill: chọn một: Giữ \| Đổi đã duyệt \| Bỏ đã duyệt \| deprecated --> |

## 4. Dữ liệu mẫu cố định (Golden Data)

<!-- fill: Mặc định dùng dữ liệu tổng hợp (synthetic). Dữ liệu lấy từ production chỉ dùng khi đã ẩn danh không đảo ngược được và chủ dự án duyệt; dữ liệu chỉ đổi tên hay giả danh hóa (pseudonymised) vẫn là dữ liệu cá nhân, không dùng. Không chứa secret, token, cookie, khóa API. -->

| Bộ dữ liệu | Nơi lưu | Cách tái tạo | Nguồn dữ liệu |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: đường dẫn trong repo --> | <!-- fill: lệnh hoặc script --> | <!-- fill: chọn một: tổng hợp \| ẩn danh không đảo ngược (ghi người duyệt) --> |

## 5. Ảnh chụp contract hiện tại (Current Contract Snapshot)

<!-- fill: Contract bên ngoài đúng như hệ thống đang trả, dùng để so sau mỗi thay đổi: tài liệu OpenAPI hiện có, bản ghi request và response, ảnh chụp màn hình, schema file xuất. Agent chụp trên môi trường dùng dữ liệu ở §4, không chụp từ production. Trước khi lưu, che mọi dữ liệu cá nhân và mọi secret, token, cookie, header xác thực, khóa API. Bản ghi từ production chỉ nhận khi chủ dự án tự cung cấp, đã che như trên; cột Môi trường chụp ghi người cung cấp. -->

| Contract | Dạng lưu | Nơi lưu | Môi trường chụp | Cách so khớp |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: lệnh hoặc test --> |

## 6. Bảo vệ hành vi trước khi sửa (Characterization Protection)

### 6.1. Test hồi quy (Regression Tests)

<!-- fill: Mỗi test bảo vệ một hàng: test REG mới viết ở bước này và test đã có của repo (gán TC ID, ghi đúng file và tên hiện có). Test mô tả hành vi hiện tại, kể cả hành vi có vẻ sai (ghi chú ở cột cuối để Gap Analysis quyết định), và phải pass trên mã sản phẩm của commit đo. Chỉ thêm file test, dữ liệu test tổng hợp, cấu hình và dependency test đã duyệt ở Gate 0; không sửa mã sản phẩm. Test REG mà SPEC thêm sau này được thêm vào bảng ở bước Sync Docs, đánh số tiếp theo. Tên test mô tả hành vi bằng tiếng Anh, không chứa TC ID hay RB ID. TC ID theo CONVENTIONS mục 4 và brownfield/PLAYBOOK_BROWNFIELD.md mục 5.3: mọi test ở bảng này mang loại REG, kể cả test đã có; một test tham số hóa là một TC; TC dùng mã phân hệ ở Codebase Summary §3 của hành vi được bảo vệ, không phải của thư mục chứa file test; NN duy nhất theo cặp mã phân hệ và loại trong toàn dự án; không đánh số lại về sau. Test REG mới viết theo vòng ở brownfield/PLAYBOOK_BROWNFIELD.md mục 5.1 quy tắc 9. -->

| TC ID | RB ID | Kịch bản (Given-When-Then) | File test | Tên test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| TC-{{MODULE_CODE}}-REG-01 | RB-001 | **Given:** <!-- fill --><br>**When:** <!-- fill --><br>**Then:** <!-- fill --> | <!-- fill --> | <!-- fill: tên test mô tả hành vi --> | <!-- fill --> |

### 6.2. Thủ tục kiểm tra thủ công (Manual Procedures)

<!-- fill: Dùng khi chủ dự án không cho thêm test ở bước này, hoặc repo không có công cụ test và Gate 0 không duyệt thêm công cụ test (Intake §4). Mỗi RB mức Must không có test một hàng; chủ dự án duyệt rủi ro. Ghi N/A khi mọi RB mức Must có test. -->

| RB ID | Các bước kiểm tra | Kết quả mong đợi | Người thực hiện | Rủi ro đã được chủ dự án chấp nhận |
| --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | [ ] |

## 7. Test hỏng sẵn (Pre-existing Failing Tests)

| Test (file và tên) | Lỗi rút gọn | Nguyên nhân nếu biết | Xử lý |
| --- | --- | --- | --- |
| <!-- fill: hoặc Không có --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: sửa trong một SPEC \| bỏ qua có lý do \| xóa sau khi Gap Analysis duyệt --> |

## 8. Tự kiểm Gate 0R (Gate 0R Self-check)

Gate 0R đầy đủ ở PLAYBOOK_BROWNFIELD mục 3; bảng dưới gồm các tiêu chí thuộc tài liệu này, cùng câu chữ với mục đó.

| Tiêu chí | Đạt? |
| --- | :---: |
| §1 và §2 có số liệu từ lệnh đã chạy; §2 theo module, hoặc một dòng cho toàn repo khi §9 ghi Có | [ ] |
| Mọi luồng chính ở Codebase Summary §5 có ít nhất một RB | [ ] |
| Mọi RB mức Must có test bảo vệ pass trên mã sản phẩm của commit đo, hoặc thủ tục thủ công ở §6.2 được chủ dự án chấp nhận | [ ] |
| Contract bên ngoài đã chụp ở §5 trên dữ liệu ở §4 | [ ] |
| Test hỏng sẵn đã liệt kê ở §7 | [ ] |
| Không còn câu hỏi BLOCKING ở §11 | [ ] |

## 9. Phạm vi tối thiểu cho repo nhỏ (Minimal Scope)

<!-- fill: Repo dưới 5.000 dòng mã (Codebase Summary §1) được phép ghi §2 một dòng cho toàn repo và ghi N/A ở §4 khi hệ thống không có dữ liệu cố định cần giữ. §3, §5, §6, §8 luôn đầy đủ. Ghi quyết định vào bảng; repo lớn hơn ghi Không. -->

| Áp dụng phạm vi tối thiểu | Căn cứ |
| --- | --- |
| <!-- fill: chọn một: Có \| Không --> | <!-- fill: số dòng mã ở Codebase Summary §1 --> |

## 10. Liên kết (Links)

| Loại | Tham chiếu |
| --- | --- |
| Hành vi được duyệt đổi hoặc bỏ | `docs/brownfield/GAP_ANALYSIS.md` §5 |
| Bước chuyển đổi và RB phải pass | `docs/brownfield/MIGRATION_PLAN.md` §2, §6 |

## 11. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## 12. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline brownfield | Chưa duyệt |
