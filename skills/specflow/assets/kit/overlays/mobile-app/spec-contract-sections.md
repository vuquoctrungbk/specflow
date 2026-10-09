---
doc_type: overlay-section
status: stable
version: 1.1.0
language: en
surface: mobile-app
---

# Overlay mobile-app: blocks for the SPEC

<!-- SLOT-CONTENT: spec.contract -->
### Screen

<!-- fill: One table per screen of the feature. With Stage 1W: the SCR ID row cites exactly the ID in the wireframe index and the Wireframe page row cites the screen's page; the SPEC only cites SCR-*, and does not redefine the screen, layout or components already on the wireframe page; the five-state table below matches the page's state table and adds the execution behavior. Without Stage 1W: remove these two rows. -->

| Item | Value |
| --- | --- |
| SCR ID | {{SCR_ID}} |
| Wireframe page | `docs/wireframes/{{SCR_ID}}.md` |
| Route | `/{{ROUTE_PATH}}` |
| Navigation parameters | <!-- fill: name, type, required or not; a parameter that comes from a deep link is validated as external input --> |
| Actor and access condition | <!-- fill: roles allowed in; behavior when the session expires while offline --> |
| Works offline | <!-- fill: choose one: Yes \| View only \| No; matches SRS §3 --> |
| Navigation in | <!-- fill: from which screen, from a deep link or a push notification --> |
| Navigation out | <!-- fill: after saving, on cancel, on the system back gesture --> |

### Components & Props

| Component | Props (name: type) | Data source | Responsibility |
| --- | --- | --- | --- |
| {{COMPONENT_NAME}} | <!-- fill --> | <!-- fill: which local query, or props from the screen --> | <!-- fill --> |

### UI States

<!-- fill: All five rows for each screen or independent data zone; a state that does not apply records N/A with a reason in the Display column. The When offline column records how the display differs when the device is offline. The AC column points to the acceptance criteria in SRS §8. -->

| State | Entry condition | Display | When offline | User action | AC |
| --- | --- | --- | --- | --- | --- |
| `Initial` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Loading` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Empty` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Success` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Error` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Record Sync States

<!-- fill: Required for records that can be edited offline; record N/A with a reason if the feature is read-only. -->

| State | Entry condition | Display | User action | AC |
| --- | --- | --- | --- | --- |
| `Synced` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Queued` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Conflict` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| `Rejected` | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

### Local Mutations

<!-- fill: One row per write operation. The local table and the change queue change in the same transaction. -->

| Operation | Local table changed | Change enqueued | Merge with an unsent change | Blocking condition |
| --- | --- | --- | :---: | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill: target endpoint, content, base version --> | <!-- fill: choose one: Yes \| No --> | <!-- fill: for example the record is in Conflict --> |

### Form & Validation

<!-- fill: One row per field; constraints are copied from the request DTO in the SPEC or the API's OpenAPI, and the source is recorded in the last column. -->

| Field | Type | Constraint | Error message string key | Constraint source |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

<!-- PROFILE-SLOT: spec.contract -->

### Sync Contract

<!-- fill: One row per API call that the sync engine or a screen uses; the path exactly as in the source contract. A definitive response is one after which the change does not need to be sent again. -->

| Call | Method and path | Source contract | Special headers and parameters | Definitive response | Unclear response |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: choose one: GET \| POST \| PATCH \| PUT \| DELETE; path exactly as in the source contract --> `/api/v1/{{RESOURCE_PATH}}` | <!-- fill: SPEC ID or operationId in OpenAPI --> | <!-- fill: for example Idempotency-Key is the change ID, base version in the body --> | <!-- fill: HTTP code and error code, with the sync state that each code leads to --> | Network error, timeout, `5xx`: resend with the same key |

### Permissions

| Permission | When to ask | Explanation text | When denied |
| --- | --- | --- | --- |
| <!-- fill: or Not used --> | <!-- fill --> | String key <!-- fill --> | <!-- fill --> |

### Error to UI Mapping

<!-- fill: Every error code that the calls above can return, and the client-side codes; the codes are in ARCHITECTURE §7.1. -->

| `error.code` | UI state or sync state | Message string key | Behavior |
| --- | --- | --- | --- |
| `NETWORK_ERROR` | `Queued` | <!-- fill --> | Resend with the same key in the next sync round |
| <!-- fill: API code --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

### i18n Keys

| Key | Content in the default locale |
| --- | --- |
| <!-- fill: in the form feature.element --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: spec.test-types -->
### Surface Test Types

| Type | TYPE in the TC ID | Scope | Data | Required |
| --- | --- | --- | --- | :---: |
| Unit | `UNIT` | Pure functions, form schemas, components rendered in isolation | In memory | Yes |
| Integration | `INT` | Local mutations, migrations, the sync engine with the real API client and a fake API at the `fetch` layer | A real local database (same SQL engine) in memory | Yes |
| E2E | `E2E` | User flows on a build running in an emulator or a device, including turning the network off and on | A fake API or the staging API | Yes |
| Accessibility | `A11Y` | Labels, roles, status announcements for the screen reader; manual check with VoiceOver and TalkBack on the main screens before release | As unit or e2e | Yes, per screen |
| Concurrency | `CONC` | The invariants in §1.2 when two devices edit offline, when sync is triggered several times at once, or when the user edits a record that is being sent | As integration, one database per device | Yes, one test per invariant in §1.2 |
| Smoke | `SMOKE` | Open the app, log in, the main flow, lose the network and get it back, on each configuration of the device matrix | An internal test build, the staging API | Yes, every release |

### Concurrency Test Pattern

1. Create a fake API at the `fetch` layer that keeps the record's version, returns a conflict when the base version is stale, stores responses by idempotency key and replays exactly that response when it receives the key again, and records the key and content of every request; with an option to lose the response after it has been applied, a hook that runs a task after the next write is applied and before the reply, and a latency option.
2. Two devices: create two local databases and two independent sync engines that call the same fake API; sync for the first time, write locally on both as when offline, then sync one after the other in an order the test chooses. Assert: the API accepts only the change based on the latest version, the other device moves to `Conflict` and keeps the user's value, and no change is lost without the user knowing.
3. Several triggers: one device has pending changes, the fake API has latency, call sync several times at once. Assert that the number of write requests the API receives equals the number of pending changes.
4. Edit while sending: the fake API's hook writes locally to the same record after the API has applied the change being sent; run once with the response arriving and once with the response lost, then sync again; add a local write right after the sync engine reads the change about to be sent (wrap the query gateway to insert the write at exactly that moment). Assert that the API keeps the latest value, each idempotency key goes with only one content, and the record on the device matches the API.
5. Do not use sleep to order events; the test controls the order with sync calls and the fake API's latency.

<!-- PROFILE-SLOT: spec.test-types -->
<!-- /SLOT-CONTENT -->
