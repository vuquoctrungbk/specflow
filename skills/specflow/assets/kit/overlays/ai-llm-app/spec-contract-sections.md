---
doc_type: overlay-section
status: stable
version: 1.0.1
language: en
surface: ai-llm-app
---

# Overlay ai-llm-app: blocks for the SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Prompts Used

<!-- fill: One row per prompt that the feature calls; the Prompt Spec has to be at status approved before Gate 3. The prompt text, output schema, failure modes and eval thresholds live in the Prompt Spec, do not copy them here. -->

| Prompt ID | Version | File | Model | Purpose |
| --- | --- | --- | --- | --- |
| `PROMPT-{{MODULE_CODE}}-001` | <!-- fill: version of the Prompt Spec --> | <!-- fill: path of the Prompt Spec in inline code --> | <!-- fill: model ID per ARCHITECTURE §2.1 --> | <!-- fill --> |

### Model Processing Flow

| Step | Input | Processing | Output |
| --- | --- | --- | --- |
| Get input | <!-- fill: source and fields --> | <!-- fill: input guard --> | <!-- fill --> |
| Call the model | <!-- fill --> | Model client with the parameters of the Prompt Spec | A schema-checked result, or an error code |
| Decide | <!-- fill --> | <!-- fill: business rules, confidence threshold --> | <!-- fill: use the result or the fallback --> |
| Write the result | <!-- fill --> | <!-- fill: conditional write so nothing is written twice --> | <!-- fill --> |

### Decision Table

| Condition | Action | Written to the log | AC |
| --- | --- | --- | --- |
| Valid output, confidence at or above the threshold | <!-- fill --> | Result, prompt version, tokens | AC-{{MODULE_CODE}}-01 |
| Valid output, confidence below the threshold | <!-- fill: send to a reviewer --> | As above, plus `LOW_CONFIDENCE` | AC-{{MODULE_CODE}}-01 |
| Invalid output | <!-- fill: fallback --> | `OUTPUT_INVALID` | AC-{{MODULE_CODE}}-01 |
| Model unavailable after retries | <!-- fill: fallback --> | `MODEL_UNAVAILABLE` | AC-{{MODULE_CODE}}-01 |

### Budget & Limits

| Item | Value |
| --- | --- |
| Maximum tokens per call | <!-- fill: max_tokens of the Prompt Spec; maximum input tokens after the input guard --> |
| Timeout, retry count and call deadline | <!-- fill: timeout per attempt, maximum retry count, deadline for the whole call including retries --> |
| Average tokens per call on the dataset | <!-- fill: threshold of the COST test --> |

<!-- PROFILE-SLOT: spec.contract -->

### Error Mapping

<!-- fill: Every error code that the feature produces or receives from external systems; the code is in ARCHITECTURE §7.1. -->

| Code | Source | Behavior | What the user sees |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: choose one: model \| guard \| external system --> | <!-- fill --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Surface Test Types

| Type | TYPE in TC ID | Scope | Data | Required |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Input and output guards, prompt assembly, decision rules | In memory | Yes |
| Integration | `INT` | The real model client with a provider simulated at the `fetch` layer: valid output, invalid output, overload, network error | Simulated responses matching the provider API | Yes |
| Evaluation | `EVAL` | The real prompt and model on a labeled dataset, repeated per the Prompt Spec | Eval dataset | Yes, per prompt |
| Prompt attack | `INJ` | Input that tries to change instructions, leak the system prompt or call tools beyond permissions | Attack dataset | Yes when the prompt receives untrusted content |
| Cost | `COST` | Average tokens per call on the dataset against the budget | Same as `EVAL` | Yes, per prompt |
| Concurrency | `CONC` | The invariant in §1.2 when the same input is processed in parallel or several calls share a budget | Simulated provider and target system | Yes, one test per invariant in §1.2 |

### Concurrency Test Pattern

1. Simulate the model provider at the `fetch` layer and simulate a target system with a conditional write (version or idempotency key).
2. Have two workers, or two triggers of the same worker, process the same set of inputs at the same time; the target system has enough latency for the two runs to overlap.
3. Assert that each input has only one result written, that the number of model calls does not exceed the number of inputs times the number of workers, and that total tokens do not exceed the budget of the run.
4. Do not use sleep to order events; the order is driven by the latency of the simulation.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
