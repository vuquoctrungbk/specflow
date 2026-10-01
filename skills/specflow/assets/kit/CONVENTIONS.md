---
doc_type: conventions
status: stable
version: 2.8.0
language: vi-en
---

# Quy ước bộ mẫu specflow (specflow Conventions)

Hợp đồng kỹ thuật bắt buộc cho mọi template, overlay, stack profile, starter, ví dụ và mọi tài liệu agent sinh ra từ bộ mẫu. Đây là nơi duy nhất định nghĩa placeholder, slot, frontmatter, ID scheme, chính sách ngôn ngữ, bố cục tài liệu dự án, quy tắc định dạng và tiêu chuẩn UI/UX của wireframe (mục 10); file khác chỉ tham chiếu, không định nghĩa lại. Mọi thay đổi ở đây MUST tăng `version` và ghi vào `CHANGELOG.md`. Từ khóa MUST, MUST NOT, SHOULD, MAY hiểu theo RFC 2119 và RFC 8174: chỉ mang nghĩa này khi viết in hoa. MUST tương đương `shall` của ISO/IEC/IEEE 29148, SHOULD tương đương `should`.

## 1. Biến giữ chỗ (Placeholder)

- Placeholder của bộ mẫu có đúng một dạng `{{UPPER_SNAKE}}`, tức chuỗi khớp biểu thức `\{\{[A-Z][A-Z0-9_]*\}\}`. Dấu `{{` trong cú pháp khác (biểu thức `${{ }}` của CI, JSX, Mermaid, template engine) không phải placeholder.
- Dạng in hoa dành riêng cho bộ mẫu. Biến trong prompt của sản phẩm (prompt spec của overlay `ai-llm-app`) viết `{{lower_snake}}`.
- Không dùng `[...]`, `<...>` hay chữ mô tả làm placeholder. Ký hiệu mẫu (pattern notation) như `{MOD}`, `NNN`, `<slug>`, `{YYMMDD-HHmm}` chỉ mô tả định dạng tên và ID trong file hạ tầng, `README.md`, khối Documentation Layout và chú thích `fill`; nội dung sẽ được chép vào tài liệu dự án không dùng ký hiệu này ngoài chú thích `fill`.
- Placeholder chỉ dùng cho giá trị một dòng. Nội dung tự do dùng chú thích `<!-- fill: ... -->` đặt đúng chỗ cần viết; hướng dẫn cho placeholder đặt ngay sau nó trong chú thích này.
- Placeholder buộc chọn ghi tập giá trị hợp lệ: `<!-- fill: chọn một: A | B | C -->`. Tài liệu sinh ra MUST NOT còn dạng "A hoặc B". Lựa chọn có hệ quả kiến trúc được đánh dấu `có ADR` (trong chú thích `fill` hoặc cột định dạng của catalog) và MUST được một ADR bao phủ; lựa chọn khác chỉ cần ghi giá trị.
- Frontmatter YAML: placeholder đặt trong nháy kép, kể cả khi nằm trong list (`title: "{{FEATURE_NAME}}"`, `parent: ["docs/specs/SPEC_{{FEATURE_KEY}}.md"]`). Khóa danh sách (`parent`, `overlays`, `assembled_from`) luôn là YAML list; template ghi sẵn giá trị cố định nếu có (ví dụ `parent` của SRS luôn gồm Intake), còn lại để `[]` cho agent điền khi tạo tài liệu.
- Mục không áp dụng: giữ heading, ghi `N/A: <lý do>`, MUST NOT xóa mục. Bảng có hàng mẫu: nhân bản hàng theo nhu cầu, xóa hàng mẫu không dùng.
- Tài liệu sinh ra MUST NOT còn placeholder, chú thích `fill` (dạng `<!-- fill: ... -->` hay `<!-- fill -->`), `<!-- slot-hint:`, dòng `<!-- SLOT` hay `<!-- PROFILE-SLOT`.
- Placeholder mới MUST được thêm vào catalog dưới đây trước khi dùng. `scripts/check-templates.sh` coi mọi hàng có ô đầu là placeholder là catalog. Cột "Nguồn" cho biết ai cấp giá trị: `Intake`, `Agent` (agent chốt khi soạn tài liệu), `Người dùng` (thay trước khi gửi prompt), `Profile` (bảng "Giá trị placeholder" của stack profile thuộc bề mặt chứa placeholder). Placeholder nguồn `Profile` chỉ được dùng trong file của overlay, không dùng trong core và không dùng trong khối cho slot `srs.*` (phiên bản cụ thể chốt ở ARCHITECTURE).

| Placeholder | Ý nghĩa | Định dạng hoặc giá trị hợp lệ | Nguồn |
| --- | --- | --- | --- |
| `{{PROJECT_NAME}}` | Tên dự án | Văn bản tự do | Intake |
| `{{PROJECT_SLUG}}` | Tên ngắn dùng trong đường dẫn | `kebab-case` | Intake |
| `{{PROJECT_BRIEF}}` | Mô tả ý tưởng dự án gửi kèm Prompt 0 | Văn bản tự do | Người dùng |
| `{{DATE}}` | Ngày | `YYYY-MM-DD` | Agent |
| `{{AUTHOR}}` | Người hoặc agent soạn | Văn bản tự do | Agent |
| `{{APPROVER}}` | Người phê duyệt gate | Tên hoặc vai trò | Intake |
| `{{MODULE_ID}}` | ID phân hệ | `MOD-NN` | Agent |
| `{{MODULE_CODE}}` | Mã phân hệ trong ID yêu cầu | Xem mục 4, ví dụ `AUTH`, `UI-AUTH` | Người dùng, Agent |
| `{{MODULE_NAME}}` | Tên phân hệ | Văn bản tự do | Agent |
| `{{MODULE_SLUG}}` | Tên thư mục mã nguồn của phân hệ | `kebab-case`; backend dùng danh từ số nhiều; stack profile được quy định cách viết khác khi ngôn ngữ bắt buộc (ví dụ package Python dùng `snake_case`) | Agent |
| `{{PROMPT_ID}}` | ID của một prompt trong Prompt Spec (overlay `ai-llm-app`) | `PROMPT-{MOD}-NNN`, xem mục 4 | Agent |
| `{{ROLE_CODE}}` | Mã vai trò trong ID tác nhân `ACT_<ROLE>` | `UPPER_SNAKE` | Agent |
| `{{ACTOR_NAME}}` | Tên tác nhân trong sơ đồ và bảng | Văn bản tự do | Agent |
| `{{EXTERNAL_SYSTEM}}` | Tên hệ thống ngoài trong sơ đồ và bảng | Văn bản tự do | Agent |
| `{{COMPONENT_NAME}}` | Tên thành phần trong sơ đồ | Văn bản tự do | Agent |
| `{{ENTITY_NAME}}` | Tên thực thể trong ERD và schema | `UPPER_SNAKE` trong ERD, theo quy ước DSL trong schema | Agent |
| `{{RESOURCE_PATH}}` | Đường dẫn tài nguyên API sau tiền tố phiên bản | `kebab-case`, danh từ số nhiều | Agent |
| `{{ROUTE_PATH}}` | Đường dẫn trang của giao diện web hoặc màn hình của ứng dụng di động, không có dấu `/` đầu | Các đoạn `kebab-case` phân cách bằng `/`; đoạn động theo cú pháp của framework, ví dụ `[itemId]` | Agent |
| `{{STATE_NAME}}` | Tên trạng thái trong state machine | `UPPER_SNAKE` | Agent |
| `{{EVENT_NAME}}` | Tên sự kiện, chuyển trạng thái hoặc domain event | Văn bản tự do hoặc `dot.case` | Agent |
| `{{MESSAGE}}` | Nhãn cạnh hoặc thông điệp trong sơ đồ (mục đích, giao thức, lời gọi) | Văn bản tự do | Agent |
| `{{FEATURE_NAME}}` | Tên tính năng | Văn bản tự do | Người dùng, Agent |
| `{{FEATURE_KEY}}` | Khóa tính năng trong tên file SPEC | `UPPER_SNAKE` | Người dùng, Agent |
| `{{FEATURE_SLUG}}` | Khóa tính năng trong tên thư mục plan | `kebab-case` | Người dùng, Agent |
| `{{PLAN_DIR}}` | Tên thư mục plan trong `plans/` | `{YYMMDD-HHmm}-<slug>` | Người dùng |
| `{{RELEASE}}` | Nhãn đợt phát hành (bản phát hành) mà SPEC và plan thực hiện; giá trị của khóa `release` (mục 3) | Một nhãn ở cột Bản phát hành của SRS §6.1, ví dụ `R1`; tên các đợt dự kiến ghi ở Intake | Người dùng, Agent |
| `{{RELEASE_SLUG}}` | Nhãn đợt phát hành trong tên thư mục plan của đợt | `kebab-case` của `{{RELEASE}}`, ví dụ `r1` | Agent |
| `{{PHASE_TITLE}}` | Tên một pha của Implementation Plan | Văn bản tự do | Agent |
| `{{PRIORITY}}` | Mức ưu tiên của plan hoặc pha | `P1` \| `P2` \| `P3` | Agent |
| `{{EFFORT}}` | Ước lượng công | Số + `h` hoặc `d` | Agent |
| `{{SPEC_ID}}` | ID spec | `SPEC-{MOD}-NNN` | Người dùng, Agent |
| `{{SCR_ID}}` | ID màn hình của wireframe | `SCR-{MOD}-NN`, xem mục 4 | Agent |
| `{{COMPONENT_ID}}` | ID component của hệ thống thiết kế | `CMP-NN`, xem mục 4 | Agent |
| `{{PATTERN_ID}}` | ID pattern của hệ thống thiết kế | `PAT-NN`, xem mục 4 | Agent |
| `{{TEMPLATE_ID}}` | ID template của hệ thống thiết kế | `TPL-NN`, xem mục 4 | Agent |
| `{{SCREEN_NAME}}` | Tên màn hình trong wireframe và sơ đồ điều hướng | Văn bản tự do | Agent |
| `{{ENTRY_POINT}}` | Điểm vào của màn hình | Web: route dạng `/{{ROUTE_PATH}}`; mobile: deep link hoặc tên màn hình trong navigator | Agent |
| `{{ADR_NUMBER}}` | Số ADR | `NNNN` | Agent |
| `{{ADR_TITLE}}` | Tên quyết định kiến trúc | Văn bản tự do | Agent |
| `{{OVERLAYS}}` | Danh sách bề mặt dạng văn bản | Tên overlay, phân cách dấu phẩy | Intake |
| `{{STACK_PROFILE}}` | Stack profile của bề mặt chứa placeholder | Tên file trong `stack-profiles/`, không đuôi; hoặc `none` khi không profile nào khớp theo PLAYBOOK mục 3, lý do ghi ở cột Lý do chọn của Intake mục 14 | Intake |
| `{{DOCS_MODE}}` | Chế độ lưu trữ SRS | `monolithic` \| `modular` | Intake |
| `{{SOURCE_GLOB}}` | Glob thư mục mã nguồn mà một rule trong `.claude/rules/` áp dụng | Glob tính từ gốc dự án; nhiều thư mục thì mỗi glob một phần tử list | Agent |
| `{{WCAG_LEVEL}}` | Mức tuân thủ WCAG 2.2 | `A` \| `AA` \| `AAA` | Agent |
| `{{COVERAGE_THRESHOLD}}` | Ngưỡng coverage của NFR-MAINT | Số nguyên phần trăm; stack profile gợi ý mặc định | Agent |
| `{{HTTP_OR_DOMAIN_ERROR}}` | Mã lỗi của exception flow | HTTP status + error code, hoặc mã lỗi miền | Agent |
| `{{TOKEN_FORMAT}}` | Định dạng access token | Một giá trị, có ADR | Agent |
| `{{SIGNING_ALG}}` | Thuật toán ký token | Một giá trị, có ADR | Agent |
| `{{ACCESS_TTL}}` | Thời hạn access token | Số + đơn vị | Agent |
| `{{REFRESH_TTL}}` | Thời hạn refresh token | Số + đơn vị | Agent |
| `{{REFRESH_STORE}}` | Nơi lưu refresh token | Một nơi duy nhất, có ADR | Agent |
| `{{PAGINATION_STYLE}}` | Kiểu phân trang | `offset` \| `cursor`, có ADR | Agent |
| `{{ID_FORMAT}}` | Định dạng ID tài nguyên | Một giá trị, ví dụ `UUIDv7`, có ADR | Agent |
| `{{ISOLATION_LEVEL}}` | Mức isolation mặc định của transaction | Một giá trị | Profile |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | Quy tắc kiểu nghiêm ngặt của ngôn ngữ | Một câu | Profile |
| `{{RENDER_BOUNDARY_RULE}}` | Quy tắc ranh giới giữa mã render ở server và mã chạy ở trình duyệt | Một câu | Profile |
| `{{CODEGEN_CMD}}` | Lệnh sinh mã trước khi typecheck, test, build (client ORM, client API) | Một dòng lệnh, hoặc `N/A: <lý do>` | Profile |
| `{{LINT_CMD}}` | Lệnh lint | Một dòng lệnh | Profile |
| `{{TYPECHECK_CMD}}` | Lệnh typecheck | Một dòng lệnh, hoặc `N/A: <lý do>` | Profile |
| `{{UNIT_TEST_CMD}}` | Lệnh unit test | Một dòng lệnh | Profile |
| `{{INTEGRATION_TEST_CMD}}` | Lệnh integration test | Một dòng lệnh | Profile |
| `{{E2E_TEST_CMD}}` | Lệnh e2e test | Một dòng lệnh, hoặc `N/A: <lý do>` | Profile |
| `{{EVAL_CMD}}` | Lệnh chạy test đánh giá prompt với mô hình thật (`EVAL`, `INJ`, `COST`) | Một dòng lệnh | Profile |
| `{{COVERAGE_CMD}}` | Lệnh đo coverage | Một dòng lệnh | Profile |
| `{{BUILD_CMD}}` | Lệnh build | Một dòng lệnh | Profile |
| `{{AUDIT_CMD}}` | Lệnh kiểm tra lỗ hổng dependency | Một dòng lệnh | Profile |
| `{{MIGRATION_CHECK_CMD}}` | Lệnh kiểm tra schema và migration khớp nhau | Một dòng lệnh | Profile |
| `{{MIGRATION_DEPLOY_CMD}}` | Lệnh áp migration khi triển khai | Một dòng lệnh | Profile |
| `{{OPENAPI_LINT_CMD}}` | Lệnh kiểm tra tài liệu OpenAPI của API | Một dòng lệnh | Profile |
| `{{PLATFORM_CHECK_CMD}}` | Lệnh kiểm tra cấu hình nền tảng và độ tương thích phiên bản dependency với SDK của ứng dụng di động | Một dòng lệnh | Profile |

## 2. Slot và quy tắc ghép (Slot & Assembly)

| Dòng đánh dấu | Đặt ở | Ý nghĩa |
| --- | --- | --- |
| `<!-- SLOT: <slot.id> -->` | Core, PLAYBOOK | Điểm chèn nội dung overlay; luôn là phần cuối của mục chứa nó |
| `<!-- slot-hint: ... -->` | Tối đa hai dòng ngay sau dòng SLOT | Mô tả nội dung mong đợi; xóa khi ghép |
| `<!-- SLOT-CONTENT: <slot.id> -->` và `<!-- /SLOT-CONTENT -->` | File section của overlay | Mở và đóng khối nội dung overlay cho slot |
| `<!-- PROFILE-SLOT: <slot.id> -->` | Bên trong khối SLOT-CONTENT cùng ID | Điểm chèn nội dung stack profile |
| `<!-- PROFILE-CONTENT: <slot.id> -->` và `<!-- /PROFILE-CONTENT -->` | Stack profile | Mở và đóng khối nội dung profile cho PROFILE-SLOT cùng ID |

- Mỗi dòng đánh dấu đứng riêng một dòng; cú pháp minh họa trong khối code không được tính. Không lồng khối cùng loại.
- Overlay là thư mục `overlays/<surface>/` có `OVERLAY.md`. Mỗi overlay MUST cung cấp đủ mọi slot trong catalog, mỗi slot đúng một khối SLOT-CONTENT, đặt trong file ngoài `stack-profiles/`. Slot không áp dụng cho bề mặt vẫn có khối, nội dung là `N/A: <lý do>` hoặc tham chiếu.
- Stack profile là `overlays/<surface>/stack-profiles/<profile>.md`, cung cấp giá trị cụ thể theo ba cách: (1) mục "Giá trị placeholder" có bảng hàng `` `{{NAME}}` `` và giá trị một dòng, đủ cho mọi placeholder nguồn `Profile` mà overlay dùng; (2) một khối PROFILE-CONTENT cho mỗi dòng PROFILE-SLOT của overlay, không thừa không thiếu; (3) một mục có heading chứa `(Tech Stack)` với bảng công nghệ cùng cột với ARCHITECTURE §2.1 (trừ cột Bề mặt), để agent chép vào §2.1. Profile MUST NOT chứa khối SLOT-CONTENT.
- Heading trong khối không đánh số. Cấp heading cao nhất trong khối SLOT-CONTENT bằng cột "Cấp khối" của catalog; khối PROFILE-CONTENT dùng cấp bằng hoặc sâu hơn cấp của dòng PROFILE-SLOT trong khối chứa nó.
- Khối PROFILE-CONTENT có thể chứa chú thích `<!-- fill: ... -->` đánh dấu phần mẫu (ví dụ schema minh họa) mà agent thay bằng nội dung thật; phần không có chú thích `fill` được chép nguyên văn.
- Quy tắc ghép:
  1. Thứ tự đọc: file core, `OVERLAY.md`, file section của overlay, stack profile của bề mặt.
  2. Nội dung của một bề mặt cho slot X là phần giữa dòng mở và dòng đóng của khối SLOT-CONTENT X, trong đó mỗi dòng PROFILE-SLOT được thay bằng phần giữa dòng mở và dòng đóng của khối PROFILE-CONTENT cùng ID trong profile của bề mặt.
  3. Một overlay: thay dòng SLOT và các dòng slot-hint bằng nội dung của bề mặt.
  4. Nhiều overlay cùng cung cấp một slot: nối nội dung theo thứ tự `overlays` khai báo trong Intake. Mỗi bề mặt mở đầu bằng heading tên bề mặt ở cấp khối (ví dụ `### Backend API`); mọi heading bên trong hạ một cấp.
  5. Thay placeholder nguồn `Profile` bằng giá trị trong profile của bề mặt chứa placeholder. Khi nội dung bề mặt đã bị hạ cấp heading ở bước 4, heading của khối PROFILE-CONTENT chèn vào bề mặt đó cũng hạ đúng số cấp ấy.
  6. Ghi `overlays` và `assembled_from` vào frontmatter (mục 3).
- Bề mặt không có stack profile (Intake ghi `none`; áp cho dự án có Intake tạo từ template Intake `1.2.0` trở lên). Bước 2 và bước 5 không có nguồn profile, nên mỗi dòng PROFILE-SLOT được thay bằng nội dung viết cho dự án và mỗi placeholder nguồn `Profile` bằng giá trị của dự án, lấy từ: dự án greenfield, đề xuất ở ARCHITECTURE §2 kèm ADR (PLAYBOOK mục 3 quy tắc 5); dự án brownfield, Codebase Summary §7 (lệnh) và As-Is Architecture §2 (tech stack, cấu trúc). Khi nguồn đó chưa có (ví dụ `CLAUDE.md` khởi tạo ở Giai đoạn 0), mục chứa nội dung ấy ghi theo PLAYBOOK mục 2.1. Tài liệu ghi tên bề mặt đó ở khóa frontmatter `stack_profile_none` (mục 3); `assembled_from` ghi nguồn core hoặc starter và overlay như thường, không có mục `stack-profiles/` của bề mặt đó.
- Starter là core đã ghép với overlay, không gắn profile: starter không còn dòng SLOT nhưng giữ dòng PROFILE-SLOT và placeholder nguồn `Profile`. Khi dùng starter, agent làm bước 2 và bước 5 với profile đã chọn trong Intake. `CLAUDE.md.template` của starter còn thêm vào cuối Phụ lục A, theo thứ tự `overlays`, mỗi file trong `agent-rules/` của overlay thành một mục `### A.N. \`.claude/rules/<file>\`` (N tiếp theo sau A.2) chứa nguyên văn file trong một khối code `markdown`.
- Starter là kết quả cơ học của các quy tắc trên: `scripts/check-templates.sh` tự ghép lại mọi file starter từ nguồn khai báo (mục đầu `assembled_from` và `overlays`) và báo lỗi khi khác dù một ký tự. Sửa core hoặc overlay thì ghép lại starter; không sửa tay starter.
- Tên hiển thị bề mặt: `backend-api` là Backend API, `frontend-web` là Frontend Web, `mobile-app` là Mobile App, `ai-llm-app` là AI/LLM App.

| Dòng đánh dấu | Vị trí | Cấp khối | Overlay cung cấp |
| --- | --- | --- | --- |
| `<!-- SLOT: srs.constraints.technical -->` | `core/01_SRS_Template.md` §2.5 | `####` | Ràng buộc kỹ thuật của bề mặt: kiểu dữ liệu, nền tảng, trình duyệt hoặc OS, toàn vẹn giao dịch |
| `<!-- SLOT: srs.external-interfaces -->` | `core/01_SRS_Template.md` §3 | `###` | Mục chi tiết cho từng loại giao diện ngoài áp dụng với bề mặt (User, Hardware, Software, Communications Interfaces, Interfaces with Services theo ISO/IEC/IEEE 29148 §9.6.4), heading theo tên loại |
| `<!-- SLOT: srs.data-model -->` | `core/01_SRS_Template.md` §4.1 | `####` | Mô hình dữ liệu logic: ERD, view model, local store hoặc dataset |
| `<!-- SLOT: arch.views -->` | `core/02_Architecture_Core_Template.md` §3 | `###` | C4 Level 2, Level 3 hoặc sơ đồ tương đương của bề mặt, và deployment view |
| `<!-- SLOT: arch.layout -->` | `core/02_Architecture_Core_Template.md` §4 | `###` | Cây thư mục theo tầng và vị trí file test |
| `<!-- SLOT: arch.schema -->` | `core/02_Architecture_Core_Template.md` §5 | `###` | Schema vật lý hoặc schema dữ liệu theo DSL của profile |
| `<!-- SLOT: arch.conventions -->` | `core/02_Architecture_Core_Template.md` §7 | `###` | Quy ước giao tiếp của bề mặt và cách ánh xạ mã lỗi của Error Code Registry (§7.1) sang bề mặt |
| `<!-- SLOT: arch.deployment -->` | `core/02_Architecture_Core_Template.md` §8 | `###` | Topology, build, release, migration khi deploy, rollback |
| `<!-- SLOT: spec.contract -->` | `core/04_Spec_Core_Template.md` §3 | `###` | Hình dạng contract: endpoint và DTO, màn hình và UI state, prompt spec |
| `<!-- SLOT: spec.test-types -->` | `core/04_Spec_Core_Template.md` §9 | `###` | Loại test đặc thù bề mặt, dạng test `CONC` của bề mặt, công cụ, vị trí file |
| `<!-- SLOT: playbook.verify-commands -->` | `PLAYBOOK.md` §11 và `core/06_Agent_Context_Template.md` | `###` | Lệnh verify theo stack profile và điều kiện pass |

## 3. Siêu dữ liệu đầu file (Frontmatter)

Mọi file `.md` của bộ mẫu (trừ `README.md`, `CHANGELOG.md`) và mọi tài liệu sinh ra MUST bắt đầu bằng YAML frontmatter.

- File hạ tầng (`doc_type` thuộc nhóm hạ tầng ở cuối mục) dùng `version` cho chính nó.
- Template là file trong `core/`, `brownfield/`, `starters/` hoặc `overlays/` có `doc_type` của tài liệu dự án hay tài liệu brownfield. Template mang sẵn frontmatter của tài liệu đầu ra để agent chép nguyên file rồi điền, nên trong template `version` luôn là `0.1.0` (version khởi tạo của đầu ra) và version của chính template ghi ở `template_version`.
- Tài liệu sinh ra giữ `template_version` chép từ template và ghi `assembled_from`: `path@version` của mọi nguồn đã ghép, tính từ gốc bộ mẫu. Nguồn là template (có `template_version`, kể cả template nằm trong `overlays/`) lấy `template_version`; nguồn là file hạ tầng (overlay section, stack profile) lấy `version`. Starter ghi sẵn nguồn core và overlay; agent thêm stack profile. `scripts/check-templates.sh` cảnh báo khi nguồn hiện tại mới hơn mục `assembled_from` ở mức MINOR hoặc MAJOR, và báo lỗi khi mục đó mới hơn nguồn. Bản PATCH của nguồn chỉ sửa câu chữ, không đổi cấu trúc hay quy tắc, nên không đòi ghép lại tài liệu.
- Cổng theo phiên bản template của một tài liệu (ví dụ "áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên") đọc theo một cách duy nhất: khóa `template_version` của chính tài liệu đó; tài liệu không có khóa này (ví dụ tài liệu từ trước khi mục này ghi `template_version`, hoặc fixture chỉ có `assembled_from`) thì đọc version ghi ở mục `assembled_from` cho nguồn tương ứng.

| Khóa | Bắt buộc với | Giá trị |
| --- | --- | --- |
| `doc_type` | Mọi file | Xem danh sách dưới bảng |
| `status` | Mọi file | Theo bảng trạng thái theo `doc_type` ở cuối mục |
| `version` | Mọi file | SemVer. Tài liệu sinh ra bắt đầu `0.1.0`; `1.0.0` là bản được duyệt đầu tiên |
| `language` | Mọi file | `vi-en` |
| `template_version` | Template, starter | Template: version của chính template. Starter: bằng `template_version` của file core nguồn (mục đầu `assembled_from`), vì starter được ghép cơ học từ nguồn; thay đổi của overlay trong starter thấy qua các mục overlay của `assembled_from` |
| `assembled_from` | Starter, tài liệu sinh ra | YAML list `path@version` |
| `parent` | Tài liệu sinh ra, trừ intake | YAML list đường dẫn (tính từ gốc dự án) tới tài liệu thượng nguồn |
| `overlays` | Tài liệu sinh ra | YAML list bề mặt, ví dụ `[backend-api, frontend-web]` |
| `module_id` | Tùy chọn | `MOD-NN` |
| `surface` | Overlay, overlay-section, profile | Tên overlay |
| `profile` | Profile | Tên profile |
| `stack_profile_none` | Tài liệu sinh ra có nguồn cần stack profile (ARCHITECTURE, SPEC, `CLAUDE.md`, rule trong `.claude/rules/`) khi ít nhất một bề mặt của nó không có profile khớp; không dùng ở tài liệu khác. Áp cho dự án có Intake tạo từ template Intake `1.2.0` trở lên | Danh sách tên overlay (bề mặt) không có profile khớp, ví dụ `[backend-api]`. Bề mặt khác của cùng tài liệu vẫn ghi profile ở `assembled_from`. `scripts/check-templates.sh` không đòi mục `stack-profiles/` cho bề mặt có tên trong danh sách, và báo lỗi khi bề mặt có tên trong danh sách mà `assembled_from` vẫn có profile của nó |
| `spec_id` | Spec, implementation phase; implementation plan tạo từ template plan `1.1.0` trở xuống | `SPEC-{MOD}-NNN`. Ở pha của plan theo đợt, `spec_id` là một phần tử của `spec_ids` của `plan.md` |
| `release` | Implementation plan tạo từ template plan `1.2.0` trở lên; spec tạo từ template SPEC `1.2.0` trở lên ở dự án có Intake tạo từ template Intake `1.3.0` trở lên | Đúng một nhãn ở cột Bản phát hành của SRS §6.1, ví dụ `R1`. Plan: đợt mà plan thực hiện (mục 9). Spec: đợt của SPEC; mọi FR ở SPEC §1.5 có Bản phát hành bằng nhãn này (PLAYBOOK mục 2.4), trừ SPEC `superseded` (PLAYBOOK mục 8). SPEC tạo từ template cũ hơn không có khóa và vẫn hợp lệ; đợt của nó là Bản phát hành của các FR ở §1.5. Dự án có Intake cũ hơn `1.3.0` không ghi khóa này ở SPEC |
| `spec_ids` | Implementation plan tạo từ template plan `1.2.0` trở lên | YAML list `SPEC-{MOD}-NNN`: mọi SPEC của đợt `release` mà plan thực hiện (mục 9) |
| `prompt_id` | Prompt spec | `PROMPT-{MOD}-NNN` |
| `paths` | Rule trong `.claude/rules/` | Danh sách glob mà rule áp dụng (khóa của Claude Code) |
| `adr_id`, `date`, `deciders`, `superseded_by` | ADR (`superseded_by` khi status là `superseded`) | `ADR-NNNN`, `YYYY-MM-DD`, danh sách người quyết định, `ADR-NNNN`. MADR 4.0.0 gọi khóa này là `decision-makers`; specflow giữ `deciders` có chủ ý để ADR đã có không phải đổi khóa |
| `title`, `description`, `priority`, `effort`, `tags`, `created` | Implementation plan | Theo mục 9 |

`doc_type` hợp lệ:

- Tài liệu dự án: `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `adr`, `spec`, `prompt-spec`, `implementation-plan`, `implementation-phase`, `agent-context`, `agent-rule`.
- Tài liệu brownfield: `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan`.
- File hạ tầng của bộ mẫu: `playbook`, `conventions`, `overlay`, `overlay-section`, `profile`, `spec-addendum`.

`wireframe-index` là chỉ mục wireframe `docs/wireframes/00_WIREFRAME_INDEX.md`; chỉ mục không đặt tên `README.md` vì `README.md` được miễn frontmatter. `wireframe-screen` là trang của một màn hình, `docs/wireframes/SCR-<MOD>-NN.md`. Hai loại này thuộc Giai đoạn 1W (PLAYBOOK mục 2.2.1), áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên. `design-system` là tài liệu hệ thống thiết kế `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS mục 10.7); thuộc Giai đoạn 1W, áp cho dự án có chỉ mục wireframe từ template chỉ mục `1.3.0` trở lên và ít nhất một trang từ template trang `1.4.0` trở lên.

Trạng thái hợp lệ theo `doc_type` (`scripts/check-templates.sh` đọc bảng này). Tài liệu có `status: approved` có `version` từ `1.0.0` trở lên.

| `doc_type` | Trạng thái |
| --- | --- |
| `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `prompt-spec`, `agent-context`, `agent-rule`, `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan` | `draft`, `in-review`, `approved`, `superseded` |
| `spec` | `draft`, `in-review`, `approved`, `implemented`, `superseded` |
| `adr` | `proposed`, `accepted`, `rejected`, `deprecated`, `superseded` |
| `implementation-plan` | `pending`, `in-progress`, `completed` |
| `implementation-phase` | `todo`, `in-progress`, `done` |
| `playbook`, `conventions`, `overlay`, `overlay-section`, `profile`, `spec-addendum` | `draft`, `stable`, `deprecated` |

## 4. Quy ước ID (ID Scheme) và truy xuất nguồn gốc (Traceability)

`{MOD}` là mã phân hệ: 2 đến 6 chữ in hoa, có thể thêm đúng một đoạn con 2 đến 6 chữ in hoa sau dấu gạch (`AUTH`, `UI-AUTH`). `N` là chữ số, đệm số 0 bên trái. Dự án gọi API của một dự án khác đặt mã phân hệ khác mã phân hệ của API đó (ví dụ thêm tiền tố `UI-`), để ID của hai dự án không trùng nhau khi tài liệu tham chiếu chéo. Dự án brownfield đặt mã phân hệ ở Codebase Summary §3; SRS to-be dùng lại mã đó cho phân hệ còn tồn tại (`brownfield/PLAYBOOK_BROWNFIELD.md` mục 5.3).

| Loại | Mẫu | Định nghĩa tại |
| --- | --- | --- |
| Mục tiêu dự án | `GOAL-NN` | Intake §2.2 |
| Phân hệ | `MOD-NN` | SRS §1.2 |
| Tác nhân | `ACT_<ROLE>` | SRS §2.2 |
| Business rule | `BR-NNN` | SRS §5 |
| Yêu cầu chức năng | `FR-{MOD}-NNN` | SRS §6 |
| Màn hình (wireframe) | `SCR-{MOD}-NN`, file `docs/wireframes/SCR-<MOD>-NN.md` | SRS §3, cột `SCR ID` của bảng Giao diện người dùng; trang wireframe ở Giai đoạn 1W chi tiết hóa |
| Component (hệ thống thiết kế) | `CMP-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS mục 10.7) |
| Pattern (hệ thống thiết kế) | `PAT-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS mục 10.7) |
| Template (hệ thống thiết kế) | `TPL-NN` | `docs/design-system/DESIGN_SYSTEM.md` (CONVENTIONS mục 10.7) |
| Yêu cầu phi chức năng | `NFR-{CAT}-NN`, CAT thuộc `PERF`, `SEC`, `RELI`, `MAINT`, `USAB`, `FLEX`, `SAFE`, `I18N`, `LEGAL`, `OBS`, `DATA`, `COMPAT`, `COST`; ánh xạ sang ISO/IEC 25010 ở mục 8 | SRS §7 |
| Tiêu chí nghiệm thu | `AC-{MOD}-NN` | SRS §8 |
| Test case | `TC-{MOD}-{TYPE}-NN`, TYPE thuộc `UNIT`, `INT`, `E2E`, `CTR`, `CONC`, `LOAD`, `A11Y`, `VIS`, `EVAL`, `INJ`, `COST`, `SMOKE`, `REG` | SRS §8 (dự kiến), SPEC §9 (chốt); `REG` ở Regression Baseline §6.1 |
| Quyết định kiến trúc | `ADR-NNNN`, file `docs/adr/NNNN-<slug>.md` | ARCHITECTURE §12 |
| Spec | `SPEC-{MOD}-NNN`, file `docs/specs/SPEC_<FEATURE_KEY>.md` | SPEC frontmatter và §1 |
| Prompt (overlay `ai-llm-app`) | `PROMPT-{MOD}-NNN`, file `docs/prompts/PROMPT_<NAME>.md` | SRS §4.1 (bảng bộ dữ liệu đánh giá); Prompt Spec frontmatter và §1 dùng lại |
| Bất biến cốt lõi (Core Invariant) | `INV-NN`, đánh số riêng trong từng SPEC | SPEC §1.2 |
| Hành vi phải giữ (brownfield) | `RB-NNN` | Regression Baseline §3 |
| Giả định hoặc câu hỏi mở | `AQ-NN`, đánh số riêng trong từng tài liệu | Mục `Assumptions & Open Questions` |
| Mã lỗi | `UPPER_SNAKE` | Error Code Registry trong ARCHITECTURE §7.1 |

ID màn hình `SCR-{MOD}-NN` (áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên): `{MOD}` là mã phân hệ chủ của màn hình, tức phân hệ có FR chính mà màn hình hiện thực; NN duy nhất theo MOD trong toàn dự án, kể cả khi web và mobile dùng chung một mã phân hệ (bảng ở SRS §3 ghi bề mặt của từng màn hình). ID được đặt ở Giai đoạn 1, trong bảng Giao diện người dùng ở SRS §3, cột `SCR ID`, để SRS đã duyệt ở Gate 1 không phải sửa lại chỉ để điền ID sau Giai đoạn 1W; chỉ màn hình mới phát hiện ở Giai đoạn 1W mới làm SRS đổi theo PLAYBOOK mục 8. Dự án brownfield: màn hình không đổi theo Gap Analysis không có ID; ô `SCR ID` ghi `Giữ nguyên` (`brownfield/PLAYBOOK_BROWNFIELD.md` mục 5.3). ID màn hình bỏ đi không dùng lại.

Ý nghĩa TYPE: `CTR` contract test; `CONC` kiểm chứng bất biến dưới thao tác đồng thời hoặc xen kẽ, dạng cụ thể do overlay định nghĩa (request song song, bấm gửi hai lần, hai thiết bị cùng sửa khi offline); `EVAL` đánh giá mô hình trên dataset; `INJ` prompt injection và red-team; `COST` ngân sách token hoặc chi phí; `SMOKE` smoke test môi trường hoặc thiết bị; `REG` regression của hành vi `RB-*`.

Chuỗi truy xuất bắt buộc:

- `GOAL → FR, NFR`: cột Nguồn của FR (bảng thuộc tính SRS §6.1) và của NFR (SRS §7) dẫn `GOAL-NN` khi yêu cầu phục vụ một mục tiêu; mỗi `GOAL-NN` ở Intake được ít nhất một FR hoặc NFR dẫn. Áp cho SRS tạo từ template SRS `1.2.0` trở lên và Intake tạo từ template Intake `1.1.0` trở lên.
- `FR → SCR` (áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên và có Giai đoạn 1W): cột FR của bảng Giao diện người dùng ở SRS §3 và bảng đối chiếu của chỉ mục wireframe. Danh sách màn hình có một nguồn là SRS §3. Chỉ mục wireframe lặp lại danh sách đó ở danh mục màn hình, và người duyệt Gate 1W đối chiếu hai nơi (`scripts/check-templates.sh` kiểm điều này trên ví dụ của bộ mẫu); SPEC chỉ dẫn `SCR-*`, không định nghĩa màn hình. Bảng đối chiếu có đúng một hàng cho mỗi FR ở SRS §6.1 có ưu tiên khác `Won't` (FR `Won't` không được làm nên không có hàng), ghi một trong: các `SCR-*` hiện thực FR; `Không có giao diện` kèm lý do; hoặc, ở dự án brownfield, `Giữ nguyên` kèm dẫn ảnh chụp ở Regression Baseline §5. Trang wireframe dẫn ít nhất một FR có thật; AC mà trang dẫn có ở SRS §8 và thuộc một FR của trang. Cột FR ở hàng của một màn hình trong bảng Giao diện người dùng ở SRS §3 liệt kê đúng các FR mà màn hình đó hiện thực, tức đúng các FR có hàng đối chiếu ghi `SCR ID` của màn hình; hai nơi lệch nhau thì sửa SRS theo PLAYBOOK mục 8.
- `FR → AC → TC` trong SRS §8; `AC → TC → file test → tên test` trong SPEC §9. SPEC §9 ghi đúng file và tên test của từng TC. Tên test mô tả hành vi bằng tiếng Anh, ví dụ `rejects an expired access token`; không đưa TC ID hay ID quy trình vào tên test, chú thích mã, tên migration hay commit message, vì các ID này thuộc tài liệu và truy vết qua bảng.
- Mỗi Core Invariant `INV-NN` của spec có ít nhất một `TC-{MOD}-CONC-NN`.
- `NFR → TC`: SPEC §9 nhận `NFR-*` ở cột "AC hoặc INV". Một NFR ở SPEC §1.5 có cách kiểm `Test` ở bảng NFR của SRS §8 thì SPEC đó có test ghi NFR ở §9, hoặc ít nhất một TC mà SRS §8 lên kế hoạch cho NFR đã có trong SPEC §9 của một SPEC của dự án (NFR dùng chung nhiều phân hệ có thể được kiểm bởi test của phân hệ khác). TC dự kiến của phân hệ chưa có SPEC vẫn được ghi ở SRS §8. NFR kiểm bằng `Inspection`, `Demo` hoặc `Analysis` không cần TC. TC chạy trên môi trường thật (tải, smoke) được lên lịch ở plan như TC khác: pha viết kịch bản test và kiểm kịch bản chạy được; lần chạy trên staging ghi ở ARCHITECTURE §11, chặn bước triển khai production chứ không chặn Definition of Done của tính năng. Áp cho SRS tạo từ template SRS `1.2.0` trở lên.
- Đánh số TC: NN của `TC-{MOD}-{TYPE}-NN` duy nhất theo cặp (MOD, TYPE) trong toàn dự án. SPEC mới đánh số tiếp sau số lớn nhất đã có ở SRS §8, Regression Baseline §6.1 và các SPEC khác; test `REG` của brownfield theo cùng quy tắc (`brownfield/PLAYBOOK_BROWNFIELD.md` mục 5.3). SRS §8 ghi TC dự kiến; khi SPEC chốt TC, Sync Docs cập nhật SRS §8 theo SPEC §9, để mỗi TC ở SRS §8 của một AC hay NFR mà SPEC đã nhận có trong SPEC §9. Hai quy tắc này áp cho SPEC tạo từ template SPEC `1.1.0` trở lên. Ở Regression Baseline §6.1, mọi test bảo vệ một `RB-*` mang loại `REG`, kể cả test có sẵn trước Giai đoạn 0R, vì loại ghi vai trò bảo vệ hành vi chứ không ghi kiểu test; một test tham số hóa là một TC; TC dùng mã phân hệ của hành vi được bảo vệ, không phải mã phân hệ chứa file test. Ba quy tắc này và việc tính §6.1 khi đánh số áp cho dự án có Intake tạo từ template Intake `1.2.0` trở lên; ID đã duyệt không đánh số lại.
- `NFR → tactic → ADR` trong ARCHITECTURE §8; `MOD → thành phần → thư mục` trong ARCHITECTURE §4.
- Mỗi mã lỗi xuất hiện ở SRS hoặc SPEC MUST có trong Error Code Registry.

## 5. Ngôn ngữ (Language Policy)

- Tiêu đề và diễn giải viết tiếng Việt có dấu đầy đủ; thuật ngữ tiếng Anh đặt trong ngoặc ở lần xuất hiện đầu. Heading ở lần đầu theo dạng "Tiếng Việt (English Term)".
- Không dịch thuật ngữ kỹ thuật đã phổ biến: idempotency, transaction, middleware, race condition, endpoint, payload.
- Luôn dùng tiếng Anh cho: định danh code, tên file, tên bảng và cột, mã lỗi, ID yêu cầu (FR, NFR, AC, TC, ADR), commit message, tên test, tên branch. Từ khóa RFC 2119 viết in hoa tiếng Anh.
- Agent MUST NOT chuyển sang toàn tiếng Anh hoặc toàn tiếng Việt giữa chừng một tài liệu.

## 6. Bố cục tài liệu dự án sinh ra (specflow Standard Layout)

Bộ mẫu được cài vào thư mục `specflow/` ở gốc dự án (chỉ đọc; agent MUST NOT sửa file trong `specflow/`). `CLAUDE.md` của dự án MUST chép nguyên văn cả hai dòng dấu mốc dưới đây và toàn bộ nội dung giữa chúng vào mục `## Documentation Layout`; `scripts/check-templates.sh` đối chiếu từng ký tự ở template, starter và ví dụ của bộ mẫu.

<!-- BEGIN: docs-layout-override -->
Dự án này dùng bố cục tài liệu specflow. Bỏ qua bộ tên tài liệu `project-overview-pdr.md`, `system-architecture.md`, `code-standards.md`, `deployment-guide.md`, `codebase-summary.md`, `project-roadmap.md` của rule toàn cục và không tạo các file đó. Vai trò của chúng được thay như sau:

| Tên theo rule toàn cục | Thay bằng trong bố cục specflow |
| --- | --- |
| `project-overview-pdr.md` | `docs/intake/PROJECT_INTAKE.md` và SRS trong `docs/srs/` |
| `system-architecture.md` | `docs/ARCHITECTURE.md` |
| `code-standards.md` | ARCHITECTURE §1 (Golden Rules), §7 (conventions) và `.claude/rules/` |
| `deployment-guide.md` | ARCHITECTURE §8 (Deployment) và §11 (CI/CD) |
| `codebase-summary.md` | ARCHITECTURE §4 (layout); dự án brownfield dùng `docs/brownfield/CODEBASE_SUMMARY.md` |
| `project-roadmap.md` | Implementation Plan trong `plans/` và phạm vi trong SRS §1.2 |

```text
specflow/                                 # bộ mẫu specflow, chỉ đọc
docs/
├── intake/PROJECT_INTAKE.md
├── srs/SRS.md                        # monolithic
├── srs/00_SRS_MASTER.md              # modular: tổng quan, NFR, mô hình dữ liệu chung
├── srs/SRS_MODULE_<NAME>.md          # modular: use case của từng phân hệ
├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
├── ARCHITECTURE.md
├── adr/NNNN-<slug>.md
├── specs/SPEC_<FEATURE_KEY>.md
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

Khối của các bản trước vẫn hợp lệ: dự án đang dùng khối cũ không phải sửa `CLAUDE.md`, và `scripts/check-templates.sh` chấp nhận khối hiện tại cùng mọi khối cũ dưới đây. Mỗi khối cũ có nhãn riêng và được ghi thành diff so với khối hiện tại ở trên, theo thứ tự dòng của khối hiện tại. Dòng `+` đứng ngay sau một dòng `-` là dòng đổi: khối cũ có dòng `-` ở vị trí của dòng `+` đó. Dòng `+` không có dòng `-` ngay trước nó là dòng chèn thêm: khối cũ không có dòng đó. Mọi dòng khác của khối hiện tại giống hệt khối cũ.

- `docs-layout-legacy-2.0`: khối của bản `2.0.0` và `2.1.0`, định dạng plan theo `ak plan` và chưa có `docs/wireframes/` và `docs/design-system/`.
- `docs-layout-legacy-2.2`: khối của bản `2.2.0` và `2.3.0`, chưa có `docs/wireframes/` và `docs/design-system/`.
- `docs-layout-legacy-2.4`: khối của các bản `2.4.0` đến `2.7.0`, chưa có `docs/design-system/`.

<!-- BEGIN: docs-layout-legacy-2.0 -->
```diff
+├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
+├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
+├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
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
+├── wireframes/00_WIREFRAME_INDEX.md  # khi có giao diện (Giai đoạn 1W): chỉ mục, đối chiếu FR
+├── wireframes/SCR-<MOD>-NN.md        # một trang cho mỗi màn hình
+├── wireframes/html/SCR-<MOD>-NN.html # tùy chọn: HTML tĩnh low-fi
-├── design-guidelines.md              # tùy chọn, khi có frontend
+├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
+├── design-system/tokens.json         # token nguồn, định dạng DTCG
```
<!-- END: docs-layout-legacy-2.2 -->

<!-- BEGIN: docs-layout-legacy-2.4 -->
```diff
-├── design-guidelines.md              # tùy chọn, khi có frontend
+├── design-system/DESIGN_SYSTEM.md    # khi có giao diện (Giai đoạn 1W): hệ thống thiết kế
+├── design-system/tokens.json         # token nguồn, định dạng DTCG
```
<!-- END: docs-layout-legacy-2.4 -->

## 7. Định dạng (Formatting)

- Không dùng LaTeX. Dùng ký tự `≤ ≥ ≠ × Σ →` và đặt công thức trong inline code, ví dụ `total = Σ line_amount`.
- Mọi sơ đồ dùng Mermaid (`flowchart`, `sequenceDiagram`, `erDiagram`, `stateDiagram-v2`); C4 vẽ bằng `flowchart`. Không vẽ khung ASCII. Cây thư mục dùng khối `text`.
- Bảng markdown luôn có hàng header. Khối code luôn có nhãn ngôn ngữ. Không dùng emoji.
- Tên file: template lõi và template brownfield `NN_Name_Template.md`; template Implementation Plan là thư mục `core/05_Implementation_Plan_Template/` theo mục 9; template wireframe là thư mục `core/07_Wireframe_Template/` gồm `00_Wireframe_Index_Template.md` (chỉ mục), `SCR_Screen_Template.md` (trang màn hình), `Design_System_Template.md` (tài liệu hệ thống thiết kế) và `Design_Tokens_Template.json` (token mẫu); template bổ sung của overlay `Name_Template.md`; file section của overlay `kebab-case.md`, trừ `OVERLAY.md`; stack profile `stack-profiles/<profile>.md`; starter `<DOC>_Template.md` và `CLAUDE.md.template`; file hạ tầng viết hoa như `PLAYBOOK.md`, `PROMPTS.md`, `COMPATIBILITY.md`, `PLAYBOOK_BROWNFIELD.md`, `Spec_Brownfield_Addendum.md`.
- Heading của core và template brownfield đánh số (`## N.`, `### N.M.`), trừ template Implementation Plan (theo mục 9), mục `## Documentation Layout` và phụ lục của Agent Context; heading trong khối SLOT-CONTENT và PROFILE-CONTENT không đánh số.
- Mục bắt buộc theo `doc_type` (heading chứa đúng chuỗi, script đọc các dòng dưới):
  - `Assumptions & Open Questions`: mọi template và tài liệu sinh ra, trừ `implementation-phase`, `agent-rule`.
  - `Version History`: `intake`, `srs`, `srs-module`, `wireframe-index`, `wireframe-screen`, `design-system`, `architecture`, `spec`, `prompt-spec`, `codebase-summary`, `as-is-architecture`, `regression-baseline`, `gap-analysis`, `migration-plan`.
  - `Failure Modes`, `Eval Metric`: `prompt-spec`.
- Template không chứa ví dụ nghiệp vụ; ví dụ nằm trong `examples/<overlay>/`.
- Bố cục low-fi của trang wireframe (áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên) viết trong một khối `text`, không dùng ảnh hay công cụ vẽ. Khối chia màn hình thành vùng xếp từ trên xuống; mỗi vùng mở bằng một dòng `== Tên vùng ==` (ví dụ `== Header ==`, `== Nội dung ==`), các vùng cạnh nhau ghi trên cùng dòng mở, phân cách bằng ` | `. Dưới dòng mở, mỗi thành phần một dòng thụt hai dấu cách: `[Nhãn]` cho nút, `Nhãn: [____]` cho trường nhập, `( ) Nhãn` và `[ ] Nhãn` cho lựa chọn, `...` cho phần lặp của danh sách; dòng chữ thường là văn bản hoặc nhãn tĩnh; thành phần con thụt thêm hai dấu cách dưới thành phần cha (ví dụ các trường của một dòng danh sách); hộp thoại hay lớp phủ là một vùng `== Hộp thoại: Tên ==` đặt sau vùng mà nó che. Nhãn trùng cột thành phần của bảng thành phần trên trang. Khối chỉ vẽ trạng thái `Success`; bốn trạng thái còn lại mô tả ở bảng trạng thái của trang. Màn hình form mà `Success` là rời màn hình (chuyển trang, thông báo thay cho form) thì khối vẽ trạng thái `Initial` và ghi điều đó ngay dưới khối.
- HTML low-fi của wireframe là tùy chọn, mỗi màn hình một file tĩnh `docs/wireframes/html/SCR-<MOD>-NN.html` (áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên). File MUST chỉ dùng CSS viết trong thẻ `<style>` của chính file, dữ liệu mẫu tự đặt (không dùng dữ liệu người thật, secret hay URL nội bộ) và có thẻ `<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; img-src data:">` đặt trong `<head>` (trình duyệt bỏ qua thẻ này khi nó nằm ngoài `<head>`). Thang xám chỉ áp cho HTML của trang từ template trang cũ hơn `1.4.0`; HTML của trang từ template trang `1.4.0` trở lên dùng biến CSS đọc từ token theo CONVENTIONS mục 10.7, không bắt buộc thang xám. File MUST NOT có thẻ script, thuộc tính sự kiện `on...=`, thẻ `iframe`, `object`, `embed`, `base`, form gửi đi, stylesheet hay `@import` ngoài, thư viện CSS ngoài, dấu `\` trong thẻ `<style>` hay thuộc tính `style` (escape CSS), hay `&` trong thuộc tính `style` (thực thể HTML); và MUST NOT có URL `http:`, `https:` hay bắt đầu bằng `//` ở mọi thuộc tính nhận URL (`src`, `srcset`, `href`, `poster`, `background`, `ping`, `cite`, `data`), `url(` hoặc hàm CSS khác nhận URL như `image-set(`. Link chỉ trỏ tới file `SCR-*.html` cùng thư mục để bấm chuyển màn hình, hoặc tới `#id` trong cùng file (ví dụ để xem trạng thái khác bằng `:target`), kể cả dạng `SCR-*.html#id`. Khi HTML và trang Markdown lệch nhau, trang Markdown thắng.
- Link markdown chỉ dùng trong file hạ tầng và `README.md`, trỏ tới file của bộ mẫu bằng đường dẫn tương đối tồn tại. Nội dung sẽ được chép vào tài liệu dự án (template, starter, khối SLOT-CONTENT và PROFILE-CONTENT) ghi đường dẫn bằng inline code, không dùng link; ngoại lệ duy nhất là link từ `plan.md` tới file pha `phase-NN-<slug>.md` cùng thư mục trong bảng Phases của Implementation Plan.

## 8. Chất lượng yêu cầu trong SRS (Requirement Quality)

Mục này áp cho SRS tạo từ `core/01_SRS_Template.md` bản `1.1.0` trở lên (khóa `template_version` của tài liệu). SRS tạo từ bản cũ hơn vẫn hợp lệ cho tới khi được nâng lên bản mới. Chuẩn tham chiếu: ISO/IEC/IEEE 29148:2018 §5.2 cho cách viết yêu cầu, ISO/IEC 25010:2023 cho nhóm NFR.

Phát biểu yêu cầu (Requirement Statement). Mỗi FR có một câu ở cột `Phát biểu yêu cầu` của bảng danh mục SRS §6.1. Chủ ngữ là hệ thống hoặc một phân hệ; câu chứa đúng một từ khóa `MUST` hoặc `MUST NOT` và nêu một hành vi kiểm chứng được. Câu viết theo một trong năm mẫu EARS (Easy Approach to Requirements Syntax):

| Mẫu | Khuôn câu |
| --- | --- |
| Luôn đúng (Ubiquitous) | `<hệ thống> MUST <phản hồi>` |
| Theo sự kiện (Event-driven) | `Khi <sự kiện>, <hệ thống> MUST <phản hồi>` |
| Theo trạng thái (State-driven) | `Trong khi <trạng thái>, <hệ thống> MUST <phản hồi>` |
| Tính năng tùy chọn (Optional feature) | `Ở nơi có <tính năng>, <hệ thống> MUST <phản hồi>` |
| Hành vi không mong muốn (Unwanted behaviour) | `Nếu <điều kiện>, thì <hệ thống> MUST <phản hồi>` |

Một FR nêu một hành vi (đặc tính singular). Hành vi phụ đi kèm nằm ở use case (§6.2) hoặc Business Rule (§5), không ghép thành nhiều hành vi trong một câu. FR đã duyệt mà gộp hai hành vi độc lập thì giữ ID cũ cho hành vi chính và thêm FR mới với số kế tiếp cho hành vi còn lại; không đánh số lại.

Thuộc tính yêu cầu (Requirement Attributes). Bảng danh mục §6.1 ghi Ưu tiên (MoSCoW), Bản phát hành (phân bổ yêu cầu theo 29148 §9.6.9, một nhãn như `R1`) và Cách kiểm chứng. Bảng thuộc tính §6.1 ghi Tiên quyết, Lý do, Nguồn và Rủi ro, một trong `Cao | Trung bình | Thấp`. Trong danh sách thuộc tính mẫu của 29148 §5.2.8, specflow dùng ID, ưu tiên, rủi ro, lý do và loại (FR, NFR, BR); version theo version của tài liệu; không dùng owner và difficulty. Bản phát hành, nguồn, tiên quyết và cách kiểm chứng là thuộc tính specflow thêm vào.

Cách kiểm chứng (Verification Method, 29148 §6.5.2): một trong `Test | Inspection | Demo | Analysis`, dùng chung cho FR, BR và NFR.

NFR. Ô Yêu cầu là nhãn ngắn; phần đo được nằm ở Chỉ số, Cách đo và Ngưỡng. NFR không áp dụng có ô Yêu cầu bắt đầu bằng `N/A:` kèm lý do; không viết "Không áp dụng". Mỗi NFR áp dụng có một dòng ở bảng NFR của SRS §8. Nhóm NFR ánh xạ sang ISO/IEC 25010:2023 như sau:

| Đặc tính ISO/IEC 25010:2023 | Nhóm NFR của specflow |
| --- | --- |
| Functional suitability | Không phải NFR: FR và AC ở SRS §6, §8 |
| Performance efficiency (time behaviour, resource utilization, capacity) | `PERF` |
| Compatibility (co-existence, interoperability) | `COMPAT` |
| Interaction capability (trước đây là usability) | `USAB` |
| Reliability (faultlessness, availability, fault tolerance, recoverability) | `RELI` |
| Security (confidentiality, integrity, non-repudiation, accountability, authenticity, resistance) | `SEC`; nhật ký kiểm toán phục vụ accountability ghi ở `OBS` |
| Maintainability | `MAINT` |
| Flexibility (adaptability, installability, replaceability, scalability) | `FLEX` |
| Safety | `SAFE` |

`I18N`, `LEGAL`, `OBS`, `DATA` và `COST` là nhóm mở rộng của specflow, không tương ứng một đặc tính 25010.

Từ mơ hồ (Vague Terms, 29148 §5.2.7). Cột Phát biểu yêu cầu của FR và cột Yêu cầu, Ngưỡng của NFR không chứa từ ở bảng dưới. `scripts/check-templates.sh` đọc bảng này và so khớp không phân biệt hoa thường; tài liệu lưu ở dạng Unicode NFC. Từ mơ hồ phụ thuộc ngữ cảnh (ví dụ "hỗ trợ", "tối thiểu" đi với con số) do người duyệt xét ở Gate 1, không nằm trong bảng.

| Từ mơ hồ | Lý do | Cách viết lại |
| --- | --- | --- |
| `thân thiện` | Chủ quan | Nêu thao tác và chỉ số đo được |
| `dễ dùng` | Chủ quan | Số bước, tỉ lệ hoàn thành trong thử nghiệm với người dùng |
| `nhanh chóng` | Không đo được | Ngưỡng thời gian kèm đơn vị |
| `tối ưu` | So sánh ngầm, không có mốc | Ngưỡng cụ thể |
| `hiệu quả` | Chủ quan | Chỉ số và ngưỡng |
| `linh hoạt` | Không kiểm chứng được | Nêu thay đổi được phép và cách thực hiện |
| `tốt hơn` | So sánh không có mốc | Mốc so sánh và con số |
| `nếu có thể` | Kẽ hở | Điều kiện rõ, hoặc hạ ưu tiên thành Should |
| `khi phù hợp` | Kẽ hở | Điều kiện rõ |
| `và/hoặc` | Logic mơ hồ | Tách thành hai yêu cầu hoặc chọn một |
| `v.v.` | Danh sách không đầy đủ | Liệt kê đủ |
| `nhưng không giới hạn` | Phạm vi mở | Liệt kê đủ |

## 9. Định dạng Implementation Plan (Implementation Plan Format)

Định dạng này là markdown thường, không cần công cụ riêng. Nó tương thích với lệnh `ak plan` của AgentKit, nhưng bộ mẫu không đòi cài `ak`. Trong dự án, người duyệt Gate 4 kiểm các quy tắc dưới; `scripts/check-templates.sh` kiểm chúng trên ví dụ của bộ mẫu.

- Mỗi plan là một thư mục `plans/{YYMMDD-HHmm}-<slug>/` gồm `plan.md` và các file pha `phase-NN-<slug>.md`, NN là hai chữ số liên tục từ `01`, `<slug>` là `kebab-case`.
- `plan.md` có frontmatter với `title` và các khóa của `implementation-plan` ở mục 3; `status` là `pending`, `in-progress` hoặc `completed`.
- Mỗi file pha có frontmatter với `phase` bằng số NN trong tên file, `title` và các khóa của `implementation-phase` ở mục 3; `status` là `todo`, `in-progress` hoặc `done`.
- `plan.md` có bảng Phases: mỗi file pha có đúng một dòng, cột Phase là link tương đối tới file đó, cột Status khớp `status` của pha. Cột Status so khớp không phân biệt hoa thường; `Pending` tương đương `todo`, `In progress` tương đương `in-progress`, `Completed` tương đương `done`.
- Không có link trong bảng Phases trỏ tới file pha không tồn tại.
- `plan.md` tạo từ template plan `1.3.0` trở lên có mục `Lịch sử phiên bản (Version History)`.

Plan theo đợt phát hành (Release Plan). Áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên; plan của các dự án này tạo từ template plan `1.2.0` trở lên. Một plan thực hiện mọi SPEC của một đợt (PLAYBOOK mục 2.5):

- Thư mục plan của đợt theo quy tắc chung `plans/{YYMMDD-HHmm}-<slug>/`; slug nên là `release-<release-slug>`, với `<release-slug>` là nhãn đợt viết `kebab-case`. Tên thư mục không phải điều kiện: đợt được xác định bằng khóa `release`, nên plan đã có giữ tên cũ khi nâng lên template `1.2.0`.
- `plan.md` có khóa `release` (nhãn đợt ở cột Bản phát hành của SRS §6.1) và `spec_ids` (YAML list mọi SPEC của đợt mà plan thực hiện), không có `spec_id`.
- Mỗi file pha có `spec_id` là một phần tử của `spec_ids`; một pha chỉ thuộc một SPEC. Pha của cùng một SPEC đứng liền nhau.
- Mỗi phần tử của `spec_ids` có ít nhất một pha và có file SPEC trong `docs/specs/`.
- SPEC trong `spec_ids` có khóa `release` (mục 3) thì khóa đó bằng `release` của plan.
- Mọi FR mà SPEC trong `spec_ids` dẫn ở SPEC §1.5 có Bản phát hành bằng `release`; SPEC nào dẫn FR của đợt thì có trong `spec_ids`, trừ SPEC `superseded` (PLAYBOOK mục 8).
- Plan tạo từ template plan `1.1.0` với một `spec_id` ở `plan.md` và ở mọi pha vẫn hợp lệ: đó là plan của một SPEC, cách làm theo tính năng của dự án có Intake cũ hơn `1.3.0`. Dự án đó lập plan mới từ template plan `1.2.0` trở lên thì ghi `spec_ids` chỉ có một SPEC và `release` là Bản phát hành của các FR mà SPEC dẫn; hai quy tắc đối chiếu đợt (FR mà SPEC dẫn thuộc đúng `release`; SPEC dẫn FR của đợt thì nằm trong `spec_ids`) chỉ áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên, vì SPEC của dự án cũ không chia theo đợt. Khi FR của SPEC thuộc nhiều đợt, `release` ghi đợt sớm nhất.

## 10. Tiêu chuẩn UI/UX (UI/UX Standards)

Mục này là nguồn duy nhất của quy tắc thiết kế giao diện mà wireframe ở Giai đoạn 1W (PLAYBOOK mục 2.2.1) phải theo. Overlay chỉ giữ con số và cách điền riêng của nền tảng; template, PLAYBOOK và rule cho agent dẫn về mục này, không viết lại quy tắc. Mục này áp cho wireframe tạo từ template wireframe `1.2.0` trở lên, xét theo từng file: chỉ mục theo `template_version` của chỉ mục, trang theo `template_version` của trang. Wireframe tạo từ bản cũ hơn vẫn hợp lệ cho tới khi được nâng lên bản mới theo PLAYBOOK mục 8.

### 10.1. Nền tảng (Foundation)

- Quy trình: thiết kế lấy con người làm trung tâm (human-centred design) theo ISO 9241-210:2019. Hiểu ngữ cảnh dùng ở SRS, thiết kế ở wireframe, đánh giá bằng bảng heuristic (10.3) và bảng mẫu lừa người dùng (10.4) trước Gate 1W, rồi sửa và đánh giá lại.
- Chất lượng tương tác: đặc tính Interaction capability của ISO/IEC 25010:2023, là nhóm NFR `USAB` (mục 8). Tám đặc tính con được xét ở các chỗ sau của wireframe; không có checklist riêng cho từng đặc tính.

| Đặc tính con ISO/IEC 25010:2023 | Nơi xét trên wireframe |
| --- | --- |
| Appropriateness recognizability | Mục đích của trang; nhãn ở bảng thành phần |
| Learnability | Trạng thái `Initial` của trang; sơ đồ điều hướng của chỉ mục |
| Operability | Bố cục low-fi, bảng thành phần, mục trợ năng của trang (bàn phím, focus, vùng chạm) |
| User error protection | Trạng thái `Error` và AC của trang; heuristic `H5`, `H9` |
| User engagement | Hướng thị giác và motion ở hệ thống thiết kế (10.7); không xét trên trang low-fi |
| Inclusivity | Mục trợ năng của trang; câu hỏi tự vấn ở 10.5 |
| User assistance | Mục trợ năng của trang; lối vào trợ giúp ở sơ đồ điều hướng (tiêu chí 3.2.6) |
| Self-descriptiveness | Nhãn ở bảng thành phần và bố cục low-fi; heuristic `H2`, `H6` |

- Trợ năng: WCAG 2.2 (W3C Recommendation) ở mức mà NFR-USAB của SRS chọn (`A`, `AA` hoặc `AAA`). WCAG 3.0 chưa dùng vì còn là bản nháp (Working Draft); bộ mẫu xét lại khi nó thành Candidate Recommendation.

### 10.2. Tiêu chí WCAG 2.2 xét ở wireframe (WCAG 2.2 Criteria at Wireframe Level)

Bảng dưới liệt kê tiêu chí thành công (success criterion) thấy được trên wireframe low-fi. Một tiêu chí áp cho dự án khi mức ở NFR-USAB bằng hoặc cao hơn mức của tiêu chí (`A` < `AA` < `AAA`); tiêu chí không áp ghi N/A kèm lý do ở chỗ ghi của nó. Tiêu chí WCAG khác vẫn áp theo NFR-USAB và được kiểm bằng test `A11Y` ở SPEC §9; bảng này chỉ nêu phần người duyệt Gate 1W xét được trên wireframe. Con số của nền tảng (vùng chạm, breakpoint) nằm ở mục Giai đoạn 1W của `OVERLAY.md` của bề mặt (10.6).

| Tiêu chí WCAG 2.2 | Mức | Ghi ở đâu trên wireframe |
| --- | --- | --- |
| `1.1.1` Non-text Content | A | Mục trợ năng của trang: nhãn thay thế của mỗi phần tử không có chữ (nút biểu tượng, hình ảnh) |
| `1.4.4` Resize Text | AA | Mục trợ năng của trang: bố cục khi chữ phóng to hoặc theo cỡ chữ hệ thống |
| `1.4.10` Reflow | AA | Bố cục low-fi vẽ ở độ rộng nhỏ nhất của bề mặt; không có cuộn ngang, trừ nội dung cần hai chiều như bảng lớn hay bản đồ |
| `2.1.1` Keyboard | A | Mục trợ năng của trang: mọi thao tác ở bảng thành phần làm được bằng bàn phím, hoặc bằng công nghệ hỗ trợ của hệ điều hành trên mobile |
| `2.4.3` Focus Order | A | Mục trợ năng của trang: thứ tự focus hoặc thứ tự đọc theo bố cục |
| `2.4.6` Headings and Labels | AA | Bảng thành phần: nhãn và tiêu đề nói đúng chức năng |
| `2.4.7` Focus Visible | AA | Mục trợ năng của trang: phần tử đang nhận focus thấy được |
| `2.4.11` Focus Not Obscured (Minimum) | AA | Mục trợ năng của trang: phần tử cố định (header, footer, banner, thanh tab) không che hết phần tử đang nhận focus |
| `2.5.7` Dragging Movements | AA | Bảng thành phần: thao tác kéo có cách thay bằng một lần chạm hoặc nhấp |
| `2.5.8` Target Size (Minimum) | AA | Mục trợ năng của trang: vùng chạm hoặc vùng bấm theo con số của overlay |
| `3.2.6` Consistent Help | A | Sơ đồ điều hướng của chỉ mục: lối vào trợ giúp lặp ở nhiều màn hình nằm cùng vị trí tương đối; ghi một lần ở chỉ mục |
| `3.3.1` Error Identification | A | Trạng thái `Error` của trang: lỗi chỉ rõ trường hay thao tác lỗi |
| `3.3.2` Labels or Instructions | A | Bảng thành phần: mỗi trường nhập có nhãn hoặc hướng dẫn |
| `3.3.7` Redundant Entry | A | Trạng thái `Initial` của bước sau trong luồng nhiều bước: dữ liệu đã nhập ở bước trước được điền sẵn hoặc chọn lại được, không bắt nhập lại |
| `3.3.8` Accessible Authentication (Minimum) | AA | Trang có dòng `Màn hình xác thực: Có`: cách xác thực không dựa vào kiểm tra nhận thức (ghi nhớ, chép lại, giải đố) hoặc có cách thay thế; cho dán và cho trình quản lý mật khẩu tự điền |
| `4.1.2` Name, Role, Value | A | Bảng thành phần và mục trợ năng: mỗi phần tử tương tác có tên và vai trò mà trình đọc màn hình đọc được |
| `4.1.3` Status Messages | AA | Mục trợ năng của trang: thông báo trạng thái (đang gửi, thành công, lỗi) được trình đọc màn hình đọc mà không chuyển focus |

### 10.3. Đánh giá heuristic (Heuristic Evaluation)

Chỉ mục wireframe có một bảng đánh giá theo 10 heuristic của Nielsen (Nielsen Norman Group), đúng một hàng cho mỗi khóa ở bảng dưới, theo thứ tự khóa. Khóa `H1` đến `H10` là khóa so khớp ổn định; tên tiếng Anh ghi đúng như nguồn. Người lập wireframe tự đánh giá toàn bộ luồng của chỉ mục và các trang, không chấm điểm. Mỗi hàng ghi mức vấn đề là một trong `Nghiêm trọng | Nhỏ | Không có`:

- `Nghiêm trọng`: người dùng không hoàn thành được nhiệm vụ của một FR, có thể mất dữ liệu hay tiền mà không biết, hoặc một tiêu chí ở 10.2 đang áp bị vi phạm.
- `Nhỏ`: người dùng vẫn hoàn thành nhiệm vụ nhưng chậm hơn hoặc dễ nhầm.
- `Không có`: không thấy vấn đề; ô đánh giá nêu căn cứ.

Vấn đề `Nghiêm trọng` được sửa trước Gate 1W. Cột Mức vấn đề ghi mức còn lại sau khi xử lý; vấn đề đã tìm thấy nêu ở cột Đánh giá và việc đã sửa ở cột Xử lý, nên vấn đề đã sửa hết ghi `Không có`. Hàng còn `Nhỏ` ghi ở cột Xử lý một mục `AQ-NN` ở phần Giả định và câu hỏi mở hoặc lý do chấp nhận. Chỉ mục có nhiều bề mặt dùng một bảng chung; vấn đề chỉ thuộc một bề mặt ghi tên bề mặt ở cột Xử lý. Dự án brownfield chỉ đánh giá màn hình có trang; màn hình `Giữ nguyên` không có trang nên không có đánh giá riêng.

| Khóa heuristic | Tên (NN/g) | Xét trên wireframe |
| --- | --- | --- |
| `H1` | Visibility of System Status | Trạng thái `Loading`, `Success`, `Error` cho biết việc gì đang xảy ra; số tiền, số lượng và trạng thái hiện trước khi người dùng quyết định |
| `H2` | Match Between the System and the Real World | Nhãn và thứ tự bước dùng ngôn ngữ của người dùng ở SRS, không dùng từ nội bộ |
| `H3` | User Control and Freedom | Sơ đồ điều hướng có lối quay lại, hủy hoặc hoàn tác cho mỗi luồng |
| `H4` | Consistency and Standards | Cùng một thao tác có cùng nhãn và vị trí qua các trang; theo quy ước của nền tảng ở overlay |
| `H5` | Error Prevention | Thao tác không hoàn tác được có bước xác nhận; ràng buộc nhập hiện trước khi gửi |
| `H6` | Recognition Rather than Recall | Thông tin cần cho bước sau hiện trên màn hình, không bắt nhớ từ bước trước |
| `H7` | Flexibility and Efficiency of Use | Luồng thường dùng có đường ngắn; không bắt đi qua bước thừa |
| `H8` | Aesthetic and Minimalist Design | Mỗi vùng của bố cục low-fi chỉ chứa thành phần mà FR của trang cần |
| `H9` | Help Users Recognize, Diagnose, and Recover from Errors | Trạng thái `Error` nói lỗi gì và cách khắc phục, gắn với trường hay thao tác lỗi |
| `H10` | Help and Documentation | Lối vào trợ giúp khi luồng cần giải thích; vị trí theo tiêu chí 3.2.6 |

### 10.4. Mẫu thiết kế lừa người dùng (Deceptive Patterns)

Năm mẫu dưới, theo tên loại của deceptive.design, thấy được trên wireframe low-fi. Chỉ mục wireframe có một bảng kiểm với đúng một hàng cho mỗi khóa `DP1` đến `DP5`, theo thứ tự khóa. Kết quả là `Không có` kèm căn cứ (trang, thành phần hoặc cạnh của sơ đồ điều hướng đã xem), hoặc `Có` kèm vị trí. Gate 1W chặn khi còn hàng `Có`. Mẫu thuộc về cách trình bày; khi bỏ mẫu cần đổi quy tắc nghiệp vụ (ví dụ thời điểm hiện phí) thì sửa SRS theo PLAYBOOK mục 8 trước. Dự án brownfield chỉ kiểm màn hình có trang, như ở 10.3.

| Khóa mẫu lừa | Tên (deceptive.design) | Dấu hiệu trên wireframe |
| --- | --- | --- |
| `DP1` | Preselection | Ô đồng ý, ô nhận tin hay lựa chọn có lợi cho bên cung cấp được chọn sẵn ở bảng thành phần hoặc bố cục (`[x] Nhãn`, `(x) Nhãn`) |
| `DP2` | Obstruction | Trong một luồng, lối từ chối, bỏ qua hay thoát cần nhiều bước hơn, bị ẩn hoặc kém nổi hơn lối đồng ý (so số cạnh ở sơ đồ điều hướng và thành phần ở bố cục) |
| `DP3` | Hidden costs | Phí, tổng tiền hay điều khoản ràng buộc chỉ hiện ở bước cuối hoặc sau khi đặt, không hiện ở bước người dùng chọn |
| `DP4` | Hard to cancel | Gói dịch vụ, đăng ký hay tài khoản bắt đầu được trong ứng dụng nhưng không có lối hủy, hoặc lối hủy phải qua kênh khác, trong sơ đồ điều hướng |
| `DP5` | Confirmshaming | Nhãn của lựa chọn từ chối bêu riếu hoặc làm người dùng thấy có lỗi |

Ranh giới giữa `DP2` và `DP4`: `DP2` xét một luồng đang làm (thanh toán, đăng ký, cấp quyền); `DP4` xét việc chấm dứt một quan hệ kéo dài (gói trả phí, nhận tin, tài khoản).

### 10.5. Câu hỏi tự vấn (Self-review Questions)

Các câu hỏi dưới không chặn gate và không có hàng ở chỉ mục; người lập wireframe tự hỏi trước khi trình Gate 1W, thay đổi phát sinh ghi như mọi thay đổi khác của wireframe.

- Thiết kế bao gồm (Microsoft Inclusive Design): ai bị loại khỏi luồng này (khuyết tật lâu dài, tạm thời hay do hoàn cảnh, như một tay bận hoặc trời nắng chói)? Giải pháp cho nhóm đó có giúp mọi người dùng khác không?
- Trợ năng nhận thức (W3C COGA "Making Content Usable"): nhãn và thông báo có dùng từ đơn giản, quen thuộc không? Biểu tượng có kèm chữ không? Luồng có bắt nhớ thông tin, có giới hạn thời gian hay gây áp lực không cần thiết không? Các bước có nhất quán và dễ đoán không?

### 10.6. Hướng dẫn theo nền tảng (Platform Guidance)

- Con số và hướng dẫn cấu trúc của nền tảng (vùng chạm tối thiểu, breakpoint, vùng an toàn, mẫu điều hướng, cử chỉ quay lại) ghi ở mục Giai đoạn 1W của `OVERLAY.md` của bề mặt, vì Giai đoạn 1W đọc file đó mà không đọc file section của overlay.
- Phong cách thị giác thuộc hệ thống thiết kế ở 10.7.
- Ứng dụng không chạy trên web áp tiêu chí WCAG viết theo ngữ web (trang, tiêu đề trang) theo WCAG2ICT của W3C, không tự suy diễn.

### 10.7. Hệ thống thiết kế (Design System)

Mục này là nguồn duy nhất của quy tắc hệ thống thiết kế theo tầng (layered design system) dùng ở Giai đoạn 1W. Áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên và có Giai đoạn 1W; xét theo từng file như câu mở mục 10: chỉ mục wireframe từ template chỉ mục `1.3.0`, trang wireframe từ template trang `1.4.0`. Tài liệu tạo từ template cũ hơn vẫn hợp lệ cho tới khi được nâng lên theo PLAYBOOK mục 8 (COMPATIBILITY mục 5).

Bảy tầng, từ nền tảng tới trải nghiệm:

| Tầng | Nội dung | Nơi ghi |
| --- | --- | --- |
| Foundation | Màu theo vai trò, typography, spacing, grid và breakpoint, iconography, elevation, radius, motion, giọng nội dung | `docs/design-system/DESIGN_SYSTEM.md` |
| Token | Giá trị máy đọc được của Foundation, theo DTCG, ba tầng `primitive`, `semantic`, `component` | `docs/design-system/tokens.json` (và file mode) |
| Primitive | Phần tử thị giác nhỏ nhất dùng token trực tiếp (màu nền, cỡ chữ, khoảng cách) | `docs/design-system/DESIGN_SYSTEM.md` |
| Component | Đơn vị giao diện có anatomy, variant, state riêng, ghép từ primitive và token | `docs/design-system/DESIGN_SYSTEM.md` |
| Pattern | Cách giải quyết một vấn đề tương tác, ghép nhiều component | `docs/design-system/DESIGN_SYSTEM.md` |
| Template | Cấu trúc vùng dùng chung cho nhiều trang, ghép pattern và component | `docs/design-system/DESIGN_SYSTEM.md` |
| Experience | Một màn hình cụ thể, chọn một Template và dẫn Pattern, Component | Trang `SCR-*` |

Hướng thị giác (visual direction): agent đề xuất 2 đến 3 hướng, mỗi hướng dẫn căn cứ ở thương hiệu, người dùng, lĩnh vực và giọng điệu của dự án; chủ dự án chọn đúng một hướng, tài liệu ghi lý do chọn. Theme mặc định của thư viện giao diện (ví dụ Material 3, Apple Human Interface Guidelines, Fluent 2) là một hướng như mọi hướng khác, chỉ dùng khi được chọn có chủ đích, không phải mặc định của bộ mẫu; tài liệu có dòng "Theme mặc định của thư viện" ghi `Không dùng` hoặc `Dùng có chủ đích` kèm lý do. Material 3, Apple HIG, Fluent 2 chỉ là tham khảo hoặc một hướng được chọn, không phải quy tắc bắt buộc.

Foundations: màu theo vai trò (không theo tên màu), typography (thang cỡ chữ, độ đậm, chiều cao dòng), spacing, grid và breakpoint (con số nền tảng dẫn `OVERLAY.md`, xem 10.6), iconography, elevation, radius, motion kèm chế độ giảm chuyển động (reduced motion), giọng nội dung.

Token (Design Token), theo DTCG Format Module 2025.10 (Design Tokens Community Group):

- Tập kiểu `$type` mà bộ mẫu chấp nhận, đúng 13 kiểu của DTCG:

  | Kiểu DTCG | Ghi chú |
  | --- | --- |
  | `color` | `$value` là object `colorSpace`, `components`, `hex` |
  | `dimension` | `$value` là object `value`, `unit` |
  | `fontFamily` | |
  | `fontWeight` | |
  | `duration` | |
  | `cubicBezier` | |
  | `number` | |
  | `strokeStyle` | |
  | `border` | Composite |
  | `transition` | Composite |
  | `shadow` | Composite |
  | `gradient` | Composite |
  | `typography` | Composite |

- Ba nhóm tầng cố định, mỗi tầng một quy tắc alias:

  | Nhóm tầng | Quy tắc alias |
  | --- | --- |
  | `primitive` | Có giá trị trực tiếp, không alias |
  | `semantic` | Alias tới token `primitive`; token composite được phép khi mọi giá trị con là alias xuống `primitive` |
  | `component` | Alias tới token `semantic`; token composite được phép khi mọi giá trị con là alias xuống `semantic` |

- Alias chỉ viết dạng `{a.b.c}`; bộ mẫu không dùng `$ref`, `$extends` hay `$root` của DTCG. `$type` phân giải theo đúng thứ tự: của chính token, rồi của token đích khi token là alias, rồi của nhóm gần nhất chứa token.
- `color`: `$value` là object có `colorSpace` bằng `srgb`, `components` khớp `hex` với sai lệch không quá 1/255 mỗi kênh, và `hex`; `hex` là nguồn duy nhất cho tính tương phản, cho CSS và cho công cụ sinh token khác.
- `dimension`: `$value` là object có `value` (số) và `unit` (`px` hoặc `rem`).
- Tên token không bắt đầu bằng `$` và không chứa `{`, `}`, `.`.
- Mode (sáng, tối, theo nền tảng): `tokens.json` là mode mặc định của dự án. Mỗi mode khác là một file `tokens.<mode>.json`, chỉ khai báo lại các token `semantic` đã có ở `tokens.json`, giữ nguyên `$type`; không có file resolver riêng. Dự án có cả web và mobile dùng một hệ thống token: token `semantic` dùng chung, mode phân biệt theo nền tảng khi cần.
- Tên biến CSS của một token là đường dẫn token bỏ tên nhóm tầng, nối các đoạn còn lại bằng `-` (ví dụ `semantic.color.text.default` thành `--color-text-default`); hai token khác nhau không được cho ra cùng một tên biến.
- Code và HTML chỉ dùng token `semantic` và `component`, không dùng thẳng token `primitive`.

Tương phản (contrast) theo cặp: tài liệu có một bảng cặp màu, mỗi hàng ghi token màu trước (chữ hoặc hình), token màu nền, token typography của chữ (cột Token chữ; ghi `Không` ở hàng phi văn bản), mode, loại (`chữ` hoặc `phi văn bản`), tỷ lệ tương phản đã tính và ngưỡng áp dụng. Chữ lớn theo định nghĩa WCAG được suy ra từ token typography ở cột Token chữ, không do người viết tự khai: `fontSize` từ 24px, hoặc từ 18,66px khi `fontWeight` từ 700 trở lên; `rem` tính theo 16px = 1rem. Ngưỡng theo WCAG 2.2: tiêu chí `1.4.3` (chữ thường 4.5:1, chữ lớn 3:1) và `1.4.11` (phi văn bản 3:1), luôn ở mức AA bất kể mức ở NFR-USAB; tính riêng theo từng mode từ giá trị `hex` của token. Cách tính, một nguồn cho mọi nơi: phân giải alias của mỗi token trong mode của hàng tới một màu đục (không có `alpha` nhỏ hơn 1); mỗi kênh `c` của `hex` (0 đến 255) chia 255, rồi lấy `c / 12.92` khi `c` không quá 0.04045, ngược lại `((c + 0.055) / 1.055)^2.4`; độ chói tương đối `L = 0.2126·R + 0.7152·G + 0.0722·B`; tỷ lệ `(L sáng + 0.05) / (L tối + 0.05)`, làm tròn xuống 2 chữ số, không làm tròn lên (4.499 ghi 4.49, không đạt 4.5). Tự kiểm không cần `scripts/`: tính từng hàng của bảng bằng một lệnh chạy được (`awk`, `python3` hay `node`), không tính nhẩm; checker của bộ mẫu chỉ là lựa chọn khi dự án có.

Danh mục (catalog) component, pattern, template: ID dạng `CMP-NN`, `PAT-NN`, `TPL-NN` (CONVENTIONS mục 4), đánh số trong phạm vi dự án. Nội dung tối thiểu của mỗi mục: component (anatomy, variant, state, hành vi bàn phím theo mẫu WAI-ARIA APG, token dùng, bề mặt áp dụng); pattern (vấn đề giải quyết, khi dùng, khi không dùng, component dùng, luồng, trạng thái); template (cấu trúc vùng, pattern dùng, component dùng, bề mặt áp dụng, thay đổi theo breakpoint). Danh mục chỉ liệt kê mục được ít nhất một trang dùng, trực tiếp hoặc gián tiếp qua cột Component dùng của một mục khác đang được dùng; không liệt kê mục không dùng.

Trang (Experience): mỗi trang chọn đúng một `TPL-*`; dòng Pattern ghi `PAT-*` hoặc `Không`; mỗi hàng của bảng thành phần có cột `Component ID` dẫn một `CMP-*` có trong danh mục. Vùng của bố cục low-fi (CONVENTIONS mục 7) theo đúng vùng mà Template đã chọn định nghĩa.

Chỉ dùng token: HTML low-fi của trang từ template trang `1.4.0` trở lên (file `docs/wireframes/html/SCR-<MOD>-NN.html` thuộc trang `SCR-<MOD>-NN.md` cùng tên) khai báo biến CSS trong khối `:root`, theo giá trị của mode có cột Áp khi ghi bề mặt của trang; trang không ghi mode nào thì `:root` theo mode mặc định. Ngoài khối `:root`, phần giá trị khai báo trong `<style>` không được chứa màu thô (`#…`, `rgb(`, `hsl(`, `oklch(`, `oklab(`); các thuộc tính spacing (`margin`, `padding`, `gap`, `row-gap`, `column-gap`, `inset`, `top`, `right`, `bottom`, `left`, kể cả dạng viết tắt như `margin-top`), radius (`border-radius` và các biến thể góc) và `font-size` chỉ được dùng `var(--…)` hoặc một trong các từ khóa `0`, `auto`, `100%`, `inherit`, `initial`, `unset`. Thuộc tính khác (khung thiết bị như `max-width`, độ dày viền) vẫn được ghi giá trị `px` thô. Quy tắc thang xám ở CONVENTIONS mục 7 chỉ còn áp cho HTML của trang từ template cũ hơn `1.4.0`; mọi quy tắc an toàn khác ở mục 7 giữ nguyên. Code (ngoài HTML low-fi) chỉ dùng token theo golden rule của overlay, áp khi dự án có `docs/design-system/`: màu, spacing, radius và cỡ chữ thô chỉ nằm ở file ánh xạ token trong code (biến CSS hoặc theme object). File đó là ánh xạ từ `tokens.json`, viết tay theo bảng ánh xạ của stack profile hoặc sinh bằng công cụ dự án chọn (bộ mẫu không cài công cụ build token), sửa cùng lúc với `tokens.json`; mọi nơi khác chỉ dùng token.

### 10.8. Tham khảo (References)

Các tài liệu dưới chỉ để tham khảo khi cần giải thích sâu hơn; không là nguồn của quy tắc MUST, vì nội dung của chúng đã được phủ bởi các chuẩn ở 10.1 đến 10.4.

- ISO 9241-11 (định nghĩa usability), ISO 9241-110 (nguyên tắc tương tác), ISO 9241-112 (trình bày thông tin), ISO 9241-125 (trình bày thị giác), ISO 9241-171 (trợ năng của phần mềm).
- ISO/IEC 40500: bản ISO của WCAG 2.2, nội dung kỹ thuật như WCAG 2.2.
- Tám quy tắc vàng của Shneiderman: phần lớn trùng 10 heuristic ở 10.3.
- EN 301 549 V4.1.1 và luật về trợ năng hay mẫu lừa người dùng của một vùng: chỉ là ví dụ; dự án chọn chuẩn hay luật mình phải theo ở Intake mục 7, bộ mẫu không đặt luật của vùng nào làm quy tắc.
