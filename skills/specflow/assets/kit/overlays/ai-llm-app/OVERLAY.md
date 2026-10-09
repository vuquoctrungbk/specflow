---
doc_type: overlay
status: stable
version: 1.0.0
language: en
surface: ai-llm-app
---

# Overlay ai-llm-app

## 1. Surface

Features built on a large language model (LLM): classification, extraction, summarization, answering from documents, agents that call tools. The model output is non-deterministic, can be wrong, or can be steered by the input data (prompt injection), and every call costs money. So a prompt is treated as a contract: each prompt has a Prompt Spec (`docs/prompts/PROMPT_<NAME>.md` following [Prompt_Spec_Template.md](Prompt_Spec_Template.md)) with the output schema, failure modes, guardrails and the eval thresholds on a dataset. An AI feature usually runs in a server-side service or worker; the screen or API that delivers the result to the user belongs to the overlay of that surface.

| Choose this overlay when | Do not choose when |
| --- | --- |
| The project calls a large language model to create or evaluate content, and the result affects users or data | AI is used only while coding (coding agent) and the product does not call a model; a self-trained traditional machine-learning model (no overlay yet, handle it per PLAYBOOK §3 rule 4) |

The `CONC` test pattern of this surface runs at integration level with a model provider simulated at the `fetch` layer: the same input is processed at the same time by two workers or two triggers, and the result is written only once; or several parallel calls share one token budget and the budget is not exceeded. Do not use sleep to order events.

Three test types are specific to this surface: `EVAL` runs the real prompt on a labeled dataset and compares with a threshold; `INJ` runs an attack dataset (prompt injection, requests that exceed permissions); `COST` measures tokens per call on the dataset. These three call a real model, so they run in a separate CI job when the prompt, input guard, model client, model or parameters change, and on a schedule, not on every commit.

## 2. Provided Slots

| Slot | File | Content | Has `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Provider and model family, structured output, non-determinism, latency, budget, data sent to the provider, human control | No |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Model provider API, vector store, tools the model may call, how AI results reach the user | No |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | Model input and output data, call log, eval datasets | No |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | Pipeline from input guard to post-processing, C4 Level 2, flow of one call with retry and fallback, deployment view | No |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Layering rules: prompt, model client, guard, eval dataset | Yes |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Structured output schema, call log record, dataset format | Yes |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Prompt and model parameter conventions, guardrails, error handling and fallback, budget, eval gate | Yes |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | API keys and limits per environment, token and cost monitoring, model upgrade, AI kill switch | No |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Prompts used, processing flow and decision table, budget, error mapping | Yes |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration with a simulated provider, `EVAL`, `INJ`, `COST`, `CONC` | Yes |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Verify command table | No |

## 3. Assembly Order

1. The stage's core files (`core/01`, `core/02`, `core/04`, `core/06`).
2. This file.
3. The section file that holds the matching SLOT-CONTENT block in the table in §2.
4. The stack profile chosen in the Intake: the "Placeholder values" table, the `(Tech Stack)` section and the PROFILE-CONTENT blocks.
5. The surface rules in `agent-rules/` when creating `.claude/rules/` (Stage 2).
6. Stage 1: the `PROMPT-{MOD}-NNN` ID of each prompt is set in the eval dataset table of SRS §4.1. Stage 3: each new prompt or prompt with changed content has a Prompt Spec from [Prompt_Spec_Template.md](Prompt_Spec_Template.md), approved before the SPEC that uses it is written (PLAYBOOK §2.4).

Detailed assembly rules are in CONVENTIONS §2 and PLAYBOOK §4.

## 4. Stack Profiles

| Profile | Stack | File |
| --- | --- | --- |
| `typescript-anthropic-sdk` | TypeScript on Node.js, Anthropic TypeScript SDK with structured output via Zod, Vitest | [stack-profiles/typescript-anthropic-sdk.md](stack-profiles/typescript-anthropic-sdk.md) |

Other stacks have no profile yet (for example Python, another model provider): propose the placeholder values and the profile content in ARCHITECTURE §2 together with an ADR (PLAYBOOK §3, rule 5).

## 5. Combining with backend-api

An AI feature usually lives inside a backend. When the project chooses both `backend-api` and `ai-llm-app` in the same repo:

- The directory tree, the Vitest and oxlint configuration, and the verify commands come from the backend profile; the model client, prompt modules, guards and output schemas go in the backend's module directory according to the layering rules of both overlays.
- The `arch.layout` PROFILE-SLOT block of `ai-llm-app` is N/A with the reason "use the directory tree of the backend profile"; `arch.schema`, `arch.conventions`, `spec.contract`, `spec.test-types` of the AI profile are still inserted, with paths changed to follow the backend's tree.
- Add an `eval` project to the backend's Vitest configuration for the `EVAL`, `INJ`, `COST` tests, and add a prompt eval row to the verify command table; the project has only one verify command table.
- Error codes of both surfaces share one Error Code Registry; the code of an AI task is returned to the client through the backend's envelope when the task runs inside a request.

## 6. Agent Rules

| File | Copy as | Applies to |
| --- | --- | --- |
| [agent-rules/ai-golden-rules.md](agent-rules/ai-golden-rules.md) | `.claude/rules/ai-golden-rules.md` | Model-calling code, prompts, guards and eval datasets (`paths` follow the directory tree in ARCHITECTURE §4) |

## 7. Surface Checklist

Self-check together with the "Overlay applied" checklist in PLAYBOOK §4.

| Check | Document | Passed |
| --- | --- | :---: |
| Each AI feature has a measurable quality threshold on a dataset, a token budget and latency, and a behavior for when the model is wrong or unavailable | SRS §2.5, §7 | [ ] |
| Data sent to the model provider is listed; personal data is masked or has a legal basis; the provider's data retention policy is recorded | SRS §3, §4; ARCHITECTURE §9 | [ ] |
| The exact model ID is in ARCHITECTURE §2.1 and covered by an ADR; a model upgrade goes through the eval gate | ARCHITECTURE §2, §8, §12 | [ ] |
| Each prompt has a Prompt Spec with output schema, failure modes, guardrails, eval metric and threshold | `docs/prompts/` | [ ] |
| Model output always passes the schema and business rules before use; invalid output has a fallback path | ARCHITECTURE §7; SPEC §3 | [ ] |
| The eval dataset has at least 20 samples and contains no real personal data; there is an attack dataset for prompts that receive untrusted content | SRS §4; Prompt Spec | [ ] |
| The SPEC has `EVAL`, `INJ`, `COST` tests per the Prompt Spec and a `CONC` test for each invariant | SPEC §9 | [ ] |
