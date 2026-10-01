---
doc_type: profile
status: stable
version: 1.1.0
language: vi-en
surface: frontend-web
profile: nextjs-app-router
---

# Stack profile nextjs-app-router

## 1. Phạm vi (Scope)

Giao diện web viết bằng TypeScript trên Next.js App Router và React, giao diện dựng bằng Tailwind CSS và shadcn/ui, dữ liệu từ server qua TanStack Query, form bằng React Hook Form với Zod, chuỗi hiển thị bằng next-intl, kiểu API sinh từ OpenAPI. Profile khớp dự án do `create-next-app` 16.3.5 sinh ra (App Router, `src/`, Tailwind, ESLint) cộng `shadcn init` và các thư viện ở mục 2. Phiên bản chốt ngày 2026-09-22 và đã chạy thử cùng nhau trên Node.js 24.21.0: sinh kiểu, typecheck, lint, unit test, integration test với API giả lập, build, e2e kèm quét trợ năng và visual regression đều đạt trên dự án thử; nâng phiên bản theo Dependency Policy ở ARCHITECTURE §2.2.

## 2. Bảng công nghệ (Tech Stack)

Chép vào ARCHITECTURE §2.1 với cột Bề mặt là `frontend-web` và cột ADR là "Mặc định của profile" (chỉ lệch profile mới cần ADR).

| Lớp (Layer) | Công nghệ | Phiên bản chính xác | Vai trò | ADR |
| --- | --- | --- | --- | --- |
| Runtime | Node.js | 24.21.0 (LTS) | Build, chạy server render và công cụ; `jsdom` 30 cần Node.js 22.22.2 hoặc 24.15.0 trở lên | Mặc định của profile |
| Ngôn ngữ | TypeScript | 5.9.3 | Kiểu nghiêm ngặt; dòng 5 theo scaffold và yêu cầu `^5` của `openapi-typescript` | Mặc định của profile |
| Framework | `next` | 16.3.5 | App Router, server component, build | Mặc định của profile |
| Framework | `react`, `react-dom` | 19.2.8 | Thư viện giao diện, đúng phiên bản scaffold ghim | Mặc định của profile |
| Kiểu | `@types/react`, `@types/react-dom` | 19.3.0 | Kiểu cho React | Mặc định của profile |
| Kiểu | `@types/node` | 24.13.6 | Kiểu cho Node.js 24 | Mặc định của profile |
| Giao diện | `tailwindcss`, `@tailwindcss/postcss` | 4.3.3 | CSS theo utility và design token | Mặc định của profile |
| Giao diện | `shadcn` | 4.21.0 | CLI thêm thành phần và file CSS nền `shadcn/tailwind.css` | Mặc định của profile |
| Giao diện | `@base-ui/react` | 1.8.0 | Thành phần nền không định kiểu cho shadcn/ui (style `base-nova`) | Mặc định của profile |
| Giao diện | `class-variance-authority` | 0.7.1 | Biến thể của thành phần | Mặc định của profile |
| Giao diện | `cn` | 0.3.2 | Ghép class Tailwind | Mặc định của profile |
| Giao diện | `lucide-react` | 1.47.0 | Biểu tượng | Mặc định của profile |
| Giao diện | `tw-animate-css` | 1.4.0 | Hiệu ứng chuyển động cho Tailwind | Mặc định của profile |
| Dữ liệu từ server | `@tanstack/react-query` | 5.103.2 | Cache truy vấn, mutation, trạng thái tải và lỗi | Mặc định của profile |
| Form | `react-hook-form` | 7.88.0 | Trạng thái form | Mặc định của profile |
| Form | `@hookform/resolvers` | 5.9.1 | Nối React Hook Form với Zod | Mặc định của profile |
| Validation | `zod` | 4.6.5 | Schema form và biến môi trường | Mặc định của profile |
| Quốc tế hóa | `next-intl` | 4.14.6 | Chuỗi hiển thị theo locale, định dạng số và thời gian | Mặc định của profile |
| Client API | `openapi-fetch` | 0.17.0 | Client HTTP có kiểu theo OpenAPI | Mặc định của profile |
| Sinh mã | `openapi-typescript` | 7.13.0 | Sinh kiểu TypeScript từ tài liệu OpenAPI | Mặc định của profile |
| Lint | `eslint`, `eslint-config-next` | 9.39.5, 16.3.5 | Lint theo cấu hình scaffold (Core Web Vitals, TypeScript); giữ ESLint 9 dù npm báo dòng này hết hỗ trợ, vì plugin React, import và jsx-a11y mà `eslint-config-next` 16.3 dùng chỉ nhận ESLint 9 | Mặc định của profile |
| Test | `vitest`, `@vitest/coverage-v8` | 4.1.11 | Unit và integration test, coverage | Mặc định của profile |
| Test | `@vitejs/plugin-react` | 5.2.0 | JSX cho Vitest; bản 6 kéo peer dependency Babel 8 bản RC nên không cài được cùng Vitest 4.1 | Mặc định của profile |
| Test | `jsdom` | 30.1.1 | DOM cho test thành phần | Mặc định của profile |
| Test | `@testing-library/react`, `@testing-library/dom`, `@testing-library/user-event`, `@testing-library/jest-dom` | 16.3.3, 10.4.2, 14.6.7, 7.0.1 | Render, truy vấn theo vai trò, thao tác người dùng, matcher DOM | Mặc định của profile |
| Test | `msw` | 2.15.0 | API giả lập ở tầng mạng cho integration test | Mặc định của profile |
| Test | `@playwright/test` | 1.63.0 | E2E, visual regression trên Chromium | Mặc định của profile |
| Test | `@axe-core/playwright` | 4.13.0 | Quét trợ năng trong test e2e | Mặc định của profile |

## 3. Giá trị placeholder

| Placeholder | Giá trị |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | TypeScript bật `strict` và `noUncheckedIndexedAccess`; cấm kiểu `any` (ESLint `@typescript-eslint/no-explicit-any` mức error, có sẵn trong `eslint-config-next/typescript`). |
| `{{RENDER_BOUNDARY_RULE}}` | Thành phần mặc định là server component; chỉ thêm `"use client"` cho thành phần cần state, effect hoặc sự kiện trình duyệt, đặt ranh giới client càng sâu càng tốt; dữ liệu đọc ban đầu lấy ở server component, MUST NOT tải dữ liệu trong `useEffect`. |
| `{{CODEGEN_CMD}}` | `npx openapi-typescript openapi/api.yaml -o src/lib/api/schema.d.ts` |
| `{{LINT_CMD}}` | `npx eslint --max-warnings=0` |
| `{{TYPECHECK_CMD}}` | `npx tsc --noEmit -p tsconfig.json` |
| `{{UNIT_TEST_CMD}}` | `npx vitest run --project unit` |
| `{{INTEGRATION_TEST_CMD}}` | `npx vitest run --project integration` |
| `{{E2E_TEST_CMD}}` | `npx playwright test` |
| `{{COVERAGE_CMD}}` | `npx vitest run --coverage` |
| `{{BUILD_CMD}}` | `npx next build` |
| `{{AUDIT_CMD}}` | `npm audit --audit-level=high` |

Ghi chú:

- Kiểu sinh ở `src/lib/api/schema.d.ts` không được commit, nên `{{CODEGEN_CMD}}` chạy đầu tiên trên máy mới, trong CI, trong bước build image và sau mỗi lần cập nhật `openapi/api.yaml`.
- `{{BUILD_CMD}}` cần `NEXT_PUBLIC_API_BASE_URL` vì biến công khai được nhúng lúc build và `src/config/env.ts` báo lỗi khi thiếu: máy lập trình viên đặt trong `.env.local`, CI và bước build image truyền giá trị của môi trường đích.
- `{{E2E_TEST_CMD}}` tự build rồi chạy ứng dụng ở cổng 3100 (cấu hình `webServer` ở mục 4.1). Máy chạy test cần trình duyệt của Playwright: `npx playwright install --with-deps chromium`.
- Ảnh gốc visual regression phụ thuộc font và hệ điều hành: chỉ tạo và cập nhật ảnh gốc (`npx playwright test --update-snapshots`) trên cùng image với CI, rồi commit.
- Ngưỡng coverage mặc định của profile là 80% cho `src/features/**`; SRS có thể đặt ngưỡng khác ở NFR-MAINT.

## 4. Nội dung chèn vào tài liệu (Profile Content)

### 4.1. Cây thư mục và cấu hình công cụ (cho ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Cây thư mục theo stack (Stack Directory Tree)

```text
.
├── openapi/api.yaml                     # bản sao tài liệu OpenAPI của API, nguồn sinh kiểu
├── messages/vi.json                     # chuỗi hiển thị theo locale
├── public/
├── src/
│   ├── app/                             # route của App Router
│   │   ├── layout.tsx                   # layout gốc: provider chuỗi hiển thị, provider truy vấn
│   │   ├── globals.css                  # Tailwind; biến token ánh xạ từ docs/design-system/tokens.json
│   │   └── {{ROUTE_PATH}}/
│   │       ├── page.tsx                 # server component, ghép thành phần của tính năng
│   │       ├── loading.tsx              # trạng thái Loading của route
│   │       └── error.tsx                # ranh giới lỗi, trạng thái Error của route
│   ├── features/
│   │   └── {{MODULE_SLUG}}/
│   │       ├── components/              # thành phần của tính năng
│   │       ├── hooks/                   # hook truy vấn và mutation qua TanStack Query
│   │       ├── {{MODULE_SLUG}}.schema.ts # schema Zod của form
│   │       ├── index.ts                 # xuất công khai của tính năng
│   │       └── tests/                   # *.test.tsx (unit), *.int.test.tsx (integration)
│   ├── components/ui/                   # thành phần shadcn/ui, không chứa nghiệp vụ
│   ├── config/env.ts                    # nơi duy nhất đọc biến môi trường, validate bằng Zod
│   ├── i18n/request.ts                  # cấu hình next-intl
│   └── lib/
│       ├── api/client.ts                # client openapi-fetch dùng chung
│       ├── api/schema.d.ts              # kiểu sinh bởi openapi-typescript, không sửa, không commit
│       ├── query-provider.tsx           # QueryClientProvider (client component)
│       └── utils.ts
├── test/
│   ├── setup/vitest.setup.ts            # jest-dom, server MSW, dọn DOM sau mỗi test
│   ├── msw/server.ts                    # server MSW dùng chung
│   └── e2e/                             # test Playwright *.spec.ts và ảnh gốc visual
├── AGENTS.md                            # khối hướng dẫn của Next.js; giữ nguyên, next dev tự cập nhật
├── components.json                      # cấu hình shadcn/ui
├── eslint.config.mjs                    # cấu hình của scaffold
├── next.config.ts
├── playwright.config.ts
├── vitest.config.mts
├── tsconfig.json
└── .env.example                         # chỉ tên biến và giá trị giả
```

<!-- fill: Lặp nhánh app/{{ROUTE_PATH}} cho mỗi route ở SRS §3 và nhánh features/{{MODULE_SLUG}} cho mỗi phân hệ ở §4.1; bỏ thư mục mà tính năng không có. -->

File Diff mặc định khi SPEC tạo màn hình mới: route trong `src/app/`, nhánh tính năng trong `src/features/`, khóa chuỗi mới trong `messages/`, test trong `tests/` của tính năng và `test/e2e/`.

Cấu hình test đơn vị và tích hợp: một `vitest.config.mts` với hai project; Vite 8 tự phân giải alias của `tsconfig.json` nên không cần plugin riêng.

```typescript
import react from "@vitejs/plugin-react";
import { configDefaults, defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  resolve: { tsconfigPaths: true },
  test: {
    environment: "jsdom",
    env: { NEXT_PUBLIC_API_BASE_URL: "http://localhost:3000" },
    setupFiles: ["test/setup/vitest.setup.ts"],
    coverage: { provider: "v8", include: ["src/features/**/*.{ts,tsx}"], thresholds: { lines: 80, branches: 80 } },
    projects: [
      {
        extends: true,
        test: { name: "unit", include: ["src/**/*.test.{ts,tsx}"], exclude: [...configDefaults.exclude, "src/**/*.int.test.{ts,tsx}"] },
      },
      { extends: true, test: { name: "integration", include: ["src/**/*.int.test.{ts,tsx}"] } },
    ],
  },
});
```

```typescript
import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterAll, afterEach, beforeAll } from "vitest";
import { server } from "../msw/server";

beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
afterEach(() => {
  server.resetHandlers();
  cleanup();
});
afterAll(() => server.close());
```

Cấu hình e2e (`playwright.config.ts`):

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "test/e2e",
  fullyParallel: true,
  use: { baseURL: "http://localhost:3100", trace: "on-first-retry" },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "npx next build && npx next start -p 3100",
    url: "http://localhost:3100",
    env: { NEXT_PUBLIC_API_BASE_URL: process.env["NEXT_PUBLIC_API_BASE_URL"] ?? "http://localhost:3000" },
    reuseExistingServer: !process.env["CI"],
    timeout: 300_000,
  },
});
```

Cấu hình lint: giữ `eslint.config.mjs` của scaffold, thêm vào `globalIgnores` các file và thư mục do công cụ sinh ra: `"src/lib/api/schema.d.ts"`, `"coverage/**"`, `"playwright-report/**"`, `"test-results/**"`.
<!-- /PROFILE-CONTENT -->

### 4.2. Kiểu API và client (cho ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Sinh kiểu và client API theo stack (Stack API Types & Client)

- `{{CODEGEN_CMD}}` sinh `src/lib/api/schema.d.ts` từ `openapi/api.yaml`; tài liệu nguồn cần khối `info` và schema cho mọi response mà giao diện đọc.
- Client dùng chung tạo bằng `openapi-fetch` và lấy `fetch` lúc gọi, để API giả lập của test (MSW) và các lớp bọc `fetch` khác chặn được request. Header xác thực gắn bằng middleware `apiClient.use(...)` theo cơ chế phiên ở ARCHITECTURE §6.1.
- Khóa cache truy vấn là mảng gồm tên phân hệ, tên tài nguyên và tham số, ví dụ `["{{MODULE_SLUG}}", "list", { cursor }]`; mutation ghi tắt thử lại tự động.
- Schema form đặt ở `src/features/{{MODULE_SLUG}}/{{MODULE_SLUG}}.schema.ts`, nối vào form bằng `zodResolver`.

```typescript
import createClient from "openapi-fetch";
import { env } from "@/config/env";
import type { paths } from "./schema";

export const apiClient = createClient<paths>({
  baseUrl: env.NEXT_PUBLIC_API_BASE_URL,
  fetch: (request) => globalThis.fetch(request),
});
```
<!-- /PROFILE-CONTENT -->

### 4.3. Quy ước giao diện của stack (cho ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Hiện thực quy ước theo stack (Stack Implementation Notes)

- `page.tsx` là server component; thành phần có form, state hay sự kiện đặt trong `src/features/` với `"use client"`.
- Trạng thái `Loading` của route dùng `loading.tsx`; trạng thái `Error` của route dùng `error.tsx` (client component, nhận `error` và `retry`; từ Next.js 16.3 `retry()` là API ổn định để tải lại segment). Trạng thái của từng vùng dữ liệu lấy từ `isPending`, `isError`, `isSuccess` của TanStack Query.
- Chuỗi hiển thị: next-intl không định tuyến theo locale; mỗi locale một file trong `messages/` (ví dụ `messages/vi.json`), `src/i18n/request.ts` dùng `getRequestConfig`, `next.config.ts` bọc bằng `createNextIntlPlugin()`, layout gốc bọc `NextIntlClientProvider`. Server component dùng `getTranslations`, client component dùng `useTranslations`.
- `QueryClientProvider` nằm trong `src/lib/query-provider.tsx` (client component), bọc nội dung ở layout gốc.
- Form: `useForm` với `zodResolver`; trường lỗi có `aria-invalid` và `aria-describedby` trỏ tới thông báo lỗi.
- `Idempotency-Key` sinh bằng `crypto.randomUUID()` khi người dùng gửi, giữ trong `useRef` cùng nội dung đã gửi; khi kết quả chưa rõ, form chuyển sang chỉ đọc (`disabled` trên các trường) và nút gửi lại dùng lại cặp khóa và nội dung đó, theo quy tắc gọi API ở trên. Cờ đang gửi cũng giữ trong `useRef` và đặt đồng bộ trước khi gọi API.
- Server component và route handler gọi API thay người dùng đọc `x-forwarded-for` bằng `headers()` của `next/headers`, lấy phần tử cuối (địa chỉ mà load balancer của web ghi) và gửi `X-Forwarded-For` chỉ gồm địa chỉ đó. Next.js không ghi đè header này khi client đã gửi, nên không chuyển nguyên giá trị nhận được.
- Biến môi trường: chỉ biến có tiền tố `NEXT_PUBLIC_` được nhúng vào mã chạy ở trình duyệt, lúc build, và chỉ khi mã đọc dạng thuộc tính như `process.env.NEXT_PUBLIC_API_BASE_URL`, không đọc bằng chỉ mục chuỗi. `src/config/env.ts` là nơi duy nhất đọc biến và validate bằng Zod:

  ```typescript
  import { z } from "zod";

  const EnvSchema = z.object({ NEXT_PUBLIC_API_BASE_URL: z.url() });

  export const env = EnvSchema.parse({ NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL });
  ```
- Token: token `semantic` của `docs/design-system/tokens.json` thành biến CSS trong `:root` của `src/app/globals.css` (mode khác ghi đè trong bộ chọn mode tương ứng); khối `@theme inline` ánh xạ biến đó thành utility của Tailwind; biến của shadcn (`--background`, `--foreground`, `--primary` và các biến còn lại) trỏ tới biến token, không giữ giá trị riêng. Style `base-nova` chỉ là khung thành phần, màu và spacing của nó đổi qua token. Style Dictionary là lựa chọn để sinh file, không cài mặc định; khi chưa dùng, viết biến CSS tay theo tên biến ở CONVENTIONS mục 10.7 và giữ khớp `tokens.json`. `globals.css` là nơi duy nhất chứa giá trị màu, spacing, radius, cỡ chữ thô.
- Next.js chèn phần tử `#__next-route-announcer__` có `role="alert"`; test truy vấn thông báo lỗi lọc theo nội dung, ví dụ `getByRole("alert").filter({ hasText: ... })`.
<!-- /PROFILE-CONTENT -->

### 4.4. Khuôn schema form (cho SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Schema form với Zod (Zod Form Schema)

Schema form chép đúng giới hạn của DTO request trong SPEC nguồn; kiểu suy ra bằng `z.infer`. Form dùng `zodResolver` ở ARCHITECTURE §7.

<!-- fill: Thay khối mẫu dưới đây bằng schema form thật của màn hình. -->

```typescript
import { z } from "zod";

export const CreateResourceFormSchema = z.strictObject({
  title: z.string().trim().min(1).max(200),
});
export type CreateResourceForm = z.infer<typeof CreateResourceFormSchema>;
```
<!-- /PROFILE-CONTENT -->

### 4.5. Công cụ test (cho SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Công cụ và vị trí test theo stack (Stack Test Tooling)

| TYPE | Công cụ | File | Chạy bằng |
| --- | --- | --- | --- |
| `UNIT` | Vitest, Testing Library, `jsdom` | `src/features/{{MODULE_SLUG}}/tests/*.test.tsx` | Project Vitest `unit` |
| `INT` | Vitest, Testing Library, MSW chặn request của client API | `src/features/{{MODULE_SLUG}}/tests/*.int.test.tsx` | Project Vitest `integration` |
| `E2E` | Playwright, `page.route` giả lập API hoặc API staging | `test/e2e/*.spec.ts` | `npx playwright test` |
| `A11Y` | Playwright, `@axe-core/playwright` với tag `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `wcag22aa` | `test/e2e/*.spec.ts` | `npx playwright test` |
| `VIS` | Playwright `toHaveScreenshot`, ảnh gốc commit trong `test/e2e/` | `test/e2e/*.spec.ts` | `npx playwright test` |
| `CONC` | Playwright, `page.route` có độ trễ, đếm request và header `Idempotency-Key` | `test/e2e/*.spec.ts` | `npx playwright test` |

Test Vitest import `describe`, `it`, `expect` từ `vitest`. Tên test mô tả hành vi bằng tiếng Anh, ví dụ `it("shows the conflict message when the API answers 409", ...)`; không chứa TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Quy ước riêng của stack (Stack Conventions)

- `tsconfig.json` theo scaffold (`module: esnext`, `moduleResolution: bundler`, `strict`, alias `@/*` trỏ `src/*`), thêm `noUncheckedIndexedAccess: true`.
- Thêm thành phần giao diện bằng `npx shadcn@4.21.0 add <tên>`; thành phần sinh ra nằm trong `src/components/ui/` và được sửa như mã của dự án.
- `create-next-app` sinh `AGENTS.md` chứa khối hướng dẫn của Next.js và `CLAUDE.md` một dòng `@AGENTS.md`. Giữ nguyên `AGENTS.md`: khi file này còn, `next dev` chỉ cập nhật khối trong `AGENTS.md`; khi file bị xóa, `next dev` ghi khối vào `CLAUDE.md`. Ứng dụng web nằm ở gốc repo: thay `CLAUDE.md` của scaffold bằng file sinh từ Agent Context Template, rồi thêm dòng `@AGENTS.md` ở cuối để Claude Code nạp hướng dẫn phiên bản của Next.js. Ứng dụng web nằm trong thư mục con (dự án fullstack): giữ nguyên `CLAUDE.md` một dòng của scaffold trong thư mục đó; Agent Context của dự án nằm ở gốc repo.
- Schema form chép giới hạn từ SPEC của API và có test biên; dùng chung gói schema với API cần ADR.

## 6. Khởi tạo dự án (Project Setup)

1. `npx create-next-app@16.3.5 <tên> --ts --app --tailwind --src-dir --eslint --import-alias "@/*" --use-npm --disable-git --yes`.
2. `npx shadcn@4.21.0 init -d -y --no-monorepo` (style `base-nova`, thành phần nền `@base-ui/react`).
3. Cài thư viện với phiên bản chính xác ở mục 2: `npm install --save-exact @tanstack/react-query@5.103.2 zod@4.6.5 react-hook-form@7.88.0 @hookform/resolvers@5.9.1 next-intl@4.14.6 openapi-fetch@0.17.0` và `npm install --save-exact --save-dev typescript@5.9.3 @types/node@24.13.6 vitest@4.1.11 @vitest/coverage-v8@4.1.11 @vitejs/plugin-react@5.2.0 jsdom@30.1.1 @testing-library/react@16.3.3 @testing-library/dom@10.4.2 @testing-library/user-event@14.6.7 @testing-library/jest-dom@7.0.1 msw@2.15.0 @playwright/test@1.63.0 @axe-core/playwright@4.13.0 openapi-typescript@7.13.0`; ghim các dependency còn lại mà scaffold và `shadcn init` ghi bằng khoảng (`^`) về đúng phiên bản ở mục 2.
4. Tạo `vitest.config.mts`, `test/setup/vitest.setup.ts`, `test/msw/server.ts`, `playwright.config.ts` theo mục 4.1; cấu hình next-intl và `QueryClientProvider` theo mục 4.3; thêm `noUncheckedIndexedAccess` vào `tsconfig.json`; thêm `src/lib/api/schema.d.ts` vào `.gitignore`, và thêm dòng `!.env.example` sau dòng `.env*` của scaffold để commit được file mẫu biến môi trường.
5. Chép tài liệu OpenAPI của API vào `openapi/api.yaml`, chạy `{{CODEGEN_CMD}}`, rồi `npx playwright install --with-deps chromium`.
6. Xử lý `AGENTS.md` và `CLAUDE.md` theo mục 5.
