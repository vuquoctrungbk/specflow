#!/usr/bin/env python3
"""Check the documents of one project for defects that cost an agent many lookups to find by hand.

Usage:
  check-project-docs.py PROJECT_DIR

Called by check-templates.sh for a worked example and for a real project. A kit document is a markdown file under
docs/ or plans/ whose frontmatter has a doc_type. Findings:

  ERROR  a table row has a different number of cells than its header
  ERROR  an FR is listed in the requirements catalog (SRS section 6.1) of more than one file
  ERROR  two documents carry the same spec_id, adr_id or prompt_id
  ERROR  an error code has more than one row in the Error Code Registry
  ERROR  an endpoint is the "Method và path" of more than one SPEC that is not superseded
  ERROR  two SPECs' File Diff list a migration file with the same number in the same folder
  ERROR  docs/INDEX.md exists and is out of date
  ERROR  a code fence is never closed
  ERROR  a "Tệp đi kèm:" line names a file that does not exist or sits outside the place of its document
         (docs/specs/<SPEC file name>.<name>.<ext> for a SPEC, docs/architecture/ for the architecture document)
  ERROR  a companion file (a file of docs/specs/ that is not markdown, any file of docs/architecture/) is named by no
         document or by more than one
  ERROR  a phase file from phase template 1.3.0 or later has no "Đọc trước (Read First)" section, an entry of it names a
         document that does not exist or has no `§section` after it, or names a section the document does not have
  ERROR  a SPEC from SPEC template RISK_SINCE or later has no `risk: high` or `risk: normal`; a SPEC with `risk: normal`
         gives no reason for it, or its File Diff touches an area that must be high (CONVENTIONS section 3)
  ERROR  a SPEC belongs to a release while a SPEC of an earlier release is not implemented yet, in a project whose Intake
         comes from Intake template SLICES_SINCE or later; WARN when a release holds more than RELEASE_SPECS SPECs
         (PLAYBOOK section 2: a release is a vertical slice, coded before the next one is specified)
  ERROR  a SPEC is longer than SPEC_LINES, the architecture document longer than ARCHITECTURE_LINES, or one of them has a
         line longer than LINE_CHARS, fenced blocks and frontmatter included (CONVENTIONS section 7); a WARN instead
         when the document comes from a template older than the one that introduced the limits

Error contract: one line per finding, "ERROR <file>: <message>" or "WARN <file>: <message>". The exit status is 0
whether or not there are findings; a non-zero exit status means the script could not run.
"""
import collections
import importlib.util
import pathlib
import re
import sys
import unicodedata

sys.dont_write_bytecode = True  # loading project-index.py must not leave a cache folder in the kit
SPEC_LINES = 500
ARCHITECTURE_LINES = 800
LINE_CHARS = 1000
# The limits bind a document made from this template version or a later one.
LIMITS = {"spec": (SPEC_LINES, (1, 3, 0)), "architecture": (ARCHITECTURE_LINES, (1, 2, 0))}

SLICES_SINCE = (1, 5, 0)  # Intake template version from which a release must be coded before the next is specified
RELEASE_SPECS = 5         # a release with more SPECs than this is too large to be one slice
RISK_SINCE = (1, 4, 0)  # SPEC template version from which the risk key is required
RISK_REASON_RE = re.compile(r"^\s*-\s*Mức rủi ro:\s*\S")
# Work that must be reviewed in full: who the user is and what they may do, isolation between tenants, money, personal
# data. A word of a File Diff path that starts with a short stem, or a path segment that contains a long one, is such
# work. The list is a floor, not a proof: the reviewer of Gate 3 still confirms the level.
HIGH_PREFIXES = ("auth", "oauth", "login", "logout", "jwt", "acl", "rbac", "role", "pii", "quota", "sso", "otp")
HIGH_INFIXES = ("signin", "signup", "session", "password", "passwd", "credential", "permission", "tenant", "billing", "payment",
                "invoice", "wallet", "pricing", "refund", "ledger", "checkout", "personal", "privacy", "consent")
SCHEMA_PATH_RE = re.compile(r"(^|/)(migrations?|migrate|alembic|schema)(/|\.|$)|\.(prisma|sql)$", re.IGNORECASE)
CONTRACT_PATH_RE = re.compile(r"openapi|swagger|\.proto$|\.graphql$|(^|/)contracts?(/|\.)", re.IGNORECASE)
# A soft delete and a new DELETE endpoint add behaviour; they do not destroy data or break a caller.
DESTRUCTIVE_RE = re.compile(r"\b(alter|drop|rename|remove|backfill|truncate)\b|(?<!soft )(?<!soft-)\bdelete\b(?!\s*`?\s*/)|\bnot null\b"
                            r"|(xóa|xoá|bỏ|gỡ) (cột|bảng|ràng buộc|index|model|trường|field|enum|khóa|khoá|endpoint|path)"
                            r"|đổi (kiểu|tên)|chuyển dữ liệu", re.IGNORECASE)
# Vietnamese names of the same high-risk work, matched on a screen name or route with marks and separators removed.
HIGH_VI = ("dangnhap", "dangky", "dangxuat", "matkhau", "xacthuc", "phanquyen", "vaitro", "thanhtoan", "hoadon", "hoantien",
           "hoso", "canhan")
BARE_PATH_RE = re.compile(r"^(?:\|\s*|\s*[-*]\s+)([\w.@\[\]-]+(?:/[\w.@\[\]-]+)+)")
INTAKE_CORE = "core/00_Project_Intake_Template.md"
PHASE_CORE = "core/05_Implementation_Plan_Template/phase-01-example-phase.md"
PATH_IN_TICKS_RE = re.compile(r"`([^`\s]*[/.][^`\s]*)`")
READ_FIRST_SINCE = (1, 3, 0)  # phase template version that introduced the Read First section
READ_FIRST_ITEM_RE = re.compile(r"^\s*[-*]\s+`([^`]+)`(.*)$")
SECTION_REF_RE = re.compile(r"§(\d+(?:\.\d+)*)")

_spec = importlib.util.spec_from_file_location("project_index", pathlib.Path(__file__).with_name("project-index.py"))
project_index = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(project_index)

FR_RE = re.compile(r"^FR-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+$")
CODE_RE = re.compile(r"^[A-Z][A-Z0-9_]+$")
ENDPOINT_RE = re.compile(r"^(GET|POST|PUT|PATCH|DELETE)\s+`?(/[^`\s]*)")
MIGRATION_RE = re.compile(r"^V?(\d[\d_-]*\d|\d)(?:__|[_-])[A-Za-z]")  # 0003_x, 20260922000100_x, 2026_09_22_000100_x, V3__x
findings = []


def is_plain_file(root, name):
    """True when `name` is a regular file under root. A symlink at any step of the path is refused, since it can lead outside the project."""
    current = root
    for part in name.split("/"):
        current = current / part
        if current.is_symlink():
            return False
    return current.is_file()


def report(level, path, message):
    findings.append(f"{level} {path}: {message}")


def raw_cell_count(line):
    """Cells of a table line as a renderer counts them: every pipe that is not escaped separates two cells."""
    body = line.strip()
    body = body[1:] if body.startswith("|") else body
    body = body[:-1] if body.endswith("|") and not body.endswith("\\|") else body
    return len(re.split(r"(?<!\\)\|", body))


def check_table_shape(doc):
    """One finding per table: the first row whose cell count differs from the header's."""
    header = None
    for line_no, line in enumerate(doc.lines, 1):
        if not line.startswith("|"):
            header = None
            continue
        count = raw_cell_count(line)
        if header is None:
            header = count
        elif header and count != header:
            report("ERROR", f"{doc.path}:{line_no}", f"table row has {count} cells, its header has {header}; "
                   "escape a pipe inside a cell as \\|")
            header = 0  # report a table once


CORE_TEMPLATE = {"spec": "core/04_Spec_Core_Template.md", "architecture": "core/02_Architecture_Core_Template.md"}


def as_version(text):
    parts = [int(p) for p in re.findall(r"\d+", text)[:3]]
    return tuple(parts + [0] * (3 - len(parts))) if parts else None


def template_version(doc):
    """The template a SPEC or architecture document was made from, as a three-part tuple.

    The newest of `template_version` and the core template entry of `assembled_from` counts, so lowering one of the
    two does not turn the limits off; a document that states neither is held to the current template.
    """
    stated = [as_version(doc.meta.get("template_version", ""))]
    core = re.escape(CORE_TEMPLATE[doc.doc_type])
    stated += [as_version(m.group(1)) for line in doc.raw[:40] if (m := re.search(rf"{core}@([\d.]+)", line))]
    stated = [v for v in stated if v]
    return max(stated) if stated else (9999, 0, 0)


def states_template(doc):
    """False for a document that names no template version at all; such a document predates any new requirement."""
    core = re.escape(CORE_TEMPLATE[doc.doc_type])
    return bool(as_version(doc.meta.get("template_version", ""))) or any(re.search(rf"{core}@[\d.]+", line) for line in doc.raw[:40])


def stated_version(doc, core):
    """Newest of `template_version` and the entry of `core` in `assembled_from`; None when the document states neither."""
    found = [as_version(doc.meta.get("template_version", ""))]
    found += [as_version(m.group(1)) for line in doc.raw[:40] if (m := re.search(rf"{re.escape(core)}@([\d.]+)", line))]
    found = [v for v in found if v]
    return max(found) if found else None


def high_words(path):
    """The words of a path that mark work as high risk (HIGH_PREFIXES, HIGH_INFIXES)."""
    hits = set()
    for word in re.findall(r"[a-z]+", re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", path).lower()):
        for stem in HIGH_PREFIXES:
            if word.startswith(stem) and not (stem == "auth" and word.startswith("author") and not word.startswith("authoriz")):
                hits.add(word)
    for segment in path.lower().split("/"):
        squeezed = re.sub(r"[^a-z]", "", segment)
        hits.update(stem for stem in HIGH_INFIXES if stem in squeezed)
    return sorted(hits)


def high_words_vi(text):
    """The Vietnamese high-risk names (HIGH_VI) in a screen name or route, whatever marks or separators it is written with."""
    folded = unicodedata.normalize("NFD", text.lower().replace("đ", "d"))
    squeezed = re.sub(r"[^a-z]", "", "".join(c for c in folded if not unicodedata.combining(c)))
    return sorted(stem for stem in HIGH_VI if stem in squeezed)


def file_diff(doc):
    """(path, rest of its line, in the modified part) for every path the File Diff of a SPEC names, and its companion lines.

    Section 2 is read whole, with or without sub-sections, except the part that lists what must not be touched.
    """
    entries, companions, skip, modified = [], [], False, True
    for _n, line in doc.section_lines(r"^2\.\s") or []:
        if re.match(r"^#+ ", line):  # a part of the File Diff: only the list of new files is not a change of existing ones
            skip = bool(re.search(r"MUST NOT|Không được chạm", line))
            modified = not re.search(r"\b2\.2\b|New Files|File tạo mới", line)
            continue
        if skip:
            continue
        if project_index.COMPANION_RE.match(line):
            companions.append(line.strip())
        # The paths of the first cell of a row, or the first path of a list item; later backticks are the description.
        head = line.split("|")[1] if line.startswith("|") and line.count("|") > 1 else None
        found = PATH_IN_TICKS_RE.findall(head) if head is not None else PATH_IN_TICKS_RE.findall(line)[:1]
        if not found and (m := BARE_PATH_RE.match(line)):
            found = [m.group(1)]
        rest = line
        for path in found:
            rest = rest.replace(f"`{path}`", "").replace(path, "")
        entries += [(path, rest, modified) for path in found]
    return entries, companions


def check_risk(docs):
    """`risk: normal` lets a SPEC take the lighter paths, so the checker refuses it where the work must be high."""
    declared = []  # extra high-risk areas of this project: the value of the row "Vùng rủi ro cao" of the Intake
    for doc in docs:
        if doc.doc_type == "intake":
            for _n, row in doc.table_rows():
                if len(row) > 1 and row[0] == "Vùng rủi ro cao" and row[1] not in ("Không", ""):
                    # the cell parser drops the outer backticks, so the areas are split at commas and backticks alike
                    declared += [t.strip().lower() for t in re.split(r"[`,]", row[1]) if t.strip()]
    for doc in docs:
        if doc.doc_type != "spec" or doc.meta.get("status") == "superseded":
            continue
        risk = doc.meta.get("risk", "").strip("\"'")
        if not risk:
            if states_template(doc) and template_version(doc) >= RISK_SINCE:
                report("ERROR", doc.path, "no `risk` in the frontmatter; write `risk: high` or `risk: normal` (CONVENTIONS §3)")
            continue  # a SPEC from an older template without the key is treated as high
        if risk not in ("high", "normal"):
            report("ERROR", doc.path, f"risk '{risk}' is not `high` or `normal` (CONVENTIONS §3)")
            continue
        if risk == "high":
            continue
        if not any(RISK_REASON_RE.match(line) for line in doc.lines):
            report("ERROR", doc.path, "risk is `normal` but the SPEC has no line `- Mức rủi ro:` giving the reason (CONVENTIONS §3)")
        entries, companions = file_diff(doc)
        if companions:
            report("ERROR", doc.path, "risk is `normal` but the File Diff is kept in a companion file, where it cannot be checked; "
                   "keep the File Diff of §2 in the SPEC (CONVENTIONS §3)")
        if not entries:
            report("ERROR", doc.path, "risk is `normal` but §2 names no file path in backticks, so the level cannot be checked (CONVENTIONS §3)")
        why = []
        for path, rest, modified in entries:
            hit = high_words(path)
            if hit:
                why.append(f"{path} ({', '.join(hit)})")
            elif any(area in path.lower() for area in declared):
                why.append(f"{path} (an area the Intake declares high)")
            elif SCHEMA_PATH_RE.search(path) and DESTRUCTIVE_RE.search(rest):  # adding a table is not
                why.append(f"{path} (changes a schema that may hold data)")
            elif modified and CONTRACT_PATH_RE.search(path) and DESTRUCTIVE_RE.search(rest):  # adding an endpoint is not
                why.append(f"{path} (changes an existing public contract)")
        why = list(dict.fromkeys(why))
        if why:
            report("ERROR", doc.path, "risk is `normal` but the File Diff touches " + "; ".join(why[:3])
                   + ("; and more" if len(why) > 3 else "") + ": set `risk: high` (CONVENTIONS §3)")


def release_label(text):
    """`R1` from a cell such as `**R1**` or `R1 (MVP)`."""
    return (re.sub(r"[*`]", "", text).split() or [""])[0]


def check_release_order(docs):
    """A release is a vertical slice: its SPECs are coded before a SPEC of a later release is written."""
    intake = next((d for d in docs if d.doc_type == "intake"), None)
    stated = stated_version(intake, INTAKE_CORE) if intake else None
    if not stated or stated < SLICES_SINCE:
        return
    order, source = [], None
    roadmap = next((d for d in docs if d.doc_type == "roadmap"), None)
    if roadmap is not None:
        source = roadmap
        order = [release_label(row[0]) for _n, row in roadmap.table_rows(roadmap.section_lines(r"^1\. ") or [])]
    else:  # before the roadmap exists, the releases are the labels of the requirements catalog, in order of first use
        for doc in docs:
            if doc.doc_type in ("srs", "srs-module"):
                numbered = doc.section_lines(r"^6\.1\.") or []
                header = next((project_index.cells(line) for _n, line in numbered if line.startswith("|")), [])
                column = next((i for i, cell in enumerate(header) if cell.startswith("Bản phát hành")), None)
                for _n, row in doc.table_rows(numbered):
                    if column is not None and len(row) > column and FR_RE.match(row[0]):
                        source = source or doc
                        order.append(release_label(row[column]))
    order = [label for n, label in enumerate(order) if label and label not in ("Đợt", "Không") and label not in order[:n]]
    if not order:
        return
    phases = collections.defaultdict(list)  # spec_id -> status of each of its phases
    for doc in docs:
        if doc.doc_type == "implementation-phase":
            phases[doc.meta.get("spec_id", "").strip("\"'")].append(doc.meta.get("status", ""))
    by_release = collections.defaultdict(list)
    for doc in docs:
        if doc.doc_type != "spec" or doc.meta.get("status") == "superseded":
            continue
        release = release_label(doc.meta.get("release", "").strip("\"'"))
        if not release and not (states_template(doc) and template_version(doc) >= (1, 2, 0)):
            continue  # a SPEC from before the release key belongs to no release
        if release not in order:
            report("ERROR", doc.path, f"release '{release}' is not a release of the project ({', '.join(order)}); every SPEC states "
                   "its release so that releases are done in order (PLAYBOOK §2)")
            continue
        by_release[release].append(doc)

    def coded(doc):  # implemented once, even when it is open again for a fix after review
        mine = phases.get(doc.doc_id, [])
        return doc.meta.get("status") == "implemented" or (bool(mine) and all(status == "done" for status in mine))

    for n, release in enumerate(order):
        specs = by_release.get(release, [])
        if len(specs) > RELEASE_SPECS:
            report("WARN", source.path, f"release {release} has {len(specs)} SPECs, more than {RELEASE_SPECS}; split it into smaller "
                   "releases so that code of the first one runs before the rest is specified (PLAYBOOK §2)")
        open_before = [d.doc_id or d.path for earlier in order[:n] for d in by_release.get(earlier, []) if not coded(d)]
        for doc in specs if open_before else []:
            report("ERROR", doc.path, f"belongs to release {release}, but {', '.join(sorted(open_before)[:3])} of an earlier release "
                   "is not implemented yet; finish the earlier release before specifying this one (PLAYBOOK §2)")


def check_flow_screens(docs):
    """A screen the catalog marks "Theo luồng" has no page of its own, so it must be low risk and drawn in a flow mockup."""
    high_specs = [d for d in docs if d.doc_type == "spec" and d.meta.get("risk", "").strip("\"'") == "high"]
    for doc in docs:
        if doc.doc_type != "wireframe-index":
            continue
        fenced, inside, drawing = [], False, False
        for raw in doc.raw:  # the `text` blocks, where the flow mockups are drawn; a Mermaid diagram is not a mockup
            if project_index.FENCE_RE.match(raw):
                inside = not inside
                drawing = inside and raw.strip().lstrip("`~").strip() == "text"
            elif inside and drawing:
                fenced.append(raw)
        mockups = "\n".join(fenced)
        for line_no, row in doc.table_rows():
            if len(row) < 3 or row[-1] != "Theo luồng" or not re.match(r"^SCR-", row[0]):
                continue
            where, screen = f"{doc.path}:{line_no}", row[0]
            named = " ".join(row[1:3]).replace("`", "")
            words = sorted(set(high_words(named) + high_words_vi(named)))
            if words:
                report("ERROR", where, f"{screen} is marked 'Theo luồng' but its name or entry point says {', '.join(words)}; "
                       "give it a page of its own (PLAYBOOK §2.2.1)")
            cited = sorted(d.doc_id or d.path for d in high_specs if re.search(rf"\b{re.escape(screen)}\b", "\n".join(d.raw)))
            if cited:
                report("ERROR", where, f"{screen} is marked 'Theo luồng' but {', '.join(cited[:3])}, a SPEC of risk high, uses it; "
                       "give it a page of its own (PLAYBOOK §2.2.1)")
            if not re.search(rf"\b{re.escape(screen)}\b", mockups):
                report("ERROR", where, f"{screen} is marked 'Theo luồng' but no flow mockup of the index draws it; add it to a "
                       "`text` block under its flow (PLAYBOOK §2.2.1)")


def check_read_first(everything):
    """A phase lists the sections of the SPEC and the architecture it needs, so the agent reads those and not the files."""
    by_path = {d.path: d for d in everything}
    companions = {name for d in everything for _n, name in d.companions}
    for doc in everything:
        if doc.doc_type != "implementation-phase":
            continue
        stated = stated_version(doc, PHASE_CORE)
        if not stated or stated < READ_FIRST_SINCE:
            continue
        numbered = doc.section_lines(r"Read First|Đọc trước")
        entries = [(n, m) for n, line in numbered or [] if (m := READ_FIRST_ITEM_RE.match(line))]
        if numbered is None or not entries:
            report("ERROR", doc.path, "no entry in the section Đọc trước (Read First): list each document to read as "
                   "`path` §section (CONVENTIONS §9)")
            continue
        for n, m in entries:
            name, rest = m.groups()
            refs = SECTION_REF_RE.findall(rest)
            where = f"{doc.path}:{n}"
            target = by_path.get(name)
            if target is None and name in companions:
                continue  # a companion file has no sections; the phase reads it whole
            if target is None:
                report("ERROR", where, f"Read First names {name}, which is not a document of the project (CONVENTIONS §9)")
            elif not refs:
                report("ERROR", where, f"Read First names {name} without a §section after it (CONVENTIONS §9)")
            else:
                for ref in refs:
                    if not any(re.match(rf"{re.escape(ref)}\.?\s", text) for _line, _lv, text in target.headings):
                        report("ERROR", where, f"{name} has no section §{ref} (CONVENTIONS §9)")


def check_sizes(doc):
    """The limits bind a SPEC and the architecture document only (CONVENTIONS section 7)."""
    if doc.doc_type not in LIMITS:
        return
    limit, since = LIMITS[doc.doc_type]
    level = "ERROR" if template_version(doc) >= since else "WARN"
    if doc.line_count > limit:
        report(level, doc.path, f"{doc.line_count} lines, more than {limit}; move a machine-readable block to a companion file "
               "(CONVENTIONS §7)")
    long_lines = [n for n, line in enumerate(doc.raw, 1) if len(line) > LINE_CHARS]
    if long_lines:
        report(level, f"{doc.path}:{long_lines[0]}", f"{len(long_lines)} line(s) longer than {LINE_CHARS} characters; "
               "break the text into shorter rows or a list (CONVENTIONS §7)")


def check_companions(root, docs):
    """Every companion line names an existing file in the place of its document, and every companion file has one owner."""
    owners = collections.defaultdict(list)
    for doc in docs:
        stem = pathlib.PurePosixPath(doc.path).stem
        for line_no, name in doc.companions:
            where = f"{doc.path}:{line_no}"
            parts = name.split("/")
            if doc.doc_type not in ("spec", "architecture"):
                report("ERROR", where, f"only a SPEC and the architecture document may have a companion file, not a document of type {doc.doc_type} (CONVENTIONS §7)")
            elif name.startswith("/") or ".." in parts or "." in parts or name != name.strip() or name.lower().endswith(".md"):
                report("ERROR", where, f"companion file {name} must be a plain path from the project root to a file that is not markdown (CONVENTIONS §7)")
            elif doc.doc_type == "spec" and not re.fullmatch(rf"docs/specs/{re.escape(stem)}\.[^/.]+\.[^/.]+", name):
                report("ERROR", where, f"companion file {name} of a SPEC is not docs/specs/{stem}.<name>.<ext> (CONVENTIONS §7)")
            elif doc.doc_type == "architecture" and not name.startswith("docs/architecture/"):
                report("ERROR", where, f"companion file {name} of the architecture document is not under docs/architecture/ (CONVENTIONS §7)")
            elif not is_plain_file(root, name):
                report("ERROR", where, f"companion file {name} does not exist (CONVENTIONS §7)")
            if doc.path not in owners[name]:
                owners[name].append(doc.path)
    found = [p for p in (root / "docs/specs").rglob("*") if p.is_file() and p.suffix.lower() != ".md"]
    found += [p for p in (root / "docs/architecture").rglob("*") if p.is_file()]
    for path in sorted(p for p in found if not p.name.startswith(".")):
        name = path.relative_to(root).as_posix()
        if not owners.get(name):
            report("ERROR", name, "companion file is named by no document; name it in a \"Tệp đi kèm:\" line or remove it (CONVENTIONS §7)")
        elif len(owners[name]) > 1:
            report("ERROR", name, f"companion file is named by more than one document: {', '.join(owners[name])} (CONVENTIONS §7)")


def report_duplicates(owners, message):
    """owners: {key: [path, ...]}; one finding per key that more than one place holds."""
    for key in sorted(owners):
        places = owners[key]
        if len(places) > 1:
            report("ERROR", places[0], message.format(key=key, others=", ".join(places[1:])))


def check_duplicates(docs):
    catalog, ids, codes, endpoints, migrations = (collections.defaultdict(list) for _ in range(5))
    for doc in docs:
        if doc.doc_type in ("srs", "srs-module"):
            for _n, row in doc.table_rows(doc.section_lines(r"^6\.1\.")):
                if FR_RE.match(row[0]) and doc.path not in catalog[row[0]]:
                    catalog[row[0]].append(doc.path)
        if doc.doc_type in ("spec", "adr", "prompt-spec") and doc.doc_id:
            ids[doc.doc_id].append(doc.path)
        if doc.doc_type == "architecture":
            for line_no, row in doc.table_rows(doc.section_lines(r"Error Code Registry")):
                if CODE_RE.match(row[0]):
                    codes[row[0]].append(f"{doc.path}:{line_no}")
        if doc.doc_type == "spec" and doc.meta.get("status") != "superseded":
            for _n, row in doc.table_rows():
                if row[0] == "Method và path" and len(row) > 1 and (m := ENDPOINT_RE.match(row[1].replace("`", ""))):
                    endpoints[f"{m.group(1)} {re.sub(r'{[^}]*}', '{}', m.group(2)).rstrip('/')}"].append(doc.path)
            for _n, row in doc.table_rows(doc.section_lines(r"^2\.2\.")):
                if len(row) > 1 and row[1] == "migration":
                    parts = row[0].split("/")
                    for n in range(len(parts) - 1, -1, -1):
                        if m := MIGRATION_RE.match(parts[n]):
                            # The number is unique within its folder, and a SPEC may list several files of one
                            # migration (up and down).
                            key = f"{m.group(1)} in {'/'.join(parts[:n]) or '.'}"
                            if doc.path not in migrations[key]:
                                migrations[key].append(doc.path)
                            break
    report_duplicates(catalog, "{key} is in the requirements catalog (§6.1) of more than one file: also {others}")
    report_duplicates(ids, "{key} is the ID of more than one document: also {others}")
    report_duplicates(codes, "error code {key} has more than one row in the Error Code Registry: also {others}")
    report_duplicates(endpoints, "endpoint {key} is the Method và path of more than one SPEC: also {others}")
    report_duplicates(migrations, "migration number {key} is in the File Diff of more than one SPEC: also {others}")


def main(argv):
    if len(argv) != 2:
        raise SystemExit(__doc__)
    root = pathlib.Path(argv[1])
    if not (root / "docs").is_dir():
        raise SystemExit(f"check-project-docs: {argv[1]} has no docs/ directory")
    everything = project_index.load(root)
    docs = [d for d in everything if d.doc_type]
    for doc in docs:
        if doc.open_fence:
            report("ERROR", f"{doc.path}:{doc.open_fence}", "code fence is never closed; the rest of the document is read as code")
        check_table_shape(doc)
        check_sizes(doc)
    check_duplicates(docs)
    check_read_first(everything)
    check_risk(docs)
    check_release_order(docs)
    check_flow_screens(docs)
    check_companions(root, docs)
    index = root / project_index.INDEX
    if index.is_file() and index.read_text(encoding="utf-8", errors="replace") != project_index.build(everything):
        report("ERROR", project_index.INDEX, "out of date; run scripts/project-index.py on the project to rebuild it")
    print("\n".join(findings))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
