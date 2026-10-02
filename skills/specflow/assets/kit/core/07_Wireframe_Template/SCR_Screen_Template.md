---
doc_type: wireframe-screen
status: draft
version: 0.1.0
template_version: 1.5.0
language: vi-en
parent: [docs/wireframes/00_WIREFRAME_INDEX.md, docs/design-system/DESIGN_SYSTEM.md]
overlays: []
assembled_from: []
---

# Wireframe màn hình (Screen Wireframe): {{SCR_ID}} {{SCREEN_NAME}}

<!-- fill: Chép thành docs/wireframes/SCR-<MOD>-NN.md ở Giai đoạn 1W (PLAYBOOK mục 2.2.1), một file cho mỗi SCR ID ở danh mục màn hình của chỉ mục; tên file là SCR ID cộng đuôi .md. parent thêm SRS chứa FR của màn hình (docs/srs/SRS.md, hoặc master và module khi modular); DESIGN_SYSTEM.md là tài liệu hệ thống thiết kế ở docs/design-system/, nguồn của Template, Pattern và Component mà trang dẫn (CONVENTIONS mục 10.7). overlays ghi bề mặt của màn hình. assembled_from ghi "core/07_Wireframe_Template/SCR_Screen_Template.md@<template_version>". Template dùng chung cho mọi bề mặt có giao diện, không có slot: khác biệt giữa web và mobile ghi ở các chú thích fill dưới và ở mục Giai đoạn 1W trong OVERLAY.md của overlay. Trang chỉ chi tiết hóa màn hình đã có ở SRS §3: không định nghĩa FR, AC hay trường dữ liệu mới; thiếu thì ghi câu hỏi BLOCKING ở mục 7 kèm đề xuất sửa SRS theo PLAYBOOK mục 8. Trạng thái, version và thay đổi sau khi duyệt theo SRS. -->

## 1. Mục đích, FR và AC (Purpose, FR & AC)

- Mục đích: <!-- fill: 1 đến 2 câu, người dùng làm được gì ở màn hình này; khớp cột Mục đích của SRS §3 -->
- Thông tin ưu tiên: <!-- fill: 1 đến 3 thông tin người dùng cần nhất để làm việc chính của màn hình, xếp theo thứ tự ưu tiên, phân cách dấu chấm phẩy; mỗi mục là trường ở SRS §4.2 hoặc nhãn ở mục 3. Thông tin thứ nhất đứng đầu và nổi nhất ở bố cục mục 2 (CONVENTIONS mục 10.7) -->
- Hành động chính: <!-- fill: đúng một hành động người dùng đến màn hình để làm, ghi nhãn trong cặp backtick trùng một ô cột Thành phần ở mục 3, có thể kèm một câu sau; ghi Không kèm lý do khi màn hình chỉ để xem, hoặc khi các hành động ngang hàng có chủ đích (ví dụ chọn giữa hai bản, để không dẫn người dùng) -->
- Bề mặt: <!-- fill: tên overlay của màn hình, ví dụ frontend-web hoặc mobile-app -->
- Template: `{{TEMPLATE_ID}}` <!-- fill: đúng một TPL-NN có trong danh mục Template của DESIGN_SYSTEM.md mục 7; vùng ở mục 2 theo đúng vùng của Template này (CONVENTIONS mục 10.7) -->
- Pattern: <!-- fill: các PAT-NN có trong danh mục Pattern của DESIGN_SYSTEM.md mục 6 mà màn hình dùng, phân cách dấu phẩy; ghi Không khi màn hình không dùng pattern nào -->
- Điểm vào: `{{ENTRY_POINT}}` <!-- fill: web: route như cột Route của SRS §3; mobile: deep link, hoặc tên màn hình trong navigator khi không mở được bằng deep link; khớp danh mục màn hình của chỉ mục -->
- Tác nhân: `ACT_{{ROLE_CODE}}`
- Bản phát hành: {{RELEASE}}
- Màn hình xác thực: <!-- fill: chọn một: Có | Không. Có khi màn hình cho người dùng đăng nhập, xác minh danh tính hay xác nhận lại tài khoản (mật khẩu, mã một lần, sinh trắc học); mục 6 khi đó ghi tiêu chí 3.3.8 theo CONVENTIONS mục 10.2 -->

<!-- fill: Một hàng cho mỗi cặp FR và AC mà màn hình hiện thực. FR có ở SRS §6.1 và có SCR ID này ở bảng đối chiếu của chỉ mục; AC có ở SRS §8 và thuộc FR cùng hàng. FR không có AC nào thể hiện trên màn hình ghi N/A kèm lý do ở cột AC ID. -->

| FR ID | AC ID | Thể hiện trên màn hình |
| --- | --- | --- |
| FR-{{MODULE_CODE}}-001 | AC-{{MODULE_CODE}}-01 | <!-- fill: thành phần hoặc trạng thái ở mục 3, 4 thể hiện AC --> |

## 2. Bố cục low-fi (Low-fi Layout)

<!-- fill: Khối text theo CONVENTIONS mục 7, chỉ vẽ trạng thái Success (màn hình form mà Success là rời màn hình thì vẽ Initial và ghi điều đó dưới khối); bốn trạng thái còn lại mô tả ở mục 4. Chia màn hình thành vùng xếp từ trên xuống, tên vùng theo vùng của Template ở mục 1; mỗi vùng mở bằng dòng "== N. Tên vùng ==", vùng cạnh nhau ghi trên cùng dòng mở, phân cách bằng " | " (ví dụ "== 2. Danh sách | 3. Chi tiết =="), hộp thoại là vùng "== N. Hộp thoại: Tên ==". Số N đánh liên tiếp từ 1 trên trang theo thứ tự đọc, từ trên xuống và từ trái sang phải; số không thuộc tên vùng, góp ý ghi SCR ID cộng số vùng. Dưới dòng mở, mỗi thành phần một dòng thụt hai dấu cách: [Nhãn] cho nút, "Nhãn: [____]" cho trường nhập, "( ) Nhãn" và "[ ] Nhãn" cho lựa chọn, "..." cho phần lặp của danh sách. Nhãn trùng cột Thành phần ở mục 3. Web: vẽ ở breakpoint nhỏ nhất của SRS §2.5, không cuộn ngang ở độ rộng đó trừ nội dung cần hai chiều (tiêu chí 1.4.10 ở CONVENTIONS mục 10.2), ghi thay đổi bố cục ở breakpoint lớn hơn dưới khối. Mobile: vẽ ở hướng dọc; thanh điều hướng, thanh tab và vùng an toàn (safe area) là vùng riêng khi màn hình có. Không dùng ảnh hay công cụ vẽ. -->

```text
== 1. Header ==
  [{{COMPONENT_NAME}}]
== 2. Nội dung ==
  {{COMPONENT_NAME}}: [____]
  ...
== 3. Footer ==
  [{{COMPONENT_NAME}}]
```

Nội dung biên: <!-- fill: ca biên của dữ liệu trên màn hình, lấy từ ràng buộc đã có ở SRS (từ điển dữ liệu §4.2, quy tắc nghiệp vụ, luồng của FR), không đặt giới hạn mới (giá trị dài nhất, trường trống, số 0, danh sách nhiều trang) và cách màn hình hiển thị từng ca (xuống dòng, cắt kèm cách xem đủ, phân trang); ghi Không kèm lý do khi màn hình không hiển thị dữ liệu hay SRS không có ràng buộc nào cho dữ liệu đó -->

HTML low-fi: <!-- fill: chọn một: `docs/wireframes/html/{{SCR_ID}}.html` | Không. HTML là tùy chọn, chỉ tạo khi Intake mục 14 ghi Giai đoạn 1W: Có, kèm HTML low-fi. Khi có: một file tĩnh docs/wireframes/html/SCR-<MOD>-NN.html cho màn hình này, tiêu đề vùng (hoặc chú thích HTML trước khối của vùng khi không có tiêu đề) mang cùng số vùng như khối bố cục, theo quy tắc an toàn ở CONVENTIONS mục 7: không có thẻ script hay thuộc tính sự kiện, không tải tài nguyên ngoài, có thẻ meta Content-Security-Policy như CONVENTIONS mục 7, chỉ CSS viết trong thẻ style của file, khối :root khai báo biến CSS lấy từ token của docs/design-system/tokens.json (tên biến và quy tắc chỉ dùng token theo CONVENTIONS mục 10.7) thay cho thang xám, dữ liệu mẫu tự đặt (không dùng dữ liệu người thật, secret hay URL nội bộ), link chỉ tới file SCR-*.html cùng thư mục. Đường dẫn ghi giống ô File HTML của danh mục màn hình. Khi HTML và trang này lệch nhau, trang này thắng. -->

## 3. Bảng thành phần (Components)

<!-- fill: Một hàng cho mỗi thành phần ở khối bố cục, cùng nhãn. Component ID là CMP-NN có trong danh mục Component của DESIGN_SYSTEM.md mục 5; thành phần chưa có trong danh mục thì thêm vào danh mục trước, không tự đặt ID ở trang. Trường ở SRS §4 ghi tên thực thể hoặc view model và tên trường ở SRS §4.2 mà thành phần hiển thị hoặc nhận; ghi Không khi thành phần không gắn dữ liệu. Thao tác ghi việc người dùng làm và kết quả (điều hướng, gửi dữ liệu, đổi trạng thái), dẫn FR. -->

| Thành phần | Component ID | Dữ liệu hiển thị | Trường ở SRS §4 | Thao tác |
| --- | --- | --- | --- | --- |
| {{COMPONENT_NAME}} | `{{COMPONENT_ID}}` | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. Trạng thái giao diện (UI States)

<!-- fill: Đúng năm hàng, ô đầu là tên trạng thái Initial, Loading, Empty, Success, Error. Trạng thái không áp dụng ghi N/A kèm lý do ở cột Hiển thị. Cột AC dẫn AC ở SRS §8 thuộc FR của mục 1, hoặc N/A kèm lý do. Web: Initial là trước khi người dùng thao tác hoặc trước khi tải; Loading gồm cả lúc đang gửi. Mobile: dữ liệu đã có trên thiết bị hiển thị ngay, Loading chỉ khi thiết bị chưa có dữ liệu; trạng thái đồng bộ của bản ghi (SRS §3) ghi ở cột Hiển thị của Success hoặc Error khi màn hình sửa được dữ liệu lúc mất mạng. -->

| Trạng thái | Điều kiện vào | Hiển thị | Hành động người dùng | AC |
| --- | --- | --- | --- | --- |
| Initial | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Loading | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Empty | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Success | <!-- fill --> | <!-- fill: như khối bố cục ở mục 2 --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Error | <!-- fill --> | <!-- fill: thông báo và cách khắc phục; mã lỗi ghi ở SPEC, không ở đây --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

## 5. Điều hướng vào và ra (Navigation)

<!-- fill: Mỗi đường vào và ra một hàng; khớp cạnh của sơ đồ điều hướng ở chỉ mục. Màn hình nguồn hoặc đích ghi SCR ID, hoặc mô tả khi nằm ngoài danh mục (ví dụ trang của bên thứ ba, ứng dụng khác). Web: tham số là tham số route hoặc query; ghi hành vi của nút quay lại của trình duyệt khi khác luồng thường. Mobile: ghi vào từ deep link hay thông báo đẩy, tham số điều hướng, và nơi cử chỉ quay lại của hệ thống đưa người dùng tới. -->

| Hướng | Màn hình | Thao tác hoặc điều kiện | Tham số |
| --- | --- | --- | --- |
| <!-- fill: chọn một: Vào \| Ra --> | {{SCR_ID}} | <!-- fill --> | <!-- fill: tên tham số, hoặc Không --> |

## 6. Ghi chú trợ năng (Accessibility Notes)

<!-- fill: Mỗi dòng dưới là một tiêu chí WCAG 2.2 mà CONVENTIONS mục 10.2 ghi ở mục trợ năng của trang; nội dung và mức của tiêu chí đọc ở đó, không chép lại ở đây. Tiêu chí áp theo mức NFR-USAB ở SRS §7; tiêu chí không áp, hoặc không có trên màn hình này, ghi N/A kèm lý do. Con số của nền tảng (vùng chạm tối thiểu, cỡ chữ hệ thống) lấy ở mục Giai đoạn 1W của OVERLAY.md của bề mặt. Tiêu chí 2.4.6, 3.3.2 ghi ở bảng thành phần (mục 3), 3.3.1 ở trạng thái Error (mục 4), 1.4.10 ở bố cục low-fi (mục 2). -->

- `1.1.1`, `4.1.2` Tên và vai trò: <!-- fill: tên thay thế của phần tử không có chữ; tên và vai trò của phần tử tương tác ở mục 3 -->
- `1.4.4` Phóng to chữ: <!-- fill -->
- `2.1.1`, `2.4.3`, `2.4.7` Bàn phím và focus: <!-- fill: thứ tự focus hoặc thứ tự đọc theo bố cục ở mục 2 -->
- `2.4.11` Focus không bị che: <!-- fill: phần tử cố định ở bố cục mục 2 và cách để phần tử đang nhận focus không bị che hết; N/A khi màn hình không có phần tử cố định -->
- `2.5.7` Kéo thả: <!-- fill: thao tác kéo (nếu có) và cách thay bằng một lần chạm hoặc nhấp; N/A khi màn hình không có thao tác kéo -->
- `2.5.8` Vùng chạm: <!-- fill: con số của OVERLAY.md của bề mặt; ngoại lệ nếu có -->
- `3.3.7` Không bắt nhập lại: <!-- fill: dữ liệu của bước trước được điền sẵn hoặc chọn lại ở trạng thái Initial (mục 4); N/A khi màn hình không phải bước sau của luồng nhiều bước -->
- `3.3.8` Xác thực: <!-- fill: khi dòng Màn hình xác thực ở mục 1 là Có: cách xác thực và cách thay thế theo CONVENTIONS mục 10.2; N/A khi dòng đó là Không, hoặc khi NFR-USAB ở SRS §7 chọn mức A -->
- `4.1.3` Thông báo trạng thái: <!-- fill: thông báo đang gửi, thành công, lỗi của màn hình -->

## 7. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## 8. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline | Chưa duyệt |
