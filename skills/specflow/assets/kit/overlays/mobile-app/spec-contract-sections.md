---
doc_type: overlay-section
status: stable
version: 1.1.0
language: vi-en
surface: mobile-app
---

# Overlay mobile-app: khối cho SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Màn hình (Screen)

<!-- fill: Một bảng cho mỗi màn hình của tính năng. Có Giai đoạn 1W: hàng SCR ID dẫn đúng ID ở chỉ mục wireframe và hàng Trang wireframe dẫn trang của màn hình; SPEC chỉ dẫn SCR-*, không định nghĩa lại màn hình, bố cục hay thành phần đã có ở trang wireframe, bảng năm trạng thái dưới khớp bảng trạng thái của trang và thêm hành vi thực thi. Dự án có Intake cũ hơn 1.3.0 hoặc không có Giai đoạn 1W: bỏ hai hàng này. -->

| Hạng mục | Giá trị |
| --- | --- |
| SCR ID | {{SCR_ID}} |
| Trang wireframe | `docs/wireframes/{{SCR_ID}}.md` |
| Route | `/{{ROUTE_PATH}}` |
| Tham số điều hướng | <!-- fill: tên, kiểu, bắt buộc hay không; tham số đến từ deep link được validate như input ngoài --> |
| Tác nhân và điều kiện truy cập | <!-- fill: vai trò được vào; hành vi khi phiên hết hạn trong lúc mất mạng --> |
| Dùng khi mất mạng | <!-- fill: chọn một: Có \| Chỉ xem \| Không; khớp SRS §3 --> |
| Điều hướng vào | <!-- fill: từ màn hình nào, từ deep link hay thông báo đẩy --> |
| Điều hướng ra | <!-- fill: sau khi lưu, khi hủy, khi quay lại bằng cử chỉ hệ thống --> |

### Thành phần và props (Components & Props)

| Thành phần | Props (tên: kiểu) | Nguồn dữ liệu | Trách nhiệm |
| --- | --- | --- | --- |
| {{COMPONENT_NAME}} | <!-- fill --> | <!-- fill: truy vấn cục bộ nào, hoặc props từ màn hình --> | <!-- fill --> |

### Năm trạng thái giao diện (UI States)

<!-- fill: Đủ năm hàng cho mỗi màn hình hoặc vùng dữ liệu độc lập; trạng thái không áp dụng ghi N/A kèm lý do ở cột Hiển thị. Cột Khi mất mạng ghi hiển thị khác đi thế nào khi thiết bị mất mạng. Cột AC trỏ tiêu chí nghiệm thu ở SRS §8. -->

| Trạng thái | Điều kiện vào | Hiển thị | Khi mất mạng | Hành động người dùng | AC |
| --- | --- | --- | --- | --- | --- |
| `Initial` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Loading` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Empty` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Success` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Error` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Trạng thái đồng bộ của bản ghi (Record Sync States)

<!-- fill: Bắt buộc với bản ghi sửa được khi mất mạng; ghi N/A kèm lý do nếu tính năng chỉ đọc. -->

| Trạng thái | Điều kiện vào | Hiển thị | Hành động người dùng | AC |
| --- | --- | --- | --- | --- |
| `Synced` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Queued` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Conflict` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Rejected` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Thao tác ghi cục bộ (Local Mutations)

<!-- fill: Mỗi thao tác ghi một hàng. Bảng cục bộ và hàng đợi thay đổi đổi trong cùng một transaction. -->

| Thao tác | Bảng cục bộ thay đổi | Thay đổi vào hàng đợi | Gộp với thay đổi chưa gửi | Điều kiện chặn |
| --- | --- | --- | :---: | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill: endpoint đích, nội dung, phiên bản gốc --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill: ví dụ bản ghi đang Conflict --> |

### Form và validation (Form & Validation)

<!-- fill: Mỗi trường một hàng; ràng buộc chép từ DTO request trong SPEC hoặc OpenAPI của API và ghi nguồn ở cột cuối. -->

| Trường | Kiểu | Ràng buộc | Khóa chuỗi thông báo lỗi | Nguồn ràng buộc |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

<!-- PROFILE-SLOT: spec.contract -->

### Hợp đồng đồng bộ (Sync Contract)

<!-- fill: Mỗi lời gọi API mà bộ máy đồng bộ hoặc màn hình dùng một hàng; đường dẫn đúng như contract nguồn. Phản hồi xác định là phản hồi mà sau đó thay đổi không cần gửi lại. -->

| Lời gọi | Method và path | Contract nguồn | Header và tham số đặc biệt | Phản hồi xác định | Phản hồi chưa rõ |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: chọn một: GET \| POST \| PATCH \| PUT \| DELETE; đường dẫn đúng như contract nguồn --> `/api/v1/{{RESOURCE_PATH}}` | <!-- fill: SPEC ID hoặc operationId trong OpenAPI --> | <!-- fill: ví dụ Idempotency-Key là ID thay đổi, phiên bản gốc trong body --> | <!-- fill: mã HTTP và mã lỗi, kèm trạng thái đồng bộ mà mỗi mã dẫn tới --> | Lỗi mạng, hết thời gian chờ, `5xx`: gửi lại với cùng khóa |

### Quyền hệ điều hành (Permissions)

| Quyền | Thời điểm xin | Nội dung giải thích | Khi bị từ chối |
| --- | --- | --- | --- |
| <!-- fill: hoặc Không dùng --> | <!-- fill --> | Khóa chuỗi <!-- fill --> | <!-- fill --> |

### Ánh xạ lỗi sang giao diện (Error to UI Mapping)

<!-- fill: Mọi mã lỗi mà lời gọi ở trên có thể trả và mã phía client; mã có trong ARCHITECTURE §7.1. -->

| `error.code` | Trạng thái giao diện hoặc trạng thái đồng bộ | Khóa chuỗi thông báo | Hành vi |
| --- | --- | --- | --- |
| `NETWORK_ERROR` | `Queued` | <!-- fill --> | Gửi lại với cùng khóa ở lượt đồng bộ sau |
| <!-- fill: mã của API --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

### Chuỗi hiển thị (i18n Keys)

| Khóa | Nội dung theo locale mặc định |
| --- | --- |
| <!-- fill: dạng tính năng.phần tử --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Loại test của bề mặt (Surface Test Types)

| Loại | TYPE trong TC ID | Phạm vi | Dữ liệu | Bắt buộc |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Hàm thuần, schema form, thành phần render độc lập | Trong bộ nhớ | Có |
| Integration | `INT` | Thao tác ghi cục bộ, migration, bộ máy đồng bộ với client API thật và API giả lập ở tầng `fetch` | Cơ sở dữ liệu cục bộ thật (cùng engine SQL) trong bộ nhớ | Có |
| E2E | `E2E` | Luồng người dùng trên bản build chạy trong máy ảo hoặc thiết bị, gồm tắt và bật mạng | API giả lập hoặc API staging | Có |
| Trợ năng | `A11Y` | Nhãn, vai trò, thông báo trạng thái cho trình đọc màn hình; kiểm tra thủ công bằng VoiceOver và TalkBack trên màn hình chính trước phát hành | Như unit hoặc e2e | Có, mỗi màn hình |
| Concurrency | `CONC` | Bất biến ở §1.2 khi hai thiết bị cùng sửa khi mất mạng, khi đồng bộ bị kích hoạt nhiều lần cùng lúc, hoặc khi người dùng sửa bản ghi đang được gửi | Như integration, mỗi thiết bị một cơ sở dữ liệu | Có, mỗi bất biến ở §1.2 một test |
| Smoke | `SMOKE` | Mở ứng dụng, đăng nhập, luồng chính, mất mạng rồi có mạng lại, trên từng cấu hình của ma trận thiết bị | Bản build thử nội bộ, API staging | Có, mỗi lần phát hành |

### Dạng test CONC của bề mặt (Concurrency Test Pattern)

1. Tạo API giả lập ở tầng `fetch` giữ phiên bản của bản ghi, trả xung đột khi phiên bản gốc cũ, lưu phản hồi theo khóa idempotency và phát lại đúng phản hồi đó khi nhận lại khóa, ghi lại khóa và nội dung của mọi request; có tùy chọn mất phản hồi sau khi đã áp dụng, móc chạy một tác vụ sau khi áp dụng lần ghi kế tiếp và trước khi trả lời, và tùy chọn độ trễ.
2. Hai thiết bị: tạo hai cơ sở dữ liệu cục bộ và hai bộ máy đồng bộ độc lập cùng gọi API giả lập; đồng bộ lần đầu, ghi cục bộ trên cả hai như khi mất mạng, rồi đồng bộ lần lượt theo thứ tự test chọn. Khẳng định: API chỉ nhận thay đổi dựa trên phiên bản mới nhất, thiết bị còn lại chuyển `Conflict` và giữ giá trị của người dùng, không thay đổi nào mất mà người dùng không biết.
3. Nhiều lần kích hoạt: một thiết bị có thay đổi chờ, API giả lập có độ trễ, gọi đồng bộ nhiều lần cùng lúc. Khẳng định số request ghi mà API nhận bằng số thay đổi chờ.
4. Sửa trong lúc gửi: móc của API giả lập ghi cục bộ lên cùng bản ghi sau khi API đã áp dụng thay đổi đang gửi; chạy một lần với phản hồi về được và một lần với phản hồi bị mất rồi đồng bộ lại; thêm một lần ghi cục bộ ngay sau khi bộ máy đồng bộ đọc thay đổi sắp gửi (bọc cổng truy vấn để chen lần ghi vào đúng lúc đó). Khẳng định API giữ giá trị mới nhất, mỗi khóa idempotency chỉ đi kèm một nội dung, và bản ghi trên máy khớp API.
5. Không dùng sleep để sắp thứ tự; thứ tự do test điều khiển bằng lời gọi đồng bộ và độ trễ của API giả lập.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
