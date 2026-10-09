---
doc_type: profile
status: stable
version: 1.0.0
language: en
surface: ai-llm-app
profile: typescript-anthropic-sdk
---

# Stack profile typescript-anthropic-sdk

## 1. Scope

An AI feature written in TypeScript on Node.js as ES modules, calling Claude models through the Anthropic TypeScript SDK with structured output generated from a Zod schema (`messages.create` with `output_config.format` from `zodOutputFormat`, then re-checked against the schema), tested with Vitest, linted with oxlint. The profile serves a worker or a server-side module. When the AI feature sits inside a backend that already has its own profile (for example `node-nestjs-prisma`), follow the "Combining with backend-api" section of `overlays/ai-llm-app/OVERLAY.md`: use the backend's directory tree, tool configuration and verify commands; this profile adds only the SDK, the model client, the evaluation test project and the evaluation command.

Versions pinned on 2026-09-22 and tried together on Node.js 24.21.0 with a trial project: typecheck, type-aware lint, unit test, integration test with a provider faked at the `fetch` layer (valid output, schema mismatch, truncation at `max_tokens`, low confidence, configuration error, overload and network error with retry, deadline of the call), the `CONC` test with two workers, build and `npm audit` all passed. The SDK 0.127.0 behavior that the client relies on was checked against the SDK source: the SDK retries `408`, `409`, `429`, `5xx` and network errors on its own, honours `retry-after` without an upper bound, and sends the provider only the shape of the schema, while enumerated domains, number ranges and lengths travel as descriptions. The evaluation test with a real model did not run in the environment where the profile was written because there was no API key; the evaluation command was checked to skip itself when the key is missing and to fail when `EVAL_REQUIRED=1`. Upgrade versions per the Dependency Policy in ARCHITECTURE §2.2.

## 2. Technology Table (Tech Stack)

Copy into ARCHITECTURE §2.1 with the Surface column set to `ai-llm-app` and the ADR column set to "Profile default" (only a deviation from the profile needs an ADR). The model ID is not part of the profile: choose it per task and record it as a separate row of §2.1 with an ADR.

| Layer | Technology | Exact version | Role | ADR |
| --- | --- | --- | --- | --- |
| Runtime | Node.js | 24.21.0 (LTS) | Runs the worker and the tools | Profile default |
| Language | TypeScript | 6.0.3 | Strict types, `module: nodenext`; same line as the backend profile | Profile default |
| Model SDK | `@anthropic-ai/sdk` | 0.127.0 | Messages API, structured output, built-in retry and timeout | Profile default |
| Validation | `zod` | 4.6.5 | Output schema (the source of the structured output format), environment variables, data from external systems | Profile default |
| Types | `@types/node` | 24.13.6 | Types for Node.js 24 | Profile default |
| Test | `vitest`, `@vitest/coverage-v8` | 4.1.11 | Unit, integration, evaluation, coverage; same line as the backend profile | Profile default |
| Lint | `oxlint`, `oxlint-tsgolint` | 1.85.0, 7.0.2002 | Lint, rules that need type information (`--type-aware`) | Profile default |

## 3. Placeholder values

| Placeholder | Value |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | TypeScript has `strict` and `noUncheckedIndexedAccess` on; the `any` type is forbidden (oxlint `typescript/no-explicit-any` at error level). |
| `{{CODEGEN_CMD}}` | `N/A: the profile has no generated client; the SDK types are built in and the output schema is written in Zod` |
| `{{LINT_CMD}}` | `npx oxlint --type-aware --deny-warnings src/ test/` |
| `{{TYPECHECK_CMD}}` | `npx tsc --noEmit` |
| `{{UNIT_TEST_CMD}}` | `npx vitest run --project unit` |
| `{{INTEGRATION_TEST_CMD}}` | `npx vitest run --project integration` |
| `{{E2E_TEST_CMD}}` | `N/A: the AI task runs in a worker or a server-side module and has no UI; end-to-end behavior is covered by integration tests and evaluation tests` |
| `{{EVAL_CMD}}` | `EVAL_REQUIRED=1 npx vitest run --project eval` |
| `{{COVERAGE_CMD}}` | `npx vitest run --project unit --project integration --coverage` |
| `{{BUILD_CMD}}` | `npx tsc -p tsconfig.build.json` |
| `{{AUDIT_CMD}}` | `npm audit --audit-level=high` |

Notes:

- `{{EVAL_CMD}}` calls a real model, needs `ANTHROPIC_API_KEY` (the key of the evaluation environment, with its own spending limit) and costs money in proportion to the number of samples times the number of runs; the command runs only in the CI evaluation job. `EVAL_REQUIRED=1` makes the command fail when the key is missing; run this command in the CI evaluation job when the prompt, the model or the parameters change, and on a schedule. Running `npx vitest run --project eval` without a key makes the test suite skip itself, which is usable on a developer machine.
- The profile default coverage threshold is 80% of lines and branches for `src/`, except `src/main.ts` and `src/config/`; the SRS may set another threshold at NFR-MAINT.
- When the project adds a client generated from OpenAPI (an external system with OpenAPI documentation), set `{{CODEGEN_CMD}}` per the matching backend or frontend profile.

## 4. Profile Content

### 4.1. Directory tree and tool configuration (for ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Stack Directory Tree

```text
.
├── evals/                               # evaluation and attack datasets, JSON Lines, one sample per line
├── src/
│   ├── main.ts                          # entry point: reads the configuration, starts the worker or server
│   ├── config/env.ts                    # the only place that reads environment variables, validated with Zod
│   ├── llm/model-client.ts              # the only module that calls the Anthropic SDK
│   ├── prompts/{{FEATURE_SLUG}}.ts       # one module per prompt, version constant equal to the Prompt Spec
│   ├── {{MODULE_SLUG}}/
│   │   ├── {{MODULE_SLUG}}.schema.ts    # Zod schema of the output
│   │   ├── guards.ts                    # input and output guards, pure functions
│   │   └── index.ts                     # business logic that uses the checked result
│   └── lib/
├── test/
│   ├── unit/                            # *.test.ts
│   ├── integration/                     # *.int.test.ts, provider faked at the fetch layer
│   ├── eval/                            # *.eval.test.ts, calls the real model
│   └── support/                         # fakes of the provider and of external systems
├── .oxlintrc.json
├── tsconfig.json                        # typecheck for both src and test, noEmit
├── tsconfig.build.json                  # build src into dist
├── vitest.config.ts
└── .env.example                         # variable names and fake values only
```

<!-- fill: Repeat the src/{{MODULE_SLUG}} branch for each module in §4.1 and the prompts/{{FEATURE_SLUG}}.ts file for each Prompt Spec; drop the directories that the project does not have. -->

Default File Diff when a SPEC adds an AI task: the prompt module in `src/prompts/`, the schema and guards in the module directory, tests in `test/unit/`, `test/integration/`, `test/eval/`, the dataset in `evals/`, the Prompt Spec in `docs/prompts/`.

Test configuration (`vitest.config.ts`): three projects; the `eval` project has a long timeout because it calls a real model.

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

Lint configuration (`.oxlintrc.json`):

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["typescript", "unicorn", "oxc", "import", "vitest"],
  "categories": { "correctness": "error", "suspicious": "warn" },
  "rules": { "typescript/no-explicit-any": "error" },
  "ignorePatterns": ["dist/**"]
}
```

`tsconfig.json`: `target` `ES2023`, `module` and `moduleResolution` `nodenext`, `strict`, `noUncheckedIndexedAccess`, `types: ["node"]`, `noEmit`, `include` has `src`, `test`, `vitest.config.ts`; relative imports carry the `.js` extension. `tsconfig.build.json` extends it, turns emit on, sets `rootDir: "src"`, `outDir: "dist"`, and `include` is only `src`.
<!-- /PROFILE-CONTENT -->

### 4.2. Output schema and model client (for ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Stack Schemas & Model Client

- The output schema is written in Zod; `zodOutputFormat(schema)` from `@anthropic-ai/sdk/helpers/zod` turns it into the structured output format sent with `messages.create`. The client reads the answer itself: a `stop_reason` other than `end_turn` (truncated at `max_tokens`, refusal), text that is not JSON, or text that fails `schema.safeParse` is `OUTPUT_INVALID`, and the tokens of the call are still returned. Do not use `messages.parse`: it throws when the output does not match the schema and loses the `usage` of a call that was already billed.
- The model client is the only module that creates `Anthropic`: `temperature` 0; a `timeout` per attempt, `maxRetries` and a deadline for the whole call (`AbortSignal.timeout`), because the SDK honours the provider's `retry-after`; `authToken`, `baseURL`, `logLevel` are passed explicitly so that the SDK does not read the matching `ANTHROPIC_*` variables itself (log level `debug` prints the request content too). The SDK still reads `ANTHROPIC_CUSTOM_HEADERS` and adds those headers after the authentication headers, so `src/config/env.ts` refuses to start when this variable is set, even empty. In a Zod 4 schema that key is `z.undefined({ error: "ANTHROPIC_CUSTOM_HEADERS must not be set" }).optional()`: without `.optional()` Zod requires the key to be present, and the worker cannot start in any environment that does not set the variable. Errors `400`, `401`, `402`, `403`, `404`, `413` are configuration errors (thrown); every other error left after retries, including an expired deadline, is `MODEL_UNAVAILABLE`.
- The client takes `fetch` as a parameter so that integration tests can swap in a fake provider.

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

### 4.3. Stack conventions (for ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Stack Implementation Notes

- Each prompt is a module that exports an `as const` constant holding `version` (equal to the `version` of the Prompt Spec), the system prompt string and the function that assembles the user message; untrusted content enters only the assembling function, between the delimiter tag pair.
- Default timeout is 20 seconds per attempt, 2 retries and a 60 second deadline for the whole call for background tasks; a task that a user is waiting on sets these values per NFR-PERF. Errors `400`, `401`, `402`, `403`, `404`, `413` are configuration or programming errors and do not switch to a fallback.
- `message.usage.input_tokens` and `output_tokens` of every call that got a response, even when the output is unusable, go into the log and into the returned result, so that the `COST` test and cost monitoring can read them.
- The API key is read only in `src/config/env.ts` and passed into the client; do not put the key or the full prompt content into logs.
- Variables in the Prompt Spec are written as a lowercase name wrapped in double curly braces; in code, they are parameters of the message assembling function.
<!-- /PROFILE-CONTENT -->

### 4.4. Output schema template (for SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Zod Output Schema

The schema matches Prompt Spec §5; enumerated domains are listed in full, strings have a maximum length. The type is inferred with `z.infer`.

<!-- fill: Replace the sample block below with the real output schema of the task. -->

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

### 4.5. Test tooling (for SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Stack Test Tooling

| TYPE | Tool | File | Run with |
| --- | --- | --- | --- |
| `UNIT` | Vitest | `test/unit/*.test.ts` | Vitest project `unit` |
| `INT` | Vitest, model client with a fake `fetch` that returns Messages API responses | `test/integration/*.int.test.ts` | Vitest project `integration` |
| `EVAL` | Vitest, real model, reads JSON Lines datasets in `evals/` | `test/eval/*.eval.test.ts` | Vitest project `eval` |
| `INJ` | Same as `EVAL`, attack dataset | `test/eval/*.eval.test.ts` | Vitest project `eval` |
| `COST` | Same as `EVAL`, sums the `usage` of every call | `test/eval/*.eval.test.ts` | Vitest project `eval` |
| `CONC` | Same as `INT`, fake target system with a conditional write | `test/integration/*.int.test.ts` | Vitest project `integration` |

The fake provider at the `fetch` layer (`test/support/fake-anthropic.ts`): each call returns the next response in the list (including network errors and the `retry-after` header), records the request body so that tests can check the masked data and the parameters, and returns a `400` error without retry when the scripted responses run out, so that a test that runs out of answers fails loudly.

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

An evaluation test starts with `describe.skipIf(!apiKey)`, and fails when `EVAL_REQUIRED=1` and the key is missing; each sample is read through the dataset's Zod schema. Tests import `describe`, `it`, `expect` from `vitest`. Test names describe behavior in English, for example `it("sends the ticket to review when the answer is not valid structured output", ...)`; they do not contain a TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Stack Conventions

- `package.json` has `"type": "module"`; relative imports carry the `.js` extension.
- Structured output uses `messages.create` with `output_config.format` from `zodOutputFormat`, and then the client checks `stop_reason` and the schema itself (§4.2); do not use `messages.parse`, and do not use tool use to force JSON when no real tool is needed.
- The evaluation datasets do not live in `src/` and are never imported into production code.
- Pin model IDs in the dated form (for example `claude-haiku-4-5-20251001`) when the provider offers it, so that evaluation results are tied to exactly one model version.

## 6. Project Setup

1. `npm init -y`, set `"type": "module"` in `package.json`.
2. `npm install --save-exact @anthropic-ai/sdk@0.127.0 zod@4.6.5` and `npm install --save-exact --save-dev typescript@6.0.3 @types/node@24.13.6 vitest@4.1.11 @vitest/coverage-v8@4.1.11 oxlint@1.85.0 oxlint-tsgolint@7.0.2002`.
3. Create `tsconfig.json`, `tsconfig.build.json`, `vitest.config.ts`, `.oxlintrc.json` per §4.1; create `src/config/env.ts`, `src/llm/model-client.ts` per §4.2 and `test/support/fake-anthropic.ts` per §4.5.
4. Add `dist/`, `coverage/` and the real env file to `.gitignore`; `.env.example` has only variable names and fake values.
5. Create a separate API key for the evaluation environment with a spending limit, and store it in the CI secret store under the name `ANTHROPIC_API_KEY`.
