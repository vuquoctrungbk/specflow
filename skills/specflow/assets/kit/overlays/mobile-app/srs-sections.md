---
doc_type: overlay-section
status: stable
version: 1.2.1
language: vi-en
surface: mobile-app
---

# Overlay mobile-app: khối cho SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Ràng buộc | Nội dung |
| --- | --- |
| Stack | Theo stack profile `{{STACK_PROFILE}}` đã chốt ở Intake mục 14; phiên bản cụ thể ở ARCHITECTURE §2 |
| Kiểu dữ liệu nghiêm ngặt | Ngôn ngữ có kiểm tra kiểu tĩnh, bật chế độ nghiêm ngặt; quy tắc cụ thể ở ARCHITECTURE và `.claude/rules/` |
| Nền tảng và phiên bản hệ điều hành | <!-- fill: iOS và Android, phiên bản tối thiểu của từng nền tảng; điện thoại, máy tính bảng hay cả hai; hướng màn hình --> |
| Ma trận thiết bị | <!-- fill: các thiết bị hoặc cấu hình dùng cho smoke test trước phát hành: máy cấu hình thấp nhất được hỗ trợ, máy phổ biến nhất của người dùng, màn hình nhỏ nhất --> |
| Làm việc khi mất mạng | <!-- fill: chức năng nào dùng được khi mất mạng; thời gian mất mạng tối đa phải chịu được; dung lượng dữ liệu tối đa giữ trên máy --> |
| Quyền hệ điều hành | <!-- fill: mỗi quyền (camera, vị trí, thông báo, ảnh) và lý do; xin quyền lúc người dùng dùng tính năng cần nó, không xin khi mở ứng dụng --> |
| Lưu trữ an toàn | Token và secret chỉ nằm trong kho khóa của hệ điều hành (Keychain, Android Keystore); dữ liệu nghiệp vụ trên máy xóa khi đăng xuất, sau khi đã cảnh báo về thay đổi chưa đồng bộ |
| Giao thức | Mọi lời gọi mạng qua HTTPS |
| Nguồn chân lý | Giá trị nghiệp vụ, quyền và trạng thái do API quyết định; ứng dụng hiển thị bản sao trên máy kèm trạng thái đồng bộ, không tự quyết thay API |
| Phiên bản ứng dụng tối thiểu | <!-- fill: cách API hoặc cấu hình từ xa báo phiên bản thấp nhất còn được hỗ trợ và hành vi của ứng dụng cũ hơn (chặn và dẫn tới cửa hàng) --> |
| Thời gian và tiền tệ | Nhận từ API theo UTC và ISO 8601; hiển thị theo locale và múi giờ của thiết bị; thời điểm tạo thay đổi trên máy chỉ dùng để hiển thị, không dùng để phân xử xung đột |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### Giao diện người dùng (User Interfaces)

<!-- fill: Một hàng cho mỗi màn hình; bảng này là nguồn duy nhất của danh sách màn hình. SCR ID dạng SCR-<MOD>-NN đặt ở đây (CONVENTIONS mục 4), MOD là mã phân hệ có FR chính của màn hình, NN duy nhất theo MOD trong toàn dự án, kể cả khi web và mobile dùng chung mã phân hệ; Giai đoạn 1W chi tiết hóa mỗi SCR ID thành một trang wireframe, không đặt thêm ID. Dự án brownfield: màn hình không đổi theo Gap Analysis ghi Giữ nguyên ở ô SCR ID. Dự án có Intake cũ hơn 1.3.0 bỏ cột SCR ID. Route là đường dẫn màn hình trong ứng dụng, cũng dùng cho deep link nếu có. -->

| Màn hình | SCR ID | Route | Tác nhân | Mục đích | Dùng khi mất mạng | FR |
| --- | --- | --- | --- | --- | :---: | --- |
| <!-- fill --> | {{SCR_ID}} | `/{{ROUTE_PATH}}` | `ACT_{{ROLE_CODE}}` | <!-- fill --> | <!-- fill: chọn một: Có \| Chỉ xem \| Không --> | FR-{{MODULE_CODE}}-001 |

Yêu cầu chung cho mọi màn hình:

- Năm trạng thái giao diện (UI states): mỗi màn hình và mỗi vùng dữ liệu độc lập có đủ `Initial`, `Loading`, `Empty`, `Success`, `Error`. Dữ liệu đã có trên máy hiển thị ngay, không chờ mạng; `Loading` chỉ dùng khi máy chưa có dữ liệu. Trạng thái không áp dụng ghi N/A kèm lý do; có Giai đoạn 1W thì ghi ở trang wireframe của màn hình (mục 4), SPEC nhận lại; không có Giai đoạn 1W thì ghi thẳng trong SPEC.
- Trạng thái đồng bộ của bản ghi: mỗi bản ghi sửa được khi mất mạng hiển thị một trong `Synced` (khớp bản của API), `Queued` (đã lưu trên máy, chờ gửi), `Conflict` (API có bản khác mới hơn, người dùng cần chọn), `Rejected` (API từ chối thay đổi, kèm lý do). Màn hình danh sách hiển thị số thay đổi chờ gửi và số mục cần chọn.
- Chỉ báo mạng: khi mất mạng, ứng dụng báo rõ và vẫn cho làm các thao tác ghi dùng được khi mất mạng.
- Trợ năng: mỗi màn hình đạt các tiêu chí WCAG 2.2 ở mức của NFR-USAB, áp cho ứng dụng di động theo WCAG2ICT; tiêu chí xét ở từng màn hình khi lập wireframe theo `specflow/CONVENTIONS.md` mục 10.2. Con số của nền tảng: vùng chạm tối thiểu 44 × 44 pt trên iOS và 48 × 48 dp trên Android; chữ co giãn theo cỡ chữ hệ thống; trình đọc màn hình VoiceOver và TalkBack.
- Mọi chuỗi hiển thị lấy từ bộ chuỗi theo locale; locale mặc định <!-- fill: ví dụ vi-VN -->.

### Giao diện phần cứng (Hardware Interfaces)

<!-- fill: Giữ hàng áp dụng, ghi "Không" ở cột Áp dụng cho hàng còn lại thay vì xóa. -->

| Phần cứng | Mục đích | Quyền cần xin | Khi bị từ chối | Áp dụng |
| --- | --- | --- | --- | :---: |
| Camera | <!-- fill --> | Camera | <!-- fill: tính năng thay thế hoặc hướng dẫn mở cài đặt --> | <!-- fill: chọn một: Có \| Không --> |
| Vị trí | <!-- fill --> | Vị trí khi dùng ứng dụng | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| Sinh trắc học | <!-- fill: mở khóa ứng dụng --> | Face ID hoặc vân tay | <!-- fill: dùng mật khẩu --> | <!-- fill: chọn một: Có \| Không --> |
| Bộ nhớ thiết bị | Cơ sở dữ liệu cục bộ và tệp chờ gửi | Không cần | <!-- fill: hành vi khi bộ nhớ đầy --> | Có |

### Giao diện phần mềm (Software Interfaces)

| Hệ thống | Mục đích | Giao thức và định dạng | Xác thực và an toàn | Áp dụng |
| --- | --- | --- | --- | :---: |
| API backend | <!-- fill: tên API và tài liệu contract (SPEC, OpenAPI) mà ứng dụng gọi, gồm contract đồng bộ --> | REST, JSON, HTTPS | <!-- fill: cơ chế phiên đăng nhập, chốt ở ARCHITECTURE §6.1 --> | <!-- fill: chọn một: Có \| Không --> |
| Dịch vụ thông báo đẩy | <!-- fill: loại thông báo; thông báo chỉ báo có thay đổi, không chứa dữ liệu cá nhân --> | APNs, FCM hoặc dịch vụ trung gian | Token thiết bị gửi lên API sau khi người dùng đồng ý | <!-- fill: chọn một: Có \| Không --> |
| Deep link | <!-- fill: đường dẫn mở thẳng màn hình --> | Universal Links, App Links | Kiểm tra quyền như khi mở màn hình từ trong ứng dụng | <!-- fill: chọn một: Có \| Không --> |
| Theo dõi lỗi và crash | <!-- fill: dịch vụ nhận crash --> | <!-- fill --> | Che dữ liệu cá nhân trước khi gửi | <!-- fill: chọn một: Có \| Không --> |
| Cửa hàng ứng dụng | Phân phối, phát hành theo tỉ lệ | App Store Connect, Google Play Console | Khóa ký giữ ngoài repo | Có |

### Giao diện truyền thông (Communications Interfaces)

| Kênh | Quy ước | Áp dụng |
| --- | --- | :---: |
| HTTPS tới API | JSON UTF-8; lỗi theo envelope của API; thời gian chờ và thử lại theo ARCHITECTURE §7 | Có |
| Đồng bộ | Gửi thay đổi chờ và nhận thay đổi mới khi có mạng lại, khi mở lại ứng dụng, khi người dùng kéo để làm mới và sau mỗi thao tác ghi; chạy nền theo giới hạn của hệ điều hành nếu có | Có |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### Dữ liệu trên thiết bị (On-device Data)

<!-- fill: Mỗi thực thể giữ trên máy một hàng. Thực thể nghiệp vụ, ERD và quy tắc toàn vẹn thuộc SRS của API; ở đây chỉ ghi phần ứng dụng giữ, trường giữ đúng tên như response của API. §4.2 liệt kê thực thể trên máy và dữ liệu chỉ có trên máy (hàng đợi thay đổi, bản của API khi có xung đột) như thực thể; §4.3 ghi quy tắc giữ, sửa, xóa trên máy. -->

| Thực thể trên máy | Nguồn (endpoint và FR của API) | Phạm vi giữ trên máy | Sửa khi mất mạng | Chứa dữ liệu cá nhân | Xóa khi |
| --- | --- | --- | :---: | :---: | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: ví dụ chỉ bản ghi được giao cho người dùng, trong 30 ngày --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill: đăng xuất, hết phạm vi, API báo đã xóa --> |

#### Chiến lược đồng bộ (Sync Strategy)

| Hạng mục | Quyết định |
| --- | --- |
| Hướng đồng bộ | <!-- fill: dữ liệu nào chỉ nhận từ API, dữ liệu nào ứng dụng gửi lên --> |
| Phát hiện xung đột | Mỗi bản ghi sửa được mang phiên bản do API cấp; thay đổi gửi kèm phiên bản mà người dùng đã sửa trên đó; API từ chối khi phiên bản đó cũ |
| Giải quyết xung đột | <!-- fill: chọn một, có ADR: người dùng chọn giữa bản của mình và bản của API \| bản của API thắng, thay đổi trên máy bị bỏ kèm thông báo \| gộp theo từng trường; không dùng đồng hồ của thiết bị để phân xử --> |
| Thứ tự gửi | Thay đổi gửi lần lượt theo thứ tự tạo; thay đổi sau của cùng bản ghi chờ thay đổi trước có kết quả |
| Gửi lại | Mỗi thay đổi có một khóa idempotency riêng; gửi lại sau lỗi mạng, hết thời gian chờ hoặc `5xx` dùng đúng khóa và nội dung cũ |
| Xóa | <!-- fill: API báo bản ghi bị xóa hoặc ra khỏi phạm vi thế nào; bản ghi còn thay đổi chưa gửi thì xử lý ra sao --> |
| Giới hạn | <!-- fill: số thay đổi chờ tối đa, dung lượng tệp chờ gửi, thời gian giữ thay đổi bị từ chối --> |

#### Bảng xung đột (Conflict Table)

<!-- fill: Mỗi tình huống hai nơi cùng đổi một bản ghi một hàng: hai thiết bị, thiết bị và người dùng web, thiết bị và tác vụ của hệ thống. -->

| Thực thể | Tình huống | Phát hiện ở | Cách giải quyết | Người dùng thấy gì |
| --- | --- | --- | --- | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: ví dụ API trả mã xung đột phiên bản khi nhận thay đổi --> | <!-- fill: theo chiến lược ở bảng trên --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->
