---
doc_type: overlay-section
status: stable
version: 1.2.0
language: vi-en
surface: frontend-web
---

# Overlay frontend-web: khối cho SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Màn hình (Screen)

<!-- fill: Một bảng cho mỗi màn hình của tính năng. Có Giai đoạn 1W: hàng SCR ID dẫn đúng ID ở chỉ mục wireframe và hàng Trang wireframe dẫn trang của màn hình; SPEC chỉ dẫn SCR-*, không định nghĩa lại màn hình, bố cục hay thành phần đã có ở trang wireframe, bảng năm trạng thái dưới khớp bảng trạng thái của trang và thêm hành vi thực thi. Dự án có Intake cũ hơn 1.3.0 hoặc không có Giai đoạn 1W: bỏ hai hàng này. -->

| Hạng mục | Giá trị |
| --- | --- |
| SCR ID | {{SCR_ID}} |
| Trang wireframe | `docs/wireframes/{{SCR_ID}}.md` |
| Route | `/{{ROUTE_PATH}}` |
| Tác nhân và điều kiện truy cập | <!-- fill: vai trò được vào; hành vi khi chưa đăng nhập hoặc không đủ quyền --> |
| Tiêu đề trang | Khóa chuỗi <!-- fill --> |
| Điều hướng vào | <!-- fill: từ màn hình nào, kèm tham số gì --> |
| Điều hướng ra | <!-- fill: sau khi thành công, khi hủy --> |
| Lập chỉ mục tìm kiếm | <!-- fill: chọn một: cho phép \| không cho phép (noindex) --> |

### Thành phần và props (Components & Props)

| Thành phần | Chạy ở | Props (tên: kiểu) | Trách nhiệm |
| --- | --- | --- | --- |
| {{COMPONENT_NAME}} | <!-- fill: chọn một: server \| client --> | <!-- fill --> | <!-- fill --> |

### Năm trạng thái giao diện (UI States)

<!-- fill: Đủ năm hàng cho mỗi màn hình hoặc vùng dữ liệu độc lập; trạng thái không áp dụng ghi N/A kèm lý do ở cột Hiển thị. Cột AC trỏ tiêu chí nghiệm thu ở SRS §8. -->

| Trạng thái | Điều kiện vào | Hiển thị | Hành động người dùng | AC |
| --- | --- | --- | --- | --- |
| `Initial` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Loading` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Empty` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Success` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Error` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Trạng thái tương tác (Interaction States)

| Phần tử | Trạng thái | Quy tắc |
| --- | --- | --- |
| Nút gửi | Đang gửi | Khóa và đổi nhãn; lần bấm thứ hai không tạo request mới |
| Form | Kết quả chưa rõ (lỗi mạng, hết thời gian chờ, `5xx`) | Các trường chỉ đọc; chỉ có hành động gửi lại cùng nội dung và cùng khóa tới khi có phản hồi xác định |
| Trường nhập | Có lỗi | Viền lỗi, thông báo gắn với trường bằng thuộc tính trợ năng, focus về trường lỗi đầu tiên khi gửi (tiêu chí ở `specflow/CONVENTIONS.md` mục 10.2) |
| <!-- fill --> | <!-- fill --> | <!-- fill --> |

### Form và validation (Form & Validation)

<!-- fill: Mỗi trường một hàng; ràng buộc chép từ DTO request trong SPEC của API và ghi SPEC nguồn ở cột cuối. -->

| Trường | Kiểu | Ràng buộc | Khóa chuỗi thông báo lỗi | Nguồn ràng buộc |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: SPEC ID của API, mục §3 --> |

<!-- PROFILE-SLOT: spec.contract -->

### Lời gọi API (API Calls)

| Thời điểm gọi | Method và path | Contract nguồn | Header đặc biệt | Xử lý thành công | Xử lý lỗi |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: chọn một: GET \| POST \| PATCH \| PUT \| DELETE; đường dẫn đúng như contract nguồn --> `/api/v1/{{RESOURCE_PATH}}` | <!-- fill: SPEC ID và operationId trong OpenAPI --> | <!-- fill: ví dụ Idempotency-Key sinh một lần cho mỗi lần gửi --> | <!-- fill --> | Theo bảng ánh xạ lỗi dưới đây |

### Ánh xạ lỗi sang giao diện (Error to UI Mapping)

<!-- fill: Mọi mã lỗi mà lời gọi ở trên có thể trả (theo ma trận lỗi của SPEC nguồn) và mã phía client; mã có trong ARCHITECTURE §7.1. -->

| `error.code` | Trạng thái giao diện | Khóa chuỗi thông báo | Hành vi |
| --- | --- | --- | --- |
| `VALIDATION_ERROR` | `Error` | <!-- fill --> | Lỗi dưới từng trường theo `error.details` |
| `UNAUTHENTICATED` | `Error` | <!-- fill --> | Chuyển tới đăng nhập rồi quay lại |
| `NETWORK_ERROR` | `Error` | <!-- fill --> | Cho thử lại với cùng `Idempotency-Key` |
| <!-- fill: mã nghiệp vụ của API --> | `Error` | <!-- fill --> | <!-- fill --> |

### Chuỗi hiển thị (i18n Keys)

| Khóa | Nội dung theo locale mặc định |
| --- | --- |
| <!-- fill: dạng tính năng.phần tử --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Loại test của bề mặt (Surface Test Types)

| Loại | TYPE trong TC ID | Phạm vi | Dữ liệu | Bắt buộc |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Schema form, hàm định dạng, hook, thành phần render độc lập | Trong bộ nhớ | Có |
| Integration | `INT` | Thành phần của tính năng cùng client API thật, API giả lập ở tầng mạng theo contract | Response giả lập khớp OpenAPI | Có khi tính năng gọi API |
| E2E | `E2E` | Luồng người dùng trên ứng dụng đã build, trong trình duyệt thật | API giả lập ở tầng mạng hoặc API môi trường staging | Có |
| Trợ năng | `A11Y` | Quét tự động theo mức WCAG của NFR-USAB trên mỗi màn hình và trạng thái chính | Như E2E | Có, mỗi màn hình |
| Visual regression | `VIS` | Ảnh chụp màn hình so với ảnh gốc đã duyệt | Như E2E, dữ liệu cố định | Có, mỗi màn hình ở trạng thái `Success` |
| Concurrency | `CONC` | Bất biến ở §1.2 khi thao tác ghi bị kích hoạt lặp | Như E2E | Có, mỗi bất biến ở §1.2 một test |

### Dạng test CONC của bề mặt (Concurrency Test Pattern)

1. Mở màn hình trên ứng dụng đã build; chặn lời gọi ghi bằng route giả lập có độ trễ đủ để lần kích hoạt thứ hai xảy ra khi request đầu chưa xong.
2. Kích hoạt thao tác ghi lặp trong cùng một lần gửi: bấm đúp, nhấn Enter rồi bấm, hoặc gửi lại sau lỗi mạng (form phải đang khóa sửa). Route giả lập trả lỗi mạng cũng phải có độ trễ, để lần bấm thứ hai rơi vào lúc request đầu chưa kết thúc.
3. Đếm request ghi đã gửi và khóa `Idempotency-Key` của chúng; khẳng định bất biến (một request cho một lần gửi, cùng khóa khi thử lại) và giao diện chỉ hiển thị một kết quả.
4. Không dùng sleep để sắp thứ tự; chờ theo trạng thái hiển thị.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
