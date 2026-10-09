---
doc_type: regression-baseline
status: draft
version: 0.1.0
template_version: 1.1.0
language: en
parent: [docs/brownfield/CODEBASE_SUMMARY.md, docs/brownfield/AS_IS_ARCHITECTURE.md]
overlays: []
assembled_from: []
---

# Regression Baseline: {{PROJECT_NAME}}

<!-- fill: Copy to docs/brownfield/REGRESSION_BASELINE.md at step 0c (brownfield/PLAYBOOK_BROWNFIELD.md). The document fixes the existing behavior that must be preserved before the code changes, and is updated throughout the migration: the Status column in §3 changes when Gap Analysis §5 approves changing or removing a behavior. Numbers come from commands that were really run on the commit in §1. Until Gate 0R is met (brownfield/PLAYBOOK_BROWNFIELD.md §3), the to-be SRS is not written. The frontmatter assembled_from records "brownfield/02_Regression_Baseline_Template.md@<template_version>". -->

## 1. Measurement Context

| Item | Value |
| --- | --- |
| Measured commit | <!-- fill: full commit hash, matching Codebase Summary §1 (HEAD after the commit of Prompt B0) --> |
| Commit containing the REG tests | <!-- fill: a single separate commit that only adds test files, test data, and approved test configuration and dependencies; it is a descendant of the measured commit, not necessarily a direct child (a commit in between only changes documents and agent configuration). Also record the Git hook that was skipped and the secret-scan result of this commit (brownfield/PLAYBOOK_BROWNFIELD.md §5.1 rule 8). Record N/A if no tests are added --> |
| Measurement date | {{DATE}} |
| Test command | <!-- fill: command, taken from Codebase Summary §7 --> |
| Test coverage tool | <!-- fill: choose one per the row of the same name in Intake §4: already present (name and version) \| installed temporarily in the measurement worktree (name and version; not in the manifest or lockfile) \| added as a dev-dependency at the REG commit (name and version; the number at the measured commit is still measured with the temporary install) \| measured another way (method and limits, for example lines only). If the Intake has no such row, record the way the project owner chose and a question in §11 --> |
| Coverage command | <!-- fill: the command at the measured commit and the command at the commit containing the REG tests if different; for a temporary install, record the install command too --> |
| Test result | <!-- fill: number passed, failed, skipped; tests that already fail are listed in §7 --> |

## 2. Current Coverage

<!-- fill: Measure twice with the tool and the command in §1: on the measured commit (existing tests only) and on the commit containing the REG tests. If no REG tests are added, the later column says N/A. If the tool cannot measure branches (for example measured another way, lines only), the Branches covered column says N/A with a reason. -->

| Module code (Codebase Summary §3) | Lines covered, measured commit | Lines covered, commit with REG tests | Branches covered | Notes |
| --- | --- | --- | --- | --- |
| `{{MODULE_CODE}}` | <!-- fill: percentage --> | <!-- fill: percentage, or N/A --> | <!-- fill: percentage, or N/A with a reason --> | <!-- fill --> |

## 3. Behaviors to Preserve

<!-- fill: Every behavior that can be observed from outside (an API response, a screen, an exported file, an event, written data) and that users or other systems rely on gets one row RB-NNN. The source is the main flows in Codebase Summary §5. The Protected by column records the TC ID in §6.1 (a newly written REG test, or an existing test that has been assigned a TC ID), or "manual procedure" in §6.2; an RB of level Should that has no test records None. The Status column: Keep when first created; Change approved or Removal approved once Gap Analysis §5 is approved, with the version of the Gap Analysis. When the SPEC that makes that change moves to implemented, the Sync Docs step updates the row: a changed RB records the new behavior and the new test in the Protected by column and returns to Keep; a removed RB records deprecated, the row is kept, and the ID is not reused. -->

| RB ID | Module code | Behavior | Evidence source | Protected by | Priority | Status |
| --- | --- | --- | --- | --- | --- | --- |
| RB-001 | `{{MODULE_CODE}}` | <!-- fill: a verifiable statement, with the input and the result --> | <!-- fill: file:line or a recorded request and response --> | TC-{{MODULE_CODE}}-REG-01 | <!-- fill: choose one: Must \| Should --> | <!-- fill: choose one: Keep \| Change approved \| Removal approved \| deprecated --> |

## 4. Golden Data

<!-- fill: By default use synthetic data. Data taken from production is used only when it has been irreversibly anonymised and the project owner approves; data that is only renamed or pseudonymised is still personal data and is not used. It contains no secret, token, cookie or API key. -->

| Dataset | Stored at | How to regenerate | Data source |
| --- | --- | --- | --- |
| <!-- fill --> | <!-- fill: path in the repo --> | <!-- fill: command or script --> | <!-- fill: choose one: synthetic \| irreversibly anonymised (record the approver) --> |

## 5. Current Contract Snapshot

<!-- fill: The external contract exactly as the system returns it now, used for comparison after every change: the existing OpenAPI document, recorded requests and responses, screenshots, the schema of exported files. The agent captures in an environment that uses the data in §4, not from production. Before saving, mask all personal data and every secret, token, cookie, authentication header and API key. A recording from production is accepted only when the project owner supplies it personally, masked as above; the Capture environment column records who supplied it. -->

| Contract | Stored form | Stored at | Capture environment | How to compare |
| --- | --- | --- | --- | --- |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill: command or test --> |

## 6. Characterization Protection

### 6.1. Regression Tests

<!-- fill: Each test that protects a behavior gets one row: a REG test newly written at this step and an existing test of the repo (assign a TC ID, record the exact existing file and name). The test describes the current behavior, even behavior that looks wrong (note it in the last column so that the Gap Analysis decides), and must pass on the product code of the measured commit. Add only test files, synthetic test data, and test configuration and dependencies approved at Gate 0; do not edit product code. A REG test that a SPEC adds later is added to the table at the Sync Docs step, numbered next in sequence. The test name describes the behavior in English and contains no TC ID or RB ID. The TC ID follows CONVENTIONS §4 and brownfield/PLAYBOOK_BROWNFIELD.md §5.3: every test in this table has type REG, even an existing test; a parameterized test is one TC; the TC uses the module code in Codebase Summary §3 of the protected behavior, not the module code of the directory that holds the test file; NN is unique per pair of module code and type across the whole project; do not renumber afterwards. A newly written REG test follows the loop in brownfield/PLAYBOOK_BROWNFIELD.md §5.1 rule 9. -->

| TC ID | RB ID | Scenario (Given-When-Then) | Test file | Test name | Notes |
| --- | --- | --- | --- | --- | --- |
| TC-{{MODULE_CODE}}-REG-01 | RB-001 | **Given:** <!-- fill --><br>**When:** <!-- fill --><br>**Then:** <!-- fill --> | <!-- fill --> | <!-- fill: test name that describes the behavior --> | <!-- fill --> |

### 6.2. Manual Procedures

<!-- fill: Used when the project owner does not allow adding tests at this step, or the repo has no test tool and Gate 0 does not approve adding one (Intake §4). Each RB of level Must that has no test gets one row; the project owner approves the risk. Record N/A when every RB of level Must has a test. -->

| RB ID | Check steps | Expected result | Performed by | Risk accepted by the project owner |
| --- | --- | --- | --- | :---: |
| <!-- fill --> | <!-- fill --> | <!-- fill --> | <!-- fill --> | [ ] |

## 7. Pre-existing Failing Tests

| Test (file and name) | Error, shortened | Cause, if known | Handling |
| --- | --- | --- | --- |
| <!-- fill: or None --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: fix in a SPEC \| skip with a reason \| delete after the Gap Analysis approves --> |

## 8. Gate 0R Self-check

The full Gate 0R is in PLAYBOOK_BROWNFIELD §3; the table below holds the criteria that belong to this document, worded the same as in that section.

| Criterion | Met? |
| --- | :---: |
| §1 and §2 have figures from commands that were run; §2 per module, or one line for the whole repo when §9 says Yes | [ ] |
| Every main flow in Codebase Summary §5 has at least one RB | [ ] |
| Every Must-level RB has a protecting test that passes on the product code of the measured commit, or the manual procedure in §6.2 is accepted by the project owner | [ ] |
| The external contract is captured in §5 on the data in §4 | [ ] |
| Pre-existing failing tests are listed in §7 | [ ] |
| No BLOCKING question remains in §11 | [ ] |

## 9. Minimal Scope

<!-- fill: A repo under 5,000 lines of code (Codebase Summary §1) is allowed to record §2 as one line for the whole repo and to record N/A in §4 when the system has no fixed data to preserve. §3, §5, §6 and §8 are always complete. Record the decision in the table; a larger repo records No. -->

| Minimal scope applies | Basis |
| --- | --- |
| <!-- fill: choose one: Yes \| No --> | <!-- fill: line count of code in Codebase Summary §1 --> |

## 10. Links

| Type | Reference |
| --- | --- |
| Behaviors approved for change or removal | `docs/brownfield/GAP_ANALYSIS.md` §5 |
| Migration step and the RB that must pass | `docs/brownfield/MIGRATION_PLAN.md` §2, §6 |

## 11. Assumptions & Open Questions

| ID | Type | Content | Reason or impact | BLOCKING | Respondent |
| --- | --- | --- | --- | :---: | --- |
| AQ-01 | <!-- fill: choose one: Assumption \| Question --> | <!-- fill --> | <!-- fill --> | <!-- fill: choose one: Yes \| No --> | <!-- fill --> |

## 12. Version History

| Version | Date | Author | Change | Reason and requester | Approver |
| --- | --- | --- | --- | --- | --- |
| 0.1.0 | {{DATE}} | {{AUTHOR}} | Initial version | Created by the brownfield pipeline | Not approved |
