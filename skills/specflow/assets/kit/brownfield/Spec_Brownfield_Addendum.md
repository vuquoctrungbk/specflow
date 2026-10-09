---
doc_type: spec-addendum
status: stable
version: 1.1.0
language: en
---

# SPEC Addendum for Brownfield Projects (Spec Brownfield Addendum)

Use together with the stage's Spec ([core/04](../core/04_Spec_Core_Template.md) or the starter's SPEC file) when the Intake has `mode: brownfield`. The addendum does not replace the SPEC template; it adds three parts to the SPEC so that every change to running code can be checked against the existing files and keeps the behavior recorded in the [Regression Baseline](02_Regression_Baseline_Template.md). The agent copies each block below into the right place in the SPEC, then fills it in like any other block.

## 1. Replace the File Diff table in SPEC §2.1

The §2.1 table of a brownfield SPEC has two more columns. Read the existing code before filling it in; each row names the exact function or class that changes.

```markdown
| Path | File state | Affected function or class | Change |
| --- | --- | --- | --- |
| <!-- fill: path in inline code --> | <!-- fill: current line count, with or without tests --> | <!-- fill: function, class or route name; with file:line --> | <!-- fill --> |
```

## 2. Append to the end of SPEC §9

The block below goes after every other subsection of §9, including a subsection supplied by an overlay.

```markdown
### 9.2. Regression Behaviors

<!-- fill: Every RB in the "RB that must pass" column of the matching step in docs/brownfield/MIGRATION_PLAN.md §2, and every RB whose evidence lies in a file in §2.1, gets one row. RB with status Keep: the test passes before and after the code change, and the test is not edited. RB with status Change approved: the old test passes before the change; the test file is in §2, the test is updated to the new behavior and has a row in §9.1 tied to the new AC; the last column states the new behavior and the TC ID of the updated test. RB with status Removal approved: the old test passes before the change, the test file or function is deleted in §2, and the "Pass after change" column says N/A. RB that has only a manual procedure: add a new REG test to §2 and to this table, using the as-is module code of the protected behavior per docs/brownfield/GAP_ANALYSIS.md §1.2 and the number after the highest number of the pair of module code and REG in SRS §8, docs/brownfield/REGRESSION_BASELINE.md §6.1 and the SPECs (CONVENTIONS §4). -->

| TC ID | RB ID | Test file | Test name | Pass before change | Pass after change | Behavior after change |
| --- | --- | --- | --- | :---: | :---: | --- |
| TC-{{MODULE_CODE}}-REG-01 | RB-001 | <!-- fill --> | <!-- fill: test name that describes the behavior --> | [ ] | [ ] | <!-- fill: Unchanged, new behavior with the TC ID in §9.1, or Removed --> |
```

## 3. Append to the Definition of Done in SPEC §12

```markdown
- [ ] Every test in §9.2 passes on the current code before the code change; after the change, the tests of RB Keep and the updated tests of RB Change approved pass, and the tests of RB Removal approved are deleted.
- [ ] No behavior changes beyond the RB approved for change in `docs/brownfield/GAP_ANALYSIS.md` §5; external contracts match the snapshot in `docs/brownfield/REGRESSION_BASELINE.md` §5, except for approved differences.
- [ ] The regression checkpoint of the step in `docs/brownfield/MIGRATION_PLAN.md` §6 is met.
- [ ] No refactoring outside the File Diff, even when the code looks like it needs improvement; record the proposal in the Assumptions & Open Questions section.
```

## 4. Rules for writing and executing a brownfield SPEC

- The SPEC frontmatter adds `docs/brownfield/MIGRATION_PLAN.md` and `docs/brownfield/REGRESSION_BASELINE.md` to `parent`, and adds the path of this addendum, with the `version` from its frontmatter, to `assembled_from` (CONVENTIONS §3).
- The File Diff contains only files that belong to the module code of the matching step in Migration Plan §2 (paths per ARCHITECTURE §4.1), plus the test files of RB Change approved, RB Removal approved and the new REG tests in §9.2; the tests of RB Keep are only run and are not in the File Diff.
- The TC of an RB Removal approved has N/A in the "Pass after change" column and does not count toward the criterion "every TC in §9 passes" of PLAYBOOK §10.2 and Prompt 5.
- A new test for existing behavior uses TYPE `REG` (CONVENTIONS §4); a test for new behavior uses the TYPE of a greenfield project. As in Regression Baseline §6.1, every test that protects an RB in §9.2 has type `REG`, even an existing test; a parameterized test is one TC; the TC uses the module code of the protected behavior (`brownfield/PLAYBOOK_BROWNFIELD.md` §5.3).
- Order of execution: run the tests in §9.2 on the current code and record the result in the "Pass before change" column; the tests in §9.2 must be green at once, with no red step. Only then write the tests in §9.1, run them to see them red, and then write the logic as in the workflow in SPEC §12. The first phase of the Implementation Plan records this run.
- The Sync Docs step of the SPEC updates Regression Baseline §3 (the row of an RB that is changed or removed, the "Protected by" column of an RB that gets a new REG test), §6.1 (a row for the new REG test) and the Status column of the step in Migration Plan §2.
