---
doc_type: profile
status: stable
version: 1.0.0
language: vi-en
surface: backend-api
profile: node-nestjs-prisma
---

# Stack profile node-nestjs-prisma

## 1. Phạm vi (Scope)

Backend API viết bằng TypeScript chạy trên Node.js, framework NestJS dạng ES module (ESM, mặc định của NestJS 12), ORM Prisma, cơ sở dữ liệu PostgreSQL. Profile khớp dự án do `nest new` của NestJS 12 sinh ra (ESM, Vitest, oxlint), cộng Prisma và các thư viện ở mục 2. Phiên bản chốt ngày 2026-09-22 và đã chạy thử cùng nhau: typecheck, lint type-aware, unit test, e2e test và build đều đạt trên dự án thử; nâng phiên bản theo Dependency Policy ở ARCHITECTURE §2.2.

## 2. Bảng công nghệ (Tech Stack)

Chép vào ARCHITECTURE §2.1 với cột Bề mặt là `backend-api` và cột ADR là "Mặc định của profile" (chỉ lệch profile mới cần ADR).

| Lớp (Layer) | Công nghệ | Phiên bản chính xác | Vai trò | ADR |
| --- | --- | --- | --- | --- |
| Runtime | Node.js | 24.21.0 (LTS) | Chạy ứng dụng và công cụ | Mặc định của profile |
| Ngôn ngữ | TypeScript | 6.0.3 | Kiểu nghiêm ngặt, `module: nodenext`; khớp yêu cầu `~6.0.2` của `@nestjs/cli` 12 | Mặc định của profile |
| Framework | `@nestjs/core`, `@nestjs/common`, `@nestjs/platform-express`, `@nestjs/testing` | 12.0.4 | Module, DI, HTTP, test module; gói ESM | Mặc định của profile |
| Build | `@nestjs/cli` | 12.0.3 | Scaffold, build, chạy dev | Mặc định của profile |
| Build | `@nestjs/schematics` | 12.0.4 | Sinh module, controller, service | Mặc định của profile |
| Phụ thuộc của NestJS | `reflect-metadata` | 0.2.2 | Decorator metadata | Mặc định của profile |
| Phụ thuộc của NestJS | `rxjs` | 7.8.2 | Luồng bất đồng bộ nội bộ của NestJS | Mặc định của profile |
| Cơ sở dữ liệu | PostgreSQL | 18.6 | Lưu trữ quan hệ, transaction ACID | Mặc định của profile |
| ORM | `prisma`, `@prisma/client`, `@prisma/adapter-pg` | 7.10.0 | Schema, migration, truy vấn có kiểu qua driver adapter `pg`; `prisma` nằm trong `dependencies` để image phát hành chạy được migration | Mặc định của profile |
| Validation | `zod` | 4.6.5 | Schema runtime cho DTO và biến môi trường | Mặc định của profile |
| Xác thực | `@nestjs/jwt` | 12.0.2 | Ký và kiểm tra access token | Mặc định của profile |
| Hash mật khẩu | `argon2` | 0.45.1 | Argon2id | Mặc định của profile |
| Giới hạn tần suất | `@nestjs/throttler` | 6.7.0 | Rate limit theo route | Mặc định của profile |
| Logging | `nestjs-pino` | 5.2.0 | Tích hợp logger vào NestJS | Mặc định của profile |
| Logging | `pino` | 10.3.1 | Log JSON có cấu trúc | Mặc định của profile |
| Logging | `pino-http` | 11.0.0 | Log request kèm correlation ID | Mặc định của profile |
| Cấu hình | `dotenv` | 18.0.2 | Nạp biến môi trường cho CLI Prisma và lúc khởi động | Mặc định của profile |
| Test | `vitest`, `@vitest/coverage-v8` | 4.1.11 | Chạy test và đo coverage; dòng 4.1 là dòng scaffold của NestJS 12 dùng | Mặc định của profile |
| Test | `vite-tsconfig-paths` | 5.1.4 | Phân giải alias của `tsconfig.json` khi chạy test | Mặc định của profile |
| Test | `supertest` | 7.2.2 | Gửi request HTTP trong e2e | Mặc định của profile |
| Test | `@types/supertest` | 7.2.1 | Kiểu cho `supertest` | Mặc định của profile |
| Test | `@testcontainers/postgresql` | 12.1.0 | PostgreSQL chạy cô lập cho integration, e2e, `CONC` | Mặc định của profile |
| Lint | `oxlint` | 1.85.0 | Lint | Mặc định của profile |
| Lint | `oxlint-tsgolint` | 7.0.2002 | Rule cần thông tin kiểu (`--type-aware`) | Mặc định của profile |
| Định dạng | `prettier` | 3.9.8 | Định dạng mã | Mặc định của profile |
| Tài liệu API | `@redocly/cli` | 2.54.0 | Kiểm tra `openapi/openapi.yaml` theo bộ quy tắc `recommended`, cấu hình ở `redocly.yaml` | Mặc định của profile |
| Ghi đè dependency | `deepmerge-ts`, `mysql2` (khối `overrides` của `package.json`) | 8.0.2, 3.24.4 | Vá lỗ hổng mức high trong dependency mà `prisma` 7.10.0 ghim; bỏ khi Prisma phát hành bản đã vá | Mặc định của profile |
| Kiểu | `@types/node`, `@types/express` | 24.13.6, 5.0.6 | Kiểu cho Node.js 24 và Express | Mặc định của profile |
| Hỗ trợ | `source-map-support` | 0.5.21 | Stack trace theo mã nguồn TypeScript | Mặc định của profile |

## 3. Giá trị placeholder

| Placeholder | Giá trị |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | TypeScript bật `strict` và `noUncheckedIndexedAccess`; cấm kiểu `any` (oxlint `typescript/no-explicit-any` mức error). |
| `{{ISOLATION_LEVEL}}` | `READ COMMITTED` |
| `{{CODEGEN_CMD}}` | `npx prisma generate` |
| `{{LINT_CMD}}` | `npx oxlint --type-aware --deny-warnings src/ test/` |
| `{{TYPECHECK_CMD}}` | `npx tsc --noEmit -p tsconfig.json` |
| `{{UNIT_TEST_CMD}}` | `npx vitest run --project unit` |
| `{{INTEGRATION_TEST_CMD}}` | `npx vitest run --project integration` |
| `{{E2E_TEST_CMD}}` | `npx vitest run --project e2e` |
| `{{COVERAGE_CMD}}` | `npx vitest run --project unit --coverage` |
| `{{BUILD_CMD}}` | `npx nest build` |
| `{{AUDIT_CMD}}` | `npm audit --audit-level=high` |
| `{{MIGRATION_CHECK_CMD}}` | `npx prisma validate && npx prisma migrate diff --from-migrations prisma/migrations --to-schema prisma/schema.prisma --exit-code` |
| `{{MIGRATION_DEPLOY_CMD}}` | `npx prisma migrate deploy` |
| `{{OPENAPI_LINT_CMD}}` | `npx redocly lint openapi/openapi.yaml` |

Ghi chú:

- Prisma Client không được commit và Prisma 7 không tự sinh client khi cài package, nên `{{CODEGEN_CMD}}` chạy đầu tiên trên máy mới, trong CI, trong bước build container image (trước `{{BUILD_CMD}}`) và sau mỗi lần sửa `prisma/schema.prisma`.
- `migrate diff --from-migrations` cần shadow database (`SHADOW_DATABASE_URL`, chỉ ở dev và CI). `prisma.config.ts` đọc biến môi trường bằng `process.env` để `prisma generate` và `migrate deploy` chạy được khi biến không liên quan vắng mặt.
- `npx prisma` dùng bản cài cục bộ; không chạy `npx prisma` ở nơi chưa cài package vì npx sẽ tải bản mới nhất từ registry.
- `prisma` 7.10.0 ghim `deepmerge-ts` 7.1.5 và `mysql2` 3.15.3, hai bản có lỗ hổng mức high làm `{{AUDIT_CMD}}` thất bại. `package.json` ghi `"overrides": { "deepmerge-ts": "8.0.2", "mysql2": "3.24.4" }`; đã chạy thử `prisma validate`, `generate`, `migrate dev`, `migrate deploy`, `migrate diff` với hai bản ghi đè.
- `redocly.yaml` ở gốc dự án gồm `extends: [recommended]` và `telemetry: off`, để lệnh kiểm tra tài liệu OpenAPI không gửi dữ liệu sử dụng ra ngoài.
- Ngưỡng coverage mặc định của profile là 80% cho `src/modules/**/*.service.ts`; SRS có thể đặt ngưỡng khác ở NFR-MAINT.

## 4. Nội dung chèn vào tài liệu (Profile Content)

### 4.1. Cây thư mục và cấu hình công cụ (cho ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Cây thư mục theo stack (Stack Directory Tree)

```text
.
├── prisma/
│   ├── schema.prisma                    # nguồn chân lý của schema
│   └── migrations/                      # migration do prisma migrate sinh, không sửa sau khi đã chạy
├── prisma.config.ts                     # đường dẫn schema, migration, datasource, shadow database
├── openapi/openapi.yaml                 # tài liệu OpenAPI 3.1 đầy đủ, gộp từ fragment của các SPEC
├── src/
│   ├── main.ts                          # khởi tạo ứng dụng, global pipe, filter, logger
│   ├── app.module.ts                    # module gốc, đăng ký mọi module phân hệ
│   ├── config/
│   │   ├── config.module.ts             # nơi duy nhất đọc biến môi trường
│   │   └── env.schema.ts                # schema Zod cho biến môi trường
│   ├── generated/prisma/                # Prisma Client sinh bởi prisma generate, không sửa, không commit
│   ├── modules/
│   │   └── {{MODULE_SLUG}}/
│   │       ├── {{MODULE_SLUG}}.module.ts
│   │       ├── {{MODULE_SLUG}}.controller.ts
│   │       ├── {{MODULE_SLUG}}.service.ts
│   │       ├── {{MODULE_SLUG}}.repository.ts
│   │       ├── dto/                     # schema Zod request và kiểu response
│   │       ├── entities/                # kiểu miền của phân hệ
│   │       └── tests/
│   │           ├── {{MODULE_SLUG}}.service.spec.ts
│   │           ├── {{MODULE_SLUG}}.repository.int-spec.ts
│   │           ├── {{MODULE_SLUG}}.e2e-spec.ts
│   │           └── {{MODULE_SLUG}}.conc-spec.ts
│   ├── shared/
│   │   ├── constants/error-codes.ts     # hằng số của Error Code Registry
│   │   ├── errors/                      # lớp lỗi nghiệp vụ mang error code
│   │   ├── filters/                     # exception filter map lỗi sang envelope
│   │   ├── guards/                      # guard xác thực, phân quyền, giới hạn tần suất
│   │   ├── interceptors/                # bọc envelope thành công, correlation ID
│   │   └── pipes/zod-validation.pipe.ts
│   └── infrastructure/
│       └── database/prisma.service.ts   # PrismaClient dùng adapter pg, inject vào repository
├── test/setup/postgres.ts               # global setup khởi động PostgreSQL bằng Testcontainers
├── vitest.config.ts
├── .oxlintrc.json
├── tsconfig.json
├── .env.example                         # chỉ tên biến và giá trị giả
└── package.json                         # "type": "module"
```

<!-- fill: Lặp nhánh modules/{{MODULE_SLUG}} cho mỗi phân hệ ở §4.1; chỉ giữ file test mà phân hệ thật sự có. Mỗi hành động có một file DTO request riêng trong dto/, đặt tên <action>-<module>.request.ts. Thêm vào infrastructure/ client của hệ thống ngoài mà dự án dùng (email, storage, API bên thứ ba), mỗi hệ thống một thư mục. -->

File Diff mặc định khi SPEC tạo phân hệ mới: mọi file của nhánh module tương ứng trong `src/modules/` ở trên, thêm dòng đăng ký module trong `src/app.module.ts`, mã lỗi mới trong `src/shared/constants/error-codes.ts`, path mới trong `openapi/openapi.yaml`, và migration trong `prisma/migrations/` nếu đổi schema.

Cấu hình test: một `vitest.config.ts` với ba project; project `integration` và `e2e` chạy tuần tự từng file vì dùng chung một PostgreSQL container.

```typescript
import { defineConfig } from "vitest/config";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    coverage: {
      provider: "v8",
      include: ["src/modules/**/*.service.ts"],
      thresholds: { lines: 80, branches: 80 },
    },
    projects: [
      { extends: true, test: { name: "unit", include: ["src/**/*.spec.ts", "test/**/*.spec.ts"] } },
      {
        extends: true,
        test: { name: "integration", include: ["src/**/*.int-spec.ts"], fileParallelism: false, globalSetup: ["test/setup/postgres.ts"] },
      },
      {
        extends: true,
        test: {
          name: "e2e",
          include: ["src/**/*.e2e-spec.ts", "src/**/*.conc-spec.ts", "test/**/*.e2e-spec.ts"],
          fileParallelism: false,
          globalSetup: ["test/setup/postgres.ts"],
        },
      },
    ],
  },
});
```

Cấu hình lint (`.oxlintrc.json`):

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "ignorePatterns": ["dist/**", "src/generated/**", "coverage/**"],
  "rules": {
    "typescript/no-explicit-any": "error",
    "typescript/no-floating-promises": "error"
  },
  "env": { "node": true }
}
```
<!-- /PROFILE-CONTENT -->

### 4.2. Schema Prisma (cho ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Quy ước schema Prisma (Prisma Schema Conventions)

Khối generator và datasource theo Prisma 7; URL kết nối nằm trong `prisma.config.ts`, không nằm trong schema. `moduleFormat = "esm"` khớp dự án NestJS 12 dạng ES module; client sinh ra import bằng đuôi `.js`, tương thích `module: nodenext`.

```prisma
generator client {
  provider     = "prisma-client"
  output       = "../src/generated/prisma"
  moduleFormat = "esm"
}

datasource db {
  provider = "postgresql"
}
```

```typescript
import { config } from "dotenv";
import { defineConfig } from "prisma/config";

config({ quiet: true });

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations" },
  datasource: {
    url: process.env["DATABASE_URL"],
    shadowDatabaseUrl: process.env["SHADOW_DATABASE_URL"],
  },
});
```

| Khái niệm | Cách viết trong Prisma |
| --- | --- |
| Tên model và bảng | Model `PascalCase` số ít, `@@map("snake_case_plural")` |
| Tên trường và cột | Trường `camelCase`, `@map("snake_case")` |
| Khóa chính UUIDv7 | `id String @id @default(uuid(7)) @db.Uuid`; UUIDv4 dùng `@default(uuid())` |
| Chuỗi | `String @db.VarChar(n)` với độ dài tối đa khớp validate; `@db.Text` chỉ khi không có giới hạn nghiệp vụ |
| Tiền tệ | `Decimal @db.Decimal(12, 2)` |
| Thời gian | `DateTime @db.Timestamptz(3)`; `createdAt DateTime @default(now()) @map("created_at") @db.Timestamptz(3)`; `updatedAt DateTime @updatedAt @map("updated_at") @db.Timestamptz(3)` |
| Xóa mềm | `deletedAt DateTime? @map("deleted_at") @db.Timestamptz(3)` |
| Khóa ngoại | `@relation(fields: [xId], references: [id], onDelete: Restrict)` kèm `@@index([xId])` |
| Duy nhất ghép | `@@unique([fieldA, fieldB])` |
| Enum | `enum` với giá trị `UPPER_SNAKE`, khớp SRS §4.2 |
| Ràng buộc kiểm tra | Prisma schema không khai báo được `CHECK`: tạo migration bằng `prisma migrate dev --create-only`, thêm câu SQL vào file vừa sinh, rồi mới áp dụng; ghi trong SPEC §4 |

Truy cập dữ liệu:

- `PrismaService` trong `src/infrastructure/database/` kế thừa `PrismaClient` với `adapter: new PrismaPg({ connectionString })` và được inject vào repository; service không gọi Prisma trực tiếp.
- Transaction: `prisma.$transaction(async (tx) => { ... }, { isolationLevel })`, mở ở service và truyền `tx` xuống repository.
- Cập nhật nguyên tử có điều kiện: `updateMany({ where: { id, field: { gte: amount } }, data: { field: { decrement: amount } } })`, kiểm tra `count` bằng 1; `count` bằng 0 nghĩa là điều kiện không thỏa.
- Khóa theo khóa nghiệp vụ trong transaction (ví dụ tuần tự hóa request cùng khóa idempotency): `` tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtextextended(${key}, 0))` ``; khóa tự nhả khi transaction kết thúc. Tham số truyền qua tagged template nên đã tham số hóa.
<!-- /PROFILE-CONTENT -->

### 4.3. Quy ước giao tiếp của stack (cho ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Hiện thực quy ước theo stack (Stack Implementation Notes)

- Import tương đối trong mã nguồn ghi đuôi `.js` (ví dụ `./{{MODULE_SLUG}}.service.js`) vì dự án dùng `module: nodenext`.
- Validate request bằng `ZodValidationPipe` dùng chung trong `src/shared/pipes/`; controller gắn pipe với schema của từng DTO: `@Body(new ZodValidationPipe(Schema)) body: Request`.
- Exception filter toàn cục trong `src/shared/filters/` map mọi lỗi sang envelope §6.2: lỗi nghiệp vụ mang mã trong §7.1; lỗi validate thành `VALIDATION_ERROR` kèm `details`; `HttpException` của framework map theo HTTP status bằng bảng ánh xạ ở trên (ví dụ `ThrottlerException` thành `429 RATE_LIMITED`, giữ header `Retry-After`); lỗi không lường trước thành `INTERNAL_ERROR` và được log đầy đủ.
- Giới hạn tần suất: dùng guard kế thừa `ThrottlerGuard` trong `src/shared/guards/`.
  - Header: `@nestjs/throttler` mặc định ghi `X-RateLimit-*`; guard đặt `protected headerPrefix = "RateLimit"` để phát `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`. Giữ throttler tên `default`, vì throttler đặt tên khác thêm chính tên đó làm hậu tố của header.
  - Khóa đếm: guard override `getTracker`, trả `sub` của access token trên route đã xác thực và IP client trên route công khai (route nào cần khóa khác, như đăng nhập đếm theo IP và email, ghi ở SPEC). Mặc định throttler đếm theo `req.ip`.
  - IP client: `main.ts` gọi `app.set("trust proxy", ...)` với danh sách dải địa chỉ nội bộ của mọi proxy tin cậy: load balancer và server của bề mặt khác gọi API thay mặt người dùng (ví dụ server render của web, server này chỉ chuyển tiếp một địa chỉ client do load balancer của nó ghi); Express bỏ qua các địa chỉ tin cậy trong `X-Forwarded-For` để lấy IP client thật. Chỉ có một load balancer phía trước thì dùng `1`. Thiếu cấu hình này, `req.ip` là địa chỉ của proxy gần nhất và mọi client đi qua proxy đó dùng chung một bộ đếm.

```typescript
import { Injectable, type PipeTransform } from "@nestjs/common";
import type { ZodType } from "zod";
import { ValidationError } from "../errors/validation.error.js";

@Injectable()
export class ZodValidationPipe implements PipeTransform {
  constructor(private readonly schema: ZodType) {}

  transform(value: unknown): unknown {
    const result = this.schema.safeParse(value);
    if (!result.success) {
      throw new ValidationError(
        result.error.issues.map((issue) => ({ field: issue.path.join("."), issue: issue.message })),
      );
    }
    return result.data;
  }
}
```
<!-- /PROFILE-CONTENT -->

### 4.4. Khuôn DTO (cho SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Schema DTO với Zod (Zod DTO Schema)

Tên schema theo hành động và tài nguyên; kiểu suy ra bằng `z.infer`, không khai báo lặp. Controller dùng `ZodValidationPipe` ở ARCHITECTURE §7.

<!-- fill: Thay khối mẫu dưới đây bằng schema request và kiểu response thật của endpoint. -->

```typescript
import { z } from "zod";

export const CreateResourceRequestSchema = z.strictObject({
  title: z.string().trim().min(1).max(200),
});
export type CreateResourceRequest = z.infer<typeof CreateResourceRequestSchema>;

export interface ResourceResponse {
  id: string;
  createdAt: string; // ISO 8601 UTC
}
```
<!-- /PROFILE-CONTENT -->

### 4.5. Công cụ test (cho SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Công cụ và vị trí test theo stack (Stack Test Tooling)

| TYPE | Công cụ | File | Project Vitest |
| --- | --- | --- | --- |
| `UNIT` | Vitest, `Test.createTestingModule` với repository mock bằng `vi.fn()` | `src/modules/{{MODULE_SLUG}}/tests/*.service.spec.ts` | `unit` |
| `INT` | Vitest, `@testcontainers/postgresql`, `prisma migrate deploy` lên container | `*.int-spec.ts` | `integration` |
| `E2E` | Vitest, Supertest, ứng dụng Nest thật, Testcontainers | `*.e2e-spec.ts` | `e2e` |
| `CTR` | Như `E2E`, parse response thật bằng schema Zod strict viết theo schema tương ứng trong `openapi/openapi.yaml`; thư viện kiểm OpenAPI riêng cần ADR | `*.e2e-spec.ts` | `e2e` |
| `CONC` | Vitest, Supertest, `Promise.all` gửi N request, truy vấn Prisma để khẳng định bất biến | `*.conc-spec.ts` | `e2e` |
| `LOAD` | Công cụ chọn bằng ADR khi SPEC cần | Ngoài `src/` | Không thuộc Vitest |

Tên test trong `it(...)` mô tả hành vi bằng tiếng Anh, ví dụ `it("rejects a request without a bearer token", ...)`; không chứa TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Quy ước riêng của stack (Stack Conventions)

- `tsconfig.json` theo scaffold của NestJS 12 (`module` và `moduleResolution` là `nodenext`, `experimentalDecorators`, `emitDecoratorMetadata`), thêm `strict: true` và `noUncheckedIndexedAccess: true`.
- Module phân hệ đăng ký trong `src/app.module.ts`; module khác chỉ dùng provider được `exports`.
- `nestjs-pino` sinh hoặc nhận correlation ID từ header `x-request-id`, gắn vào mọi bản ghi log.
- `dotenv` 18 in thông báo khi nạp biến; gọi `config({ quiet: true })` như trong `prisma.config.ts`.

## 6. Khởi tạo dự án (Project Setup)

1. `npx @nestjs/cli@12.0.3 new <tên> --skip-git --package-manager npm --no-observe` (ESM, Vitest, oxlint là mặc định).
2. Cài thư viện với phiên bản chính xác ở mục 2, ví dụ `npm install --save-exact prisma@7.10.0 @prisma/client@7.10.0 @prisma/adapter-pg@7.10.0 zod@4.6.5 dotenv@18.0.2 @nestjs/jwt@12.0.2 @nestjs/throttler@6.7.0 argon2@0.45.1 nestjs-pino@5.2.0 pino@10.3.1 pino-http@11.0.0` và `npm install --save-exact --save-dev @testcontainers/postgresql@12.1.0 @redocly/cli@2.54.0`; ghim các devDependency scaffold sinh ra về đúng phiên bản ở mục 2.
3. Hai sửa lỗi cho file mẫu của scaffold: test e2e mẫu import `supertest/types` không có đuôi, lỗi TS2307 dưới `nodenext`, sửa thành `supertest/types.js`; spec mẫu dùng `describe` toàn cục nên cần `globals: true` như cấu hình ở mục 4.1.
4. Thay `vitest.config.ts`, `vitest.config.e2e.ts` và `.oxlintrc.json` của scaffold bằng cấu hình ở mục 4.1, rồi sửa script `test:e2e` trong `package.json` thành `vitest run --project e2e`; tạo `prisma/schema.prisma` và `prisma.config.ts` theo mục 4.2; chạy `npx prisma generate`.
5. Scaffold thêm devDependency `@nestjs/mau` và script `deploy` cho nền tảng NestJS Mau; gói này kéo theo dependency có lỗ hổng mức high. Dự án triển khai bằng container theo ARCHITECTURE §8 thì gỡ cả hai; dùng NestJS Mau thì ghi ADR.
6. Thêm khối `overrides` và `redocly.yaml` theo ghi chú ở mục 3; chạy `npm install` rồi `{{AUDIT_CMD}}`.
