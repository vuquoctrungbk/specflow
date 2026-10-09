---
doc_type: adr
status: proposed
version: 0.1.0
template_version: 1.0.1
language: en
adr_id: "ADR-{{ADR_NUMBER}}"
date: "{{DATE}}"
deciders: []
parent: [docs/ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# ADR-{{ADR_NUMBER}}: {{ADR_TITLE}}

<!-- fill: Copy to docs/adr/NNNN-<slug>.md, NNNN increasing, slug in English kebab-case. Follows MADR 4.0.0 with adjustments: keeps the deciders key (MADR 4.0.0 calls it decision-makers) and a more compact section layout. The document language: set the language key of the generated document to the language of the project (the language key of the Intake). Status: proposed while awaiting approval; accepted once approved; rejected when the approver does not accept it, keep the file to record the rejected option; deprecated or superseded when it is no longer in force. One ADR may group several choices on the same topic (PLAYBOOK §2.3). An accepted ADR does not change its decision content; to change the decision, create a new ADR, set this ADR to status superseded and add the key superseded_by to the frontmatter. Record deciders as the list of decision makers; assembled_from records "core/03_ADR_Template.md@<template_version>". Add the ADR to ARCHITECTURE §12. -->

## 1. Context and Problem Statement

<!-- fill: the situation that forces a decision, the relevant constraints, the question to answer. Write it so that a reader one year later still understands why a choice had to be made. -->

## 2. Decision Drivers

<!-- fill: one driver per line, with an ID if it has one (NFR, FR, BR, constraint in Intake §6). -->

## 3. Considered Options

<!-- fill: at least two options, including the simplest option or doing nothing. One row per option. -->

| Option | Description | Pros | Cons |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. Decision Outcome

- Chosen option: <!-- fill -->
- Reason: <!-- fill: check against each driver in §2 -->
- Mandatory choices covered by this ADR: <!-- fill: placeholders that ARCHITECTURE forces a choice for, and the chosen value, for example the token signing method; write "None" if there are none -->

## 5. Consequences

| Type | Consequence |
| --- | --- |
| Good | <!-- fill --> |
| Bad or accepted cost | <!-- fill --> |
| Follow-up work | <!-- fill: documents, SPECs, configuration to update; write "None" if there are none --> |

## 6. Confirmation

<!-- fill: how to detect code that goes against the decision: a specific test (TC ID), a linter rule, a CI check, a review checkpoint. -->

## 7. Links

| Type | Reference |
| --- | --- |
| Requirements | <!-- fill: FR, NFR, BR IDs --> |
| Architecture section | <!-- fill: section in ARCHITECTURE --> |
| Related SPEC | <!-- fill: SPEC ID or "None" --> |
| Supersedes ADR | <!-- fill: ID of the ADR this ADR supersedes, or "None" --> |

## 8. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |
