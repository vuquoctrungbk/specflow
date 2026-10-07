#!/usr/bin/env python3
"""Check a project roadmap against the contract of CONVENTIONS section 11.

Usage:
  check-roadmap.py PROJECT_DIR

PROJECT_DIR holds docs/ (Intake, SRS, SPECs, ROADMAP.md) and plans/. The caller runs this only for a project whose Intake
comes from template 1.4.0 or later. The roadmap is compared with its sources: the FR catalog of SRS section 6.1, the
Must NFRs of SRS section 7, section 1.5 and 9 of every SPEC that is not superseded, the phases of every plan, and, for a
brownfield project, the "Giữ nguyên" rows of Gap Analysis section 2. Whether a commit or tag exists in git is not
checked: the worked examples have no history, so that part stays with the agent's reconciliation (PLAYBOOK 2.6).

Error contract: one line per finding, "ERROR <file>: <message>", each message ending with "(CONVENTIONS §11)". The exit
status is 0 whether or not there are findings; a non-zero exit status means the script could not run, which the caller
reports as a helper failure.
"""
import pathlib
import re
import sys

SUFFIX = " (CONVENTIONS §11)"
FR_RE = re.compile(r"^FR-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+$")
NFR_RE = re.compile(r"^NFR-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+$")
NFR_ANY = re.compile(r"NFR-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+")
TC_RE = re.compile(r"TC-[A-Z0-9]+(?:-[A-Z0-9]+)*-\d+")
COMMIT_RE = re.compile(r"^[0-9a-f]{7,40}$")
STATUSES = ("Chưa làm", "Đang làm", "Xong", "Đã xác nhận", "Bỏ")
DONE = ("Xong", "Đã xác nhận")
MOSCOW = {"Must": 0, "Should": 1, "Could": 2}
NONE = "Không có"
NOT_YET = "Chưa có"

findings = []


def err(path, msg):
    findings.append(f"ERROR {path}: {msg}{SUFFIX}")


def cells(line):
    """Cells of a table row; an escaped pipe (\\|) stays inside its cell, as in check-templates.sh."""
    body = line.strip()
    body = body[1:] if body.startswith("|") else body
    body = body[:-1] if body.endswith("|") and not body.endswith("\\|") else body
    return [c.replace("\\|", "|").strip().strip("`").strip() for c in re.split(r"(?<!\\)\|", body)]


def unfenced(text):
    out, fence = [], False
    for line in text.splitlines():
        if re.match(r"^\s*(```|~~~)", line):
            fence = not fence
            continue
        out.append("" if fence else line)
    return "\n".join(out)


def section(text, heading_re, stop_re):
    m = re.search(heading_re, text, re.M)
    if not m:
        return None
    rest = text[m.end():]
    s = re.search(stop_re, rest, re.M)
    return rest[: s.start()] if s else rest


def rows(block, first_re=None, width=0):
    """Data rows of every table in the block (header and separator rows dropped)."""
    out = []
    lines = [l for l in (block or "").splitlines()]
    for i, line in enumerate(lines):
        if not line.startswith("|"):
            continue
        if re.match(r"^\|\s*:?-{3,}", line):
            continue
        if i + 1 < len(lines) and re.match(r"^\|\s*:?-{3,}", lines[i + 1]):
            continue
        c = cells(line)
        if first_re is not None and not first_re.match(c[0]):
            continue
        if len(c) >= width:
            out.append(c)
    return out


def frontmatter(text, key):
    m = re.search(rf"^{key}: *\"?([^\"\n]*)\"?\s*$", text, re.M)
    return m.group(1).strip() if m else ""


def passed_gate(text):
    """A SPEC passed Gate 3, or a plan passed Gate 4, once its version reached 1.0.0; a draft (0.x) is not counted yet."""
    v = frontmatter(text, "version")
    return bool(re.match(r"^[1-9]\d*\.", v))


def phase_label(nums):
    """'3', '3 đến 6', or ranges joined by commas when the numbers are not consecutive."""
    nums, parts = sorted(set(nums)), []
    for n in nums:
        if parts and n == parts[-1][1] + 1:
            parts[-1][1] = n
        else:
            parts.append([n, n])
    return ", ".join(str(a) if a == b else f"{a} đến {b}" for a, b in parts)


def srs_files(root):
    """SRS files in reading order: a single SRS.md, or the modular master first and then the module files in the order of the
    master's section 6 table (a module the table does not list follows, by file name)."""
    files = sorted((root / "docs/srs").glob("*.md"))
    master = next((f for f in files if f.name.startswith("00_SRS_MASTER")), None)
    if master is None:
        return files
    listed = re.findall(r"docs/srs/[A-Za-z0-9_.-]+\.md", section(unfenced(master.read_text(encoding="utf-8")), r"^## 6\.", r"^## ") or "")
    by_path = {f.relative_to(root).as_posix(): f for f in files}
    ordered = [by_path[x] for i, x in enumerate(listed) if x in by_path and x not in listed[:i]]
    return [master] + ordered + [f for f in files if f is not master and f not in ordered]


def main():
    root = pathlib.Path(sys.argv[1])
    rm_path = root / "docs/ROADMAP.md"
    intake_path = root / "docs/intake/PROJECT_INTAKE.md"

    intake = unfenced(intake_path.read_text(encoding="utf-8"))
    routing = section(intake, r"^## 14\.", r"^## ") or ""
    tag_lines = [l for l in routing.splitlines() if re.match(r"^\|\s*Định dạng tag\s*\|", l)]
    if len(tag_lines) != 1 or not re.match(r"^\|\s*Định dạng tag\s*\|\s*`[^`]+`", tag_lines[0]):
        err(intake_path, "Intake from template 1.4.0 or later needs one 'Định dạng tag' row in section 14 with the tag pattern in backticks")

    if not rm_path.is_file():
        err(root, "project with Intake 1.4.0 or later has no docs/ROADMAP.md")
        return

    # Sources: SRS (one file, or master plus modules), SPECs, plans, Gap Analysis.
    frs, nfrs = [], []
    for p in srs_files(root):
        t = unfenced(p.read_text(encoding="utf-8"))
        frs += rows(section(t, r"^### 6\.1\.", r"^##+ "), FR_RE, 8)
        nfrs += rows(section(t, r"^## 7\.", r"^## "), NFR_RE, 9)
    srs_fr = {r[0]: r for r in frs}
    srs_nfr = {r[0]: r for r in nfrs}
    srs_releases = []
    for r in frs:
        if r[6] not in srs_releases:
            srs_releases.append(r[6])

    kept = set()
    gap = root / "docs/brownfield/GAP_ANALYSIS.md"
    if gap.is_file():
        g = unfenced(gap.read_text(encoding="utf-8"))
        kept = {c[0] for c in rows(section(g, r"^## 2\.", r"^## "), FR_RE, 4) if c[3].startswith("Giữ nguyên")}
    want_fr = [r for r in frs if r[5] != "Won't" and r[0] not in kept]
    want_nfr = [r for r in nfrs if r[7] == "Must"]
    want_fr_ids = {r[0] for r in want_fr}
    want_nfr_ids = {r[0] for r in want_nfr}

    specs, all_spec_ids = {}, set()
    for p in sorted((root / "docs/specs").glob("SPEC_*.md")):
        t = unfenced(p.read_text(encoding="utf-8"))
        sid = frontmatter(t, "spec_id")
        all_spec_ids.add(sid)
        if frontmatter(t, "status") == "superseded" or not passed_gate(t):
            continue
        block = section(t, r"^### 1\.5\.", r"^## ") or ""
        specs[sid] = {
            "status": frontmatter(t, "status"),
            "frs": [c[0] for c in rows(block, FR_RE)],
            "nfrs": set(NFR_ANY.findall(block)),
            "tcs": {c[0] for c in rows(section(t, r"^## 9\.", r"^## "), re.compile(r"^TC-"))},
            "phases": [],
            "open_phases": [],
        }
    approved_plans = {pl.parent for pl in root.glob("plans/*/plan.md") if passed_gate(pl.read_text(encoding="utf-8"))}
    for ph in sorted(root.glob("plans/*/phase-*.md")):
        if ph.parent not in approved_plans:
            continue
        t = ph.read_text(encoding="utf-8")
        sid, num = frontmatter(t, "spec_id"), frontmatter(t, "phase")
        if sid in specs and num.isdigit():
            specs[sid]["phases"].append(int(num))
            if frontmatter(t, "status") != "done":
                specs[sid]["open_phases"].append(int(num))
    planned = {frontmatter((d / "plan.md").read_text(encoding="utf-8"), "release") for d in approved_plans} - {""}
    spec_rank = {sid: (min(s["phases"]) if s["phases"] else 10**6, i) for i, (sid, s) in enumerate(specs.items())}
    fr_specs = {}
    for sid in sorted(specs, key=lambda x: spec_rank[x]):
        for fr in specs[sid]["frs"]:
            fr_specs.setdefault(fr, [])
            if sid not in fr_specs[fr]:
                fr_specs[fr].append(sid)

    # The roadmap itself.
    text = unfenced(rm_path.read_text(encoding="utf-8"))
    sec = {n: section(text, rf"^## {n}\.", r"^## ") for n in (1, 2, 3, 4, 5)}
    for n, name in ((1, "Tiến độ"), (2, "Hàng việc"), (3, "Yêu cầu mới"), (4, "Đã hoàn thành"), (5, "Mốc version")):
        if sec[n] is None:
            err(rm_path, f"roadmap has no section {n} ({name})")
    if any(sec[n] is None for n in (1, 2, 4, 5)):
        return
    sub = {k: section(sec[2], rf"^### 2\.{k}\.", r"^###? ") for k in (1, 2)}
    for k, name in ((1, "Yêu cầu chức năng"), (2, "Yêu cầu phi chức năng mức Must")):
        if sub[k] is None:
            err(rm_path, f"section 2 has no subsection 2.{k} ({name})")
    fr_rows = rows(sub[1], None, 8)
    nfr_rows = rows(sub[2], None, 7)

    # Releases: the rows of section 1 give their order (copied from the Intake); they hold exactly the SRS releases.
    prog_rows = rows(sec[1], None, 5)
    releases = []
    for c in prog_rows:
        if c[0] in releases:
            err(rm_path, f"section 1 has more than one row for release {c[0]}")
        elif c[0] not in srs_releases:
            err(rm_path, f"section 1 has a row for release {c[0]}, which no FR of SRS §6.1 has")
        else:
            releases.append(c[0])
    for rel in srs_releases:
        if rel not in releases:
            err(rm_path, f"section 1 has no row for release {rel}")
            releases.append(rel)

    def coverage(kind, have, want_ids, src, why, st_col):
        seen = {}
        for c in have:
            seen[c[1]] = seen.get(c[1], 0) + 1
        for rid in sorted(want_ids, key=lambda x: list(src).index(x)):
            if rid not in seen:
                err(rm_path, f"{rid} ({kind} of SRS) has no row in section 2")
        for rid, n in seen.items():
            if n > 1:
                err(rm_path, f"{rid} has a row in section 2 more than once")
        for c in have:
            if c[1] in want_ids:
                if c[st_col] == "Bỏ":
                    err(rm_path, f"row {c[1]} is Bỏ, but SRS still has it as {why}; Bỏ is only for a requirement the SRS dropped or moved out")
            elif c[st_col] != "Bỏ":
                detail = why_not(kind, c[1])
                err(rm_path, f"row {c[1]} is not {why}: {detail}")

    def why_not(kind, rid):
        if kind == "FR" and rid in srs_fr:
            return f"SRS §6.1 gives priority {srs_fr[rid][5]}" + (", and Gap Analysis says Giữ nguyên" if rid in kept else "")
        if kind != "FR" and rid in srs_nfr:
            return f"SRS §7 gives priority {srs_nfr[rid][7]}"
        return "SRS has no such ID"

    coverage("FR", fr_rows, want_fr_ids, srs_fr, "an FR of SRS §6.1 to do (priority other than Won't)", 7)
    coverage("Must NFR", nfr_rows, want_nfr_ids, srs_nfr, "a Must NFR of SRS §7", 6)

    for label, rs in (("2.1", fr_rows), ("2.2", nfr_rows)):
        for i, c in enumerate(rs, 1):
            if c[0] != str(i):
                err(rm_path, f"section {label} row {c[1]} is numbered '{c[0]}', not {i}; rows are numbered from 1")
                break

    status = {}
    for c in fr_rows:
        rid, st = c[1], c[7]
        status[rid] = st
        if st not in STATUSES:
            err(rm_path, f"row {rid} has status '{st}', not one of {', '.join(STATUSES)}")
        src = srs_fr.get(rid)
        if src:
            if c[2] != src[2]:
                err(rm_path, f"row {rid} has name '{c[2]}', but SRS §6.1 has '{src[2]}'")
            if c[3] != src[5]:
                err(rm_path, f"row {rid} has priority '{c[3]}', but SRS §6.1 has '{src[5]}'")
            if c[4] != src[6]:
                err(rm_path, f"row {rid} has release '{c[4]}', but SRS §6.1 has '{src[6]}'")
        sids = fr_specs.get(rid, [])
        want_spec = ", ".join(sids) or NOT_YET
        if c[5] != want_spec:
            err(rm_path, f"row {rid} has SPEC '{c[5]}', but " + (f"{want_spec} names it in §1.5" if sids else "no SPEC names it in §1.5, so 'Chưa có'"))
        nums = [n for s in sids for n in specs[s]["phases"]]
        want_phase = phase_label(nums) if nums else NOT_YET
        if c[6] != want_phase:
            err(rm_path, f"row {rid} has phase '{c[6]}', but the plan gives '{want_phase}'")
        if st in DONE and not sids:
            err(rm_path, f"row {rid} is {st}, but no SPEC names it in §1.5")
        open_ph = [n for s_ in sids for n in specs[s_]["open_phases"]]
        if st in DONE and open_ph:
            err(rm_path, f"row {rid} is {st}, but phase {phase_label(open_ph)} of its SPECs is not done")
        if st != "Bỏ" and c[4] in planned and (not sids or not nums):
            err(rm_path, f"row {rid} belongs to release {c[4]}, which has a plan, but has no SPEC or no phase")

    # Order of section 2.1: release (section 1 order), then rows with phases by first phase of their release plan, then
    # rows without phases by priority and SRS order. Rows marked Bỏ are left out of the order.
    def order_key(rid):
        src = srs_fr.get(rid)
        rel = releases.index(src[6]) if src and src[6] in releases else len(releases)
        sids = fr_specs.get(rid, [])
        nums = [n for s in sids for n in specs[s]["phases"]]
        if nums:
            return (rel, 0, min(nums), specs[sids[0]]["frs"].index(rid), 0)
        return (rel, 1, MOSCOW.get(src[5], 3) if src else 3, frs.index(src) if src else 0, 0)
    live = [c[1] for c in fr_rows if c[7] != "Bỏ"]
    expect = sorted(live, key=order_key)
    if live != expect:
        k = next(i for i, (a, b) in enumerate(zip(live, expect)) if a != b)
        err(rm_path, f"section 2.1 is out of order at row {live[k]}: {expect[k]} comes first (release, then first phase, then priority and SRS order)")

    # Work goes in roadmap order: a done row never follows a row of the same release that is still Chưa làm.
    open_row = {}
    for rid in expect:
        rel = srs_fr[rid][6] if rid in srs_fr else ""
        if status.get(rid) == "Chưa làm":
            open_row.setdefault(rel, rid)
        elif status.get(rid) in DONE and rel in open_row:
            err(rm_path, f"row {rid} is {status[rid]}, but the earlier row {open_row[rel]} of release {rel} is still Chưa làm")

    spec_order = []
    for rid in expect:
        for sid in fr_specs.get(rid, []):
            if sid not in spec_order:
                spec_order.append(sid)
    spec_order += [s for s in specs if s not in spec_order]
    live_nfr = [c[1] for c in nfr_rows if c[6] != "Bỏ"]
    nfr_expect = sorted(live_nfr, key=lambda x: list(srs_nfr).index(x) if x in srs_nfr else len(srs_nfr))
    if live_nfr != nfr_expect:
        k = next(i for i, (a, b) in enumerate(zip(live_nfr, nfr_expect)) if a != b)
        err(rm_path, f"section 2.2 is out of order at row {live_nfr[k]}: {nfr_expect[k]} comes first (SRS §7 order)")
    for c in nfr_rows:
        rid, st = c[1], c[6]
        status[rid] = st
        if st not in STATUSES:
            err(rm_path, f"row {rid} has status '{st}', not one of {', '.join(STATUSES)}")
        src = srs_nfr.get(rid)
        if src:
            if c[2] != src[1]:
                err(rm_path, f"row {rid} has name '{c[2]}', but the Nhóm of SRS §7 is '{src[1]}'")
            if c[4] != src[6]:
                err(rm_path, f"row {rid} has verification '{c[4]}', but SRS §7 has '{src[6]}'")
        named = ", ".join(s for s in spec_order if rid in specs[s]["nfrs"]) or NONE
        if c[3] != named:
            err(rm_path, f"row {rid} lists SPEC '{c[3]}', but the SPECs naming it in §1.5 are '{named}'")
        if c[5] not in releases:
            err(rm_path, f"row {rid} has closing release '{c[5]}', which is not a release of section 1")
        if st == "Đã xác nhận":
            open_frs = [f[1] for f in fr_rows if f[4] == c[5] and f[7] not in ("Đã xác nhận", "Bỏ")]
            if open_frs:
                err(rm_path, f"row {rid} is Đã xác nhận, but FR rows of its closing release {c[5]} are not all Đã xác nhận ({open_frs[0]})")

    def status_of(rid):
        return status.get(rid)

    # Section 4 and 5: evidence, commit, tag, milestone.
    done_rows = [c for c in rows(sec[4], None, 4) if c[0] != NONE]
    ms_rows = [c for c in rows(sec[5], None, 6) if c[0] != NONE]
    milestones, latest = {}, {}
    for c in ms_rows:
        if c[0] in milestones:
            err(rm_path, f"section 5 has more than one row for tag {c[0]}")
        milestones[c[0]] = c
        latest[c[1]] = c[0]
        if c[1] not in all_spec_ids:
            err(rm_path, f"section 5 tag {c[0]} names SPEC '{c[1]}', which is not a SPEC of the project")
        if not COMMIT_RE.match(c[2]):
            err(rm_path, f"section 5 tag {c[0]} has commit '{c[2]}', not a 7 to 40 character hex commit hash")
    for sid, tag in latest.items():
        reworked = sid in specs and specs[sid]["frs"] and all(status_of(fr) in ("Chưa làm", "Đang làm") for fr in specs[sid]["frs"])
        if not any(d[3] == tag for d in done_rows) and not reworked:
            err(rm_path, f"section 5 tag {tag} is the latest milestone of {sid}, but the tag of no row in section 4")
    by_id = {}
    for c in done_rows:
        if c[0] in by_id:
            err(rm_path, f"section 4 has more than one row for {c[0]}")
        by_id[c[0]] = c
        if status.get(c[0]) not in DONE:
            err(rm_path, f"section 4 has a row for {c[0]}, but its row in section 2 is not Xong or Đã xác nhận")
    for rid, st in status.items():
        if st not in DONE:
            continue
        d = by_id.get(rid)
        if not d:
            err(rm_path, f"row {rid} is {st} but has no row in section 4")
            continue
        if not COMMIT_RE.match(d[2]):
            err(rm_path, f"section 4 row {rid} has commit '{d[2]}', not a 7 to 40 character hex commit hash")
        is_fr = rid in srs_fr or bool(FR_RE.match(rid))
        if is_fr:
            sids = fr_specs.get(rid, [])
            tcs = TC_RE.findall(d[1])
            known = set().union(*(specs[s]["tcs"] for s in sids)) if sids else set()
            if not tcs or (sids and any(t not in known for t in tcs)):
                err(rm_path, f"section 4 row {rid} has no evidence of TCs from §9 of {', '.join(sids) or 'its SPEC'}")
        elif d[1] in ("", NONE, NOT_YET) or (srs_nfr.get(rid, [""] * 9)[6] == "Test" and not TC_RE.search(d[1])):
            err(rm_path, f"section 4 row {rid} has no evidence from SRS §8" + (" (a Test NFR needs TC IDs)" if srs_nfr.get(rid, [""] * 9)[6] == "Test" else ""))
        if st == "Xong" and d[3] != NOT_YET:
            err(rm_path, f"row {rid} is Xong, but section 4 gives it tag '{d[3]}'; the tag is 'Chưa có' until Đã xác nhận")
        if st == "Đã xác nhận":
            if d[3] in ("", NONE, NOT_YET):
                err(rm_path, f"row {rid} is Đã xác nhận, but section 4 gives it no tag")
            elif d[3] not in milestones:
                err(rm_path, f"section 4 tag '{d[3]}' of {rid} has no row in section 5")
            elif is_fr and milestones[d[3]][1] not in fr_specs.get(rid, []):
                err(rm_path, f"section 4 tag '{d[3]}' of {rid} is the milestone of {milestones[d[3]][1]}, not of a SPEC that names it")
            if is_fr:
                for sid in fr_specs.get(rid, []):
                    if specs[sid]["status"] != "implemented":
                        err(rm_path, f"row {rid} is Đã xác nhận, but {sid} is not implemented")

    # Section 3: decisions.
    for c in rows(sec[3], None, 4):
        if c[0] == NONE:
            continue
        dec = c[3]
        if dec == "Chờ":
            continue
        for word in ("Đưa vào change request", "Bỏ"):
            if dec.startswith(word):
                if len(dec[len(word):].strip(" :,;.-")) < 3:
                    err(rm_path, f"section 3 decision '{dec}' needs " + ("the document it changes" if word != "Bỏ" else "a reason"))
                break
        else:
            err(rm_path, f"section 3 decision '{dec}' is not Chờ, Đưa vào change request or Bỏ")

    # Section 1: counts per release and the line of work in progress.
    prog = {c[0]: c for c in prog_rows}
    for rel in releases:
        ids = [c[1] for c in fr_rows if c[4] == rel and c[7] != "Bỏ"] + [c[1] for c in nfr_rows if c[5] == rel and c[6] != "Bỏ"]
        tot = len(ids)
        x = sum(status.get(i) in DONE for i in ids)
        y = sum(status.get(i) == "Đã xác nhận" for i in ids)
        want = [str(tot), str(x), str(y), f"{y * 100 // tot if tot else 0}%"]
        have = prog.get(rel)
        if have and have[1:5] != want:
            err(rm_path, f"section 1 row {rel} gives {' | '.join(have[1:5])}, but section 2 gives {' | '.join(want)}")
    m = re.search(r"^- Đang làm: *(.*)$", sec[1], re.M)
    doing = [rid for rid, st in status.items() if st == "Đang làm"]
    if not m:
        err(rm_path, "section 1 has no '- Đang làm:' line")
    elif not doing and m.group(1).strip() != "Không":
        err(rm_path, f"section 1 says Đang làm '{m.group(1).strip()}', but no row of section 2 is Đang làm; write 'Không'")
    elif doing and not all(rid in m.group(1) for rid in doing):
        err(rm_path, f"section 1 says Đang làm '{m.group(1).strip()}', but {', '.join(doing)} is Đang làm in section 2")

if __name__ == "__main__":
    main()
    print("\n".join(findings))
