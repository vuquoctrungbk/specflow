---
doc_type: design-system
status: draft
version: 0.1.0
template_version: 1.0.0
language: en
parent: [docs/intake/PROJECT_INTAKE.md, docs/srs/SRS.md]
overlays: []
assembled_from: []
---

# Design System: {{PROJECT_NAME}}

<!-- fill: Copy to docs/design-system/DESIGN_SYSTEM.md at the start of Stage 1W (PLAYBOOK §2.2.1), before the screen pages, only when Intake §14 records Stage 1W: Yes, with full HTML, or Yes, Markdown only. At the same time copy Design_Tokens_Template.json to docs/design-system/tokens.json and replace each token to follow the chosen visual direction; each other mode is a file docs/design-system/tokens.<mode>.json. The JSON file has no frontmatter: its version is the version of this document, so when the JSON file changes, raise the version and record it in Version History in §9. parent names the Intake and the SRS that holds the FRs of the screens (docs/srs/SRS.md, or the master and modules when modular). overlays lists the surfaces of the project that have a UI. assembled_from records "core/07_Wireframe_Template/Design_System_Template.md@<template_version>". The rules of the design system have one source, CONVENTIONS §10.7; the fill comments point there and do not restate the rules. Inputs of §1: the Intake (brand, users, domain), SRS §2 (users), §3 (screens), §7 (NFR-USAB) and the answers of the project owner. Status, version and changes after approval follow the SRS (CONVENTIONS §3, PLAYBOOK §8). The document lists only entries that at least one page uses (CONVENTIONS §10.7, catalog). -->

## 1. Visual Direction

<!-- fill: Propose 2 to 3 directions, one row each; the first column MUST be Direction. The basis cites the brand, users, domain and tone of the project per CONVENTIONS §10.7. The project owner chooses exactly one direction: the Chosen column holds Yes in exactly one row and No in the other rows. -->

| Direction | Description | Basis | Chosen |
| --- | --- | --- | --- |
| <!-- fill: direction name --> | <!-- fill: visual character: color, shape, density, motion --> | <!-- fill: brand, users, domain, tone --> | <!-- fill: choose one: Yes \| No --> |
| <!-- fill: direction name --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |
| <!-- fill: direction name; remove this row when only 2 directions are proposed --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> |

Reason for choice: <!-- fill: why the direction with Chosen = Yes fits better than the others, citing the basis in the table above -->

Library default theme: <!-- fill: choose one: Not used \| Used on purpose, with a reason. The UI library is the library of the stack profile recorded in Intake §14 (OVERLAY.md of the surface, Stage 1W section); with profile none, write that no library has been chosen and revisit at Stage 2 -->

## 2. Foundations

<!-- fill: Each subsection records the decisions of the chosen direction; the concrete values are in tokens.json (§3), and this section records the role and the reason. Platform figures (breakpoints, minimum touch target, system font size) come from the Stage 1W section of the OVERLAY.md of the surface, and are not set again here. -->

### 2.1. Color Roles

<!-- fill: Colors are set by role (background, text, action, border, focus, status), not by color name; each role corresponds to a semantic token in §3 -->

### 2.2. Typography

<!-- fill: the type scale, weight, line height and font family of each text role (body, heading, label); each role corresponds to a typography token -->

### 2.3. Spacing, grid & breakpoint

<!-- fill: the spacing scale, the columns and margins of the grid, the breakpoints; the smallest breakpoint matches SRS §2.5 and the platform figure in the OVERLAY.md of the surface -->

### 2.4. Iconography

<!-- fill: the icon set, sizes, and the rule for pairing with a text label -->

### 2.5. Elevation & radius

<!-- fill: the elevation levels (shadow, layer) and the radius levels, and which kind of element each level is used for -->

### 2.6. Motion

<!-- fill: durations and easing curves by kind of transition; which motion the reduced motion mode replaces or removes -->

### 2.7. Content Voice

<!-- fill: tone, form of address, length of labels and messages, matching the tone in §1 -->

## 3. Token

<!-- fill: Tokens follow DTCG in CONVENTIONS §10.7, in three tier groups: primitive, semantic, component. The mode table: one row for each file; the first row is tokens.json (the default mode). The Applies when column holds the condition for applying the mode, and the surface of the page when the mode differs by platform. The semantic token table summarizes the tokens of tokens.json and of every mode; the token paths are exactly as in the file. -->

| Mode | File | Applies when |
| --- | --- | --- |
| <!-- fill: name of the default mode --> | `docs/design-system/tokens.json` | <!-- fill: the condition for applying; the default mode holds Default --> |
| <!-- fill: name of another mode, or remove this row when the project has only the default mode --> | <!-- fill: docs/design-system/tokens.<mode name>.json; write No file for the default mode --> | <!-- fill: for example a condition of the operating system or the surface --> |

| Token | Type | Value or alias | Role |
| --- | --- | --- | --- |
| <!-- fill: path of a semantic token, for example semantic.color.text.default --> | <!-- fill: DTCG type --> | <!-- fill: the resolved value in the default mode --> | <!-- fill: which element it is used for --> |

<!-- fill: Contrast table by pair (CONVENTIONS §10.7): one row for each pair of colors used together, in each mode; the first column MUST be Foreground token. The background token is the color token of the background behind it. The text token is the typography token of the text row, and holds None in a non-text row. Large text is derived by the checker from the typography token in the Text token column (fontSize, fontWeight), and the author does not declare it. Kind is one of: text | non-text. The threshold is 4.5 (normal text), 3 (large text or non-text). The ratio is computed from the hex values of the two tokens in the mode of the row, rounded down to 2 digits. -->

| Foreground token | Background token | Text token | Mode | Kind | Ratio | Threshold |
| --- | --- | --- | --- | --- | --- | --- |
| <!-- fill: the token of a text color or shape color --> | <!-- fill: the token of the background color --> | <!-- fill: the typography token of the text, or None --> | <!-- fill: a mode from the table above --> | <!-- fill: choose one: text \| non-text --> | <!-- fill: for example 7.25 --> | <!-- fill: 4.5 or 3 --> |

## 4. Primitive

<!-- fill: The smallest visual elements that use tokens directly. One row for each primitive; the Token used is a semantic or component token, not a primitive token (CONVENTIONS §10.7). -->

| Primitive | Purpose | Token used |
| --- | --- | --- |
| <!-- fill: primitive name --> | <!-- fill: visual role --> | <!-- fill: semantic or component token --> |

## 5. Component

<!-- fill: The Component catalog, listing only components that at least one page uses, directly or through the Components used column of another entry that is itself used (CONVENTIONS §10.7). The ID CMP-NN is numbered within the project; the first column MUST be Component ID. The APG pattern is the name of the WAI-ARIA Authoring Practices pattern of the component, or None when the component is not interactive. Variant and State are separated by commas. Tokens used are semantic or component tokens. Components used holds the CMP-NN of the components nested inside, or None. Surface holds the names of the overlays it applies to. -->

| Component ID | Name | APG pattern | Variant | State | Tokens used | Components used | Surface |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{COMPONENT_ID}} | {{COMPONENT_NAME}} | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: CMP-NN, separated by commas, or None --> | <!-- fill: for example frontend-web or mobile-app --> |

<!-- fill: Each component in the table above has a subsection below, in the order of the table: the anatomy (the parts) and the keyboard map per the APG pattern. A component that receives no keyboard input holds No interaction in the keys table. -->

### 5.1. {{COMPONENT_ID}}: {{COMPONENT_NAME}}

Anatomy: <!-- fill: the parts of the component from the outside in, and which token each part uses -->

| Key or action | Behavior |
| --- | --- |
| <!-- fill: the key per the APG pattern, or No interaction --> | <!-- fill --> |

## 6. Pattern

<!-- fill: The Pattern catalog, listing only patterns that at least one page uses. The ID is PAT-NN; the first column MUST be Pattern ID. Components used holds the CMP-NN that are in §5. Flow holds the user's steps in the pattern; States holds the UI states of the pattern (CONVENTIONS §10.1). -->

| Pattern ID | Name | Problem | When to use | When not to use | Components used | Flow | States |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{PATTERN_ID}} | <!-- fill --> | <!-- fill: the interaction problem the pattern solves --> | <!-- fill --> | <!-- fill --> | <!-- fill: CMP-NN, separated by commas --> | <!-- fill --> | <!-- fill --> |

## 7. Template

<!-- fill: The page Template catalog, listing only templates that at least one page uses. The ID is TPL-NN; the first column MUST be Template ID. Zones holds the names of the layout zones from top to bottom, exactly the zone names the page uses in the low-fi layout block (the lines == Zone name ==). Patterns used holds PAT-NN or None; Components used holds CMP-NN. By breakpoint records how the layout changes at breakpoints larger than the smallest breakpoint (mobile: by screen orientation). -->

| Template ID | Name | Zones | Patterns used | Components used | Surface | By breakpoint |
| --- | --- | --- | --- | --- | --- | --- |
| {{TEMPLATE_ID}} | <!-- fill --> | <!-- fill: zone names, separated by commas --> | <!-- fill: PAT-NN, separated by commas, or None --> | <!-- fill: CMP-NN, separated by commas --> | <!-- fill: overlay name --> | <!-- fill --> |

## 8. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## 9. Version History

| Version | Date | Author | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the pipeline | Not approved |
