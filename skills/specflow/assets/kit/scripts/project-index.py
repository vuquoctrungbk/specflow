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
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from i18n import T  # noqa: E402

INDEX = "docs/INDEX.md"
TC_RE = re.compile(r"^TC-([A-Z0-9]+(?:-[A-Z0-9]+)??)-([A-Z0-9]+)-(\d+)$")
TC_ANY_RE = re.compile(r"(?<![A-Za-z0-9-])TC-([A-Z0-9]+(?:-[A-Z0-9]+)??)-([A-Z0-9]+)-(\d+)(?![A-Za-z0-9])")
REQ_RE = re.compile(r"^(?:FR|NFR)-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+$")
SEPARATOR_RE = re.compile(r"^\|\s*:?-{3,}")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*\S)\s*$")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
TRACE_RE = re.compile(r"\b(?:AC|NFR)-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+\b")  # what a test row of SPEC section 9 verifies
COMPANION_RE = re.compile(rf"^\s*{re.escape(T.index_companion)}:\s*`([^`]+)`")  # CONVENTIONS section 7: a machine-readable block kept in its own file
# Which doc_type is the home of an ID, by its prefix (CONVENTIONS section 4). Any other token has its home in the
# architecture document, where the error code registry is.
HOMES = (
    ("GOAL-", ("intake",)), ("MOD-", ("srs",)), ("BR-", ("srs", "srs-module")),
    ("FR-", ("srs", "srs-module")), ("NFR-", ("srs", "srs-module")), ("AC-", ("srs", "srs-module")),
    ("TC-", ("spec", "regression-baseline")), ("SCR-", ("wireframe-screen", "srs", "srs-module")),
    ("CMP-", ("design-system",)), ("PAT-", ("design-system",)), ("TPL-", ("design-system",)),
    ("ADR-", ("adr",)), ("SPEC-", ("spec",)), ("PROMPT-", ("prompt-spec",)), ("RB-", ("regression-baseline",)),
)
# The heading of SPEC section 9: the English form, or the form of the project language.
TESTS_HEADING_RE = rf"^9\. .*\(Tests\)|^9\. {re.escape(T.index_tests_heading)}"
OWN_ID = {"spec": "spec_id", "adr": "adr_id", "prompt-spec": "prompt_id"}


def table_head(*labels):
    """The header row of a table of docs/INDEX.md."""
    return "| " + " | ".join(labels) + " |"


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


def blocking_cells(doc):
    """[(question ID, text of its BLOCKING cell)] of the "AQ-" rows of the Assumptions & Open Questions table of a document."""
    out = []
    numbered = doc.section_lines(r"Assumptions & Open Questions")
    header = next((cells(line) for _n, line in numbered if line.startswith("|")), [])
    column = next((i for i, cell in enumerate(header) if cell.upper() == "BLOCKING"), None)
    if column is None:
        return out
    for _line_no, row in doc.table_rows(numbered):
        if len(row) > column and row[0].startswith("AQ-"):
            out.append((row[0], row[column]))
    return out


def invalid_blocking(doc):
    """[(question ID, cell)] whose BLOCKING cell is neither the word for yes nor the word for no of the project language."""
    return [(qid, cell) for qid, cell in blocking_cells(doc) if cell not in (T.tpl_val_yes, T.tpl_val_no)]


def open_blocking(doc):
    """IDs of the questions of a document that are not settled: the BLOCKING cell is anything but the word for no, so a cell
    in the wrong language, empty or with a remark counts as blocking until it is written correctly."""
    return [qid for qid, cell in blocking_cells(doc) if cell != T.tpl_val_no]


def build(docs):
    """The text of docs/INDEX.md."""
    out = [
        "<!-- Generated by specflow/scripts/project-index.py. Do not edit; run the script again. -->",
        "",
        T.index_title,
        "",
        T.index_intro,
        "",
        T.index_h_docs,
        "",
        table_head(T.index_col_file, T.index_col_type, T.index_col_id, T.index_col_status, T.index_col_version, T.index_col_wave,
                   T.index_col_lines, T.index_companion),
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
            for m in TC_ANY_RE.finditer(" ".join(row)):  # every table counts, phase files included
                key = (m.group(1), m.group(2))
                highest[key] = max(highest.get(key, 0), int(m.group(3)))
    out += ["", T.index_h_specs, ""]
    if specs:
        out += [table_head(T.index_col_spec, T.index_col_file, T.index_col_reqs, T.index_col_tc_used), "| --- | --- | --- | --- |"]
        for doc in specs:
            reqs = [row[0] for _n, row in doc.table_rows(doc.section_lines(r"Requirements Satisfied")) if REQ_RE.match(row[0])]
            used = {}
            for _n, row in doc.table_rows(doc.section_lines(TESTS_HEADING_RE)):
                if row and (m := TC_RE.match(row[0])):
                    used.setdefault(f"{m.group(1)}-{m.group(2)}", []).append(int(m.group(3)))
            out.append(f"| {doc.doc_id} | `{doc.path}` | {', '.join(reqs) or T.index_none} | {tc_ranges(used) or T.index_none} |")
    else:
        out.append(T.index_no_spec)
    out += ["", T.index_h_next_tc, ""]
    if highest:
        out += [T.index_next_note, "",
                table_head(T.index_col_module, T.index_col_type, T.index_col_next), "| --- | --- | ---: |"]
        out += [f"| {mod} | {kind} | {highest[(mod, kind)] + 1} |" for mod, kind in sorted(highest)]
    else:
        out.append(T.index_no_tc)
    out += ["", T.index_h_blocking, ""]
    blocking = [(doc.path, ids) for doc in docs if (ids := open_blocking(doc))]
    if blocking:
        out += [table_head(T.index_col_file, T.index_col_questions), "| --- | --- |"] + [f"| `{path}` | {', '.join(ids)} |" for path, ids in blocking]
    else:
        out.append(T.index_no_blocking)
    out += ["", T.index_h_trace, ""]
    traced = {}  # AC or NFR id -> {spec id: [TC ids]}, from the tests table of each SPEC
    for doc in specs:
        if doc.meta.get("status") == "superseded":
            continue  # its tests no longer verify anything
        numbered = doc.section_lines(TESTS_HEADING_RE) or []
        header = next((cells(line) for _n, line in numbered if line.startswith("|")), [])
        column = next((i for i, cell in enumerate(header) if cell.startswith("AC")), None)
        for _n, row in doc.table_rows(numbered):
            if column is None or len(row) <= column or not TC_RE.match(row[0]):
                continue
            for target in TRACE_RE.findall(row[column]):
                traced.setdefault(target, {}).setdefault(doc.doc_id, []).append(row[0])
    if traced:
        out += [T.index_trace_note, "",
                table_head(T.index_col_ac_nfr, T.index_col_spec, T.index_col_tc), "| --- | --- | --- |"]
        out += [f"| {target} | {spec} | {', '.join(tcs)} |" for target in sorted(traced) for spec, tcs in traced[target].items()]
    else:
        out.append(T.index_no_tc_in_spec)
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
