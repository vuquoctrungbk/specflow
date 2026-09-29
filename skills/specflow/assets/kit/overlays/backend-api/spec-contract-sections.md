---
doc_type: overlay-section
status: stable
version: 1.0.1
language: vi-en
surface: backend-api
---

# Overlay backend-api: khối cho SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Endpoint

<!-- fill: Một bảng cho mỗi endpoint của tính năng. -->

| Hạng mục | Giá trị |
| --- | --- |
| Method và path | <!-- fill: chọn một: GET \| POST \| PATCH \| PUT \| DELETE --> `/api/v1/{{RESOURCE_PATH}}` |
| Xác thực | <!-- fill: Bearer token theo ARCHITECTURE §6.1, hoặc "Không" cho endpoint công khai --> |
| Phân quyền | <!-- fill: vai trò được phép, khớp §6 --> |
| Header bắt buộc | `Content-Type: application/json`<!-- fill: thêm `Idempotency-Key` nếu thao tác ghi không idempotent tự nhiên --> |
| Giới hạn tần suất | <!-- fill: giới hạn theo ARCHITECTURE §9.1 --> |
| Mã thành công | <!-- fill: ví dụ 201 khi tạo mới, 200 khi phát lại cùng Idempotency-Key --> |

### DTO request và response (Request & Response DTO)

- Request được validate tại biên bằng schema runtime trước khi vào service; trường lạ bị từ chối; lỗi validate trả `VALIDATION_ERROR` kèm danh sách trường ở `error.details`.
- Giá trị tính toán (giá, tổng tiền, quyền) không nhận từ request; service tính từ nguồn chân lý.
- Response chỉ chứa trường đã khai báo; MUST NOT trả trường nội bộ (hash, khóa ngoại không cần thiết, dữ liệu cá nhân không cần cho client).

<!-- PROFILE-SLOT: spec.contract -->

<!-- fill: Viết schema request và kiểu response thật của endpoint theo khuôn ở trên. -->

### Phản hồi thành công (Success Response)

<!-- fill: Một ví dụ JSON trong envelope ARCHITECTURE §6.2, giá trị ví dụ khớp DTO. -->

### Ma trận lỗi (Error Matrix)

| HTTP status | `error.code` | Kịch bản kích hoạt | `error.details` |
| --- | --- | --- | --- |
| `400` | `VALIDATION_ERROR` | Request sai schema | Danh sách `{ field, issue }` |
| `401` | `UNAUTHENTICATED` | Thiếu token, token hết hạn hoặc sai chữ ký | Không có |
| `403` | `FORBIDDEN` | Đã xác thực nhưng vai trò không được phép | Không có |
| `429` | `RATE_LIMITED` | Vượt giới hạn tần suất | Không có; header `Retry-After` |
| <!-- fill: status theo ARCHITECTURE §7 --> | <!-- fill: mã nghiệp vụ có trong ARCHITECTURE §7.1 --> | <!-- fill --> | <!-- fill --> |

### Fragment OpenAPI 3.1 (OpenAPI Fragment)

<!-- fill: Fragment đủ để sinh client và chạy contract test: path, method đúng với bảng Endpoint, operationId camelCase, security, requestBody với schema thật, mọi response trong ma trận lỗi, response thành công và response lỗi có schema của envelope (khai báo trong components), mỗi loại phần tử của `error.details` có thuộc tính khai báo rõ để client sinh được kiểu. Khi hiện thực, SPEC gộp fragment vào openapi/openapi.yaml, file này nằm trong File Diff. -->

```yaml
openapi: 3.1.0
paths:
  /api/v1/{{RESOURCE_PATH}}:
    post:
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema: {}
      responses:
        "201":
          description: "Tạo thành công"
          content:
            application/json:
              schema: {}
        "400":
          description: VALIDATION_ERROR
        "401":
          description: UNAUTHENTICATED
        "403":
          description: FORBIDDEN
        "429":
          description: RATE_LIMITED
```
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Loại test của bề mặt (Surface Test Types)

| Loại | TYPE trong TC ID | Phạm vi | Dữ liệu | Bắt buộc |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Service với repository và adapter được mock | Trong bộ nhớ | Có |
| Integration | `INT` | Repository và truy vấn trên cơ sở dữ liệu thật chạy cô lập | Cơ sở dữ liệu tạo riêng cho lần chạy | Có khi SPEC có truy vấn mới |
| E2E | `E2E` | Request HTTP qua toàn bộ ứng dụng tới cơ sở dữ liệu | Cơ sở dữ liệu tạo riêng cho lần chạy | Có |
| Contract | `CTR` | Response thật so với fragment OpenAPI ở §3 | Như E2E | Có khi endpoint được client khác dùng |
| Concurrency | `CONC` | Bất biến ở §1.2 dưới request song song | Cơ sở dữ liệu thật | Có, mỗi bất biến ở §1.2 một test |
| Load smoke | `LOAD` | Đo nhanh độ trễ so với NFR-PERF | Môi trường staging | Khi SPEC chạm đường nóng của NFR-PERF |

### Dạng test CONC của bề mặt (Concurrency Test Pattern)

1. Chuẩn bị trạng thái giới hạn tài nguyên (ví dụ số lượng còn lại nhỏ hơn số request).
2. Gửi N request song song (N ≥ 10) tới cùng tài nguyên, chờ tất cả kết thúc.
3. Đếm phản hồi theo mã và truy vấn cơ sở dữ liệu để khẳng định bất biến (không âm, không trùng, tổng khớp).
4. Không dùng mock cho tầng lưu trữ; không dùng sleep để sắp thứ tự.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
