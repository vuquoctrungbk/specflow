#!/usr/bin/env python3
"""Check the full HTML of the wireframe pages of one project (CONVENTIONS section 7, PLAYBOOK section 2.2.1).

Usage: check-full-html.py PROJECT_DIR

Applies only when the Intake records stage 1W as "Có, kèm HTML đầy đủ". Then every wireframe page
docs/wireframes/SCR-*.md needs docs/wireframes/html/<same name>.html that
  - has a viewport meta tag, and at least one @media query on a frontend-web page;
  - is not titled as a low-fi draft;
  - has an element with id state-<name> (initial, loading, empty, success, error) for each UI state the page
    does not mark N/A, and a link to #state-<name> for each of those states except success, so the reviewer
    can reach every state;
  - marks each component with data-cmp="CMP-NN", exactly the Component IDs of the page's component table.
The safety rules and the token rules of the same file are checked by check-templates.sh and
check-design-token-use.py. Prints "ERROR <file>: <message>" lines and exits 0.
"""
import pathlib
import re
import sys

STATES = ("Initial", "Loading", "Empty", "Success", "Error")
FULL = "Có, kèm HTML đầy đủ"


def cells(line):
    body = line.strip().strip("|")
    return [c.strip() for c in re.split(r"(?<!\\)\|", body)]


def section(text, number):
    m = re.search(rf"^## {number}\..*$", text, re.M)
    if not m:
        return ""
    rest = text[m.end():]
    nxt = re.search(r"^## ", rest, re.M)
    return rest[: nxt.start()] if nxt else rest


def rows(block):
    return [cells(l) for l in block.splitlines() if l.startswith("|") and not re.match(r"^\|\s*-", l)]


def main():
    root = pathlib.Path(sys.argv[1])
    intake = root / "docs/intake/PROJECT_INTAKE.md"
    if not intake.is_file():
        return
    value = next((cells(l)[1] for l in intake.read_text(encoding="utf-8").splitlines()
                  if l.startswith("| Giai đoạn 1W") and len(cells(l)) > 1), "")
    if not value.startswith(FULL):
        return
    wf = root / "docs/wireframes"
    for page in sorted(wf.glob("SCR-*.md")):
        text = page.read_text(encoding="utf-8")
        rel = page.relative_to(root).as_posix()
        html = wf / "html" / (page.stem + ".html")
        hrel = html.relative_to(root).as_posix()
        if not html.is_file():
            print(f"ERROR {rel}: the Intake records stage 1W as '{FULL}' but {hrel} does not exist (CONVENTIONS §7)")
            continue
        body = html.read_text(encoding="utf-8")
        if not re.search(r"<meta[^>]+name=[\"']viewport[\"']", body, re.I):
            print(f"ERROR {hrel}: no viewport meta tag (CONVENTIONS §7)")
        overlays = re.search(r"^overlays:\s*\[(.*)\]", text, re.M)
        if overlays and "frontend-web" in overlays.group(1) and not re.search(r"@media", body):
            print(f"ERROR {hrel}: a frontend-web page needs at least one @media query so the layout shows at a small and a large width (CONVENTIONS §7)")
        title = re.search(r"<title>(.*?)</title>", body, re.I | re.S)
        if title and re.search(r"low-?fi", title.group(1), re.I):
            print(f"ERROR {hrel}: the title calls the page low-fi; with '{FULL}' the HTML is the full screen (CONVENTIONS §7)")
        for row in rows(section(text, 4)):
            name = row[0].strip("` ")
            if name not in STATES or len(row) < 3 or row[2].upper().startswith("N/A"):
                continue
            key = name.lower()
            if not re.search(rf"\bid=[\"']state-{key}[\"']", body):
                print(f"ERROR {hrel}: no element with id=\"state-{key}\" for the UI state {name} (CONVENTIONS §7)")
            elif key != "success" and not re.search(rf"href=[\"']#state-{key}[\"']", body):
                print(f"ERROR {hrel}: no link to #state-{key}, so the reviewer cannot reach the UI state {name} (CONVENTIONS §7)")
        wanted = {c for row in rows(section(text, 3))[1:] if len(row) > 1 for c in re.findall(r"CMP-\d{2}", row[1])}
        found = set(re.findall(r"data-cmp=[\"'](CMP-\d{2})[\"']", body))
        for cmp_id in sorted(wanted - found):
            print(f"ERROR {hrel}: the component table lists {cmp_id} but no element has data-cmp=\"{cmp_id}\" (CONVENTIONS §7)")
        for cmp_id in sorted(found - wanted):
            print(f"ERROR {hrel}: data-cmp=\"{cmp_id}\" is not in the component table of {rel} (CONVENTIONS §7)")


if __name__ == "__main__":
    main()
