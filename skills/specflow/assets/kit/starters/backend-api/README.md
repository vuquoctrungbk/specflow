# Starter backend-api

Bộ template đã ghép sẵn cho dự án có một bề mặt `backend-api` (Routing Decision: `overlays: [backend-api]`, `starter: backend-api`). Mỗi file là template lõi trong `core/` với các slot đã thay bằng nội dung của overlay [`backend-api`](../../overlays/backend-api/OVERLAY.md). Starter không gắn stack profile: dòng `PROFILE-SLOT` và placeholder nguồn `Profile` được giữ lại để agent điền bằng profile chọn trong Intake.

## File trong starter

| File | Ghép từ | Đầu ra trong dự án | Giai đoạn |
| --- | --- | --- | --- |
| [SRS_Template.md](SRS_Template.md) | `core/01_SRS_Template.md` + `overlays/backend-api/srs-sections.md` | `docs/srs/SRS.md` hoặc SRS modular | 1 |
| [ARCHITECTURE_Template.md](ARCHITECTURE_Template.md) | `core/02_Architecture_Core_Template.md` + `overlays/backend-api/architecture-sections.md` | `docs/ARCHITECTURE.md` | 2 |
| [SPEC_Template.md](SPEC_Template.md) | `core/04_Spec_Core_Template.md` + `overlays/backend-api/spec-contract-sections.md` | `docs/specs/SPEC_<FEATURE_KEY>.md` | 3 |
| [CLAUDE.md.template](CLAUDE.md.template) | `core/06_Agent_Context_Template.md` + `overlays/backend-api/verify-commands.md` + rule của overlay (Phụ lục A.3) | `CLAUDE.md`, `.claude/rules/` | 0 và 2 |

Template dùng thẳng từ core, không qua starter: [Intake](../../core/00_Project_Intake_Template.md), [ADR](../../core/03_ADR_Template.md), [Implementation Plan](../../core/05_Implementation_Plan_Template/plan.md).

## Cách dùng

1. Cài bộ mẫu vào `specflow/` theo README gốc; starter nằm ở `specflow/starters/backend-api/`.
2. Chạy prompt của `PROMPTS.md`; prompt tự chọn file của starter khi Routing Decision có `starter: backend-api`.
3. Khi chép một file starter sang dự án, áp stack profile đã chọn (PLAYBOOK mục 4, bước 3): thay mỗi dòng `PROFILE-SLOT` bằng khối `PROFILE-CONTENT` cùng ID trong profile, thay placeholder nguồn `Profile` bằng bảng "Giá trị placeholder", và thêm profile vào `assembled_from`.

## Bảo trì

- Không sửa file trong starter. Sửa `core/` hoặc `overlays/backend-api/`, rồi ghép lại starter theo CONVENTIONS mục 2; frontmatter của starter (`overlays`, `assembled_from`, `template_version`) cũng là kết quả của phép ghép.
- `scripts/check-templates.sh` tự ghép lại từng file starter từ nguồn khai báo trong `assembled_from` và `overlays`, rồi báo lỗi khi file trong starter khác kết quả ghép dù một ký tự. Sửa nguồn mà chưa ghép lại starter thì checker không pass.
