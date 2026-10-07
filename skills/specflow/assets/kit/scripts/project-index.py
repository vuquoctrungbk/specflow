#!/usr/bin/env python3
"""Build and query the index of a project's documents, so an agent looks things up instead of searching for them.

Usage:
  project-index.py PROJECT_DIR                    write PROJECT_DIR/docs/INDEX.md
  project-index.py PROJECT_DIR --check            exit 1 when docs/INDEX.md is missing or out of date
  project-index.py PROJECT_DIR --where ID [ID...] where each ID is defined and which files mention it
  project-index.py PROJECT_DIR --outline FILE     headings of FILE with the line range of each section

PROJECT_DIR holds docs/ and, once Stage 4 started, plans/. docs/INDEX.md is generated: nobody edits it by hand.
It lists every document with its frontmatter, every SPEC with the requirements it satisfies and the test case
numbers it uses, the next free test case number of each (module, type) pair, and the blocking questions still
open. An ID is any token of CONVENTIONS section 4 (FR-AUTH-001, TC-ORD-INT-07, ADR-0003, an error code).

--where prints one line per place, "file:line  section", so the caller reads that range and nothing else.
A place defines the ID when the ID is the first cell of a table row, or part of a heading, in the kind of document
that section 4 names as its home; the same form in any other document is listed under "restated".
"""
import argparse
import pathlib
import re
import sys

sys.dont_write_bytecode = True  # the script sits in a read-only kit folder of the project

INDEX = "docs/INDEX.md"
TC_RE = re.compile(r"^TC-([A-Z0-9]+(?:-[A-Z0-9]+)??)-([A-Z0-9]+)-(\d+)$")
TC_ANY_RE = re.compile(r"(?<![A-Za-z0-9-])TC-([A-Z0-9]+(?:-[A-Z0-9]+)??)-([A-Z0-9]+)-(\d+)(?![A-Za-z0-9])")
REQ_RE = re.compile(r"^(?:FR|NFR)-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+$")
SEPARATOR_RE = re.compile(r"^\|\s*:?-{3,}")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
TRACE_RE = re.compile(r"\b(?:AC|NFR)-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+\b")  # what a test row of SPEC section 9 verifies
COMPANION_RE = re.compile(r"^\s*Tệp đi kèm:\s*`([^`]+)`")  # CONVENTIONS section 7: a machine-readable block kept in its own file
# Which doc_type is the home of an ID, by its prefix (CONVENTIONS section 4). Any other token has its home in the
# architecture document, where the error code registry is.
HOMES = (
    ("GOAL-", ("intake",)), ("MOD-", ("srs",)), ("BR-", ("srs", "srs-module")),
    ("FR-", ("srs", "srs-module")), ("NFR-", ("srs", "srs-module")), ("AC-", ("srs", "srs-module")),
    ("TC-", ("spec", "regression-baseline")), ("SCR-", ("wireframe-screen", "srs", "srs-module")),
    ("CMP-", ("design-system",)), ("PAT-", ("design-system",)), ("TPL-", ("design-system",)),
    ("ADR-", ("adr",)), ("SPEC-", ("spec",)), ("PROMPT-", ("prompt-spec",)), ("RB-", ("regression-baseline",)),
)
OWN_ID = {"spec": "spec_id", "adr": "adr_id", "prompt-spec": "prompt_id"}


def cells(line):
    """Cells of a table row; an escaped pipe stays inside its cell."""
    body = line.strip()
    body = body[1:] if body.startswith("|") else body
    body = body[:-1] if body.endswith("|") and not body.endswith("\\|") else body
    return [c.replace("\\|", "|").strip().strip("`").strip() for c in re.split(r"(?<!\\)\|", body)]


class Document:
    """One markdown file: its frontmatter, its headings, and its lines with fenced blocks blanked."""

    def __init__(self, root, path):
        self.path = path.relative_to(root).as_posix()
        raw = [line.removesuffix("\r") for line in path.read_text(encoding="utf-8", errors="replace").split("\n")]
        if raw and raw[-1] == "":
            raw.pop()  # the newline that ends the file starts no line
        self.raw = raw  # every line as written; self.lines blanks the frontmatter and fenced blocks
        self.line_count = len(raw)
        self.meta = {}
        body_start = 0
        if raw and raw[0].strip() == "---":
            meta = {}
            for i, line in enumerate(raw[1:], 1):
                if line.strip() == "---":
                    body_start = i + 1
                    self.meta = meta  # frontmatter that is never closed is not frontmatter
                    break
                m = re.match(r"^([a-z_]+):\s*(.*?)\s*$", line)
                if m:
                    value = m.group(2)
                    if not value.startswith(("\"", "'")):
                        value = re.sub(r"\s+#.*$", "", value)  # a trailing YAML comment
                    meta[m.group(1)] = value.strip("\"'")
        self.lines, fence = [], False
        self.open_fence = 0  # line of a code fence that is never closed, or 0
        for i, line in enumerate(raw):
            if i < body_start:
                self.lines.append("")
            elif FENCE_RE.match(line):
                fence = not fence
                self.open_fence = i + 1 if fence else 0
                self.lines.append("")
            else:
                self.lines.append("" if fence else line)
        self.headings = [(i + 1, len(m.group(1)), m.group(2))
                         for i, line in enumerate(self.lines) if (m := HEADING_RE.match(line))]
        self.companions = [(i + 1, m.group(1)) for i, line in enumerate(self.lines) if (m := COMPANION_RE.match(line))]

    @property
    def doc_type(self):
        return self.meta.get("doc_type", "")

    @property
    def doc_id(self):
        """The ID this document is the home of; a phase that names its SPEC in spec_id has none."""
        key = OWN_ID.get(self.doc_type)
        return self.meta.get(key, "") if key else ""

    def section_of(self, line_no):
        """Text of the nearest heading at or above a line."""
        title = ""
        for start, _level, text in self.headings:
            if start > line_no:
                break
            title = text
        return title

    def section_lines(self, title_re):
        """(line number, line) of the section whose heading matches, up to the next heading of the same or a higher level."""
        for n, (start, level, text) in enumerate(self.headings):
            if not re.search(title_re, text):
                continue
            end = next((s for s, lv, _ in self.headings[n + 1:] if lv <= level), self.line_count + 1)
            return [(i, self.lines[i - 1]) for i in range(start + 1, end)]
        return []

    def table_rows(self, numbered_lines=None):
        """(line number, cells) of every data row; header and separator rows are dropped."""
        numbered = numbered_lines if numbered_lines is not None else list(enumerate(self.lines, 1))
        out = []
        for n, (line_no, line) in enumerate(numbered):
            if not line.startswith("|") or SEPARATOR_RE.match(line):
                continue
            if n + 1 < len(numbered) and SEPARATOR_RE.match(numbered[n + 1][1]):
                continue
            out.append((line_no, cells(line)))
        return out


def is_plain_file(root, name):
    """True when `name` is a regular file under root. A symlink at any step of the path is refused, since it can lead outside the project."""
    current = root
    for part in name.split("/"):
        current = current / part
        if current.is_symlink():
            return False
    return current.is_file()


def load(root):
    """Every document of the project in a stable order; the index itself is left out."""
    paths = sorted(p for d in ("docs", "plans") if (root / d).is_dir() for p in (root / d).rglob("*") if p.suffix.lower() == ".md")
    return [Document(root, p) for p in paths if p.relative_to(root).as_posix() != INDEX]


def homes_of(token):
    return next((types for prefix, types in HOMES if token.startswith(prefix)), ("architecture",))


def where(root, docs, token):
    """Lines that define the token, lines that restate it in the same form elsewhere, and files that mention it."""
    word = re.compile(rf"(?<![A-Za-z0-9_-]){re.escape(token)}(?![A-Za-z0-9_]|-[A-Za-z0-9])")
    defined, restated, mentions = [], [], []
    for doc in docs:
        count = sum(len(word.findall(line)) for line in doc.lines)
        owns = doc.doc_id == token
        if not count and not owns:
            continue
        home = owns or doc.doc_type in homes_of(token)
        places = [(1, "frontmatter")] if owns else []
        places += [(n, text) for n, _lv, text in doc.headings if word.search(text)]
        places += [(n, doc.section_of(n)) for n, row in doc.table_rows() if row and row[0] == token]
        if home and not places:
            # An ID that is never a first cell (an AC in the traceability table): the rows of its home that hold it.
            places = [(n, doc.section_of(n)) for n, row in doc.table_rows() if any(word.search(c) for c in row)]
        target = defined if home else restated
        target.extend((doc.path, n, section) for n, section in sorted(set(places)))
        mentions.append((doc.path, count))
    for doc in docs:
        for _n, name in doc.companions:
            path = root / name
            if ".." not in name.split("/") and is_plain_file(root, name):
                count = len(word.findall(path.read_text(encoding="utf-8", errors="replace")))
                if count:
                    mentions.append((name, count))
    return defined, restated, mentions


def merged(places):
    """Join the places of one file and section that sit on consecutive lines into one "first-last" span."""
    out = []
    for path, line_no, section in places:
        if out and out[-1][0] == path and out[-1][3] == section and line_no == out[-1][2] + 1:
            out[-1][2] = line_no
        else:
            out.append([path, line_no, line_no, section])
    return [(path, str(a) if a == b else f"{a}-{b}", section) for path, a, b, section in out]


def print_where(root, docs, tokens):
    for token in tokens:
        defined, restated, mentions = where(root, docs, token)
        print(token)
        if not mentions:
            print("  not found")
            continue
        for label, places in (("defined", defined), ("restated", restated)):
            for path, span, section in merged(places):
                print(f"  {label}  {path}:{span}  {section}")
        print("  mentioned in  " + ", ".join(f"{path} ({count})" for path, count in mentions))


def print_outline(root, name):
    path = (root / name) if (root / name).is_file() else pathlib.Path(name)
    if not path.is_file():
        raise SystemExit(f"project-index: no such file: {name}")
    doc = Document(path.parent, path)
    for n, (start, level, text) in enumerate(doc.headings):
        end = next((s - 1 for s, lv, _ in doc.headings[n + 1:] if lv <= level), doc.line_count)
        print(f"{start:>5}-{end:<5} {'  ' * (level - 1)}{text}")


def tc_ranges(numbers):
    """'INT 1-3, 7; UNIT 1-4' from {type: [numbers]}."""
    parts = []
    for kind in sorted(numbers):
        spans = []
        for n in sorted(set(numbers[kind])):
            if spans and n == spans[-1][1] + 1:
                spans[-1][1] = n
            else:
                spans.append([n, n])
        parts.append(f"{kind} " + ", ".join(str(a) if a == b else f"{a}-{b}" for a, b in spans))
    return "; ".join(parts)


def open_blocking(doc):
    """IDs of the questions of a document whose BLOCKING cell still says "Có"."""
    out = []
    numbered = doc.section_lines(r"Assumptions & Open Questions")
    header = next((cells(line) for _n, line in numbered if line.startswith("|")), [])
    column = next((i for i, cell in enumerate(header) if cell.upper() == "BLOCKING"), None)
    if column is None:
        return out
    for _line_no, row in doc.table_rows(numbered):
        if len(row) > column and row[0].startswith("AQ-") and row[column].startswith("Có"):
            out.append(row[0])
    return out


def build(docs):
    """The text of docs/INDEX.md."""
    out = [
        "<!-- Generated by specflow/scripts/project-index.py. Do not edit; run the script again. -->",
        "",
        "# Chỉ mục dự án (Project Index)",
        "",
        "Đọc file này trước khi mở tài liệu khác. Tra một ID hoặc một mã lỗi: `python3 specflow/scripts/project-index.py . "
        "--where <ID>` in `tệp:dòng` nơi định nghĩa. Xem các mục của một tài liệu kèm khoảng dòng: `python3 "
        "specflow/scripts/project-index.py . --outline <tệp>`. Sau đó chỉ đọc khoảng dòng cần.",
        "",
        "## 1. Tài liệu (Documents)",
        "",
        "| Tệp | Loại | ID | Trạng thái | Version | Đợt | Số dòng | Tệp đi kèm |",
        "| --- | --- | --- | --- | --- | --- | ---: | --- |",
    ]
    for doc in docs:
        if doc.doc_type:
            out.append(f"| `{doc.path}` | {doc.doc_type} | {doc.doc_id} | {doc.meta.get('status', '')} | "
                       f"{doc.meta.get('version', '')} | {doc.meta.get('release', '')} | {doc.line_count} | "
                       f"{', '.join(f'`{name}`' for _n, name in doc.companions)} |")
    specs = [d for d in docs if d.doc_type == "spec"]
    highest = {}
    for doc in docs:
        if not doc.doc_type:
            continue
        for _n, row in doc.table_rows():
            for m in TC_ANY_RE.finditer(" ".join(row)):  # SRS section 8 keeps its test cases in the last column
                key = (m.group(1), m.group(2))
                highest[key] = max(highest.get(key, 0), int(m.group(3)))
    out += ["", "## 2. SPEC và test case (SPECs & Test Cases)", ""]
    if specs:
        out += ["| SPEC | Tệp | Yêu cầu nhận (§1.5) | TC đã dùng (§9) |", "| --- | --- | --- | --- |"]
        for doc in specs:
            reqs = [row[0] for _n, row in doc.table_rows(doc.section_lines(r"Requirements Satisfied")) if REQ_RE.match(row[0])]
            used = {}
            for _n, row in doc.table_rows(doc.section_lines(r"^9\. .*\(Tests\)|^9\. Kiểm thử")):
                if row and (m := TC_RE.match(row[0])):
                    used.setdefault(f"{m.group(1)}-{m.group(2)}", []).append(int(m.group(3)))
            out.append(f"| {doc.doc_id} | `{doc.path}` | {', '.join(reqs) or 'Không có'} | {tc_ranges(used) or 'Không có'} |")
    else:
        out.append("Chưa có SPEC.")
    out += ["", "## 3. Số TC kế tiếp (Next Free Test Case Number)", ""]
    if highest:
        out += ["Số lớn nhất tính trên mọi bảng của tài liệu dự án (SRS §8, Regression Baseline §6.1, SPEC §9).", "",
                "| Phân hệ | Loại | Số kế tiếp |", "| --- | --- | ---: |"]
        out += [f"| {mod} | {kind} | {highest[(mod, kind)] + 1} |" for mod, kind in sorted(highest)]
    else:
        out.append("Chưa có TC.")
    out += ["", "## 4. Câu hỏi chặn còn mở (Open Blocking Questions)", ""]
    blocking = [(doc.path, ids) for doc in docs if (ids := open_blocking(doc))]
    if blocking:
        out += ["| Tệp | Câu hỏi |", "| --- | --- |"] + [f"| `{path}` | {', '.join(ids)} |" for path, ids in blocking]
    else:
        out.append("Không có.")
    out += ["", "## 5. Truy xuất AC và NFR tới TC (Acceptance to Test Traceability)", ""]
    traced = {}  # AC or NFR id -> {spec id: [TC ids]}, from the tests table of each SPEC
    for doc in specs:
        if doc.meta.get("status") == "superseded":
            continue  # its tests no longer verify anything
        numbered = doc.section_lines(r"^9\. .*\(Tests\)|^9\. Kiểm thử") or []
        header = next((cells(line) for _n, line in numbered if line.startswith("|")), [])
        column = next((i for i, cell in enumerate(header) if cell.startswith("AC")), None)
        for _n, row in doc.table_rows(numbered):
            if column is None or len(row) <= column or not TC_RE.match(row[0]):
                continue
            for target in TRACE_RE.findall(row[column]):
                traced.setdefault(target, {}).setdefault(doc.doc_id, []).append(row[0])
    if traced:
        out += ["Sinh từ bảng test ở §9 của từng SPEC; đây là nơi tra TC của một AC hay một NFR.", "",
                "| AC hoặc NFR | SPEC | TC |", "| --- | --- | --- |"]
        out += [f"| {target} | {spec} | {', '.join(tcs)} |" for target in sorted(traced) for spec, tcs in traced[target].items()]
    else:
        out.append("Chưa có TC ở SPEC nào.")
    return "\n".join(out) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description="Build and query the index of a project's documents.")
    parser.add_argument("project")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--check", action="store_true")
    group.add_argument("--where", nargs="+", metavar="ID")
    group.add_argument("--outline", metavar="FILE")
    args = parser.parse_args(argv)
    root = pathlib.Path(args.project)
    if not (root / "docs").is_dir():
        raise SystemExit(f"project-index: {args.project} has no docs/ directory")
    if args.outline:
        print_outline(root, args.outline)
        return 0
    docs = load(root)
    if args.where:
        print_where(root, docs, args.where)
        return 0
    text, target = build(docs), root / INDEX
    if args.check:
        if not target.is_file() or target.read_text(encoding="utf-8", errors="replace") != text:
            print(f"ERROR {INDEX}: missing or out of date; run project-index.py to rebuild it")
            return 1
        return 0
    target.write_text(text, encoding="utf-8")
    print(f"wrote {target} ({len(text.splitlines())} lines)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
