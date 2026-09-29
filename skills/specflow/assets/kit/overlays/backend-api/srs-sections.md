---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: backend-api
---

# Overlay backend-api: khối cho SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Ràng buộc | Nội dung |
| --- | --- |
| Stack | Theo stack profile `{{STACK_PROFILE}}` đã chốt ở Intake mục 14; phiên bản cụ thể ở ARCHITECTURE §2 |
| Kiểu dữ liệu nghiêm ngặt | Ngôn ngữ có kiểm tra kiểu tĩnh, bật chế độ nghiêm ngặt; quy tắc cụ thể ở ARCHITECTURE và `.claude/rules/` |
| Toàn vẹn giao dịch | Mọi thao tác nghiệp vụ thay đổi trạng thái từ hai bản ghi liên quan trở lên chạy trong một database transaction; mức isolation mặc định chốt ở ARCHITECTURE §7; SPEC nêu rõ khi cần mức cao hơn hoặc khóa dòng |
| Giao thức | API chỉ phục vụ qua HTTPS; <!-- fill: phiên bản TLS tối thiểu, ví dụ TLS 1.2 --> |
| Thời gian | Lưu và truyền theo UTC, định dạng ISO 8601 |
| Tiền tệ | <!-- fill: đơn vị tiền tệ và biểu diễn chính xác; ghi N/A nếu hệ thống không xử lý tiền --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### Giao diện phần mềm (Software Interfaces)

<!-- fill: Giữ hàng áp dụng, ghi "Không" ở cột Áp dụng cho hàng còn lại thay vì xóa. -->

| Hệ thống | Mục đích | Giao thức và định dạng | Xác thực và an toàn | Áp dụng |
| --- | --- | --- | --- | :---: |
| Client của API (ứng dụng web, mobile, hệ thống khác) | Gọi nghiệp vụ của hệ thống | REST, JSON, HTTPS | Bearer token theo ARCHITECTURE §6.1 | <!-- fill: chọn một: Có \| Không --> |
| API của bên thứ ba (ngoài email, SMS và định danh ở các hàng dưới) | <!-- fill: dịch vụ nào, làm gì --> | <!-- fill --> | <!-- fill: API key, OAuth client credentials --> | <!-- fill: chọn một: Có \| Không --> |
| Webhook nhận vào | <!-- fill: bên gửi, sự kiện --> | HTTPS POST, JSON | Xác thực chữ ký (ví dụ HMAC-SHA256 trên raw body), chống phát lại bằng timestamp, xử lý idempotent theo ID sự kiện của bên gửi | <!-- fill: chọn một: Có \| Không --> |
| Object storage | <!-- fill: file nào được lưu --> | API tương thích S3, pre-signed URL có thời hạn | Bucket riêng tư, URL ký có thời hạn ngắn | <!-- fill: chọn một: Có \| Không --> |
| Email hoặc SMS | <!-- fill: thông báo nào --> | API của nhà cung cấp | API key trong secret manager | <!-- fill: chọn một: Có \| Không --> |
| Nhà cung cấp định danh (identity provider) | Đăng nhập liên kết | OpenID Connect trên OAuth 2.0, Authorization Code kèm PKCE | Kiểm tra `state`, `nonce`, audience | <!-- fill: chọn một: Có \| Không --> |

### Giao diện truyền thông (Communications Interfaces)

| Kênh | Quy ước | Áp dụng |
| --- | --- | :---: |
| REST API | JSON UTF-8, URI chữ thường `kebab-case`, phiên bản major trong path; chi tiết ở ARCHITECTURE §7 | Có |
| Thời gian thực | WebSocket trên TLS (WSS) có heartbeat ping/pong và client tự kết nối lại với backoff lũy thừa | <!-- fill: chọn một: Có \| Không --> |
| Hàng đợi hoặc event bus | <!-- fill: dùng cho sự kiện nội bộ hay tích hợp; ghi Không nếu không dùng --> | <!-- fill: chọn một: Có \| Không --> |

Giao diện người dùng (User Interfaces) và giao diện phần cứng (Hardware Interfaces): N/A cho bề mặt `backend-api`; giao diện người dùng thuộc overlay của bề mặt client nếu dự án có.
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### Sơ đồ thực thể liên kết logic (Logical ERD)

<!-- fill: Mọi thực thể nghiệp vụ và quan hệ, ký hiệu Crow's foot; tên thực thể UPPER_SNAKE số ít, thuộc tính snake_case. Chỉ ghi thuộc tính cốt lõi, kiểu logic (uuid, string, decimal, int, timestamp, enum) và vai trò khóa (PK, FK, UK). Tên và tập giá trị enum MUST khớp §4.2 và §10.1. -->

```mermaid
erDiagram
    {{ENTITY_NAME}} ||--o{ {{ENTITY_NAME}} : "{{MESSAGE}}"
    {{ENTITY_NAME}} {
        uuid id PK "Khóa chính"
        timestamp created_at "Thời điểm tạo, UTC"
        timestamp updated_at "Thời điểm cập nhật cuối, UTC"
    }
```

<!-- fill: Khi điền §4.2 và §4.3, xét đủ và ghi quyết định vào đúng mục: bảng lịch sử, tài chính, nhật ký kiểm toán là append-only; thực thể có dữ liệu con mang ràng buộc tài chính hoặc pháp lý xóa mềm bằng cột deleted_at, cấm xóa cứng, nêu hành vi truy vấn mặc định với bản ghi đã xóa mềm; giá trị phụ thuộc thời điểm (giá, tỉ lệ, cấu hình) được chụp lại vào bản ghi giao dịch; quy tắc số học viết trong inline code, khớp tên cột; khóa tự nhiên duy nhất và khóa duy nhất ghép; miền giá trị hữu hạn liệt kê đủ, thực thể có vòng đời có state machine ở §10.1. -->
<!-- /SLOT-CONTENT -->
