---
doc_type: gap-analysis
status: draft
version: 0.1.0
template_version: 1.0.0
language: en
parent: [docs/srs/SRS.md, docs/brownfield/CODEBASE_SUMMARY.md, docs/brownfield/AS_IS_ARCHITECTURE.md, docs/brownfield/REGRESSION_BASELINE.md]
overlays: []
assembled_from: []
---

# Gap Analysis: {{PROJECT_NAME}}

<!-- fill: Copy to docs/brownfield/GAP_ANALYSIS.md at step 0d, after the to-be SRS has been written (brownfield/PLAYBOOK_BROWNFIELD.md). For a modular SRS, parent replaces docs/srs/SRS.md with docs/srs/00_SRS_MASTER.md and the module SRS files. The to-be SRS describes the whole target system, including the parts that stay unchanged, so every FR and NFR of the to-be SRS gets one row in §2 or §3. Each row compares one to-be requirement with the current state, with evidence; the conclusion of the document is the list of work in §6 for the to-be Architecture and the Migration Plan. After Gate 1, the document changes only through the change process in PLAYBOOK §8. The frontmatter assembled_from records "brownfield/03_Gap_Analysis_Template.md@<template_version>". -->

## 1. Comparison Scope

### 1.1. Sources

| Item | Value |
| --- | --- |
| To-be SRS | <!-- fill: path and version --> |
| Current state | <!-- fill: Codebase Summary, As-Is Architecture and Regression Baseline, the version of each document and the measured commit --> |

### 1.2. Module Mapping

<!-- fill: Every module code in Codebase Summary §3 and every module in to-be SRS §1.2 appears at least once. A module that stays unchanged reuses its exact as-is code; a new module has a new code; a module that is split or merged gets one row for each pair of codes. A REG test keeps its as-is code in the TC ID and is not renumbered; the last column says which to-be module the REG tests of the as-is code now belong to. -->

| As-is code (Codebase Summary §3) | To-be code (SRS §1.2) | Relation | To-be module of the REG tests |
| --- | --- | --- | --- |
| `{{MODULE_CODE}}` | `{{MODULE_CODE}}` | <!-- fill: choose one: unchanged \| split \| merged \| new \| removed --> | <!-- fill: to-be code, or N/A when there are no REG tests --> |

## 2. Functional Gaps

| FR ID | Current state | Evidence | Work needed | Risk | Affected RB |
| --- | --- | --- | --- | --- | --- |
| FR-{{MODULE_CODE}}-001 | <!-- fill: choose one: Yes \| Partial \| No --> | <!-- fill: file:line or RB ID --> | <!-- fill: choose one: Unchanged \| Modify \| Write new \| Remove; with a short description --> | <!-- fill --> | <!-- fill: RB ID, or None --> |

## 3. Non-functional Gaps

| NFR ID | To-be threshold | Current measurement | How measured | Gap | Work needed |
| --- | --- | --- | --- | --- | --- |
| NFR-PERF-01 | <!-- fill: taken from SRS §7 --> | <!-- fill: the real measurement, or Not measured --> | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 4. Data Gaps

| To-be entity (SRS §4) | Current state (As-Is Architecture §5) | Difference | Data migration needed |
| --- | --- | --- | :---: |
| {{ENTITY_NAME}} | <!-- fill --> | <!-- fill: differences in table, column, type, constraint --> | <!-- fill: choose one: Yes \| No --> |

## 5. Behavior Changes

<!-- fill: Every RB that the to-be SRS changes or removes gets one row. A row here needs the project owner's approval at Gate 1; an RB that does not appear in this table MUST stay unchanged. After Gate 1 approves, the first step of Stage 2 records the status Change approved or Removal approved for these RB in Regression Baseline §3. For an RB that is changed without a reason in the to-be SRS: record a BLOCKING question in §8. -->

| RB ID | Kind | Current behavior | To-be behavior | Reason | Users or systems affected |
| --- | --- | --- | --- | --- | --- |
| RB-001 | <!-- fill: choose one: Change \| Removal --> | <!-- fill --> | <!-- fill: or Gone --> | <!-- fill: related FR, NFR or BR --> | <!-- fill --> |

## 6. Prioritized Summary

| # | Work needed | Source (FR, NFR, data, RB) | Priority | Dependencies |
| --- | --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: P1 \| P2 \| P3 --> | <!-- fill --> |

## 7. Minimal Scope

<!-- fill: A repo under 5,000 lines of code (Codebase Summary §1) is allowed: §3 holds only the NFR whose threshold differs from the current state; §4 records N/A with a reason when the schema does not change. §1, §2, §5 and §6 are always complete. Record the decision in the table; a larger repo records No. -->

| Minimal scope applies | Basis |
| --- | --- |
| <!-- fill: choose one: Yes \| No --> | <!-- fill: line count of code in Codebase Summary §1 --> |

## 8. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## 9. Version History

| Version | Date | Author | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the brownfield pipeline | Not approved |
