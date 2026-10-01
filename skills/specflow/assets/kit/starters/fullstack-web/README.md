# Starter fullstack-web

Bộ template đã ghép sẵn cho dự án có hai bề mặt `backend-api` và `frontend-web` trong cùng một bộ tài liệu (Routing Decision: `overlays: [backend-api, frontend-web]`, `starter: fullstack-web`). Mỗi file là template lõi trong `core/` với các slot đã thay bằng nội dung của overlay [`backend-api`](../../overlays/backend-api/OVERLAY.md) và [`frontend-web`](../../overlays/frontend-web/OVERLAY.md) theo quy tắc nhiều overlay ở CONVENTIONS mục 2: slot có khối của cả hai bề mặt được tách bằng heading `Backend API` và `Frontend Web` ở cấp khối của slot, heading bên trong hạ một cấp. Starter không gắn stack profile: dòng `PROFILE-SLOT` và placeholder nguồn `Profile` được giữ lại để agent điền bằng profile của từng bề mặt chọn trong Intake.

## File trong starter

| File | Ghép từ | Đầu ra trong dự án | Giai đoạn |
| --- | --- | --- | --- |
| [SRS_Template.md](SRS_Template.md) | `core/01_SRS_Template.md` + `srs-sections.md` của hai overlay | `docs/srs/SRS.md` hoặc SRS modular | 1 |
| [ARCHITECTURE_Template.md](ARCHITECTURE_Template.md) | `core/02_Architecture_Core_Template.md` + `architecture-sections.md` của hai overlay | `docs/ARCHITECTURE.md` | 2 |
| [SPEC_Backend_Template.md](SPEC_Backend_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/backend-api/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` cho tính năng của API | 3 |
| [SPEC_Frontend_Template.md](SPEC_Frontend_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/frontend-web/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` cho màn hình | 3 |
| [CLAUDE.md.template](CLAUDE.md.template) | `core/06_Agent_Context_Template.md` + `verify-commands.md` của hai overlay + rule của hai overlay (Phụ lục A.3, A.4) | `CLAUDE.md`, `.claude/rules/` | 0 và 2 |

Template dùng thẳng từ core, không qua starter: [Intake](../../core/00_Project_Intake_Template.md), [Wireframe](../../core/07_Wireframe_Template/00_Wireframe_Index_Template.md) (Giai đoạn 1W, cho bề mặt `frontend-web`), [Hệ thống thiết kế](../../core/07_Wireframe_Template/Design_System_Template.md) và [token](../../core/07_Wireframe_Template/Design_Tokens_Template.json) (cùng Giai đoạn 1W), [ADR](../../core/03_ADR_Template.md), [Implementation Plan](../../core/05_Implementation_Plan_Template/plan.md).

## Cách dùng

1. Cài bộ mẫu vào `specflow/` theo README gốc; starter nằm ở `specflow/starters/fullstack-web/`.
2. Chạy prompt của `PROMPTS.md`; prompt tự chọn file của starter khi Routing Decision có `starter: fullstack-web`. SPEC của tính năng API dùng `SPEC_Backend_Template.md`; SPEC của màn hình dùng `SPEC_Frontend_Template.md`. Một tính năng chạm cả hai bề mặt có hai SPEC, SPEC giao diện ghi SPEC API trong `parent` và ở mục Phụ thuộc.
3. Khi chép một file starter sang dự án, áp stack profile của từng bề mặt (PLAYBOOK mục 4, bước 3): mỗi dòng `PROFILE-SLOT` nằm dưới heading của một bề mặt được thay bằng khối `PROFILE-CONTENT` cùng ID trong profile của bề mặt đó, hạ heading của khối một cấp; placeholder nguồn `Profile` lấy giá trị từ profile của bề mặt chứa nó, nên cùng một placeholder như `{{LINT_CMD}}` có giá trị khác nhau dưới `Backend API` và `Frontend Web`.
4. Hai bề mặt trong một repo đặt mã nguồn ở hai thư mục riêng, ghi ở ARCHITECTURE §4; lệnh verify của mỗi bề mặt chạy trong thư mục của bề mặt đó, và `paths` của rule trong `.claude/rules/` trỏ đúng thư mục ấy. Bề mặt web sinh kiểu API từ `openapi/openapi.yaml` của bề mặt API; nếu profile của bề mặt web đọc một đường dẫn khác, bước sinh mã chép file này sang đường dẫn đó và ARCHITECTURE §5 ghi cách làm.

## Bảo trì

- Không sửa file trong starter. Sửa `core/` hoặc overlay, rồi ghép lại starter theo CONVENTIONS mục 2; frontmatter của starter (`overlays`, `assembled_from`, `template_version`) cũng là kết quả của phép ghép.
- `scripts/check-templates.sh` tự ghép lại từng file starter từ nguồn khai báo trong `assembled_from` và `overlays`, rồi báo lỗi khi file trong starter khác kết quả ghép dù một ký tự.
