---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.2.0
language: vi-en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [frontend-web]
assembled_from: []
---

# Quy tắc giao diện web (Frontend Golden Rules)

<!-- fill: Chép thành .claude/rules/frontend-golden-rules.md ở Giai đoạn 2. paths liệt kê thư mục mã nguồn giao diện theo ARCHITECTURE §4, mỗi glob một phần tử. assembled_from ghi "overlays/frontend-web/agent-rules/frontend-golden-rules.md@<template_version>" và stack profile đã dùng. -->

- Tách tầng: route chỉ lấy dữ liệu ban đầu và ghép thành phần của tính năng; logic hiển thị nằm trong thư mục tính năng; thành phần giao diện dùng chung không chứa nghiệp vụ và không gọi API.
- {{RENDER_BOUNDARY_RULE}}
- Mọi lời gọi API đi qua client sinh từ OpenAPI; MUST NOT viết tay kiểu response hay gọi API bằng URL ghép chuỗi.
- Mỗi màn hình hiện thực đủ năm trạng thái giao diện theo bảng trong SPEC §3; MUST NOT để màn hình trắng khi đang tải hoặc khi lỗi.
- Mọi chuỗi hiển thị lấy qua khóa chuỗi theo locale; MUST NOT viết cứng văn bản hiển thị trong thành phần.
- MUST NOT viết màu, spacing, radius hay cỡ chữ thô trong mã giao diện, kể cả giá trị tùy ý (arbitrary value) của công cụ CSS tiện ích; chỉ dùng token của `docs/design-system/tokens.json` qua file ánh xạ token (biến CSS). File ánh xạ đó, viết tay hoặc sinh bằng công cụ, là nơi duy nhất được chứa giá trị thô và MUST khớp `tokens.json`. Theme của thư viện giao diện chỉ đổi qua token, không sửa trực tiếp file theme của thư viện. Dự án chưa có `docs/design-system/` (wireframe từ template trang cũ hơn `1.4.0`) giữ nguồn token ghi ở ARCHITECTURE.
- Giá, số tiền, quyền và trạng thái hiển thị theo dữ liệu API trả về; MUST NOT tự tính rồi gửi các giá trị này lên API.
- Thao tác ghi khóa trong lúc đang gửi; mỗi nội dung gửi có một `Idempotency-Key` riêng. Sau lỗi mạng, hết thời gian chờ hoặc `5xx`, form khóa sửa và chỉ gửi lại đúng nội dung đó với cùng khóa tới khi có phản hồi xác định.
- MUST NOT lưu token, secret hay dữ liệu cá nhân trong `localStorage` hoặc `sessionStorage`; biến môi trường gửi xuống trình duyệt không chứa secret.
- Trợ năng: thẻ ngữ nghĩa trước ARIA, mọi trường có nhãn, lỗi gắn với trường, mọi thao tác làm được bằng bàn phím; tiêu chí đầy đủ ở `specflow/CONVENTIONS.md` mục 10.2.
- {{LANGUAGE_STRICT_MODE_RULE}}
