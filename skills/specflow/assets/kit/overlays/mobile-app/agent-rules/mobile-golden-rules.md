---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.2.0
language: vi-en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [mobile-app]
assembled_from: []
---

# Quy tắc ứng dụng di động (Mobile Golden Rules)

<!-- fill: Chép thành .claude/rules/mobile-golden-rules.md ở Giai đoạn 2. paths liệt kê thư mục mã nguồn của ứng dụng theo ARCHITECTURE §4, mỗi glob một phần tử. assembled_from ghi "overlays/mobile-app/agent-rules/mobile-golden-rules.md@<template_version>" và stack profile đã dùng. -->

- Tách tầng: màn hình chỉ ghép thành phần của tính năng; đọc dữ liệu qua hook của tính năng từ cơ sở dữ liệu cục bộ; MUST NOT gọi API hay truy vấn SQL trong thành phần giao diện.
- Thao tác ghi cập nhật bản ghi cục bộ và thêm thay đổi vào hàng đợi trong cùng một transaction; MUST NOT gọi endpoint ghi của API từ màn hình. Chỉ bộ máy đồng bộ gửi thay đổi lên API.
- Mỗi thay đổi có một khóa idempotency riêng lưu cùng thay đổi; đọc và đánh dấu thay đổi đã gửi trong cùng một transaction trước khi gửi request; gửi lại dùng đúng khóa và nội dung cũ. MUST NOT sửa nội dung của thay đổi đã gửi hoặc đang gửi; lần sửa mới thành thay đổi mới xếp sau.
- Thay đổi của một bản ghi gửi theo đúng thứ tự tạo; thay đổi đang chờ giờ hẹn gửi lại giữ lại các thay đổi sau của cùng bản ghi, không giữ thay đổi của bản ghi khác.
- Phân xử xung đột theo phiên bản do API cấp và chiến lược ở ADR; MUST NOT dùng đồng hồ của thiết bị để quyết định bản nào thắng.
- MUST NOT bỏ thay đổi chưa đồng bộ mà người dùng không biết: đăng xuất, xóa dữ liệu, xung đột và bị từ chối đều hiển thị trước.
- Mỗi màn hình hiện thực đủ năm trạng thái giao diện; bản ghi sửa được khi mất mạng hiển thị trạng thái đồng bộ theo SPEC §3.
- Mọi chuỗi hiển thị lấy qua khóa chuỗi theo locale; MUST NOT viết cứng văn bản hiển thị trong thành phần.
- MUST NOT viết màu, spacing, radius hay cỡ chữ thô trong mã giao diện; chỉ đọc token của `docs/design-system/tokens.json` qua theme của ứng dụng. File theme đó (theme object), viết tay hoặc sinh bằng công cụ, là nơi duy nhất được chứa giá trị thô và MUST khớp `tokens.json`. Theme của thư viện giao diện chỉ đổi qua token. Dự án chưa có `docs/design-system/` (wireframe từ template trang cũ hơn `1.4.0`) giữ nguồn token ghi ở ARCHITECTURE.
- Token và secret chỉ lưu trong kho khóa của hệ điều hành; MUST NOT ghi token hay dữ liệu cá nhân vào log, báo cáo crash hay bộ nhớ không mã hóa ngoài cơ sở dữ liệu cục bộ đã khai báo.
- Xin quyền hệ điều hành ngay trước khi dùng tính năng cần quyền, kèm giải thích; xử lý trường hợp bị từ chối.
- Migration của cơ sở dữ liệu cục bộ chỉ thêm mới; MUST NOT sửa, gộp hay xóa migration đã phát hành.
- Trợ năng: mọi phần tử tương tác có nhãn và vai trò cho trình đọc màn hình, vùng chạm tối thiểu 44 × 44 pt trên iOS và 48 × 48 dp trên Android, chữ co giãn theo cỡ chữ hệ thống; tiêu chí đầy đủ ở `specflow/CONVENTIONS.md` mục 10.2.
- {{LANGUAGE_STRICT_MODE_RULE}}
