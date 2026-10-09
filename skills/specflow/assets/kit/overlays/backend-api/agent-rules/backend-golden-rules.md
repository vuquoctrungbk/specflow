---
doc_type: agent-rule
status: draft
version: 0.1.0
template_version: 1.0.0
language: en
paths: ["{{SOURCE_GLOB}}"]
parent: [docs/ARCHITECTURE.md]
overlays: [backend-api]
assembled_from: []
---

# Backend Golden Rules

<!-- fill: Copy to .claude/rules/backend-golden-rules.md at Stage 2. paths lists the backend source directories per ARCHITECTURE §4, one glob per element. assembled_from records "overlays/backend-api/agent-rules/backend-golden-rules.md@<template_version>" and the stack profile used. -->

- Separate the layers: the controller only receives the request, validates with a runtime schema, calls the service and maps the response; MUST NOT import the ORM client or a repository into a controller.
- Open the transaction in the service; the repository receives the transaction client from the service and does not open a transaction itself.
- Keep invariants under concurrent operations in the database with a conditional atomic update, a unique constraint, or a lock taken inside the transaction before the check step; MUST NOT check-then-write at the application layer without holding that lock.
- Every response follows the ARCHITECTURE §6.2 envelope; every error carries a code present in ARCHITECTURE §7.1 and an HTTP status per the mapping table in ARCHITECTURE §7.
- {{LANGUAGE_STRICT_MODE_RULE}}
- Do not trust computed values from the client (price, amount, permissions, status); the service recomputes them from the database.
- Generate migrations only with the stack's tool; do not edit a migration that has already run; every schema change comes with a migration in the File Diff.
- Log through a structured logger with a correlation ID; do not log secrets, tokens, passwords, unmasked personal data.
