---
doc_type: wireframe-screen
status: draft
version: 0.1.0
template_version: 1.6.0
language: en
parent: [docs/wireframes/00_WIREFRAME_INDEX.md, docs/design-system/DESIGN_SYSTEM.md]
overlays: []
assembled_from: []
---

# Screen Wireframe: {{SCR_ID}} {{SCREEN_NAME}}

<!-- fill: Copy to docs/wireframes/SCR-<MOD>-NN.md at Stage 1W (PLAYBOOK §2.2.1), one file for each SCR ID in the screen catalog of the index; the file name is the SCR ID plus the .md suffix. parent also adds the SRS that holds the FRs of the screen (docs/srs/SRS.md, or the master and modules when modular); DESIGN_SYSTEM.md is the design system document in docs/design-system/, the source of the Templates, Patterns and Components that the page cites (CONVENTIONS §10.7). overlays records the surface of the screen. assembled_from records "core/07_Wireframe_Template/SCR_Screen_Template.md@<template_version>". This template is shared by every surface that has a UI and has no slots: the differences between web and mobile are written in the fill comments below and in the Stage 1W section of the overlay's OVERLAY.md. The page only details a screen that already exists in SRS §3: it does not define new FRs, ACs or data fields; if something is missing, record a BLOCKING question in §7 with a proposed SRS fix per PLAYBOOK §8. Status, version and changes after approval follow the SRS. -->

## 1. Purpose, FR & AC

- Purpose: <!-- fill: 1 to 2 sentences, what the user can do on this screen; matches the Purpose column of SRS §3 -->
- Priority information: <!-- fill: 1 to 3 pieces of information the user needs most to do the main task of the screen, in priority order, separated by semicolons; each item is a field in SRS §4.2 or a label in §3. The first item comes first and is the most prominent in the layout of §2 (CONVENTIONS §10.7) -->
- Primary action: <!-- fill: exactly one action the user comes to the screen to do, written as a label in a pair of backticks that equals a cell of the Component column in §3, optionally followed by one sentence; write None with a reason when the screen is view-only, or when the actions are peers on purpose (for example choosing between two versions, so as not to steer the user) -->
- Surface: <!-- fill: name of the overlay of the screen, for example frontend-web or mobile-app -->
- Template: `{{TEMPLATE_ID}}` <!-- fill: exactly one TPL-NN that is in the Template catalog of DESIGN_SYSTEM.md §7; the zones in §2 follow the zones of this Template (CONVENTIONS §10.7) -->
- Pattern: <!-- fill: the PAT-NN in the Pattern catalog of DESIGN_SYSTEM.md §6 that the screen uses, separated by commas; write None when the screen uses no pattern -->
- Entry point: `{{ENTRY_POINT}}` <!-- fill: web: the route as in the Route column of SRS §3; mobile: the deep link, or the screen name in the navigator when it cannot be opened by deep link; matches the screen catalog of the index -->
- Actor: `ACT_{{ROLE_CODE}}`
- Release: {{RELEASE}}
- Authentication screen: <!-- fill: choose one: Yes | No. Yes when the screen lets the user sign in, verify identity or re-confirm the account (password, one-time code, biometrics); §6 then records criterion 3.3.8 per CONVENTIONS §10.2 -->

<!-- fill: One row for each FR and AC pair that the screen implements. The FR is in SRS §6.1 and has this SCR ID in the traceability table of the index; the AC is in SRS §8 and belongs to the FR in the same row. An FR with no AC that shows on the screen gets N/A with a reason in the AC ID column. -->

| FR ID | AC ID | Shown on the screen |
| --- | --- | --- |
| FR-{{MODULE_CODE}}-001 | AC-{{MODULE_CODE}}-01 | <!-- fill: the component or state in §3, 4 that shows the AC --> |

## 2. Low-fi Layout

<!-- fill: A text block per CONVENTIONS §7, drawing only the Success state (a form screen whose Success is leaving the screen draws Initial and says so under the block); the other four states are described in §4. Split the screen into zones stacked from top to bottom, with the zone names following the zones of the Template in §1; each zone opens with a line "== N. Zone name ==", zones side by side are written on the same opening line, separated by " | " (for example "== 2. List | 3. Details =="), and a dialog is a zone "== N. Dialog: Name ==". The number N runs consecutively from 1 on the page in reading order, top to bottom and left to right; the number is not part of the zone name, and feedback cites the SCR ID plus the zone number. Under the opening line, each component is one line indented by two spaces: [Label] for a button, "Label: [____]" for an input field, "( ) Label" and "[ ] Label" for choices, "..." for the repeated part of a list. Labels equal the Component column in §3. Web: draw at the smallest breakpoint of SRS §2.5, with no horizontal scroll at that width except for content that needs two dimensions (criterion 1.4.10 in CONVENTIONS §10.2), and record the layout changes at larger breakpoints under the block. Mobile: draw in portrait; the navigation bar, the tab bar and the safe area are separate zones when the screen has them. Do not use images or drawing tools. -->

```text
== 1. Header ==
  [{{COMPONENT_NAME}}]
== 2. Content ==
  {{COMPONENT_NAME}}: [____]
  ...
== 3. Footer ==
  [{{COMPONENT_NAME}}]
```

Edge content: <!-- fill: the edge cases of the data on the screen, taken from constraints that already exist in the SRS (data dictionary §4.2, business rules, flows of the FR), without setting new limits (longest value, empty field, the number 0, a list of many pages), and how the screen shows each case (wrapping, truncation with a way to see it in full, pagination); write None with a reason when the screen shows no data or the SRS has no constraint for that data -->

HTML: <!-- fill: choose one: `docs/wireframes/html/{{SCR_ID}}.html` | None. There is a file when Intake §14 records Stage 1W: Yes, with full HTML (default); None when the Intake records Yes, Markdown only. One static file for this screen, a complete screen built from the design system, per CONVENTIONS §7 and 10.7: every visual value comes from the tokens of docs/design-system/tokens.json through the CSS variables in the :root block; each component of §3 is an element with data-cmp="CMP-NN" (exactly the set of Component IDs of §3); each state of §4 that is not N/A is an element id="state-initial" (or loading, empty, success, error), the state drawn by the layout block in §2 is shown by default and the other states are shown by :target through #state-... links on the page itself; it has a meta viewport tag, and a web page has @media; the zone headings (or an HTML comment before the zone block) carry the same zone numbers as the layout block; the content and sample data are self-made (no real person data, secrets or internal URLs); no script, no external resources, and a meta Content-Security-Policy tag as in CONVENTIONS §7; links only to SCR-*.html files in the same directory. The path is written the same as in the HTML file cell of the screen catalog. -->

## 3. Components

<!-- fill: One row for each component in the layout block, with the same label. The Component ID is a CMP-NN that is in the Component catalog of DESIGN_SYSTEM.md §5; a component that is not in the catalog is added to the catalog first, and the page does not make up an ID. Field in SRS §4 holds the entity or view model name and the field name in SRS §4.2 that the component shows or receives; write None when the component is not bound to data. Action holds what the user does and the result (navigation, submitting data, changing state), citing the FR. -->

| Component | Component ID | Data shown | Field in SRS §4 | Action |
| --- | --- | --- | --- | --- |
| {{COMPONENT_NAME}} | `{{COMPONENT_ID}}` | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. UI States

<!-- fill: Exactly five rows, with the first cell being the state name Initial, Loading, Empty, Success, Error. A state that does not apply gets N/A with a reason in the Display column. The AC column cites the AC in SRS §8 that belongs to the FR of §1, or N/A with a reason. Web: Initial is before the user acts or before loading; Loading includes the time of submitting. Mobile: data already on the device is shown immediately, and Loading applies only when the device does not have the data yet; the sync state of the record (SRS §3) goes in the Display column of Success or Error when the screen edits data while offline. -->

| State | Entry condition | Display | User action | AC |
| --- | --- | --- | --- | --- |
| Initial | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Loading | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Empty | <!-- fill --> | <!-- fill --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Success | <!-- fill --> | <!-- fill: as in the layout block in §2 --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |
| Error | <!-- fill --> | <!-- fill: the message and how to recover; error codes are in the SPEC, not here --> | <!-- fill --> | AC-{{MODULE_CODE}}-01 |

## 5. Navigation

<!-- fill: One row for each entry and exit path; matches the edges of the navigation map in the index. The source or target screen is an SCR ID, or a description when it is outside the catalog (for example a third-party page, another app). Web: parameters are route or query parameters; record the behavior of the browser's back button when it differs from the normal flow. Mobile: record entry from a deep link or push notification, the navigation parameters, and where the system back gesture takes the user. -->

| Direction | Screen | Action or condition | Parameters |
| --- | --- | --- | --- |
| <!-- fill: choose one: In \| Out --> | {{SCR_ID}} | <!-- fill --> | <!-- fill: parameter names, or None --> |

## 6. Accessibility Notes

<!-- fill: Each line below is a WCAG 2.2 criterion that CONVENTIONS §10.2 lists for the accessibility section of the page; read the content and level of the criterion there, and do not copy it here. Criteria apply by the level of the NFR-USAB in SRS §7; a criterion that does not apply, or is not present on this screen, gets N/A with a reason. Platform figures (minimum touch target, system font size) come from the Stage 1W section of the OVERLAY.md of the surface. Criteria 2.4.6 and 3.3.2 are recorded in the components table (§3), 3.3.1 in the Error state (§4), 1.4.10 in the low-fi layout (§2). -->

- `1.1.1`, `4.1.2` Name and role: <!-- fill: the text alternative of an element with no text; the name and role of the interactive elements in §3 -->
- `1.4.4` Text resize: <!-- fill -->
- `2.1.1`, `2.4.3`, `2.4.7` Keyboard and focus: <!-- fill: the focus order or reading order following the layout in §2 -->
- `2.4.11` Focus not obscured: <!-- fill: the fixed elements in the layout of §2 and how the focused element is kept from being fully covered; N/A when the screen has no fixed element -->
- `2.5.7` Dragging: <!-- fill: the drag actions (if any) and how they are replaced by a single tap or click; N/A when the screen has no drag action -->
- `2.5.8` Target size: <!-- fill: the figure from the OVERLAY.md of the surface; exceptions if any -->
- `3.3.7` Redundant entry: <!-- fill: data from the previous step is pre-filled or re-selectable in the Initial state (§4); N/A when the screen is not a later step of a multi-step flow -->
- `3.3.8` Authentication: <!-- fill: when the Authentication screen line in §1 is Yes: the authentication method and the alternative per CONVENTIONS §10.2; N/A when that line is No, or when the NFR-USAB in SRS §7 chooses level A -->
- `4.1.3` Status messages: <!-- fill: the submitting, success and error messages of the screen -->

## 7. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## 8. Version History

| Version | Date | Author | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the pipeline | Not approved |
