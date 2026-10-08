---
doc_type: intake
status: draft
version: 0.1.0
template_version: 1.6.0
language: vi-en
overlays: []
assembled_from: []
---

# Hồ sơ khởi tạo dự án (Project Intake): {{PROJECT_NAME}}

<!-- fill: Chép file này thành docs/intake/PROJECT_INTAKE.md. Điền từ brief của người dùng; thông tin brief không có thì ghi giả định hoặc câu hỏi ở mục 13, không tự bịa. Mục 14 (Routing Decision) là đầu vào của PLAYBOOK mục 3; điền cuối cùng, sau khi các mục khác đã rõ. Frontmatter: overlays ghi đúng danh sách ở mục 14, assembled_from ghi "core/00_Project_Intake_Template.md@<template_version>". -->

## 1. Định danh dự án (Project Identity)

| Trường | Giá trị |
| --- | --- |
| Tên dự án | {{PROJECT_NAME}} |
| Tên ngắn (slug) | `{{PROJECT_SLUG}}` |
| Chủ dự án | <!-- fill: người hoặc vai trò có quyền quyết định cuối cùng --> |
| Ngày lập | {{DATE}} |
| Người soạn | {{AUTHOR}} |
| Brief gốc | <!-- fill: tóm tắt brief trong 3 đến 5 câu, giữ nguyên các con số và ràng buộc người dùng nêu --> |

## 2. Bài toán và mục tiêu (Problem & Goals)

### 2.1. Bài toán (Problem Statement)

<!-- fill: ai đang gặp vấn đề gì, hiện giải quyết thế nào, vì sao cách hiện tại chưa đủ. Không mô tả giải pháp kỹ thuật ở đây. -->

### 2.2. Mục tiêu đo được (Measurable Goals)

| GOAL ID | Mục tiêu | Chỉ số | Ngưỡng đạt | Thời hạn |
| --- | --- | --- | --- | --- |
| GOAL-01 | <!-- fill: mục tiêu nghiệp vụ; ID đánh số liên tục, SRS dẫn ID này ở cột Nguồn của FR và NFR (CONVENTIONS mục 4) --> | <!-- fill: đại lượng đo được --> | <!-- fill: con số cụ thể, dùng ≤ ≥ --> | <!-- fill: ngày hoặc mốc --> |

### 2.3. Ngoài phạm vi đã biết (Known Non-goals)

<!-- fill: những gì brief hoặc chủ dự án đã loại trừ rõ ràng; mỗi dòng một mục. Ghi "Chưa có" nếu brief không nêu. -->

## 3. Loại dự án và bề mặt (Project Type & Surfaces)

Đánh dấu mọi bề mặt dự án có; mỗi bề mặt được chọn ghi bằng chứng từ brief. Bảng overlay hiện có nằm ở PLAYBOOK mục 3.

| Chọn | Bề mặt | Dấu hiệu nhận biết | Bằng chứng từ brief |
| :---: | --- | --- | --- |
| [ ] | `backend-api` | API HTTP hoặc RPC, lưu trữ dữ liệu, background job | <!-- fill: hoặc N/A --> |
| [ ] | `frontend-web` | Giao diện chạy trên trình duyệt | <!-- fill: hoặc N/A --> |
| [ ] | `mobile-app` | Ứng dụng cài trên điện thoại hoặc máy tính bảng | <!-- fill: hoặc N/A --> |
| [ ] | `ai-llm-app` | Tính năng dựa trên mô hình ngôn ngữ lớn: prompt, đánh giá, guardrail | <!-- fill: hoặc N/A --> |
| [ ] | Khác | Bề mặt chưa có overlay (công cụ dòng lệnh, thư viện, pipeline dữ liệu, hạ tầng) | <!-- fill: mô tả; xử lý theo PLAYBOOK mục 3 quy tắc 4, hoặc N/A --> |

## 4. Trạng thái xuất phát (Starting State)

| Trường | Giá trị |
| --- | --- |
| Mode | <!-- fill: chọn một: greenfield \| brownfield. brownfield khi dự án đã có mã nguồn đang chạy cần giữ hành vi; sau Gate 0 dự án brownfield đi qua specflow/brownfield/PLAYBOOK_BROWNFIELD.md trước Giai đoạn 1 --> |
| Kho mã hiện có | <!-- fill: đường dẫn hoặc URL, kèm commit HEAD lúc bắt đầu (BASE của lệnh kiểm tra sót trước khi có Codebase Summary); greenfield ghi N/A --> |
| Quy mô mã hiện có | <!-- fill: số dòng code ước lượng, ngôn ngữ chính, có test và công cụ test hay không; greenfield ghi N/A --> |
| Hệ thống sẽ thay thế hoặc tích hợp | <!-- fill: hoặc N/A --> |
| Test REG ở Giai đoạn 0R | <!-- fill: chọn một: cho phép \| cho phép, chạy trên môi trường dùng một lần (ghi môi trường) \| cho phép, kèm thêm công cụ test (ghi tên và phiên bản) \| không cho phép. Chỉ brownfield, mặc định cho phép; repo chưa có công cụ test thì chọn thêm công cụ hoặc không cho phép; không cho phép thì Regression Baseline dùng thủ tục thủ công có rủi ro được chấp nhận (specflow/brownfield/PLAYBOOK_BROWNFIELD.md mục 5.1). Trước khi chọn, đọc cấu hình test mặc định (file cấu hình và fixture của bộ chạy test, giá trị mặc định trong mã; không mở file env) và ghi nó có trỏ vào dịch vụ hay database đang chạy không; có thì chọn môi trường dùng một lần hoặc không cho phép, và ghi câu hỏi ở mục 13; lựa chọn này thắng chữ "cho phép" của brief vì là điều kiện an toàn, lý do ghi ở mục 13. Greenfield ghi N/A --> |
| Công cụ đo độ phủ test | <!-- fill: chọn một: có sẵn (ghi tên và phiên bản) \| cài tạm trong worktree đo (ghi tên và phiên bản; không đổi manifest hay lockfile) \| thêm vào dev-dependency ở commit REG (ghi tên và phiên bản; duyệt ở Gate 0; số đo ở commit đo vẫn dùng cài tạm) \| đo bằng cách khác (ghi phương pháp và giới hạn, ví dụ chỉ đo dòng, không đo nhánh). Chỉ brownfield: Regression Baseline §2 cần số coverage ở commit đo và sau commit test REG; hàng này có từ template Intake 1.2.0. Greenfield ghi N/A --> |
| Tài liệu và cấu hình agent có sẵn trong repo | <!-- fill: brownfield: CLAUDE.md, AGENTS.md, .claude/, .mcp.json, docs/ đã có, mỗi mục kèm cách xử lý đề xuất theo specflow/brownfield/PLAYBOOK_BROWNFIELD.md mục 5.5 và hook đã tắt trong Giai đoạn 0R. Liệt kê cả git hook đang bật (.pre-commit-config.yaml, .husky/, hook trong .git/hooks không có đuôi .sample, core.hooksPath) kèm lệnh mà hook chạy, vì hook chạy ngay ở commit của bước chuẩn bị repo (Prompt B0); cách xử lý đề xuất ghi ở mục 13 để duyệt ở Gate 0. Greenfield ghi N/A --> |

## 5. Ước lượng quy mô (Scale Estimate)

| Đại lượng | Ước lượng | Căn cứ |
| --- | --- | --- |
| Số phân hệ (module) | <!-- fill: số --> | <!-- fill --> |
| Số đơn vị giao tiếp (endpoint, màn hình, lệnh) | <!-- fill: số --> | <!-- fill --> |
| Người dùng đồng thời lúc cao điểm | <!-- fill: số --> | <!-- fill --> |
| Khối lượng dữ liệu sau 12 tháng | <!-- fill: số + đơn vị --> | <!-- fill --> |
| Chế độ lưu trữ SRS | `{{DOCS_MODE}}` | <!-- fill: áp tiêu chí PLAYBOOK mục 5 lên các con số trên; cross-cutting và thư viện dùng chung không tính là phân hệ; brownfield xét lại ở Gate 0R theo PLAYBOOK mục 5 --> |

## 6. Ràng buộc (Constraints)

| Loại | Ràng buộc | Nguồn | Có thể thương lượng? |
| --- | --- | --- | --- |
| Công nghệ bắt buộc | <!-- fill: ngôn ngữ, framework, dịch vụ bắt buộc dùng hoặc cấm dùng; "Không có" nếu tự do --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| Hạ tầng và hosting | <!-- fill: nhà cung cấp, vùng dữ liệu, on-premise hay cloud --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| Ngân sách | <!-- fill: ngân sách phát triển và vận hành hằng tháng --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| Mốc thời gian | <!-- fill: ngày ra mắt, các mốc trung gian, và tên các đợt phát hành dự kiến theo thứ tự (ví dụ R1, R2), mỗi đợt kèm mốc và mục tiêu một câu. SRS §6.1 dùng đúng các nhãn này ở cột Bản phát hành; SPEC và plan được lập theo từng đợt (PLAYBOOK mục 2). Chưa chia đợt thì ghi một đợt R1 --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| Tổ chức | <!-- fill: quy trình nội bộ, quy định bảo mật công ty; "Không có" nếu không có --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |

## 7. Tuân thủ (Compliance)

| Áp dụng | Khung tuân thủ | Lý do áp dụng | Hệ quả cho SRS |
| :---: | --- | --- | --- |
| [ ] | Luật Bảo vệ dữ liệu cá nhân số 91/2025/QH15 và Nghị định 356/2025/NĐ-CP (Việt Nam) | <!-- fill: xử lý dữ liệu cá nhân của người ở Việt Nam, hoặc N/A --> | NFR-LEGAL, NFR-DATA |
| [ ] | GDPR | <!-- fill: người dùng ở EU, hoặc N/A --> | NFR-LEGAL, NFR-DATA |
| [ ] | PCI DSS | <!-- fill: lưu, xử lý hoặc truyền dữ liệu thẻ thanh toán, hoặc N/A --> | NFR-SEC, NFR-LEGAL |
| [ ] | Khác | <!-- fill: chuẩn ngành, hợp đồng với khách hàng, hoặc N/A --> | <!-- fill --> |

Loại dữ liệu hệ thống xử lý: <!-- fill: liệt kê dữ liệu cá nhân, dữ liệu cá nhân nhạy cảm, dữ liệu tài chính, bí mật kinh doanh; "Không có dữ liệu cá nhân" nếu đúng như vậy -->

## 8. Tích hợp ngoài (External Integrations)

| Hệ thống ngoài | Mục đích | Giao thức | Chiều dữ liệu | Bắt buộc ở bản đầu? |
| --- | --- | --- | --- | --- |
| {{EXTERNAL_SYSTEM}} | <!-- fill --> | <!-- fill: ví dụ REST, webhook, SMTP, SDK --> | <!-- fill: chọn một: vào \| ra \| hai chiều --> | <!-- fill: chọn một: Có \| Không --> |

## 9. Đội ngũ và người duyệt (Team & Approvers)

| Vai trò | Người | Trách nhiệm |
| --- | --- | --- |
| Chủ dự án | <!-- fill --> | Quyết định phạm vi, duyệt Gate 0 |
| Kỹ thuật chính | <!-- fill --> | <!-- fill --> |

| Gate | Nội dung duyệt | Người duyệt |
| --- | --- | --- |
| Gate 0 | Intake và Routing Decision | {{APPROVER}} |
| Gate 0R | Codebase Summary, As-Is Architecture, Regression Baseline <!-- fill: chỉ brownfield; greenfield xóa hàng này --> | {{APPROVER}} |
| Gate 1 | SRS | {{APPROVER}} |
| Gate 1W | Wireframe: chỉ mục, trang màn hình và bảng đối chiếu với SRS | {{APPROVER}} <!-- fill: mặc định là người duyệt Gate 1; ghi người phụ trách sản phẩm hoặc trải nghiệm người dùng nếu khác. Không bề mặt nào có giao diện (mục 14 ghi Giai đoạn 1W: Không) thì thay cả ô bằng N/A kèm lý do --> |
| Gate 2 | ARCHITECTURE và ADR | {{APPROVER}} |
| Gate 3 | Mọi SPEC của một đợt phát hành | {{APPROVER}} |
| Gate 4 | Implementation Plan của đợt và DoR | {{APPROVER}} |
| Gate 5 | DoD của từng SPEC | {{APPROVER}} |

## 10. Chính sách ngôn ngữ (Language Confirmation)

- [ ] Dự án dùng chính sách song ngữ của CONVENTIONS mục 5: diễn giải tiếng Việt, thuật ngữ kỹ thuật và định danh tiếng Anh.
- Ngoại lệ: <!-- fill: ví dụ tài liệu cho đối tác nước ngoài viết toàn tiếng Anh; "Không có" nếu không có -->

## 11. Chỉ số thành công (Success Metrics)

| Chỉ số | Giá trị hiện tại | Mục tiêu | Cách đo | Thời điểm đo |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: hoặc "Chưa có" --> | <!-- fill --> | <!-- fill: công cụ hoặc quy trình đo --> | <!-- fill --> |

## 12. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo từ brief | Khởi tạo theo pipeline | Chưa duyệt |

## 13. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill: câu hỏi chạm hợp đồng mà không chặn Routing Decision ghi thêm "trả lời trước Gate 1" (PLAYBOOK mục 7 quy tắc 3); brownfield: đề xuất cần duyệt trước bước chuẩn bị repo ghi "duyệt ở Gate 0" (specflow/brownfield/PLAYBOOK_BROWNFIELD.md mục 6.1) --> | <!-- fill: chọn một: Có \| Không. Có dành cho câu chặn Routing Decision; Gate 0 không cho còn câu Có --> | <!-- fill --> |

## 14. Quyết định định tuyến (Routing Decision)

<!-- fill: Khối này quyết định template nào được dùng ở mọi giai đoạn sau. Mọi trường MUST có giá trị trước Gate 0. -->

| Trường | Giá trị |
| --- | --- |
| `overlays` (theo thứ tự ghép) | `{{OVERLAYS}}` |
| `starter` | <!-- fill: tên thư mục trong starters/ khớp đúng tổ hợp overlays (PLAYBOOK mục 3), hoặc none --> |
| `mode` | <!-- fill: chọn một: greenfield \| brownfield, khớp mục 4 --> |
| `docs_mode` | `{{DOCS_MODE}}` |
| Giai đoạn 1W (Wireframe) | <!-- fill: chọn một: Có, kèm HTML đầy đủ \| Có, chỉ Markdown: <lý do> \| Không. Mặc định Có, kèm HTML đầy đủ khi overlays có frontend-web hoặc mobile-app, hoặc bề mặt khác có màn hình; Không thì Gate 1W ở mục 9 ghi N/A (PLAYBOOK mục 2) --> |
| Định dạng tag | `{release}-{feature-key}` <!-- fill: mẫu tên tag mà agent đánh khi một SPEC qua Gate 5 (CONVENTIONS mục 11); giữ mặc định hoặc ghi mẫu khác của dự án trong backtick, ví dụ `v{release}-{feature-key}` --> |
| Quy mô | <!-- fill: chọn một: standard \| small. small khi dự án có tối đa 15 FR, một người duyệt mọi gate và không có ràng buộc tuân thủ ở mục 7; khi đó các gate được trình gộp theo PLAYBOOK mục 5 --> |
| Vùng rủi ro cao | <!-- fill: thư mục hoặc từ trong đường dẫn mà SPEC nào chạm tới cũng phải là risk: high, mỗi mục trong backtick, ví dụ `apps/billing/`, `ledger`; ghi Không khi dự án không có vùng riêng ngoài danh sách chung ở CONVENTIONS mục 3 --> |
| Người duyệt | Theo mục 9 |

| Overlay | Stack profile | Lý do chọn |
| --- | --- | --- |
| <!-- fill: một hàng cho mỗi overlay, cùng thứ tự với overlays --> | `{{STACK_PROFILE}}` | <!-- fill: profile khớp theo tiêu chí ở PLAYBOOK mục 3, kèm ràng buộc ở mục 6 hoặc lý do kỹ thuật; không profile nào khớp thì ô Stack profile ghi none, cột này nêu thành phần nền không khớp và ghi "đề xuất ở ARCHITECTURE §2" theo PLAYBOOK mục 3 quy tắc 5 --> |
