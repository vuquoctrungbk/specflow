---
doc_type: profile
status: stable
version: 1.0.0
language: vi-en
surface: ai-llm-app
profile: typescript-anthropic-sdk
---

# Stack profile typescript-anthropic-sdk

## 1. Phạm vi (Scope)

Tính năng AI viết bằng TypeScript chạy trên Node.js dạng ES module, gọi mô hình Claude qua Anthropic TypeScript SDK với đầu ra có cấu trúc sinh từ schema Zod (`messages.create` với `output_config.format` từ `zodOutputFormat`, rồi kiểm lại bằng schema), test bằng Vitest, lint bằng oxlint. Profile dùng cho worker hoặc module phía server. Khi tính năng AI nằm trong một backend đã có profile riêng (ví dụ `node-nestjs-prisma`), làm theo mục "Ghép với backend-api" ở `overlays/ai-llm-app/OVERLAY.md`: dùng cây thư mục, cấu hình công cụ và lệnh verify của backend, profile này chỉ thêm SDK, client mô hình, project test đánh giá và lệnh đánh giá.

Phiên bản chốt ngày 2026-09-22 và đã chạy thử cùng nhau trên Node.js 24.21.0 với một dự án thử: typecheck, lint type-aware, unit test, integration test với nhà cung cấp giả lập ở tầng `fetch` (đầu ra hợp lệ, sai schema, bị cắt ở `max_tokens`, độ tin cậy thấp, lỗi cấu hình, quá tải và lỗi mạng có thử lại, hạn chót của lời gọi), test `CONC` hai worker, build và `npm audit` đều đạt. Hành vi của SDK 0.127.0 mà client dựa vào đã đối chiếu với mã nguồn của SDK: SDK tự thử lại `408`, `409`, `429`, `5xx` và lỗi mạng, tuân theo `retry-after` không giới hạn, và chỉ gửi hình dạng của schema cho nhà cung cấp, còn miền liệt kê, khoảng số, độ dài đi dưới dạng mô tả. Test đánh giá với mô hình thật chưa chạy trong môi trường soạn profile vì không có khóa API; lệnh đánh giá đã được kiểm tra là tự bỏ qua khi thiếu khóa và báo lỗi khi `EVAL_REQUIRED=1`. Nâng phiên bản theo Dependency Policy ở ARCHITECTURE §2.2.

## 2. Bảng công nghệ (Tech Stack)

Chép vào ARCHITECTURE §2.1 với cột Bề mặt là `ai-llm-app` và cột ADR là "Mặc định của profile" (chỉ lệch profile mới cần ADR). ID mô hình không thuộc profile: chọn theo nhiệm vụ, ghi thành một hàng riêng của §2.1 kèm ADR.

| Lớp (Layer) | Công nghệ | Phiên bản chính xác | Vai trò | ADR |
| --- | --- | --- | --- | --- |
| Runtime | Node.js | 24.21.0 (LTS) | Chạy worker và công cụ | Mặc định của profile |
| Ngôn ngữ | TypeScript | 6.0.3 | Kiểu nghiêm ngặt, `module: nodenext`; cùng dòng với profile backend | Mặc định của profile |
| SDK mô hình | `@anthropic-ai/sdk` | 0.127.0 | Messages API, đầu ra có cấu trúc, thử lại và thời gian chờ có sẵn | Mặc định của profile |
| Validation | `zod` | 4.6.5 | Schema đầu ra (nguồn của định dạng đầu ra có cấu trúc), biến môi trường, dữ liệu từ hệ thống ngoài | Mặc định của profile |
| Kiểu | `@types/node` | 24.13.6 | Kiểu cho Node.js 24 | Mặc định của profile |
| Test | `vitest`, `@vitest/coverage-v8` | 4.1.11 | Unit, integration, đánh giá, coverage; cùng dòng với profile backend | Mặc định của profile |
| Lint | `oxlint`, `oxlint-tsgolint` | 1.85.0, 7.0.2002 | Lint, rule cần thông tin kiểu (`--type-aware`) | Mặc định của profile |

## 3. Giá trị placeholder

| Placeholder | Giá trị |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | TypeScript bật `strict` và `noUncheckedIndexedAccess`; cấm kiểu `any` (oxlint `typescript/no-explicit-any` mức error). |
| `{{CODEGEN_CMD}}` | `N/A: profile không có client sinh mã; kiểu của SDK có sẵn, schema đầu ra viết bằng Zod` |
| `{{LINT_CMD}}` | `npx oxlint --type-aware --deny-warnings src/ test/` |
| `{{TYPECHECK_CMD}}` | `npx tsc --noEmit` |
| `{{UNIT_TEST_CMD}}` | `npx vitest run --project unit` |
| `{{INTEGRATION_TEST_CMD}}` | `npx vitest run --project integration` |
| `{{E2E_TEST_CMD}}` | `N/A: tác vụ AI chạy trong worker hoặc module phía server, không có giao diện; hành vi đầu cuối phủ bằng integration test và test đánh giá` |
| `{{EVAL_CMD}}` | `EVAL_REQUIRED=1 npx vitest run --project eval` |
| `{{COVERAGE_CMD}}` | `npx vitest run --project unit --project integration --coverage` |
| `{{BUILD_CMD}}` | `npx tsc -p tsconfig.build.json` |
| `{{AUDIT_CMD}}` | `npm audit --audit-level=high` |

Ghi chú:

- `{{EVAL_CMD}}` gọi mô hình thật, cần `ANTHROPIC_API_KEY` (khóa của môi trường đánh giá, có hạn mức chi tiêu riêng) và tốn tiền theo số mẫu nhân số lần chạy; lệnh chỉ chạy trong job đánh giá của CI. `EVAL_REQUIRED=1` làm lệnh báo lỗi khi thiếu khóa; chạy lệnh này trong job đánh giá của CI khi đổi prompt, mô hình hoặc tham số, và theo lịch. Chạy `npx vitest run --project eval` không có khóa thì bộ test tự bỏ qua, dùng được trên máy lập trình viên.
- Ngưỡng coverage mặc định của profile là 80% dòng và nhánh cho `src/`, trừ `src/main.ts` và `src/config/`; SRS có thể đặt ngưỡng khác ở NFR-MAINT.
- Khi dự án thêm client sinh từ OpenAPI (hệ thống ngoài có tài liệu OpenAPI), đặt `{{CODEGEN_CMD}}` theo profile backend hoặc frontend tương ứng.

## 4. Nội dung chèn vào tài liệu (Profile Content)

### 4.1. Cây thư mục và cấu hình công cụ (cho ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Cây thư mục theo stack (Stack Directory Tree)

```text
.
├── evals/                               # bộ dữ liệu đánh giá và tấn công, JSON Lines, mỗi dòng một mẫu
├── src/
│   ├── main.ts                          # điểm vào: đọc cấu hình, khởi động worker hoặc server
│   ├── config/env.ts                    # nơi duy nhất đọc biến môi trường, validate bằng Zod
│   ├── llm/model-client.ts              # module duy nhất gọi Anthropic SDK
│   ├── prompts/{{FEATURE_SLUG}}.ts       # một module cho mỗi prompt, hằng version trùng Prompt Spec
│   ├── {{MODULE_SLUG}}/
│   │   ├── {{MODULE_SLUG}}.schema.ts    # schema Zod của đầu ra
│   │   ├── guards.ts                    # guard đầu vào và đầu ra, hàm thuần
│   │   └── index.ts                     # logic nghiệp vụ dùng kết quả đã kiểm tra
│   └── lib/
├── test/
│   ├── unit/                            # *.test.ts
│   ├── integration/                     # *.int.test.ts, nhà cung cấp giả lập ở tầng fetch
│   ├── eval/                            # *.eval.test.ts, gọi mô hình thật
│   └── support/                         # giả lập nhà cung cấp và hệ thống ngoài
├── .oxlintrc.json
├── tsconfig.json                        # typecheck cả src và test, noEmit
├── tsconfig.build.json                  # build src ra dist
├── vitest.config.ts
└── .env.example                         # chỉ tên biến và giá trị giả
```

<!-- fill: Lặp nhánh src/{{MODULE_SLUG}} cho mỗi phân hệ ở §4.1 và file prompts/{{FEATURE_SLUG}}.ts cho mỗi Prompt Spec; bỏ thư mục mà dự án không có. -->

File Diff mặc định khi SPEC thêm một tác vụ AI: module prompt trong `src/prompts/`, schema và guard trong thư mục phân hệ, test trong `test/unit/`, `test/integration/`, `test/eval/`, bộ dữ liệu trong `evals/`, Prompt Spec trong `docs/prompts/`.

Cấu hình test (`vitest.config.ts`): ba project; project `eval` có thời gian chờ dài vì gọi mô hình thật.

```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    coverage: { provider: "v8", include: ["src/**/*.ts"], exclude: ["src/main.ts", "src/config/**"], thresholds: { lines: 80, branches: 80 } },
    projects: [
      { extends: true, test: { name: "unit", include: ["test/unit/**/*.test.ts"] } },
      { extends: true, test: { name: "integration", include: ["test/integration/**/*.int.test.ts"] } },
      { extends: true, test: { name: "eval", include: ["test/eval/**/*.eval.test.ts"], testTimeout: 600_000 } },
    ],
  },
});
```

Cấu hình lint (`.oxlintrc.json`):

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["typescript", "unicorn", "oxc", "import", "vitest"],
  "categories": { "correctness": "error", "suspicious": "warn" },
  "rules": { "typescript/no-explicit-any": "error" },
  "ignorePatterns": ["dist/**"]
}
```

`tsconfig.json`: `target` `ES2023`, `module` và `moduleResolution` `nodenext`, `strict`, `noUncheckedIndexedAccess`, `types: ["node"]`, `noEmit`, `include` gồm `src`, `test`, `vitest.config.ts`; import tương đối ghi đuôi `.js`. `tsconfig.build.json` kế thừa, bật emit, `rootDir: "src"`, `outDir: "dist"`, chỉ `include` `src`.
<!-- /PROFILE-CONTENT -->

### 4.2. Schema đầu ra và client mô hình (cho ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Schema và client mô hình theo stack (Stack Schemas & Model Client)

- Schema đầu ra viết bằng Zod; `zodOutputFormat(schema)` của `@anthropic-ai/sdk/helpers/zod` chuyển nó thành định dạng đầu ra có cấu trúc gửi kèm `messages.create`. Client tự đọc câu trả lời: `stop_reason` khác `end_turn` (bị cắt ở `max_tokens`, từ chối), văn bản không phải JSON hoặc không qua `schema.safeParse` đều là `OUTPUT_INVALID`, và token của lời gọi vẫn được trả về. Không dùng `messages.parse`: hàm này ném lỗi khi đầu ra sai schema và làm mất `usage` của một lời gọi đã tính tiền.
- Client mô hình là module duy nhất tạo `Anthropic`: `temperature` 0; `timeout` mỗi lần gọi, `maxRetries` và một hạn chót cho cả lời gọi (`AbortSignal.timeout`), vì SDK tuân theo `retry-after` của nhà cung cấp; `authToken`, `baseURL`, `logLevel` truyền tường minh để SDK không tự đọc các biến `ANTHROPIC_*` tương ứng (mức log `debug` in cả nội dung request). SDK vẫn đọc `ANTHROPIC_CUSTOM_HEADERS` và thêm các header này sau header xác thực, nên `src/config/env.ts` từ chối khởi động khi biến này được đặt, kể cả rỗng. Trong schema Zod 4, khóa đó là `z.undefined({ error: "ANTHROPIC_CUSTOM_HEADERS must not be set" }).optional()`: thiếu `.optional()` thì Zod đòi khóa phải có mặt, và worker không khởi động được ở mọi môi trường không đặt biến. Lỗi `400`, `401`, `402`, `403`, `404`, `413` là lỗi cấu hình (ném ra); lỗi còn lại sau khi thử lại, kể cả hết hạn chót, là `MODEL_UNAVAILABLE`.
- Client nhận `fetch` qua tham số để integration test thay bằng nhà cung cấp giả lập.

```typescript
import Anthropic, { AnthropicError, APIError } from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import type { z } from "zod";

// Request, key, billing, model ID and size errors are bugs or configuration, not a reason to fall back.
const CONFIGURATION_ERRORS = new Set([400, 401, 402, 403, 404, 413]);

export interface ModelCallOptions<S extends z.ZodType> {
  model: string;
  system: string;
  user: string;
  schema: S;
  maxTokens: number;
}

export type ModelCallResult<T> =
  | { ok: true; value: T; inputTokens: number; outputTokens: number }
  | { ok: false; code: "OUTPUT_INVALID" | "MODEL_UNAVAILABLE"; inputTokens: number; outputTokens: number };

// The only code that talks to the model provider: structured output, temperature 0, and a deadline for the whole
// call. The SDK retries overload, rate limit, 408, 409, 5xx and network errors and honours retry-after, so the
// per-attempt timeout alone does not bound the time of a call.
export function createModelClient(options: { apiKey: string; fetch?: typeof fetch; timeoutMs?: number; maxRetries?: number; deadlineMs?: number }) {
  const client = new Anthropic({
    apiKey: options.apiKey,
    // Explicit values, so the SDK reads no ANTHROPIC_* variable itself (another base URL, another credential,
    // debug logging that prints request bodies).
    authToken: null,
    baseURL: "https://api.anthropic.com",
    logLevel: "off",
    fetch: options.fetch,
    timeout: options.timeoutMs ?? 20_000,
    maxRetries: options.maxRetries ?? 2,
  });
  const deadlineMs = options.deadlineMs ?? 60_000;
  return {
    async call<S extends z.ZodType>(request: ModelCallOptions<S>): Promise<ModelCallResult<z.infer<S>>> {
      let message;
      try {
        message = await client.messages.create(
          {
            model: request.model,
            max_tokens: request.maxTokens,
            temperature: 0,
            system: request.system,
            messages: [{ role: "user", content: request.user }],
            output_config: { format: zodOutputFormat(request.schema) },
          },
          { signal: AbortSignal.timeout(deadlineMs) },
        );
      } catch (error) {
        if (error instanceof APIError && error.status !== undefined && CONFIGURATION_ERRORS.has(error.status)) throw error;
        // Overload, rate limit, server and network errors after the SDK's retries, or the deadline.
        if (error instanceof AnthropicError) return { ok: false, code: "MODEL_UNAVAILABLE", inputTokens: 0, outputTokens: 0 };
        throw error;
      }
      // Usage is billed even when the answer cannot be used, so every path returns it.
      const usage = { inputTokens: message.usage.input_tokens, outputTokens: message.usage.output_tokens };
      const invalid = { ok: false, code: "OUTPUT_INVALID", ...usage } as const;
      const text = message.stop_reason === "end_turn" ? message.content.find((block) => block.type === "text") : undefined;
      if (text?.type !== "text") return invalid;
      let json: unknown;
      try {
        json = JSON.parse(text.text);
      } catch {
        return invalid;
      }
      // The provider holds the answer to the schema's shape; value limits (enum members, ranges, lengths) are
      // checked here, because the structured output format carries them only as descriptions.
      const parsed = request.schema.safeParse(json);
      return parsed.success ? { ok: true, value: parsed.data, ...usage } : invalid;
    },
  };
}

export type ModelClient = ReturnType<typeof createModelClient>;
```
<!-- /PROFILE-CONTENT -->

### 4.3. Quy ước của stack (cho ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Hiện thực quy ước theo stack (Stack Implementation Notes)

- Mỗi prompt là một module xuất một hằng `as const` gồm `version` (trùng `version` của Prompt Spec), chuỗi prompt hệ thống và hàm ghép tin nhắn người dùng; nội dung không tin cậy chỉ đi vào hàm ghép, nằm giữa cặp thẻ phân cách.
- Thời gian chờ mặc định 20 giây mỗi lần gọi, 2 lần thử lại và hạn chót 60 giây cho cả lời gọi với tác vụ nền; tác vụ người dùng đang chờ đặt các giá trị này theo NFR-PERF. Lỗi `400`, `401`, `402`, `403`, `404`, `413` là lỗi cấu hình hoặc lỗi lập trình, không chuyển phương án dự phòng.
- `message.usage.input_tokens` và `output_tokens` của mỗi lời gọi có phản hồi, kể cả khi đầu ra không dùng được, đi vào nhật ký và vào kết quả trả về, để test `COST` và giám sát chi phí đọc được.
- Khóa API chỉ đọc trong `src/config/env.ts` và truyền vào client; không đưa khóa hay nội dung prompt đầy đủ vào log.
- Biến trong Prompt Spec viết dạng hai ngoặc nhọn bao tên chữ thường; trong mã, chúng là tham số của hàm ghép tin nhắn.
<!-- /PROFILE-CONTENT -->

### 4.4. Khuôn schema đầu ra (cho SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Schema đầu ra với Zod (Zod Output Schema)

Schema khớp Prompt Spec §5; miền giá trị liệt kê đầy đủ, chuỗi có độ dài tối đa. Kiểu suy ra bằng `z.infer`.

<!-- fill: Thay khối mẫu dưới đây bằng schema đầu ra thật của tác vụ. -->

```typescript
import { z } from "zod";

export const ClassificationOutputSchema = z.strictObject({
  label: z.enum(["category_a", "category_b", "other"]),
  confidence: z.number().min(0).max(1),
  reason: z.string().max(300),
});
export type ClassificationOutput = z.infer<typeof ClassificationOutputSchema>;
```
<!-- /PROFILE-CONTENT -->

### 4.5. Công cụ test (cho SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Công cụ và vị trí test theo stack (Stack Test Tooling)

| TYPE | Công cụ | File | Chạy bằng |
| --- | --- | --- | --- |
| `UNIT` | Vitest | `test/unit/*.test.ts` | Project Vitest `unit` |
| `INT` | Vitest, client mô hình với `fetch` giả lập trả phản hồi của Messages API | `test/integration/*.int.test.ts` | Project Vitest `integration` |
| `EVAL` | Vitest, mô hình thật, đọc bộ dữ liệu JSON Lines trong `evals/` | `test/eval/*.eval.test.ts` | Project Vitest `eval` |
| `INJ` | Như `EVAL`, bộ dữ liệu tấn công | `test/eval/*.eval.test.ts` | Project Vitest `eval` |
| `COST` | Như `EVAL`, cộng `usage` của mỗi lời gọi | `test/eval/*.eval.test.ts` | Project Vitest `eval` |
| `CONC` | Như `INT`, giả lập hệ thống đích có ghi có điều kiện | `test/integration/*.int.test.ts` | Project Vitest `integration` |

Nhà cung cấp giả lập ở tầng `fetch` (`test/support/fake-anthropic.ts`): mỗi lời gọi trả phản hồi kế tiếp trong danh sách (kể cả lỗi mạng và header `retry-after`), ghi lại body của request để test kiểm tra dữ liệu đã che và tham số, và trả lỗi `400` không thử lại khi hết phản hồi đã soạn, để test hết câu trả lời thì thất bại rõ ràng.

```typescript
// Fake Messages API at the fetch layer: each call returns the next scripted answer, and running out of answers
// fails loudly instead of looking like a network error.
type Answer = { status: number; body: unknown; headers?: Record<string, string> } | { network: true };

export function fakeAnthropicFetch(answers: Answer[]) {
  const calls: { body: unknown }[] = [];
  const fetchImpl: typeof fetch = async (input, init) => {
    const request = new Request(input, init);
    calls.push({ body: await request.json() });
    const answer = answers.shift();
    // A request error that the client throws and the SDK does not retry, so a test that runs out of answers fails.
    if (!answer) {
      const message = `fake provider: no scripted answer for call ${calls.length}`;
      return new Response(JSON.stringify({ type: "error", error: { type: "invalid_request_error", message } }), {
        status: 400,
        headers: { "content-type": "application/json", "x-should-retry": "false" },
      });
    }
    if ("network" in answer) throw new TypeError("fetch failed");
    return new Response(JSON.stringify(answer.body), {
      status: answer.status,
      headers: { "content-type": "application/json", ...answer.headers },
    });
  };
  return { fetchImpl, calls };
}

export const messageWithText = (text: string, stopReason = "end_turn") => ({
  status: 200,
  body: {
    id: "msg_test",
    type: "message",
    role: "assistant",
    model: "claude-haiku-4-5-20251001",
    content: [{ type: "text", text }],
    stop_reason: stopReason,
    stop_sequence: null,
    usage: { input_tokens: 120, output_tokens: 30 },
  },
});

export const overloaded = (retryAfterSeconds?: number) => ({
  status: 529,
  body: { type: "error", error: { type: "overloaded_error", message: "Overloaded" } },
  headers: retryAfterSeconds === undefined ? undefined : { "retry-after": String(retryAfterSeconds) },
});
```

Test đánh giá mở đầu bằng `describe.skipIf(!apiKey)`, và báo lỗi khi `EVAL_REQUIRED=1` mà thiếu khóa; mỗi mẫu đọc qua schema Zod của bộ dữ liệu. Test import `describe`, `it`, `expect` từ `vitest`. Tên test mô tả hành vi bằng tiếng Anh, ví dụ `it("sends the ticket to review when the answer is not valid structured output", ...)`; không chứa TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Quy ước riêng của stack (Stack Conventions)

- `package.json` có `"type": "module"`; import tương đối ghi đuôi `.js`.
- Đầu ra có cấu trúc dùng `messages.create` với `output_config.format` từ `zodOutputFormat`, rồi client tự kiểm `stop_reason` và schema (mục 4.2); không dùng `messages.parse` và không dùng tool use để ép JSON khi không cần công cụ thật.
- Bộ dữ liệu đánh giá không nằm trong `src/` và không được import vào mã chạy production.
- Ghim ID mô hình dạng có ngày (ví dụ `claude-haiku-4-5-20251001`) khi nhà cung cấp có, để kết quả đánh giá gắn với đúng một phiên bản mô hình.

## 6. Khởi tạo dự án (Project Setup)

1. `npm init -y`, đặt `"type": "module"` trong `package.json`.
2. `npm install --save-exact @anthropic-ai/sdk@0.127.0 zod@4.6.5` và `npm install --save-exact --save-dev typescript@6.0.3 @types/node@24.13.6 vitest@4.1.11 @vitest/coverage-v8@4.1.11 oxlint@1.85.0 oxlint-tsgolint@7.0.2002`.
3. Tạo `tsconfig.json`, `tsconfig.build.json`, `vitest.config.ts`, `.oxlintrc.json` theo mục 4.1; tạo `src/config/env.ts`, `src/llm/model-client.ts` theo mục 4.2 và `test/support/fake-anthropic.ts` theo mục 4.5.
4. Thêm `dist/`, `coverage/` và file env thật vào `.gitignore`; `.env.example` chỉ có tên biến và giá trị giả.
5. Tạo khóa API riêng cho môi trường đánh giá với hạn mức chi tiêu, lưu vào kho secret của CI dưới tên `ANTHROPIC_API_KEY`.
