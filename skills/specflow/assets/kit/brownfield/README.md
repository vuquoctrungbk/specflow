# Bộ brownfield

Lối vào cho dự án đã có mã nguồn đang chạy (Intake `mode: brownfield`). Bộ này dùng chung template lõi, overlay, stack profile và starter với dự án greenfield; nó chỉ thêm các bước phục hồi hiện trạng, đo mốc hồi quy, phân tích khoảng cách, kế hoạch chuyển đổi, phụ lục cho SPEC và phần bổ sung cho prompt của PLAYBOOK. Quy trình đầy đủ ở [PLAYBOOK_BROWNFIELD.md](PLAYBOOK_BROWNFIELD.md).

## File trong bộ

Số thứ tự trong tên template là thứ tự thực hiện.

| File | Loại | Đầu ra trong dự án | Bước |
| --- | --- | --- | --- |
| [PLAYBOOK_BROWNFIELD.md](PLAYBOOK_BROWNFIELD.md) | Playbook bổ sung | Không có | Mọi bước |
| [00_Codebase_Summary_Template.md](00_Codebase_Summary_Template.md) | Template | `docs/brownfield/CODEBASE_SUMMARY.md` | 0a |
| [01_As_Is_Architecture_Recovery_Template.md](01_As_Is_Architecture_Recovery_Template.md) | Template | `docs/brownfield/AS_IS_ARCHITECTURE.md` | 0b |
| [02_Regression_Baseline_Template.md](02_Regression_Baseline_Template.md) | Template | `docs/brownfield/REGRESSION_BASELINE.md` | 0c |
| [03_Gap_Analysis_Template.md](03_Gap_Analysis_Template.md) | Template | `docs/brownfield/GAP_ANALYSIS.md` | 0d, sau SRS to-be |
| [04_Migration_Plan_Template.md](04_Migration_Plan_Template.md) | Template | `docs/brownfield/MIGRATION_PLAN.md` | 0e, cùng Architecture to-be |
| [Spec_Brownfield_Addendum.md](Spec_Brownfield_Addendum.md) | Phụ lục cho SPEC | Ba khối chèn vào mỗi SPEC | Giai đoạn 3 |

## Cách dùng

1. Trước Prompt 0, xem và tắt hook của Claude Code có sẵn trong repo nếu hook chạy lệnh của dự án (PLAYBOOK_BROWNFIELD mục 5.1 quy tắc 6).
2. Chạy Prompt 0 của PROMPTS.md với `mode: brownfield`, cộng phần bổ sung ở PLAYBOOK_BROWNFIELD mục 6.1. Ở Gate 0, chủ dự án quyết định có cho viết test `REG` ở Giai đoạn 0R hay không (mặc định cho phép; repo chưa có công cụ test thì duyệt thêm công cụ hoặc dùng thủ tục thủ công) và cách xử lý `CLAUDE.md`, `.claude/`, `docs/` đã có trong repo.
3. Chạy Prompt B0 (chuẩn bị repo), mở phiên mới, chạy B1 rồi B2 ở PLAYBOOK_BROWNFIELD mục 6; duyệt Gate 0R. Lệnh của dự án chỉ chạy trong worktree sạch, khi mọi kho dữ liệu và dịch vụ ngoài trỏ tới đích cục bộ hoặc dùng một lần (PLAYBOOK_BROWNFIELD mục 5.1).
4. Chạy Prompt 1 (SRS to-be) của PROMPTS.md cộng phần bổ sung, rồi Prompt B3; duyệt Gate 1.
5. Chạy Prompt 2 (Architecture to-be) của PROMPTS.md cộng phần bổ sung, rồi Prompt B4; duyệt Gate 2.
6. Từ Giai đoạn 3, chạy prompt của PLAYBOOK cộng phần bổ sung; mỗi SPEC áp phụ lục brownfield.

## Bảo trì

- Không chép nội dung của `core/` hay `overlays/` vào đây; chỉ tham chiếu.
- `scripts/check-templates.sh` kiểm tra frontmatter, mục bắt buộc, placeholder, link, heading đánh số và tính trung lập về stack của bộ này như với `core/`, và kiểm tra bảng tự kiểm Gate 0R của Regression Baseline cùng câu chữ với PLAYBOOK_BROWNFIELD mục 3.1.
