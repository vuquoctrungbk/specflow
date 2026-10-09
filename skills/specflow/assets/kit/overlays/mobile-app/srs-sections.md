---
doc_type: overlay-section
status: stable
version: 1.2.1
language: en
surface: mobile-app
---

# Overlay mobile-app: blocks for the SRS

<!-- SLOT-CONTENT: srs.constraints.technical -->
| Constraint | Content |
| --- | --- |
| Stack | Per the stack profile `{{STACK_PROFILE}}` chosen in Intake §14; specific versions in ARCHITECTURE §2 |
| Strict typing | A language with static type checking, strict mode on; specific rules in ARCHITECTURE and `.claude/rules/` |
| Platform and OS version | <!-- fill: iOS and Android, the minimum version of each platform; phone, tablet or both; screen orientation --> |
| Device matrix | <!-- fill: the devices or configurations used for the smoke test before release: the lowest-spec supported device, the most common device among users, the smallest screen --> |
| Offline work | <!-- fill: which functions work offline; the longest offline period that must be tolerated; the maximum amount of data kept on the device --> |
| OS permissions | <!-- fill: each permission (camera, location, notifications, photos) and its reason; ask for the permission when the user uses the feature that needs it, not when the app opens --> |
| Secure storage | Tokens and secrets live only in the OS key store (Keychain, Android Keystore); business data on the device is deleted on logout, after warning about changes not yet synced |
| Protocol | Every network call goes through HTTPS |
| Source of truth | Business values, permissions and status are decided by the API; the app shows the on-device copy with its sync state and does not decide in place of the API |
| Minimum app version | <!-- fill: how the API or remote config reports the lowest supported version, and the behavior of an older app (block and send to the store) --> |
| Time and currency | Received from the API in UTC and ISO 8601; displayed by the device's locale and time zone; the time a change was made on the device is only for display and is not used to settle conflicts |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.external-interfaces -->
### User Interfaces

<!-- fill: One row per screen; this table is the only source of the screen list. The SCR ID in the form SCR-<MOD>-NN is set here (CONVENTIONS §4), MOD is the module code that has the screen's main FR, NN is unique per MOD across the whole project, even when web and mobile share the module code; Stage 1W details each SCR ID as one wireframe page, without adding IDs. Brownfield project: a screen that does not change per the Gap Analysis records Unchanged in the SCR ID cell. Route is the screen's path inside the app, also used for the deep link if there is one. -->

| Screen | SCR ID | Route | Actor | Purpose | Works offline | FR |
| --- | --- | --- | --- | --- | :---: | --- |
| <!-- fill --> | {{SCR_ID}} | `/{{ROUTE_PATH}}` | `ACT_{{ROLE_CODE}}` | <!-- fill --> | <!-- fill: choose one: Yes \| View only \| No --> | FR-{{MODULE_CODE}}-001 |

Requirements common to every screen:

- Five UI states: every screen and every independent data zone has `Initial`, `Loading`, `Empty`, `Success`, `Error`. Data already on the device shows at once without waiting for the network; `Loading` is used only when the device has no data yet. A state that does not apply records N/A with a reason; with Stage 1W, record it on the screen's wireframe page (§4) and the SPEC takes it back; without Stage 1W, record it directly in the SPEC.
- Record sync state: every record that can be edited offline shows one of `Synced` (matches the API's version), `Queued` (saved on the device, waiting to be sent), `Conflict` (the API has a newer version, the user must choose), `Rejected` (the API refused the change, with a reason). A list screen shows the number of changes waiting to be sent and the number of items that need a choice.
- Network indicator: when offline, the app says so clearly and still allows the write actions that work offline.
- Accessibility: every screen meets the WCAG 2.2 criteria at the level of NFR-USAB, applied to mobile apps through WCAG2ICT; the criteria are considered per screen when the wireframe is written, per `specflow/CONVENTIONS.md` §10.2. Platform figures: minimum touch target 44 × 44 pt on iOS and 48 × 48 dp on Android; text scales with the system font size; the VoiceOver and TalkBack screen readers.
- Every displayed string comes from the string set by locale; default locale <!-- fill: for example en-US -->.

### Hardware Interfaces

<!-- fill: Keep the rows that apply, and write "No" in the Applies column of the other rows instead of deleting them. -->

| Hardware | Purpose | Permission to request | When denied | Applies |
| --- | --- | --- | --- | :---: |
| Camera | <!-- fill --> | Camera | <!-- fill: a replacement feature or guidance to open settings --> | <!-- fill: choose one: Yes \| No --> |
| Location | <!-- fill --> | Location while using the app | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| Biometrics | <!-- fill: unlock the app --> | Face ID or fingerprint | <!-- fill: use a password --> | <!-- fill: choose one: Yes \| No --> |
| Device storage | The local database and files waiting to be sent | Not needed | <!-- fill: behavior when storage is full --> | Yes |

### Software Interfaces

| System | Purpose | Protocol and format | Authentication and safety | Applies |
| --- | --- | --- | --- | :---: |
| Backend API | <!-- fill: name of the API and the contract documents (SPEC, OpenAPI) that the app calls, including the sync contract --> | REST, JSON, HTTPS | <!-- fill: the login session mechanism, decided in ARCHITECTURE §6.1 --> | <!-- fill: choose one: Yes \| No --> |
| Push notification service | <!-- fill: notification types; a notification only signals that there is a change and holds no personal data --> | APNs, FCM or an intermediary service | The device token is sent to the API after the user agrees | <!-- fill: choose one: Yes \| No --> |
| Deep link | <!-- fill: paths that open a screen directly --> | Universal Links, App Links | Check permissions as when the screen is opened from inside the app | <!-- fill: choose one: Yes \| No --> |
| Error and crash tracking | <!-- fill: the service that receives crashes --> | <!-- fill --> | Mask personal data before sending | <!-- fill: choose one: Yes \| No --> |
| App store | Distribution, staged rollout | App Store Connect, Google Play Console | Signing keys kept outside the repo | Yes |

### Communications Interfaces

| Channel | Convention | Applies |
| --- | --- | :---: |
| HTTPS to the API | JSON UTF-8; errors follow the API's envelope; timeout and retry per ARCHITECTURE §7 | Yes |
| Sync | Send pending changes and receive new changes when the network returns, when the app reopens, when the user pulls to refresh and after every write; runs in the background within OS limits if available | Yes |
<!-- /SLOT-CONTENT -->

<!-- SLOT-CONTENT: srs.data-model -->
#### On-device Data

<!-- fill: One row per entity kept on the device. Business entities, the ERD and integrity rules belong to the API's SRS; here record only the part the app keeps, with fields kept under the same names as the API response. §4.2 lists the on-device entities and the data that exists only on the device (the change queue, the API's version when there is a conflict) as entities; §4.3 records the rules for keeping, editing and deleting on the device. -->

| On-device entity | Source (API endpoint and FR) | Scope kept on the device | Edited offline | Holds personal data | Deleted when |
| --- | --- | --- | :---: | :---: | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: for example only records assigned to the user, within 30 days --> | <!-- fill: choose one: Yes \| No --> | <!-- fill: choose one: Yes \| No --> | <!-- fill: logout, out of scope, the API reports it deleted --> |

#### Sync Strategy

| Item | Decision |
| --- | --- |
| Sync direction | <!-- fill: which data is only received from the API, which data the app sends up --> |
| Conflict detection | Every editable record carries a version issued by the API; a change is sent with the version the user edited on top of; the API refuses when that version is stale |
| Conflict resolution | <!-- fill: choose one, with an ADR: the user chooses between their version and the API's version \| the API's version wins, the change on the device is dropped with a notice \| merge per field; do not use the device clock to settle --> |
| Send order | Changes are sent one after another in creation order; a later change of the same record waits until the earlier change has a result |
| Resend | Every change has its own idempotency key; a resend after a network error, timeout or `5xx` uses exactly the same key and the same content |
| Delete | <!-- fill: how the API reports that a record is deleted or out of scope; what happens to a record that still has unsent changes --> |
| Limits | <!-- fill: the maximum number of pending changes, the size of files waiting to be sent, how long rejected changes are kept --> |

#### Conflict Table

<!-- fill: One row for each situation where two places change the same record: two devices, a device and a web user, a device and a system job. -->

| Entity | Situation | Detected at | Resolution | What the user sees |
| --- | --- | --- | --- | --- |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: for example the API returns a version conflict code when it receives the change --> | <!-- fill: per the strategy in the table above --> | <!-- fill --> |
<!-- /SLOT-CONTENT -->
