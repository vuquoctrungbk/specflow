---
doc_type: overlay-section
status: stable
version: 1.2.1
language: vi-en
surface: frontend-web
---

# Overlay frontend-web: khối cho SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Ràng buộc | Nội dung |
| --- | --- |
| Stack | Theo stack profile `{{STACK_PROFILE}}` đã chốt ở Intake mục 14; phiên bản cụ thể ở ARCHITECTURE §2 |
| Kiểu dữ liệu nghiêm ngặt | Ngôn ngữ có kiểm tra kiểu tĩnh, bật chế độ nghiêm ngặt; quy tắc cụ thể ở ARCHITECTURE và `.claude/rules/` |
| Trình duyệt hỗ trợ | <!-- fill: danh sách trình duyệt và phiên bản tối thiểu, ví dụ hai phiên bản mới nhất của Chrome, Edge, Firefox, Safari; Safari trên iOS từ phiên bản cụ thể --> |
| Thiết bị và breakpoint | <!-- fill: độ rộng màn hình nhỏ nhất phải dùng được (ví dụ 360 px) và các breakpoint chuyển bố cục --> |
| Trợ năng | Tuân thủ WCAG 2.2 mức {{WCAG_LEVEL}} theo NFR-USAB |
| Hiệu năng cảm nhận | <!-- fill: ngưỡng Core Web Vitals ở phân vị 75, ví dụ LCP ≤ 2,5 s, INP ≤ 200 ms, CLS ≤ 0,1; thiết bị và mạng dùng để đo --> |
| Giao thức | Trang và lời gọi API chỉ qua HTTPS |
| Nguồn chân lý | Giá, số tiền, quyền và trạng thái nghiệp vụ hiển thị theo dữ liệu API trả về; giao diện không tự tính rồi gửi các giá trị này lên |
| Lưu trữ phía trình duyệt | Không lưu token, secret hay dữ liệu cá nhân trong `localStorage` hoặc `sessionStorage` |
| Thời gian và tiền tệ | Nhận từ API theo UTC và ISO 8601; định dạng hiển thị theo locale của người dùng |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### Giao diện người dùng (User Interfaces)

<!-- fill: Một hàng cho mỗi màn hình; bảng này là nguồn duy nhất của danh sách màn hình. SCR ID dạng SCR-<MOD>-NN đặt ở đây (CONVENTIONS mục 4), MOD là mã phân hệ có FR chính của màn hình, NN duy nhất theo MOD trong toàn dự án; Giai đoạn 1W chi tiết hóa mỗi SCR ID thành một trang wireframe, không đặt thêm ID. Dự án brownfield: màn hình không đổi theo Gap Analysis ghi Giữ nguyên ở ô SCR ID. Dự án có Intake cũ hơn 1.3.0 bỏ cột SCR ID. Route viết đường dẫn trang; FR là yêu cầu mà màn hình hiện thực. -->

| Màn hình | SCR ID | Route | Tác nhân | Mục đích | FR |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | {{SCR_ID}} | `/{{ROUTE_PATH}}` | `ACT_{{ROLE_CODE}}` | <!-- fill --> | FR-{{MODULE_CODE}}-001 |

Yêu cầu chung cho mọi màn hình:

- Năm trạng thái giao diện (UI states): mỗi màn hình và mỗi vùng dữ liệu độc lập trên màn hình có đủ `Initial` (trước khi người dùng thao tác hoặc trước khi tải), `Loading` (đang chờ dữ liệu hoặc đang gửi), `Empty` (tải xong nhưng không có dữ liệu), `Success` (có dữ liệu hoặc thao tác thành công), `Error` (lỗi, kèm cách khắc phục). Trạng thái không áp dụng ghi N/A kèm lý do; có Giai đoạn 1W thì ghi ở trang wireframe của màn hình (mục 4), SPEC nhận lại; không có Giai đoạn 1W thì ghi thẳng trong SPEC.
- Responsive theo breakpoint ở §2.5; không có cuộn ngang ở độ rộng nhỏ nhất.
- Trợ năng theo §2.5: mỗi màn hình đạt các tiêu chí WCAG 2.2 ở mức của NFR-USAB; tiêu chí xét ở từng màn hình khi lập wireframe theo `specflow/CONVENTIONS.md` mục 10.2.
- Mọi chuỗi hiển thị lấy từ bộ chuỗi theo locale; locale mặc định <!-- fill: ví dụ vi-VN -->.

### Giao diện phần mềm (Software Interfaces)

<!-- fill: Giữ hàng áp dụng, ghi "Không" ở cột Áp dụng cho hàng còn lại thay vì xóa. -->

| Hệ thống | Mục đích | Giao thức và định dạng | Xác thực và an toàn | Áp dụng |
| --- | --- | --- | --- | :---: |
| API backend | <!-- fill: tên API và tài liệu contract (SPEC, OpenAPI) mà giao diện gọi --> | REST, JSON, HTTPS | <!-- fill: cơ chế phiên đăng nhập, chốt ở ARCHITECTURE §6.1 --> | <!-- fill: chọn một: Có \| Không --> |
| Nhà cung cấp định danh (identity provider) | Đăng nhập liên kết | OpenID Connect trên OAuth 2.0, Authorization Code kèm PKCE | Kiểm tra `state`, `nonce`, audience | <!-- fill: chọn một: Có \| Không --> |
| Phân tích hành vi (analytics) | <!-- fill: sự kiện nào được gửi --> | <!-- fill --> | Chỉ gửi sau khi người dùng đồng ý; không gửi dữ liệu cá nhân | <!-- fill: chọn một: Có \| Không --> |
| Theo dõi lỗi phía trình duyệt | <!-- fill: dịch vụ nhận lỗi JavaScript --> | <!-- fill --> | Che dữ liệu cá nhân trước khi gửi | <!-- fill: chọn một: Có \| Không --> |

### Giao diện truyền thông (Communications Interfaces)

| Kênh | Quy ước | Áp dụng |
| --- | --- | :---: |
| HTTPS tới API | JSON UTF-8; lỗi theo envelope của API; timeout và thử lại theo ARCHITECTURE §7 | Có |
| Thời gian thực | <!-- fill: chọn một: WebSocket trên TLS (WSS) \| Server-Sent Events; không dùng thì thay cả ô bằng Không cần --> kèm tự kết nối lại với backoff lũy thừa | <!-- fill: chọn một: Có \| Không --> |

Giao diện phần cứng (Hardware Interfaces): N/A cho bề mặt `frontend-web`; trình duyệt là lớp trung gian với thiết bị.
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### Mô hình dữ liệu hiển thị (View Model)

<!-- fill: Bề mặt này không sở hữu dữ liệu lưu trữ; thực thể nghiệp vụ, ERD và quy tắc toàn vẹn thuộc SRS của API mà nó gọi. Mỗi view model lấy trường từ response của một endpoint, giữ đúng tên trường như response (kể cả ở §4.2, không đổi sang snake_case); không thêm trường mà API không trả. Dữ liệu hiển thị cần giữ lại sau khi nguồn của nó bị xóa (ví dụ tên sản phẩm của đơn vừa đặt khi giỏ đã xóa) ghi rõ nguồn chụp lại. §4.2 liệt kê view model và trạng thái phía client như thực thể; §4.3 ghi quy tắc hiển thị và lưu trữ phía client. -->

| View model | Nguồn (endpoint và FR của API) | Trường hiển thị | Định dạng hiển thị |
| --- | --- | --- | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill --> | <!-- fill: ví dụ tiền theo locale, thời gian theo múi giờ người dùng --> |

#### Trạng thái phía client (Client State)

| Trạng thái | Loại | Vòng đời | Nơi giữ | Chứa dữ liệu cá nhân |
| --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill: chọn một: dữ liệu từ server \| trạng thái form \| trạng thái URL \| trạng thái giao diện --> | <!-- fill: khi nào tạo, khi nào xóa --> | <!-- fill: bộ nhớ, URL, cookie; không dùng localStorage cho dữ liệu nhạy cảm --> | <!-- fill: chọn một: Có \| Không --> |
<!-- /SLOT-CONTENT -->
