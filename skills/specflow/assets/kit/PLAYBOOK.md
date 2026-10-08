---
doc_type: playbook
status: stable
version: 3.1.0
language: vi-en
---

# Playbook điều phối AI Coding (AI Coding Playbook)

## 1. Mục đích và nguyên tắc (Purpose & Principles)

### 1.1. Mục đích

Quy trình bắt buộc cho coding agent (mặc định là Claude Code) và kỹ sư khi xây dựng phần mềm bằng bộ mẫu specflow: từ ý tưởng tới mã nguồn đã kiểm chứng, qua một chuỗi tài liệu thu hẹp dần ngữ cảnh và tăng dần độ chi tiết (Top-Down Specification). Chuỗi đó là quy trình 3 bước rồi tới thực thi: bước 1 Yêu cầu (Intake, SRS, wireframe đối chiếu với SRS khi có giao diện), bước 2 Thiết kế (Architecture và ADR, SPEC của đợt), bước 3 Kế hoạch (plan triển khai của đợt); thực thi gồm coding TDD, verify và đồng bộ tài liệu (mục 2). Playbook này định nghĩa quy trình; hợp đồng định dạng (placeholder, slot, frontmatter, ID, bố cục tài liệu) nằm trong [CONVENTIONS.md](CONVENTIONS.md).

### 1.2. Nguyên tắc bất di bất dịch

1. Không sinh mã nguồn khi chuỗi tài liệu `PROJECT_INTAKE → SRS → WIREFRAME → ARCHITECTURE + ADR → SPEC → Implementation Plan` chưa hoàn thiện và chưa được duyệt theo Definition of Ready (mục 10.1). WIREFRAME chỉ có ở dự án có Giai đoạn 1W (mục 2.2.1). Ngoại lệ duy nhất: test `REG` của dự án brownfield ở Giai đoạn 0R ([brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md) mục 5.1).
2. Mỗi giai đoạn kết thúc ở một exit gate có người duyệt; agent dừng ở gate, không tự chuyển giai đoạn.
3. Tài liệu là nguồn chân lý (Single Source of Truth). Khi code và tài liệu lệch nhau, sửa một trong hai qua quy trình mục 8, không để lệch.
4. Mọi mơ hồ được ghi lại trong mục `Assumptions & Open Questions`, không được giải quyết ngầm.
5. TDD: test viết từ kịch bản trong SPEC trước khi viết logic.

### 1.3. Ngôn ngữ

Theo [CONVENTIONS.md](CONVENTIONS.md) mục 5: diễn giải tiếng Việt có dấu, thuật ngữ kỹ thuật giữ tiếng Anh, định danh luôn tiếng Anh. Agent MUST NOT đổi ngôn ngữ giữa chừng.

### 1.4. Cài đặt và đường dẫn

Bộ mẫu được chép vào thư mục `specflow/` ở gốc dự án: `PLAYBOOK.md`, `PROMPTS.md`, `COMPATIBILITY.md`, `CONVENTIONS.md`, `CHANGELOG.md`, `core/`, `overlays/`, `starters/`, `brownfield/`, `scripts/`; khi nâng cấp, xóa `specflow/` cũ trước khi chép. Không chép `examples/`. Đường dẫn template trong tài liệu này tính từ gốc bộ mẫu (ví dụ `core/01_SRS_Template.md`); trong dự án, thêm tiền tố `specflow/`. Prompt ở `PROMPTS.md` đã viết sẵn theo đường dẫn dự án.

## 2. Pipeline tài liệu (Document Pipeline)

Quy trình gồm 3 bước và giai đoạn thực thi. Mỗi bước gom một hoặc nhiều giai đoạn và khép lại bằng gate của giai đoạn cuối; số và tên giai đoạn, gate giữ như cũ.

Cột `Prompt` dưới là bảng đối chiếu duy nhất của bước, giai đoạn, gate và prompt; nơi khác dẫn về bảng này thay vì lặp lại.

| Bước | Giai đoạn | Gate | Prompt | Kết quả khi đạt |
| --- | --- | --- | --- | --- |
| 1. Yêu cầu | 0 Intake; 0R khi brownfield; 1 SRS; 1W Wireframe khi có giao diện | Gate 0; Gate 0R; Gate 1; Gate 1W | Prompt 0; Prompt B0 đến B2 (brownfield); Prompt 1; Prompt 1W | SRS, wireframe và tài liệu hệ thống thiết kế `approved`, bảng đối chiếu FR ↔ SCR khớp |
| 2. Thiết kế | 2 Architecture và ADR; 3 SPEC của đợt | Gate 2; Gate 3 theo đợt | Prompt 2; Prompt 3 (mỗi lượt một SPEC) | ARCHITECTURE, ADR và mọi SPEC của đợt `approved` |
| 3. Kế hoạch | 4a plan của đợt | Gate 4 | Prompt 4 phần A | Plan của đợt phủ mọi SPEC của đợt, DoR đạt |
| Thực thi | 4b Coding TDD; 5 Verify và Sync Docs | Gate 5 theo SPEC | Prompt 4 phần B, 5, 6 | Mỗi SPEC `implemented`; plan `completed` khi SPEC cuối của đợt xong |
| Phiên mới | Giai đoạn đang dở khi mở phiên mới | Theo giai đoạn đang dở | Prompt Resume | Tiếp tục đúng bước còn dở, không lặp lại gate đã qua |

- Giai đoạn 1W có khi dự án có bề mặt giao diện: overlay `frontend-web` hoặc `mobile-app`, hoặc bề mặt khác có màn hình. Intake mục 14 ghi Giai đoạn 1W có hay không; dự án không có giao diện (chỉ `backend-api`, `ai-llm-app`) ghi Không và Gate 1W ghi N/A ở Intake mục 9.
- Đợt phát hành (release) là nhãn ở cột Bản phát hành của SRS §6.1, ví dụ `R1`; tên các đợt dự kiến ghi ở Intake. Bước 2 và bước 3 chạy cho từng đợt theo thứ tự: Giai đoạn 2 chạy một lần ở đợt đầu, đợt sau chỉ cập nhật ARCHITECTURE và ADR theo mục 8 khi cần; Giai đoạn 3 viết mọi SPEC của đợt; Giai đoạn 4a lập một plan cho cả đợt. Thực thi đi theo từng SPEC trong plan; đợt xong thì lặp lại từ Giai đoạn 3 cho đợt tiếp theo.
- Mỗi đợt là một lát cắt dọc, để có mã chạy được sớm. Đợt đầu gồm nền tảng dùng chung và một luồng đầu cuối; mỗi đợt có 1 đến 3 SPEC, không quá 5. SRS §6.1 chia FR vào các đợt theo cách đó ngay từ Giai đoạn 1; FR của đợt sau chỉ cần phát biểu và AC, chưa cần SPEC. Dự án có Intake tạo từ template Intake `1.5.0` trở lên: không viết SPEC của đợt sau khi đợt trước còn SPEC chưa `implemented` (`scripts/check-templates.sh` báo lỗi, và cảnh báo khi một đợt có hơn 5 SPEC).
- Roadmap (dự án có Intake tạo từ template Intake `1.4.0` trở lên): `docs/ROADMAP.md` theo `core/08_Roadmap_Template.md` và CONVENTIONS mục 11 là danh sách việc phải làm mà coding agent bám theo. Agent dựng nó khi nhận "Duyệt Gate 1", điền dần ở Gate 3 và Gate 4, cập nhật sau mỗi pha, đối soát ở mục 2.6 và đánh dấu `Đã xác nhận` khi nhận "Duyệt Gate 5" (mục 2.7). Roadmap dẫn xuất từ SRS: lệch thì SRS thắng.
- Dự án brownfield: Giai đoạn 1W chạy sau Gap Analysis và vẽ giao diện to-be ([brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md) mục 2).

Quy tắc trong file này viết cho tài liệu tạo từ template hiện hành. Dự án có tài liệu (Intake, SRS, SPEC hoặc wireframe) tạo từ template cũ hơn đọc `COMPATIBILITY.md` để biết phần khác đi, kể cả cách nâng lên template hiện hành.

Cột Kiểm chứng của các bảng exit gate nêu nơi người duyệt đối chiếu. Hàng ghi "checker trên ví dụ" là quy tắc mà `scripts/check-templates.sh --examples` kiểm trên ví dụ của bộ mẫu; trong dự án, `bash specflow/scripts/check-templates.sh --project .` kiểm cùng các quy tắc đó trên tài liệu của dự án (cần `python3` cho chỉ mục, tệp đi kèm và roadmap), và người duyệt đối chiếu những hàng checker không kiểm; ngoặc sau đó, nếu có, nêu phần checker kiểm khi nó không kiểm hết hàng.

| Giai đoạn | Trả lời câu hỏi | Template | Đầu ra trong dự án | Người duyệt gate |
| --- | --- | --- | --- | --- |
| 0. Intake | Dự án gì, bề mặt nào, quy mô, ràng buộc | `core/00_Project_Intake_Template.md`; Agent Context của giai đoạn | `docs/intake/PROJECT_INTAKE.md`, `CLAUDE.md` khởi tạo | Chủ dự án |
| 1. SRS | WHAT: nghiệp vụ, tác nhân, dữ liệu logic, use case, NFR, danh sách màn hình | SRS của giai đoạn; `core/08_Roadmap_Template.md` khi nhận "Duyệt Gate 1" | `docs/srs/`; `docs/ROADMAP.md` (Intake `1.4.0` trở lên, mục 2.7) | Theo Intake |
| 1W. Wireframe | Mỗi màn hình trông và điều hướng thế nào, FR nào hiện thực ở màn hình nào, hệ thống thiết kế dùng chung | `core/07_Wireframe_Template/` | `docs/wireframes/`, `docs/design-system/` | Theo Intake (Gate 1W) |
| 2. Architecture + ADR | WHERE và HOW: stack, C4, layout, schema, cross-cutting | Architecture của giai đoạn, `core/03_ADR_Template.md`, Agent Context của giai đoạn | `docs/ARCHITECTURE.md`, `docs/adr/`, `CLAUDE.md`, `.claude/rules/` | Theo Intake |
| 3. Spec | Hợp đồng thực thi của một phần việc của đợt; mọi SPEC của đợt được duyệt ở Gate 3 | Spec của giai đoạn | `docs/specs/SPEC_<FEATURE_KEY>.md` | Theo Intake |
| 4a. Implementation Plan | Chia việc của mọi SPEC trong đợt thành pha commit được | `core/05_Implementation_Plan_Template/` | `plans/{YYMMDD-HHmm}-{slug}/` | Theo Intake |
| 4b. Coding TDD | Mã nguồn và test | Không có | Mã nguồn trong File Diff | Không có gate riêng |
| 5. Verify và Sync Docs | Code của một SPEC khớp SPEC chưa, tài liệu còn đúng không | Không có | SPEC `implemented`; plan `completed` khi mọi SPEC của đợt xong; ADR cho deviation | Theo Intake |

Dự án brownfield (Intake `mode: brownfield`) đi thêm các bước ở [brownfield/PLAYBOOK_BROWNFIELD.md](brownfield/PLAYBOOK_BROWNFIELD.md): phục hồi hiện trạng và Gate 0R trước Giai đoạn 1, Gap Analysis sau SRS và trước Giai đoạn 1W, Migration Plan cùng Giai đoạn 2, phụ lục SPEC ở Giai đoạn 3, và phần bổ sung cho prompt, Definition of Ready, Definition of Done ở mọi giai đoạn sau.

"Template của giai đoạn" định nghĩa ở mục 4. Chuẩn tham chiếu: SRS theo ISO/IEC/IEEE 29148:2018, nhóm NFR theo ISO/IEC 25010:2023; Architecture tham khảo ISO/IEC/IEEE 42010:2022 (khái niệm view và rationale ghi bằng ADR; không tuyên bố tuân thủ) và dùng mô hình C4; ADR theo MADR 4.0.0 có điều chỉnh (giữ khóa `deciders`, bố cục mục gọn hơn); Spec dùng từ khóa RFC 2119 và RFC 8174.

### 2.1. Giai đoạn 0: Intake

- Thu thập: định danh dự án; bài toán và mục tiêu đo được; bề mặt (surface) và overlay; greenfield hay brownfield; ước lượng quy mô; ràng buộc (stack bắt buộc, hosting, ngân sách, mốc thời gian và các đợt phát hành dự kiến); tuân thủ (tại Việt Nam: Luật Bảo vệ dữ liệu cá nhân số 91/2025/QH15 và Nghị định 356/2025/NĐ-CP; GDPR; PCI DSS; khác); tích hợp ngoài; đội ngũ và người duyệt từng gate; chỉ số thành công.
- Chốt khối `Routing Decision`: `overlays` theo thứ tự, stack profile cho từng overlay, starter, `mode`, `docs_mode`, người duyệt, Giai đoạn 1W có hay không (mục 2).
- Tạo `CLAUDE.md` khởi tạo từ Agent Context của giai đoạn: mục `Documentation Layout` chép nguyên văn; mục chưa đủ dữ liệu (ví dụ Golden Rules tóm tắt) thay bằng dòng `Hoàn thiện ở Giai đoạn 2.`; không chép Phụ lục A (dùng ở Giai đoạn 2); không để lại dòng đánh dấu, placeholder hay `fill`. Mục đích: bố cục specflow có hiệu lực trước khi sinh tài liệu đầu tiên.
- Dự án brownfield: mục lệnh verify của `CLAUDE.md` khởi tạo không ghi `Hoàn thiện ở Giai đoạn 2.` mà ghi `Hoàn thiện ở Giai đoạn 0R (Prompt B1).`, kể cả khi có profile khớp; không chép lệnh của profile vào mục này. Prompt B1 điền lệnh từ Codebase Summary §7 theo `brownfield/PLAYBOOK_BROWNFIELD.md`, vì lệnh đã chạy được trên repo thắng lệnh của profile.
- Exit gate: Routing Decision đủ mọi trường, không còn câu hỏi `BLOCKING`, chủ dự án duyệt. Câu hỏi chạm hợp đồng chưa có câu trả lời nhưng không chặn routing được ghi `BLOCKING: Không` kèm "trả lời trước Gate 1" (mục 7 quy tắc 3); chúng không chặn Gate 0 và được Prompt 1 chép sang SRS §9.

### 2.2. Giai đoạn 1: SRS

- Làm rõ bài toán, ranh giới In-scope và Out-of-scope, danh sách phân hệ `MOD-NN`.
- Vẽ sơ đồ bối cảnh (`flowchart`), lập ma trận tác nhân `ACT_*`, stakeholders.
- Điền ràng buộc kỹ thuật, giao diện ngoài và mô hình dữ liệu logic theo overlay. Bề mặt có lưu trữ quan hệ MUST có `erDiagram` Crow's foot và Data Dictionary.
- Bề mặt có giao diện: bảng Giao diện người dùng ở §3 liệt kê mọi màn hình, mỗi màn hình một `SCR ID` dạng `SCR-{MOD}-NN` theo CONVENTIONS mục 4. SRS §3 là nguồn duy nhất của danh sách màn hình; Giai đoạn 1W chi tiết hóa, không đặt thêm ID.
- Điền ràng buộc vận hành, bộ nhớ và thích ứng nơi triển khai (§2.4) và chuẩn phải tuân thủ (§2.7).
- Lập Business Rules `BR-NNN`. Mỗi FR có một phát biểu yêu cầu theo mẫu EARS ở CONVENTIONS mục 8, kèm ưu tiên, bản phát hành (nhãn đợt ở Intake), cách kiểm chứng và rủi ro. FR mức Must có use case đủ Pre-conditions, Main flow, Alternative flow, Exception flow kèm mã lỗi cụ thể, Post-conditions.
- NFR có chỉ số, cách đo, ngưỡng và cách kiểm chứng; ma trận Given-When-Then nối `FR → AC`, bảng NFR ghi cách kiểm chứng và bằng chứng của mỗi NFR; TC không ghi ở SRS (CONVENTIONS mục 4).
- Exit gate: mọi tiêu chí ở bảng dưới đạt. Tiêu chí 1 đến 3 lấy từ ISO/IEC/IEEE 29148 §5.2.5 đến 5.2.7 và CONVENTIONS mục 8; người duyệt đọc từng FR và NFR, không chỉ dựa vào checker.

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Mỗi yêu cầu cần thiết (necessary), phù hợp mức SRS (appropriate), không mơ hồ (unambiguous), đầy đủ (complete), nêu một hành vi (singular), khả thi (feasible), kiểm chứng được (verifiable), đúng với nhu cầu (correct), theo đúng mẫu của CONVENTIONS mục 8 (conforming) | Người duyệt đọc §5, §6.1, §7 |
| Tập yêu cầu đầy đủ, nhất quán, khả thi, dễ hiểu và kiểm định được với stakeholder; không còn TBD | §9 không còn câu hỏi `BLOCKING`; §1.2 và §6.1 khớp nhau |
| Phát biểu FR và ô Yêu cầu, Ngưỡng của NFR không dùng từ mơ hồ ở CONVENTIONS mục 8, kể cả từ phụ thuộc ngữ cảnh như "hỗ trợ" không kèm hành vi | Người duyệt; checker trên ví dụ |
| Mỗi FR, BR và NFR có cách kiểm chứng; mỗi NFR áp dụng có dòng ở bảng NFR của §8 | §5, §6.1, §7, §8 |
| Mọi mục áp dụng của §2.4, §2.7 và §3 đã điền, mục không áp dụng ghi N/A kèm lý do | §2, §3; đối chiếu §10.3 |
| Có giao diện: mọi màn hình ở bảng Giao diện người dùng §3 có `SCR ID` không trùng, FR ở cột FR có ở §6.1 | §3, §6.1 |
| SRS `approved`, version `1.0.0` | Frontmatter và Version History |

### 2.2.1. Giai đoạn 1W: Wireframe

Áp cho dự án mà Intake mục 14 ghi Giai đoạn 1W có (mục 2). Chạy sau Gate 1; dự án brownfield chạy sau khi Gate 1 duyệt cả SRS to-be và Gap Analysis, và vẽ giao diện to-be.

- Hệ thống thiết kế trước tiên, theo CONVENTIONS mục 10.7: agent đề xuất 2 đến 3 hướng thị giác, chủ dự án chọn đúng một (một lượt dừng giữa giai đoạn, ngoại lệ của mục 7 quy tắc 3; các hướng ghi vào `DESIGN_SYSTEM.md` `draft` trước khi dừng); rồi viết foundations, token (`tokens.json` và file mode), primitive và danh mục component, pattern, template vào `docs/design-system/` từ `core/07_Wireframe_Template/`, trước khi dựng trang màn hình.
- Nhiệm vụ: vẽ mọi màn hình có ở SRS §3, không thêm hay bớt màn hình, với độ chi tiết theo rủi ro của màn. Màn có thao tác ghi, hiển thị phụ thuộc quyền, hoặc dữ liệu cá nhân có một trang riêng. Màn còn lại được vẽ trong mockup của luồng nó thuộc về ở chỉ mục (một khối low-fi cho mỗi luồng), và danh mục màn hình ghi `Theo luồng` ở cột File HTML; người duyệt Gate 1W đổi được một màn sang trang riêng. Trang riêng `docs/wireframes/SCR-<MOD>-NN.md` từ `core/07_Wireframe_Template/` gồm: mục đích, FR và AC, bố cục low-fi (khối `text` theo CONVENTIONS mục 7), trang chọn đúng một Template và dẫn Pattern, Component đã có trong danh mục hệ thống thiết kế, bảng thành phần, năm trạng thái UI kèm AC, điều hướng vào và ra, ghi chú trợ năng.
- Chỉ mục `docs/wireframes/00_WIREFRAME_INDEX.md`: danh mục màn hình lặp đúng tập `SCR ID` của SRS §3, sơ đồ điều hướng (`flowchart`), bảng đối chiếu có đúng một hàng cho mỗi FR ở SRS §6.1 có ưu tiên khác `Won't` (gộp master và module khi `docs_mode` là `modular`) theo chuỗi `FR → SCR` ở CONVENTIONS mục 4.
- Tiêu chuẩn UI/UX theo CONVENTIONS mục 10: trang có dòng `Màn hình xác thực` và ghi chú trợ năng theo các tiêu chí WCAG 2.2 ở CONVENTIONS mục 10.2 với con số của nền tảng ở `OVERLAY.md`; chỉ mục có bảng đánh giá heuristic (CONVENTIONS mục 10.3) và bảng kiểm mẫu thiết kế lừa người dùng (CONVENTIONS mục 10.4). Người lập wireframe tự đánh giá, sửa vấn đề `Nghiêm trọng` và bỏ mẫu lừa người dùng trước khi trình Gate 1W; câu hỏi tự vấn ở CONVENTIONS mục 10.5 không chặn gate.
- HTML ở `docs/wireframes/html/`: mỗi trang màn hình có một file khi Intake mục 14 ghi Giai đoạn 1W là `Có, kèm HTML đầy đủ` (mặc định); `Có, chỉ Markdown` kèm lý do thì không tạo HTML; màn `Theo luồng` không có HTML. Nội dung và quy tắc ở CONVENTIONS mục 7 và 10.7. Đổi lựa chọn sau Gate 0 thì sửa Intake mục 14 theo mục 8 trước; trang Markdown thắng khi hai bên lệch nhau.
- Chỉ mục và từng trang dùng cùng tập trạng thái với SRS (CONVENTIONS mục 3); version và thay đổi sau khi duyệt theo mục 8.
- Lệch giữa wireframe và SRS (màn hình thêm, bớt hay đổi; FR thiếu; AC không khớp với trạng thái của màn hình) có hai trường hợp:
  - Wireframe vẽ sai hoặc sót so với SRS đã duyệt (trang quên một trạng thái có AC, thiếu thành phần mà FR cần, điều hướng sai): sửa wireframe cho khớp SRS; SRS không đổi.
  - Lập wireframe cho thấy SRS thiếu hoặc sai (cần màn hình mới, FR thiếu, AC không thực hiện được trên màn hình): không sửa wireframe để che chỗ lệch. SRS được sửa theo mục 8 (thêm màn hình mới là MINOR, kèm `SCR ID` mới), người duyệt Gate 1 duyệt lại, rồi mới xét Gate 1W. Dự án brownfield sửa cả Gap Analysis theo mục 8.
- Exit gate Gate 1W: mọi tiêu chí ở bảng dưới đạt. Người duyệt ghi ở Intake mục 9.

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Chỉ mục, mọi trang wireframe và tài liệu hệ thống thiết kế `approved`, version từ `1.0.0` | Frontmatter và Version History; checker trên ví dụ (tài liệu `approved` có version từ `1.0.0`) |
| Tập `SCR ID` ở SRS §3, danh mục màn hình của chỉ mục và bảng đối chiếu trùng nhau; mỗi `SCR ID` có trang hoặc ghi `Theo luồng`; không màn nào có thao tác ghi, quyền hay dữ liệu cá nhân ghi `Theo luồng`, và mỗi màn `Theo luồng` có trong một mockup của luồng | SRS §3, chỉ mục, `docs/wireframes/`; checker trên ví dụ (màn `Theo luồng` có trong mockup, tên và điểm vào không mang từ khóa rủi ro, không SPEC `risk: high` nào dùng nó; người duyệt xét phần còn lại) |
| Bảng đối chiếu phủ mọi FR ở SRS §6.1 có ưu tiên khác `Won't`, mỗi FR đúng một hàng ghi `SCR-*`, `Không có giao diện` kèm lý do, hoặc (brownfield) `Giữ nguyên` kèm dẫn Regression Baseline §5 | Chỉ mục, SRS §6.1; checker trên ví dụ (trừ việc dẫn Regression Baseline §5) |
| Mọi trang dẫn ít nhất một FR có thật; AC mà trang dẫn có ở SRS §8 và thuộc FR của trang | Trang, SRS §6.1, §8; checker trên ví dụ |
| Mỗi trang có đủ năm trạng thái UI; trạng thái không áp dụng ghi N/A kèm lý do | Trang; checker trên ví dụ (có hàng cho đủ năm trạng thái) |
| Khi Intake ghi `Có, kèm HTML đầy đủ`, mỗi trang có file HTML theo CONVENTIONS mục 7 (an toàn, token, `data-cmp`, trạng thái, responsive) | `docs/wireframes/html/`; checker trên ví dụ |
| Mọi lệch đã phát hiện đã xử lý: lỗi vẽ đã sửa ở wireframe; SRS thiếu hoặc sai đã sửa (brownfield: cả Gap Analysis) theo mục 8 và đã duyệt lại | Trang wireframe; Version History của SRS và Gap Analysis |
| Không còn câu hỏi `BLOCKING` ở chỉ mục và các trang | Mục Giả định và câu hỏi mở; checker trên ví dụ (tài liệu `approved`) |
| Chỉ mục: bảng đánh giá heuristic có đúng một hàng cho mỗi khóa `H1` đến `H10` ở CONVENTIONS mục 10.3, không hàng nào có mức `Nghiêm trọng`; vấn đề `Nhỏ` có cách xử lý | Chỉ mục, các trang; checker trên ví dụ (đủ hàng, mức hợp lệ, không còn `Nghiêm trọng` ở chỉ mục `approved`) |
| Chỉ mục: không còn mẫu thiết kế lừa người dùng; bảng kiểm có đúng một hàng cho mỗi khóa `DP1` đến `DP5` ở CONVENTIONS mục 10.4, mọi hàng `Không có` kèm căn cứ | Chỉ mục, các trang, sơ đồ điều hướng; checker trên ví dụ (đủ hàng, mọi hàng `Không có` ở chỉ mục `approved`) |
| Trang: có dòng Màn hình xác thực; mục trợ năng ghi từng tiêu chí ở CONVENTIONS mục 10.2 hoặc N/A kèm lý do | Trang; checker trên ví dụ (dòng Màn hình xác thực, `3.3.8` khi Có) |
| Hướng thị giác: 2 đến 3 hướng có căn cứ, chủ dự án chọn một, lý do ghi ở tài liệu; theme mặc định của thư viện chỉ khi được chọn có chủ đích | Tài liệu hệ thống thiết kế; checker trên ví dụ (hình dạng bảng hướng) |
| Token: `tokens.json` và file mode theo DTCG ở CONVENTIONS mục 10.7, ba tầng; mọi cặp ở bảng tương phản đạt `1.4.3`, `1.4.11` ở mọi mode | `docs/design-system/`; tính lại từng hàng bảng tương phản theo CONVENTIONS mục 10.7 (không tính nhẩm); checker trên ví dụ |
| Danh mục: mỗi trang có đúng một Template, mọi Template, Pattern, Component mà trang dẫn có trong danh mục, danh mục không có component, pattern hay template không dùng | Trang, tài liệu hệ thống thiết kế; checker trên ví dụ |
| HTML của trang: biến CSS trong `:root` khớp token của mode áp cho bề mặt của trang; ngoài `:root`, màu, spacing, radius và `font-size` chỉ dùng `var(--…)` hoặc từ khóa được phép ở CONVENTIONS mục 10.7 | `docs/wireframes/html/`; checker trên ví dụ |

### 2.3. Giai đoạn 2: Architecture + ADR

- Chốt tech stack với phiên bản chính xác: chép bảng ở mục `(Tech Stack)` của stack profile vào ARCHITECTURE §2.1; mọi lệch profile ghi ADR.
- Vẽ C4 Level 1, Level 2, Level 3 hoặc sơ đồ tương đương của bề mặt, và deployment view; cố định layout thư mục kèm bảng `MOD → thành phần → thư mục`.
- Viết schema vật lý đầy đủ (kiểu cụ thể, khóa, index, ràng buộc xóa) nếu bề mặt có lưu trữ.
- Chốt cross-cutting: auth, error envelope, logging, config và env, observability, i18n, cache, job; quy ước giao tiếp và Error Code Registry. Registry nhận toàn bộ mã lỗi ở SRS §6.3.
- Lập bảng `NFR → tactic → ADR`, security architecture, test strategy, CI/CD.
- ADR: kiểu kiến trúc (ARCHITECTURE §1.3) có ADR riêng; mỗi lựa chọn đánh dấu `có ADR` (CONVENTIONS mục 1) và mỗi lệch stack profile được một ADR bao phủ, một ADR có thể gom nhiều lựa chọn cùng chủ đề (ví dụ mô hình token). Lựa chọn không đánh dấu chỉ cần ghi giá trị.
- Hoàn thiện `CLAUDE.md` (lệnh verify, Golden Rules tóm tắt) và `.claude/rules/`; ô Điều kiện pass của hàng Coverage trong bảng lệnh verify ghi con số ngưỡng của `NFR-MAINT` (SRS §7) thay cho câu chung "≥ ngưỡng của `NFR-MAINT`".
- Có Giai đoạn 1W: ghi cách sinh token vào code ở ARCHITECTURE theo overlay và profile; theme của thư viện đặt qua token.
- Exit gate: mọi tiêu chí ở bảng dưới đạt. Người duyệt đối chiếu từng hàng (cột Kiểm chứng theo mục 2).

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Mỗi NFR áp dụng ở SRS §7 có hàng ở ARCHITECTURE §8.1, hoặc một hàng ghi "không cần tactic" kèm lý do | ARCHITECTURE §8.1 đối chiếu SRS §7 |
| Mọi mã lỗi ở SRS §6.3 có trong Error Code Registry kèm HTTP status và ánh xạ theo bề mặt | ARCHITECTURE §7.1; checker trên ví dụ |
| Kiểu kiến trúc, mỗi lựa chọn đánh dấu `có ADR` và mỗi lệch stack profile có ADR `accepted`; mọi ADR được dẫn có file | ARCHITECTURE §1.3, §12, `docs/adr/`; checker trên ví dụ (ADR được dẫn có file) |
| Tech stack ở §2.1 khớp mục `(Tech Stack)` của stack profile, hoặc lệch có ADR | ARCHITECTURE §2.1 |
| Mỗi phân hệ ở SRS §1.2 có thành phần và thư mục ở bảng `MOD → thành phần → thư mục` | ARCHITECTURE §4 |
| Schema khớp mô hình dữ liệu logic; tập giá trị của enum khớp state machine của SRS | ARCHITECTURE §5, SRS §4, §10.1; checker trên ví dụ (enum khớp state machine) |
| Có Giai đoạn 1W: mỗi `SCR-*` của chỉ mục wireframe có hàng ở bảng route (web) hoặc bảng điều hướng (mobile) của ARCHITECTURE, cột `SCR ID` | ARCHITECTURE §3, chỉ mục wireframe |
| Không còn câu hỏi `BLOCKING`; ARCHITECTURE `approved`, mọi ADR liên quan `accepted` | Frontmatter; mục Giả định và câu hỏi mở; checker trên ví dụ (câu hỏi `BLOCKING` trong tài liệu `approved`) |
| Có `docs/design-system/` (trang từ template `1.4.0`, COMPATIBILITY mục 1): ARCHITECTURE ghi nguồn token `docs/design-system/tokens.json` và file ánh xạ token trong code | ARCHITECTURE, mục quy ước giao diện |

### 2.4. Giai đoạn 3: Spec

- Mỗi tính năng một SPEC: mục tiêu, Core Invariant, out-of-scope, bảng FR, AC, BR được đáp ứng.
- Theo đợt: Giai đoạn 3 viết mọi SPEC của một đợt, mỗi lượt một SPEC (Prompt 3). SPEC ghi đợt ở khóa frontmatter `release` (CONVENTIONS mục 3); mọi FR ở SPEC §1.5 có Bản phát hành bằng đợt đó. Dự án nhiều bề mặt có SPEC riêng cho mỗi bề mặt mà FR của đợt cần. SPEC của bề mặt có giao diện dẫn `SCR-*` và trang wireframe ở bảng Màn hình của §3, không định nghĩa lại màn hình.
- Đọc mã nguồn hiện có của phân hệ (theo ARCHITECTURE §4) để khóa File Diff (sửa, tạo mới, migration) và bảng MUST NOT touch.
- Câu hỏi chỉ trả lời được bằng cách chạy mã (câu SQL chưa chạy trên cơ sở dữ liệu thật, hành vi của thư viện, thời gian chờ chưa đo) không được giữ lại qua nhiều lượt: nó thành một spike, là pha đầu của SPEC trong plan, có hạn thời gian và một câu hỏi cụ thể. Kết quả spike ghi ở `plans/reports/`, rồi SPEC sửa theo mục 8 và câu hỏi được đóng. Câu hỏi như vậy ghi `BLOCKING: Không` kèm "trả lời bằng spike" nên không chặn Gate 3.
- Nền tảng dùng chung của đợt: mỗi bề mặt có nền tảng dùng chung riêng (khung dự án, cấu hình, thư viện dùng chung và hạ tầng test của bề mặt đó). Nền tảng của một bề mặt nằm trong File Diff §2 của SPEC đầu tiên của bề mặt đó trong đợt; dự án một bề mặt có đúng một SPEC như vậy. SPEC đầu tiên của cả đợt là SPEC không tiêu thụ contract của SPEC khác cùng đợt, nên không trái quy tắc thứ tự contract ở mục 2.5. Pha của SPEC mang nền tảng đứng trước pha của SPEC khác cùng bề mặt trong plan của đợt (mục 2.5). SPEC viết sau của cùng bề mặt không lặp lại các file đó, và cần sửa file nào trong số đó thì ghi file ấy ở §2.1 (File sửa) của mình.
- Điền contract theo overlay, migration, thuật toán có sơ đồ tuần tự (`sequenceDiagram`), ranh giới transaction, cập nhật nguyên tử và idempotency, authorization matrix, event contract, observability, rollout.
- Bảng test gắn `AC-*`, `INV-*`, `NFR-*` với `TC-*`; mỗi Core Invariant có một test `CONC` theo dạng overlay định nghĩa. TC lấy số kế tiếp ở `docs/INDEX.md` mục 3 (CONVENTIONS mục 4).
- Tính năng gọi mô hình ngôn ngữ (overlay `ai-llm-app`): mỗi prompt mới hoặc đổi nội dung có Prompt Spec `docs/prompts/PROMPT_<NAME>.md` từ `overlays/ai-llm-app/Prompt_Spec_Template.md` và bộ dữ liệu đánh giá trong `evals/`, viết trước SPEC; ID của prompt đã đặt ở SRS §4.1. SPEC tham chiếu Prompt Spec, không chép lại nội dung prompt.
- Exit gate của mỗi SPEC: mọi tiêu chí ở bảng dưới đạt.

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Mọi FR, AC, BR, NFR ở §1.5 tồn tại ở SRS | SPEC §1.5; checker trên ví dụ |
| Mỗi AC ở §1.5 có TC ở §9; mỗi Core Invariant có test `CONC` | SPEC §9; checker trên ví dụ |
| Mỗi NFR ở §1.5 kiểm bằng Test có TC ghi tên NFR ở §9 của SPEC này hoặc của một SPEC khác của dự án; NFR kiểm bằng cách khác có bằng chứng ghi ở SRS §8 | SPEC §9, SRS §8; checker trên ví dụ |
| Mỗi file test ở §9 nằm trong File Diff | SPEC §2, §9; checker trên ví dụ |
| TC không trùng với SPEC khác; mọi mã lỗi của SPEC có trong Error Code Registry | SPEC §9, ARCHITECTURE §7.1; checker trên ví dụ |
| Prompt Spec của mọi prompt mà SPEC dùng `approved`; không còn câu hỏi `BLOCKING`; SPEC `approved` | Frontmatter; mục Giả định và câu hỏi mở |
| Có Giai đoạn 1W: mỗi màn hình ở bảng Màn hình của §3 dẫn `SCR-*` có ở chỉ mục wireframe | SPEC §3, chỉ mục wireframe |

Gate 3 theo đợt đạt khi mọi SPEC của đợt đạt bảng trên và mọi tiêu chí ở bảng dưới đạt. Người duyệt kiểm mọi hàng; checker trên ví dụ chỉ kiểm hàng cuối, qua khóa `release` của SPEC, nên không cần plan.

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Mọi FR có Bản phát hành bằng đợt nằm trong SPEC §1.5 của ít nhất một SPEC `approved` của đợt | Người duyệt đối chiếu SRS §6.1 với SPEC §1.5 |
| Dự án nhiều bề mặt: mỗi bề mặt mà FR của đợt cần có SPEC của đợt; mỗi `SCR-*` mà FR của đợt dẫn có SPEC của bề mặt giao diện dẫn nó | Người duyệt; SPEC §3, chỉ mục wireframe |
| Mọi SPEC của đợt có `release` bằng đợt; mọi FR mà SPEC của đợt dẫn ở §1.5 có Bản phát hành bằng đợt | Frontmatter và §1.5 của SPEC, SRS §6.1; checker trên ví dụ (SPEC có khóa `release`) |

### 2.5. Giai đoạn 4: Implementation Plan và Coding TDD

- 4a. Lập plan trong `plans/{YYMMDD-HHmm}-{slug}/` theo `core/05_Implementation_Plan_Template/`. Mỗi pha nêu: tập con File Diff, TC phải pass, lệnh verify, commit message; mỗi pha kết thúc xanh và commit được. Thứ tự mặc định (overlay có thể thay): migration, kiểu dùng chung và contract; logic nghiệp vụ (test đỏ rồi xanh trong cùng pha); lớp giao tiếp (controller, màn hình) và e2e. Dừng ở Gate 4.
- Plan theo đợt: một plan cho mọi SPEC của đợt, định dạng ở CONVENTIONS mục 9 (`release`, `spec_ids`, `spec_id` ở mỗi pha). Pha nhóm theo SPEC, pha của một SPEC đứng liền nhau; SPEC cung cấp contract đứng trước SPEC tiêu thụ contract đó. Mỗi SPEC trong `spec_ids` có khóa `release` thì khóa đó bằng `release` của plan. Ở mỗi bề mặt, pha của SPEC mang nền tảng của bề mặt đó (mục 2.4) đứng trước pha của SPEC khác cùng bề mặt; SPEC đầu tiên của đợt đứng được ở đầu plan (mục 2.4). SPEC sau được sửa file thuộc File Diff của SPEC trước cùng đợt: file đó ghi ở SPEC §2.1 (File sửa) của SPEC sau, và pha của SPEC sau đứng sau pha tạo file.
- Nhánh: mỗi pha hoặc nhóm pha một nhánh từ nhánh chính, merge xong mới mở nhánh phụ thuộc; không xếp chồng nhánh, vì mỗi lần sửa nhánh dưới phải gộp và verify lại mọi nhánh trên. Pha độc lập chạy song song ở worktree riêng.
- Exit gate Gate 4: mọi tiêu chí ở bảng dưới đạt.

| Tiêu chí | Kiểm chứng |
| --- | --- |
| Plan đúng định dạng ở CONVENTIONS mục 9 | `plans/`; checker trên ví dụ |
| Plan của đợt phủ mọi SPEC của đợt: `spec_ids` gồm mọi SPEC `approved` của đợt, mỗi SPEC trong đó có ít nhất một pha và khóa `release` (nếu có) khớp quy tắc ở mục 2.5 | `plan.md`, file pha, `docs/specs/`; checker trên ví dụ (mỗi phần tử của `spec_ids` có file SPEC, `release` bằng của plan và có pha; SPEC dẫn FR của đợt có trong `spec_ids`) |
| Pha của mỗi SPEC phủ hết File Diff và mọi TC ở §9 của SPEC đó | File pha, SPEC §2, §9 |
| Definition of Ready (mục 10.1) đạt | Bảng DoR |

- 4b. Thực thi từng pha theo thứ tự, lần lượt từng SPEC của plan: chạy test đỏ trước, viết code tới khi xanh, refactor, chạy verify, cập nhật checkbox của pha, commit một lần mỗi pha theo Conventional Commits bằng tiếng Anh.
- Chỉ sửa file trong File Diff của SPEC mà pha thuộc về (`spec_id` của pha). Cần file khác thì dừng và đề xuất sửa SPEC.
- Có roadmap (mục 2): thứ tự pha do plan quyết; roadmap kiểm không việc nào bị bỏ qua. Trước mỗi pha, agent đọc `docs/ROADMAP.md`: pha kế tiếp của plan không được nhảy qua dòng, tức không có dòng `Chưa làm` nào đứng trước các dòng mà pha đó hiện thực; dòng đầu tiên còn `Chưa làm` hay `Đang làm` mà chưa có Pha thì dừng và báo (FR chưa có SPEC hay pha). Khi bắt đầu pha, mọi dòng mà pha hiện thực chuyển `Đang làm` và mục 1 ghi chúng cùng SPEC, pha. Một dòng chuyển `Xong` khi mọi pha của mọi SPEC ở cột SPEC của nó đã xong và verify đạt; mục 4 có hàng bằng chứng (TC đã pass, commit pha cuối) và mục 1 cập nhật số đếm. Sửa roadmap sau commit pha cuối được commit cùng tài liệu ở Prompt 6. Ý tưởng hay yêu cầu phát sinh ghi vào mục 3 của roadmap, không làm. Giới hạn số lần sửa theo mục 7 quy tắc 11.

### 2.6. Giai đoạn 5: Verify và Sync Docs

- Giai đoạn 5 chạy cho từng SPEC khi mọi pha có `spec_id` của SPEC đó xong; Gate 5 xét theo SPEC. Khoảng commit của SPEC đi từ cha của commit pha đầu tiên tới commit pha cuối cùng có `spec_id` đó.
- Chạy đủ cổng verify ở mục 11; đối chiếu code với SPEC (contract, thuật toán, mã lỗi) và `git diff` trên khoảng commit của SPEC với File Diff của SPEC đó.
- Cập nhật: SPEC `implemented`, các pha của SPEC sang `done`, plan `completed` khi mọi SPEC trong `spec_ids` đã `implemented` (nếu không, `in-progress`), bảng test trong SPEC §9 ghi đúng file test và tên test, version tài liệu tăng theo mục 8. Tính năng gọi mô hình ngôn ngữ: kết quả của job đánh giá ghi vào Prompt Spec §9.1; việc ghi này không đổi prompt nên không tăng version của Prompt Spec.
- Mọi khác biệt so với SPEC hoặc ARCHITECTURE phải có ADR.
- Đối soát roadmap (có roadmap, mục 2): chạy `specflow/scripts/check-templates.sh --project .` ở đây và ở Prompt Resume; nó so roadmap với SRS, SPEC và plan theo CONVENTIONS mục 11. Agent chỉ tự kiểm hai điều script không thấy: commit ở mục 4 có trong `git log`, tag ở mục 4 và 5 có trong `git tag`. Dán kết quả vào báo cáo dừng. Lệch thì báo vị trí, không tự sửa SRS hay SPEC; roadmap sai so với SRS thì sửa roadmap. Đợt đã đóng (plan `completed`): dòng chưa `Đã xác nhận` được báo kèm lý do.
- Thứ tự đóng một SPEC theo `risk` của nó (CONVENTIONS mục 3; SPEC không ghi `risk` là `high`). `high`: Prompt 5 là review độc lập bằng agent ngữ cảnh mới, kèm thử đột biến cho mọi điều kiện phân quyền và phạm vi, rồi Prompt 6 riêng cho SPEC đó. `normal`: verify theo checklist (lệnh verify, File Diff, TC ở §9) và đồng bộ tài liệu trong cùng một lượt, gộp được cho các SPEC `normal` cùng đợt; review ở cấp pull request. Sau đó dừng chờ "Duyệt Gate 5"; Gate 5 xét sau Prompt 6 vì một phần Definition of Done hoàn tất ở Prompt 6.
- Exit gate: Definition of Done (mục 10.2) đạt.

### 2.7. Cách duyệt gate (Gate Approval)

Người duyệt của mỗi gate ghi ở bảng Gate của Intake mục 9. Agent dừng ở gate, gửi danh sách file đã tạo hoặc sửa cùng checklist exit gate đã tự kiểm (mục 7 quy tắc 9). Một lượt được trình nhiều gate khi một thay đổi chạm nhiều tài liệu (mục 8); lời trình nêu từng gate. Người duyệt đối chiếu bảng exit gate; đạt thì gửi "Duyệt Gate N" kèm tên mình, chưa đạt thì gửi lại các hàng chưa đạt. Khi nhận lời duyệt, agent chạy `python3 specflow/scripts/gate.py . approve --gate N --approver "tên người duyệt"` kèm đường dẫn các tài liệu của gate (thêm `--bump` và `--note` khi duyệt thay đổi của tài liệu đã duyệt, mục 8) và không sửa tay các chỗ script ghi. Script đặt `approved` (ADR liên quan ở Gate 2: `accepted`; plan ở Gate 4 giữ `pending` vì bảng trạng thái của plan ở CONVENTIONS mục 3 không có `approved`), đặt `version: 1.0.0` ở lần duyệt đầu, ghi một dòng lịch sử, ghi `docs/gates/GATE-N.md` và dựng lại `docs/INDEX.md`; nó từ chối cả lượt khi một tài liệu được trình còn câu hỏi `BLOCKING`, sai trạng thái, hoặc bị checker báo lỗi (pha tính theo plan). Việc ở roadmap, ở pha của plan và tag của Gate 5 vẫn do agent làm. Agent MUST NOT tự đặt `approved` hay `accepted` khi chưa nhận lời duyệt (nguyên tắc 2, mục 1.2).

Có roadmap (mục 2), lời duyệt gate còn kéo theo việc ở `docs/ROADMAP.md` (CONVENTIONS mục 11):

| Nhận | Việc ở roadmap |
| --- | --- |
| "Duyệt Gate 1" | Dựng roadmap từ `core/08_Roadmap_Template.md`: mục 1 một hàng cho mỗi đợt theo thứ tự ở Intake, mục 2.1 một dòng cho mỗi FR có Ưu tiên khác `Won't`, mục 2.2 một dòng cho mỗi NFR mức Must với Đợt đóng là đợt đầu, cột SPEC và Pha ghi `Chưa có`, mọi dòng `Chưa làm`. Thứ tự lúc này đã định sẵn bởi SRS (đợt, ưu tiên, thứ tự ở §6.1), nên không cần duyệt riêng |
| "Duyệt Gate 3" | Điền cột SPEC theo §1.5 của các SPEC vừa duyệt, cả cột SPEC của mục 2.2 |
| "Duyệt Gate 4" | Điền cột Pha theo plan, xếp lại mục 2.1 theo thứ tự pha và sắp lại cột SPEC của mục 2.2 theo thứ tự mới |
| "Duyệt Gate 5" của một SPEC | Chỉ làm khi SPEC đã `implemented` (Prompt 6 đã chạy); chưa thì báo và chờ. Tạo annotated tag trên commit pha cuối của SPEC theo dòng Định dạng tag ở Intake mục 14 (lần qua Gate 5 thứ hai trở đi của cùng SPEC thêm hậu tố `-2`, `-3`), chỉ push khi người duyệt cho phép; thêm một hàng ở mục 5. Mỗi dòng `Xong` mà mọi SPEC ở cột SPEC của nó đã `implemented` chuyển `Đã xác nhận`, Tag ở mục 4 ghi tag vừa tạo. Dòng NFR `Xong` có Đợt đóng là đợt của SPEC và mọi dòng FR của đợt đó đã `Đã xác nhận`: chuyển `Đã xác nhận` cùng tag đó. Commit các sửa này thành một commit tài liệu riêng sau tag |

Agent MUST NOT đặt `Đã xác nhận` khi chưa nhận "Duyệt Gate 5" của SPEC chứa dòng đó.

## 3. Định tuyến overlay (Overlay Routing)

Intake khai báo bề mặt của dự án; mỗi bề mặt ánh xạ tới một overlay và một stack profile khớp, hoặc `none` khi không profile nào khớp. Một dự án có thể có nhiều bề mặt.

Profile khớp. Một stack profile khớp với bề mặt khi mọi thành phần nền mà mục `(Tech Stack)` của profile chốt đều trùng với lựa chọn của dự án (greenfield: ràng buộc ở Intake mục 6; brownfield: mã đang chạy):

- cùng ngôn ngữ;
- cùng major version của framework chính;
- cùng major version của lớp truy cập dữ liệu, tức ORM, SDK hay kho lưu trữ mà mục Tech Stack của profile nêu;
- cùng engine lưu trữ, khi bề mặt có lưu trữ;
- cùng bộ chạy test.

Major version theo SemVer; thành phần còn ở `0.x` thì minor đứng vị trí major (FastAPI `0.139` và `0.141` khác major). Engine lưu trữ và bộ chạy test chỉ xét tên, khác version thì là lệch như dưới. Thành phần nền mà mục Tech Stack của profile không nêu thì không xét. Khác biệt còn lại (cây thư mục, minor hay patch version, cách xác thực, envelope lỗi, thư viện phụ) không làm mất khớp: dự án greenfield giữ khác biệt nào thì ghi lệch có ADR ở Giai đoạn 2 (mục 2.3); dự án brownfield xử lý theo `brownfield/PLAYBOOK_BROWNFIELD.md` mục 5.5. Không profile nào khớp thì ô Stack profile ở Intake mục 14 ghi `none`, cột Lý do chọn nêu thành phần nền không khớp, và áp quy tắc 5. Để quyết điều này ở Giai đoạn 0, agent đọc mục `(Tech Stack)` của các profile thuộc overlay đang cân nhắc (mục 6).

| Bề mặt | Chọn khi dự án có | Overlay | Stack profile có sẵn | Trạng thái |
| --- | --- | --- | --- | --- |
| `backend-api` | API HTTP hoặc RPC, cơ sở dữ liệu, background job | [overlays/backend-api/](overlays/backend-api/OVERLAY.md) | [node-nestjs-prisma](overlays/backend-api/stack-profiles/node-nestjs-prisma.md), [python-fastapi-sqlalchemy](overlays/backend-api/stack-profiles/python-fastapi-sqlalchemy.md) | Có |
| `frontend-web` | Giao diện web chạy trên trình duyệt | [overlays/frontend-web/](overlays/frontend-web/OVERLAY.md) | [nextjs-app-router](overlays/frontend-web/stack-profiles/nextjs-app-router.md) | Có |
| `mobile-app` | Ứng dụng cài trên điện thoại hoặc máy tính bảng, làm việc khi mất mạng | [overlays/mobile-app/](overlays/mobile-app/OVERLAY.md) | [react-native-expo](overlays/mobile-app/stack-profiles/react-native-expo.md) | Có |
| `ai-llm-app` | Tính năng gọi mô hình ngôn ngữ lớn: phân loại, trích xuất, tóm tắt, trả lời theo tài liệu, agent gọi công cụ | [overlays/ai-llm-app/](overlays/ai-llm-app/OVERLAY.md) | [typescript-anthropic-sdk](overlays/ai-llm-app/stack-profiles/typescript-anthropic-sdk.md) | Có |
| Bề mặt khác | Bề mặt chưa có overlay | Không có | Không có | Ghép thủ công, xem quy tắc 4 |

| Tổ hợp `overlays` | Starter | Trạng thái |
| --- | --- | --- |
| `[backend-api]` | [starters/backend-api/](starters/backend-api/README.md) | Có |
| `[backend-api, frontend-web]` | [starters/fullstack-web/](starters/fullstack-web/README.md) | Có |
| Tổ hợp khác | Không có, ghép thủ công theo mục 4 | Không áp dụng |

Quy tắc định tuyến:

1. Đọc khối `Routing Decision` của Intake: `overlays` (có thứ tự), stack profile của từng overlay, `starter`, `mode`, `docs_mode`.
2. Có starter cho đúng tổ hợp thì dùng file của starter (đã ghép core với overlay, chưa gắn profile). Template dùng chung (Intake, Wireframe, ADR, Implementation Plan) lấy thẳng từ `core/`.
3. Không có starter thì ghép thủ công theo mục 4.
4. Bề mặt chưa có overlay: agent ghi đề xuất nội dung cho 11 slot vào `Assumptions & Open Questions` của Intake, chủ dự án duyệt ở Gate 0; từ đó ghép như overlay bình thường.
5. Overlay có nhưng không có stack profile khớp (Intake ghi `none`): agent đề xuất giá trị placeholder và nội dung profile trong ARCHITECTURE §2 kèm ADR; duyệt ở Gate 2. Dự án brownfield lấy đề xuất từ Codebase Summary §7 và As-Is Architecture §2. Cách ghép tài liệu khi không có profile theo CONVENTIONS mục 2.

## 4. Quy tắc ghép và checklist "Overlay đã áp" (Assembly)

Template của giai đoạn là file tương ứng trong `starters/<starter>/` nếu Routing Decision có starter (SRS, ARCHITECTURE, SPEC theo bề mặt, `CLAUDE.md.template`); nếu không có starter, là file core ghép với overlay. Agent Context không có starter thì dùng `core/06_Agent_Context_Template.md` cộng `agent-rules/` của từng overlay. Ghép theo [CONVENTIONS.md](CONVENTIONS.md) mục 2:

1. Chép template (file starter, hoặc file core) sang đường dẫn đích.
2. Không có starter: với mỗi dòng `<!-- SLOT: ... -->`, đọc `OVERLAY.md` rồi lấy khối SLOT-CONTENT cùng ID của từng overlay theo thứ tự `overlays`; một overlay thì chèn nguyên văn, nhiều overlay thì mỗi bề mặt có heading tên bề mặt và hạ cấp heading bên trong.
3. Áp stack profile của từng bề mặt: thay mỗi dòng `<!-- PROFILE-SLOT: ... -->` bằng khối PROFILE-CONTENT cùng ID (hạ cấp heading nếu bề mặt đã bị hạ cấp ở bước 2, thay phần mẫu có chú thích `fill` bằng nội dung thật); thay placeholder nguồn `Profile` bằng bảng "Giá trị placeholder" của profile. Bề mặt có stack profile `none`: theo CONVENTIONS mục 2.
4. Thay placeholder còn lại, điền nội dung theo `<!-- fill: ... -->`.
5. Frontmatter: `status: draft`, `version: 0.1.0`, `parent`, `overlays`, `assembled_from` (nguồn của starter hoặc core và overlay, cộng stack profile); bề mặt không có profile thì ghi tên bề mặt vào `stack_profile_none` (CONVENTIONS mục 3).
6. Chạy lệnh kiểm tra sót, kết quả MUST rỗng:

```bash
grep -rnE '<!-- (SLOT|PROFILE-SLOT|slot-hint|fill)[ :-]|\{\{[A-Z][A-Z0-9_]*\}\}|"\$description": *"fill:' docs/ plans/ CLAUDE.md .claude/ 2>/dev/null
```

Checklist "Overlay đã áp", tự kiểm ở exit gate của giai đoạn tương ứng; một ô chỉ tick khi cả nội dung overlay và nội dung profile đã vào tài liệu:

| Slot | Tài liệu đích | Giai đoạn | Đã áp |
| --- | --- | --- | --- |
| `srs.constraints.technical` | SRS §2.5 | 1 | [ ] |
| Mục `(Tech Stack)` của stack profile | ARCHITECTURE §2.1 | 2 | [ ] |
| `srs.external-interfaces` | SRS §3 | 1 | [ ] |
| `srs.data-model` | SRS §4.1 | 1 | [ ] |
| `arch.views` | ARCHITECTURE §3 | 2 | [ ] |
| `arch.layout` | ARCHITECTURE §4 | 2 | [ ] |
| `arch.schema` | ARCHITECTURE §5 | 2 | [ ] |
| `arch.conventions` | ARCHITECTURE §7 | 2 | [ ] |
| `arch.deployment` | ARCHITECTURE §8 | 2 | [ ] |
| `playbook.verify-commands` | `CLAUDE.md` mục lệnh verify | 0 hoặc 2; brownfield 0R (Prompt B1) | [ ] |
| `spec.contract` | SPEC §3 | 3 | [ ] |
| `spec.test-types` | SPEC §9 | 3 | [ ] |

## 5. Lưu trữ tài liệu theo quy mô (Docs by Scale)

Chọn ở Intake (`docs_mode`), đường dẫn theo [CONVENTIONS.md](CONVENTIONS.md) mục 6.

| Chế độ | Khi nào | Cấu trúc SRS |
| --- | --- | --- |
| `modular` | Từ 5 phân hệ, hoặc trên 20 đơn vị giao tiếp (endpoint, màn hình, lệnh), hoặc SRS dự kiến vượt 800 dòng | `docs/srs/00_SRS_MASTER.md` giữ §1 đến §5, §7, mô hình dữ liệu chung; mỗi `docs/srs/SRS_MODULE_<NAME>.md` giữ FR, use case và ma trận §8 của một phân hệ, `parent` trỏ về master |
| `monolithic` | Không thỏa điều kiện nào của `modular` | Một file `docs/srs/SRS.md` |

Đếm phân hệ: phần cross-cutting (xác thực, giới hạn tần suất, logging) và thư viện dùng chung không tính là phân hệ, trừ khi có dữ liệu riêng hoặc API riêng. Dự án brownfield chốt `docs_mode` ở Gate 0 theo ước lượng ở Intake mục 5, rồi xét lại ở Gate 0R khi Codebase Summary §3 đã chốt mã phân hệ. Kết quả đổi thì Intake mục 5 và mục 14 được cập nhật như một thay đổi MINOR theo mục 8; người duyệt Gate 0 ghi ở Intake mục 9 duyệt lại Intake cùng lúc duyệt Gate 0R.

Quy mô `small` (Intake mục 14, template Intake `1.5.0` trở lên; tối đa 15 FR, một người duyệt mọi gate, không có ràng buộc tuân thủ): bộ tài liệu giữ nguyên, số lần dừng giảm. Intake và SRS được soạn trong một lượt và trình gộp Gate 0 với Gate 1; ARCHITECTURE, các SPEC `risk: normal` của đợt đầu và plan được soạn trong một lượt và trình gộp Gate 2, 3, 4. ADR chỉ viết cho quyết định khó đảo ngược (đổi stack, mô hình dữ liệu, cách xác thực); quyết định khác ghi một dòng ở ARCHITECTURE §2. SPEC `risk: high` vẫn dừng ở Gate 3 riêng. Dự án vượt ngưỡng trong lúc làm thì sửa Quy mô về `standard` theo mục 8.

ARCHITECTURE luôn là một file. SPEC luôn là một file cho mỗi tính năng. Hai loại tài liệu này có trần kích thước ở CONVENTIONS mục 7 (SPEC 500 dòng, ARCHITECTURE 800 dòng); khối máy đọc dài nằm ở tệp đi kèm theo cùng mục đó. Mục tiêu của chế độ `modular` và của trần kích thước: agent chỉ nạp phần liên quan, tránh tràn context và suy diễn sai.

## 6. Danh mục nạp ngữ cảnh (Context Loading Manifest)

Agent nạp đúng những gì giai đoạn cần. "Của giai đoạn" theo định nghĩa ở mục 4; "profile" là stack profile của các bề mặt đã chọn.

| Giai đoạn | MUST đọc | MUST NOT đọc |
| --- | --- | --- |
| 0. Intake | Brief, `specflow/PLAYBOOK.md` mục 1 đến 7, `specflow/CONVENTIONS.md` mục 1 đến 7, `specflow/core/00_Project_Intake_Template.md`; trước khi chốt routing: mục `(Tech Stack)` của mọi stack profile thuộc overlay đang cân nhắc, để xét profile khớp (mục 3); sau khi chốt routing: Agent Context của giai đoạn, `OVERLAY.md` và profile đã chọn | File section của overlay và phần còn lại của profile khi chưa chốt routing, template SRS, Architecture, Spec |
| 1. SRS | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.2 và 4 đến 7, `specflow/CONVENTIONS.md` mục 1 đến 8, Intake, SRS của giai đoạn, `OVERLAY.md` | Overlay và profile không được chọn, profile (SRS không dùng placeholder nguồn `Profile`), template Architecture và Spec, mã nguồn |
| 1W. Wireframe | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.2.1 và 4 đến 8, `specflow/CONVENTIONS.md` mục 1, 3, 4, 6, 7, 10, Intake, SRS (§1.2, §2.2, §2.4, §2.5, §3, §4, §5, §6, §7, §8, §9, §10.2; master và mọi module nếu `modular`), `specflow/core/07_Wireframe_Template/`, `OVERLAY.md` của bề mặt có giao diện, `docs/design-system/` khi sửa lại | Stack profile, file section của overlay, template Architecture và Spec, mã nguồn |
| 2. Architecture + ADR | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.3 và 4 đến 7, `specflow/CONVENTIONS.md` mục 1 đến 7 (thêm mục 10.7 khi có `docs/design-system/`), Intake, SRS (master và mô hình dữ liệu chung nếu `modular`; khi đó thêm §6.3 của mọi file module), chỉ mục wireframe `docs/wireframes/00_WIREFRAME_INDEX.md` khi có Giai đoạn 1W, `docs/design-system/tokens.json`, file mode và mục Token của `DESIGN_SYSTEM.md` khi có `docs/design-system/`, Architecture và Agent Context của giai đoạn, `OVERLAY.md`, profile, `specflow/core/03_ADR_Template.md`, `specflow/overlays/<surface>/agent-rules/` khi không có starter | Overlay và profile không được chọn, template Spec, mã nguồn |
| 3. Spec | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.4 và 4 đến 7, `specflow/CONVENTIONS.md` mục 1, 3, 4, `docs/ARCHITECTURE.md`, phần SRS chứa FR của SPEC đang viết, cột FR ID và Bản phát hành ở SRS §6.1 (master và mọi module khi `modular`), frontmatter của mọi SPEC trong `docs/specs/` và §1.5 của SPEC thuộc đợt (khóa `release`; SPEC không có khóa thì đọc §1.5 của nó, đợt theo Bản phát hành của FR, mục 2.4), `docs/INDEX.md` mục 3 (số TC kế tiếp, CONVENTIONS mục 4), chỉ mục wireframe và trang wireframe của các `SCR-*` mà FR đang viết dẫn, mục danh mục hệ thống thiết kế (`CMP-*`, `PAT-*`, `TPL-*`) mà các trang đó dẫn, ADR được tham chiếu, Spec của giai đoạn, profile, mã nguồn hiện có của phân hệ theo ARCHITECTURE §4; overlay `ai-llm-app`: Prompt Spec của các prompt tính năng dùng, hoặc `specflow/overlays/ai-llm-app/Prompt_Spec_Template.md` khi viết Prompt Spec mới | Phần còn lại của SRS module khác, nội dung SPEC khác ngoài frontmatter, §1.5 và cột TC ID ở §9 (trừ SPEC phụ thuộc ghi trong §1), trang wireframe khác, mã nguồn của phân hệ khác |
| 4a. Plan | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.4, 2.5, 4, 6, 7, 10.1, `specflow/CONVENTIONS.md` mục 3, 4, 9, mọi SPEC trong `spec_ids` của đợt, hàng SRS §6.1 của FR có Bản phát hành bằng đợt và hàng SRS §8 của AC mà SPEC của đợt dẫn; có Giai đoạn 1W: chỉ mục wireframe và trang của các `SCR-*` mà SPEC của đợt dẫn ở §3; ARCHITECTURE §1, §4, §5, §7, `specflow/core/05_Implementation_Plan_Template/` | SRS toàn văn (chỉ đọc các hàng đã nêu), trang wireframe không được SPEC của đợt dẫn, SPEC ngoài đợt |
| 4b. Coding | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 7, plan và pha đang làm, các mục ghi ở `Đọc trước` của pha (pha từ template pha `1.3.0` trở lên; pha cũ hơn đọc SPEC theo `spec_id` của pha và ARCHITECTURE §1, §4 đến §7), file trong File Diff, file phụ thuộc ghi ở SPEC §1, mục danh mục hệ thống thiết kế mà trang wireframe của SPEC dẫn, `docs/design-system/tokens.json` khi pha có file token trong File Diff; overlay `ai-llm-app`: Prompt Spec của các prompt SPEC dùng | File ngoài File Diff và ngoài danh sách phụ thuộc; file trong `specflow/` ngoài PLAYBOOK và CONVENTIONS |
| 5. Verify và Sync | `CLAUDE.md`, `specflow/PLAYBOOK.md` mục 2.6, 2.7, 4, 8, 10.2, 11, `specflow/CONVENTIONS.md` mục 9, SPEC đang đóng, plan, `git diff` trên khoảng commit của SPEC, kết quả verify, ARCHITECTURE §2.1, §12, ADR liên quan, hàng `NFR-MAINT` của SRS §8 (ngưỡng coverage); khi Sync Docs: Prompt Spec của các prompt SPEC dùng (overlay `ai-llm-app`: §9.1 để ghi kết quả đánh giá), tài liệu gốc cần sửa theo mục 8 và `specflow/core/03_ADR_Template.md` khi tạo ADR; brownfield: `specflow/brownfield/PLAYBOOK_BROWNFIELD.md` mục 7 | Không giới hạn thêm |
| Resume | `CLAUDE.md`, trang ở `docs/gates/` có hàng mang ngày mới nhất và bản ghi trạng thái phiên trước ở `plans/reports/` khi có, `specflow/PLAYBOOK.md` mục 2 (phần mở đầu và tiểu mục của giai đoạn đang dở), 2.7, 7, mục của giai đoạn đang dở ở `specflow/PROMPTS.md`, tài liệu hoặc plan đang dở; pha đang dở thì thêm các mục ở `Đọc trước` của pha | Tài liệu thượng nguồn toàn văn (đọc theo mục, qua `docs/INDEX.md`), tài liệu của giai đoạn đã đóng |

Dự án có Intake tạo từ template Intake cũ hơn `1.4.0`, hoặc có wireframe từ template chỉ mục cũ hơn `1.3.0` hay template trang cũ hơn `1.4.0`: mọi hàng nạp thêm `specflow/COMPATIBILITY.md`.

Lượt trình gộp (mục 5 quy mô `small`, mục 8 bước 8) nạp các hàng của những giai đoạn nó làm; khi cột MUST NOT của một hàng cấm thứ mà hàng khác đòi đọc thì hàng đòi đọc thắng, và vẫn đọc theo mục qua `docs/INDEX.md`.

Mọi hàng kết thúc ở một gate: khi dừng ở gate hoặc nhận "Duyệt Gate N", agent nạp thêm `specflow/PLAYBOOK.md` mục 2.7 và mục 8.

Có roadmap (mục 2): hàng 4b, 5, Resume và lúc nhận "Duyệt Gate 1", "Duyệt Gate 3", "Duyệt Gate 4", "Duyệt Gate 5" nạp thêm `docs/ROADMAP.md`, `specflow/CONVENTIONS.md` mục 11 và `specflow/PLAYBOOK.md` mục 2.5, 2.6; khi nhận "Duyệt Gate 5" nạp thêm dòng Định dạng tag ở Intake mục 14.

Chỉ mục và tệp đi kèm: khi dự án có `docs/INDEX.md`, mọi hàng đọc file đó trước các tài liệu khác và tra ID bằng `specflow/scripts/project-index.py` (lệnh ghi ở đầu chỉ mục) thay cho việc dò cả thư mục `docs/`. Hàng nào nạp một mục của SPEC hay ARCHITECTURE thì chỉ nạp tệp đi kèm mà mục đó dẫn (CONVENTIONS mục 7) khi việc đang làm cần nội dung của tệp: viết hoặc sửa chính khối đó, hiện thực nó, hoặc đối chiếu với nó.

Mọi giai đoạn: MUST NOT đọc `examples/` hoặc bộ mẫu cũ khi sinh tài liệu dự án, để không rò rỉ nội dung ví dụ. Dự án brownfield dùng thêm bảng ở mục 4 của `brownfield/PLAYBOOK_BROWNFIELD.md`.

## 7. Quy tắc cho agent (Agent Rules)

1. Mọi tài liệu có mục `Assumptions & Open Questions`. Mỗi giả định ghi lý do và ảnh hưởng; câu hỏi chặn đánh dấu `BLOCKING`.
2. Agent MUST NOT tự giải quyết mơ hồ mà không ghi lại. Mơ hồ chạm hợp đồng (phạm vi, API, schema, bảo mật, dữ liệu cá nhân) thì dừng và hỏi; ở Giai đoạn 0 theo quy tắc 3. Mơ hồ nhỏ thì chọn giả định an toàn nhất, ghi lại, tiếp tục.
3. Gộp câu hỏi vào một lượt ở cuối giai đoạn, tối đa 5 câu, mỗi câu kèm phương án đề xuất. Ở Giai đoạn 0, 5 câu được chọn theo thứ tự: câu chặn Routing Decision trước, rồi câu chạm hợp đồng theo quy tắc 2, xếp theo rủi ro. Câu chạm hợp đồng mà không chặn routing, kể cả câu vượt quá 5 câu, ghi `BLOCKING: Không` và thêm "trả lời trước Gate 1" ở cột Lý do hoặc ảnh hưởng. Câu không chạm hợp đồng ghi thành giả định an toàn nhất. Gate 0 vẫn không cho còn câu hỏi `BLOCKING`. Prompt 1 chép mọi câu "trả lời trước Gate 1" chưa có câu trả lời vào SRS §9 với `BLOCKING: Có`, nên người duyệt Gate 1 chặn chúng như câu hỏi chặn khác (trên ví dụ của bộ mẫu, `scripts/check-templates.sh` báo câu hỏi `BLOCKING` còn trong tài liệu `approved`).
4. Agent MUST NOT thêm dependency ngoài bảng tech stack đã duyệt. Cần thêm thì đề xuất ADR `proposed` và chờ duyệt.
5. Khi code: chỉ sửa và tạo file trong File Diff của SPEC đang thực thi.
6. Khi SPEC mâu thuẫn với code hiện có hoặc với ARCHITECTURE: dừng, báo vị trí (`file:line`, mục tài liệu) và các phương án; không tự chọn.
7. Không sinh code trước khi Definition of Ready đạt.
8. Không sửa file trong `specflow/`. Không đánh số lại ID đã duyệt; ID bỏ đi ghi `deprecated`, không tái sử dụng.
9. Dự án mới và đợt mới: mỗi lượt sinh tài liệu của một giai đoạn, trừ các lần soạn gộp của quy mô `small` (mục 5). Thay đổi trên dự án đã có baseline: một lượt được sửa và tạo mọi tài liệu thay đổi cần, rồi trình gộp (mục 8). Kết thúc lượt bằng: danh sách file đã tạo hoặc sửa, checklist exit gate đã tự kiểm, Open Questions còn lại. Agent tự kiểm đúng các hàng exit gate (kể cả DoR ở mục 10.1) mà nó đọc được theo danh mục nạp ngữ cảnh của mục 6; hàng cần tài liệu mà manifest của giai đoạn đó không nạp (ví dụ SRS toàn văn ở Giai đoạn 4a) để người duyệt kiểm.
10. Nhận "Duyệt Gate N": làm theo mục 2.7.
11. Cùng một lệnh test hoặc verify hỏng cùng một lỗi sau 3 lần sửa liên tiếp trong một pha (kể cả vòng đỏ sang xanh của TDD): dừng, báo lệnh, lỗi, các cách đã thử và các phương án; không sửa tiếp khi chưa có hướng từ người dùng. Bộ đếm chỉ về 0 khi người dùng đã cho hướng.
12. Có roadmap (mục 2): chỉ làm việc có dòng trong roadmap, theo thứ tự ở mục 2.5; yêu cầu mới ghi vào mục 3 của roadmap rồi chờ quyết định, không làm ngay. Yêu cầu do chính người quyết phạm vi (Intake mục 9) đưa ra kèm lời bảo làm thì đã là quyết định: ghi `Đưa vào change request` và làm tiếp theo mục 8. Dự án có Intake tạo từ template Intake `1.4.0` trở lên đã qua Gate 1 mà thiếu `docs/ROADMAP.md`: báo, rồi dựng theo mục 2.7 trước khi làm tiếp.
13. Giao việc cho agent con (khi runtime có): mỗi lần giao viết một work packet theo `specflow/PROMPTS.md` mục Work packet, gồm mục tiêu, lát đọc là các `tệp §mục` lấy từ `docs/INDEX.md` hoặc mục Đọc trước của pha, tệp được sửa, điều kiện dừng, ngân sách lượt gọi công cụ và dạng báo cáo cuối. Agent con không nhận lịch sử hội thoại. Agent điều phối giữ việc gộp kết quả, chạy `specflow/scripts/check-templates.sh --project .` và mọi lời duyệt của người dùng; agent con MUST NOT sửa file ngoài danh sách được giao và MUST NOT tự đặt `approved` hay `accepted`.
14. Giữ ngữ cảnh của phiên điều phối gọn, vì mỗi lượt gọi đọc lại cả ngữ cảnh: không dán báo cáo dài vào hội thoại, chỉ đọc phần cần; sau mỗi gate, hoặc khi đã dùng quá nửa cửa sổ ngữ cảnh, ghi trạng thái (việc đang dở, quyết định chưa có trong tài liệu) vào `plans/reports/` rồi mở phiên mới bằng Prompt Resume. Việc cơ học (đồng bộ tài liệu, rà nhất quán, thao tác git) được giao cho mô hình nhỏ hơn. Trong vòng làm việc của một pha chỉ chạy lint, typecheck và test của phần đang sửa; bộ verify đầy đủ chạy một lần ở cuối pha.

## 8. Quản trị thay đổi (Change Management)

Nghi thức của một thay đổi tỉ lệ với cái nó chạm, không với số tài liệu nó sửa. Version theo SemVer:

| Mức | Khi nào | Dừng chờ duyệt |
| --- | --- | --- |
| MAJOR | Đổi phạm vi hoặc hợp đồng làm tài liệu hạ nguồn đã duyệt không còn đúng (xóa FR, đổi schema có dữ liệu, đổi contract công khai) | Có; kèm ADR nếu là quyết định kiến trúc |
| MINOR | Thêm FR, NFR, mục, endpoint mà không phá hợp đồng đã duyệt | Có khi thay đổi chạm hợp đồng công khai, schema, bảo mật, phạm vi, hoặc thuộc SPEC `risk: high`. Còn lại không dừng: tài liệu sửa cùng nhánh với code và được duyệt một lần khi merge pull request của pha |
| PATCH | Sửa lỗi chữ, làm rõ, không đổi nghĩa | Không |

Tài liệu mới luôn qua gate của giai đoạn nó (mục 2). Quy trình cho thay đổi:

1. Đang sửa: đặt `status: draft` (tài liệu chưa từng duyệt) hoặc `in-review` (tài liệu đã duyệt) và sửa tự do. Không tăng version và không ghi lịch sử cho từng lần sửa; lịch sử chi tiết là git.
2. Khi trình: chạy `specflow/scripts/check-templates.sh --project .`, rồi khi nhận lời duyệt `gate.py approve --bump <patch|minor|major> --note "nội dung chính của thay đổi"` (mục 2.7) tăng version một lần và ghi một dòng lịch sử có nội dung đó. Một thay đổi chạm nhiều tài liệu được làm trong một lượt và trình gộp; lời trình nêu từng gate đang xin duyệt và checklist exit của từng gate.
3. Tài liệu hạ nguồn: chỉ sửa tài liệu mà bảng dưới nêu cho thay đổi đó và chỉ khi nội dung của nó thật sự đổi; tài liệu không đổi nội dung giữ nguyên `status` và version.
4. Khác biệt phát hiện khi code: SPEC `risk: normal` thì sửa SPEC cùng nhánh với code, không dừng và không đổi `status`; thay đổi được ghi khi đóng SPEC bằng `gate.py implemented --bump minor --note "..."` (PATCH khi không đổi nghĩa), và người duyệt Gate 5 là người duyệt nó. Đổi kiến trúc, hoặc SPEC `risk: high`, thì ghi ADR trước khi merge và trình lại gate của tài liệu bị đổi.
5. ADR đã `accepted` không sửa nội dung quyết định: tạo ADR mới, đặt ADR cũ `superseded` với `superseded_by`.
6. Sửa sau review một SPEC đã `implemented`: khi thay đổi nằm trong khoảng commit của SPEC và có TC phủ, SPEC đi `implemented → in-review → implemented` (`gate.py implemented --after-review --note "..."`), không thêm pha mới và không qua lại Gate 4; lời duyệt Gate 5 kế tiếp ghi tên người duyệt cho version đó.
7. Đổi hành vi của một SPEC đã `implemented`: SPEC tăng MINOR và nhận một pha mới trong plan của đợt còn dở, chèn liền sau các pha của SPEC đó (CONVENTIONS mục 9); Gate 5 của lần đổi xét khoảng commit của pha mới. Đợt đã xong (plan `completed`): thay đổi đi qua một SPEC mới của đợt sau. Không mở lại SRS hay ARCHITECTURE khi thay đổi không chạm nội dung của chúng.
8. Đường thay đổi nhỏ, cho một yêu cầu trên dự án đã có baseline mà SPEC của nó là `risk: normal`: trong một lượt, agent thêm FR và AC vào SRS (khi yêu cầu là hành vi mới), viết hoặc sửa SPEC, thêm pha vào plan, rồi trình gộp các gate tương ứng một lần. Sau lời duyệt, agent code các pha, verify theo checklist và đồng bộ tài liệu trong một lượt, rồi dừng chờ "Duyệt Gate 5". Thay đổi chạm kiến trúc, hoặc SPEC `risk: high`, không đi đường này: nó dừng ở từng gate như một đợt mới.

| Thay đổi ở | Tài liệu phải rà | Hành động |
| --- | --- | --- |
| SRS: FR, AC, use case | SPEC chứa FR đó, trang wireframe và hàng đối chiếu dẫn FR đó, plan, test | Cập nhật SPEC §1, §3, §9 và wireframe; thêm pha vào plan nếu cần |
| SRS §3: thêm, bớt hay đổi màn hình (`SCR ID`) | Chỉ mục wireframe, trang của màn hình, bảng route hoặc điều hướng ở ARCHITECTURE §3, SPEC dẫn `SCR-*` đó | Cập nhật chỉ mục và trang; ID bỏ đi không dùng lại |
| Wireframe: bố cục, thành phần, trạng thái, điều hướng, sau khi SPEC dẫn `SCR-*` đó đã `approved` | SPEC dẫn `SCR-*` đó (§3, §9), plan, test giao diện và e2e | Wireframe tăng MINOR (PATCH khi chỉ làm rõ, không đổi nghĩa). SPEC được cập nhật theo mục này và plan đã qua Gate 4 thêm hoặc sửa pha; có dừng chờ duyệt lại hay không theo bảng mức ở đầu mục. SPEC đã `implemented` thì theo bước 7 ở trên |
| SRS §6.1: đổi Bản phát hành của FR | SPEC dẫn FR đó ở §1.5 (khóa `release`), plan của đợt cũ và đợt mới | Bỏ FR khỏi §1.5 của SPEC đợt cũ, hoặc đặt SPEC đó `superseded` khi mọi FR của nó chuyển đi; đưa FR vào §1.5 của SPEC có `release` bằng đợt mới. Cập nhật `spec_ids` và pha ở plan của hai đợt; đổi đợt là đổi phạm vi, nên người duyệt Gate 3 và Gate 4 của từng đợt duyệt lại. FR mà SPEC `implemented` đã thực hiện thì không đổi đợt; thay đổi theo bước 7 ở trên |
| Hệ thống thiết kế: token, file mode, danh mục component, pattern, template, sau Gate 1W | Trang dẫn mục đổi, HTML, file ánh xạ token trong code, ARCHITECTURE hàng Design token, SPEC dẫn trang | `DESIGN_SYSTEM.md` tăng version và ghi Version History cho mọi đổi của nó và của `tokens.json` (file JSON không có frontmatter, không thêm trường lạ vào token); đổi token thì tính lại bảng tương phản ở mọi mode; trang bị ảnh hưởng theo dòng Wireframe ở trên; đổi hướng thị giác thì duyệt lại Gate 1W |
| SRS: NFR | ARCHITECTURE §8 (`NFR → tactic`), ADR | Cập nhật tactic, ghi ADR nếu đổi quyết định |
| SRS §6.1 hoặc §7 (có roadmap): thêm, bỏ FR hay NFR Must, đổi Ưu tiên, Bản phát hành hay Cách kiểm chứng | `docs/ROADMAP.md` | Thêm dòng `Chưa làm` (NFR Must thêm sau Gate 1 có Đợt đóng là đợt đang làm), đặt dòng của yêu cầu bỏ đi hay chuyển `Won't` sang `Bỏ` (giữ dòng để còn thấy lịch sử), sửa ô chép từ SRS, xếp lại thứ tự và cập nhật mục 1 |
| SPEC đã `implemented` đổi theo bước 7 ở trên (có roadmap) | `docs/ROADMAP.md` | Dòng FR của SPEC về `Chưa làm`, bỏ hàng của chúng ở mục 4; giữ hàng cũ ở mục 5. Lần qua Gate 5 sau đó đánh tag có hậu tố `-2`, `-3` (mục 2.7) |
| Roadmap mục 3: người duyệt quyết "Đưa vào change request" | Tài liệu ghi ở cột Quyết định | Đi theo quy trình change request ở trên, bắt đầu từ tài liệu đó; roadmap đổi theo dòng trên khi SRS đổi |
| SRS: mô hình dữ liệu | ARCHITECTURE §5, SPEC §4 (migration) | Cập nhật schema, thêm migration |
| ARCHITECTURE: schema, conventions, Error Code Registry | Mọi SPEC tham chiếu | Cập nhật contract và bảng lỗi |
| ARCHITECTURE: tech stack | ADR, `CLAUDE.md`, `.claude/rules/` | Ghi ADR, cập nhật lệnh verify |
| SPEC: contract | SPEC của bề mặt tiêu thụ contract đó, plan | Cập nhật SPEC phía tiêu thụ và plan |
| Prompt Spec (overlay `ai-llm-app`): prompt, ví dụ mẫu, schema đầu ra, tham số, guardrail, ngưỡng | SPEC dùng prompt, module prompt trong mã, bộ dữ liệu đánh giá | Tăng version của Prompt Spec và hằng phiên bản trong mã, chạy lại cổng đánh giá, cập nhật SPEC §3 nếu schema hay ngân sách đổi |

## 9. Prompt mẫu cho Claude Code (Prompts)

Prompt nằm ở [PROMPTS.md](PROMPTS.md).

## 10. Điều kiện sẵn sàng và hoàn tất (Definition of Ready, Definition of Done)

### 10.1. Definition of Ready (DoR)

Đối chiếu ở Gate 4, trước khi cho phép viết dòng code đầu tiên của plan: plan của đợt. Hàng SPEC áp cho mọi SPEC mà plan thực hiện.

| Hạng mục | Tiêu chí | Đạt? |
| --- | --- | :---: |
| Intake | Routing Decision đủ trường (overlays, stack profile, starter, mode, docs_mode, người duyệt, Giai đoạn 1W), status `approved` | [ ] |
| Overlay | Checklist "Overlay đã áp" ở mục 4 đủ cho SRS, ARCHITECTURE và mọi SPEC của plan; lệnh kiểm tra sót trả về rỗng | [ ] |
| SRS | Mô hình dữ liệu logic theo bề mặt; bề mặt có lưu trữ quan hệ có `erDiagram` Crow's foot | [ ] |
| SRS | Mọi use case có Exception flow kèm mã lỗi có trong Error Code Registry | [ ] |
| SRS | Ma trận Given-When-Then nối `FR → AC`; NFR có chỉ số, cách đo, ngưỡng; status `approved` | [ ] |
| Wireframe | Không có Giai đoạn 1W (không có giao diện) ghi N/A. Gate 1W đạt: mọi tiêu chí ở bảng exit gate mục 2.2.1, kể cả hàng Màn hình xác thực, mục trợ năng của trang và tài liệu hệ thống thiết kế (khi wireframe từ chỉ mục `1.3.0`, trang `1.4.0`) | [ ] |
| ARCHITECTURE | Tech stack ghi phiên bản chính xác, không còn "A hoặc B" | [ ] |
| ARCHITECTURE | Schema vật lý hoàn chỉnh, migrate được ngay (nếu có lưu trữ) | [ ] |
| ARCHITECTURE | Layout phân tầng rõ, có bảng `MOD → thành phần → thư mục`; có Error Code Registry và bảng `NFR → tactic`; status `approved` | [ ] |
| ADR | Kiểu kiến trúc, mỗi lựa chọn đánh dấu `có ADR` và mỗi lệch stack profile được một ADR `accepted` bao phủ, liệt kê ở ARCHITECTURE §12 | [ ] |
| Agent Context | `CLAUDE.md` có `## Documentation Layout` là mục đầu tiên, có lệnh verify, không còn dòng "Hoàn thiện ở Giai đoạn 2." hay "Hoàn thiện ở Giai đoạn 0R (Prompt B1)."; `.claude/rules/` đã tạo | [ ] |
| SPEC | File Diff đã khóa, có bảng MUST NOT touch, không có file thừa | [ ] |
| SPEC | Bảng test SPEC §9 đủ AC và INV; NFR ở §1.5 mà SRS §8 kiểm bằng Test có TC theo CONVENTIONS mục 4; mỗi Core Invariant có test `CONC`; status `approved` | [ ] |
| SPEC | Có Giai đoạn 1W: SPEC của FR có giao diện dẫn `SCR-*` của FR đó ở bảng Màn hình §3; không có thì ghi N/A | [ ] |
| Prompt Spec | Bề mặt không gọi mô hình ngôn ngữ ghi N/A. Mỗi prompt mà SPEC dùng có Prompt Spec `approved` với ID đặt ở SRS §4.1 và bộ dữ liệu đủ mẫu trong `evals/` | [ ] |
| Roadmap | Dự án có Intake cũ hơn `1.4.0` ghi N/A. `docs/ROADMAP.md` có; mọi dòng FR của đợt có SPEC, và mỗi SPEC đó có pha trong plan (cột Pha điền khi nhận "Duyệt Gate 4"); đối soát ở mục 2.6 không lệch | [ ] |
| Plan | Plan trong `plans/` đúng định dạng ở CONVENTIONS mục 9, pha phủ hết File Diff, đã duyệt. Plan theo đợt: `release` và `spec_ids` gồm mọi SPEC của đợt, khóa `release` của SPEC (nếu có) khớp quy tắc ở mục 2.5, mỗi SPEC có pha, pha của mỗi SPEC phủ File Diff của SPEC đó | [ ] |
| Brownfield | Greenfield ghi N/A. Tiêu chí DoR ở `brownfield/PLAYBOOK_BROWNFIELD.md` mục 7 đạt: Gate 0R, Gap Analysis và Migration Plan `approved`, SPEC áp phụ lục brownfield | [ ] |
| Open Questions | Không còn câu hỏi `BLOCKING` trong mọi tài liệu thượng nguồn | [ ] |

### 10.2. Definition of Done (DoD)

DoD xét cho từng SPEC ở Gate 5, trên khoảng commit của SPEC (mục 2.6). Plan `completed` khi mọi SPEC của đợt đạt DoD.

| Tiêu chí | Đạt? |
| --- | :---: |
| Mọi lệnh ở cổng verify (mục 11) đạt điều kiện pass, cục bộ và trên CI; lệnh mà bảng lệnh verify ghi chỉ chạy trong CI (e2e trên máy ảo, đánh giá prompt) đạt trên CI | [ ] |
| Tính năng gọi mô hình ngôn ngữ (bề mặt khác ghi N/A): Prompt Spec §9.1 ghi kết quả đánh giá đạt cho phiên bản prompt phát hành | [ ] |
| Mọi TC trong SPEC §9 có test đúng file và tên ghi trong bảng, và pass | [ ] |
| Coverage đạt ngưỡng của `NFR-MAINT` | [ ] |
| Mã nguồn trong `git diff` trên khoảng commit của SPEC chỉ nằm trong File Diff của SPEC đó; ngoài ra chỉ có tài liệu và plan được cập nhật | [ ] |
| Không có dependency mới ngoài tech stack đã duyệt hoặc ADR `accepted` | [ ] |
| SPEC `implemented`, các pha của SPEC `done`; plan `completed` khi mọi SPEC trong `spec_ids` đã `implemented` (plan một SPEC: plan hoàn tất); ADR cho mọi deviation, version tài liệu đã tăng (hoàn tất ở Prompt 6) | [ ] |
| Lệnh kiểm tra sót ở mục 4 trả về rỗng | [ ] |
| Có roadmap (dự án có Intake cũ hơn `1.4.0` ghi N/A): dòng của SPEC `Xong` với bằng chứng ở mục 4; đối soát ở mục 2.6 không còn lệch; plan chỉ `completed` khi không còn dòng `Chưa làm` của đợt | [ ] |
| Brownfield (greenfield ghi N/A): tiêu chí DoD ở `brownfield/PLAYBOOK_BROWNFIELD.md` mục 7 đạt | [ ] |
| Open Questions đã giải quyết hoặc được hoãn có người chịu trách nhiệm | [ ] |

## 11. Cổng verify (Verify Gate)

Danh mục tối thiểu mọi dự án phải có; overlay cung cấp lệnh cụ thể theo stack profile.

| Hạng mục | Điều kiện pass |
| --- | --- |
| Sinh mã (khi stack có client sinh tự động) | Exit code 0; chạy trước mọi hạng mục khác |
| Lint | 0 lỗi, 0 cảnh báo |
| Typecheck (ngôn ngữ có kiểm tra kiểu) | 0 lỗi |
| Unit test | 100% pass |
| Integration test | 100% pass |
| E2E test | 100% pass; bề mặt không có giao diện hay API riêng ghi N/A kèm lý do |
| Đánh giá prompt (khi dự án gọi mô hình ngôn ngữ) | Mọi lần chạy đạt ngưỡng của Prompt Spec; chạy trong job đánh giá của CI |
| Coverage | ≥ ngưỡng của `NFR-MAINT` |
| Build | Exit code 0 |
| Dependency audit | Không còn lỗ hổng mức high hoặc critical chưa có ADR chấp nhận rủi ro |

<!-- SLOT: playbook.verify-commands -->
<!-- slot-hint: Overlay cung cấp bảng lệnh cho từng hạng mục trên theo stack profile. Trong dự án, lệnh đã ghép nằm ở mục lệnh verify của CLAUDE.md. -->
