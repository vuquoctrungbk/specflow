---
doc_type: overlay-section
status: stable
version: 1.0.1
language: vi-en
surface: ai-llm-app
---

# Overlay ai-llm-app: khối cho SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Prompt dùng (Prompts Used)

<!-- fill: Mỗi prompt mà tính năng gọi một hàng; Prompt Spec phải ở status approved trước Gate 3. Nội dung prompt, schema đầu ra, chế độ lỗi và ngưỡng đánh giá nằm trong Prompt Spec, không chép lại ở đây. -->

| Prompt ID | Phiên bản | File | Mô hình | Mục đích |
| --- | --- | --- | --- | --- |
| `PROMPT-{{MODULE_CODE}}-001` | <!-- fill: version của Prompt Spec --> | <!-- fill: đường dẫn Prompt Spec trong inline code --> | <!-- fill: ID mô hình theo ARCHITECTURE §2.1 --> | <!-- fill --> |

### Luồng xử lý với mô hình (Model Processing Flow)

| Bước | Đầu vào | Xử lý | Đầu ra |
| --- | --- | --- | --- |
| Lấy đầu vào | <!-- fill: nguồn và trường --> | <!-- fill: guard đầu vào --> | <!-- fill --> |
| Gọi mô hình | <!-- fill --> | Client mô hình với tham số của Prompt Spec | Kết quả đã qua schema, hoặc mã lỗi |
| Quyết định | <!-- fill --> | <!-- fill: quy tắc nghiệp vụ, ngưỡng độ tin cậy --> | <!-- fill: dùng kết quả hoặc phương án dự phòng --> |
| Ghi kết quả | <!-- fill --> | <!-- fill: ghi có điều kiện để không ghi lặp --> | <!-- fill --> |

### Bảng quyết định (Decision Table)

| Điều kiện | Hành động | Ghi vào nhật ký | AC |
| --- | --- | --- | --- |
| Đầu ra hợp lệ, độ tin cậy từ ngưỡng trở lên | <!-- fill --> | Kết quả, phiên bản prompt, token | AC-{{MODULE_CODE}}-01 |
| Đầu ra hợp lệ, độ tin cậy dưới ngưỡng | <!-- fill: chuyển người xem lại --> | Như trên, kèm `LOW_CONFIDENCE` | AC-{{MODULE_CODE}}-01 |
| Đầu ra không hợp lệ | <!-- fill: phương án dự phòng --> | `OUTPUT_INVALID` | AC-{{MODULE_CODE}}-01 |
| Mô hình không sẵn sàng sau khi thử lại | <!-- fill: phương án dự phòng --> | `MODEL_UNAVAILABLE` | AC-{{MODULE_CODE}}-01 |

### Ngân sách và giới hạn (Budget & Limits)

| Hạng mục | Giá trị |
| --- | --- |
| Token tối đa mỗi lời gọi | <!-- fill: max_tokens của Prompt Spec; token vào tối đa sau guard đầu vào --> |
| Thời gian chờ, số lần thử lại và hạn chót của lời gọi | <!-- fill: thời gian chờ mỗi lần, số lần thử lại tối đa, hạn chót cho toàn bộ lời gọi kể cả thử lại --> |
| Token trung bình mỗi lời gọi trên bộ dữ liệu | <!-- fill: ngưỡng của test COST --> |

<!-- PROFILE-SLOT: spec.contract -->

### Ánh xạ lỗi (Error Mapping)

<!-- fill: Mọi mã lỗi mà tính năng tạo ra hoặc nhận từ hệ thống ngoài; mã có trong ARCHITECTURE §7.1. -->

| Mã | Nguồn | Hành vi | Người dùng thấy gì |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: chọn một: mô hình \| guard \| hệ thống ngoài --> | <!-- fill --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Loại test của bề mặt (Surface Test Types)

| Loại | TYPE trong TC ID | Phạm vi | Dữ liệu | Bắt buộc |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Guard đầu vào và đầu ra, ghép prompt, quy tắc quyết định | Trong bộ nhớ | Có |
| Integration | `INT` | Client mô hình thật với nhà cung cấp giả lập ở tầng `fetch`: đầu ra hợp lệ, không hợp lệ, quá tải, lỗi mạng | Phản hồi giả lập khớp API của nhà cung cấp | Có |
| Đánh giá | `EVAL` | Prompt và mô hình thật trên bộ dữ liệu có nhãn, lặp theo Prompt Spec | Bộ dữ liệu đánh giá | Có, mỗi prompt |
| Tấn công prompt | `INJ` | Đầu vào cố đổi chỉ dẫn, lộ prompt hệ thống hoặc gọi công cụ ngoài quyền | Bộ dữ liệu tấn công | Có khi prompt nhận nội dung không tin cậy |
| Chi phí | `COST` | Token trung bình mỗi lời gọi trên bộ dữ liệu so với ngân sách | Như `EVAL` | Có, mỗi prompt |
| Concurrency | `CONC` | Bất biến ở §1.2 khi cùng đầu vào được xử lý song song hoặc nhiều lời gọi dùng chung ngân sách | Nhà cung cấp và hệ thống đích giả lập | Có, mỗi bất biến ở §1.2 một test |

### Dạng test CONC của bề mặt (Concurrency Test Pattern)

1. Giả lập nhà cung cấp mô hình ở tầng `fetch` và giả lập hệ thống đích có ghi có điều kiện (phiên bản hoặc khóa idempotency).
2. Cho hai worker, hoặc hai lần kích hoạt của cùng worker, xử lý cùng tập đầu vào cùng lúc; hệ thống đích có độ trễ đủ để hai lần xử lý chồng nhau.
3. Khẳng định mỗi đầu vào chỉ có một kết quả được ghi, số lời gọi mô hình không vượt số đầu vào nhân số worker, và tổng token không vượt ngân sách của lần chạy.
4. Không dùng sleep để sắp thứ tự; thứ tự do độ trễ của giả lập điều khiển.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
