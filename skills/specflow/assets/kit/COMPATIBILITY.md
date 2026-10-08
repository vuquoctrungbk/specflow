---
doc_type: playbook
status: stable
version: 3.1.0
language: vi-en
---

# Nhánh tương thích ngược (specflow Compatibility)

`PLAYBOOK.md` và `PROMPTS.md` viết cho tài liệu tạo từ template hiện hành. Dự án có ít nhất một tài liệu tạo từ template cũ hơn (Intake, SRS, SPEC hoặc wireframe) đọc file này để biết phần nào của quy trình, prompt và Definition of Ready đổi khác cho tài liệu đó. Mục 1 gom mọi cổng phiên bản đang dùng trong PLAYBOOK; mục 2 đến 5 nêu cách làm khác cho từng nhóm tài liệu cũ.

## 1. Cổng phiên bản (Version Gates)

Mỗi quy tắc dưới chỉ áp dụng khi tài liệu tương ứng được tạo từ template ở cột "Áp từ template" trở lên. Cách đọc phiên bản của một tài liệu theo đúng một cách: CONVENTIONS mục 3 (khóa `template_version` của chính tài liệu; tài liệu chưa có khóa này thì đọc version ghi ở mục `assembled_from` cho nguồn tương ứng).

| Quy tắc | Áp từ template | Khóa đọc |
| --- | --- | --- |
| Trần kích thước là lỗi (CONVENTIONS mục 7): SPEC 500 dòng, ARCHITECTURE 800 dòng, dòng 1.000 ký tự; tài liệu từ template cũ hơn chỉ nhận cảnh báo. Fragment OpenAPI của SPEC backend nằm ở tệp đi kèm; SPEC cũ hơn giữ fragment trong §3 và vẫn hợp lệ | SPEC `1.3.0`, Architecture `1.2.0`, xét theo từng file; phiên bản xét là phiên bản mới hơn giữa `template_version` và mục core của `assembled_from`, tài liệu không ghi cả hai chịu trần | CONVENTIONS mục 7 |
| Mục `Đọc trước (Read First)` ở file pha (CONVENTIONS mục 9); pha tạo từ template cũ hơn vẫn hợp lệ và agent đọc SPEC theo `spec_id` của pha | Template pha `1.3.0`, xét theo từng file | CONVENTIONS mục 3 |
| Khóa `risk` ở SPEC và dòng `- Mức rủi ro:` (CONVENTIONS mục 3); SPEC cũ hơn không ghi khóa này được coi là `high` | SPEC `1.4.0`, xét theo từng file | CONVENTIONS mục 3 |
| SRS §8 không có cột TC; SRS cũ hơn giữ cột đó nhưng cột không còn được cập nhật hay đối chiếu, với mọi phiên bản (CONVENTIONS mục 4) | SRS `1.3.0` | CONVENTIONS mục 3 |
| Màn hình ghi `Theo luồng` ở danh mục không cần trang riêng (PLAYBOOK mục 2.2.1); chỉ mục cũ hơn vẫn dùng được giá trị này | Chỉ mục wireframe `1.4.0` | CONVENTIONS mục 3 |
| Hàng `Quy mô` ở Intake mục 14 và thứ tự giữa các đợt (PLAYBOOK mục 2); Intake cũ hơn là quy mô `standard` và không bị kiểm thứ tự đợt. Hàng `Vùng rủi ro cao` thì Intake của mọi phiên bản đều thêm được, checker đọc nó ở mọi phiên bản | Intake `1.5.0` | CONVENTIONS mục 3 |
| Roadmap `docs/ROADMAP.md` (CONVENTIONS mục 11), dòng Định dạng tag ở Intake mục 14, việc ở roadmap khi nhận lời duyệt gate (PLAYBOOK mục 2.7), đối soát roadmap (PLAYBOOK mục 2.6), hàng roadmap ở Definition of Done, mục 7 quy tắc 12 | Intake `1.4.0` | CONVENTIONS mục 3 |
| Quy trình 3 bước, Giai đoạn 1W và Gate 1W, Gate 3 và plan theo đợt, cột `SCR ID` ở SRS §3 và ARCHITECTURE, khóa `release` của SPEC theo đợt, đổi SPEC đã `implemented` theo đợt, hàng Giai đoạn 1W ở Definition of Ready | Intake `1.3.0` | CONVENTIONS mục 3 |
| Profile khớp (PLAYBOOK mục 3), đếm phân hệ loại trừ cross-cutting (PLAYBOOK mục 5), dòng lệnh verify riêng cho brownfield ở `CLAUDE.md` khởi tạo (PLAYBOOK mục 2.1), thứ tự và giới hạn 5 câu hỏi ở Giai đoạn 0 (PLAYBOOK mục 7 quy tắc 3) | Intake `1.2.0` | CONVENTIONS mục 3 |
| Exit gate SRS đầy đủ theo EARS và ISO/IEC/IEEE 29148 §5.2.5 đến §5.2.7 (PLAYBOOK mục 2.2) | SRS `1.1.0` | CONVENTIONS mục 3 |
| Khóa frontmatter `release` của SPEC (PLAYBOOK mục 2.4) | SPEC `1.2.0` | CONVENTIONS mục 3 |
| Tiêu chuẩn UI/UX của wireframe: dòng Màn hình xác thực, tiêu chí WCAG 2.2 ở CONVENTIONS mục 10.2, bảng đánh giá heuristic (mục 10.3), bảng kiểm mẫu thiết kế lừa người dùng (mục 10.4) | Wireframe `1.2.0`, xét theo từng file (chỉ mục theo `template_version` của chỉ mục, trang theo `template_version` của trang) | CONVENTIONS mục 3 |
| Hệ thống thiết kế (CONVENTIONS mục 10.7), dòng Template và Pattern, cột Component ID, HTML đọc token; hàng Gate 1W về hướng, token, danh mục, HTML; hàng Gate 2 và Definition of Ready về hệ thống thiết kế; nhiệm vụ ánh xạ token của Prompt 2 và golden rule chỉ dùng token | chỉ mục `1.3.0`, trang `1.4.0`, xét theo từng file | CONVENTIONS mục 3 |
| Dòng Thông tin ưu tiên, Hành động chính và Nội dung biên, số vùng của bố cục low-fi (CONVENTIONS mục 7 và 10.7) | Trang wireframe `1.5.0`, xét theo từng trang | CONVENTIONS mục 3 |
| Giá trị `Có, kèm HTML đầy đủ` của Giai đoạn 1W và HTML đầy đủ của mỗi trang (CONVENTIONS mục 7). Intake cũ hơn `1.6.0` ghi `Có` hoặc `Có, kèm HTML low-fi`: HTML vẫn tùy chọn, chỉ theo quy tắc an toàn và token | Intake `1.6.0` (giá trị ở mục 14), xét theo từng dự án | CONVENTIONS mục 7 |

## 2. Dự án có Intake cũ hơn `1.3.0`

Dự án có Intake tạo từ template Intake cũ hơn `1.3.0` giữ cách làm theo tính năng của bản `2.3.0`: không có Giai đoạn 1W, mỗi tính năng một SPEC và một plan, Gate 3 và Gate 4 theo từng SPEC; tài liệu đã duyệt không phải sửa lại. Dự án đó muốn dùng 3 bước thì nâng Intake lên template `1.3.0` như một thay đổi MINOR theo PLAYBOOK mục 8 (thêm các trường mới, người duyệt Gate 0 duyệt lại), thêm cột `SCR ID` vào SRS §3 theo PLAYBOOK mục 8, chạy Giai đoạn 1W, rồi áp cách làm theo đợt từ đợt kế tiếp.

- Gate 3, Gate 4: exit gate của mỗi SPEC (PLAYBOOK mục 2.4) là Gate 3 cho SPEC đó; không có bảng Gate 3 theo đợt. PLAYBOOK mục 2.5 áp cho một plan của một SPEC, không phải plan theo đợt; exit gate Gate 4 xét cho plan đó.
- SPEC: không ghi khóa frontmatter `release`, kể cả khi SPEC tạo từ template SPEC `1.2.0` trở lên; đợt của SPEC là Bản phát hành của các FR ở §1.5 (PLAYBOOK mục 2.4).
- Danh mục nạp ngữ cảnh, Giai đoạn 4a (PLAYBOOK mục 6): đọc SPEC đang làm, thay cho mọi SPEC trong `spec_ids` của đợt.
- Giai đoạn 5 (PLAYBOOK mục 2.6): khoảng commit của Gate 5 là toàn bộ plan, vì plan chỉ có một SPEC.
- Definition of Ready (PLAYBOOK mục 10.1): hàng Intake xét plan của một tính năng thay vì plan của đợt; hàng Wireframe ghi N/A (không có Giai đoạn 1W).

## 3. Prompt với Intake cũ hơn `1.3.0`

Dự án có Intake cũ hơn `1.3.0` chạy các prompt ở `PROMPTS.md` với phần thay đổi dưới đây cho từng prompt; phần còn lại của prompt giữ nguyên.

| Prompt | Thay đổi |
| --- | --- |
| Prompt 1 | Bỏ nhiệm vụ 3 (bảng Giao diện người dùng và `SCR ID` ở SRS §3). |
| Prompt 1W | Không chạy prompt này; sau Gate 1 chạy Prompt 2. |
| Prompt 2 | Bỏ phần về wireframe và cột `SCR ID`. |
| Prompt 3 | SPEC cho một tính năng như bản `2.3.0`: bỏ phần về đợt (`{{RELEASE}}`, khóa `release`, SRS §6.1 và SPEC khác của đợt, nền tảng dùng chung ở nhiệm vụ 2, nhiệm vụ 8) và phần wireframe; Gate 3 xét riêng SPEC này. |
| Prompt 4 | Plan cho một SPEC như bản `2.3.0`, thư mục `plans/{YYMMDD-HHmm}-{{FEATURE_SLUG}}/`; phần A đọc SPEC đó thay cho các SPEC của đợt, hàng SRS §6.1 và §8 của FR và AC mà SPEC đó dẫn, không có phần wireframe. Plan chép từ template plan `1.2.0` trở lên ghi `spec_ids` chỉ có SPEC đó và `release` là Bản phát hành của các FR mà SPEC dẫn; mọi pha có `spec_id` của SPEC đó. Plan đã có từ template `1.1.0` giữ nguyên. Phần B chạy mọi pha của plan. |
| Prompt 5 | Khoảng commit là toàn bộ plan. |
| Prompt 6 | Mọi pha và plan sang trạng thái hoàn tất. |
| Prompt Resume | Không có Giai đoạn 1W và đợt; plan đang dở là plan của một SPEC. |

## 4. Dự án có Intake cũ hơn `1.2.0`

Bốn quy tắc dưới thêm ở bản `2.3.0` của bộ mẫu, chỉ áp cho dự án có Intake tạo từ template Intake `1.2.0` trở lên; dự án có Intake cũ hơn giữ cách làm trước đó:

- Profile khớp (PLAYBOOK mục 3): không xét năm tiêu chí khớp thành phần nền; Routing Decision chốt profile theo lựa chọn của dự án mà không kiểm khớp, mọi lệch so với profile ghi ADR ở Giai đoạn 2 như dự án khác.
- Đếm phân hệ (PLAYBOOK mục 5): không loại trừ cross-cutting và thư viện dùng chung khi đếm; `docs_mode` chọn theo ước lượng ở Intake mục 5 mà không xét lại ở Gate 0R.
- `CLAUDE.md` khởi tạo của dự án brownfield (PLAYBOOK mục 2.1): mục lệnh verify ghi "Hoàn thiện ở Giai đoạn 2." như dự án greenfield, không ghi "Hoàn thiện ở Giai đoạn 0R (Prompt B1)."; lệnh được điền ở Giai đoạn 2 theo profile như thường.
- Giai đoạn 0 (PLAYBOOK mục 7 quy tắc 3): không giới hạn 5 câu hay thứ tự ưu tiên câu hỏi; agent gộp câu hỏi cuối giai đoạn theo quy tắc chung, không tách riêng câu ghi `BLOCKING: Không` kèm "trả lời trước Gate 1".

## 5. Tài liệu từ template cũ hơn

- SRS tạo từ template SRS cũ hơn `1.1.0`: dùng exit gate Giai đoạn 1 của bản đó, không theo bảng exit gate ở PLAYBOOK mục 2.2, cho tới khi được nâng lên theo PLAYBOOK mục 8.
- SPEC tạo từ template SPEC cũ hơn `1.2.0`: không có khóa frontmatter `release` và không phải thêm khóa này; đợt của SPEC đó là Bản phát hành của các FR ở §1.5 (PLAYBOOK mục 2.4).
- Wireframe (chỉ mục hoặc trang) tạo từ template wireframe cũ hơn `1.2.0`: không cần dòng Màn hình xác thực, ghi chú theo tiêu chí WCAG 2.2 ở CONVENTIONS mục 10.2, bảng đánh giá heuristic (mục 10.3) hay bảng kiểm mẫu thiết kế lừa người dùng (mục 10.4); vẫn hợp lệ cho tới khi được nâng lên theo PLAYBOOK mục 8.
- Wireframe từ chỉ mục cũ hơn template chỉ mục `1.3.0` hay trang cũ hơn template trang `1.4.0` không cần hệ thống thiết kế; HTML của trang đó giữ thang xám. Muốn nâng thì tạo `docs/design-system/`, nâng chỉ mục và từng trang như một thay đổi MINOR theo PLAYBOOK mục 8, người duyệt Gate 1W duyệt lại. Dự án không có `tokens.json` thì hàng Design token ở ARCHITECTURE ghi nguồn token mà dự án đang dùng. Dự án brownfield có sẵn thư mục `docs/design-system/` (ví dụ bản xuất của Storybook hay zeroheight) chuyển nó vào `docs/legacy/` theo `brownfield/PLAYBOOK_BROWNFIELD.md` (mục chuyển tài liệu cũ) trước khi tạo hệ thống thiết kế to-be.
- Trang tạo từ template trang `1.4.0` không cần dòng Thông tin ưu tiên, Hành động chính, Nội dung biên hay số vùng, và vẫn hợp lệ. Một bộ wireframe được có cả trang `1.4.0` lẫn trang `1.5.0`: trang mới tạo từ `1.5.0`; trang `1.4.0` có thể nâng khi được sửa theo PLAYBOOK mục 8 (không bắt buộc), bằng cách thêm ba dòng, đánh số vùng và đổi `template_version`, `assembled_from` lên `1.5.0`.
- Thêm trang mới vào wireframe có chỉ mục cũ hơn template chỉ mục `1.3.0`: nâng cả chỉ mục và các trang theo gạch trước, không tạo trang từ `1.4.0` trở lên đứng riêng dưới chỉ mục cũ, để mọi màn hình của dự án dựng từ cùng một hệ thống.
- Dự án đã qua Gate 2 mà nâng theo gạch trước: ARCHITECTURE sửa hàng Design token và mục quy ước giao diện như một thay đổi MINOR theo PLAYBOOK mục 8 (người duyệt Gate 2 duyệt lại); SPEC và plan đã duyệt theo các dòng Wireframe và Hệ thống thiết kế ở mục 8. Khi đó MUST chép dòng golden rule chỉ dùng token của template `1.2.0` (frontend-web, mobile-app) vào file golden rule đã có ở `.claude/rules/`, đúng một bản, và cập nhật `assembled_from` của file đó. Code hiện có dùng giá trị thô chuyển sang file ánh xạ token qua SPEC hoặc plan của đợt sau, không sửa ngoài plan. Dự án chọn không nâng thì không thêm golden rule, giữ nguồn token ghi ở ARCHITECTURE, và chấp nhận cảnh báo MINOR về `assembled_from` của file golden rule.
- Dự án có Intake cũ hơn template Intake `1.4.0`: không có roadmap, các việc ở roadmap trong PLAYBOOK và PROMPTS bỏ qua, hàng roadmap ở Definition of Done ghi N/A. Giới hạn 3 lần sửa ở PLAYBOOK mục 7 quy tắc 11 áp cho mọi dự án. Muốn dùng roadmap thì nâng Intake lên `1.4.0` như một thay đổi MINOR theo PLAYBOOK mục 8 (thêm dòng Định dạng tag, người duyệt Gate 0 duyệt lại), rồi dựng `docs/ROADMAP.md` theo PLAYBOOK mục 2.7 như khi nhận "Duyệt Gate 1", điền cột SPEC và Pha theo SPEC và plan đã có; dòng của SPEC đã `implemented` ghi `Xong` kèm bằng chứng, không đặt `Đã xác nhận` và không đánh tag lùi cho SPEC đã đóng.

## 6. Khối layout của các bản trước (Legacy Layout Blocks)

Khối của các bản trước vẫn hợp lệ: dự án đang dùng khối cũ không phải sửa `CLAUDE.md`, và `scripts/check-templates.sh` chấp nhận khối hiện tại cùng mọi khối cũ dưới đây. Mỗi khối cũ có nhãn riêng và được ghi thành diff so với khối hiện tại ở CONVENTIONS mục 6, theo thứ tự dòng của khối hiện tại. Dòng `+` đứng ngay sau một dòng `-` là dòng đổi: khối cũ có dòng `-` ở vị trí của dòng `+` đó. Dòng `+` không có dòng `-` ngay trước nó là dòng chèn thêm: khối cũ không có dòng đó. Mọi dòng khác của khối hiện tại giống hệt khối cũ.

- `docs-layout-legacy-2.0`: khối của bản `2.0.0` và `2.1.0`, định dạng plan theo `ak plan` và chưa có `docs/wireframes/`, `docs/design-system/`, `docs/ROADMAP.md`.
- `docs-layout-legacy-2.2`: khối của bản `2.2.0` và `2.3.0`, chưa có `docs/wireframes/`, `docs/design-system/`, `docs/ROADMAP.md`.
- `docs-layout-legacy-2.4`: khối của các bản `2.4.0` đến `2.7.0`, chưa có `docs/design-system/` và `docs/ROADMAP.md`.
- `docs-layout-legacy-2.8`: khối của các bản `2.8.0` đến `2.9.1`, chưa có `docs/ROADMAP.md`.
- `docs-layout-legacy-2.10`: khối của các bản `2.10.0` và `2.10.1`, chưa có `docs/INDEX.md` và tệp đi kèm.

<!-- BEGIN: docs-layout-legacy-2.0 -->
```diff
-| `project-roadmap.md` | Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+| `project-roadmap.md` | `docs/ROADMAP.md` (dự án có Intake tạo từ template Intake `1.4.0` trở lên), Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+├── ROADMAP.md                        # Intake 1.4.0 trở lên: việc phải làm, tiến độ, mốc (CONVENTIONS mục 11)
+├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
+├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
+├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
+├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
+├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
+├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
+├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
-├── design-guidelines.md              # tùy chọn, khi có frontend
+├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
+├── design-system/tokens.json         # token nguồn, định dạng DTCG
-plans/{YYMMDD-HHmm}-{slug}/plan.md    # Implementation Plan, định dạng ak plan
+plans/{YYMMDD-HHmm}-{slug}/plan.md    # Implementation Plan, định dạng ở CONVENTIONS mục 9
-Implementation Plan và report nằm trong `plans/` theo định dạng của `ak plan`; không tạo `IMPLEMENTATION_PLAN.md` ở gốc. Khi rule toàn cục và tài liệu specflow mâu thuẫn về bố cục hoặc quy trình tài liệu, tài liệu specflow thắng trong phạm vi dự án này. Các rule toàn cục khác (development rules, git, process management) vẫn có hiệu lực.
+Implementation Plan và report nằm trong `plans/` theo định dạng ở CONVENTIONS mục 9 (không cần công cụ riêng); không tạo `IMPLEMENTATION_PLAN.md` ở gốc. Khi rule toàn cục và tài liệu specflow mâu thuẫn về bố cục hoặc quy trình tài liệu, tài liệu specflow thắng trong phạm vi dự án này. Các rule toàn cục khác (development rules, git, process management) vẫn có hiệu lực.
```
<!-- END: docs-layout-legacy-2.0 -->

<!-- BEGIN: docs-layout-legacy-2.2 -->
```diff
-| `project-roadmap.md` | Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+| `project-roadmap.md` | `docs/ROADMAP.md` (dự án có Intake tạo từ template Intake `1.4.0` trở lên), Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+├── ROADMAP.md                        # Intake 1.4.0 trở lên: việc phải làm, tiến độ, mốc (CONVENTIONS mục 11)
+├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
+├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
+├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
+├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
+├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
+├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
+├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
-├── design-guidelines.md              # tùy chọn, khi có frontend
+├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
+├── design-system/tokens.json         # token nguồn, định dạng DTCG
```
<!-- END: docs-layout-legacy-2.2 -->

<!-- BEGIN: docs-layout-legacy-2.4 -->
```diff
-| `project-roadmap.md` | Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+| `project-roadmap.md` | `docs/ROADMAP.md` (dự án có Intake tạo từ template Intake `1.4.0` trở lên), Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+├── ROADMAP.md                        # Intake 1.4.0 trở lên: việc phải làm, tiến độ, mốc (CONVENTIONS mục 11)
+├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
+├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
+├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
+├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
-├── design-guidelines.md              # tùy chọn, khi có frontend
+├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
+├── design-system/tokens.json         # token nguồn, định dạng DTCG
```
<!-- END: docs-layout-legacy-2.4 -->

<!-- BEGIN: docs-layout-legacy-2.8 -->
```diff
-| `project-roadmap.md` | Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+| `project-roadmap.md` | `docs/ROADMAP.md` (dự án có Intake tạo từ template Intake `1.4.0` trở lên), Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |
+├── ROADMAP.md                        # Intake 1.4.0 trở lên: việc phải làm, tiến độ, mốc (CONVENTIONS mục 11)
+├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
+├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
+├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
+├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
```
<!-- END: docs-layout-legacy-2.8 -->

<!-- BEGIN: docs-layout-legacy-2.10 -->
```diff
+├── INDEX.md                          # chỉ mục sinh bởi specflow/scripts/project-index.py, không sửa tay
+├── gates/GATE-N.md                   # sổ duyệt của từng gate, do specflow/scripts/gate.py ghi, không sửa tay
+├── architecture/                     # tệp đi kèm của ARCHITECTURE (CONVENTIONS mục 7)
+├── specs/SPEC_<FEATURE_KEY>.*        # tệp đi kèm của SPEC, không phải .md (CONVENTIONS mục 7)
```
<!-- END: docs-layout-legacy-2.10 -->

## 7. Nâng từ 2.x lên 3.0.0

Bản 3.0.0 đổi cách làm, không đổi định dạng tài liệu đã duyệt. Quy tắc mới của 3.0.0 không sinh lỗi nào trên tài liệu viết theo 2.x; lỗi mà `scripts/check-templates.sh --project .` báo trên một dự án cũ là lỗi có sẵn của tài liệu đó. `gate.py` chỉ từ chối vì lỗi của chính tài liệu đang trình, nên dự án còn lỗi cũ ở tài liệu khác vẫn dùng được nó.

Việc phải làm:

1. Thay thư mục bộ mẫu trong dự án bằng bản 3.0.0, gồm cả `scripts/` (cần `python3`).
2. Xóa mọi file nới lỏng riêng của dự án đã viết để giảm nghi thức của 2.x; các điều đó nay là quy tắc mặc định (PLAYBOOK mục 2.6, 7 và 8).
3. Ở `CLAUDE.md` của dự án, thay dòng "Mỗi lượt chỉ làm một giai đoạn" bằng dòng tương ứng ở mục 2 của `core/06_Agent_Context_Template.md`. Ở `.claude/rules/docs-workflow.md`, thay dòng "Pipeline 3 bước", dòng "Thay đổi tài liệu đã duyệt theo" và dòng "Khác biệt so với SPEC hoặc ARCHITECTURE" bằng các dòng tương ứng ở Phụ lục A của file đó.
4. Chạy `python3 <thư mục bộ mẫu>/scripts/project-index.py .` để có `docs/INDEX.md`.

Phần của 2.x còn nguyên hiệu lực cho tới khi tài liệu được sửa:

- SPEC không ghi `risk` là `high`: nó vẫn đóng bằng review đầy đủ và dừng chờ duyệt khi sửa. Muốn một SPEC cũ đi đường nhẹ thì thêm `risk: normal` và dòng `- Mức rủi ro:` như một thay đổi MINOR, người duyệt Gate 3 duyệt; nhiều SPEC được trình trong một lần duyệt.
- File pha tạo từ template pha cũ hơn `1.3.0` không có mục `Đọc trước`: agent đọc SPEC theo `spec_id` của pha và ARCHITECTURE §1, §4 đến §7.
- Cột TC ở SRS §8 không cần xóa; nó chỉ không còn được cập nhật hay đối chiếu.

Không phải làm: sửa lại nội dung tài liệu đã `approved` hay `implemented`. Thứ tự giữa các đợt và quy mô `small` chỉ áp khi Intake được nâng lên template Intake `1.5.0` theo PLAYBOOK mục 8; hàng `Vùng rủi ro cao` thì thêm được vào Intake của mọi phiên bản.
