---
doc_type: overlay
status: stable
version: 1.3.0
language: en
surface: frontend-web
---

# Overlay frontend-web

## 1. Surface

A web interface that runs in a browser: pages rendered on the server, on the client or a mix of both, calling the backend API over HTTPS. This surface does not own persistent business data; the source of truth for data and error codes is the API it calls.

| Choose this overlay when | Do not choose it when |
| --- | --- |
| The project has a user interface in the browser that calls the API of its own system or of another party | The project only provides an API (see `backend-api`); an app installed on a phone (see `mobile-app`) |

The `CONC` test pattern of this surface: trigger a write action several times in a row (double click, Enter then click, resend after a network error) on the built app, intercept the API calls with the mock route of the e2e tool, then count the write requests actually sent and their idempotency keys. Each tab holds its own key, so two tabs submitting at the same time are two independent submissions; this pattern does not test across tabs. Do not use sleep to order events.

## 2. Provided Slots

| Slot | File | Contents | Has `PROFILE-SLOT` |
| --- | --- | --- | :---: |
| `srs.constraints.technical` | [srs-sections.md](srs-sections.md) | Browsers, devices and breakpoints, accessibility, perceived performance, browser-side storage | No |
| `srs.external-interfaces` | [srs-sections.md](srs-sections.md) | Screens, the five UI states, responsive, accessibility, internationalization; APIs called; communications channels | No |
| `srs.data-model` | [srs-sections.md](srs-sections.md) | View model and client-side state; no ERD | No |
| `arch.views` | [architecture-sections.md](architecture-sections.md) | C4 Level 2, route map and route table with an `SCR ID` column, component tree of a screen, deployment view | No |
| `arch.layout` | [architecture-sections.md](architecture-sections.md) | Layering rules: route, feature, shared UI components, API client | Yes |
| `arch.schema` | [architecture-sections.md](architecture-sections.md) | Client-side data types: API types generated from OpenAPI, form schema, state and browser storage | Yes |
| `arch.conventions` | [architecture-sections.md](architecture-sections.md) | UI conventions, the five states, mapping of error codes to the UI, API call conventions | Yes |
| `arch.deployment` | [architecture-sections.md](architecture-sections.md) | Packaging, public and secret environment variables, CDN, release, rollback | No |
| `spec.contract` | [spec-contract-sections.md](spec-contract-sections.md) | Screen, props, five-state table, interaction states, form, API calls, error mapping, i18n keys | Yes |
| `spec.test-types` | [spec-contract-sections.md](spec-contract-sections.md) | Unit, integration with a mock API, e2e, accessibility, visual regression, `CONC` | Yes |
| `playbook.verify-commands` | [verify-commands.md](verify-commands.md) | Verify command table | No |

## 3. Assembly Order

1. The core file of the stage (`core/01`, `core/02`, `core/04`, `core/06`).
2. This file.
3. The section file that holds the matching SLOT-CONTENT block in the table of §2.
4. The stack profile chosen in the Intake: the "Placeholder values" table, the `(Tech Stack)` section and the PROFILE-CONTENT blocks.
5. The rule of the surface in `agent-rules/` when creating `.claude/rules/` (Stage 2).

Detailed assembly rules are in CONVENTIONS §2 and PLAYBOOK §4.

## 4. Stack Profiles

| Profile | Stack | File |
| --- | --- | --- |
| `nextjs-app-router` | Next.js App Router, React, TypeScript, Tailwind CSS, shadcn/ui, TanStack Query | [stack-profiles/nextjs-app-router.md](stack-profiles/nextjs-app-router.md) |

Another stack has no profile yet: propose the placeholder values and the profile contents in ARCHITECTURE §2 together with an ADR (PLAYBOOK §3, rule 5).

## 5. Agent Rules

| File | Copy to | Applies to |
| --- | --- | --- |
| [agent-rules/frontend-golden-rules.md](agent-rules/frontend-golden-rules.md) | `.claude/rules/frontend-golden-rules.md` | Web UI source code (`paths` follow the directory tree in ARCHITECTURE §4) |

## 6. Surface Checklist

Self-check together with the "Overlay applied" checklist in PLAYBOOK §4.

| Check | Document | Pass |
| --- | --- | :---: |
| Every screen in SRS §3 has an `SCR ID`, a route, an actor and an FR; every UI FR traces to the FR or endpoint of the API it uses | SRS §3, §8 | [ ] |
| The view models in SRS §4 contain only fields present in the API response; they do not redefine backend entities | SRS §4 | [ ] |
| Every error code the UI handles is in ARCHITECTURE §7.1 with an i18n key and the display behavior | ARCHITECTURE §7 | [ ] |
| API data types are generated from the backend's OpenAPI document; there are no hand-written response types | ARCHITECTURE §5 | [ ] |
| Each screen in the SPEC has all five UI states (a state that does not apply is written N/A with a reason) and the form schema matches the constraints of the backend DTO | SPEC §3 | [ ] |
| Each write action has a duplicate-submit lock; the `Idempotency-Key` is reused on retry and the form locks editing while the result is unknown | SPEC §3, §5 | [ ] |
| Each screen has an `A11Y` accessibility test and a `VIS` visual test for the main state | SPEC §9 | [ ] |

## 7. Stage 1W: Wireframe

This surface has a UI, so the project has Stage 1W (PLAYBOOK §2, and 2.2.1): Intake §14 records Stage 1W: Yes, Intake §9 records the approver of Gate 1W.

- The screen ID `SCR-{MOD}-NN` is assigned at Stage 1, in the `SCR ID` column of the User Interfaces table in SRS §3 (the `srs.external-interfaces` block of this overlay). Stage 1W elaborates each ID into one page `docs/wireframes/SCR-<MOD>-NN.md`, without adding or removing screens.
- Design system: Stage 1W also writes `docs/design-system/DESIGN_SYSTEM.md` and `docs/design-system/tokens.json` per CONVENTIONS §10.7, before the screen pages; each page chooses one Template and cites the Pattern and Component IDs of that document. The default theme of the stack profile's UI library (Intake §14) is only a visual direction, used when it is chosen on purpose; the `none` profile records that no library is chosen and revisits it at Stage 2.
- The template `core/07_Wireframe_Template/` is shared by every surface that has a UI and has no slot; the overlay provides no block for the wireframe. How to fill it for web:

| Template section | How to fill it for `frontend-web` |
| --- | --- |
| Entry point (screen and page catalog) | The route as `/path`, the same as the Route column in SRS §3 |
| Low-fi Layout | Draw at the smallest breakpoint in SRS §2.5; layout changes at larger breakpoints go under the block |
| UI States | Per the general requirement for every screen in SRS §3; `Loading` includes the time of submitting, with the submit button locked |
| Navigation | Route or query parameters; routes that need login; behavior of the browser back button when it differs from the normal flow |
| Accessibility Notes | Per CONVENTIONS §10.2 at the WCAG level of NFR-USAB. Web figures: minimum target size 24 × 24 CSS px, or a smaller target spaced so that a circle of 24 CSS px diameter centered on it touches neither another target nor the circle of another small target (WCAG 2.5.8, level AA); reflow is checked at the smallest breakpoint in SRS §2.5 (WCAG 1.4.10) |
| Full HTML (per Intake §14) | One static file per page per CONVENTIONS §7: the layout is correct at the smallest and the largest breakpoint in SRS §2.5 (`@media`), opens directly in a browser; the code stage rebuilds exactly this screen (PLAYBOOK §2.5) |

- After Gate 1W: the route table in ARCHITECTURE §3 (the `arch.views` block) has an `SCR ID` column, and each `SCR-*` of the wireframe index has at least one row (Gate 2); the Screen table in SPEC §3 (the `spec.contract` block) cites the `SCR ID` and the wireframe page and does not redefine the screen. At Stage 2, ARCHITECTURE §7 records how tokens map to source code (the `arch.conventions` block) and the stack profile records the mapping tool; code reads only the mapped tokens.
