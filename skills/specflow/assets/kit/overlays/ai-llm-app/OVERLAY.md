---
doc_type: overlay
status: stable
version: 1.0.0
language: vi-en
surface: ai-llm-app
---

# Overlay ai-llm-app

## 1. Bề mặt (Surface)

Tính năng dựa trên mô hình ngôn ngữ lớn (LLM): phân loại, trích xuất, tóm tắt, trả lời theo tài liệu, agent gọi công cụ. Đầu ra của mô hình không tất định, có thể sai hoặc bị dữ liệu đầu vào dẫn dắt (prompt injection), và mỗi lời gọi tốn tiền. Vì vậy prompt được coi là contract: mỗi prompt có một Prompt Spec (`docs/prompts/PROMPT_<NAME>.md` theo [Prompt_Spec_Template.md](Prompt_Spec_Template.md)) với schema đầu ra, chế độ lỗi, guardrail và ngưỡng đánh giá trên bộ dữ liệu. Tính năng AI thường chạy trong một dịch vụ hoặc worker phía server; màn hình hay API đưa kết quả tới người dùng thuộc overlay của bề mặt đó.

| Chọn overlay này khi | Không chọn khi |
| --- | --- |
| Dự án gọi mô hình ngôn ngữ lớn để tạo hoặc đánh giá nội dung, và kết quả ảnh hưởng tới người dùng hay dữ liệu | Chỉ dùng AI lúc lập trình (coding agent) mà sản phẩm không gọi mô hình; mô hình học máy truyền thống tự huấn luyện (chưa có overlay, xử lý theo PLAYBOOK mục 3 quy tắc 4) |

Dạng test `CONC` của bề mặt này chạy ở mức integration với nhà cung cấp mô hình giả lập ở tầng `fetch`: cùng một đầu vào được hai worker hoặc hai lần kích hoạt xử lý cùng lúc, và kết quả chỉ được ghi một lần; hoặc nhiều lời gọi song song cùng dùng một ngân sách token và ngân sách không bị vượt. Không dùng sleep để sắp thứ tự.

Ba loại test riêng của bề mặt: `EVAL` chạy prompt thật trên bộ dữ liệu có nhãn và so với ngưỡng; `INJ` chạy bộ dữ liệu tấn công (prompt injection, yêu cầu vượt quyền); `COST` đo token mỗi lời gọi trên bộ dữ liệu. Ba loại này gọi mô hình thật nên chạy trong job riêng của CI khi đổi prompt, guard đầu vào, client mô hình, mô hình hoặc tham số, và theo lịch, không chạy ở mỗi commit.

## 2. Slot được cung cấp (Provided Slots)

| Slot | File | Nội dung | Có `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Nhà cung cấp và họ mô hình, đầu ra có cấu trúc, tính không tất định, độ trễ, ngân sách, dữ liệu gửi tới nhà cung cấp, con người kiểm soát | Không |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | API của nhà cung cấp mô hình, kho vector, công cụ mà mô hình được gọi, cách kết quả AI tới người dùng | Không |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | Dữ liệu vào và ra của mô hình, nhật ký lời gọi, bộ dữ liệu đánh giá | Không |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | Pipeline từ guard đầu vào tới hậu xử lý, C4 Level 2, luồng một lời gọi có thử lại và phương án dự phòng, góc nhìn triển khai | Không |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Quy tắc tầng: prompt, client mô hình, guard, bộ dữ liệu đánh giá | Có |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Schema đầu ra có cấu trúc, bản ghi nhật ký lời gọi, định dạng bộ dữ liệu | Có |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Quy ước prompt và tham số mô hình, guardrail, xử lý lỗi và dự phòng, ngân sách, cổng đánh giá | Có |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Khóa API và hạn mức theo môi trường, giám sát token và chi phí, nâng mô hình, công tắc tắt AI | Không |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Prompt dùng, luồng xử lý và bảng quyết định, ngân sách, ánh xạ lỗi | Có |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration với nhà cung cấp giả lập, `EVAL`, `INJ`, `COST`, `CONC` | Có |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Bảng lệnh verify | Không |

## 3. Thứ tự đọc khi ghép (Assembly Order)

1. File core của giai đoạn (`core/01`, `core/02`, `core/04`, `core/06`).
2. File này.
3. File section chứa khối SLOT-CONTENT tương ứng ở bảng mục 2.
4. Stack profile đã chọn trong Intake: bảng "Giá trị placeholder", mục `(Tech Stack)` và các khối PROFILE-CONTENT.
5. Rule của bề mặt ở `agent-rules/` khi tạo `.claude/rules/` (Giai đoạn 2).
6. Giai đoạn 1: ID `PROMPT-{MOD}-NNN` của mỗi prompt đặt ở bảng bộ dữ liệu đánh giá của SRS §4.1. Giai đoạn 3: mỗi prompt mới hoặc prompt đổi nội dung có một Prompt Spec từ [Prompt_Spec_Template.md](Prompt_Spec_Template.md), được duyệt trước khi viết SPEC dùng nó (PLAYBOOK mục 2.4).

Quy tắc ghép chi tiết ở CONVENTIONS mục 2 và PLAYBOOK mục 4.

## 4. Stack profile (Stack Profiles)

| Profile | Stack | File |
| --- | --- | --- |
| `typescript-anthropic-sdk` | TypeScript trên Node.js, Anthropic TypeScript SDK với đầu ra có cấu trúc qua Zod, Vitest | [stack-profiles/typescript-anthropic-sdk.md](stack-profiles/typescript-anthropic-sdk.md) |

Stack khác chưa có profile (ví dụ Python, nhà cung cấp mô hình khác): đề xuất giá trị placeholder và nội dung profile trong ARCHITECTURE §2 kèm ADR (PLAYBOOK mục 3, quy tắc 5).

## 5. Ghép với backend-api (Combining with backend-api)

Tính năng AI thường nằm trong một backend. Khi dự án chọn cả `backend-api` và `ai-llm-app` trong cùng một repo:

- Cây thư mục, cấu hình Vitest và oxlint, lệnh verify lấy theo profile của backend; client mô hình, module prompt, guard và schema đầu ra đặt trong thư mục phân hệ của backend theo quy tắc tầng của cả hai overlay.
- Khối PROFILE-SLOT `arch.layout` của `ai-llm-app` ghi N/A kèm lý do "dùng cây thư mục của profile backend"; `arch.schema`, `arch.conventions`, `spec.contract`, `spec.test-types` của profile AI vẫn chèn, với đường dẫn đổi theo cây của backend.
- Thêm một project `eval` vào cấu hình Vitest của backend cho test `EVAL`, `INJ`, `COST`, và thêm dòng đánh giá prompt vào bảng lệnh verify; bảng lệnh verify của dự án chỉ có một bản.
- Mã lỗi của hai bề mặt nằm chung một Error Code Registry; mã của tác vụ AI trả cho client qua envelope của backend khi tác vụ chạy trong request.

## 6. Rule cho agent (Agent Rules)

| File | Chép thành | Áp dụng cho |
| --- | --- | --- |
| [agent-rules/ai-golden-rules.md](agent-rules/ai-golden-rules.md) | `.claude/rules/ai-golden-rules.md` | Mã gọi mô hình, prompt, guard và bộ dữ liệu đánh giá (`paths` theo cây thư mục ở ARCHITECTURE §4) |

## 7. Checklist riêng của bề mặt (Surface Checklist)

Tự kiểm cùng checklist "Overlay đã áp" ở PLAYBOOK mục 4.

| Kiểm tra | Tài liệu | Đạt |
| --- | --- | :---: |
| Mỗi tính năng AI có ngưỡng chất lượng đo được trên bộ dữ liệu, ngân sách token và độ trễ, và hành vi khi mô hình sai hoặc không sẵn sàng | SRS §2.5, §7 | [ ] |
| Dữ liệu gửi tới nhà cung cấp mô hình đã liệt kê; dữ liệu cá nhân được che hoặc có căn cứ pháp lý; chính sách lưu dữ liệu của nhà cung cấp đã ghi | SRS §3, §4; ARCHITECTURE §9 | [ ] |
| ID mô hình chính xác trong ARCHITECTURE §2.1 và được một ADR bao phủ; nâng mô hình đi qua cổng đánh giá | ARCHITECTURE §2, §8, §12 | [ ] |
| Mỗi prompt có Prompt Spec với schema đầu ra, chế độ lỗi, guardrail, chỉ số đánh giá và ngưỡng | `docs/prompts/` | [ ] |
| Đầu ra của mô hình luôn qua schema và quy tắc nghiệp vụ trước khi dùng; đầu ra không hợp lệ có đường dự phòng | ARCHITECTURE §7; SPEC §3 | [ ] |
| Bộ dữ liệu đánh giá có ít nhất 20 mẫu, không chứa dữ liệu cá nhân thật; có bộ dữ liệu tấn công cho prompt nhận nội dung không tin cậy | SRS §4; Prompt Spec | [ ] |
| SPEC có test `EVAL`, `INJ`, `COST` theo Prompt Spec và test `CONC` cho mỗi bất biến | SPEC §9 | [ ] |
