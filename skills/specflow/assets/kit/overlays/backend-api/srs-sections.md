---
doc_type: overlay-section
status: stable
version: 1.0.0
language: en
surface: backend-api
---

# Overlay backend-api: blocks for the SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Constraint | Content |
| --- | --- |
| Stack | Per the stack profile `{{STACK_PROFILE}}` chosen at Intake §14; specific versions in ARCHITECTURE §2 |
| Strict typing | A language with static type checking, strict mode on; specific rules in ARCHITECTURE and `.claude/rules/` |
| Transaction integrity | Every business operation that changes the state of two or more related records runs in one database transaction; the default isolation level is fixed in ARCHITECTURE §7; the SPEC states it explicitly when a higher level or a row lock is needed |
| Protocol | The API is served over HTTPS only; <!-- fill: minimum TLS version, for example TLS 1.2 --> |
| Time | Stored and transmitted in UTC, ISO 8601 format |
| Currency | <!-- fill: currency unit and exact representation; write N/A if the system does not handle money --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### Software Interfaces

<!-- fill: Keep the rows that apply, write "No" in the Applies column of the remaining rows instead of deleting them. -->

| System | Purpose | Protocol and format | Authentication and safety | Applies |
| --- | --- | --- | --- | :---: |
| API client (web app, mobile app, other system) | Calls the business functions of the system | REST, JSON, HTTPS | Bearer token per ARCHITECTURE §6.1 | <!-- fill: choose one: Yes \| No --> |
| Third-party API (other than the email, SMS and identity in the rows below) | <!-- fill: which service, doing what --> | <!-- fill --> | <!-- fill: API key, OAuth client credentials --> | <!-- fill: choose one: Yes \| No --> |
| Incoming webhook | <!-- fill: sender, event --> | HTTPS POST, JSON | Signature verification (for example HMAC-SHA256 over the raw body), replay protection by timestamp, idempotent handling by the sender's event ID | <!-- fill: choose one: Yes \| No --> |
| Object storage | <!-- fill: which files are stored --> | S3-compatible API, pre-signed URL with an expiry | Private bucket, signed URL with a short expiry | <!-- fill: choose one: Yes \| No --> |
| Email or SMS | <!-- fill: which notifications --> | Provider API | API key in a secret manager | <!-- fill: choose one: Yes \| No --> |
| Identity provider | Federated sign-in | OpenID Connect over OAuth 2.0, Authorization Code with PKCE | Check `state`, `nonce`, audience | <!-- fill: choose one: Yes \| No --> |

### Communications Interfaces

| Channel | Convention | Applies |
| --- | --- | :---: |
| REST API | JSON UTF-8, lowercase `kebab-case` URIs, major version in the path; details in ARCHITECTURE §7 | Yes |
| Real time | WebSocket over TLS (WSS) with heartbeat ping/pong and client auto-reconnect with exponential backoff | <!-- fill: choose one: Yes \| No --> |
| Queue or event bus | <!-- fill: used for internal events or for integration; write No if not used --> | <!-- fill: choose one: Yes \| No --> |

User Interfaces and Hardware Interfaces: N/A for the `backend-api` surface; user interfaces belong to the overlay of the client surface if the project has one.
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### Logical ERD

<!-- fill: Every business entity and relationship, Crow's foot notation; entity names UPPER_SNAKE singular, attributes snake_case. Record only the core attributes, the logical type (uuid, string, decimal, int, timestamp, enum) and the key role (PK, FK, UK). Enum names and value sets MUST match §4.2 and §10.1. -->

```mermaid
erDiagram
    {{ENTITY_NAME}} ||--o{ {{ENTITY_NAME}} : "{{MESSAGE}}"
    {{ENTITY_NAME}} {
        uuid id PK "Primary key"
        timestamp created_at "Creation time, UTC"
        timestamp updated_at "Last update time, UTC"
    }
```

<!-- fill: When filling §4.2 and §4.3, consider each point fully and record the decision in the right section: history, financial and audit-log tables are append-only; an entity whose child data carries financial or legal constraints is soft-deleted with a deleted_at column, hard delete is forbidden, and the default query behavior for soft-deleted records is stated; time-dependent values (price, rate, configuration) are captured into the transaction record; arithmetic rules are written in inline code, matching the column names; natural unique keys and composite unique keys; finite value domains are listed in full, an entity with a lifecycle has a state machine in §10.1. -->
<!-- /SLOT-CONTENT -->
