---
doc_type: design-system
status: draft
version: 0.1.0
template_version: 1.0.0
language: vi-en
parent: [docs/intake/PROJECT_INTAKE.md, docs/srs/SRS.md]
overlays: []
assembled_from: []
---

# Hệ thống thiết kế (Design System): {{PROJECT_NAME}}

<!-- fill: Chép thành docs/design-system/DESIGN_SYSTEM.md ở đầu Giai đoạn 1W (PLAYBOOK mục 2.2.1), trước các trang màn hình, chỉ khi Intake mục 14 ghi Giai đoạn 1W: Có, kèm HTML đầy đủ, hoặc Có, chỉ Markdown. Cùng lúc chép Design_Tokens_Template.json thành docs/design-system/tokens.json và thay từng token theo hướng thị giác đã chọn; mỗi mode khác là một file docs/design-system/tokens.<mode>.json. File JSON không có frontmatter: version của nó là version của tài liệu này, nên đổi file JSON thì tăng version và ghi Version History ở mục 9. parent ghi Intake và SRS chứa FR của màn hình (docs/srs/SRS.md, hoặc master và module khi modular). overlays ghi các bề mặt có giao diện của dự án. assembled_from ghi "core/07_Wireframe_Template/Design_System_Template.md@<template_version>". Quy tắc của hệ thống thiết kế có một nguồn là CONVENTIONS mục 10.7; chú thích fill chỉ dẫn về đó, không viết lại quy tắc. Đầu vào của mục 1: Intake (thương hiệu, người dùng, lĩnh vực), SRS §2 (người dùng), §3 (màn hình), §7 (NFR-USAB) và câu trả lời của chủ dự án. Trạng thái, version và thay đổi sau khi duyệt theo SRS (CONVENTIONS mục 3, PLAYBOOK mục 8). Tài liệu chỉ ghi mục được ít nhất một trang dùng (CONVENTIONS mục 10.7, danh mục). -->

## 1. Hướng thị giác (Visual Direction)

<!-- fill: Đề xuất 2 đến 3 hướng, mỗi hướng một hàng; cột đầu MUST là Hướng. Căn cứ dẫn thương hiệu, người dùng, lĩnh vực, giọng điệu của dự án theo CONVENTIONS mục 10.7. Chủ dự án chọn đúng một hướng: cột Chọn ghi Có ở đúng một hàng, các hàng còn lại ghi Không. -->

| Hướng | Mô tả | Căn cứ | Chọn |
| --- | --- | --- | --- |
| <!-- fill: tên hướng --> | <!-- fill: tính chất thị giác: màu, hình dáng, mật độ, chuyển động --> | <!-- fill: thương hiệu, người dùng, lĩnh vực, giọng điệu --> | <!-- fill: chọn một: Có \| Không --> |
| <!-- fill: tên hướng --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |
| <!-- fill: tên hướng; bỏ hàng này khi chỉ đề xuất 2 hướng --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> |

Lý do chọn: <!-- fill: vì sao hướng có Chọn là Có phù hợp hơn các hướng còn lại, dẫn căn cứ ở bảng trên -->

Theme mặc định của thư viện: <!-- fill: chọn một: Không dùng \| Dùng có chủ đích, kèm lý do. Thư viện giao diện là thư viện của stack profile ghi ở Intake mục 14 (OVERLAY.md của bề mặt, mục Giai đoạn 1W); profile none thì ghi chưa chọn thư viện, xét lại ở Giai đoạn 2 -->

## 2. Foundations

<!-- fill: Mỗi mục con ghi quyết định của hướng đã chọn, giá trị cụ thể nằm ở tokens.json (mục 3); mục này ghi vai trò và lý do. Con số của nền tảng (breakpoint, vùng chạm tối thiểu, cỡ chữ hệ thống) lấy ở mục Giai đoạn 1W của OVERLAY.md của bề mặt, không tự đặt lại. -->

### 2.1. Màu theo vai trò (Color Roles)

<!-- fill: Màu đặt theo vai trò (nền, chữ, hành động, viền, focus, trạng thái), không đặt theo tên màu; mỗi vai trò ứng với một token semantic ở mục 3 -->

### 2.2. Typography

<!-- fill: thang cỡ chữ, độ đậm, chiều cao dòng, họ chữ của từng vai trò chữ (nội dung, tiêu đề, nhãn); mỗi vai trò ứng với một token typography -->

### 2.3. Spacing, grid và breakpoint

<!-- fill: thang spacing, cột và lề của grid, breakpoint; breakpoint nhỏ nhất khớp SRS §2.5 và con số nền tảng ở OVERLAY.md của bề mặt -->

### 2.4. Iconography

<!-- fill: bộ biểu tượng, kích thước, quy tắc đi kèm nhãn chữ -->

### 2.5. Elevation và radius

<!-- fill: các bậc nổi (bóng, lớp) và các bậc bo góc, mỗi bậc dùng cho loại phần tử nào -->

### 2.6. Motion

<!-- fill: thời lượng và đường cong theo loại chuyển động; chế độ giảm chuyển động (reduced motion) thay hoặc bỏ chuyển động nào -->

### 2.7. Giọng nội dung (Content Voice)

<!-- fill: giọng điệu, cách xưng hô, độ dài nhãn và thông báo, khớp giọng điệu ở mục 1 -->

## 3. Token

<!-- fill: Token theo DTCG ở CONVENTIONS mục 10.7, ba nhóm tầng primitive, semantic, component. Bảng mode: một hàng cho mỗi file; hàng đầu là tokens.json (mode mặc định). Cột Áp khi ghi điều kiện áp mode, và bề mặt của trang khi mode phân biệt theo nền tảng. Bảng token semantic tóm tắt token của tokens.json và mọi mode; đường dẫn token đúng như trong file. -->

| Mode | File | Áp khi |
| --- | --- | --- |
| <!-- fill: tên mode mặc định --> | `docs/design-system/tokens.json` | <!-- fill: điều kiện áp; mode mặc định ghi Mặc định --> |
| <!-- fill: tên mode khác, hoặc bỏ hàng khi dự án chỉ có mode mặc định --> | <!-- fill: docs/design-system/tokens.<tên mode>.json; ghi Không có file khi là mode mặc định --> | <!-- fill: ví dụ điều kiện của hệ điều hành hoặc bề mặt --> |

| Token | Kiểu | Giá trị hoặc alias | Vai trò |
| --- | --- | --- | --- |
| <!-- fill: đường dẫn token semantic, ví dụ semantic.color.text.default --> | <!-- fill: kiểu DTCG --> | <!-- fill: giá trị đã phân giải ở mode mặc định --> | <!-- fill: dùng cho phần tử nào --> |

<!-- fill: Bảng tương phản theo cặp (CONVENTIONS mục 10.7): mỗi cặp màu dùng cùng nhau một hàng, ở từng mode; cột đầu MUST là Token trước. Token nền là token màu của nền phía sau. Token chữ là token typography của hàng chữ, ghi Không ở hàng phi văn bản. Chữ lớn do checker suy ra từ token typography ở cột Token chữ (fontSize, fontWeight), người viết không khai. Loại chọn một: chữ | phi văn bản. Ngưỡng là 4.5 (chữ thường), 3 (chữ lớn hoặc phi văn bản). Tỷ lệ tính từ hex của hai token ở mode của hàng, làm tròn xuống 2 chữ số. -->

| Token trước | Token nền | Token chữ | Mode | Loại | Tỷ lệ | Ngưỡng |
| --- | --- | --- | --- | --- | --- | --- |
| <!-- fill: token màu chữ hoặc màu hình --> | <!-- fill: token màu nền --> | <!-- fill: token typography của chữ, hoặc Không --> | <!-- fill: mode ở bảng trên --> | <!-- fill: chọn một: chữ \| phi văn bản --> | <!-- fill: ví dụ 7.25 --> | <!-- fill: 4.5 hoặc 3 --> |

## 4. Primitive

<!-- fill: Phần tử thị giác nhỏ nhất dùng token trực tiếp. Mỗi primitive một hàng; Token dùng là token semantic hoặc component, không phải token primitive (CONVENTIONS mục 10.7). -->

| Primitive | Mục đích | Token dùng |
| --- | --- | --- |
| <!-- fill: tên primitive --> | <!-- fill: vai trò thị giác --> | <!-- fill: token semantic hoặc component --> |

## 5. Component

<!-- fill: Danh mục component, chỉ liệt kê component được ít nhất một trang dùng, trực tiếp hoặc qua cột Component dùng của mục khác đang được dùng (CONVENTIONS mục 10.7). ID CMP-NN đánh số trong dự án; cột đầu MUST là Component ID. Mẫu APG là tên mẫu WAI-ARIA Authoring Practices của component, hoặc Không khi component không tương tác. Variant và State ngăn cách bằng dấu phẩy. Token dùng là token semantic hoặc component. Component dùng ghi CMP-NN của component lồng bên trong, hoặc Không. Bề mặt ghi tên overlay áp dụng. -->

| Component ID | Tên | Mẫu APG | Variant | State | Token dùng | Component dùng | Bề mặt |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{COMPONENT_ID}} | {{COMPONENT_NAME}} | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: CMP-NN, phân cách dấu phẩy, hoặc Không --> | <!-- fill: ví dụ frontend-web hoặc mobile-app --> |

<!-- fill: Mỗi component ở bảng trên có một mục con dưới đây, theo thứ tự của bảng: anatomy (các phần) và bản đồ bàn phím theo mẫu APG. Component không nhận bàn phím ghi Không có tương tác ở bảng phím. -->

### 5.1. {{COMPONENT_ID}}: {{COMPONENT_NAME}}

Anatomy: <!-- fill: các phần của component theo thứ tự từ ngoài vào trong, mỗi phần dùng token nào -->

| Phím hoặc thao tác | Hành vi |
| --- | --- |
| <!-- fill: phím theo mẫu APG, hoặc Không có tương tác --> | <!-- fill --> |

## 6. Pattern

<!-- fill: Danh mục pattern, chỉ liệt kê pattern được ít nhất một trang dùng. ID PAT-NN; cột đầu MUST là Pattern ID. Component dùng ghi CMP-NN có trong mục 5. Luồng ghi các bước của người dùng ở pattern; Trạng thái ghi các trạng thái giao diện của pattern (CONVENTIONS mục 10.1). -->

| Pattern ID | Tên | Vấn đề | Khi dùng | Khi không dùng | Component dùng | Luồng | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{PATTERN_ID}} | <!-- fill --> | <!-- fill: vấn đề tương tác mà pattern giải quyết --> | <!-- fill --> | <!-- fill --> | <!-- fill: CMP-NN, phân cách dấu phẩy --> | <!-- fill --> | <!-- fill --> |

## 7. Template

<!-- fill: Danh mục template của trang, chỉ liệt kê template được ít nhất một trang dùng. ID TPL-NN; cột đầu MUST là Template ID. Vùng ghi tên các vùng của bố cục từ trên xuống, đúng tên vùng mà trang dùng ở khối bố cục low-fi (dòng == Tên vùng ==). Pattern dùng ghi PAT-NN hoặc Không; Component dùng ghi CMP-NN. Theo breakpoint ghi bố cục đổi thế nào ở breakpoint lớn hơn breakpoint nhỏ nhất (mobile: theo hướng màn hình). -->

| Template ID | Tên | Vùng | Pattern dùng | Component dùng | Bề mặt | Theo breakpoint |
| --- | --- | --- | --- | --- | --- | --- |
| {{TEMPLATE_ID}} | <!-- fill --> | <!-- fill: tên vùng, phân cách dấu phẩy --> | <!-- fill: PAT-NN, phân cách dấu phẩy, hoặc Không --> | <!-- fill: CMP-NN, phân cách dấu phẩy --> | <!-- fill: tên overlay --> | <!-- fill --> |

## 8. Giả định và câu hỏi mở (Assumptions & Open Questions)

| ID | Loại | Nội dung | Lý do hoặc ảnh hưởng | BLOCKING | Người trả lời |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: chọn một: Giả định \| Câu hỏi --> | <!-- fill --> | <!-- fill --> | <!-- fill: chọn một: Có \| Không --> | <!-- fill --> |

## 9. Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Người sửa | Nội dung thay đổi | Lý do và người yêu cầu | Người duyệt |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Bản khởi tạo | Khởi tạo theo pipeline | Chưa duyệt |
