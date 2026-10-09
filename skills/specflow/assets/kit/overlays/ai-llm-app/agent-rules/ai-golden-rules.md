---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.0.0
language: en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [ai-llm-app]
assembled_from: []
---

# AI Golden Rules

<!-- fill: Copy to .claude/rules/ai-golden-rules.md at Stage 2. paths lists the prompt directory, the model client, the guards, every test directory (unit, integration, evaluation, fakes) and the datasets per ARCHITECTURE §4, one glob per element. assembled_from records "overlays/ai-llm-app/agent-rules/ai-golden-rules.md@<template_version>" and the stack profile used. -->

- Only the model client calls the provider SDK; agent MUST NOT call a model from anywhere else in the code.
- Each prompt is a module that copies the approved Prompt Spec exactly, with a version constant equal to the `version` of the Prompt Spec. Agent MUST NOT change the prompt, the examples, the output schema, the model or the parameters away from the Prompt Spec; when a change is needed, stop and propose a Prompt Spec change per PLAYBOOK §8.
- Model output always passes the schema and the business rules before use; agent MUST NOT extract JSON from free text or guess-repair invalid output.
- Untrusted content sits only inside the delimiter tag pair that the system prompt declares as data; the input guard replaces angle brackets in the content so that it cannot open or close the delimiter tags. Agent MUST NOT concatenate untrusted content into the instruction part.
- Mask personal data before sending it to the provider per SRS §2.5; agent MUST NOT put secrets in prompts, logs or error messages.
- Use exactly the model ID and parameters in ARCHITECTURE §2.1 and the Prompt Spec; changing the model needs an ADR.
- The evaluation dataset holds only synthetic samples or samples anonymized irreversibly; agent MUST NOT edit the expected labels to make an evaluation test pass.
- Unit and integration tests do not call a real model; the real model runs only in the evaluation project.
- {{LANGUAGE_STRICT_MODE_RULE}}
