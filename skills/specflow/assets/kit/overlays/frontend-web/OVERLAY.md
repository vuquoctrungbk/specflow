---
doc_type: overlay
status: stable
version: 1.3.0
language: vi-en
surface: frontend-web
---

# Overlay frontend-web

## 1. Bề mặt (Surface)

Giao diện web chạy trên trình duyệt: trang render ở server, ở client hoặc kết hợp, gọi API của backend qua HTTPS. Bề mặt này không sở hữu dữ liệu lưu trữ nghiệp vụ; nguồn chân lý của dữ liệu và mã lỗi là API mà nó gọi.

| Chọn overlay này khi | Không chọn khi |
| --- | --- |
| Dự án có giao diện cho người dùng trên trình duyệt, gọi API của hệ thống mình hoặc của bên khác | Dự án chỉ cung cấp API (xem `backend-api`); ứng dụng cài trên điện thoại (xem `mobile-app`) |

Dạng test `CONC` của bề mặt này: kích hoạt một thao tác ghi nhiều lần liên tiếp (bấm đúp, Enter rồi bấm, gửi lại sau lỗi mạng) trên ứng dụng đã build, chặn lời gọi API bằng route giả lập của công cụ e2e, rồi đếm số request ghi thật sự gửi đi và khóa idempotency của chúng. Mỗi tab giữ khóa của riêng nó, nên hai tab cùng gửi là hai lần gửi độc lập; dạng test này không kiểm giữa các tab. Không dùng sleep để sắp thứ tự.

## 2. Slot được cung cấp (Provided Slots)

| Slot | File | Nội dung | Có `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Trình duyệt, thiết bị và breakpoint, trợ năng, hiệu năng cảm nhận, lưu trữ phía trình duyệt | Không |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Màn hình, năm trạng thái giao diện, responsive, trợ năng, quốc tế hóa; API gọi tới; kênh truyền thông | Không |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | View model và trạng thái phía client; không có ERD | Không |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, bản đồ route và bảng route có cột `SCR ID`, cây thành phần của màn hình, góc nhìn triển khai | Không |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Quy tắc tầng: route, tính năng, thành phần giao diện dùng chung, client API | Có |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Kiểu dữ liệu phía client: kiểu API sinh từ OpenAPI, schema form, trạng thái và lưu trữ trình duyệt | Có |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Quy ước giao diện, năm trạng thái, ánh xạ mã lỗi sang giao diện, quy ước gọi API | Có |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Đóng gói, biến môi trường công khai và bí mật, CDN, phát hành, rollback | Không |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Màn hình, props, bảng năm trạng thái, trạng thái tương tác, form, lời gọi API, ánh xạ lỗi, khóa i18n | Có |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration với API giả lập, e2e, trợ năng, visual regression, `CONC` | Có |
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
| `nextjs-app-router` | Next.js App Router, React, TypeScript, Tailwind CSS, shadcn/ui, TanStack Query | [stack-profiles/nextjs-app-router.md](stack-profiles/nextjs-app-router.md) |

Stack khác chưa có profile: đề xuất giá trị placeholder và nội dung profile trong ARCHITECTURE §2 kèm ADR (PLAYBOOK mục 3, quy tắc 5).

## 5. Rule cho agent (Agent Rules)

| File | Chép thành | Áp dụng cho |
| --- | --- | --- |
| [agent-rules/frontend-golden-rules.md](agent-rules/frontend-golden-rules.md) | `.claude/rules/frontend-golden-rules.md` | Mã nguồn giao diện web (`paths` theo cây thư mục ở ARCHITECTURE §4) |

## 6. Checklist riêng của bề mặt (Surface Checklist)

Tự kiểm cùng checklist "Overlay đã áp" ở PLAYBOOK mục 4.

| Kiểm tra | Tài liệu | Đạt |
| --- | --- | :---: |
| Mọi màn hình ở SRS §3 có `SCR ID` (Intake tạo từ template Intake `1.3.0` trở lên), route, tác nhân và FR; mọi FR giao diện truy xuất tới FR hoặc endpoint của API mà nó dùng | SRS §3, §8 | [ ] |
| View model ở SRS §4 chỉ gồm trường có trong response của API; không định nghĩa lại thực thể của backend | SRS §4 | [ ] |
| Mọi mã lỗi mà giao diện xử lý có trong ARCHITECTURE §7.1 kèm khóa i18n và hành vi hiển thị | ARCHITECTURE §7 | [ ] |
| Kiểu dữ liệu API sinh từ tài liệu OpenAPI của backend; không có kiểu response viết tay | ARCHITECTURE §5 | [ ] |
| Mỗi màn hình trong SPEC có đủ năm trạng thái giao diện (trạng thái không áp dụng ghi N/A kèm lý do) và schema form khớp ràng buộc của DTO backend | SPEC §3 | [ ] |
| Mỗi thao tác ghi có khóa chống gửi lặp; `Idempotency-Key` dùng lại khi thử lại và form khóa sửa khi kết quả chưa rõ | SPEC §3, §5 | [ ] |
| Mỗi màn hình có test trợ năng `A11Y` và test visual `VIS` cho trạng thái chính | SPEC §9 | [ ] |

## 7. Giai đoạn 1W: Wireframe (Stage 1W)

Bề mặt này có giao diện nên dự án có Giai đoạn 1W (PLAYBOOK mục 2 và 2.2.1): Intake mục 14 ghi Giai đoạn 1W: Có, Intake mục 9 ghi người duyệt Gate 1W. Áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên.

- ID màn hình `SCR-{MOD}-NN` đặt ở Giai đoạn 1, cột `SCR ID` của bảng Giao diện người dùng ở SRS §3 (khối `srs.external-interfaces` của overlay này). Giai đoạn 1W chi tiết hóa mỗi ID thành một trang `docs/wireframes/SCR-<MOD>-NN.md`, không thêm hay bớt màn hình.
- Hệ thống thiết kế: Giai đoạn 1W viết thêm `docs/design-system/DESIGN_SYSTEM.md` và `docs/design-system/tokens.json` theo CONVENTIONS mục 10.7, trước các trang màn hình; mỗi trang chọn một Template, dẫn Pattern và Component ID của tài liệu đó. Theme mặc định của thư viện giao diện của stack profile (Intake mục 14) chỉ là một hướng thị giác, dùng khi được chọn có chủ đích; profile `none` ghi chưa chọn thư viện và xét lại ở Giai đoạn 2.
- Template `core/07_Wireframe_Template/` dùng chung cho mọi bề mặt có giao diện và không có slot; overlay không cung cấp khối cho wireframe. Cách điền riêng cho web:

| Mục của template | Cách điền cho `frontend-web` |
| --- | --- |
| Điểm vào (danh mục màn hình và trang) | Route dạng `/đường-dẫn`, giống cột Route ở SRS §3 |
| Bố cục low-fi | Vẽ ở breakpoint nhỏ nhất của SRS §2.5; thay đổi bố cục ở breakpoint lớn hơn ghi dưới khối |
| Năm trạng thái UI | Theo yêu cầu chung cho mọi màn hình ở SRS §3; `Loading` gồm cả lúc đang gửi, nút gửi bị khóa |
| Điều hướng vào và ra | Tham số route hoặc query; route cần đăng nhập; hành vi của nút quay lại của trình duyệt khi khác luồng thường |
| Ghi chú trợ năng | Theo CONVENTIONS mục 10.2 ở mức WCAG của NFR-USAB. Con số của web: vùng bấm tối thiểu 24 × 24 CSS px, hoặc vùng nhỏ hơn đặt đủ xa để vòng tròn đường kính 24 CSS px đặt ở tâm của nó không chạm vùng bấm khác hay vòng tròn của vùng nhỏ khác (WCAG 2.5.8, mức AA); reflow xét ở breakpoint nhỏ nhất của SRS §2.5 (WCAG 1.4.10) |
| HTML đầy đủ (theo Intake mục 14) | Một file tĩnh mỗi trang theo CONVENTIONS mục 7: bố cục đúng ở breakpoint nhỏ nhất và lớn nhất của SRS §2.5 (`@media`), mở trực tiếp bằng trình duyệt; trang Markdown thắng khi hai bên lệch nhau |

- Sau Gate 1W: bảng route ở ARCHITECTURE §3 (khối `arch.views`) có cột `SCR ID`, mỗi `SCR-*` của chỉ mục wireframe ít nhất một hàng (Gate 2); bảng Màn hình ở SPEC §3 (khối `spec.contract`) dẫn `SCR ID` và trang wireframe, không định nghĩa lại màn hình. Ở Giai đoạn 2, ARCHITECTURE §7 ghi cách ánh xạ token thành mã nguồn (khối `arch.conventions`) và stack profile ghi công cụ ánh xạ; code chỉ đọc token đã ánh xạ.
