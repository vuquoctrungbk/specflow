---
doc_type: overlay
status: stable
version: 1.0.0
language: en
surface: backend-api
---

# Overlay backend-api

## 1. Surface

Software that runs on the server side, provides an API over the network (REST over HTTPS is the default) and owns persistent data: business services, background jobs, integrations with external systems, webhooks.

| Choose this overlay when | Do not choose when |
| --- | --- |
| The project has an API for other clients to call, has its own database, has background jobs | The project only calls other parties' APIs and stores no data itself (see `frontend-web`, `mobile-app`) |

The `CONC` test pattern of this surface: send N parallel requests (N ≥ 10) to the same resource over HTTP, or call the service in parallel against a real database, then check the invariant with a direct query after every request has finished. Do not use a simulated database for `CONC` tests.

## 2. Provided Slots

| Slot | File | Content | Has `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Strict typing, transaction integrity, protocol, time (independent of the stack profile) | No |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Software and communications interfaces: API clients, third-party APIs, webhooks, object storage, email/SMS, identity | No |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | Crow's foot ERD and guidance for relational storage | No |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, Level 3, deployment view | No |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Layering rules in the directory tree | Yes |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Physical schema rules and schema in the DSL | Yes |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | HTTP API conventions, error code to HTTP mapping, transaction | Yes |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Packaging, migrations on deploy, release, rollback | No |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Endpoint, DTO, response, error matrix, OpenAPI 3.1 fragment in the companion file (template: `spec-openapi-fragment-template.yaml`) | Yes |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration, e2e, contract, `CONC`, load smoke | Yes |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Verify command table | No |

## 3. Assembly Order

1. The core files of the stage (`core/01`, `core/02`, `core/04`, `core/06`).
2. This file.
3. The section file that holds the matching SLOT-CONTENT block, per the table in §2.
4. The stack profile chosen in the Intake: the "Placeholder values" table, the `(Tech Stack)` section and the PROFILE-CONTENT blocks.
5. The rules of the surface in `agent-rules/` when creating `.claude/rules/` (Stage 2).

Detailed assembly rules are in CONVENTIONS §2 and PLAYBOOK §4.

## 4. Stack Profiles

| Profile | Stack | File |
| --- | --- | --- |
| `node-nestjs-prisma` | Node.js, NestJS, Prisma, PostgreSQL | [stack-profiles/node-nestjs-prisma.md](stack-profiles/node-nestjs-prisma.md) |
| `python-fastapi-sqlalchemy` | Python, FastAPI, SQLAlchemy 2 async, Alembic, PostgreSQL | [stack-profiles/python-fastapi-sqlalchemy.md](stack-profiles/python-fastapi-sqlalchemy.md) |

Another stack without a profile: propose the placeholder values and the profile content in ARCHITECTURE §2 together with an ADR (PLAYBOOK §3, rule 5).

## 5. Agent Rules

| File | Copy to | Applies to |
| --- | --- | --- |
| [agent-rules/backend-golden-rules.md](agent-rules/backend-golden-rules.md) | `.claude/rules/backend-golden-rules.md` | Backend source code (`paths` follow the directory tree in ARCHITECTURE §4) |

## 6. Surface Checklist

Self-check together with the "Overlay applied" checklist in PLAYBOOK §4.

| Check | Document | Pass |
| --- | --- | :---: |
| The ERD uses Crow's foot notation, every relationship has cardinality, entity names match the Data Dictionary | SRS §4 | [ ] |
| Value domains (enums) match across SRS §4.2, SRS §10.1 and the ARCHITECTURE §5 schema | SRS, ARCHITECTURE | [ ] |
| Every error code in SRS §6.3 appears in ARCHITECTURE §7.1 and has an HTTP mapping | ARCHITECTURE §7 | [ ] |
| The physical schema can be migrated as is: concrete types, foreign keys with delete rules, indexes, unique constraints | ARCHITECTURE §5 | [ ] |
| Every endpoint in the SPEC has an error matrix and an OpenAPI 3.1 fragment | SPEC §3 | [ ] |
| Every write operation that is not naturally idempotent has a unique idempotency mechanism | SPEC §5.3 | [ ] |
