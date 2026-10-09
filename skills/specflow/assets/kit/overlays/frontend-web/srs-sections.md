---
doc_type: overlay-section
status: stable
version: 1.2.1
language: en
surface: frontend-web
---

# Overlay frontend-web: blocks for the SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Constraint | Content |
| --- | --- |
| Stack | Per the stack profile `{{STACK_PROFILE}}` chosen at Intake §14; exact versions in ARCHITECTURE §2 |
| Strict typing | A language with static type checking, strict mode enabled; specific rules in ARCHITECTURE and `.claude/rules/` |
| Supported browsers | <!-- fill: list of browsers and minimum versions, for example the two latest versions of Chrome, Edge, Firefox, Safari; Safari on iOS from a specific version --> |
| Devices and breakpoints | <!-- fill: the smallest screen width that must be usable (for example 360 px) and the breakpoints where the layout changes --> |
| Accessibility | Comply with WCAG 2.2 level {{WCAG_LEVEL}} per NFR-USAB |
| Perceived performance | <!-- fill: Core Web Vitals thresholds at the 75th percentile, for example LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1; the device and network used to measure --> |
| Protocol | Pages and API calls over HTTPS only |
| Source of truth | Prices, amounts, permissions and business status are displayed from the data the API returns; the UI does not compute these values and then send them up |
| Browser-side storage | Do not store tokens, secrets or personal data in `localStorage` or `sessionStorage` |
| Time and currency | Received from the API in UTC and ISO 8601; display format follows the user's locale |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### User Interfaces

<!-- fill: One row for each screen; this table is the only source of the screen list. The SCR ID as SCR-<MOD>-NN is assigned here (CONVENTIONS §4), MOD is the code of the module that owns the main FR of the screen, NN is unique per MOD across the whole project; Stage 1W elaborates each SCR ID into one wireframe page, without assigning more IDs. Brownfield project: a screen that does not change per the Gap Analysis records Unchanged in the SCR ID cell. Route is the page path; FR is the requirement that the screen implements. -->

| Screen | SCR ID | Route | Actor | Purpose | FR |
| --- | --- | --- | --- | --- | --- |
| <!-- fill --> | {{SCR_ID}} | `/{{ROUTE_PATH}}` | `ACT_{{ROLE_CODE}}` | <!-- fill --> | FR-{{MODULE_CODE}}-001 |

General requirements for every screen:

- The five UI states: each screen and each independent data region on a screen has all of `Initial` (before the user acts or before loading), `Loading` (waiting for data or submitting), `Empty` (loaded but no data), `Success` (has data or the action succeeded), `Error` (an error, with a way to recover). A state that does not apply is written N/A with a reason; with Stage 1W, write it on the screen's wireframe page (§4) and the SPEC takes it over; without Stage 1W, write it directly in the SPEC.
- Responsive per the breakpoints in §2.5; no horizontal scroll at the smallest width.
- Accessibility per §2.5: each screen meets the WCAG 2.2 criteria at the level of NFR-USAB; the criteria are examined per screen when drawing the wireframe per `specflow/CONVENTIONS.md` §10.2.
- Every display string comes from the string bundle by locale; default locale <!-- fill: for example en-US -->.

### Software Interfaces

<!-- fill: Keep the rows that apply, write "No" in the Applies column of the other rows instead of deleting them. -->

| System | Purpose | Protocol and format | Authentication and safety | Applies |
| --- | --- | --- | --- | :---: |
| Backend API | <!-- fill: name of the API and the contract document (SPEC, OpenAPI) that the UI calls --> | REST, JSON, HTTPS | <!-- fill: login session mechanism, decided in ARCHITECTURE §6.1 --> | <!-- fill: choose one: Yes \| No --> |
| Identity provider | Federated login | OpenID Connect on OAuth 2.0, Authorization Code with PKCE | Check `state`, `nonce`, audience | <!-- fill: choose one: Yes \| No --> |
| Analytics | <!-- fill: which events are sent --> | <!-- fill --> | Send only after the user consents; do not send personal data | <!-- fill: choose one: Yes \| No --> |
| Browser-side error tracking | <!-- fill: the service that receives JavaScript errors --> | <!-- fill --> | Mask personal data before sending | <!-- fill: choose one: Yes \| No --> |

### Communications Interfaces

| Channel | Convention | Applies |
| --- | --- | :---: |
| HTTPS to the API | JSON UTF-8; errors per the API's envelope; timeout and retry per ARCHITECTURE §7 | Yes |
| Real time | <!-- fill: choose one: WebSocket over TLS (WSS) \| Server-Sent Events; if not used, replace the whole cell with Not needed --> with automatic reconnect using exponential backoff | <!-- fill: choose one: Yes \| No --> |

Hardware Interfaces: N/A for the `frontend-web` surface; the browser is the intermediary layer to the device.
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### View Model

<!-- fill: This surface owns no persistent data; business entities, the ERD and integrity rules belong to the SRS of the API it calls. Each view model takes its fields from the response of one endpoint, keeping the field names exactly as in the response (including in §4.2, without converting to snake_case); do not add fields that the API does not return. Display data that must be kept after its source is deleted (for example the product name of an order just placed when the cart has been cleared) records the snapshot source explicitly. §4.2 lists view models and client-side state as entities; §4.3 records the display and client-side storage rules. -->

| View model | Source (endpoint and FR of the API) | Displayed fields | Display format |
| --- | --- | --- | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill --> | <!-- fill: for example currency per locale, time in the user's time zone --> |

#### Client State

| State | Type | Lifecycle | Where it is held | Contains personal data |
| --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill: choose one: server data \| form state \| URL state \| UI state --> | <!-- fill: when created, when cleared --> | <!-- fill: memory, URL, cookie; do not use localStorage for sensitive data --> | <!-- fill: choose one: Yes \| No --> |
<!-- /SLOT-CONTENT -->
