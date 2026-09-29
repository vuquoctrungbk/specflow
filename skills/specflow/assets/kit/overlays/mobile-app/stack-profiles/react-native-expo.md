---
doc_type: profile
status: stable
version: 1.0.1
language: vi-en
surface: mobile-app
profile: react-native-expo
---

# Stack profile react-native-expo

## 1. Phạm vi (Scope)

Ứng dụng di động viết bằng TypeScript trên React Native và Expo SDK 57, điều hướng bằng Expo Router, dữ liệu trên thiết bị trong SQLite qua `expo-sqlite`, token trong `expo-secure-store`, chuỗi hiển thị bằng i18next, kiểu API sinh từ OpenAPI. Profile khớp dự án do `create-expo-app` 5.0.0 sinh ra (template mặc định, thư mục `src/app/`) cộng các thư viện ở mục 2.

Phiên bản chốt ngày 2026-09-22 và đã chạy thử cùng nhau trên Node.js 24.21.0 với một dự án thử: sinh kiểu, lint, typecheck, unit test thành phần, integration test của bộ máy đồng bộ trên `node:sqlite` (hai thiết bị xung đột, nhiều lần kích hoạt cùng lúc, mất phản hồi rồi gửi lại, thay đổi nối tiếp, sửa trong lúc thay đổi của cùng bản ghi đang gửi, đồng bộ trước giờ hẹn gửi lại, dữ liệu nhận về không lưu được), đóng gói JavaScript cho iOS và Android, `expo-doctor` và `npm audit` đều đạt; các bước khởi tạo ở mục 6 đã chạy lại trên một scaffold mới. Chưa chạy thử trong môi trường soạn profile: e2e Maestro (cần máy ảo hoặc thiết bị), build native bằng EAS Build và gửi lên cửa hàng (cần tài khoản Expo và tài khoản nhà phát triển), và cổng truy vấn trên `expo-sqlite` chạy trên thiết bị thật; cổng này dùng chung hàm xếp hàng với adapter của test (mục 4.2) để hành vi transaction giống nhau. Dự án chạy hai phần này lần đầu trên CI của mình và ghi kết quả vào ARCHITECTURE §13 trước Gate 2. Nâng phiên bản theo Dependency Policy ở ARCHITECTURE §2.2.

## 2. Bảng công nghệ (Tech Stack)

Chép vào ARCHITECTURE §2.1 với cột Bề mặt là `mobile-app` và cột ADR là "Mặc định của profile" (chỉ lệch profile mới cần ADR). Các gói có tiền tố `expo-` và gói native khác cài bằng `npx expo install` để lấy đúng phiên bản của SDK, rồi ghim về đúng phiên bản dưới đây bằng lệnh ở mục 6 bước 3.

| Lớp (Layer) | Công nghệ | Phiên bản chính xác | Vai trò | ADR |
| --- | --- | --- | --- | --- |
| Runtime công cụ | Node.js | 24.21.0 (LTS) | Chạy Expo CLI, Metro, Jest và công cụ | Mặc định của profile |
| Ngôn ngữ | TypeScript | 6.0.3 | Kiểu nghiêm ngặt; đúng phiên bản scaffold của SDK 57 | Mặc định của profile |
| Framework | `expo` | 57.0.24 | SDK, CLI, cấu hình native qua `app.json` | Mặc định của profile |
| Framework | `react-native` | 0.86.3 | Nền tảng giao diện native, đúng phiên bản SDK 57 ghim | Mặc định của profile |
| Framework | `react` | 19.2.3 | Thư viện giao diện, đúng phiên bản SDK 57 ghim | Mặc định của profile |
| Điều hướng | `expo-router` | 57.0.22 | Điều hướng theo file trong `src/app/`, deep link | Mặc định của profile |
| Màn hình chờ | `expo-splash-screen` | 57.0.9 | Giữ màn hình chờ tới khi mở xong cơ sở dữ liệu và chạy migration | Mặc định của profile |
| Cơ sở dữ liệu cục bộ | `expo-sqlite` | 57.0.3 | SQLite trên thiết bị qua một kết nối dùng chung, sự kiện thay đổi bảng | Mặc định của profile |
| Lưu trữ an toàn | `expo-secure-store` | 57.0.4 | Token trong Keychain và Android Keystore | Mặc định của profile |
| Trạng thái mạng | `expo-network` | 57.0.2 | Sự kiện có mạng lại để kích hoạt đồng bộ | Mặc định của profile |
| Sinh ID | `expo-crypto` | 57.0.3 | `randomUUID()` cho ID thay đổi và khóa idempotency | Mặc định của profile |
| Quốc tế hóa | `expo-localization`, `i18next`, `react-i18next` | 57.0.2, 26.4.2, 17.0.15 | Locale của thiết bị, chuỗi hiển thị theo khóa, số nhiều | Mặc định của profile |
| Validation | `zod` | 4.6.5 | Schema form và biến môi trường | Mặc định của profile |
| Client API | `openapi-fetch` | 0.17.0 | Client HTTP có kiểu theo OpenAPI | Mặc định của profile |
| Sinh mã | `openapi-typescript` | 7.13.0 | Sinh kiểu từ tài liệu OpenAPI; chạy qua `npx`, không cài vào dự án vì bản này chỉ nhận TypeScript 5 | Mặc định của profile |
| Kiểu | `@types/react`, `@types/node`, `@types/jest` | 19.2.18, 24.13.6, 29.5.14 | Kiểu cho React, Node.js (test chạy trên Node.js), Jest | Mặc định của profile |
| Lint | `eslint`, `eslint-config-expo` | 9.39.5, 57.0.2 | Lint theo cấu hình flat của Expo, chạy qua `expo lint` | Mặc định của profile |
| Test | `jest`, `jest-expo` | 29.7.0, 57.0.5 | Unit và integration test; SDK 57 ghim Jest 29 | Mặc định của profile |
| Test | `@testing-library/react-native`, `react-test-renderer` | 13.3.3, 19.2.3 | Render thành phần, truy vấn theo nhãn và vai trò; bản 14 cần React 19.3 nên chưa dùng được với SDK 57 | Mặc định của profile |
| E2E | Maestro CLI | 2.10.0 | Flow e2e và smoke trên máy ảo hoặc thiết bị | Mặc định của profile |
| Kiểm tra nền tảng | `expo-doctor` | 1.20.4 | Kiểm tra cấu hình và độ tương thích phiên bản với SDK; chạy qua `npx` | Mặc định của profile |
| Build và phân phối | `eas-cli` | 24.7.0 | Build native, ký, gửi lên cửa hàng, cập nhật qua mạng; chạy qua `npx` | Mặc định của profile |

## 3. Giá trị placeholder

| Placeholder | Giá trị |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | TypeScript bật `strict` và `noUncheckedIndexedAccess`; cấm kiểu `any` (ESLint `@typescript-eslint/no-explicit-any` mức error). |
| `{{CODEGEN_CMD}}` | `npx --yes openapi-typescript@7.13.0 openapi/api.yaml -o src/lib/api/schema.d.ts` |
| `{{LINT_CMD}}` | `npx expo lint --max-warnings 0` |
| `{{TYPECHECK_CMD}}` | `npx tsc --noEmit` |
| `{{UNIT_TEST_CMD}}` | `npx jest --selectProjects unit` |
| `{{INTEGRATION_TEST_CMD}}` | `npx jest --selectProjects integration` |
| `{{E2E_TEST_CMD}}` | `maestro test .maestro/` |
| `{{COVERAGE_CMD}}` | `npx jest --coverage` |
| `{{PLATFORM_CHECK_CMD}}` | `npx --yes expo-doctor@1.20.4` |
| `{{BUILD_CMD}}` | `node --env-file-if-exists=.env --env-file-if-exists=.env.production --env-file-if-exists=.env.local --env-file-if-exists=.env.production.local -e "if (!URL.canParse(process.env.EXPO_PUBLIC_API_BASE_URL ?? '')) { console.error('EXPO_PUBLIC_API_BASE_URL is missing or not a URL'); process.exit(1); }" && npx expo export --platform ios --platform android --output-dir dist` |
| `{{AUDIT_CMD}}` | `npm audit --audit-level=high` |

Ghi chú:

- Kiểu sinh ở `src/lib/api/schema.d.ts` không được commit, nên `{{CODEGEN_CMD}}` chạy đầu tiên trên máy mới, trong CI và sau mỗi lần cập nhật `openapi/api.yaml`. `npx --yes` tải đúng bản 7.13.0 cùng TypeScript 5 vào bộ nhớ đệm của npx, tách khỏi TypeScript 6 của dự án; kiểu sinh ra dùng được với TypeScript 6.
- `{{BUILD_CMD}}` đóng gói JavaScript và tài nguyên cho cả hai nền tảng bằng Metro, bắt lỗi import và cấu hình mà typecheck không thấy. Metro nhúng `EXPO_PUBLIC_API_BASE_URL` lúc đóng gói nhưng không kiểm tra nó, còn `src/config/env.ts` chỉ báo lỗi khi ứng dụng khởi động; vì vậy phần đầu của lệnh đọc `.env`, `.env.production`, `.env.local`, `.env.production.local` theo thứ tự ưu tiên của Expo CLI khi đóng gói bản production (biến đặt sẵn trong môi trường thắng mọi file) và dừng với thông báo nêu tên biến khi biến thiếu hoặc không phải URL. Build native (ký, tạo file cài) chạy ở pipeline phát hành bằng `npx eas-cli@24.7.0 build`, với biến đặt ở khóa `env` của từng profile build trong `eas.json`, theo ARCHITECTURE §8.
- `{{E2E_TEST_CMD}}` chạy trên máy ảo đã cài bản build phát triển hoặc bản preview của ứng dụng (`npx expo run:android`, `npx expo run:ios`, hoặc bản tải từ EAS Build). Cài Maestro đúng phiên bản: `export MAESTRO_VERSION=2.10.0; curl -Ls "https://get.maestro.mobile.dev" | bash`. Lệnh `setAirplaneMode` của Maestro chỉ có tác dụng trên Android; hành vi mất mạng trên iOS được bảo vệ bằng integration test và smoke test thủ công.
- `{{PLATFORM_CHECK_CMD}}` tra phiên bản gói của SDK qua mạng; lỗi mạng thì chạy lại, CI không có mạng ra ngoài thì chạy lệnh ở job có mạng.
- `{{E2E_TEST_CMD}}` và test smoke cần máy ảo hoặc thiết bị nên chạy trong CI, không chạy trong vòng commit của coding agent.
- Ngưỡng coverage mặc định của profile là 80% dòng và nhánh cho `src/features/**`; SRS có thể đặt ngưỡng khác ở NFR-MAINT. Test bắt buộc của SPEC thường chưa phủ đủ nhánh lỗi; test bổ sung đặt tên theo hành vi như mọi test khác.

## 4. Nội dung chèn vào tài liệu (Profile Content)

### 4.1. Cây thư mục và cấu hình công cụ (cho ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Cây thư mục theo stack (Stack Directory Tree)

```text
.
├── openapi/api.yaml                     # bản sao tài liệu OpenAPI của API, nguồn sinh kiểu
├── .maestro/                            # flow e2e và smoke của Maestro, mỗi flow một file yaml
├── assets/
├── src/
│   ├── app/                             # màn hình của Expo Router
│   │   ├── _layout.tsx                  # mở cơ sở dữ liệu, chạy migration, provider, đăng ký kích hoạt đồng bộ
│   │   └── {{ROUTE_PATH}}.tsx           # một file cho mỗi màn hình theo quy ước đặt tên của Expo Router
│   ├── features/
│   │   ├── {{MODULE_SLUG}}/
│   │   │   ├── components/              # thành phần của tính năng
│   │   │   ├── hooks/                   # hook đọc dữ liệu từ cơ sở dữ liệu cục bộ
│   │   │   ├── mutations/               # thao tác ghi cục bộ: bản ghi và hàng đợi trong một transaction
│   │   │   ├── {{MODULE_SLUG}}.schema.ts # schema Zod của form
│   │   │   ├── index.ts                 # xuất công khai của tính năng
│   │   │   └── tests/                   # *.test.ts(x) unit, *.int.test.ts integration
│   │   └── sync/                        # bộ máy đồng bộ, kích hoạt đồng bộ, màn hình chọn bản khi xung đột
│   ├── db/
│   │   ├── sql-executor.ts              # cổng truy vấn dùng chung
│   │   ├── serialize-connection.ts      # một kết nối: xếp hàng lời gọi, transaction giữ kết nối
│   │   ├── expo-sqlite-executor.ts      # hiện thực cổng trên expo-sqlite
│   │   ├── migrations.ts                # migration cục bộ, chỉ thêm mới
│   │   └── use-local-query.ts           # hook truy vấn lại khi bảng liên quan thay đổi
│   ├── i18n/                            # cấu hình i18next và file chuỗi theo locale
│   ├── config/env.ts                    # nơi duy nhất đọc biến EXPO_PUBLIC_, validate bằng Zod
│   └── lib/
│       ├── api/client.ts                # client openapi-fetch dùng chung
│       ├── api/schema.d.ts              # kiểu sinh bởi openapi-typescript, không sửa, không commit
│       ├── secure-session.ts            # token trong expo-secure-store
│       └── single-flight.ts             # chạy một tác vụ tại một thời điểm
├── test/support/                        # adapter node:sqlite, dữ liệu mẫu cục bộ, API giả lập cho integration test
├── AGENTS.md                            # hướng dẫn của Expo do scaffold sinh; CLAUDE.md thắng khi mâu thuẫn
├── app.json                             # cấu hình Expo, config plugin, android.allowBackup false
├── eas.json                             # profile build, sinh bằng eas build:configure
├── eslint.config.js
├── jest.config.js
├── tsconfig.json
└── .env.example                         # chỉ tên biến và giá trị giả
```

<!-- fill: Lặp nhánh app/{{ROUTE_PATH}}.tsx cho mỗi màn hình ở SRS §3 và nhánh features/{{MODULE_SLUG}} cho mỗi phân hệ ở §4.1; bỏ thư mục mà tính năng không có. -->

File Diff mặc định khi SPEC thêm màn hình hoặc thao tác ghi: file màn hình trong `src/app/`, nhánh tính năng trong `src/features/`, migration mới trong `src/db/migrations.ts`, khóa chuỗi mới trong `src/i18n/`, test trong `tests/` của tính năng và flow trong `.maestro/`. Không có thư mục `ios/` và `android/` trong repo: Expo sinh chúng khi build (Continuous Native Generation).

Cấu hình Jest (`jest.config.js`): hai project; project integration chạy trên môi trường Node.js để dùng `node:sqlite`.

```javascript
/** @type {import('jest').Config} */
module.exports = {
  projects: [
    {
      displayName: "unit",
      preset: "jest-expo",
      testMatch: ["<rootDir>/src/**/*.test.ts?(x)"],
      testPathIgnorePatterns: ["/node_modules/", "\\.int\\.test\\.ts$"],
    },
    {
      displayName: "integration",
      preset: "jest-expo",
      testEnvironment: "node",
      testMatch: ["<rootDir>/src/**/*.int.test.ts"],
    },
  ],
  collectCoverageFrom: ["src/features/**/*.{ts,tsx}", "!src/features/**/tests/**"],
  coverageThreshold: { global: { lines: 80, branches: 80 } },
};
```

Cấu hình lint (`eslint.config.js`): giữ cấu hình flat của Expo, thêm file sinh ra vào `ignores` và nâng `no-explicit-any` lên error.

```javascript
const { defineConfig } = require("eslint/config");
const expoConfig = require("eslint-config-expo/flat");

module.exports = defineConfig([
  expoConfig,
  { ignores: ["dist/*", "coverage/*", "src/lib/api/schema.d.ts"] },
  { rules: { "@typescript-eslint/no-explicit-any": "error" } },
]);
```

`tsconfig.json` theo scaffold (`extends: "expo/tsconfig.base"`, `strict`, alias `@/*` trỏ `./src/*`), thêm `"noUncheckedIndexedAccess": true` và `"types": ["jest", "node"]`: TypeScript 6 mặc định không nạp kiểu toàn cục nào, nên thiếu dòng này thì test không thấy `describe`, `expect`.
<!-- /PROFILE-CONTENT -->

### 4.2. Cơ sở dữ liệu cục bộ và client API (cho ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Cổng truy vấn, migration và client API theo stack (Stack Local Database & API Client)

- Mọi truy cập SQLite đi qua cổng `SqlExecutor`; ứng dụng dùng hiện thực trên `expo-sqlite`, integration test dùng hiện thực trên `node:sqlite` của Node.js với cùng migration. Cả hai mở đúng một kết nối và bọc nó bằng `serializeConnection`: lời gọi xếp hàng, transaction (`BEGIN IMMEDIATE` tới `COMMIT`) giữ kết nối tới khi kết thúc nên không câu lệnh nào khác chen vào. Không dùng `withExclusiveTransactionAsync`: hàm này mở kết nối thứ hai cho mỗi transaction, trên đó khóa ngoại tắt và lệnh ghi song song lỗi `database is locked`, khác với test.
- `PRAGMA foreign_keys` và `busy_timeout` có hiệu lực theo kết nối, nên đặt ngay sau khi mở kết nối duy nhất.
- Migration là danh sách script chỉ thêm mới; `PRAGMA user_version` ghi số migration đã chạy. Cơ sở dữ liệu mở với `enableChangeListener: true` để hook truy vấn lại khi bảng liên quan đổi.
- Client dùng chung tạo bằng `openapi-fetch` và nhận `fetch` qua tham số, để integration test thay bằng API giả lập. Header xác thực gắn bằng middleware `client.use(...)` theo cơ chế phiên ở ARCHITECTURE §6.1.

```typescript
export type SqlValue = string | number | null;

// Port over the on-device database: expo-sqlite in the app, node:sqlite in integration tests.
export interface SqlExecutor {
  exec(script: string): Promise<void>;
  run(sql: string, params?: readonly SqlValue[]): Promise<void>;
  all<T>(sql: string, params?: readonly SqlValue[]): Promise<T[]>;
  transaction(task: (tx: SqlExecutor) => Promise<void>): Promise<void>;
}
```

```typescript
import type { SqlExecutor, SqlValue } from "./sql-executor";

export type SqlConnection = Pick<SqlExecutor, "exec" | "run" | "all">;

// The app opens one connection. Calls queue behind each other and a transaction owns the connection until it ends,
// so no statement from elsewhere runs inside it. The app adapter and the test adapter share this code.
export function serializeConnection(connection: SqlConnection): SqlExecutor {
  let tail: Promise<unknown> = Promise.resolve();
  const exclusive = <T>(task: () => Promise<T>): Promise<T> => {
    const result = tail.then(task, task);
    tail = result.catch(() => undefined);
    return result;
  };
  const insideTransaction: SqlExecutor = {
    exec: (script) => connection.exec(script),
    run: (sql, params) => connection.run(sql, params),
    all: <T>(sql: string, params?: readonly SqlValue[]) => connection.all<T>(sql, params),
    transaction: () => Promise.reject(new Error("nested transactions are not supported")),
  };
  return {
    exec: (script) => exclusive(() => connection.exec(script)),
    run: (sql, params) => exclusive(() => connection.run(sql, params)),
    all: <T>(sql: string, params?: readonly SqlValue[]) => exclusive(() => connection.all<T>(sql, params)),
    transaction: (task) =>
      exclusive(async () => {
        await connection.exec("BEGIN IMMEDIATE");
        try {
          await task(insideTransaction);
          await connection.exec("COMMIT");
        } catch (error) {
          // SQLite may already have rolled back on its own; the original error is the one that matters.
          await connection.exec("ROLLBACK").catch(() => undefined);
          throw error;
        }
      }),
  };
}
```

```typescript
import { openDatabaseAsync } from "expo-sqlite";
import { migrate } from "./migrations";
import { serializeConnection } from "./serialize-connection";
import type { SqlExecutor, SqlValue } from "./sql-executor";

// One connection for the whole app. withExclusiveTransactionAsync is not used: it opens a second connection,
// on which foreign keys are off and concurrent writes fail with "database is locked".
export async function openAppDatabase(name: string): Promise<SqlExecutor> {
  const db = await openDatabaseAsync(name, { enableChangeListener: true });
  await db.execAsync("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 5000;");
  const executor = serializeConnection({
    exec: (script) => db.execAsync(script),
    async run(sql, params = []) {
      await db.runAsync(sql, [...params]);
    },
    all: <T>(sql: string, params: readonly SqlValue[] = []) => db.getAllAsync<T>(sql, [...params]),
  });
  await migrate(executor);
  return executor;
}
```

<!-- fill: Thay danh sách MIGRATIONS mẫu bằng migration thật theo bảng cục bộ ở trên; giữ hàm migrate. -->

```typescript
import type { SqlExecutor } from "./sql-executor";

// Append-only: a released migration is never edited; PRAGMA user_version records how many ran.
export const MIGRATIONS: readonly string[] = [
  `CREATE TABLE sync_state (id INTEGER PRIMARY KEY CHECK (id = 1), cursor TEXT, last_synced_at TEXT);
   INSERT INTO sync_state (id) VALUES (1);`,
];

export async function migrate(db: SqlExecutor): Promise<void> {
  const [row] = await db.all<{ user_version: number }>("PRAGMA user_version");
  for (let version = row?.user_version ?? 0; version < MIGRATIONS.length; version++) {
    const script = MIGRATIONS[version];
    if (script === undefined) break;
    await db.transaction(async (tx) => {
      await tx.exec(script);
      await tx.exec(`PRAGMA user_version = ${version + 1}`);
    });
  }
}
```

```typescript
import createClient from "openapi-fetch";
import type { paths } from "./schema";

export type ApiClient = ReturnType<typeof createClient<paths>>;

export function createApiClient(baseUrl: string, fetchImpl: typeof fetch = (input, init) => globalThis.fetch(input, init)): ApiClient {
  return createClient<paths>({ baseUrl, fetch: (request) => fetchImpl(request) });
}
```
<!-- /PROFILE-CONTENT -->

### 4.3. Quy ước của stack (cho ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Hiện thực quy ước theo stack (Stack Implementation Notes)

- Màn hình là file trong `src/app/`; `_layout.tsx` gốc giữ màn hình chờ (`expo-splash-screen`) tới khi mở xong cơ sở dữ liệu và chạy migration, rồi cung cấp `SqlExecutor`, client API và bộ máy đồng bộ qua React context. Tham số điều hướng đọc bằng `useLocalSearchParams` và validate bằng Zod trước khi dùng.
- Hook đọc dữ liệu dùng `useLocalQuery`: truy vấn cục bộ, rồi truy vấn lại khi `addDatabaseChangeListener` báo bảng liên quan đổi; SQLite báo từng dòng đổi, nên các lần báo trong một khung hình được gộp thành một lần truy vấn. Danh sách bảng truyền vào là hằng số hoặc được memo hóa.

  ```typescript
  import { addDatabaseChangeListener } from "expo-sqlite";
  import { useCallback, useEffect, useState } from "react";
  import type { SqlExecutor, SqlValue } from "./sql-executor";

  // Re-runs a local query when one of the given tables changes (the database is opened with enableChangeListener).
  // SQLite reports every changed row, so the reloads of one burst of changes are merged into one.
  export function useLocalQuery<T>(db: SqlExecutor, sql: string, params: readonly SqlValue[], tables: readonly string[]) {
    const [rows, setRows] = useState<T[] | undefined>(undefined);
    const [error, setError] = useState<unknown>(undefined);
    const key = JSON.stringify(params);
    const load = useCallback(() => {
      db.all<T>(sql, JSON.parse(key) as SqlValue[]).then((next) => {
        setRows(next);
        setError(undefined);
      }, setError);
    }, [db, sql, key]);
    useEffect(() => {
      load();
      let pending: ReturnType<typeof setTimeout> | undefined;
      const subscription = addDatabaseChangeListener((event) => {
        if (!tables.includes(event.tableName) || pending !== undefined) return;
        pending = setTimeout(() => {
          pending = undefined;
          load();
        }, 16);
      });
      return () => {
        clearTimeout(pending);
        subscription.remove();
      };
    }, [load, tables]);
    return { rows, error };
  }
  ```
- Bộ máy đồng bộ bọc lượt đồng bộ bằng `createSingleFlight`, chạy thêm đúng một lượt cho kích hoạt đến giữa chừng khi lượt kết thúc `done` hoặc `offline`; kích hoạt: một lần khi mở xong cơ sở dữ liệu, `addNetworkStateListener` của `expo-network` (khi `isInternetReachable` là `true`), `AppState` (khi ứng dụng trở lại `active`), kéo để làm mới (`RefreshControl`), và bộ hẹn giờ khi ứng dụng đang mở. Bốn kích hoạt đầu bỏ giờ hẹn của backoff trước khi đồng bộ (chỉ giữ thời gian chờ `429` của thiết bị); khi một lượt kết thúc, bộ hẹn giờ đặt tới hết thời gian chờ `429` khi chưa có lượt nào chạy sau nó, nếu không thì tới giờ hẹn gần nhất còn chờ, kể cả giờ hẹn đã qua trong lúc lượt đó chạy (khi đó dùng độ trễ một giây thay vì bỏ qua), trừ khi lượt kết thúc bằng `auth-required` hoặc `failed`; lượt đầu tiên chạy sau khi hết thời gian chờ `429` xóa nó, nên thời gian chờ đó không đặt thêm bộ hẹn giờ nào; bộ hẹn giờ bị hủy khi ứng dụng xuống nền hoặc khi gỡ đăng ký. Làm mới phiên khi gặp `401` dùng `createSingleFlight(refresh, () => false)` để một loạt `401` chỉ làm mới một lần.

  ```typescript
  // Runs one task at a time; calls that arrive during a run share it and schedule exactly one more run.
  export function createSingleFlight<T>(task: () => Promise<T>, runAgain: (result: T) => boolean = () => true): () => Promise<T> {
    let running: Promise<T> | null = null;
    let again = false;
    return () => {
      if (running) {
        again = true;
        return running;
      }
      running = (async () => {
        let result: T;
        do {
          again = false;
          result = await task();
        } while (again && runAgain(result));
        return result;
      })().finally(() => {
        running = null;
      });
      return running;
    };
  }
  ```
- ID thay đổi và khóa idempotency sinh bằng `randomUUID()` của `expo-crypto`, lưu cùng thay đổi trong hàng đợi trước khi gửi.
- Refresh token lưu bằng `SecureStore.setItemAsync` với `keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK_THIS_DEVICE_ONLY` (đọc được khi đồng bộ chạy lúc máy đã mở khóa một lần, không đi theo bản sao lưu sang máy khác); access token chỉ giữ trong bộ nhớ.
- Sao lưu: `app.json` đặt `android.allowBackup` là `false`. Trên iOS, `expo-sqlite` đặt cơ sở dữ liệu trong thư mục `Documents/SQLite` của ứng dụng, thuộc bản sao lưu iCloud và máy tính; ARCHITECTURE §9 ghi rủi ro này hoặc biện pháp riêng.
- Chuỗi hiển thị: một instance i18next tạo bằng `createInstance()` và `initReactI18next`, locale lấy từ `getLocales()` của `expo-localization`, mỗi locale một file JSON trong `src/i18n/`; số nhiều dùng hậu tố `_one`, `_other`. Thành phần dùng `useTranslation`.
- Trợ năng: phần tử tương tác có `accessibilityRole` và `accessibilityLabel`; giá trị liệt kê (kết quả, trạng thái) đọc bằng nhãn trong file chuỗi, không đọc mã thô; thông báo trạng thái đồng bộ dùng `accessibilityLiveRegion="polite"` trên Android và `AccessibilityInfo.announceForAccessibility` trên iOS; test truy vấn bằng `getByRole`, `getByLabelText`. Phần tử mà flow Maestro chạm tới có `testID`.
- Biến môi trường: chỉ biến có tiền tố `EXPO_PUBLIC_` được nhúng vào bản build, và chỉ khi mã đọc dạng `process.env.EXPO_PUBLIC_API_BASE_URL`, không đọc bằng chỉ mục chuỗi. `src/config/env.ts` là nơi duy nhất đọc biến:

  ```typescript
  import { z } from "zod";

  const EnvSchema = z.object({ EXPO_PUBLIC_API_BASE_URL: z.url() });

  export const env = EnvSchema.parse({ EXPO_PUBLIC_API_BASE_URL: process.env.EXPO_PUBLIC_API_BASE_URL });
  ```
<!-- /PROFILE-CONTENT -->

### 4.4. Khuôn schema form (cho SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Schema form với Zod (Zod Form Schema)

Schema form chép đúng giới hạn của DTO request trong contract nguồn; kiểu suy ra bằng `z.infer`. Thao tác ghi cục bộ chỉ nhận dữ liệu đã qua schema.

<!-- fill: Thay khối mẫu dưới đây bằng schema form thật của màn hình. -->

```typescript
import { z } from "zod";

export const UpdateRecordFormSchema = z.strictObject({
  note: z.string().trim().max(1000).nullable(),
});
export type UpdateRecordForm = z.infer<typeof UpdateRecordFormSchema>;
```
<!-- /PROFILE-CONTENT -->

### 4.5. Công cụ test (cho SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Công cụ và vị trí test theo stack (Stack Test Tooling)

| TYPE | Công cụ | File | Chạy bằng |
| --- | --- | --- | --- |
| `UNIT` | Jest với preset `jest-expo`, Testing Library cho React Native | `src/features/{{MODULE_SLUG}}/tests/*.test.ts(x)` | Project Jest `unit` |
| `INT` | Jest trên môi trường Node.js, `node:sqlite` qua cổng `SqlExecutor`, API giả lập truyền vào client API qua tham số `fetch` | `src/features/{{MODULE_SLUG}}/tests/*.int.test.ts` | Project Jest `integration` |
| `E2E` | Maestro trên máy ảo Android và iOS; `setAirplaneMode` cho kịch bản mất mạng (chỉ Android) | `.maestro/*.yaml` | `maestro test .maestro/` |
| `A11Y` | Testing Library truy vấn theo vai trò và nhãn; kiểm tra thủ công bằng VoiceOver và TalkBack theo checklist của SPEC | `src/features/{{MODULE_SLUG}}/tests/*.test.tsx` | Project Jest `unit` |
| `CONC` | Như `INT`, mỗi thiết bị một cơ sở dữ liệu `node:sqlite` trong bộ nhớ | `src/features/{{MODULE_SLUG}}/tests/*.int.test.ts` | Project Jest `integration` |
| `SMOKE` | Maestro trên bản build thử nội bộ, chạy trên từng cấu hình của ma trận thiết bị | `.maestro/smoke/*.yaml` | `maestro test .maestro/smoke/` |

Adapter `node:sqlite` cho integration test (`test/support/node-sqlite-executor.ts`) dùng cùng `serializeConnection` với ứng dụng, nên transaction trong test và trên thiết bị theo cùng một cách:

```typescript
import { DatabaseSync } from "node:sqlite";
import { migrate } from "@/db/migrations";
import { serializeConnection } from "@/db/serialize-connection";
import type { SqlExecutor, SqlValue } from "@/db/sql-executor";

// Same port and the same serialization as the app, backed by node:sqlite in memory.
export async function openTestDatabase(): Promise<SqlExecutor> {
  const db = new DatabaseSync(":memory:");
  db.exec("PRAGMA foreign_keys = ON");
  const executor = serializeConnection({
    async exec(script) {
      db.exec(script);
    },
    async run(sql, params = []) {
      db.prepare(sql).run(...params);
    },
    async all<T>(sql: string, params: readonly SqlValue[] = []) {
      return db.prepare(sql).all(...params) as T[];
    },
  });
  await migrate(executor);
  return executor;
}
```

API giả lập của test `CONC` là một lớp có phương thức `fetch` nhận `Request`, giữ phiên bản bản ghi, lưu phản hồi theo header `Idempotency-Key`, ghi lại khóa và body của mọi request, có cờ làm mất phản hồi kế tiếp sau khi đã áp dụng, móc chạy một tác vụ sau khi áp dụng lần ghi kế tiếp và trước khi trả lời (để test ghi cục bộ trong lúc thay đổi đang gửi), móc chạy một tác vụ trước khi trả lời lần đọc kế tiếp (để test kích hoạt đến trong lúc lần đọc đang bay), công tắc cho một bản ghi luôn trả lỗi `5xx` và tùy chọn độ trễ; test tạo client bằng `createApiClient(baseUrl, api.fetch)`. Test thao tác ghi cục bộ không cần API: `test/support/` có hàm đưa bản ghi mẫu vào cơ sở dữ liệu như sau một lượt đồng bộ. Test import `describe`, `it`, `expect` từ biến toàn cục của Jest. Tên test mô tả hành vi bằng tiếng Anh, ví dụ `it("keeps both edits when two devices change the same item offline", ...)`; không chứa TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Quy ước riêng của stack (Stack Conventions)

- Cài gói có mã native hoặc gói thuộc SDK bằng `npx expo install`, rồi ghim về phiên bản chính xác bằng `npm install --save-exact`; gói thuần JavaScript cài thẳng bằng `npm install --save-exact`. `npx expo install` ghi gói vào dependencies kể cả khi thêm `-- --save-dev`, nên gói chỉ dùng cho test và công cụ cài bằng `npm install --save-dev --save-exact`.
- Không tạo hay sửa tay thư mục `ios/` và `android/`; cấu hình native nằm trong `app.json` và config plugin. Thêm thư viện có mã native thì cần bản build phát triển mới (`npx expo run:ios`, `npx expo run:android` hoặc EAS Build), Expo Go không chạy được.
- `create-expo-app` sinh `AGENTS.md` chứa hướng dẫn của Expo, `CLAUDE.md` một dòng `@AGENTS.md` và `.claude/settings.json` bật plugin Expo cho Claude Code. Giữ nguyên `AGENTS.md` và `.claude/settings.json`; ứng dụng nằm ở gốc repo thì thay `CLAUDE.md` của scaffold bằng file sinh từ Agent Context Template rồi thêm ở cuối một dòng ưu tiên và dòng `@AGENTS.md` để Claude Code nạp hướng dẫn phiên bản của Expo. `AGENTS.md` khuyên `npx expo install --fix`, `eas-cli@latest` và cập nhật qua mạng; các điểm này nhường cho phiên bản ghim ở ARCHITECTURE §2, Dependency Policy và chính sách phát hành ở ARCHITECTURE §8. Dòng ưu tiên: "Khi `AGENTS.md` mâu thuẫn với file này, `docs/ARCHITECTURE.md` hoặc `.claude/rules/`, các file đó thắng."; ứng dụng nằm trong thư mục con thì giữ `CLAUDE.md` một dòng của scaffold trong thư mục đó, Agent Context của dự án nằm ở gốc repo. Rule của specflow nằm trong `.claude/rules/` cạnh `.claude/settings.json`.
- Schema form chép giới hạn từ contract của API và có test biên; dùng chung gói schema với API cần ADR.
- Mã riêng cho một nền tảng đặt trong file hậu tố `.ios.tsx`, `.android.tsx`; `Platform.OS` chỉ dùng cho khác biệt nhỏ trong một dòng.

## 6. Khởi tạo dự án (Project Setup)

1. `npx create-expo-app@5.0.0 <tên> --yes`, rồi xóa mã mẫu bằng `npm run reset-project` (trả lời `n` để không giữ bản sao mã mẫu).
2. Cài gói của SDK: `npx expo install expo-sqlite expo-secure-store expo-network expo-crypto expo-localization`; lệnh này thêm config plugin cần thiết vào `app.json`.
3. Ghim phiên bản ở mục 2:
   - `npm install --save-exact expo@57.0.24 expo-router@57.0.22 expo-sqlite@57.0.3 expo-secure-store@57.0.4 expo-network@57.0.2 expo-crypto@57.0.3 expo-localization@57.0.2 expo-splash-screen@57.0.9 zod@4.6.5 openapi-fetch@0.17.0 i18next@26.4.2 react-i18next@17.0.15`
   - `npm install --save-dev --save-exact typescript@6.0.3 @types/react@19.2.18 @types/node@24.13.6 eslint@9.39.5 eslint-config-expo@57.0.2 jest@29.7.0 jest-expo@57.0.5 @types/jest@29.5.14 @testing-library/react-native@13.3.3 react-test-renderer@19.2.3`
   - Ghim các gói còn lại của scaffold về phiên bản đang cài, rồi cài lại: `node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));for(const k of ['dependencies','devDependencies'])for(const n of Object.keys(p[k]??{}))if(/^[~^]/.test(p[k][n]))p[k][n]=require('./node_modules/'+n+'/package.json').version;fs.writeFileSync('package.json',JSON.stringify(p,null,2)+'\n')" && npm install`
4. Tạo `eslint.config.js`, `jest.config.js` và sửa `tsconfig.json` theo mục 4.1 (ESLint đã cài ở bước 3, không cần chạy `npx expo lint` để sinh cấu hình); trong `app.json` đặt `android.allowBackup` là `false`.
5. Tạo `src/db/`, `src/lib/`, `src/config/env.ts`, `src/i18n/`, `test/support/` theo mục 4.2, 4.3 và 4.5; thêm `src/lib/api/schema.d.ts` và `coverage/` vào `.gitignore` (scaffold đã bỏ qua `dist/`).
6. Chép tài liệu OpenAPI của API vào `openapi/api.yaml`, chạy `{{CODEGEN_CMD}}`; tạo `eas.json` bằng `npx eas-cli@24.7.0 build:configure` khi dự án có tài khoản Expo, và đặt `EXPO_PUBLIC_API_BASE_URL` ở khóa `env` của từng profile build.
7. Xử lý `AGENTS.md`, `CLAUDE.md` và `.claude/settings.json` theo mục 5.
