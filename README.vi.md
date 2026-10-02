# specflow

Tiếng Việt · [English](README.md)

**specflow** là một agent skill viết bộ tài liệu của dự án phần mềm trước khi
viết code, theo phương pháp spec-first. Bạn mô tả điều mình cần,
đính kèm những gì đang có (brief, biên bản họp, bảng yêu cầu), rồi specflow sẽ:

1. đọc yêu cầu và tài liệu đính kèm;
2. soạn bản nháp từ template của bộ kit;
3. hỏi bạn những điều nó chưa tự chốt được, mỗi câu kèm sẵn các lựa chọn và
   phương án đề xuất;
4. hoàn thiện tài liệu và tự kiểm theo exit gate của giai đoạn;
5. dừng lại chờ bạn duyệt rồi mới sang giai đoạn sau.

```text
/specflow tạo tài liệu SRS cho ứng dụng đặt phòng họp nội bộ cho công ty 50 người:
nhân viên xem lịch trống, đặt, hủy; quản trị viên quản lý phòng; đăng nhập bằng Google Workspace của công ty
```

Skill chạy trên **Claude Code**, **Codex** (CLI, extension trong IDE và Codex
trong ChatGPT), **OpenCode** và **Google Antigravity**.

## Skill tạo ra những gì

Phương pháp gồm 3 bước. Mỗi giai đoạn kết thúc ở một gate, do người có tên trong
Intake duyệt.

| Bước | Giai đoạn | Tài liệu | Gate |
| --- | --- | --- | --- |
| 1. Yêu cầu | 0 Intake | `docs/intake/PROJECT_INTAKE.md`: mục tiêu, phạm vi, định tuyến (bề mặt, stack profile), các đợt phát hành, người duyệt | Gate 0 |
| | 0R Mốc brownfield | Codebase Summary, As-Is Architecture, Regression Baseline (chỉ dự án đã có code) | Gate 0R |
| | 1 SRS | `docs/srs/SRS.md`: cấu trúc ISO/IEC/IEEE 29148, FR viết theo EARS, NFR ánh xạ ISO/IEC 25010, use case, tiêu chí nghiệm thu | Gate 1 |
| | 1W Wireframe | `docs/wireframes/`: mỗi màn hình một trang, đối chiếu FR ↔ màn hình, hệ thống thiết kế (hướng thị giác, token, danh mục component), thông tin ưu tiên, hành động chính và nội dung biên của từng trang, đánh số vùng bố cục, kiểm WCAG 2.2 và heuristic Nielsen, kiểm mẫu thiết kế lừa người dùng | Gate 1W |
| 2. Thiết kế | 2 Architecture | `docs/ARCHITECTURE.md` và ADR trong `docs/adr/` | Gate 2 |
| | 3 SPEC | `docs/specs/SPEC_*.md`: mỗi phần việc của một đợt một hợp đồng thực thi | Gate 3 (theo đợt) |
| 3. Kế hoạch | 4a Plan | `plans/<ngày>-<slug>/`: các pha theo SPEC, bảng test, Definition of Ready | Gate 4 |
| Thực thi | 4b, 5 | Code theo TDD, kiểm chứng, đồng bộ tài liệu | Gate 5 (theo SPEC) |

Tài liệu theo quy ước ngôn ngữ của bộ kit: diễn giải tiếng Việt có dấu, thuật
ngữ kỹ thuật và định danh giữ tiếng Anh, trừ khi Intake của dự án ghi ngôn ngữ
tài liệu khác (ví dụ tiếng Anh cho đối tác nước ngoài). specflow trò chuyện với
bạn bằng ngôn ngữ bạn dùng.

## Cài đặt

Chọn một trong các cách dưới. Cách nào cũng cài cùng thư mục `skills/specflow/`.

specflow chỉ gồm Markdown nên chạy ở mọi nơi agent chạy được: Windows 10 và 11,
macOS và Linux (đã kiểm trên Ubuntu). Trong các đường dẫn dưới, `~` là thư mục
home của bạn: `/home/<tên>` trên Linux, `/Users/<tên>` trên macOS và
`%USERPROFILE%` (`C:\Users\<tên>`) trên Windows. Cả bốn agent dùng cùng các thư
mục này trên cả ba hệ điều hành; không agent nào dùng `AppData` hay
`~/Library` cho skill.

### Mọi agent, một lệnh (skills CLI)

Cần Node.js. Lệnh cài vào mọi agent bạn liệt kê:

```bash
npx skills add vuquoctrungbk/specflow -a claude-code -a codex -a opencode -a antigravity
```

Thêm `-g` để cài cho tài khoản người dùng thay vì cho dự án hiện tại. Mặc định
CLI tạo liên kết (trên Windows là junction, không cần quyền admin); thêm
`--copy` nếu muốn chép file. OpenCode cũng đọc thư mục
skill của Claude Code và Codex, nên khi đã cài cho một trong hai agent đó, bỏ
`-a opencode` để không có hai skill trùng tên, rồi chép file lệnh OpenCode bằng
tay (xem mục "Chép bằng tay"). Với Antigravity và `-g`, kiểm tra skill nằm ở
`~/.gemini/config/skills/`, thư mục toàn cục mà tài liệu Antigravity nêu; nếu
không, chuyển nó vào đó.

### Mọi agent, từ bản clone (script cài đặt)

macOS và Linux (bash; bash 3.2 có sẵn trên macOS chạy được):

```bash
git clone https://github.com/vuquoctrungbk/specflow.git
cd specflow
./install.sh --agent all                                   # mọi agent, cho tài khoản của bạn
./install.sh --agent claude --scope project --project-dir ~/code/my-app   # một agent, một dự án
```

Windows (Windows PowerShell 5.1 hoặc PowerShell 7):

```powershell
git clone https://github.com/vuquoctrungbk/specflow.git
cd specflow
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent all
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent claude -Scope project -ProjectDir C:\code\my-app
```

`-ExecutionPolicy Bypass` chỉ áp cho lần chạy này; cần vì Windows mặc định chặn
script chưa ký. Nếu tải file ZIP thay vì clone, chạy `Unblock-File .\install.ps1`
trước.

Hai script nhận cùng các tùy chọn: agent (`claude`, `codex`, `opencode`,
`antigravity` hoặc `all`; `--agent` lặp lại được, `-Agent` nhận danh sách cách
nhau bằng dấu phẩy), phạm vi (mặc định `user`, hoặc `project` kèm thư mục dự
án), và force. Bản đã cài được giữ nguyên, trừ khi bạn dùng force để thay (dùng
khi nâng cấp). Khi cài OpenCode cùng Claude Code hoặc Codex, script chỉ cài file
lệnh cho OpenCode, vì OpenCode đã đọc thư mục skill của hai agent kia.

### Plugin marketplace của Claude Code

```text
/plugin marketplace add vuquoctrungbk/specflow
/plugin install specflow@specflow
```

Skill cài qua plugin có tiền tố tên plugin, nên lệnh là `/specflow:specflow`.
Muốn gõ `/specflow` gọn, hãy cài bằng script hoặc skills CLI.

### Chép bằng tay

Chép cả thư mục `skills/specflow/` vào thư mục skills của agent:

| Agent | Cho tài khoản | Cho một dự án | Cách gọi |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills/specflow/` | `.claude/skills/specflow/` | `/specflow …` |
| Codex | `~/.agents/skills/specflow/` | `.agents/skills/specflow/` | `$specflow …` hoặc `/skills` |
| OpenCode | `~/.config/opencode/skills/specflow/` | `.opencode/skills/specflow/` | `/specflow …` (cần file lệnh ở dưới) |
| Antigravity | `~/.gemini/config/skills/specflow/` | `.agents/skills/specflow/` | `/specflow …` |

OpenCode cũng đọc skill ở `.claude/skills/` và `.agents/skills/`. Để có lệnh
`/specflow` trong OpenCode, chép `adapters/opencode/commands/specflow.md` vào
`~/.config/opencode/commands/` (tài khoản) hoặc `.opencode/commands/` (dự án).
Không có file này, OpenCode vẫn dùng skill khi bạn gọi tên skill. Một số bản
Codex tìm skill ở `~/.codex/skills/` thay vì `~/.agents/skills/`; nếu không
thấy `$specflow`, chép thư mục vào đó.

Sau khi cài, khởi động lại agent hoặc mở phiên mới.

## Cách dùng

Mở phiên ở thư mục gốc của dự án và gọi skill kèm điều bạn cần. Đính kèm hoặc
dán tài liệu đang có; specflow coi đó là thông tin về dự án.

| Agent | Ví dụ |
| --- | --- |
| Claude Code | `/specflow tạo tài liệu SRS với các thông tin sau: …` |
| Codex | `$specflow viết Intake cho app kiểm tra hiện trường, ghi chú đính kèm` |
| OpenCode | `/specflow soạn Architecture cho SRS đã duyệt` |
| Antigravity | `/specflow vẽ wireframe cho đợt R1` |

Các yêu cầu khác skill hiểu:

- `/specflow bắt đầu dự án mới: <brief>`: Giai đoạn 0, Intake.
- `/specflow áp specflow cho repo có sẵn này`: Giai đoạn 0 và 0R của brownfield.
- `/specflow viết SPEC cho đợt R1`: Giai đoạn 3, mỗi lượt một SPEC.
- `/specflow lập plan cho đợt R1`: Giai đoạn 4a.
- `/specflow tiếp tục`: làm tiếp giai đoạn đang dở trong phiên mới.
- `Duyệt Gate 1` (hoặc "duyệt gate 1, người duyệt: Lan"): ghi nhận lần duyệt
  và đề nghị bắt đầu giai đoạn sau.

### Một phiên làm việc diễn ra thế nào

1. **Lần đầu trong một dự án.** specflow hỏi trước khi chép bộ kit (quy tắc và
   template) vào thư mục `specflow/` của repo. Hãy commit thư mục này cùng tài liệu: tài liệu
   dẫn chiếu tới nó và các phiên sau đọc nó.
2. **Thiếu giai đoạn trước.** Nếu bạn yêu cầu SRS khi dự án chưa có Intake đã
   duyệt, skill đưa hai lựa chọn: làm Intake trước (đề xuất; thông tin bạn đưa
   cho SRS được giữ lại để dùng), hoặc bạn gửi Intake đã có. Mỗi giai đoạn vẫn
   qua gate riêng của nó.
3. **Vòng hỏi.** Sau bản nháp đầu, mỗi vòng skill hỏi tối đa năm câu, câu chặn
   và câu chạm hợp đồng hỏi trước. Mỗi câu có hai đến bốn lựa chọn, phương án
   đề xuất đứng đầu kèm lý do. Trên Claude Code bạn bấm chọn; OpenCode dùng
   công cụ hỏi của nó; nơi khác bạn nhận danh sách đánh số và trả lời kiểu
   `1a, 2c, 3: <ý của bạn>`.
4. **Gate.** Cuối lượt, skill liệt kê file đã tạo hoặc sửa, checklist exit gate
   (hàng nào đạt, hàng nào chưa) và câu hỏi còn mở. Người duyệt ghi trong Intake
   xem lại rồi gửi `Duyệt Gate N`; chỉ khi đó tài liệu mới chuyển sang
   `approved` và giai đoạn sau mới bắt đầu.

### File trong dự án của bạn

| Đường dẫn | Ai tạo | Ghi chú |
| --- | --- | --- |
| `specflow/` | specflow, ở lần chạy đầu | Quy tắc và template; không sửa về sau |
| `docs/…`, `plans/…` | từng giai đoạn | Các tài liệu ở bảng trên |
| `CLAUDE.md` | Giai đoạn 0 | Ngữ cảnh dự án cho các phiên sau, ở mọi agent |
| `.claude/rules/` | Giai đoạn 2 | Quy tắc code cho stack đã chọn |
| `AGENTS.md` | Giai đoạn 0, trên Codex, OpenCode, Antigravity | Đoạn ngắn trỏ tới `CLAUDE.md`; `AGENTS.md` đã có thì không bị ghi đè |

## Nâng cấp

Cài lại bằng `./install.sh --agent … --force` hoặc chạy lại
`npx skills add vuquoctrungbk/specflow …`. Bản specflow mới có thể mang quy tắc
mới hơn thư mục `specflow/` của dự án; specflow sẽ báo và để bạn quyết, vì đổi
quy tắc giữa một đợt có thể ảnh hưởng tài liệu đang chờ duyệt. Xem
`CHANGELOG.md`.

## Cấu trúc repo

```text
skills/specflow/
  SKILL.md                 cách skill làm việc
  references/              định tuyến, cách hỏi, cài đặt vào dự án
  assets/kit/              quy tắc và template (VERSION ghi phiên bản quy tắc)
adapters/opencode/commands/specflow.md   lệnh /specflow cho OpenCode
.claude-plugin/            manifest plugin và marketplace của Claude Code
install.sh                 script cài cho macOS và Linux
install.ps1                script cài cho Windows
```

## Xử lý sự cố

- **Không thấy `/specflow`.** Mở phiên mới; kiểm tra thư mục nằm ngay dưới thư
  mục skills (`…/skills/specflow/SKILL.md`). Trên Codex dùng `$specflow`. Trên
  OpenCode cài file lệnh.
- **Agent viết code hoặc bỏ qua gate.** Nhắc lại quy tắc gate: code chờ plan đã
  duyệt, mỗi giai đoạn chờ `Duyệt Gate N`. Quy tắc nằm ở `specflow/PLAYBOOK.md`
  mục 1.2 và 7.
- **Câu hỏi hiện dạng chữ thay vì nút chọn.** Agent không có công cụ hỏi ở chế
  độ hiện tại; trả lời theo dạng `1a, 2b`.
- **Windows: agent chạy lệnh bằng PowerShell.** Codex trên Windows và một số
  agent khác chạy lệnh trong PowerShell thay vì shell POSIX. specflow chạy các
  lệnh kiểm của bộ kit bằng lệnh PowerShell tương đương nên không cần cấu hình
  gì; cài Git for Windows để agent nào ưu tiên Git Bash dùng được nó.
- **Windows: `install.sh` báo `$'\r': command not found`.** Dùng `install.ps1`,
  hoặc chạy `install.sh` từ một bản clone mới trong Git Bash (repo giữ script
  shell ở dạng xuống dòng LF).

## Giấy phép

MIT, áp cho cả bộ kit trong `skills/specflow/assets/kit/`.
Xem [LICENSE](LICENSE).
