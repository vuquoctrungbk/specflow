---
doc_type: playbook
status: stable
version: 2.7.0
language: vi-en
---

# Prompt mẫu cho Claude Code (specflow Prompts)

Chạy từng prompt trong phiên Claude Code ở gốc dự án. Mỗi prompt nêu file phải đọc, file phải sinh và điều kiện dừng. Bạn thay các placeholder (CONVENTIONS mục 1) trước khi gửi; `<starter>`, `<surface>`, `<NAME>`, `<slug>`, `{YYMMDD-HHmm}` và placeholder `{{RELEASE_SLUG}}` là giá trị agent tự xác định từ Routing Decision, `{{RELEASE}}` và ngày giờ hiện tại; bạn không thay chúng. "Của giai đoạn" theo định nghĩa ở PLAYBOOK mục 4. Dự án brownfield áp thêm phần bổ sung cho từng prompt ở mục 6.1 của `brownfield/PLAYBOOK_BROWNFIELD.md` và dùng Prompt B0 đến B4 ở mục 6 của file đó.

Dự án có Intake tạo từ template Intake cũ hơn `1.3.0`: đọc thêm `specflow/COMPATIBILITY.md` mục 3 trước khi dùng prompt.

Câu mở đầu "X đã duyệt" của các prompt dưới, và các hàng Intake, SPEC, Plan trạng thái `approved` ở Definition of Ready (PLAYBOOK mục 10.1), đều theo thủ tục duyệt gate ở PLAYBOOK mục 2.7.

## Prompt 0: Intake

```text
Bắt đầu dự án mới theo bộ mẫu specflow đã cài trong thư mục specflow/.

Mô tả dự án:
{{PROJECT_BRIEF}}

Đọc: specflow/PLAYBOOK.md mục 1 đến 7, specflow/CONVENTIONS.md, specflow/core/00_Project_Intake_Template.md.

Nhiệm vụ:
1. Tạo docs/intake/PROJECT_INTAKE.md từ template Intake, điền mọi mục; mục không áp dụng ghi N/A kèm lý do.
2. Chốt khối Routing Decision: overlays theo thứ tự, stack profile của từng overlay (profile khớp theo PLAYBOOK mục 3, đọc mục Tech Stack của profile trước khi chốt; không profile nào khớp thì ghi none), starter, mode, docs_mode, Giai đoạn 1W có hay không (PLAYBOOK mục 2), người duyệt từng gate kể cả Gate 1W. Ghi tên các đợt phát hành dự kiến ở hàng Mốc thời gian của Intake mục 6.
3. Tạo CLAUDE.md khởi tạo từ Agent Context của giai đoạn (specflow/starters/<starter>/CLAUDE.md.template nếu có starter; nếu không, specflow/core/06_Agent_Context_Template.md) và áp stack profile theo PLAYBOOK mục 4 (stack profile none: theo specflow/CONVENTIONS.md mục 2). Mục Documentation Layout chép nguyên văn; mục chưa đủ dữ liệu thay bằng dòng "Hoàn thiện ở Giai đoạn 2." (dự án brownfield: mục lệnh verify theo PLAYBOOK mục 2.1); không chép Phụ lục A.
4. Ghi giả định và câu hỏi vào Assumptions & Open Questions theo PLAYBOOK mục 7 quy tắc 3. Tạo bản nháp hai file rồi hỏi một lượt, gộp tối đa 5 câu: câu chặn Routing Decision trước, rồi câu chạm phạm vi, API, bảo mật hay dữ liệu cá nhân. Câu chạm hợp đồng còn lại ghi BLOCKING: Không kèm "trả lời trước Gate 1"; câu khác ghi thành giả định.

Dừng khi: hai file đã tạo, lệnh kiểm tra sót ở PLAYBOOK mục 4 trả về rỗng (dự án brownfield dùng lệnh ở specflow/brownfield/PLAYBOOK_BROWNFIELD.md mục 5.5 thay cho lệnh ở mục 4) và exit gate mục 2.1 đã tự kiểm. Không tạo SRS, không viết code.
```

## Prompt 1: SRS

```text
Intake đã duyệt. Bắt đầu Giai đoạn 1.

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "1. SRS" và dòng áp cho mọi hàng.
Template: SRS của giai đoạn (specflow/starters/<starter>/SRS_Template.md nếu có starter; nếu không, specflow/core/01_SRS_Template.md ghép với specflow/overlays/<surface>/srs-sections.md sau khi đọc specflow/overlays/<surface>/OVERLAY.md), áp stack profile của từng bề mặt theo PLAYBOOK mục 4.

Nhiệm vụ:
1. Tạo SRS theo docs_mode của Intake (monolithic: docs/srs/SRS.md; modular: docs/srs/00_SRS_MASTER.md và docs/srs/SRS_MODULE_<NAME>.md).
2. Điền đủ mọi mục: sơ đồ bối cảnh, tác nhân, ràng buộc (gồm vận hành, bộ nhớ, thích ứng nơi triển khai), chuẩn phải tuân thủ, giao diện ngoài, mô hình dữ liệu logic, Business Rules, FR có phát biểu EARS theo specflow/CONVENTIONS.md mục 8 và use case có exception flow kèm mã lỗi, NFR đo được kèm cách kiểm chứng, ma trận FR → AC → TC và bảng NFR ở §8.
3. Bề mặt có giao diện: bảng Giao diện người dùng ở SRS §3 liệt kê mọi màn hình, mỗi màn hình một SCR ID dạng SCR-{MOD}-NN theo specflow/CONVENTIONS.md mục 4; cột FR liệt kê mọi FR mà màn hình hiện thực, kể cả thành phần dùng chung như nút Đăng xuất ở header. Cột Bản phát hành ở §6.1 dùng đúng tên đợt ở Intake mục 6.
4. Chép mọi câu ở mục Assumptions & Open Questions của Intake có ghi "trả lời trước Gate 1" mà chưa có câu trả lời vào SRS §9 với BLOCKING: Có, dẫn ID của Intake (PLAYBOOK mục 7 quy tắc 3).
5. Tự kiểm checklist Overlay đã áp cho 3 slot SRS và chạy lệnh kiểm tra sót ở PLAYBOOK mục 4.

Dừng khi: SRS ở status in-review, exit gate mục 2.2 đã tự kiểm. Không tạo wireframe, không tạo ARCHITECTURE, không viết code.
```

## Prompt 1W: Wireframe

```text
SRS đã duyệt. Bắt đầu Giai đoạn 1W.

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "1W. Wireframe" và dòng áp cho mọi hàng.
Template: specflow/core/07_Wireframe_Template/.

Nhiệm vụ:
1. Tạo docs/wireframes/00_WIREFRAME_INDEX.md: danh mục màn hình gồm đúng tập SCR ID ở bảng Giao diện người dùng của SRS §3, sơ đồ điều hướng, bảng đối chiếu có đúng một hàng cho mỗi FR ở SRS §6.1 có ưu tiên khác Won't (FR Won't không có hàng), ghi SCR-* hoặc "Không có giao diện" kèm lý do; dự án brownfield ghi "Giữ nguyên" cho màn hình không đổi.
2. Mỗi SCR ID một trang trong docs/wireframes/, tên file là SCR ID cộng đuôi .md: mục đích, FR và AC, bố cục low-fi trong khối text theo specflow/CONVENTIONS.md mục 7, bảng thành phần, năm trạng thái UI kèm AC, điều hướng vào và ra, dòng Màn hình xác thực, ghi chú trợ năng theo specflow/CONVENTIONS.md mục 10.2 và con số của OVERLAY.md. Không thêm màn hình ngoài SRS §3.
3. HTML low-fi trong docs/wireframes/html/ chỉ tạo khi Intake mục 14 ghi Giai đoạn 1W "Có, kèm HTML low-fi", theo quy tắc an toàn ở specflow/CONVENTIONS.md mục 7. Intake ghi "Có" mà tôi muốn HTML thì đề xuất sửa Intake mục 14 theo PLAYBOOK mục 8 trước.
4. Lệch với SRS (màn hình thêm, bớt hay đổi; FR thiếu; AC không khớp trạng thái) theo PLAYBOOK mục 2.2.1: wireframe vẽ sai hoặc sót so với SRS thì sửa wireframe. SRS thiếu hoặc sai thì không sửa wireframe để che chỗ lệch; ghi câu hỏi BLOCKING ở chỉ mục kèm đề xuất sửa SRS; khi tôi đồng ý, sửa SRS theo PLAYBOOK mục 8 (tăng version, Version History, status in-review) để người duyệt Gate 1 duyệt lại.
5. Ở chỉ mục, điền bảng đánh giá heuristic theo specflow/CONVENTIONS.md mục 10.3 và bảng kiểm mẫu thiết kế lừa người dùng theo mục 10.4 cho toàn bộ chỉ mục và các trang; sửa vấn đề Nghiêm trọng và bỏ mẫu lừa người dùng trước khi dừng. Cần đổi SRS để sửa thì làm như nhiệm vụ 4.
6. Chạy lệnh kiểm tra sót ở PLAYBOOK mục 4.

Dừng khi: chỉ mục và các trang ở status in-review, exit gate mục 2.2.1 đã tự kiểm. Không tạo ARCHITECTURE, không viết code.

Intake mục 14 ghi Giai đoạn 1W: Không: không chạy prompt này; sau Gate 1 chạy Prompt 2.
```

## Prompt 2: Architecture và ADR

```text
SRS đã duyệt; wireframe đã duyệt ở Gate 1W khi dự án có Giai đoạn 1W. Bắt đầu Giai đoạn 2.

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "2. Architecture + ADR" và dòng áp cho mọi hàng.
Template: Architecture của giai đoạn (specflow/starters/<starter>/ARCHITECTURE_Template.md nếu có starter; nếu không, specflow/core/02_Architecture_Core_Template.md ghép với specflow/overlays/<surface>/architecture-sections.md) và Agent Context của giai đoạn, áp stack profile theo PLAYBOOK mục 4.

Nhiệm vụ:
1. Tạo docs/ARCHITECTURE.md, điền đủ mọi mục; §2.1 chép từ mục Tech Stack của stack profile; Error Code Registry §7.1 nhận mọi mã ở SRS §6.3. Có Giai đoạn 1W: bảng route (web) hoặc bảng điều hướng (mobile) ở §3 có cột SCR ID, mỗi SCR-* của chỉ mục wireframe ít nhất một hàng.
2. Tạo ADR trong docs/adr/NNNN-<slug>.md theo PLAYBOOK mục 2.3; lập ADR index ở §12.
3. Hoàn thiện CLAUDE.md (thay các dòng "Hoàn thiện ở Giai đoạn 2.", ghi con số ngưỡng NFR-MAINT vào ô Điều kiện pass của hàng Coverage) và tạo .claude/rules/ từ Phụ lục A của Agent Context của giai đoạn và agent-rules của từng overlay.
4. Tự kiểm checklist Overlay đã áp cho slot arch.* và playbook.verify-commands, chạy lệnh kiểm tra sót.

Dừng khi: ARCHITECTURE ở status in-review, ADR ở status proposed, exit gate mục 2.3 đã tự kiểm. Không tạo SPEC, không viết code.
```

## Prompt 3: Spec của một đợt, mỗi lượt một SPEC

```text
ARCHITECTURE đã duyệt. Viết SPEC tiếp theo của đợt {{RELEASE}}: tính năng {{FEATURE_NAME}} (phân hệ {{MODULE_CODE}}).

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "3. Spec" và dòng áp cho mọi hàng.
Template: Spec của giai đoạn cho đúng bề mặt (file SPEC trong specflow/starters/<starter>/ nếu có starter; nếu không, specflow/core/04_Spec_Core_Template.md ghép với specflow/overlays/<surface>/spec-contract-sections.md), áp stack profile theo PLAYBOOK mục 4.

Nhiệm vụ:
1. Tạo docs/specs/SPEC_{{FEATURE_KEY}}.md với ID {{SPEC_ID}} và khóa frontmatter release: {{RELEASE}}. Mọi FR ở §1.5 có Bản phát hành {{RELEASE}} ở SRS §6.1.
2. Khóa File Diff và bảng MUST NOT touch. SPEC đầu tiên của mỗi bề mặt trong đợt nhận nền tảng dùng chung của bề mặt đó (khung dự án, cấu hình, thư viện dùng chung, hạ tầng test) vào File Diff; SPEC đầu tiên của cả đợt là SPEC không tiêu thụ contract của SPEC khác cùng đợt. SPEC sau của cùng bề mặt không lặp lại, cần sửa file đó thì ghi ở §2.1 (PLAYBOOK mục 2.4). Điền contract, migration, thuật toán có sơ đồ tuần tự, ranh giới transaction và idempotency, authorization matrix, event, observability, rollout.
3. Bề mặt có giao diện: bảng Màn hình ở §3 dẫn SCR-* và trang wireframe của từng màn hình; không định nghĩa lại màn hình.
4. Bảng test gắn AC và TC, ghi file và tên từng test; mỗi Core Invariant có một test CONC; tên test mô tả hành vi, không chứa TC ID.
5. Mã lỗi dùng đúng Error Code Registry; thiếu mã thì ghi Open Question, không tự thêm vào ARCHITECTURE.
6. Tính năng gọi mô hình ngôn ngữ (overlay ai-llm-app): trước SPEC, viết hoặc cập nhật Prompt Spec docs/prompts/PROMPT_<NAME>.md từ specflow/overlays/ai-llm-app/Prompt_Spec_Template.md và bộ dữ liệu trong evals/; SPEC tham chiếu Prompt Spec.
7. Cuối lượt, từ cột Bản phát hành ở SRS §6.1 và §1.5 của các SPEC thuộc đợt {{RELEASE}} (kể cả SPEC này), liệt kê FR có Bản phát hành {{RELEASE}} chưa nằm trong §1.5 của SPEC nào của đợt, kèm đề xuất SPEC tiếp theo (tính năng, phân hệ, bề mặt).

Dừng khi: SPEC và Prompt Spec ở status in-review, exit gate của SPEC ở mục 2.4 đã tự kiểm. Không viết code. Chạy lại prompt này cho SPEC tiếp theo tới khi danh sách ở nhiệm vụ 7 rỗng; khi đó tự kiểm bảng Gate 3 theo đợt ở mục 2.4 và dừng ở Gate 3.
```

## Prompt 4: Implementation Plan của đợt và Coding TDD

```text
Mọi SPEC của đợt {{RELEASE}} đã duyệt ở Gate 3.

Phần A, lập plan. Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "4a. Plan" và dòng áp cho mọi hàng.
Tạo plans/{YYMMDD-HHmm}-release-{{RELEASE_SLUG}}/ (tên gợi ý theo CONVENTIONS mục 9) gồm plan.md và các phase-NN-<slug>.md. plan.md có release: {{RELEASE}} và spec_ids liệt kê mọi SPEC của đợt (SPEC có khóa release thì khóa đó bằng {{RELEASE}}); mỗi pha có spec_id thuộc spec_ids; pha của một SPEC đứng liền nhau, SPEC cung cấp contract đứng trước SPEC tiêu thụ, và ở mỗi bề mặt SPEC mang nền tảng dùng chung của bề mặt đứng trước SPEC khác của bề mặt đó (PLAYBOOK mục 2.4, 2.5). Khi có Giai đoạn 1W, thứ tự pha giao diện và e2e theo luồng điều hướng của chỉ mục wireframe; mỗi FR của đợt có pha thực hiện qua SPEC chứa nó. Pha của mỗi SPEC phủ hết File Diff và mọi TC ở §9 của SPEC đó. Mỗi pha: tập con File Diff, TC phải pass, lệnh verify, commit message. Plan theo định dạng ở specflow/CONVENTIONS.md mục 9; chạy lệnh kiểm tra sót ở PLAYBOOK mục 4.
Dừng sau phần A để tôi duyệt plan và DoR (Gate 4, PLAYBOOK mục 2.5 và 10.1).

Phần B, chỉ chạy khi tôi đã duyệt plan. Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "4b. Coding" và dòng áp cho mọi hàng. Thực thi lần lượt pha của SPEC đầu tiên chưa implemented. Mỗi pha: viết test đỏ, viết code tới khi xanh, refactor, chạy lệnh verify, đánh dấu checkbox, commit theo Conventional Commits bằng tiếng Anh. Chỉ sửa file trong File Diff của SPEC theo spec_id của pha.
Dừng khi: mọi pha của SPEC đó xong và lệnh verify trong CLAUDE.md đều đạt. Dừng; bạn chạy Prompt 5 và 6 cho SPEC đó rồi gửi lại phần B cho SPEC tiếp theo. Cũng dừng khi gặp mâu thuẫn theo PLAYBOOK mục 7.
```

## Prompt 5: Verify và Review

```text
Các pha có spec_id {{SPEC_ID}} của plans/{{PLAN_DIR}} đã xong. Kiểm chứng SPEC này trước khi đóng.

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "5. Verify và Sync" và dòng áp cho mọi hàng; SPEC {{SPEC_ID}}, plan.

Nhiệm vụ:
1. Chạy đủ lệnh verify trong CLAUDE.md; báo kết quả từng lệnh kèm exit code.
2. Xác định khoảng commit của SPEC theo PLAYBOOK mục 2.6: từ cha của commit pha đầu tiên tới commit pha cuối cùng có spec_id {{SPEC_ID}}. So git diff trên khoảng đó với File Diff của SPEC (bỏ qua tài liệu và plan); liệt kê file thừa hoặc thiếu.
3. Đối chiếu code với SPEC: contract, mã lỗi, thuật toán, authorization matrix, event; liệt kê mọi khác biệt kèm file:line.
4. Kiểm tra mọi TC trong SPEC §9 có test đúng file và tên ghi trong bảng, và đang pass.

Dừng khi: có báo cáo đạt hoặc không đạt cho mọi tiêu chí DoD (mục 10.2), trừ hàng ghi "hoàn tất ở Prompt 6" (Prompt 6 mới cập nhật trạng thái tài liệu). Không sửa tài liệu ở bước này; sửa code chỉ khi tôi đồng ý.
```

## Prompt 6: Sync Docs

```text
Verify đã đạt cho SPEC {{SPEC_ID}} của plans/{{PLAN_DIR}}. Đồng bộ tài liệu.

Đọc: theo specflow/PLAYBOOK.md mục 6, hàng "5. Verify và Sync" và dòng áp cho mọi hàng; SPEC {{SPEC_ID}}, plan, báo cáo verify, tài liệu gốc cần sửa ở nhiệm vụ 4.

Nhiệm vụ:
1. SPEC: status implemented, bảng test §9 ghi đúng file test và tên test, tăng version, ghi Version History.
2. Plan: các pha có spec_id {{SPEC_ID}} sang done ở frontmatter và cột Status của bảng Phases (specflow/CONVENTIONS.md mục 9); status của plan là completed khi mọi SPEC trong spec_ids đã implemented, nếu không là in-progress.
3. SRS §8: cập nhật TC của các AC và NFR mà SPEC nhận theo SPEC §9, tăng PATCH version SRS.
4. Mỗi khác biệt đã chấp nhận so với SPEC hoặc ARCHITECTURE: tạo ADR, cập nhật tài liệu gốc theo PLAYBOOK mục 8.
5. Chạy lệnh kiểm tra sót ở PLAYBOOK mục 4.
6. Tính năng gọi mô hình ngôn ngữ: ghi kết quả của job đánh giá (phiên bản prompt, mô hình, chỉ số, token, đạt hay không) vào Prompt Spec §9.1.

Dừng khi: tài liệu khớp code, DoD mục 10.2 đạt cho SPEC này, danh sách thay đổi tài liệu đã báo.
```

## Prompt Resume: tiếp tục trong phiên mới

```text
Tiếp tục dự án {{PROJECT_NAME}} trong phiên mới.

Đọc: CLAUDE.md, specflow/PLAYBOOK.md mục 2, 6 và 7, specflow/PROMPTS.md; dự án brownfield đọc thêm specflow/brownfield/PLAYBOOK_BROWNFIELD.md mục 2, 4 và 5.

Nhiệm vụ:
1. Xác định giai đoạn đang dở: tài liệu trong docs/ (kể cả docs/wireframes/ của Giai đoạn 1W) còn status draft hoặc in-review, hoặc plan trong plans/ còn pha in-progress hay todo. Xác định đợt đang làm: release của plan đang dở, hoặc đợt của SPEC còn draft hay in-review.
2. Đọc tài liệu hoặc plan đang dở và các tài liệu trong parent của nó; plan đang dở thì đọc SPEC theo spec_id của pha đang dở. Tóm tắt trạng thái: phần đã xong, SPEC nào của đợt đã implemented, phần còn lại, Open Questions.
3. Nếu đang ở Giai đoạn 4b: chạy lệnh verify trong CLAUDE.md để xác nhận trạng thái thật; checkbox [x] mà verify hỏng thì báo trước khi làm tiếp.
4. Tiếp tục bước chưa xong đầu tiên theo đúng prompt của giai đoạn đó ở specflow/PROMPTS.md; dự án brownfield theo cả mục 6 của specflow/brownfield/PLAYBOOK_BROWNFIELD.md.

Dừng khi: gặp điều kiện dừng của prompt giai đoạn đó, hoặc gặp mâu thuẫn theo PLAYBOOK mục 7.
```
