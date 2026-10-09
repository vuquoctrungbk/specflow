---
doc_type: overlay
status: stable
version: 1.3.0
language: en
surface: mobile-app
---

# Overlay mobile-app

## 1. Surface

An app installed on a phone or tablet (iOS, Android), distributed through an app store. The app keeps a copy of the data on the device, lets users work offline, and syncs with the API when the network returns. The source of truth for business data and error codes is the API; the on-device copy is a replica plus the changes not yet sent. Many app versions run in production at the same time, because users do not update all at once.

| Choose this overlay when | Do not choose when |
| --- | --- |
| The project has an app installed on a mobile device, uses the device hardware (camera, location, push notifications) or must work offline | The UI runs in a browser, including a browser on a phone (see `frontend-web`); the project only provides the API that the app calls (see `backend-api`) |

The `CONC` test pattern of this surface runs at integration level on the same SQL engine as the device (the SQLite of the test machine, through the same query gateway and the same connection queueing as the app), with a fake API that keeps record versions and stores responses by idempotency key. Three patterns are mandatory: two devices (two independent local databases) edit the same record offline and then sync one after the other; one device triggers sync several times at once (network returns, app reopens, pull to refresh); and the user edits a record while an earlier change of that same record is being sent, with the response arriving and with the response lost. Do not use sleep to order events; the test controls the order with sync calls and the fake API's latency.

## 2. Provided Slots

| Slot | File | Content | Has `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Platform and OS version, device matrix, offline work, OS permissions, secure storage, minimum app version | No |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Screens, the five UI states and the record sync state, accessibility; API, push notifications, deep links; device hardware | No |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | On-device data, sync strategy, conflict table | No |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, navigation map and navigation table with a `SCR ID` column, sync flow, build and distribution view | No |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Layer rules: screens, features, local database, sync engine, API client | Yes |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Local schema, on-device migrations, sync columns, change queue, mapping to the API DTOs | Yes |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | Offline work rules, sync conventions, UI states, mapping of error codes to the UI, OS permissions | Yes |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | App version, signing and distribution, staged rollout, over-the-air updates, minimum version, compatibility with the API | No |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Screens and navigation parameters, the five states, sync states, local mutations, sync contract, permissions, error mapping, string keys | Yes |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration with the local database, e2e on emulators, accessibility, `CONC`, smoke on the device matrix | Yes |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Verify command table | No |

## 3. Assembly Order

1. The stage's core files (`core/01`, `core/02`, `core/04`, `core/06`).
2. This file.
3. The section file that holds the matching SLOT-CONTENT block in the §2 table.
4. The stack profile chosen in the Intake: the "Placeholder values" table, the `(Tech Stack)` section and the PROFILE-CONTENT blocks.
5. The surface rule in `agent-rules/` when creating `.claude/rules/` (Stage 2).

Detailed assembly rules are in CONVENTIONS §2 and PLAYBOOK §4.

## 4. Stack Profiles

| Profile | Stack | File |
| --- | --- | --- |
| `react-native-expo` | React Native with Expo SDK, Expo Router, TypeScript, on-device SQLite, Jest, Maestro | [stack-profiles/react-native-expo.md](stack-profiles/react-native-expo.md) |

Other stacks have no profile yet (for example Flutter, native Swift or Kotlin apps): propose the placeholder values and the profile content in ARCHITECTURE §2 together with an ADR (PLAYBOOK §3, rule 5).

## 5. Agent Rules

| File | Copy to | Applies to |
| --- | --- | --- |
| [agent-rules/mobile-golden-rules.md](agent-rules/mobile-golden-rules.md) | `.claude/rules/mobile-golden-rules.md` | Mobile app source code (`paths` follow the directory tree in ARCHITECTURE §4) |

## 6. Surface Checklist

Self-check together with the "Overlay applied" checklist in PLAYBOOK §4.

| Check | Document | Pass |
| --- | --- | :---: |
| Every screen in SRS §3 has a `SCR ID` and states whether it works offline; every FR of the app traces to the FR or endpoint of the API that it uses | SRS §3, §8 | [ ] |
| Every on-device entity has its source in the API, the scope of data kept on the device, and how it is deleted; the conflict strategy is covered by an ADR | SRS §4; ARCHITECTURE §5, §12 | [ ] |
| A local write and the change queue are updated in the same transaction; each change has its own idempotency key, and a resend uses the same key | ARCHITECTURE §5, §7; SPEC §3, §5 | [ ] |
| Every error code the app handles is in ARCHITECTURE §7.1 with a string key and a behavior, including the record sync state | ARCHITECTURE §7 | [ ] |
| API data types are generated from the API's OpenAPI document; there are no hand-written response types | ARCHITECTURE §5 | [ ] |
| Every screen in the SPEC has all five UI states and a sync state table for records that can be edited offline | SPEC §3 | [ ] |
| There are `CONC` tests for two devices editing offline, for several sync triggers at once, and for an edit made while a change of the same record is being sent; there is a smoke test on the device matrix before release | SPEC §9 | [ ] |
| The API keeps its contract for every app version still at or above the minimum version; the way to force an update is decided | ARCHITECTURE §8 | [ ] |

## 7. Stage 1W: Wireframe

This surface has a UI, so the project has Stage 1W (PLAYBOOK §2 and 2.2.1): Intake §14 records Stage 1W: Yes, Intake §9 records the Gate 1W approver.

- The screen ID `SCR-{MOD}-NN` is set in Stage 1, in the `SCR ID` column of the User Interfaces table in SRS §3 (the `srs.external-interfaces` block of this overlay). Stage 1W details each ID as one page `docs/wireframes/SCR-<MOD>-NN.md`, without adding or removing screens. A project with both web and mobile that share a module code: NN is still unique per MOD, and a web screen and a mobile screen are two different IDs.
- Design system: Stage 1W also writes `docs/design-system/DESIGN_SYSTEM.md` and `docs/design-system/tokens.json` per CONVENTIONS §10.7, before the screen pages; each page chooses a Template and cites the Pattern and Component IDs of that document. The default theme of the stack profile's UI library (Intake §14) is only a visual direction, used when chosen on purpose; profile `none` records that no library is chosen yet and is revisited in Stage 2.
- The template `core/07_Wireframe_Template/` is shared by every surface that has a UI and has no slot; the overlay provides no block for the wireframe. How to fill it for mobile:

| Template section | How to fill for `mobile-app` |
| --- | --- |
| Entry point (catalog of screens and pages) | The deep link when the screen can be opened by a deep link; otherwise the screen name in the navigator; the in-app route is in the Route column of SRS §3 |
| Low-fi Layout | Draw in portrait; the navigation bar, tab bar and safe area are separate zones when the screen has them |
| UI States | Data already on the device shows at once, and `Loading` only when the device has no data yet; a screen that can be edited offline records the record's sync state (`Synced`, `Queued`, `Conflict`, `Rejected`) in the Display column; a network indicator when offline |
| Navigation | Entering from a deep link or a push notification; navigation parameters; where the system back gesture takes the user |
| Accessibility Notes | Per CONVENTIONS §10.2 at the WCAG level of NFR-USAB; criteria written in web terms (page, page title) apply through WCAG2ICT. Mobile figures: minimum touch target 44 × 44 pt on iOS and 48 × 48 dp on Android (higher than the WCAG 2.5.8 floor); text scales with the system font size; the OS screen reader (VoiceOver, TalkBack) |
| Full HTML (per Intake §14) | One static file per page per CONVENTIONS §7, with a phone-sized frame, portrait; the code stage rebuilds exactly this screen (PLAYBOOK §2.5) |

- After Gate 1W: the navigation table in ARCHITECTURE §3 (the `arch.views` block) has a `SCR ID` column, with at least one row for each `SCR-*` of the wireframe index (Gate 2); the Screen table in SPEC §3 (the `spec.contract` block) cites the `SCR ID` and the wireframe page, and does not redefine the screen. In Stage 2, ARCHITECTURE §7 records how tokens map to source code (the `arch.conventions` block) and the stack profile records the mapping tool; code reads only the mapped tokens.
