---
doc_type: agent-context
status: draft
version: 0.1.0
template_version: 2.8.0
language: vi-en
parent: [docs/intake/PROJECT_INTAKE.md]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}}: hướng dẫn cho Claude Code

## Documentation Layout

<!-- BEGIN: docs-layout-override -->
Dự án này dùng bố cục tài liệu specflow. Bỏ qua bộ tên tài liệu `project-overview-pdr.md`, `system-architecture.md`, `code-standards.md`, `deployment-guide.md`, `codebase-summary.md`, `project-roadmap.md` của rule toàn cục và không tạo các file đó. Vai trò của chúng được thay như sau:

| Tên theo rule toàn cục | Thay bằng trong bố cục specflow |
| --- | --- |
| `project-overview-pdr.md` | `docs/intake/PROJECT_INTAKE.md` và SRS trong `docs/srs/` |
| `system-architecture.md` | `docs/ARCHITECTURE.md` |
| `code-standards.md` | ARCHITECTURE §1 (Golden Rules), §7 (conventions) và `.claude/rules/` |
| `deployment-guide.md` | ARCHITECTURE §8 (Deployment) và §11 (CI/CD) |
| `codebase-summary.md` | ARCHITECTURE §4 (layout); dự án brownfield dùng `docs/brownfield/CODEBASE_SUMMARY.md` |
| `project-roadmap.md` | `docs/ROADMAP.md` (dự án có Intake tạo từ template Intake `1.4.0` trở lên), Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |

```text
specflow/                                 # bộ mẫu specflow, chỉ đọc
docs/
├── intake/PROJECT_INTAKE.md
├── ROADMAP.md                        # Intake 1.4.0 trở lên: việc phải làm, tiến độ, mốc (CONVENTIONS mục 11)
├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
├── srs/SRS.md                        # monolithic
├── srs/00_SRS_MASTER.md              # modular: tổng quan, NFR, mô hình dữ liệu chung
├── srs/SRS_MODULE_<NAME>.md          # modular: use case của từng phân hệ
├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
├── ARCHITECTURE.md
├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
├── adr/NNNN-<slug>.md
├── specs/SPEC_<FEATURE_KEY>.md
├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
├── prompts/PROMPT_<NAME>.md          # chỉ khi dùng overlay ai-llm-app
├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
├── design-system/tokens.json         # token nguồn, định dạng DTCG
└── brownfield/                       # chỉ dự án brownfield
    ├── CODEBASE_SUMMARY.md
    ├── AS_IS_ARCHITECTURE.md
    ├── REGRESSION_BASELINE.md
    ├── GAP_ANALYSIS.md
    └── MIGRATION_PLAN.md
plans/{YYMMDD-HHmm}-{slug}/plan.md    # Implementation Plan, định dạng ở CONVENTIONS mục 9
plans/{YYMMDD-HHmm}-{slug}/phase-NN-<slug>.md
plans/reports/                        # report của agent
CLAUDE.md
.claude/rules/*.md
```

Implementation Plan và report nằm trong `plans/` theo định dạng ở CONVENTIONS mục 9 (không cần công cụ riêng); không tạo `IMPLEMENTATION_PLAN.md` ở gốc. Khi rule toàn cục và tài liệu specflow mâu thuẫn về bố cục hoặc quy trình tài liệu, tài liệu specflow thắng trong phạm vi dự án này. Các rule toàn cục khác (development rules, git, process management) vẫn có hiệu lực.
<!-- END: docs-layout-override -->

Chế độ lưu trữ SRS của dự án: `{{DOCS_MODE}}` (PLAYBOOK mục 5).

<!-- fill: Chép file này thành CLAUDE.md ở gốc dự án; giữ mục Documentation Layout là mục đầu tiên và giữ nguyên văn khối giữa hai dòng dấu mốc (kể cả hai dòng dấu mốc). Giai đoạn 0 tạo bản khởi tạo: mục chưa đủ dữ liệu thay bằng dòng "Hoàn thiện ở Giai đoạn 2."; Giai đoạn 2 hoàn thiện toàn bộ và tạo các file ở Phụ lục A. Có starter thì dùng CLAUDE.md.template của starter thay cho file này. Không chép Phụ lục A vào CLAUDE.md: Giai đoạn 2 đọc Phụ lục A từ template trong specflow/ để tạo các file rule. Frontmatter assembled_from ghi nguồn theo CONVENTIONS mục 3. -->

## 1. Dự án (Project)

| Trường | Giá trị |
| --- | --- |
| Tên | {{PROJECT_NAME}} |
| Mục tiêu | <!-- fill: 1 đến 2 câu từ Intake mục 2 --> |
| Bề mặt (overlays) | `{{OVERLAYS}}` |
| Stack profile theo bề mặt | <!-- fill: overlay và profile, theo Intake mục 14 --> |
| Mode | <!-- fill: chọn một: greenfield \| brownfield --> |
| Intake | `docs/intake/PROJECT_INTAKE.md` |

## 2. Quy trình tài liệu (Documentation Workflow)

- Quy trình và gate theo `specflow/PLAYBOOK.md`; prompt theo `specflow/PROMPTS.md`; hợp đồng định dạng theo `specflow/CONVENTIONS.md`. Các file này và mọi file trong `specflow/` chỉ đọc.
- Quy trình gồm 3 bước và giai đoạn thực thi (PLAYBOOK mục 2): 1. Yêu cầu (Giai đoạn 0 Intake, 1 SRS, 1W Wireframe khi có giao diện); 2. Thiết kế (Giai đoạn 2 Architecture và ADR, 3 mọi SPEC của đợt); 3. Kế hoạch (Giai đoạn 4a plan của đợt); thực thi (4b Coding TDD, 5 Verify và Sync Docs theo từng SPEC). Giai đoạn 1W của dự án này: <!-- fill: chọn một: Có | Không, theo Intake mục 14 -->.
- Intake tạo từ template Intake cũ hơn `1.3.0`: dự án làm theo tính năng như bản `2.3.0` của bộ mẫu (PLAYBOOK mục 2): không có Giai đoạn 1W và đợt, mỗi tính năng một SPEC và một plan; `specflow/COMPATIBILITY.md` mục 2 và 3 nêu phần thay đổi cho nhánh này.
<!-- fill: Intake tạo từ template Intake 1.3.0 trở lên thì xóa dòng trên; Intake cũ hơn thì giữ dòng trên và ghi Giai đoạn 1W của dự án này là Không. -->
- Không viết code khi Definition of Ready (PLAYBOOK mục 10.1) chưa đạt. Dừng ở mỗi gate để người duyệt quyết định.
- Roadmap `docs/ROADMAP.md` (CONVENTIONS mục 11) là danh sách việc phải làm: đọc đầu mỗi phiên; khi code làm theo thứ tự pha của plan và không nhảy qua dòng `Chưa làm` nào; cập nhật sau mỗi pha (PLAYBOOK mục 2.5); yêu cầu mới ghi vào mục 3 của roadmap, không làm ngay; chỉ đặt `Đã xác nhận` và đánh tag khi nhận "Duyệt Gate 5" (PLAYBOOK mục 2.7).
<!-- fill: Intake tạo từ template Intake cũ hơn 1.4.0 thì xóa dòng trên (dự án không có roadmap, specflow/COMPATIBILITY.md mục 5). -->
- Tra cứu tài liệu: đọc `docs/INDEX.md` trước khi mở tài liệu khác. Tìm nơi định nghĩa một ID hoặc một mã lỗi bằng `python3 specflow/scripts/project-index.py .` với `--where` và ID đó; xem các mục của một tài liệu kèm khoảng dòng bằng `--outline` và đường dẫn tệp; rồi chỉ đọc khoảng dòng cần. Không dò cả thư mục `docs/` bằng lệnh tìm kiếm để tìm một ID.
- Sau khi sửa tài liệu: chạy `python3 specflow/scripts/project-index.py .` để dựng lại chỉ mục và `bash specflow/scripts/check-templates.sh --project .` để kiểm; sửa mọi lỗi nó báo ở tài liệu vừa sửa. Không tự viết script để kiểm những điều checker đã kiểm.
- SPEC và ARCHITECTURE giữ trong trần kích thước của CONVENTIONS mục 7; khối máy đọc dài (hợp đồng API, lược đồ dữ liệu, mã mẫu) đặt ở tệp đi kèm và chỉ mở khi việc đang làm cần nội dung của nó.
- Dự án mới và đợt mới: mỗi lượt làm một giai đoạn. Thay đổi trên dự án đã có baseline: một lượt sửa mọi tài liệu thay đổi cần và trình gộp các gate (specflow/PLAYBOOK.md mục 8). Kết thúc lượt bằng danh sách file đã đổi, checklist exit gate và Open Questions.
- Chi tiết: `.claude/rules/docs-workflow.md`.
<!-- fill: Dự án brownfield giữ ba dòng dưới; dự án greenfield xóa ba dòng này. -->
- Brownfield: đi theo `specflow/brownfield/PLAYBOOK_BROWNFIELD.md`, gồm phần bổ sung cho từng prompt ở mục 6.1; mục 5 của file đó thắng rule khác của repo khi mâu thuẫn. Giai đoạn 0R không sửa mã sản phẩm; ngoại lệ duy nhất của quy tắc không viết code trước DoR và quy tắc chỉ commit file trong File Diff là test `REG` trong commit riêng theo mục 5.1 khi Intake §4 cho phép. Ở Giai đoạn 0R, lệnh của dự án chỉ chạy trong worktree sạch, khi mọi kho dữ liệu và dịch vụ ngoài trỏ tới đích cục bộ hoặc dùng một lần (`docs/brownfield/CODEBASE_SUMMARY.md` §2); từ Giai đoạn 1, lệnh chạy trong thư mục làm việc với các biến đó đặt tường minh theo mục 5.4 quy tắc 6. Không mở file env không phải file mẫu; không ghi secret hay dữ liệu cá nhân vào tài liệu.
- Brownfield: không refactor ngoài File Diff của SPEC đang làm, kể cả khi thấy mã cần cải thiện; đề xuất ghi vào mục `Assumptions & Open Questions`.
- Brownfield: giữ nguyên mọi hành vi trong `docs/brownfield/REGRESSION_BASELINE.md`, trừ hành vi đã được duyệt đổi ở `docs/brownfield/GAP_ANALYSIS.md` §5; chạy test `REG` trước và sau mỗi pha.

## 3. Đọc trước khi làm (Context Loading)

| Việc đang làm | Đọc | Không đọc |
| --- | --- | --- |
| Viết hoặc sửa SRS | Intake, template SRS của giai đoạn, overlay và profile đã chọn | Template Architecture và Spec, mã nguồn |
| Viết hoặc sửa wireframe (Giai đoạn 1W) | Theo `specflow/PLAYBOOK.md` mục 6, hàng 1W | Stack profile, template Architecture và Spec, mã nguồn |
| Viết hoặc sửa ARCHITECTURE, ADR | Intake, SRS, chỉ mục wireframe khi có Giai đoạn 1W, template Architecture của giai đoạn, profile, `specflow/core/03_ADR_Template.md` | Template Spec, mã nguồn |
| Viết SPEC của đợt | `docs/ARCHITECTURE.md`, phần SRS chứa FR, cột FR ID và Bản phát hành ở SRS §6.1, frontmatter của mọi SPEC và §1.5 của SPEC thuộc đợt (khóa `release`; SPEC không có khóa thì đọc §1.5 của nó, đợt theo Bản phát hành của FR, PLAYBOOK mục 2.4), cột TC ID ở §9 của mọi SPEC cùng mã phân hệ (đánh số TC tiếp theo, CONVENTIONS mục 4), chỉ mục wireframe và trang wireframe của các `SCR-*` mà FR dẫn, ADR liên quan, mã nguồn của phân hệ | Phần còn lại của SRS module khác, nội dung SPEC khác ngoài frontmatter, §1.5 và cột TC ID ở §9, trang wireframe khác, mã nguồn của phân hệ khác |
| Lập plan của đợt | Mọi SPEC trong `spec_ids` của đợt, hàng SRS §6.1 của FR thuộc đợt và hàng SRS §8 của AC mà SPEC của đợt dẫn, chỉ mục wireframe và trang của các `SCR-*` mà SPEC của đợt dẫn (khi có Giai đoạn 1W), ARCHITECTURE §1, §4, §5, §7, `specflow/core/05_Implementation_Plan_Template/` | SRS toàn văn (chỉ đọc các hàng đã nêu), trang wireframe không được SPEC của đợt dẫn, SPEC ngoài đợt |
| Code | `docs/ROADMAP.md` khi có, plan và pha đang làm, SPEC theo `spec_id` của pha, ARCHITECTURE §1, §4 đến §7, file trong File Diff | File ngoài File Diff, SPEC khác |
| Mọi việc | File này | `examples/` của bộ mẫu, bộ mẫu cũ |

Bảng đầy đủ: `specflow/PLAYBOOK.md` mục 6.

## 4. Lệnh build, test và verify (Build, Test & Verify)

Chạy trước mỗi commit; điều kiện pass theo PLAYBOOK mục 11. Lệnh nào báo lỗi thì dừng, sửa, chạy lại cả bộ. Cùng một lệnh test hay verify vẫn hỏng cùng lỗi sau 3 lần sửa liên tiếp, kể cả trong vòng đỏ sang xanh, thì dừng, báo lỗi, các cách đã thử và phương án (PLAYBOOK mục 7 quy tắc 11).

<!-- SLOT: playbook.verify-commands -->
<!-- slot-hint: Overlay cung cấp bảng lệnh verify của bề mặt; lệnh cụ thể lấy từ stack profile đã chọn. -->

## 5. Nguyên tắc lập trình (Golden Rules)

<!-- fill: tóm tắt 5 đến 8 quy tắc quan trọng nhất từ docs/ARCHITECTURE.md §1.2, mỗi dòng một quy tắc. Bản đầy đủ: docs/ARCHITECTURE.md §1.2 và .claude/rules/coding-golden-rules.md. -->

## 6. Khi gặp mơ hồ (Ambiguity)

- Ghi mọi giả định vào mục `Assumptions & Open Questions` của tài liệu đang làm; không giải quyết mơ hồ ngầm.
- Mơ hồ chạm phạm vi, API, schema, bảo mật hoặc dữ liệu cá nhân: dừng và hỏi. Mơ hồ nhỏ: chọn giả định an toàn nhất, ghi lại, làm tiếp.
- SPEC mâu thuẫn với mã hiện có hoặc với ARCHITECTURE: dừng, báo `file:line` và mục tài liệu, đưa phương án; không tự chọn.
- Câu hỏi gộp một lượt, tối đa 5 câu, mỗi câu kèm phương án đề xuất.

## 7. Ngôn ngữ (Language)

Tài liệu viết tiếng Việt có dấu, thuật ngữ kỹ thuật giữ tiếng Anh; định danh code, tên file, tên bảng và cột, mã lỗi, ID yêu cầu, commit message, tên test luôn tiếng Anh (CONVENTIONS mục 5). Không đổi ngôn ngữ giữa chừng một tài liệu.

## 8. Git

- Conventional Commits bằng tiếng Anh; một commit cho mỗi pha của Implementation Plan; message mô tả hành vi, không chứa ID quy trình.
- Không commit secret, file biến môi trường thật, dữ liệu cá nhân.
- Chỉ commit file trong File Diff của SPEC đang làm, cộng tài liệu và plan được cập nhật.
- SPEC qua Gate 5: annotated tag trên commit pha cuối của SPEC theo dòng Định dạng tag ở Intake mục 14; push tag khi người duyệt cho phép.
<!-- fill: Intake tạo từ template Intake cũ hơn 1.4.0 thì xóa dòng trên (không có dòng Định dạng tag). -->

## 9. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill: giả định về môi trường, lệnh, quy ước chưa chốt --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## Phụ lục A: file trong `.claude/rules/` (Appendix)

<!-- fill: Phụ lục này không thuộc CLAUDE.md. Ở Giai đoạn 2, tạo mỗi file dưới đây từ khối tương ứng (bỏ dòng mở và đóng khối code), điền placeholder (paths liệt kê mỗi thư mục mã nguồn một glob), ghi assembled_from là "core/06_Agent_Context_Template.md@<template_version>" và template_version của rule bằng template_version của template này, rồi thêm rule của từng overlay: starter đã kèm sẵn ở các mục A.3 trở đi; không có starter thì chép từ specflow/overlays/<surface>/agent-rules/. -->

### A.1. `.claude/rules/docs-workflow.md`

```markdown
---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 2.2.0
language: vi-en
parent: [CLAUDE.md]
overlays: []
assembled_from: []
---

# Quy trình tài liệu (Documentation Workflow)

- Pipeline 3 bước và giai đoạn thực thi (specflow/PLAYBOOK.md mục 2): bước 1 Yêu cầu gồm Giai đoạn 0 Intake, 1 SRS, 1W Wireframe khi có giao diện; bước 2 Thiết kế gồm Giai đoạn 2 Architecture và ADR, 3 mọi SPEC của đợt; bước 3 Kế hoạch gồm Giai đoạn 4a plan của đợt; thực thi gồm 4b coding TDD và 5 Verify và Sync Docs theo từng SPEC, gộp được cho SPEC risk: normal (specflow/PLAYBOOK.md mục 2.6). Mỗi giai đoạn dừng ở gate, trừ các lần trình gộp ở specflow/PLAYBOOK.md mục 5 và 8; không tự chuyển giai đoạn khi chưa có lời duyệt. Dự án có Intake tạo từ template Intake cũ hơn 1.3.0 làm theo tính năng như bản 2.3.0: không có Giai đoạn 1W và đợt, mỗi tính năng một SPEC và một plan; specflow/COMPATIBILITY.md mục 2 và 3 nêu phần thay đổi cho nhánh này.
- Mỗi giai đoạn dùng đúng prompt ở specflow/PROMPTS.md và đúng danh mục nạp ngữ cảnh ở mục 6.
- Sau khi ghép template, chạy lệnh kiểm tra sót ở specflow/PLAYBOOK.md mục 4; kết quả MUST rỗng.
- Thay đổi tài liệu theo specflow/PLAYBOOK.md mục 8: sửa tự do khi tài liệu còn draft hoặc in-review; tăng version một lần lúc trình gate bằng specflow/scripts/gate.py; chỉ dừng chờ duyệt khi thay đổi chạm hợp đồng công khai, schema, bảo mật, phạm vi hoặc SPEC risk: high; chỉ sửa tài liệu hạ nguồn có nội dung thật sự đổi. TC chỉ ghi ở SPEC §9 và file pha.
- Khác biệt phát hiện khi code: SPEC risk: normal thì sửa SPEC cùng nhánh với code; đổi kiến trúc hoặc SPEC risk: high thì ghi ADR trước khi merge. ADR đã accepted không sửa nội dung quyết định; tạo ADR mới và đặt ADR cũ superseded.
- Không tạo tài liệu ngoài bố cục ở mục Documentation Layout của CLAUDE.md.
```

### A.2. `.claude/rules/coding-golden-rules.md`

```markdown
---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 2.2.0
language: vi-en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# Nguyên tắc lập trình (Coding Golden Rules)

- Tuân thủ Golden Rules ở docs/ARCHITECTURE.md §1.2, cây thư mục ở §4 và schema ở §5.
- Chỉ sửa hoặc tạo file trong File Diff của SPEC đang thực thi; cần file khác thì dừng và đề xuất sửa SPEC.
- TDD: viết test theo SPEC §9 trước, chạy thấy đỏ, rồi mới viết logic. Đặt đúng file và tên test như bảng SPEC §9; tên test mô tả hành vi, không chứa TC ID hay ID quy trình.
- Mọi lỗi ra khỏi hệ thống theo envelope ở docs/ARCHITECTURE.md §6.2 với mã trong §7.1; không tự đặt mã lỗi mới.
- Chỉ dùng thư viện trong docs/ARCHITECTURE.md §2.1; cần thư viện mới thì đề xuất ADR và dừng.
- Không hardcode secret; không ghi log secret, token hay dữ liệu cá nhân chưa che.
```
