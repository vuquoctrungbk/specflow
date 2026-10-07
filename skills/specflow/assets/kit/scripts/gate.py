#!/usr/bin/env python3
"""Record a gate decision in the frontmatter and Version History of project documents.

Usage:
  gate.py PROJECT_DIR approve --gate N --approver NAME [--bump patch|minor|major --note TEXT] [--author NAME] [--date YYYY-MM-DD] FILE...
  gate.py PROJECT_DIR implemented --note TEXT [--bump patch|minor] [--after-review] [--author NAME] [--date YYYY-MM-DD] SPEC_FILE

The agent runs this when it receives "Duyệt Gate N" (PLAYBOOK section 2.7) and at Sync Docs (Prompt 6), instead of
editing frontmatter and history rows by hand. It changes nothing but those two places; the roadmap, the plan phases and
the tag of Gate 5 stay with the agent.

approve, per FILE:
  - status becomes `approved`; an ADR becomes `accepted`; a plan keeps its status (CONVENTIONS section 3 has no
    `approved` for a plan); a SPEC that is already `implemented` keeps it (Gate 5 comes after Sync Docs).
  - version becomes 1.0.0 when it is still 0.x. A document changed after an approval is edited freely while it is
    `draft` or `in-review`; --bump raises its version once, here, when the change is presented at the gate, and
    --note says in the history row what changed. Without --bump a later approval keeps the version the change
    already set; it is refused when that version was approved before, since the change would leave no trace.
  - Version History: the row of that version gets NAME as its approver when it still says "Chưa duyệt"; when there is
    no row for the version, a row "Duyệt Gate N" is added, with as many cells as the table has: the six-column table
    of older templates, or the four-column one (version, date, content, approver). An ADR has no Version History.
  - docs/gates/GATE-N.md gets one row per approved document: the page a later session reads instead of the history
    of the conversation.
implemented:
  - a SPEC that is `approved` becomes `implemented`, its version rises by a PATCH (or a MINOR with --bump minor), and a
    row with TEXT is added whose approver is "Chưa duyệt" until Gate 5 is approved. --after-review also accepts a
    SPEC that went back to `in-review` for a fix found by review (PLAYBOOK section 8).

Nothing is written unless every FILE can be changed: each must be a kit document in a status the action accepts and,
for approve, hold no question whose BLOCKING cell says "Có". Before anything is written, check-templates.sh --project
must report no error for the FILEs themselves or their companion files; errors in other documents of the project are
counted in a note and do not refuse the action. After writing, docs/INDEX.md is rebuilt when it exists.
The exit status is 0 on success and 1 when the action was refused; the reasons are printed, one per line.
"""
import argparse
import datetime
import importlib.util
import pathlib
import re
import subprocess
import sys

sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location("project_index", pathlib.Path(__file__).with_name("project-index.py"))
project_index = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(project_index)

NOT_APPROVED = "Chưa duyệt"
ROW_RE = re.compile(r"^\| *(\d+\.\d+\.\d+) *\|.*\|\s*$")
# doc_type -> (statuses the approval accepts, status after approval; None keeps the current one)
APPROVE = {
    "adr": (("proposed",), "accepted"),
    "implementation-plan": (("pending", "in-progress"), None),
    "spec": (("draft", "in-review", "implemented"), "approved"),
}
DEFAULT_APPROVE = (("draft", "in-review"), "approved")
NO_HISTORY = ("adr", "implementation-phase", "agent-context", "agent-rule", "roadmap")


class Refused(Exception):
    pass


def split_row(line):
    return [c.strip() for c in re.split(r"(?<!\\)\|", line.strip().strip("|"))]


def set_frontmatter(lines, key, value):
    """Replace the value of a frontmatter key, keeping the quotes the line had."""
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            break
        m = re.match(rf"^{key}:\s*(\"?)[^\"]*(\"?)\s*$", line)
        if m:
            lines[i] = f"{key}: {m.group(1)}{value}{m.group(2)}"
            return
    raise Refused(f"frontmatter has no {key}")


def history_rows(lines):
    """Indexes of the rows of the Version History table, in order."""
    start = next((i for i, l in enumerate(lines) if re.match(r"^#+ .*Version History", l)), None)
    if start is None:
        return None
    rows = []
    for i in range(start + 1, len(lines)):
        if re.match(r"^#+ ", lines[i]):
            break
        if ROW_RE.match(lines[i]):
            rows.append(i)
    return rows


def write_history(lines, version, date, author, content, reason, approver):
    """Set the approver of the row of `version`, or add a row for it after the last one."""
    rows = history_rows(lines)
    if not rows:
        raise Refused("has no Version History table with a version row")
    for i in rows:
        cells = split_row(lines[i])
        if cells[0] == version:
            if approver != NOT_APPROVED and cells[-1] == NOT_APPROVED:
                cells[-1] = approver
                lines[i] = "| " + " | ".join(cells) + " |"
            return
    width = len(split_row(lines[rows[-1]]))
    if width == 6:
        row = f"| {version} | {date} | {author} | {content} | {reason} | {approver} |"
    elif width == 4:
        row = f"| {version} | {date} | {content} | {approver} |"
    else:
        raise Refused(f"Version History rows have {width} cells, not 4 or 6")
    lines.insert(rows[-1] + 1, row)


def bump(version, part):
    major, minor, patch = (int(x) for x in version.split("."))
    return {"major": f"{major + 1}.0.0", "minor": f"{major}.{minor + 1}.0"}.get(part, f"{major}.{minor}.{patch + 1}")


def plan_change(root, name, args):
    """Return (path, new lines) for one file, or raise Refused."""
    path = (root / name).resolve()  # a relative FILE is read from the project root
    if not path.is_file():
        raise Refused("no such file")
    doc = project_index.Document(root, path) if path.is_relative_to(root) else None
    if doc is None or not doc.doc_type:
        raise Refused("is not a kit document of this project (no doc_type in its frontmatter)")
    status, version = doc.meta.get("status", ""), doc.meta.get("version", "")
    if not re.match(r"^\d+\.\d+\.\d+$", version):
        raise Refused(f"version '{version}' is not SemVer")
    lines = path.read_text(encoding="utf-8").split("\n")
    if args.action == "approve":
        accepted, target = APPROVE.get(doc.doc_type, DEFAULT_APPROVE)
        if status not in accepted:
            raise Refused(f"status '{status}' cannot be approved (expected {' or '.join(accepted)})")
        blocking = project_index.open_blocking(doc)
        if blocking:
            raise Refused(f"still has BLOCKING question(s) {', '.join(blocking)}")
        if status == "implemented" and args.bump:
            raise Refused("is implemented: Gate 5 confirms the version it has, so --bump does not apply")
        if doc.doc_type not in NO_HISTORY and status != "implemented" and not version.startswith("0.") and not args.bump:
            rows = history_rows(lines) or []
            if any(split_row(lines[i])[0] == version and split_row(lines[i])[-1] != NOT_APPROVED for i in rows):
                raise Refused(f"version {version} was approved before; pass --bump and --note for the change being presented")
        if target and status != "implemented":
            set_frontmatter(lines, "status", target)
        if version.startswith("0."):
            version = "1.0.0"
            set_frontmatter(lines, "version", version)
        elif args.bump:
            version = bump(version, args.bump)
            set_frontmatter(lines, "version", version)
        if doc.doc_type not in NO_HISTORY:
            content = f"{args.note} (Gate {args.gate})" if args.note else f"Duyệt Gate {args.gate}"
            write_history(lines, version, args.date, args.author, content, f"{args.approver} duyệt", args.approver)
    else:
        if doc.doc_type != "spec":
            raise Refused("only a SPEC becomes implemented")
        if status == "in-review" and not args.after_review:
            raise Refused("status 'in-review' cannot become implemented; pass --after-review when the SPEC was implemented "
                          "and went back to in-review for a fix found by review")
        if status == "in-review":
            rows = history_rows(lines) or []
            if version.startswith("0.") or not any(split_row(lines[i])[-1] != NOT_APPROVED for i in rows):
                raise Refused("was never approved; --after-review is for a SPEC that passed Gate 3 before the fix")
        if status not in ("approved", "in-review"):
            raise Refused(f"status '{status}' cannot become implemented (expected approved)")
        version = bump(version, args.bump)
        set_frontmatter(lines, "status", "implemented")
        set_frontmatter(lines, "version", version)
        write_history(lines, version, args.date, args.author, args.note, "Sync Docs sau khi hiện thực (PLAYBOOK mục 2.6)", NOT_APPROVED)
    return path, lines, version


GATES_DIR = "docs/gates"
GATE_HEADER = "| Ngày | Người duyệt | Tài liệu | Version | Trạng thái |\n| --- | --- | --- | --- | --- |\n"


def write_gate_page(root, args, approved):
    """Add one row per approved document to docs/gates/GATE-N.md, the page a new session reads to resume."""
    page = root / GATES_DIR / f"GATE-{args.gate}.md"
    page.parent.mkdir(parents=True, exist_ok=True)
    text = page.read_text(encoding="utf-8") if page.is_file() else (
        f"<!-- Written by specflow/scripts/gate.py. Do not edit. -->\n\n# Gate {args.gate}\n\n" + GATE_HEADER)
    for path, lines, version in approved:
        status = next((l.split(":", 1)[1].strip() for l in lines[1:40] if l.startswith("status:")), "")
        row = f"| {args.date} | {args.approver} | `{path.relative_to(root).as_posix()}` | {version} | {status} |\n"
        text += "" if row in text else row  # approving Gate 5 again for the same version adds nothing
    page.write_text(text, encoding="utf-8")
    return page.relative_to(root).as_posix()


def project_errors(root, files):
    """(ERROR lines about `files` or their companion files, number of ERROR lines about other documents)."""
    res = subprocess.run(["bash", str(pathlib.Path(__file__).with_name("check-templates.sh")), "--project", str(root)],
                         capture_output=True, text=True)
    if res.returncode == 0:
        return [], 0
    lines = [line for line in (res.stdout + res.stderr).splitlines() if line.startswith("ERROR")]
    if not lines:
        return [f"check-templates.sh exited {res.returncode}"], 0
    stems = [re.escape(re.sub(r"\.md$", "", path.relative_to(root).as_posix())) + "[.:]" for path in files]
    # a plan is approved with its phases, which have no approval of their own
    stems += [re.escape(path.parent.relative_to(root).as_posix()) + "/phase-" for path in files if path.name == "plan.md"]
    mine = [line for line in lines if any(re.match(rf"ERROR\s+{stem}", line) for stem in stems)]
    return mine, len(lines) - len(mine)


def main(argv=None):
    parser = argparse.ArgumentParser(description="Record a gate decision in project documents.")
    parser.add_argument("project")
    sub = parser.add_subparsers(dest="action", required=True)
    approve = sub.add_parser("approve")
    approve.add_argument("--gate", required=True)
    approve.add_argument("--approver", required=True)
    approve.add_argument("--bump", choices=("patch", "minor", "major"))
    approve.add_argument("--note")
    done = sub.add_parser("implemented")
    done.add_argument("--note", required=True)
    done.add_argument("--bump", choices=("patch", "minor"), default="patch")
    done.add_argument("--after-review", action="store_true")
    for p in (approve, done):
        p.add_argument("--author", default="Claude Code")
        p.add_argument("--date", default=datetime.date.today().isoformat())
        p.add_argument("files", nargs="+")
    args = parser.parse_args(argv)
    root = pathlib.Path(args.project).resolve()
    if not (root / "docs").is_dir():
        raise SystemExit(f"gate: {args.project} has no docs/ directory")
    if args.action == "implemented" and len(args.files) != 1:
        raise SystemExit("gate: implemented takes one SPEC file")
    if args.action == "approve" and not re.fullmatch(r"[0-9A-Za-z]+", args.gate):
        raise SystemExit("gate: --gate takes a gate name such as 3 or 1W")
    if args.action == "approve" and bool(args.bump) != bool(args.note):
        raise SystemExit("gate: --bump and --note go together: the note says what the change being approved is")
    if any(re.search(r"[|\r\n]", text) for text in (getattr(args, "approver", ""), getattr(args, "note", "") or "", args.author)):
        raise SystemExit("gate: a name or note must not contain '|' or a line break")
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", args.date):
        raise SystemExit("gate: --date is YYYY-MM-DD")
    changes, refused = [], []
    for name in args.files:
        try:
            changes.append(plan_change(root, name, args))
        except Refused as reason:
            refused.append(f"REFUSED {name}: {reason}")
    if refused:
        print("\n".join(refused))
        print("nothing was changed")
        return 1
    problems, elsewhere = project_errors(root, [path for path, _lines, _version in changes])
    if problems:
        print("\n".join(f"REFUSED {line}" for line in problems))
        print("nothing was changed")
        return 1
    if elsewhere:
        print(f"note: check-templates.sh reports {elsewhere} error(s) in other documents of the project; they do not block this action")
    for path, lines, _version in changes:
        path.write_text("\n".join(lines), encoding="utf-8")
        print(f"updated {path.relative_to(root)}")
    if args.action == "approve":
        print(f"recorded {write_gate_page(root, args, changes)}")
    if (root / project_index.INDEX).is_file():
        (root / project_index.INDEX).write_text(project_index.build(project_index.load(root)), encoding="utf-8")
        print(f"rebuilt {project_index.INDEX}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
