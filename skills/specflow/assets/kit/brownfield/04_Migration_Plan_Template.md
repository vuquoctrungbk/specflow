---
doc_type: migration-plan
status: draft
version: 0.1.0
template_version: 1.0.0
language: en
parent: [docs/ARCHITECTURE.md, docs/brownfield/GAP_ANALYSIS.md, docs/brownfield/REGRESSION_BASELINE.md]
overlays: []
assembled_from: []
---

# Migration Plan: {{PROJECT_NAME}}

<!-- fill: Copy to docs/brownfield/MIGRATION_PLAN.md at step 0e, together with Stage 2 (brownfield/PLAYBOOK_BROWNFIELD.md). The plan takes the system from the current state to the to-be ARCHITECTURE in small steps; each step reruns all REG tests and protecting tests, and keeps every RB not yet approved for change in Gap Analysis §5. Each step becomes one or a few SPECs in Stage 3. The document is updated throughout the migration: the Sync Docs step of every SPEC updates the Status column in §2. The frontmatter assembled_from records "brownfield/04_Migration_Plan_Template.md@<template_version>". -->

## 1. Strategy

| Item | Decision |
| --- | --- |
| Migration strategy | <!-- fill: choose one, with an ADR: strangler fig (replace piece by piece behind a routing layer) \| big-bang (replace everything at once) \| parallel run (old and new systems run together and results are compared); give the reason --> |
| ADR | <!-- fill: ADR ID; the ADR MUST be accepted before Gate 2 --> |
| Completion condition | <!-- fill: when the old system can be switched off, and how that is measured --> |

## 2. Ordered Steps

<!-- fill: The "RB that must pass" column holds every RB whose evidence lies within the scope of the step (Regression Baseline §3) and every RB that the step changes or removes per Gap Analysis §5. The SPEC of the step copies this list into §9.2 per brownfield/Spec_Brownfield_Addendum.md. -->

| Step | Module code | Work (Gap Analysis §6) | Start condition | Done condition | RB that must pass | Planned SPEC | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `{{MODULE_CODE}}` | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: RB ID --> | SPEC-{{MODULE_CODE}}-001 | <!-- fill: choose one: not started \| in progress \| done --> |

## 3. Kill Switch & Feature Flags

| Step | Mechanism to switch back to the old system | Who may toggle it | Time to take effect |
| --- | --- | --- | --- |
| 1 | <!-- fill: feature flag, routing, configuration --> | <!-- fill --> | <!-- fill --> |

## 4. Rollback per Step

| Step | How to roll back | Whether data is lost | Estimated time |
| --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill --> |

## 5. Data Migration

<!-- fill: Record N/A with a reason if Gap Analysis §4 has no entity that needs migration. Do a trial run on a copy that is not production, using synthetic or irreversibly anonymised data, before the real run. -->

| Data | Source | Target | How it is moved | Reconciliation after the move | Safe to rerun |
| --- | --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: migration, script, two-way sync --> | <!-- fill: record count, checksum --> | <!-- fill: choose one: Yes \| No --> |

## 6. Regression Checkpoints

- Before and after every step in §2: run all the protecting tests in Regression Baseline §6.1; every RB that is not changed or removed at this step or an earlier step MUST pass, including an RB approved for change that belongs to a later step. An RB that has only a manual procedure runs per Regression Baseline §6.2.
- Compare the external contract with the snapshot in Regression Baseline §5; a difference outside Gap Analysis §5 is a defect.

| Step | Check command | Confirmed by |
| --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> |

## 7. Communication & Maintenance Windows

| Step | Who needs to know | When to notify | Maintenance window |
| --- | --- | --- | --- |
| 1 | <!-- fill --> | <!-- fill --> | <!-- fill: or Not needed --> |

## 8. Minimal Scope

<!-- fill: A repo under 5,000 lines of code (Codebase Summary §1) is allowed: §2 with a single step; §3 and §7 record N/A with a reason when the change is released once outside usage hours. §1, §4 and §6 are always complete. Record the decision in the table; a larger repo records No. -->

| Minimal scope applies | Basis |
| --- | --- |
| <!-- fill: choose one: Yes \| No --> | <!-- fill: line count of code in Codebase Summary §1 --> |

## 9. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## 10. Version History

| Version | Date | Author | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the brownfield pipeline | Not approved |
