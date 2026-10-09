---
doc_type: overlay-section
status: stable
version: 1.1.0
language: en
surface: backend-api
---

# Overlay backend-api: blocks for the SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Endpoint

<!-- fill: One table for each endpoint of the feature. -->

| Item | Value |
| --- | --- |
| Method and path | <!-- fill: choose one: GET \| POST \| PATCH \| PUT \| DELETE --> `/api/v1/{{RESOURCE_PATH}}` |
| Authentication | <!-- fill: Bearer token per ARCHITECTURE §6.1, or "No" for a public endpoint --> |
| Authorization | <!-- fill: roles allowed, matching §6 --> |
| Required headers | `Content-Type: application/json`<!-- fill: add `Idempotency-Key` if the write operation is not naturally idempotent --> |
| Rate limit | <!-- fill: limit per ARCHITECTURE §9.1 --> |
| Success code | <!-- fill: for example 201 on create, 200 when replaying the same Idempotency-Key --> |

### Request & Response DTO

- The request is validated at the boundary with a runtime schema before it enters the service; unknown fields are rejected; a validation error returns `VALIDATION_ERROR` with the list of fields in `error.details`.
- Computed values (price, total, permissions) are not accepted from the request; the service computes them from the source of truth.
- The response contains only declared fields; MUST NOT return internal fields (hashes, unnecessary foreign keys, personal data the client does not need).

<!-- PROFILE-SLOT: spec.contract -->

<!-- fill: Write the real request schema and response type of the endpoint following the pattern above. -->

### Success Response

<!-- fill: One JSON example in the ARCHITECTURE §6.2 envelope, example values matching the DTO. -->

### Error Matrix

| HTTP status | `error.code` | Triggering scenario | `error.details` |
| --- | --- | --- | --- |
| `400` | `VALIDATION_ERROR` | Request does not match the schema | List of `{ field, issue }` |
| `401` | `UNAUTHENTICATED` | Token missing, expired or with a wrong signature | None |
| `403` | `FORBIDDEN` | Authenticated but the role is not allowed | None |
| `429` | `RATE_LIMITED` | Rate limit exceeded | None; `Retry-After` header |
| <!-- fill: status per ARCHITECTURE §7 --> | <!-- fill: business code present in ARCHITECTURE §7.1 --> | <!-- fill --> | <!-- fill --> |

### OpenAPI Fragment

<!-- fill: Replace this line with a line that starts with "Companion file:" per CONVENTIONS §7, pointing to the file next to this SPEC whose name is the SPEC file name without the .md extension plus ".openapi.yaml", with the list of operationIds of the fragment. Create that file from the template specflow/overlays/backend-api/spec-openapi-fragment-template.yaml. The fragment is enough to generate a client and run contract tests: path and method matching the Endpoint table, camelCase operationId, security, requestBody with a real schema, every response in the error matrix, the success response and the error responses carry the schema of the envelope (declared in components), each kind of element of `error.details` has clearly declared properties so a client can generate the type. When implemented, the SPEC merges the fragment into openapi/openapi.yaml, and this file is in the File Diff. -->
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Surface Test Types

| Type | TYPE in the TC ID | Scope | Data | Required |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Service with the repository and adapters mocked | In memory | Yes |
| Integration | `INT` | Repository and queries on a real database running in isolation | A database created for the run | Yes when the SPEC has a new query |
| E2E | `E2E` | HTTP request through the whole application to the database | A database created for the run | Yes |
| Contract | `CTR` | Real response compared with the OpenAPI fragment in §3 | Same as E2E | Yes when the endpoint is used by another client |
| Concurrency | `CONC` | The invariant in §1.2 under parallel requests | Real database | Yes, one test per invariant in §1.2 |
| Load smoke | `LOAD` | Quick latency measurement against NFR-PERF | Staging environment | When the SPEC touches a hot path of NFR-PERF |

### Concurrency Test Pattern

1. Prepare a state that limits the resource (for example the remaining quantity is smaller than the number of requests).
2. Send N parallel requests (N ≥ 10) to the same resource, wait for all of them to finish.
3. Count the responses by code and query the database to assert the invariant (non-negative, no duplicates, totals match).
4. Do not mock the storage layer; do not use sleep to order the requests.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
