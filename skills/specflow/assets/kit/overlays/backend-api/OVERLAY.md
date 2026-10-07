---
doc_type: overlay
status: stable
version: 1.0.0
language: vi-en
surface: backend-api
---

# Overlay backend-api

## 1. Bề mặt (Surface)

Phần mềm chạy phía server, cung cấp API qua mạng (REST trên HTTPS là mặc định) và sở hữu dữ liệu lưu trữ: dịch vụ nghiệp vụ, background job, tích hợp hệ thống ngoài, webhook.

| Chọn overlay này khi | Không chọn khi |
| --- | --- |
| Dự án có API cho client khác gọi, có cơ sở dữ liệu riêng, có job chạy nền | Dự án chỉ gọi API của bên khác và không tự lưu dữ liệu (xem `frontend-web`, `mobile-app`) |

Dạng test `CONC` của bề mặt này: gửi N request song song (N ≥ 10) tới cùng một tài nguyên qua HTTP hoặc gọi service song song trên cơ sở dữ liệu thật, rồi kiểm tra bất biến bằng truy vấn trực tiếp sau khi mọi request kết thúc. Không dùng cơ sở dữ liệu giả lập cho test `CONC`.

## 2. Slot được cung cấp (Provided Slots)

| Slot | File | Nội dung | Có `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Kiểu dữ liệu nghiêm ngặt, toàn vẹn giao dịch, giao thức, thời gian (không phụ thuộc stack profile) | Không |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Giao diện phần mềm và truyền thông: client API, API bên thứ ba, webhook, object storage, email/SMS, định danh | Không |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | ERD Crow's foot và hướng dẫn cho lưu trữ quan hệ | Không |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, Level 3, góc nhìn triển khai | Không |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Quy tắc tầng trong cây thư mục | Có |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Quy tắc schema vật lý và schema theo DSL | Có |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Quy ước API HTTP, ánh xạ mã lỗi sang HTTP, transaction | Có |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Đóng gói, migration khi triển khai, phát hành, rollback | Không |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Endpoint, DTO, phản hồi, ma trận lỗi, fragment OpenAPI 3.1 ở tệp đi kèm (khung: `spec-openapi-fragment-template.yaml`) | Có |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration, e2e, contract, `CONC`, load smoke | Có |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Bảng lệnh verify | Không |

## 3. Thứ tự đọc khi ghép (Assembly Order)

1. File core của giai đoạn (`core/01`, `core/02`, `core/04`, `core/06`).
2. File này.
3. File section chứa khối SLOT-CONTENT tương ứng ở bảng mục 2.
4. Stack profile đã chọn trong Intake: bảng "Giá trị placeholder", mục `(Tech Stack)` và các khối PROFILE-CONTENT.
5. Rule của bề mặt ở `agent-rules/` khi tạo `.claude/rules/` (Giai đoạn 2).

Quy tắc ghép chi tiết ở CONVENTIONS mục 2 và PLAYBOOK mục 4.

## 4. Stack profile (Stack Profiles)

| Profile | Stack | File |
| --- | --- | --- |
| `node-nestjs-prisma` | Node.js, NestJS, Prisma, PostgreSQL | [stack-profiles/node-nestjs-prisma.md](stack-profiles/node-nestjs-prisma.md) |
| `python-fastapi-sqlalchemy` | Python, FastAPI, SQLAlchemy 2 async, Alembic, PostgreSQL | [stack-profiles/python-fastapi-sqlalchemy.md](stack-profiles/python-fastapi-sqlalchemy.md) |

Stack khác chưa có profile: đề xuất giá trị placeholder và nội dung profile trong ARCHITECTURE §2 kèm ADR (PLAYBOOK mục 3, quy tắc 5).

## 5. Rule cho agent (Agent Rules)

| File | Chép thành | Áp dụng cho |
| --- | --- | --- |
| [agent-rules/backend-golden-rules.md](agent-rules/backend-golden-rules.md) | `.claude/rules/backend-golden-rules.md` | Mã nguồn backend (`paths` theo cây thư mục ở ARCHITECTURE §4) |

## 6. Checklist riêng của bề mặt (Surface Checklist)

Tự kiểm cùng checklist "Overlay đã áp" ở PLAYBOOK mục 4.

| Kiểm tra | Tài liệu | Đạt |
| --- | --- | :---: |
| ERD dùng ký hiệu Crow's foot, mọi quan hệ có cardinality, tên thực thể khớp Data Dictionary | SRS §4 | [ ] |
| Miền giá trị (enum) khớp nhau giữa SRS §4.2, SRS §10.1 và schema ARCHITECTURE §5 | SRS, ARCHITECTURE | [ ] |
| Mọi mã lỗi ở SRS §6.3 có trong ARCHITECTURE §7.1 và có ánh xạ HTTP | ARCHITECTURE §7 | [ ] |
| Schema vật lý migrate được ngay: kiểu cụ thể, khóa ngoại có quy tắc xóa, index, ràng buộc duy nhất | ARCHITECTURE §5 | [ ] |
| Mỗi endpoint trong SPEC có ma trận lỗi và fragment OpenAPI 3.1 | SPEC §3 | [ ] |
| Mỗi thao tác ghi không idempotent tự nhiên có cơ chế idempotency duy nhất | SPEC §5.3 | [ ] |
