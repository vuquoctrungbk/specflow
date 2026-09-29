---
doc_type: overlay-section
status: stable
version: 1.0.0
language: vi-en
surface: ai-llm-app
---

# Overlay ai-llm-app: khối cho SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Ràng buộc | Nội dung |
| --- | --- |
| Stack | Theo stack profile `{{STACK_PROFILE}}` đã chốt ở Intake mục 14; phiên bản cụ thể và ID mô hình ở ARCHITECTURE §2 |
| Kiểu dữ liệu nghiêm ngặt | Ngôn ngữ có kiểm tra kiểu tĩnh, bật chế độ nghiêm ngặt; quy tắc cụ thể ở ARCHITECTURE và `.claude/rules/` |
| Nhà cung cấp và họ mô hình | <!-- fill: nhà cung cấp và mức mô hình (nhanh và rẻ, cân bằng, mạnh nhất) phù hợp nhiệm vụ; ID mô hình chính xác chốt ở ARCHITECTURE §2.1 kèm ADR --> |
| Đầu ra có cấu trúc | Mọi đầu ra dùng cho xử lý tiếp theo khớp một schema; đầu ra không khớp được coi là lỗi, không sửa đoán |
| Tính không tất định | Cùng đầu vào có thể cho kết quả khác nhau; chất lượng đo bằng chỉ số trên bộ dữ liệu có nhãn qua nhiều lần chạy, không bằng một lần chạy |
| Độ trễ | <!-- fill: p95 của một lời gọi, gồm cả thử lại; tác vụ nền hay tác vụ người dùng đang chờ --> |
| Ngân sách | <!-- fill: token tối đa mỗi lời gọi, chi phí tối đa mỗi tháng, hành vi khi chạm ngưỡng --> |
| Dữ liệu gửi tới nhà cung cấp | <!-- fill: trường nào được gửi; dữ liệu cá nhân được che hay có căn cứ pháp lý; chính sách lưu và huấn luyện trên dữ liệu của nhà cung cấp --> |
| Khi mô hình sai hoặc không sẵn sàng | <!-- fill: phương án dự phòng: chuyển người xem lại, giá trị mặc định an toàn, thử lại sau; không chặn luồng nghiệp vụ chính --> |
| Con người kiểm soát | <!-- fill: kết quả nào cần người duyệt (độ tin cậy thấp, tác động lớn); ai sửa được kết quả của AI --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### Giao diện phần mềm (Software Interfaces)

<!-- fill: Giữ hàng áp dụng, ghi "Không" ở cột Áp dụng cho hàng còn lại thay vì xóa. -->

| Hệ thống | Mục đích | Giao thức và định dạng | Xác thực và an toàn | Áp dụng |
| --- | --- | --- | --- | :---: |
| API của nhà cung cấp mô hình | <!-- fill: tác vụ gọi mô hình --> | HTTPS, JSON, đầu ra có cấu trúc | Khóa API trong kho secret; dữ liệu gửi đi theo §2.5 | Có |
| Kho vector hoặc chỉ mục tìm kiếm | <!-- fill: tài liệu dùng làm ngữ cảnh --> | <!-- fill --> | <!-- fill: quyền đọc theo người dùng yêu cầu --> | <!-- fill: chọn một: Có \| Không --> |
| Công cụ mà mô hình được gọi | <!-- fill: mỗi công cụ, có tác dụng phụ hay chỉ đọc --> | <!-- fill --> | Công cụ có tác dụng phụ cần xác nhận của người dùng hoặc kiểm tra quyền ở server | <!-- fill: chọn một: Có \| Không --> |
| Hệ thống nguồn và đích của dữ liệu | <!-- fill: nơi lấy đầu vào và ghi kết quả --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |

### Giao diện người dùng (User Interfaces)

<!-- fill: Màn hình hay API hiển thị kết quả AI thuộc overlay của bề mặt đó; ở đây chỉ ghi yêu cầu riêng của nội dung do AI tạo. -->

| Yêu cầu | Nội dung |
| --- | --- |
| Đánh dấu nội dung AI | <!-- fill: người dùng biết kết quả nào do AI tạo --> |
| Sửa và phản hồi | <!-- fill: người dùng sửa được kết quả; sửa được ghi lại để làm dữ liệu đánh giá sau khi ẩn danh --> |
| Giải thích | <!-- fill: lý do ngắn hoặc nguồn trích dẫn đi kèm kết quả nếu có --> |

### Giao diện truyền thông (Communications Interfaces)

| Kênh | Quy ước | Áp dụng |
| --- | --- | :---: |
| HTTPS tới nhà cung cấp mô hình | Thời gian chờ và số lần thử lại theo ARCHITECTURE §7; không gửi lại lời gọi đã có phản hồi hợp lệ | Có |
| Truyền dần (streaming) | <!-- fill: chỉ khi người dùng chờ đọc kết quả dài; đầu ra có cấu trúc thì chờ đủ rồi mới kiểm tra schema --> | <!-- fill: chọn một: Có \| Không --> |

Giao diện phần cứng (Hardware Interfaces): N/A cho bề mặt `ai-llm-app`.
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### Dữ liệu vào và ra của mô hình (Model Input & Output)

<!-- fill: Mỗi tác vụ gọi mô hình một hàng. Đầu ra ghi tên trường và miền giá trị; schema chính xác ở ARCHITECTURE §5 và Prompt Spec. §4.2 liệt kê đầu vào, đầu ra, nhật ký và bộ dữ liệu như thực thể. -->

| Tác vụ | Đầu vào (nguồn, độ tin cậy) | Đầu ra (trường và miền giá trị) | Dùng đầu ra để làm gì |
| --- | --- | --- | --- |
| {{FEATURE_NAME}} | <!-- fill: ví dụ nội dung khách gửi, không tin cậy --> | <!-- fill --> | <!-- fill --> |

#### Nhật ký lời gọi mô hình (Model Call Log)

| Trường | Ý nghĩa | Chứa dữ liệu cá nhân | Thời gian giữ |
| --- | --- | :---: | --- |
| Prompt và phiên bản | Prompt Spec và version đã dùng | Không | <!-- fill --> |
| Mô hình | ID mô hình chính xác | Không | <!-- fill --> |
| Đầu vào | <!-- fill: bản đã che, hoặc chỉ mã băm --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |
| Đầu ra và quyết định | Kết quả đã kiểm tra schema và quyết định cuối (dùng, chuyển người xem lại) | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |
| Token và độ trễ | Token vào, token ra, thời gian của lời gọi | Không | <!-- fill --> |

#### Bộ dữ liệu đánh giá (Eval Datasets)

<!-- fill: Mỗi bộ dữ liệu một hàng. Cột Prompt đặt ID `PROMPT-{MOD}-NNN` lần đầu cho mỗi prompt (CONVENTIONS mục 4); ARCHITECTURE và Prompt Spec dùng lại ID này. Tối thiểu 20 mẫu cho mỗi prompt; mẫu tổng hợp hoặc đã ẩn danh không đảo ngược, không chứa dữ liệu cá nhân thật; phân bố nhãn gần phân bố thật. -->

| Bộ dữ liệu | Prompt | Số mẫu | Nguồn | Người gán nhãn | Nơi lưu |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill: ≥ 20 --> | <!-- fill: chọn một: tổng hợp \| ẩn danh không đảo ngược --> | <!-- fill --> | <!-- fill: đường dẫn trong repo --> |
<!-- /SLOT-CONTENT -->
