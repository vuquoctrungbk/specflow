---
doc_type: overlay
status: stable
version: 1.3.0
language: vi-en
surface: mobile-app
---

# Overlay mobile-app

## 1. Bề mặt (Surface)

Ứng dụng cài trên điện thoại hoặc máy tính bảng (iOS, Android), phân phối qua cửa hàng ứng dụng. Ứng dụng giữ một bản sao dữ liệu trên thiết bị, cho người dùng làm việc khi mất mạng và đồng bộ với API khi có mạng lại. Nguồn chân lý của dữ liệu nghiệp vụ và mã lỗi là API; bản trên thiết bị là bản sao cộng các thay đổi chưa gửi. Nhiều phiên bản ứng dụng cùng chạy ngoài thực tế, vì người dùng không cập nhật cùng lúc.

| Chọn overlay này khi | Không chọn khi |
| --- | --- |
| Dự án có ứng dụng cài trên thiết bị di động, dùng phần cứng của thiết bị (camera, vị trí, thông báo đẩy) hoặc phải làm việc khi mất mạng | Giao diện chạy trên trình duyệt, kể cả trình duyệt trên điện thoại (xem `frontend-web`); dự án chỉ cung cấp API mà ứng dụng gọi (xem `backend-api`) |

Dạng test `CONC` của bề mặt này chạy ở mức integration trên cùng engine SQL với thiết bị (SQLite của máy chạy test, qua cùng cổng truy vấn và cùng cách xếp hàng kết nối như ứng dụng), với API giả lập giữ phiên bản bản ghi và lưu phản hồi theo khóa idempotency. Ba dạng bắt buộc: hai thiết bị (hai cơ sở dữ liệu cục bộ độc lập) cùng sửa một bản ghi khi mất mạng rồi lần lượt đồng bộ; một thiết bị kích hoạt đồng bộ nhiều lần cùng lúc (có mạng lại, mở lại ứng dụng, kéo để làm mới); và người dùng sửa bản ghi trong lúc thay đổi trước của chính bản ghi đó đang được gửi, với phản hồi về được và với phản hồi bị mất. Không dùng sleep để sắp thứ tự; thứ tự do test điều khiển bằng lời gọi đồng bộ và độ trễ của API giả lập.

## 2. Slot được cung cấp (Provided Slots)

| Slot | File | Nội dung | Có `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Nền tảng và phiên bản hệ điều hành, ma trận thiết bị, làm việc khi mất mạng, quyền hệ điều hành, lưu trữ an toàn, phiên bản ứng dụng tối thiểu | Không |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Màn hình, năm trạng thái giao diện và trạng thái đồng bộ của bản ghi, trợ năng; API, thông báo đẩy, deep link; phần cứng của thiết bị | Không |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | Dữ liệu trên thiết bị, chiến lược đồng bộ, bảng xung đột | Không |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, bản đồ điều hướng và bảng điều hướng có cột `SCR ID`, luồng đồng bộ, góc nhìn build và phân phối | Không |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Quy tắc tầng: màn hình, tính năng, cơ sở dữ liệu cục bộ, bộ máy đồng bộ, client API | Có |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Schema cục bộ, migration trên thiết bị, cột đồng bộ, hàng đợi thay đổi, ánh xạ sang DTO của API | Có |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Quy tắc làm việc khi mất mạng, quy ước đồng bộ, trạng thái giao diện, ánh xạ mã lỗi sang giao diện, quyền hệ điều hành | Có |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Phiên bản ứng dụng, ký và phân phối, phát hành theo tỉ lệ, cập nhật qua mạng, phiên bản tối thiểu, tương thích với API | Không |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Màn hình và tham số điều hướng, năm trạng thái, trạng thái đồng bộ, thao tác ghi cục bộ, hợp đồng đồng bộ, quyền, ánh xạ lỗi, khóa chuỗi | Có |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration với cơ sở dữ liệu cục bộ, e2e trên máy ảo, trợ năng, `CONC`, smoke trên ma trận thiết bị | Có |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Bảng lệnh verify | Không |

## 3. Thứ tự đọc khi ghép (Assembly Order)

1. File core của giai đoạn (`core/01`, `core/02`, `core/04`, `core/06`).
2. File này.
3. File section chứa khối SLOT-CONTENT tương ứng ở bảng mục 2.
4. Stack profile đã chọn trong Intake: bảng "Giá trị placeholder", mục `(Tech Stack)` và các khối PROFILE-CONTENT.
5. Rule của bề mặt ở `agent-rules/` khi tạo `.claude/rules/` (Giai đoạn 2).

Quy tắc ghép chi tiết ở CONVENTIONS mục 2 và PLAYBOOK mục 4.

## 4. Stack profile (Stack Profiles)

| Profile | Stack | File |
| --- | --- | --- |
| `react-native-expo` | React Native với Expo SDK, Expo Router, TypeScript, SQLite trên thiết bị, Jest, Maestro | [stack-profiles/react-native-expo.md](stack-profiles/react-native-expo.md) |

Stack khác chưa có profile (ví dụ Flutter, ứng dụng native Swift hoặc Kotlin): đề xuất giá trị placeholder và nội dung profile trong ARCHITECTURE §2 kèm ADR (PLAYBOOK mục 3, quy tắc 5).

## 5. Rule cho agent (Agent Rules)

| File | Chép thành | Áp dụng cho |
| --- | --- | --- |
| [agent-rules/mobile-golden-rules.md](agent-rules/mobile-golden-rules.md) | `.claude/rules/mobile-golden-rules.md` | Mã nguồn ứng dụng di động (`paths` theo cây thư mục ở ARCHITECTURE §4) |

## 6. Checklist riêng của bề mặt (Surface Checklist)

Tự kiểm cùng checklist "Overlay đã áp" ở PLAYBOOK mục 4.

| Kiểm tra | Tài liệu | Đạt |
| --- | --- | :---: |
| Mọi màn hình ở SRS §3 có `SCR ID` (Intake tạo từ template Intake `1.3.0` trở lên) và ghi rõ dùng được khi mất mạng hay không; mọi FR của ứng dụng truy xuất tới FR hoặc endpoint của API mà nó dùng | SRS §3, §8 | [ ] |
| Mỗi thực thể trên thiết bị có nguồn ở API, phạm vi dữ liệu giữ trên máy, cách xóa; chiến lược xung đột được một ADR bao phủ | SRS §4; ARCHITECTURE §5, §12 | [ ] |
| Thao tác ghi cục bộ và hàng đợi thay đổi cập nhật trong cùng một transaction; mỗi thay đổi có khóa idempotency riêng, gửi lại với cùng khóa | ARCHITECTURE §5, §7; SPEC §3, §5 | [ ] |
| Mọi mã lỗi mà ứng dụng xử lý có trong ARCHITECTURE §7.1 kèm khóa chuỗi và hành vi, gồm cả trạng thái đồng bộ của bản ghi | ARCHITECTURE §7 | [ ] |
| Kiểu dữ liệu API sinh từ tài liệu OpenAPI của API; không có kiểu response viết tay | ARCHITECTURE §5 | [ ] |
| Mỗi màn hình trong SPEC có đủ năm trạng thái giao diện và bảng trạng thái đồng bộ cho bản ghi sửa được khi mất mạng | SPEC §3 | [ ] |
| Có test `CONC` cho hai thiết bị cùng sửa khi mất mạng, cho nhiều lần kích hoạt đồng bộ cùng lúc và cho lần sửa trong lúc thay đổi của cùng bản ghi đang gửi; có smoke test trên ma trận thiết bị trước khi phát hành | SPEC §9 | [ ] |
| API giữ contract cho mọi phiên bản ứng dụng còn trên phiên bản tối thiểu; cách buộc cập nhật đã chốt | ARCHITECTURE §8 | [ ] |

## 7. Giai đoạn 1W: Wireframe (Stage 1W)

Bề mặt này có giao diện nên dự án có Giai đoạn 1W (PLAYBOOK mục 2 và 2.2.1): Intake mục 14 ghi Giai đoạn 1W: Có, Intake mục 9 ghi người duyệt Gate 1W. Áp cho dự án có Intake tạo từ template Intake `1.3.0` trở lên.

- ID màn hình `SCR-{MOD}-NN` đặt ở Giai đoạn 1, cột `SCR ID` của bảng Giao diện người dùng ở SRS §3 (khối `srs.external-interfaces` của overlay này). Giai đoạn 1W chi tiết hóa mỗi ID thành một trang `docs/wireframes/SCR-<MOD>-NN.md`, không thêm hay bớt màn hình. Dự án có cả web và mobile dùng chung một mã phân hệ: NN vẫn duy nhất theo MOD, màn hình web và màn hình mobile là hai ID khác nhau.
- Hệ thống thiết kế: Giai đoạn 1W viết thêm `docs/design-system/DESIGN_SYSTEM.md` và `docs/design-system/tokens.json` theo CONVENTIONS mục 10.7, trước các trang màn hình; mỗi trang chọn một Template, dẫn Pattern và Component ID của tài liệu đó. Theme mặc định của thư viện giao diện của stack profile (Intake mục 14) chỉ là một hướng thị giác, dùng khi được chọn có chủ đích; profile `none` ghi chưa chọn thư viện và xét lại ở Giai đoạn 2.
- Template `core/07_Wireframe_Template/` dùng chung cho mọi bề mặt có giao diện và không có slot; overlay không cung cấp khối cho wireframe. Cách điền riêng cho mobile:

| Mục của template | Cách điền cho `mobile-app` |
| --- | --- |
| Điểm vào (danh mục màn hình và trang) | Deep link khi màn hình mở được bằng deep link; nếu không, tên màn hình trong navigator; route trong ứng dụng ở cột Route của SRS §3 |
| Bố cục low-fi | Vẽ ở hướng dọc; thanh điều hướng, thanh tab và vùng an toàn là vùng riêng khi màn hình có |
| Năm trạng thái UI | Dữ liệu đã có trên máy hiển thị ngay, `Loading` chỉ khi máy chưa có dữ liệu; màn hình sửa được khi mất mạng ghi trạng thái đồng bộ của bản ghi (`Synced`, `Queued`, `Conflict`, `Rejected`) ở cột Hiển thị; chỉ báo mạng khi mất mạng |
| Điều hướng vào và ra | Vào từ deep link hay thông báo đẩy; tham số điều hướng; nơi cử chỉ quay lại của hệ thống đưa người dùng tới |
| Ghi chú trợ năng | Theo CONVENTIONS mục 10.2 ở mức WCAG của NFR-USAB; tiêu chí viết theo ngữ web (trang, tiêu đề trang) áp theo WCAG2ICT. Con số của mobile: vùng chạm tối thiểu 44 × 44 pt trên iOS và 48 × 48 dp trên Android (cao hơn mức sàn của WCAG 2.5.8); chữ co giãn theo cỡ chữ hệ thống; trình đọc màn hình của hệ điều hành (VoiceOver, TalkBack) |
| HTML đầy đủ (theo Intake mục 14) | Một file tĩnh mỗi trang theo CONVENTIONS mục 7, khung theo kích thước điện thoại, hướng dọc; trang Markdown thắng khi hai bên lệch nhau |

- Sau Gate 1W: bảng điều hướng ở ARCHITECTURE §3 (khối `arch.views`) có cột `SCR ID`, mỗi `SCR-*` của chỉ mục wireframe ít nhất một hàng (Gate 2); bảng Màn hình ở SPEC §3 (khối `spec.contract`) dẫn `SCR ID` và trang wireframe, không định nghĩa lại màn hình. Ở Giai đoạn 2, ARCHITECTURE §7 ghi cách ánh xạ token thành mã nguồn (khối `arch.conventions`) và stack profile ghi công cụ ánh xạ; code chỉ đọc token đã ánh xạ.
