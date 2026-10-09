---
doc_type: overlay-section
status: stable
version: 1.2.0
language: en
surface: frontend-web
---

# Overlay frontend-web: blocks for the SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Screen

<!-- fill: One table for each screen of the feature. With Stage 1W: the SCR ID row cites exactly the ID in the wireframe index and the Wireframe page row cites the screen's page; the SPEC only cites SCR-*, and does not redefine the screen, the layout or the components already on the wireframe page; the five-state table below matches the state table of the page and adds the execution behavior. Without Stage 1W: remove these two rows. -->

| Item | Value |
| --- | --- |
| SCR ID | {{SCR_ID}} |
| Wireframe page | `docs/wireframes/{{SCR_ID}}.md` |
| Route | `/{{ROUTE_PATH}}` |
| Actor and access condition | <!-- fill: roles allowed in; behavior when not logged in or without permission --> |
| Page title | String key <!-- fill --> |
| Navigation in | <!-- fill: from which screen, with which parameters --> |
| Navigation out | <!-- fill: after success, on cancel --> |
| Search indexing | <!-- fill: choose one: allowed \| not allowed (noindex) --> |

### Components & Props

| Component | Runs on | Props (name: type) | Responsibility |
| --- | --- | --- | --- |
| {{COMPONENT_NAME}} | <!-- fill: choose one: server \| client --> | <!-- fill --> | <!-- fill --> |

### UI States

<!-- fill: All five rows for each screen or independent data region; a state that does not apply is written N/A with a reason in the Display column. The AC column points to the acceptance criteria in SRS §8. -->

| State | Entry condition | Display | User action | AC |
| --- | --- | --- | --- | --- |
| `Initial` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Loading` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Empty` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Success` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Error` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Interaction States

| Element | State | Rule |
| --- | --- | --- |
| Submit button | Submitting | Locked and the label changes; a second click does not create a new request |
| Form | Result unknown (network error, timeout, `5xx`) | Fields are read-only; the only action is to resend the same content with the same key until a definitive response arrives |
| Input field | Has an error | Error border, message tied to the field through an accessibility attribute, focus moves to the first error field on submit (criteria in `specflow/CONVENTIONS.md` §10.2) |
| <!-- fill --> | <!-- fill --> | <!-- fill --> |

### Form & Validation

<!-- fill: One row for each field; copy the constraints from the request DTO in the API's SPEC and record the source SPEC in the last column. -->

| Field | Type | Constraints | String key of the error message | Constraint source |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: SPEC ID of the API, section §3 --> |

<!-- PROFILE-SLOT: spec.contract -->

### API Calls

| When called | Method and path | Source contract | Special headers | Success handling | Error handling |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: choose one: GET \| POST \| PATCH \| PUT \| DELETE; the path exactly as in the source contract --> `/api/v1/{{RESOURCE_PATH}}` | <!-- fill: SPEC ID and operationId in OpenAPI --> | <!-- fill: for example Idempotency-Key generated once for each submission --> | <!-- fill --> | Per the error mapping table below |

### Error to UI Mapping

<!-- fill: Every error code that the calls above can return (per the error matrix of the source SPEC) and the client-side codes; the codes are in ARCHITECTURE §7.1. -->

| `error.code` | UI state | String key of the message | Behavior |
| --- | --- | --- | --- |
| `VALIDATION_ERROR` | `Error` | <!-- fill --> | Errors under each field per `error.details` |
| `UNAUTHENTICATED` | `Error` | <!-- fill --> | Go to login, then return |
| `NETWORK_ERROR` | `Error` | <!-- fill --> | Allow retry with the same `Idempotency-Key` |
| <!-- fill: business code of the API --> | `Error` | <!-- fill --> | <!-- fill --> |

### i18n Keys

| Key | Content in the default locale |
| --- | --- |
| <!-- fill: in the form feature.element --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Surface Test Types

| Type | TYPE in the TC ID | Scope | Data | Required |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Form schema, formatting functions, hooks, components rendered in isolation | In memory | Yes |
| Integration | `INT` | The feature's components together with the real API client, with the API mocked at the network layer per the contract | Mock response that matches OpenAPI | Yes when the feature calls the API |
| E2E | `E2E` | User flows on the built app, in a real browser | API mocked at the network layer, or the staging environment API | Yes |
| Accessibility | `A11Y` | Automated scan at the WCAG level of NFR-USAB on every screen and main state | Same as E2E | Yes, for each screen |
| Visual regression | `VIS` | Screenshot compared with the approved baseline | Same as E2E, fixed data | Yes, for each screen in the `Success` state |
| Concurrency | `CONC` | The invariants in §1.2 when a write action is triggered repeatedly | Same as E2E | Yes, one test for each invariant in §1.2 |

### Concurrency Test Pattern

1. Open the screen on the built app; intercept the write call with a mock route that has enough delay for the second trigger to happen while the first request has not finished.
2. Trigger the write action repeatedly within one submission: double click, press Enter then click, or resend after a network error (the form must be locked for editing). The mock route that returns a network error must also have a delay, so that the second click lands while the first request has not ended.
3. Count the write requests sent and their `Idempotency-Key`; assert the invariant (one request for one submission, the same key on retry) and that the UI shows only one result.
4. Do not use sleep to order events; wait on the displayed state.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
