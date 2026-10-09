---
doc_type: roadmap
status: active
version: 0.1.0
template_version: 1.0.0
language: en
parent: [docs/srs/SRS.md]
overlays: []
assembled_from: []
---

# {{PROJECT_NAME}}: Roadmap

<!-- fill: Copy to docs/ROADMAP.md on receiving "Approved at Gate 1" (PLAYBOOK §2.7). The roadmap is a to-do list derived from the SRS: on a mismatch, the SRS wins. The rules of each section, the row statuses (Not started, In progress, Done, Confirmed, Dropped), the order and the evidence are in CONVENTIONS §11; the notes below only say how to fill. The coding agent updates the roadmap per PLAYBOOK §2.5, reconciles it per §2.6, and sets Confirmed only on receiving "Approved at Gate 5". The document language: set the language key of the generated document to the language of the project (the language key of the Intake). Frontmatter: parent lists the SRS files; overlays is copied from the Intake; assembled_from records "core/08_Roadmap_Template.md@<template_version>". The roadmap has no gate of its own and no Version History: its history is git. -->

## 1. Progress

<!-- fill: One row per release, in the release order of the Intake (the Timeline row of the constraints). The counts and the In progress line follow CONVENTIONS §11. -->

| Release | Total | Done | Confirmed | Complete |
| --- | --- | --- | --- | --- |
| {{RELEASE}} | <!-- fill --> | 0 | 0 | 0% |

- In progress: None

## 2. Work Queue

### 2.1. Functional Requirements

<!-- fill: One line for each FR in SRS §6.1 whose Priority is other than Won't; Name, Priority and Release are copied from SRS §6.1. SPEC says Not yet before Gate 3, Phase says Not yet before Gate 4; the format of these two columns and the order of the lines follow CONVENTIONS §11. -->

| # | ID | Name | Priority | Release | SPEC | Phase | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | FR-{{MODULE_CODE}}-001 | <!-- fill: short name in SRS §6.1 --> | Must | {{RELEASE}} | Not yet | Not yet | Not started |

### 2.2. Must NFRs

<!-- fill: One line for each NFR in SRS §7 whose Priority is Must, in the order of SRS §7; Name copies the Group column, Verification method copies SRS §7. SPEC lists the SPECs that cite the NFR or says None. Closing release and the way of confirming follow CONVENTIONS §11 and PLAYBOOK §2.7. -->

| # | ID | Name | SPEC | Verification method | Closing release | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | NFR-SEC-01 | <!-- fill: Group column in SRS §7 --> | None | Test | {{RELEASE}} | Not started |

## 3. New Requests

<!-- fill: Ideas or requirements that arise after Gate 1. The agent only records them, it does not do them. The approver of the nearest gate decides: Raise change request (record the document that changes, then follow PLAYBOOK §8) or Dropped (with the reason); undecided is Pending. With no requests, keep one None row. -->

| Date | Content | Raised by | Decision |
| --- | --- | --- | --- |
| None | None | None | None |

## 4. Done

<!-- fill: One row for each Done or Confirmed line in §2: the evidence (TC ID, or the evidence per SRS §8 for an NFR), the commit, the tag (Not yet until Confirmed), per CONVENTIONS §11. With no line done yet, keep one None row. -->

| ID | Evidence | Commit | Tag |
| --- | --- | --- | --- |
| None | None | None | None |

## 5. Milestones

<!-- fill: One row each time a SPEC passes Gate 5, in the order of approval; the tag name follows the Tag format line in Intake §14, and the second time and later for the same SPEC adds the suffix -2, -3 (PLAYBOOK §2.7). Rollback: revert the commit range of the SPEC (PLAYBOOK §2.6) to the previous tag; a phase with a migration follows the rollback section of the phase. With no milestone yet, keep one None row. -->

| Tag | SPEC | Commit | Date | Approver | Rollback method |
| --- | --- | --- | --- | --- | --- |
| None | None | None | None | None | None |
