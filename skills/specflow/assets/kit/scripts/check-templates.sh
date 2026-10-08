#!/usr/bin/env bash
# Structural and contract checks for the specflow template set.
#
# Usage:
#   scripts/check-templates.sh             check core/, overlays/, starters/, brownfield/ and top-level docs
#   scripts/check-templates.sh --examples  check the worked examples under examples/
#   scripts/check-templates.sh --project DIR  check the documents of the project in DIR (CLAUDE.md, .claude/rules/,
#                                             the kit folders of docs/, and plan.md and phase files of plans/*/)
#
# Contract source: CONVENTIONS.md. The placeholder catalog (with value sources), slot catalog,
# doc_type groups, required-section rules and the docs-layout override block are parsed from it,
# so this script never duplicates those lists. It also parses the "- Giai đoạn 1W có khi" line of
# PLAYBOOK.md §2 for the UI overlays of Stage 1W. Marker lines and links inside fenced code blocks
# are ignored. Exit status: 0 when no error was found, 1 on errors, 2 on bad usage.
# Warnings are printed but never fail the run.

set -uo pipefail
# With pipefail, never end a pipeline in `grep -q`: an early exit sends SIGPIPE upstream and the
# pipeline fails even on a match. Use `grep ... >/dev/null` so grep reads its whole input.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE="templates"
PROJECT=""
case "${1:-}" in
  "") ;;
  --examples) MODE="examples" ;;
  --project)
    MODE="project"
    PROJECT="$(cd "${2:-}" 2>/dev/null && pwd)" || { echo "--project needs an existing directory" >&2; exit 2; }
    (($# == 2)) || { echo "--project takes one directory" >&2; exit 2; }
    [[ -d "$PROJECT/docs" ]] || { echo "$PROJECT has no docs/ directory" >&2; exit 2; }
    ;;
  -h | --help) sed -n '2,14p' "$0"; exit 0 ;;
  *) echo "unknown option: $1" >&2; exit 2 ;;
esac
cd "$ROOT" || exit 2
if [[ "$MODE" != project && ! -f scripts/expected-structure.txt ]]; then
  echo "This kit is installed in a project. Check the project documents with: bash $(basename "$ROOT")/scripts/check-templates.sh --project ." >&2
  exit 2
fi

CONVENTIONS="CONVENTIONS.md"
LEGACY_LAYOUTS="COMPATIBILITY.md"  # the layout blocks of earlier releases, kept out of the rules every agent loads
STRUCTURE_LIST="scripts/expected-structure.txt"
KIT_DIRS=(core overlays starters brownfield)
TOP_DOCS=(PLAYBOOK.md PROMPTS.md COMPATIBILITY.md CONVENTIONS.md README.md CHANGELOG.md)
PLACEHOLDER_RE='\{\{[A-Z][A-Z0-9_]*\}\}'

ERRORS=0
WARNINGS=0
# In project mode a finding names the file from the project root, not from the kit.
finding() {
  local where="$2" text="$3"
  if [[ -n "$PROJECT" ]]; then
    where="${where//"$PROJECT"\//}"
    [[ "$where" == "$PROJECT" ]] && where="."
    text="${text//"$PROJECT"\//}"
    text="${text//the example/the project}"
  fi
  printf '%s %s: %s\n' "$1" "$where" "$text"
}
err() { finding 'ERROR ' "$1" "$2"; ERRORS=$((ERRORS + 1)); }
warn() { finding 'WARN  ' "$1" "$2"; WARNINGS=$((WARNINGS + 1)); }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# existing <path...>: print only the paths that exist, one per line.
existing() {
  local p
  for p in "$@"; do [[ -e "$p" ]] && printf '%s\n' "$p"; done
}

# markdown_files <dir...>: markdown files (including *.md.template) under the given dirs, sorted.
markdown_files() {
  local dirs
  mapfile -t dirs < <(existing "$@")
  ((${#dirs[@]})) || return 0
  find "${dirs[@]}" -type f \( -name '*.md' -o -name '*.md.template' \) | sort
}

# unfenced <file>: "<line-number><TAB><text>" for every line outside fenced code blocks.
unfenced() {
  awk '/^[ \t]*(```|~~~)/ { fence = !fence; next } !fence { print NR "\t" $0 }' "$1"
}

# frontmatter_value <file> <key>: scalar value of a top-level key in the leading YAML frontmatter,
# with surrounding quotes and trailing comments removed.
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, key ":") == 1 {
      v = substr($0, length(key) + 2)
      sub(/^[ \t]+/, "", v); sub(/[ \t]+#.*$/, "", v); sub(/[ \t]+$/, "", v)
      if (v ~ /^".*"$/ || v ~ /^\x27.*\x27$/) v = substr(v, 2, length(v) - 2)
      print v; exit
    }' "$1"
}

# frontmatter_has_items <file> <key>: true when a list key holds at least one item (inline or block).
frontmatter_has_items() {
  awk -v key="$2" '
    NR == 1 { if ($0 != "---") exit 1; next }
    $0 == "---" { exit found ? 0 : 1 }
    index($0, key ":") == 1 {
      v = substr($0, length(key) + 2); sub(/^[ \t]+/, "", v); sub(/[ \t]+#.*$/, "", v)
      if (v ~ /^\[[ \t]*[^] \t]/) { found = 1 } else if (v == "") { inlist = 1 }
      next
    }
    inlist && /^[ \t]*- +[^ \t]/ { found = 1; next }
    inlist && /^[^ \t-]/ { inlist = 0 }
    END { exit found ? 0 : 1 }' "$1"
}

in_list() { grep -qxF -- "$1" "$2"; }

# frontmatter_list <file> <key>: items of a YAML list key (inline [a, b] or block "- a"), one per line.
frontmatter_list() {
  awk -v key="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, key ":") == 1 {
      v = substr($0, length(key) + 2); sub(/^[ \t]+/, "", v); sub(/[ \t]+#.*$/, "", v)
      if (v ~ /^\[/) {
        gsub(/^\[|\][ \t]*$/, "", v); n = split(v, parts, ",")
        for (i = 1; i <= n; i++) { item = parts[i]; gsub(/^[ \t"]+|[ \t"]+$/, "", item); if (item != "") print item }
      } else if (v == "") { inlist = 1 }
      next
    }
    inlist && /^[ \t]*- / { item = $0; sub(/^[ \t]*- +/, "", item); gsub(/^"|"$/, "", item); print item; next }
    inlist && /^[^ \t-]/ { inlist = 0 }' "$1"
}

# location <hit>: "file:line" from a "file:line:text" grep hit.
location() { printf '%s:%s' "${1%%:*}" "$(cut -d: -f2 <<< "$1")"; }

# ---------------------------------------------------------------------------
# Contract catalogs parsed from CONVENTIONS.md
# ---------------------------------------------------------------------------

load_catalogs() {
  if [[ ! -f "$CONVENTIONS" ]]; then
    err "$CONVENTIONS" "contract file is missing; nothing else can be checked"
    return 1
  fi
  # Placeholder catalog: table rows whose first cell is a backticked {{NAME}}; column 4 is the value source.
  grep -E "^\| \`$PLACEHOLDER_RE\`" "$CONVENTIONS" > "$TMP/placeholder-rows"
  grep -oE "^\| \`$PLACEHOLDER_RE" "$TMP/placeholder-rows" | grep -oE "$PLACEHOLDER_RE" | sort -u > "$TMP/placeholders"
  awk -F'|' '$5 ~ /Profile/ { print $2 }' "$TMP/placeholder-rows" | grep -oE "$PLACEHOLDER_RE" | sort -u > "$TMP/profile-placeholders"
  # Slot catalog: table rows whose first cell is a backticked slot marker with a concrete id.
  grep -E '^\| `<!-- SLOT: [a-z0-9.-]+ -->`' "$CONVENTIONS" > "$TMP/slot-rows"
  sed -E 's/^\| `<!-- SLOT: ([a-z0-9.-]+) -->`.*/\1/' "$TMP/slot-rows" | sort -u > "$TMP/slots"
  # doc_type groups: the bullet lines after the "`doc_type` hợp lệ" line; the infrastructure group is named "File hạ tầng".
  awk '/`doc_type` hợp lệ/ { on = 1; next } on && /^- / { print; next } on && NF { exit }' "$CONVENTIONS" > "$TMP/doc-type-lines"
  sed 's/^[^:]*://' "$TMP/doc-type-lines" | grep -oE '`[a-z-]+`' | tr -d '`' | sort -u > "$TMP/doc-types"
  grep 'File hạ tầng' "$TMP/doc-type-lines" | sed 's/^[^:]*://' | grep -oE '`[a-z-]+`' | tr -d '`' | sort -u > "$TMP/infra-types"
  comm -23 "$TMP/doc-types" "$TMP/infra-types" > "$TMP/document-types"
  # Required sections: the two indented bullets under "Mục bắt buộc theo `doc_type`".
  grep -E '^  - `Assumptions & Open Questions`:' "$CONVENTIONS" | sed 's/.*trừ//' | grep -oE '`[a-z-]+`' | tr -d '`' | sort -u > "$TMP/aoq-exempt"
  grep -E '^  - `Version History`:' "$CONVENTIONS" | sed 's/^  - `Version History`://' | grep -oE '`[a-z-]+`' | tr -d '`' | sort -u > "$TMP/history-types"
  # Further bullets there name sections before the colon and doc_types after it: "<doc_type>\t<section>" pairs.
  awk '/Mục bắt buộc theo `doc_type`/ { on = 1; next } on && /^  - / { print; next } on { exit }' "$CONVENTIONS" |
    grep -vE '^  - `(Assumptions & Open Questions|Version History)`:' |
    awk '{ i = index($0, ":"); names = substr($0, 1, i - 1); types = substr($0, i + 1); n = 0
      while (match(names, /`[^`]+`/)) { sec[++n] = substr(names, RSTART + 1, RLENGTH - 2); names = substr(names, RSTART + RLENGTH) }
      while (match(types, /`[a-z-]+`/)) { t = substr(types, RSTART + 1, RLENGTH - 2); types = substr(types, RSTART + RLENGTH); for (k = 1; k <= n; k++) print t "\t" sec[k] } }' \
    > "$TMP/extra-sections"
  # Vague terms of the requirement-quality rules (CONVENTIONS §8): backticked first cells of the "Từ mơ hồ" table.
  awk '/^\| Từ mơ hồ \|/ { on = 1; next } on && /^\|/ { print; next } on { exit }' "$CONVENTIONS" |
    grep -oE '^\| `[^`]+`' | sed -E 's/^\| `//; s/`$//' > "$TMP/vague-terms"
  # Valid status per doc_type (CONVENTIONS §3): "<doc_type>\t<status>" pairs from the status table.
  awk '/^Trạng thái hợp lệ theo `doc_type`/ { on = 1; next } on && /^\| `/ { print; next } on && /^\| ---/ { next } on && /^\|/ { next } on && NF && !/^\|/ { exit }' "$CONVENTIONS" |
    awk -F'|' '{ n = split($2, t, ","); m = split($3, v, ",")
      for (i = 1; i <= n; i++) { gsub(/[ `]/, "", t[i]); for (j = 1; j <= m; j++) { x = v[j]; gsub(/[ `]/, "", x); print t[i] "\t" x } } }' > "$TMP/status-map"
  # Docs-layout override block, markers excluded.
  awk '/^<!-- END: docs-layout-override -->$/ { on = 0 } on { print } /^<!-- BEGIN: docs-layout-override -->$/ { on = 1 }' \
    "$CONVENTIONS" > "$TMP/layout-block"
  # Legacy blocks still accepted (COMPATIBILITY §6): one "docs-layout-legacy-<label>" diff per earlier release, each
  # rebuilt into the old block it stands for (build_legacy_layout). Labels are listed in $TMP/layout-legacy-labels.
  grep -oE '^<!-- BEGIN: docs-layout-legacy-[A-Za-z0-9._-]+ -->$' "$LEGACY_LAYOUTS" |
    sed -E 's/^<!-- BEGIN: docs-layout-legacy-//; s/ -->$//' > "$TMP/layout-legacy-labels"
  local label
  while IFS= read -r label; do
    build_legacy_layout "$label"
  done < "$TMP/layout-legacy-labels"

  # Overlays whose projects have Stage 1W (PLAYBOOK §2): the backticked names before ", hoặc bề mặt khác" on its
  # "- Giai đoạn 1W có khi" line.
  grep -m1 '^- Giai đoạn 1W có khi' PLAYBOOK.md 2>/dev/null | sed 's/, hoặc bề mặt khác.*//; s/^[^:]*://' |
    grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u > "$TMP/ui-overlays"
  [[ -s "$TMP/ui-overlays" ]] || err "PLAYBOOK.md" "cannot parse the UI overlays of Stage 1W from the '- Giai đoạn 1W có khi' line of §2"

  # UI/UX standards of the wireframe (CONVENTIONS §10), so no key, name or value is written into this script:
  # "<key>\t<name>" rows of the heuristic table (§10.3, first column "Khóa heuristic") and of the deceptive pattern table
  # (§10.4, first column "Khóa mẫu lừa"); the problem levels of §10.3 ("mức vấn đề là một trong `A | B | C`") and the
  # level that Gate 1W blocks ("Vấn đề `X` được sửa trước Gate 1W"); the two results of §10.4 ("Kết quả là `clean` kèm
  # căn cứ ..., hoặc `found` kèm vị trí").
  first_header_table "$CONVENTIONS" 'Khóa heuristic' 'Tên' | grep -v '^#HEADER$' | tr -d '`' > "$TMP/ux-heuristics"
  first_header_table "$CONVENTIONS" 'Khóa mẫu lừa' 'Tên' | grep -v '^#HEADER$' | tr -d '`' > "$TMP/ux-deceptive"
  # The four lines below only make sense inside §10.3 and §10.4 (the levels, blocking level and clean/found result
  # words belong to those two sections); reading them from the whole file would pick up an unrelated sentence placed
  # anywhere earlier, such as in an ID scheme example. section_rows already cuts one section to its next heading.
  { section_rows "$CONVENTIONS" '^### 10\.3\.'; section_rows "$CONVENTIONS" '^### 10\.4\.'; } > "$TMP/ux-1034"
  grep -m1 -oE 'mức vấn đề là một trong `[^`]+`' "$TMP/ux-1034" | sed -E 's/.*`([^`]+)`$/\1/' | tr '|' '\n' |
    sed -E 's/^ +| +$//g' | grep -v '^$' > "$TMP/ux-levels"
  grep -m1 -oE '^Vấn đề `[^`]+` được sửa trước Gate 1W' "$TMP/ux-1034" | cut -d'`' -f2 > "$TMP/ux-level-blocking"
  grep -m1 -oE 'Kết quả là `[^`]+` kèm căn cứ' "$TMP/ux-1034" | cut -d'`' -f2 > "$TMP/ux-dp-clean"
  grep -m1 -oE 'hoặc `[^`]+` kèm vị trí' "$TMP/ux-1034" | cut -d'`' -f2 > "$TMP/ux-dp-found"

  # Design tokens (§10.7): the DTCG types of the table "Kiểu DTCG" and the tier groups of the table "Nhóm tầng", in the
  # order written there (lowest tier first), one name per line, for scripts/check-design-tokens.py.
  # Both tables sit inside list items, indented; first_header_table reads tables from the line start, so the indent of
  # table lines is dropped in a copy first.
  sed -E 's/^ +\|/|/' "$CONVENTIONS" > "$TMP/conventions-flat"
  first_header_table "$TMP/conventions-flat" 'Kiểu DTCG' 'Kiểu DTCG' | grep -v '^#HEADER$' | cut -f1 | tr -d '`' > "$TMP/dtcg-types"
  first_header_table "$TMP/conventions-flat" 'Nhóm tầng' 'Nhóm tầng' | grep -v '^#HEADER$' | cut -f1 | tr -d '`' > "$TMP/dtcg-tiers"

  local name
  for name in placeholders slots doc-types infra-types history-types layout-block layout-legacy-labels vague-terms status-map \
    ux-heuristics ux-deceptive ux-levels ux-level-blocking ux-dp-clean ux-dp-found; do
    [[ -s "$TMP/$name" ]] || err "$CONVENTIONS" "cannot parse '$name' from the contract"
  done
  for name in dtcg-types dtcg-tiers; do
    [[ -s "$TMP/$name" ]] || err "$CONVENTIONS" "cannot parse '$name' from the contract (CONVENTIONS §10.7)"
  done
  grep -qE '^  - `Assumptions & Open Questions`:' "$CONVENTIONS" ||
    err "$CONVENTIONS" "cannot parse the 'Assumptions & Open Questions' rule from the contract"
  return 0
}

is_document_type() { in_list "$1" "$TMP/document-types"; }

# emit_helper_lines <label> <output>: turn the "ERROR <file>: <msg>" and "WARN <file>: <msg>" lines of a design token helper
# into err and warn; any other line is an error of its own, since the helper must print findings only.
emit_helper_lines() {
  local label="$1" line what="${3:-design token helper}" ref="${4:-CONVENTIONS §10.7}"
  while IFS= read -r line; do
    case "$line" in
      "ERROR "*) line="${line#ERROR }"; err "${line%%: *}" "${line#*: }" ;;
      "WARN "*) line="${line#WARN }"; warn "${line%%: *}" "${line#*: }" ;;
      "") ;;
      *) err "$label" "$what printed an unexpected line ($ref)" ;;
    esac
  done <<< "$2"
}

# run_token_helper <label> <token-file>...: run scripts/check-design-tokens.py on one base token file and its mode files
# and turn each "ERROR <file>: <msg>" or "WARN <file>: <msg>" line into err or warn. The helper exits 0 even with
# findings; a non-zero exit status means it could not run, which is an error of its own (CONVENTIONS §10.7). Without
# python3 the token files are not validated and one warning says so. Extra options for the helper come from
# $TOKEN_HELPER_OPTS (for example --template).
run_token_helper() {
  local label="$1" out status line
  shift
  if ! command -v python3 >/dev/null 2>&1; then
    warn "$label" "no python3; design tokens not validated (CONVENTIONS §10.7)"
    return 0
  fi
  out="$(python3 scripts/check-design-tokens.py --types "$TMP/dtcg-types" --tiers "$TMP/dtcg-tiers" ${TOKEN_HELPER_OPTS:-} "$@" 2>&1)"
  status=$?
  if ((status != 0)); then
    err "$label" "design token helper failed (exit $status) (CONVENTIONS §10.7)"
    return 0
  fi
  emit_helper_lines "$label" "$out"
}

# check_design_tokens <example-dir>: the token files of a project whose Intake comes from template 1.3.0 or later
# (CONVENTIONS §10.7): docs/design-system/tokens.json and its mode files tokens.<mode>.json.
check_design_tokens() {
  local dir="$1" intake="$1/docs/intake/PROJECT_INTAKE.md" ds="$1/docs/design-system" mode
  local modes=()
  [[ -f "$intake" ]] && version_at_least "$(gate_version "$intake" core/00_Project_Intake_Template.md)" 1.3.0 || return 0
  [[ -d "$ds" ]] || return 0
  while IFS= read -r mode; do
    modes+=("$mode")
  done < <(find "$ds" -maxdepth 1 -type f -name 'tokens.*.json' | sort)
  [[ -f "$ds/tokens.json" || ${#modes[@]} -gt 0 ]] || return 0
  run_token_helper "$dir" "$ds/tokens.json" ${modes[@]+"${modes[@]}"}
}

# check_roadmap <example-dir>: the roadmap of a project whose Intake comes from template 1.4.0 or later (CONVENTIONS §11),
# checked by scripts/check-roadmap.py against the SRS, SPECs, plans and Gap Analysis. The helper prints findings only and
# exits 0; a non-zero exit status is an error of its own. Without python3 the roadmap is not validated and one warning
# says so.
check_roadmap() {
  local dir="$1" intake="$1/docs/intake/PROJECT_INTAKE.md" out status
  [[ -f "$intake" ]] && version_at_least "$(gate_version "$intake" core/00_Project_Intake_Template.md)" 1.4.0 || return 0
  if ! command -v python3 >/dev/null 2>&1; then
    warn "$dir" "no python3; roadmap not validated (CONVENTIONS §11)"
    return 0
  fi
  out="$(python3 scripts/check-roadmap.py "$dir" 2>&1)"
  status=$?
  if ((status != 0)); then
    err "$dir" "roadmap helper failed (exit $status) (CONVENTIONS §11)"
    return 0
  fi
  emit_helper_lines "$dir" "$out" "roadmap helper" "CONVENTIONS §11"
}

# table_rows <file> <first-header-prefix>: every data row, as its cells joined by tabs with backticks removed, of the first
# table outside fenced code whose first header cell starts with <first-header-prefix>.
table_rows() {
  awk -v a="$2" '
    /^[ \t]*(```|~~~)/ { fence = !fence; intable = 0; next }
    fence || !/^\|/ { intable = 0; next }
    {
      line = $0; gsub(/\\\|/, "\001", line); n = split(line, c, "|")
      if (!intable) {
        intable = 1; header = 1; gsub(/^ +| +$/, "", c[2])
        want = (!found && index(c[2], a) == 1); if (want) found = 1
        next
      }
      if (header) { header = 0; next }
      if (!want) next
      out = ""
      for (i = 2; i < n; i++) { gsub(/^ +| +$/, "", c[i]); gsub(/\001/, "|", c[i]); gsub(/`/, "", c[i]); out = out (i > 2 ? "\t" : "") c[i] }
      print out
    }' "$1"
}

# catalog_rows <ds-file> <first-header> <column-header> <out-file>: the "<ID>\t<cell>" rows of one catalog table, header
# marker dropped.
catalog_rows() { first_header_table "$1" "$2" "$3" | grep -v '^#HEADER$' > "$4"; }

# check_design_system <example-dir>: the design system document and the pages that use it (CONVENTIONS §10.7).
# Gated: the Intake is from template 1.3.0 or later, the wireframe index from 1.3.0, and at least one page from 1.4.0.
# Bash checks the document (the file set, the Template, Pattern and Component IDs of the pages, unused catalog entries,
# the visual direction). Contrast and the token use of HTML wireframes need the token values, so they go to
# scripts/check-design-token-use.py, which is skipped without python3 (check_design_tokens already warns).
check_design_system() {
  local dir="$1" intake="$1/docs/intake/PROJECT_INTAKE.md" wf="$1/docs/wireframes" ds="$1/docs/design-system/DESIGN_SYSTEM.md"
  local index="$1/docs/wireframes/00_WIREFRAME_INDEX.md" page pages=() id ids n line name html out status surface
  local suffix=" (CONVENTIONS §10.7)" cmp_re='CMP-[0-9]{2}' pat_re='PAT-[0-9]{2}' tpl_re='TPL-[0-9]{2}'
  [[ -f "$intake" ]] && version_at_least "$(gate_version "$intake" core/00_Project_Intake_Template.md)" 1.3.0 || return 0
  [[ -f "$index" ]] && version_at_least "$(gate_version "$index" core/07_Wireframe_Template/00_Wireframe_Index_Template.md)" 1.3.0 || return 0
  for page in "$wf"/SCR-*.md; do
    [[ -f "$page" ]] && version_at_least "$(gate_version "$page" core/07_Wireframe_Template/SCR_Screen_Template.md)" 1.4.0 && pages+=("$page")
  done
  ((${#pages[@]})) || return 0

  # 1. The document and the token file exist.
  if [[ ! -f "$ds" ]]; then
    err "$index" "the project has pages from screen template 1.4.0 but no docs/design-system/DESIGN_SYSTEM.md$suffix"
    return 0
  fi
  [[ -f "$1/docs/design-system/tokens.json" ]] || err "$ds" "no docs/design-system/tokens.json next to the design system document$suffix"

  # 2. Each page names one Template, its Patterns (or Không) and a Component ID per component, all in the catalogs.
  catalog_rows "$ds" 'Component ID' 'Component dùng' "$TMP/ds-cmp"
  catalog_rows "$ds" 'Pattern ID' 'Component dùng' "$TMP/ds-pat"
  catalog_rows "$ds" 'Template ID' 'Pattern dùng' "$TMP/ds-tpl-pat"
  catalog_rows "$ds" 'Template ID' 'Component dùng' "$TMP/ds-tpl-cmp"
  cut -f1 "$TMP/ds-cmp" | grep -oE "$cmp_re" | sort -u > "$TMP/ds-cmp-ids"
  cut -f1 "$TMP/ds-pat" | grep -oE "$pat_re" | sort -u > "$TMP/ds-pat-ids"
  cut -f1 "$TMP/ds-tpl-pat" | grep -oE "$tpl_re" | sort -u > "$TMP/ds-tpl-ids"
  : > "$TMP/ds-roots"
  for page in "${pages[@]}"; do
    n="$(grep -c '^- Template:' "$page")"
    if ((n == 0)); then
      err "$page" "no 'Template:' line; a page names exactly one Template$suffix"
    elif ((n > 1)); then
      err "$page" "has $n 'Template:' lines; a page names exactly one Template$suffix"
    fi
    ids="$(grep '^- Template:' "$page" | grep -oE "$tpl_re")"
    if ((n == 1)) && [[ -z "$ids" ]]; then
      err "$page" "the 'Template:' line names no TPL-NN$suffix"
    elif ((n == 1)) && [[ "$(wc -l <<< "$ids")" -gt 1 ]]; then
      err "$page" "the 'Template:' line names more than one Template$suffix"
    fi
    while IFS= read -r id; do
      [[ -n "$id" ]] || continue
      printf '%s\n' "$id" >> "$TMP/ds-roots"
      in_list "$id" "$TMP/ds-tpl-ids" || err "$page" "$id is not in the Template catalog of DESIGN_SYSTEM.md$suffix"
    done <<< "$ids"

    line="$(grep -m 1 '^- Pattern:' "$page")"
    if [[ -z "$line" ]]; then
      err "$page" "no 'Pattern:' line; write the PAT-NN the page uses, or Không$suffix"
    else
      ids="$(grep -oE "$pat_re" <<< "$line")"
      line="${line#- Pattern:}"; line="${line//\`/}"; line="${line# }"
      if [[ -z "$ids" && "$line" != Không* ]]; then
        err "$page" "the 'Pattern:' line names no PAT-NN and is not Không$suffix"
      fi
      while IFS= read -r id; do
        [[ -n "$id" ]] || continue
        printf '%s\n' "$id" >> "$TMP/ds-roots"
        in_list "$id" "$TMP/ds-pat-ids" || err "$page" "$id is not in the Pattern catalog of DESIGN_SYSTEM.md$suffix"
      done <<< "$ids"
    fi

    first_header_table "$page" 'Thành phần' 'Component ID' > "$TMP/ds-page-cmp"
    if ! grep -qx '#HEADER' "$TMP/ds-page-cmp"; then
      err "$page" "the components table has no 'Component ID' column$suffix"
      continue
    fi
    while IFS=$'\t' read -r name line; do
      ids="$(grep -oE "$cmp_re" <<< "$line")"
      if [[ -z "$ids" ]]; then
        err "$page" "component '$name' has no CMP-NN in the Component ID column$suffix"
        continue
      fi
      while IFS= read -r id; do
        printf '%s\n' "$id" >> "$TMP/ds-roots"
        in_list "$id" "$TMP/ds-cmp-ids" || err "$page" "$id is not in the Component catalog of DESIGN_SYSTEM.md$suffix"
      done <<< "$ids"
    done < <(grep -v '^#HEADER$' "$TMP/ds-page-cmp")
  done

  # 3. The catalogs list only entries a page uses, directly or through the Component dùng and Pattern dùng columns of
  #    an entry that is used.
  : > "$TMP/ds-edges"
  for name in ds-cmp ds-pat ds-tpl-pat ds-tpl-cmp; do
    while IFS=$'\t' read -r id line; do
      grep -oE "$cmp_re|$pat_re" <<< "$line" | awk -v f="$id" '{ print f "\t" $0 }' >> "$TMP/ds-edges"
    done < "$TMP/$name"
  done
  awk -F'\t' -v roots="$TMP/ds-roots" '
    FILENAME == roots { seen[$1] = 1; next }
    { from[++n] = $1; to[n] = $2 }
    END { do { changed = 0; for (i = 1; i <= n; i++) if ((from[i] in seen) && !(to[i] in seen)) { seen[to[i]] = 1; changed = 1 } } while (changed)
          for (k in seen) print k }' "$TMP/ds-roots" "$TMP/ds-edges" | sort > "$TMP/ds-used"
  for id in $(cat "$TMP/ds-cmp-ids" "$TMP/ds-pat-ids" "$TMP/ds-tpl-ids"); do
    in_list "$id" "$TMP/ds-used" || err "$ds" "$id is not used by any page or by a used catalog entry; the catalog lists only entries in use$suffix"
  done

  # 6. One visual direction: two or three directions, exactly one chosen with a reason, and the library default theme stated.
  first_header_table "$ds" 'Hướng' 'Chọn' | grep -v '^#HEADER$' > "$TMP/ds-directions"
  n="$(wc -l < "$TMP/ds-directions")"; n="${n// /}"
  if ((n < 2 || n > 3)); then
    err "$ds" "the direction table has $n row$([[ $n == 1 ]] || printf s); propose 2 to 3 visual directions$suffix"
  fi
  n="$(cut -f2 "$TMP/ds-directions" | grep -cxF 'Có')"
  ((n == 1)) || err "$ds" "$n directions are marked 'Có' in the Chọn column; the owner chooses exactly one$suffix"
  line="$(sed -n 's/^Lý do chọn:[[:space:]]*//p' "$ds" | head -n 1)"
  line="${line//<!--*-->/}"
  [[ -n "${line//[[:space:]]/}" ]] || err "$ds" "the 'Lý do chọn:' line is missing or empty; give the reason for the chosen direction$suffix"
  if ! grep -q '^Theme mặc định của thư viện:' "$ds"; then
    err "$ds" "the 'Theme mặc định của thư viện:' line is missing; write Không dùng, or Dùng có chủ đích with a reason$suffix"
  else
    line="$(sed -n 's/^Theme mặc định của thư viện:[[:space:]]*//p' "$ds" | head -n 1)"
    case "$line" in
      "Không dùng"*) ;;
      "Dùng có chủ đích"*)
        line="${line#Dùng có chủ đích}"
        [[ -n "$(tr -d '[:space:],.:;-' <<< "$line")" ]] ||
          err "$ds" "'Dùng có chủ đích' needs a reason after it$suffix" ;;
      *) err "$ds" "the 'Theme mặc định của thư viện:' line must start with 'Không dùng' or 'Dùng có chủ đích'$suffix" ;;
    esac
  fi

  # 4 and 5. Contrast and the token use of HTML wireframes: the values come from the token files.
  command -v python3 >/dev/null 2>&1 || return 0
  table_rows "$ds" 'Mode' > "$TMP/ds-modes"
  table_rows "$ds" 'Token trước' | awk -F'\t' -v OFS='\t' '{ print NR, $0 }' > "$TMP/ds-contrast"
  : > "$TMP/ds-html"
  for page in "${pages[@]}"; do
    html="$wf/html/$(basename "$page" .md).html"
    [[ -f "$html" ]] || continue
    surface="$(frontmatter_list "$page" overlays | paste -sd, -)"
    printf '%s\t%s\n' "$html" "$surface" >> "$TMP/ds-html"
  done
  out="$(python3 scripts/check-design-token-use.py --tiers "$TMP/dtcg-tiers" --root "$dir" --doc "$ds" \
    --modes "$TMP/ds-modes" --contrast "$TMP/ds-contrast" --html "$TMP/ds-html" 2>&1)"
  status=$?
  if ((status != 0)); then
    err "$ds" "design token use helper failed (exit $status)$suffix"
    return 0
  fi
  emit_helper_lines "$ds" "$out"
  out="$(python3 scripts/check-full-html.py "$dir" 2>&1)"
  status=$?
  if ((status != 0)); then
    err "$ds" "full HTML helper failed (exit $status) (CONVENTIONS §7)"
    return 0
  fi
  emit_helper_lines "$ds" "$out" "full HTML helper" "CONVENTIONS §7"
}

# build_legacy_layout <label>: write $TMP/layout-legacy-<label>, the old docs-layout block that the labelled diff of
# CONVENTIONS §6 describes. The diff lists lines in the order of the current block. A "+" line right after a "-" line is
# a changed line: the old block has the "-" text in its place. A "+" line with no "-" line right before it is an
# inserted line: the old block does not have it. Every other line of the current block is unchanged. The "+" lines are
# matched against the current block in order, so a diff that does not fit the current block is a contract error.
build_legacy_layout() {
  local label="$1" diff="$TMP/layout-legacy-diff-$1"
  awk -v label="$label" '
    $0 == "<!-- END: docs-layout-legacy-" label " -->" { on = 0 }
    on && /^[-+]/ { print }
    $0 == "<!-- BEGIN: docs-layout-legacy-" label " -->" { on = 1 }' "$LEGACY_LAYOUTS" > "$diff"
  if [[ ! -s "$diff" ]]; then
    err "$LEGACY_LAYOUTS" "legacy layout block docs-layout-legacy-$label has no '-' or '+' line (COMPATIBILITY §6)"
    return
  fi
  awk -v diff="$diff" '
    BEGIN {
      while ((getline line < diff) > 0) {
        t = substr(line, 1, 1); s = substr(line, 2)
        if (t == "-") { if (pending) bad = 1; pending = 1; old = s; continue }
        n++; plus[n] = s; changed[n] = pending; if (pending) was[n] = old; pending = 0
      }
      if (pending) bad = 1
    }
    k < n && $0 == plus[k + 1] { k++; if (changed[k]) print was[k]; next }
    { print }
    END { exit (bad || k != n) ? 3 : 0 }' "$TMP/layout-block" > "$TMP/layout-legacy-$label" ||
    err "$LEGACY_LAYOUTS" "legacy layout block docs-layout-legacy-$label does not fit the current block: a '-' line without a '+' line after it, or a '+' line that is not in the current block in diff order (CONVENTIONS §6)"
}

# ---------------------------------------------------------------------------
# Shared checks
# ---------------------------------------------------------------------------

# check_frontmatter <file...>: leading frontmatter with a valid doc_type and the keys every file needs.
check_frontmatter() {
  local f doc_type key
  for f in "$@"; do
    case "$(basename "$f")" in README.md | CHANGELOG.md) continue ;; esac
    if [[ "$(head -n 1 "$f")" != "---" ]] || ! awk 'NR > 1 && $0 == "---" { found = 1; exit } END { exit !found }' "$f"; then
      err "$f" "missing YAML frontmatter delimited by '---'"
      continue
    fi
    doc_type="$(frontmatter_value "$f" doc_type)"
    if [[ -z "$doc_type" ]]; then
      err "$f" "frontmatter has no doc_type"
    elif ! in_list "$doc_type" "$TMP/doc-types"; then
      err "$f" "doc_type '$doc_type' is not listed in $CONVENTIONS"
    fi
    for key in status version language; do
      [[ -n "$(frontmatter_value "$f" "$key")" ]] || err "$f" "frontmatter has no $key"
    done
  done
}

# check_required_sections <file...>: sections required for the file's doc_type by CONVENTIONS §7.
check_required_sections() {
  local f doc_type type section
  for f in "$@"; do
    doc_type="$(frontmatter_value "$f" doc_type)"
    is_document_type "$doc_type" || continue
    if ! in_list "$doc_type" "$TMP/aoq-exempt" && ! grep -qE '^#+ .*Assumptions & Open Questions' "$f"; then
      err "$f" "doc_type '$doc_type' requires an 'Assumptions & Open Questions' section"
    fi
    if in_list "$doc_type" "$TMP/history-types" && ! grep -qE '^#+ .*Version History' "$f"; then
      err "$f" "doc_type '$doc_type' requires a 'Version History' section"
    fi
    while IFS=$'\t' read -r type section; do
      [[ "$type" == "$doc_type" ]] || continue
      grep -E '^#+ ' "$f" | grep -qF -- "$section" || err "$f" "doc_type '$doc_type' requires a '$section' section"
    done < "$TMP/extra-sections"
  done
}

# check_links <copied-content-policy> <file...>: relative links resolve; with policy "strict", content that
# will be copied into a project (template files, overlay and profile blocks) must not use relative links.
check_links() {
  local policy="$1" f lineno in_block target path copied doc_type
  local phase_link='^phase-[0-9]{2}-[a-z0-9-]+\.md$'
  shift
  for f in "$@"; do
    copied=0
    doc_type="$(frontmatter_value "$f" doc_type)"
    if [[ "$policy" == "strict" && "$f" =~ ^(core|overlays|starters|brownfield)/ ]] && is_document_type "$doc_type"; then
      copied=1
    fi
    while IFS=$'\t' read -r lineno in_block target; do
      target="${target%% \"*}"
      target="${target#<}"
      target="${target%>}"
      case "$target" in '' | '#'* | http://* | https://* | mailto:* | *://*) continue ;; esac
      if [[ "$policy" == "strict" ]] && ((copied || in_block)); then
        # The only allowed link: plan.md -> a sibling phase-NN-<slug>.md file copied together with it.
        if ((in_block)) || [[ "$doc_type" != implementation-plan || ! "${target#./}" =~ $phase_link ]]; then
          err "$f:$lineno" "relative link '$target' in content copied into projects; write the path in inline code"
          continue
        fi
      fi
      path="${target%%#*}"
      path="${path%%\?*}"
      path="${path//%20/ }"
      [[ -z "$path" ]] && continue
      if [[ "$path" == /* ]]; then path="$ROOT$path"; else path="$(dirname "$f")/$path"; fi
      [[ -e "$path" ]] || err "$f:$lineno" "broken relative link '$target'"
    done < <(awk '
      /^[ \t]*(```|~~~)/ { fence = !fence; next }
      fence { next }
      /^<!-- (SLOT|PROFILE)-CONTENT: / { block = 1 }
      /^<!-- \/(SLOT|PROFILE)-CONTENT -->/ { block = 0 }
      {
        line = $0
        gsub(/`[^`]*`/, "", line)
        while (match(line, /\]\([^)]+\)/)) {
          print NR "\t" (block ? 1 : 0) "\t" substr(line, RSTART + 2, RLENGTH - 3)
          line = substr(line, RSTART + RLENGTH)
        }
      }' "$f")
  done
}

# check_layout_block <file> [current-only]: the file carries the docs-layout override block verbatim, markers included.
# Generated CLAUDE.md files may keep any legacy block listed in CONVENTIONS §6; templates must carry the current one.
check_layout_block() {
  local f="$1" current_only="${2:-}" label
  if ! grep -qx '<!-- BEGIN: docs-layout-override -->' "$f" || ! grep -qx '<!-- END: docs-layout-override -->' "$f"; then
    err "$f" "missing docs-layout-override block (copy both marker lines and the content from $CONVENTIONS §6)"
    return
  fi
  awk '/^<!-- END: docs-layout-override -->$/ { on = 0 } on { print } /^<!-- BEGIN: docs-layout-override -->$/ { on = 1 }' \
    "$f" > "$TMP/layout-candidate"
  cmp -s "$TMP/layout-block" "$TMP/layout-candidate" && return
  if [[ -z "$current_only" ]]; then
    while IFS= read -r label; do
      [[ -f "$TMP/layout-legacy-$label" ]] && cmp -s "$TMP/layout-legacy-$label" "$TMP/layout-candidate" && return
    done < "$TMP/layout-legacy-labels"
  fi
  err "$f" "docs-layout-override block differs from $CONVENTIONS (must be copied verbatim; the legacy blocks of COMPATIBILITY.md §6 are also accepted)"
}

# check_assembled_from <file...>: every "path@version" source exists; warn when the source is newer by a MINOR or MAJOR.
check_assembled_from() {
  local f item path ver current
  for f in "$@"; do
    while IFS= read -r item; do
      path="${item%@*}"
      ver="${item##*@}"
      if [[ "$item" != *@* || ! -f "$path" ]]; then
        err "$f" "assembled_from source '$item' does not exist (expected path@version from the kit root)"
        continue
      fi
      current="$(frontmatter_value "$path" template_version)"
      [[ -n "$current" ]] || current="$(frontmatter_value "$path" version)"
      if [[ "$ver" != "$current" ]]; then
        if [[ "$(printf '%s\n%s\n' "$ver" "$current" | sort -V | tail -n 1)" == "$current" ]]; then
          # A PATCH release of the source only rewords; it does not ask for re-assembly (CONVENTIONS §3).
          [[ "${ver%.*}" == "${current%.*}" ]] ||
            warn "$f" "assembled_from '$item' is older than the source (now $current); review the source changes and re-assemble"
        else
          err "$f" "assembled_from '$item' is newer than the source (now $current)"
        fi
      fi
    done < <(frontmatter_list "$f" assembled_from)
  done
}

# check_profile_listed <file>...: a generated document assembled from overlay content that needs a stack
# profile (PROFILE-SLOT lines or Profile placeholders) also lists a stack profile of that overlay. A surface
# named in "stack_profile_none" has no matching profile and is filled from project sources instead
# (CONVENTIONS §2, §3); such a surface must not also list a profile.
check_profile_listed() {
  local f item path surface
  for f in "$@"; do
    frontmatter_list "$f" assembled_from > "$TMP/items"
    frontmatter_list "$f" stack_profile_none > "$TMP/no-profile"
    while IFS= read -r item; do
      path="${item%@*}"
      [[ "$path" == overlays/*/* && "$path" != */stack-profiles/* && -f "$path" ]] || continue
      surface="$(cut -d/ -f2 <<< "$path")"
      grep -qxF "$surface" "$TMP/no-profile" && continue
      grep -E '^<!-- PROFILE-SLOT: ' "$path" >/dev/null ||
        [[ -n "$(grep -oE "$PLACEHOLDER_RE" "$path" | sort -u | comm -12 - "$TMP/profile-placeholders")" ]] || continue
      grep -E "^overlays/$surface/stack-profiles/[^@]+\.md@" "$TMP/items" >/dev/null ||
        err "$f" "assembled from $path, which needs a stack profile, but lists no overlays/$surface/stack-profiles/ source"
    done < "$TMP/items"
    while IFS= read -r surface; do
      grep -E "^overlays/$surface/stack-profiles/" "$TMP/items" >/dev/null &&
        err "$f" "stack_profile_none names $surface but assembled_from lists a stack profile of that surface"
    done < "$TMP/no-profile"
  done
}

# ---------------------------------------------------------------------------
# Starter verification: re-assemble each starter file from its declared sources (CONVENTIONS §2)
# and compare byte for byte. Verification only; the kit ships no starter generator.
# ---------------------------------------------------------------------------

# slot_levels: "slot-id=###;..." from the "Cấp khối" column of the CONVENTIONS slot catalog.
slot_levels() {
  grep -E '^\| `<!-- SLOT: [a-z0-9.-]+ -->` \|' "$CONVENTIONS" |
    sed -E 's/^\| `<!-- SLOT: ([a-z0-9.-]+) -->` \|[^|]*\| `(#+)` \|.*/\1=\2/' | paste -sd';' -
}

# min_heading_level <file>: smallest number of leading # among headings outside fenced code (99 when none).
min_heading_level() {
  awk '/^[ \t]*(```|~~~)/ { fence = !fence; next } !fence && /^#+ / { n = index($0, " ") - 1; if (min == "" || n < min) min = n } END { print (min == "" ? 99 : min) }' "$1"
}

# display_names: "surface=Display Name;..." parsed from the "Tên hiển thị bề mặt" line of CONVENTIONS §2.
display_names() {
  grep -m1 -E '^- Tên hiển thị bề mặt: ' "$CONVENTIONS" | sed -E 's/^- Tên hiển thị bề mặt: //; s/\.$//' |
    sed -E 's/, /\n/g' | sed -E 's/^`([a-z0-9-]+)` là (.+)$/\1=\2/' | paste -sd';' -
}

# extract_overlay_blocks <surface> <out-dir>: one file per SLOT-CONTENT id, plus "<id>\t<path@version>" lines in <out-dir>/src.
extract_overlay_blocks() {
  local surface="$1" out="$2" f ver
  mkdir -p "$out"
  : > "$out/src"
  while IFS= read -r f; do
    ver="$(frontmatter_value "$f" template_version)"
    [[ -n "$ver" ]] || ver="$(frontmatter_value "$f" version)"
    awk -v out="$out" -v src="$f@$ver" '
      NR == 1 && $0 == "---" { fm = 1; next }
      fm { if ($0 == "---") fm = 0; next }
      !fence && /^<!-- SLOT-CONTENT: [a-z0-9.-]+ -->[ \t]*$/ {
        split($0, p, " "); open = p[3]; printf "" > (out "/" open); print open "\t" src >> (out "/src"); next
      }
      !fence && /^<!-- \/SLOT-CONTENT -->[ \t]*$/ { close(out "/" open); open = ""; next }
      /^[ \t]*(```|~~~)/ { fence = !fence }
      open != "" { print >> (out "/" open) }
    ' "$f"
  done < <(markdown_files "overlays/$surface" | grep -v '/stack-profiles/' | grep -v '/agent-rules/')
}

# assemble_starter <core-file> <comma-separated-surfaces> <is-agent-context 0|1> <out-file>
assemble_starter() {
  local core="$1" surfaces="$2" is_claude="$3" out="$4" work surface levels core_ver n f rule_ver display
  local -a surface_list
  work="$(mktemp -d "$TMP/asm.XXXXXX")"
  levels="$(slot_levels)"
  IFS=',' read -r -a surface_list <<< "$surfaces"
  display="$(display_names)"
  for surface in "${surface_list[@]}"; do
    [[ ";$display" == *";$surface="* ]] || err "overlays/$surface" "surface has no display name in $CONVENTIONS §2"
    extract_overlay_blocks "$surface" "$work/$surface"
  done
  : > "$work/used"
  awk -v surfaces="$surfaces" -v asm="$work" -v levels="$levels" -v display="$display" -v used="$work/used" '
    BEGIN {
      ns = split(surfaces, S, ",")
      n = split(levels, lv, ";"); for (i = 1; i <= n; i++) { split(lv[i], kv, "="); L[kv[1]] = length(kv[2]) }
      n = split(display, dv, ";"); for (i = 1; i <= n; i++) { split(dv[i], kv, "="); D[kv[1]] = kv[2] }
    }
    NR == 1 && $0 == "---" { fm = 1; next }
    fm { if ($0 == "---") fm = 0; next }
    hint && /^<!-- slot-hint:/ { next }
    { hint = 0 }
    !fence && /^<!-- SLOT: [a-z0-9.-]+ -->[ \t]*$/ {
      split($0, p, " "); id = p[3]; hint = 1
      for (k = 1; k <= ns; k++) {
        file = asm "/" S[k] "/" id
        if (ns > 1) {
          if (k > 1) print ""
          h = ""; for (i = 0; i < L[id]; i++) h = h "#"
          print h " " D[S[k]]; print ""
        }
        infence = 0
        while ((getline line < file) > 0) {
          if (ns > 1 && !infence && line ~ /^#{1,5} /) line = "#" line
          if (line ~ /^[ \t]*(```|~~~)/) infence = !infence
          print line
        }
        close(file)
        print S[k] "\t" id >> used
      }
      next
    }
    /^[ \t]*(```|~~~)/ { fence = !fence }
    { print }
  ' "$core" > "$work/body"
  core_ver="$(frontmatter_value "$core" template_version)"
  {
    printf '%s@%s\n' "$core" "$core_ver"
    while IFS=$'\t' read -r surface id; do
      awk -F'\t' -v id="$id" '$1 == id { print $2; exit }' "$work/$surface/src"
    done < "$work/used" | awk '!seen[$0]++'
  } > "$work/sources"
  if [[ "$is_claude" == 1 ]]; then
    n=2
    for surface in "${surface_list[@]}"; do
      while IFS= read -r f; do
        n=$((n + 1))
        rule_ver="$(frontmatter_value "$f" template_version)"
        printf '%s@%s\n' "$f" "$rule_ver" >> "$work/sources"
        { printf '\n### A.%d. `.claude/rules/%s`\n\n```markdown\n' "$n" "$(basename "$f")"; cat "$f"; printf '```\n'; } >> "$work/body"
      done < <(find "overlays/$surface/agent-rules" -type f -name '*.md' 2>/dev/null | sort)
    done
  fi
  awk -v ovl="${surfaces//,/, }" -v srcfile="$work/sources" '
    NR == 1 { print; next }
    done { next }
    /^---$/ { print; done = 1; next }
    /^overlays:/ { print "overlays: [" ovl "]"; next }
    /^assembled_from:/ { print "assembled_from:"; while ((getline x < srcfile) > 0) print "  - " x; skip = 1; next }
    skip && /^[ \t]+- / { next }
    { skip = 0; print }
  ' "$core" > "$out"
  cat "$work/body" >> "$out"
}

# check_starter_assembly: every starter file equals the re-assembly of its declared sources.
check_starter_assembly() {
  local file core surfaces is_claude expected first
  while IFS= read -r file; do
    [[ "$(basename "$file")" == README.md ]] && continue
    core="$(frontmatter_list "$file" assembled_from | head -n 1)"
    core="${core%@*}"
    surfaces="$(frontmatter_list "$file" overlays | paste -sd, -)"
    if [[ "$core" != core/* || ! -f "$core" || -z "$surfaces" ]]; then
      err "$file" "starter must declare its core template first in assembled_from and list overlays"
      continue
    fi
    is_claude=0
    [[ "$(basename "$file")" == CLAUDE.md.template ]] && is_claude=1
    expected="$TMP/expected-starter"
    assemble_starter "$core" "$surfaces" "$is_claude" "$expected"
    if ! cmp -s "$expected" "$file"; then
      first="$(diff "$expected" "$file" | grep -m1 -E '^[<>]')"
      err "$file" "differs from re-assembling $core with overlays [$surfaces] (first difference: ${first:0:80}); re-assemble instead of editing the starter"
    fi
  done < <(markdown_files starters)
}

# ---------------------------------------------------------------------------
# Template-set checks
# ---------------------------------------------------------------------------

check_structure() {
  local line
  if [[ ! -f "$STRUCTURE_LIST" ]]; then
    err "$STRUCTURE_LIST" "required-path list is missing"
    return
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    if [[ "$line" == */ ]]; then
      [[ -d "$line" ]] || err "$line" "required directory is missing (listed in $STRUCTURE_LIST)"
    else
      [[ -f "$line" ]] || err "$line" "required file is missing (listed in $STRUCTURE_LIST)"
    fi
  done < "$STRUCTURE_LIST"
}

check_legacy_patterns() {
  local targets pattern hit f lineno text
  mapfile -t targets < <(existing "${KIT_DIRS[@]}" "${TOP_DOCS[@]}")
  ((${#targets[@]})) || return 0
  for pattern in '[Tên Dự Án]' '[vX.X]' '[MODULE_NAME'; do
    while IFS= read -r hit; do
      err "$(location "$hit")" "legacy placeholder '$pattern' (see $CONVENTIONS §1)"
    done < <(grep -rnF -- "$pattern" "${targets[@]}")
  done
  for pattern in cursorrules windsurf; do
    while IFS= read -r hit; do
      err "$(location "$hit")" "reference to '$pattern'; the set targets Claude Code"
    done < <(grep -rniF -- "$pattern" "${targets[@]}")
  done
  # LaTeX math delimiters, outside fenced code (fences may hold SQL dollar-quoting or shell).
  while IFS= read -r f; do
    while IFS=$'\t' read -r lineno text; do
      [[ "$text" == *'$$'* || "$text" == *'$\'* ]] && err "$f:$lineno" "LaTeX math delimiter (see $CONVENTIONS §7)"
    done < <(unfenced "$f")
  done < <(markdown_files "${KIT_DIRS[@]}"; existing "${TOP_DOCS[@]}")
}

# Heuristic: names of languages, frameworks, databases and tools that belong in overlays or profiles, not in the
# stack-neutral core and brownfield sets.
check_stack_neutral_core() {
  local any_case='NestJS|Nest\.js|Prisma|TypeORM|Drizzle|Sequelize|Next\.js|Nuxt|Angular|Svelte|Fastify|Django|FastAPI|Flask|Laravel|PostgreSQL|Postgres|MySQL|MariaDB|MongoDB|SQLite|Redis|Kafka|RabbitMQ|TypeScript|JavaScript|Python|Kotlin|Golang|PHP|Ruby|Zod|Vitest|Jest|Pytest|Playwright|Cypress|Flutter|Tailwind|Node\.js|npm|pnpm|yarn|tsc|eslint|Docker|Kubernetes'
  local exact_case='React|Vue|Express|Spring|Rails|Swift|Rust|Java|Expo'
  local hit word dirs
  mapfile -t dirs < <(existing core brownfield)
  ((${#dirs[@]})) || return 0
  while IFS= read -r hit; do
    word="$(grep -oiwE "$any_case|$exact_case" <<< "${hit#*:*:}" | head -n 1)"
    err "$(location "$hit")" "stack-specific name '$word' in ${hit%%/*}; move it to an overlay or stack profile"
  done < <({ grep -rniwE "$any_case" "${dirs[@]}"; grep -rnwE "$exact_case" "${dirs[@]}"; } | sort -u)
}

check_placeholders() {
  local targets hit file lineno token
  mapfile -t targets < <(existing "${KIT_DIRS[@]}" PLAYBOOK.md PROMPTS.md COMPATIBILITY.md)
  ((${#targets[@]})) || return 0
  while IFS= read -r hit; do
    file="${hit%%:*}"
    lineno="$(cut -d: -f2 <<< "$hit")"
    token="${hit#*:*:}"
    if ! in_list "$token" "$TMP/placeholders"; then
      err "$file:$lineno" "placeholder $token is not in the $CONVENTIONS catalog"
    elif [[ "$file" == core/* || "$file" == brownfield/* ]] && in_list "$token" "$TMP/profile-placeholders"; then
      err "$file:$lineno" "placeholder $token takes its value from a stack profile and must not appear in ${file%%/*}"
    fi
  done < <(grep -rnoE "$PLACEHOLDER_RE" "${targets[@]}" | sort -u)
}

# Headings of core and brownfield templates are numbered (CONVENTIONS §7). The Implementation Plan template follows
# the plan layout of CONVENTIONS §9; the Agent Context template's Documentation Layout section and its appendix are exempt.
check_numbered_headings() {
  local f doc_type lineno text
  while IFS= read -r f; do
    [[ "$f" == core/05_Implementation_Plan_Template/* ]] && continue
    doc_type="$(frontmatter_value "$f" doc_type)"
    is_document_type "$doc_type" || continue
    while IFS=$'\t' read -r lineno text; do
      err "$f:$lineno" "heading is not numbered as '## N.' or '### N.M.' (see $CONVENTIONS §7): $text"
    done < <(unfenced "$f" | awk -F'\t' -v agent_context="$([[ "$f" == core/06_Agent_Context_Template.md ]] && echo 1)" '
      agent_context && $2 ~ /^## Phụ lục/ { appendix = 1 }
      appendix || (agent_context && $2 == "## Documentation Layout") { next }
      $2 ~ /^###? / && $2 !~ /^## [0-9]+\. / && $2 !~ /^### [0-9]+\.[0-9]+\. / { print }')
  done < <(markdown_files core brownfield)
}

# The Regression Baseline's Gate 0R self-check repeats, word for word, the criteria that PLAYBOOK_BROWNFIELD §3.1
# assigns to that document, so the two lists cannot drift apart.
check_gate_0r_rows() {
  local baseline=brownfield/02_Regression_Baseline_Template.md playbook=brownfield/PLAYBOOK_BROWNFIELD.md row
  [[ -f "$baseline" && -f "$playbook" ]] || return 0
  section_rows "$baseline" '^## [0-9]+\. .*Gate 0R' | grep -E '\| \[ \] \|$' | sort > "$TMP/gate-0r-baseline"
  section_rows "$playbook" '^### [0-9]+\.[0-9]+\. Gate 0R' | grep -E '\| \[ \] \|$' | sort > "$TMP/gate-0r-playbook"
  if [[ ! -s "$TMP/gate-0r-baseline" || ! -s "$TMP/gate-0r-playbook" ]]; then
    err "$baseline" "cannot find the Gate 0R checklist here or in $playbook"
    return
  fi
  while IFS= read -r row; do
    err "$baseline" "Gate 0R row differs from $playbook: $row"
  done < <(comm -23 "$TMP/gate-0r-baseline" "$TMP/gate-0r-playbook")
  while IFS= read -r row; do
    err "$playbook" "Gate 0R row is missing from $baseline: $row"
  done < <(comm -13 "$TMP/gate-0r-baseline" "$TMP/gate-0r-playbook")
}

# parse_blocks <file> <kind> <out>: validate SLOT-CONTENT or PROFILE-CONTENT blocks of one file.
# Appends "<file>\t<id>" per block to <out> and "<file>\t<block-id>\t<profile-slot-id>" per PROFILE-SLOT
# line to <out>.profile-slots. Prints ERROR lines for structural problems.
parse_blocks() {
  local file="$1" kind="$2" out="$3"
  unfenced "$file" | awk -F'\t' -v file="$file" -v kind="$kind" -v out="$out" -v ps="$out.profile-slots" '
    {
      n = $1; line = $0; sub(/^[0-9]+\t/, "", line)
    }
    line ~ ("^<!-- " kind ": [a-z0-9.-]+ -->[ \t]*$") {
      if (open != "") printf "ERROR  %s:%d: nested %s block inside %s\n", file, n, kind, open
      split(line, parts, " "); open = parts[3]; print file "\t" open >> out; next
    }
    line ~ ("^<!-- /" kind " -->[ \t]*$") {
      if (open == "") printf "ERROR  %s:%d: closing %s without an opening block\n", file, n, kind
      open = ""; next
    }
    line ~ ("^<!-- /?" kind) { printf "ERROR  %s:%d: malformed %s line\n", file, n, kind; next }
    line ~ /^<!-- PROFILE-SLOT: [a-z0-9.-]+ -->[ \t]*$/ {
      split(line, parts, " ")
      if (kind != "SLOT-CONTENT") printf "ERROR  %s:%d: PROFILE-SLOT is only allowed inside an overlay SLOT-CONTENT block\n", file, n
      else if (open == "") printf "ERROR  %s:%d: PROFILE-SLOT outside a SLOT-CONTENT block\n", file, n
      else if (parts[3] != open) printf "ERROR  %s:%d: PROFILE-SLOT %s inside SLOT-CONTENT %s (ids must match)\n", file, n, parts[3], open
      print file "\t" open "\t" parts[3] >> ps; next
    }
    line ~ /^<!-- PROFILE-SLOT/ { printf "ERROR  %s:%d: malformed PROFILE-SLOT line\n", file, n; next }
    END { if (open != "") printf "ERROR  %s: %s block %s is not closed\n", file, kind, open }
  ' > "$TMP/awk-errors"
  if [[ -s "$TMP/awk-errors" ]]; then
    cat "$TMP/awk-errors"
    ERRORS=$((ERRORS + $(wc -l < "$TMP/awk-errors")))
  fi
}

# forbid_marker <file> <regex> <message>: error for every unfenced line matching the marker regex.
forbid_marker() {
  local lineno text
  while IFS=$'\t' read -r lineno text; do
    [[ "$text" =~ $2 ]] && err "$1:$lineno" "$3"
  done < <(unfenced "$1")
}

check_slots() {
  local file lineno text id row located marker_files dir surface section_files profile_files profile ids token level levels
  levels="$(slot_levels)"
  local marker_line='^<!-- SLOT: ([a-z0-9.-]+) -->[[:space:]]*$'
  local any_slot_line='^<!-- SLOT:'
  local foreign_marker='^<!-- (PROFILE-SLOT|/?SLOT-CONTENT|/?PROFILE-CONTENT)'

  # Slot markers in core, brownfield and PLAYBOOK: well-formed and catalogued; no profile or block markers there.
  : > "$TMP/core-slot-ids"
  while IFS= read -r file; do
    while IFS=$'\t' read -r lineno text; do
      if [[ "$text" =~ $marker_line ]]; then
        id="${BASH_REMATCH[1]}"
        printf '%s\n' "$id" >> "$TMP/core-slot-ids"
        in_list "$id" "$TMP/slots" || err "$file:$lineno" "slot '$id' is not in the $CONVENTIONS slot catalog"
      elif [[ "$text" =~ $any_slot_line ]]; then
        err "$file:$lineno" "malformed slot marker line"
      elif [[ "$text" =~ $foreign_marker ]]; then
        err "$file:$lineno" "overlay or profile marker in a core file"
      fi
    done < <(unfenced "$file")
  done < <(markdown_files core brownfield; existing PLAYBOOK.md PROMPTS.md COMPATIBILITY.md)
  sort -u -o "$TMP/core-slot-ids" "$TMP/core-slot-ids"

  # Every catalogued slot is present in each file named in its location column.
  while IFS= read -r row; do
    id="$(sed -E 's/^\| `<!-- SLOT: ([a-z0-9.-]+) -->`.*/\1/' <<< "$row")"
    mapfile -t marker_files < <(awk -F'|' '{ print $3 }' <<< "$row" | grep -oE '`[^`]+\.md`' | tr -d '`')
    for located in "${marker_files[@]}"; do
      if [[ ! -f "$located" ]]; then
        warn "$located" "slot '$id' belongs here but the file does not exist yet"
      elif ! unfenced "$located" | cut -f2- | grep -xE "<!-- SLOT: ${id//./\\.} -->[[:space:]]*" >/dev/null; then
        err "$located" "missing slot marker for '$id' required by the $CONVENTIONS slot catalog"
      fi
    done
  done < "$TMP/slot-rows"

  # Overlays: directories under overlays/ that carry OVERLAY.md.
  : > "$TMP/all-overlay-blocks"
  local overlay_count=0
  for dir in overlays/*/; do
    [[ -d "$dir" ]] || continue
    surface="$(basename "$dir")"
    if [[ ! -f "$dir/OVERLAY.md" ]]; then
      [[ -n "$(markdown_files "$dir")" ]] && err "overlays/$surface" "directory has markdown files but no OVERLAY.md"
      continue
    fi
    overlay_count=$((overlay_count + 1))
    : > "$TMP/blocks"
    : > "$TMP/blocks.profile-slots"
    mapfile -t section_files < <(markdown_files "$dir" | grep -v '/stack-profiles/')
    for file in "${section_files[@]}"; do
      parse_blocks "$file" SLOT-CONTENT "$TMP/blocks"
      forbid_marker "$file" '^<!-- /?PROFILE-CONTENT' "PROFILE-CONTENT belongs in a stack profile, not in an overlay section"
      forbid_marker "$file" '^<!-- SLOT: ' "core SLOT marker inside an overlay file"
    done
    cat "$TMP/blocks" >> "$TMP/all-overlay-blocks"
    while IFS=$'\t' read -r file id; do
      in_list "$id" "$TMP/slots" || err "$file" "SLOT-CONTENT '$id' is not in the $CONVENTIONS slot catalog"
    done < "$TMP/blocks"
    extract_overlay_blocks "$surface" "$TMP/xb-$surface"
    while IFS=$'\t' read -r id located; do
      [[ "$id" == srs.* ]] || continue
      while IFS= read -r token; do
        err "${located%@*}" "SLOT-CONTENT $id uses $token, a stack-profile placeholder; SRS content stays stack-neutral (CONVENTIONS §1)"
      done < <(grep -oE "$PLACEHOLDER_RE" "$TMP/xb-$surface/$id" | sort -u | comm -12 - "$TMP/profile-placeholders")
    done < "$TMP/xb-$surface/src"
    # Heading levels: block content never rises above the slot's "Cấp khối" (CONVENTIONS §2).
    while IFS=$'\t' read -r id located; do
      level="$(tr ';' '\n' <<< "$levels" | awk -F= -v id="$id" '$1 == id { print length($2) }')"
      [[ -n "$level" ]] || continue
      (($(min_heading_level "$TMP/xb-$surface/$id") >= level)) ||
        err "${located%@*}" "SLOT-CONTENT $id has a heading above its block level (${level} #)"
    done < "$TMP/xb-$surface/src"
    # PROFILE-SLOT lines never sit in srs.* blocks: the SRS is written before the stack is fixed.
    while IFS=$'\t' read -r file id token; do
      [[ "$id" == srs.* ]] && err "$file" "PROFILE-SLOT $token inside SLOT-CONTENT $id; SRS content stays stack-neutral (CONVENTIONS §1)"
    done < "$TMP/blocks.profile-slots"
    ids="$(cut -f2 "$TMP/blocks" | sort)"
    while IFS= read -r id; do
      [[ -n "$id" ]] && err "overlays/$surface" "slot '$id' is provided more than once"
    done < <(uniq -d <<< "$ids")
    while IFS= read -r id; do
      grep -qxF -- "$id" <<< "$ids" || err "overlays/$surface" "overlay does not provide slot '$id'"
    done < "$TMP/slots"

    # Stack profiles of this overlay.
    cut -f3 "$TMP/blocks.profile-slots" | sort -u > "$TMP/profile-slot-ids"
    for file in "${section_files[@]}"; do grep -oE "$PLACEHOLDER_RE" "$file"; done | sort -u |
      comm -12 - "$TMP/profile-placeholders" > "$TMP/needed-values"
    mapfile -t profile_files < <(find "$dir" -path '*/stack-profiles/*' -type f -name '*.md' | sort)
    if ((${#profile_files[@]} == 0)) && { [[ -s "$TMP/profile-slot-ids" ]] || [[ -s "$TMP/needed-values" ]]; }; then
      err "overlays/$surface" "overlay uses PROFILE-SLOT lines or profile placeholders but has no stack profile"
    fi
    for profile in "${profile_files[@]}"; do
      : > "$TMP/pblocks"
      parse_blocks "$profile" PROFILE-CONTENT "$TMP/pblocks"
      forbid_marker "$profile" '^<!-- /?SLOT-CONTENT' "stack profile must not contain SLOT-CONTENT blocks"
      grep -qE '^#+ .*\(Tech Stack\)' "$profile" ||
        err "$profile" "stack profile needs a section whose heading contains '(Tech Stack)' (CONVENTIONS §2)"
      rm -rf "$TMP/pb" && mkdir -p "$TMP/pb"
      awk -v out="$TMP/pb" '
        /^[ \t]*(```|~~~)/ { fence = !fence }
        !fence && /^<!-- PROFILE-CONTENT: [a-z0-9.-]+ -->[ \t]*$/ { split($0, p, " "); open = p[3]; printf "" > (out "/" open); next }
        !fence && /^<!-- \/PROFILE-CONTENT -->[ \t]*$/ { close(out "/" open); open = ""; next }
        open != "" { print >> (out "/" open) }
      ' "$profile"
      for located in "$TMP"/pb/*; do
        [[ -f "$located" ]] || continue
        id="$(basename "$located")"
        level="$(tr ';' '\n' <<< "$levels" | awk -F= -v id="$id" '$1 == id { print length($2) }')"
        [[ -n "$level" ]] || continue
        (($(min_heading_level "$located") >= level)) ||
          err "$profile" "PROFILE-CONTENT $id has a heading above its block level (${level} #)"
      done
      cut -f2 "$TMP/pblocks" | sort > "$TMP/pblock-ids"
      while IFS= read -r id; do
        [[ -n "$id" ]] && err "$profile" "PROFILE-CONTENT '$id' is provided more than once"
      done < <(uniq -d "$TMP/pblock-ids")
      while IFS= read -r id; do
        err "$profile" "no PROFILE-CONTENT block for the overlay's PROFILE-SLOT '$id'"
      done < <(sort -u "$TMP/pblock-ids" | comm -13 - "$TMP/profile-slot-ids")
      while IFS= read -r id; do
        err "$profile" "PROFILE-CONTENT '$id' has no matching PROFILE-SLOT in the overlay"
      done < <(sort -u "$TMP/pblock-ids" | comm -23 - "$TMP/profile-slot-ids")
      while IFS= read -r id; do
        grep -qE "^\| \`\{\{$id\}\}\` \|" "$profile" 2>/dev/null ||
          err "$profile" "no value for {{$id}} in the 'Giá trị placeholder' table"
      done < <(sed -E 's/^\{\{(.*)\}\}$/\1/' "$TMP/needed-values")
    done
  done

  if ((overlay_count == 0)); then
    while IFS= read -r id; do
      warn "overlays/" "no overlay provides slot '$id' yet"
    done < "$TMP/core-slot-ids"
  else
    while IFS= read -r id; do
      cut -f2 "$TMP/all-overlay-blocks" | grep -xF -- "$id" >/dev/null || err "overlays/" "no overlay provides slot '$id' used in core"
    done < "$TMP/core-slot-ids"
  fi
}

# check_pattern_notation <file>...: text that is copied into project documents (templates, starters, SLOT-CONTENT and
# PROFILE-CONTENT blocks, filled examples) uses no pattern notation outside fill comments (CONVENTIONS §1): angle
# brackets such as `<slug>`, single-brace `{MOD}`, `NNN`. Fenced code is skipped except `text` and `markdown` blocks
# (directory trees and blocks pasted into documents); the Documentation Layout block may use notation.
# Not notation: a type argument (`<` right after a letter, digit, `)` or `]`, or `<T>`/`<T,>`), a tag that is closed
# somewhere in the file, a self-closing or PascalCase JSX tag, an HTML element name, `<br>`, autolinks, `${VAR}`.
# With --blocks, only lines inside SLOT-CONTENT or PROFILE-CONTENT count.
check_pattern_notation() {
  local blocks=0 f hit
  [[ "${1:-}" == --blocks ]] && { blocks=1; shift; }
  for f in "$@"; do
    while IFS= read -r hit; do
      err "$f:${hit%%$'\t'*}" "pattern notation '${hit#*$'\t'}' in content copied into project documents; write the value or a {{PLACEHOLDER}} (CONVENTIONS §1)"
    done < <(awk -v blocks="$blocks" '
      BEGIN {
        n = split("a abbr article aside b blockquote body br button canvas caption code col dd details dialog div dl dt em fieldset figure footer form h1 h2 h3 h4 h5 h6 head header hr html i iframe img input kbd label legend li link main mark meta nav noscript ol optgroup option output p pre progress script section select slot small source span strong style sub summary sup table tbody td template textarea tfoot th thead time title tr u ul video", tags, " ")
        for (i = 1; i <= n; i++) html[tags[i]] = 1
      }
      FNR == 1 { while ((getline l < FILENAME) > 0) { t = l; while (match(t, /<\/[A-Za-z][A-Za-z0-9_-]*>/)) { closed[substr(t, RSTART + 2, RLENGTH - 3)] = 1; t = substr(t, RSTART + RLENGTH) } } close(FILENAME) }
      function report(text) { printf "%d\t%s\n", FNR, text; reported = 1 }
      function is_tag(tok,   name) {
        if (tok ~ /\/>$/) return 1
        name = tok; sub(/^<[ ]*/, "", name); sub(/[ >].*$/, "", name)
        if (name in closed) return 1
        if (name in html) return 1
        if (name ~ /^[A-Z][a-z]+([A-Z][A-Za-z0-9]*)*$/ && name ~ /^[A-Za-z0-9]+$/ && tok ~ /^<[A-Za-z]/) return 1
        if (tok ~ /^<[A-Z],?>$/) return 1
        return 0
      }
      FNR == 1 && $0 == "---" { fm = 1; next }
      fm { if ($0 == "---") fm = 0; next }
      /^<!-- (SLOT|PROFILE)-CONTENT: / { on = 1; next }
      /^<!-- \/(SLOT|PROFILE)-CONTENT -->/ { on = 0; next }
      /^<!-- BEGIN: docs-layout-override -->/ { layout = 1; next }
      /^<!-- END: docs-layout-override -->/ { layout = 0; next }
      layout { next }
      /^[ \t]*(```|~~~)/ { if (!fence) { fence = 1; textfence = ($0 ~ /^[ \t]*(```|~~~)(text|markdown)[ \t]*$/) } else { fence = 0; textfence = 0 } next }
      (fence && !textfence) || (blocks && !on) { next }
      {
        line = $0; out = ""
        while (line != "") {
          if (incomment) {
            e = index(line, "-->"); if (!e) { line = ""; break }
            line = substr(line, e + 3); incomment = 0; continue
          }
          s = index(line, "<!--"); if (!s) { out = out line; break }
          out = out substr(line, 1, s - 1); line = substr(line, s + 4); incomment = 1
        }
        gsub(/<br[ ]*\/?>/, "", out); gsub(/<https?:[^>]*>/, "", out)
        reported = 0; rest = out; offset = 0
        while (!reported && match(rest, /<[ ]*[A-Za-zÀ-ỹ][^<>=`]*>/)) {
          tok = substr(rest, RSTART, RLENGTH)
          prev = (offset + RSTART > 1) ? substr(out, offset + RSTART - 1, 1) : ""
          if (prev !~ /[])A-Za-z0-9]/ && !is_tag(tok)) report(tok)
          offset += RSTART + RLENGTH - 1; rest = substr(rest, RSTART + RLENGTH)
        }
        rest = out; offset = 0
        while (!reported && match(rest, /\{[A-Z][A-Z0-9_-]*\}/)) {
          prev = (offset + RSTART > 1) ? substr(out, offset + RSTART - 1, 1) : ""
          next_c = substr(out, offset + RSTART + RLENGTH, 1)
          if (prev != "{" && prev != "$" && next_c != "}") report(substr(rest, RSTART, RLENGTH))
          offset += RSTART + RLENGTH - 1; rest = substr(rest, RSTART + RLENGTH)
        }
        if (!reported && match(out, /(^|[^A-Za-z])N{2,4}([^A-Za-z]|$)/)) report(substr(out, RSTART, RLENGTH))
      }' "$f")
  done
}

# Template files carry the output frontmatter: version 0.1.0 plus their own template_version.
check_template_frontmatter() {
  local file doc_type
  while IFS= read -r file; do
    doc_type="$(frontmatter_value "$file" doc_type)"
    is_document_type "$doc_type" || continue
    [[ "$(frontmatter_value "$file" version)" == "0.1.0" ]] ||
      err "$file" "template frontmatter must keep 'version: 0.1.0' (its own version goes in template_version)"
    [[ -n "$(frontmatter_value "$file" template_version)" ]] || err "$file" "template frontmatter has no template_version"
    if [[ "$file" == starters/* ]]; then
      frontmatter_has_items "$file" assembled_from || err "$file" "starter frontmatter must list assembled_from sources"
    fi
  done < <(markdown_files "${KIT_DIRS[@]}")
}

# A '|' inside an HTML comment in a table row splits the cell when rendered; it must be written '\|'.
check_table_comment_pipes() {
  local f lineno text rest inner
  while IFS= read -r f; do
    while IFS=$'\t' read -r lineno text; do
      [[ "${text#"${text%%[![:space:]]*}"}" == '|'* ]] || continue
      rest="${text//\\|/}"
      while [[ "$rest" == *'<!--'*'-->'* ]]; do
        inner="${rest#*<!--}"
        inner="${inner%%-->*}"
        if [[ "$inner" == *'|'* ]]; then
          err "$f:$lineno" "unescaped '|' inside a comment in a table row; write '\\|'"
          break
        fi
        rest="${rest#*-->}"
      done
    done < <(unfenced "$f")
  done < <(markdown_files "${KIT_DIRS[@]}"; existing "${TOP_DOCS[@]}")
}

check_starters() {
  local file
  while IFS= read -r file; do
    forbid_marker "$file" '^<!-- (SLOT|slot-hint|/?SLOT-CONTENT|/?PROFILE-CONTENT)' "starter still contains an unassembled core or overlay marker"
  done < <(markdown_files starters)
}

check_layout_blocks_in_templates() {
  local file
  [[ -f core/06_Agent_Context_Template.md ]] && check_layout_block core/06_Agent_Context_Template.md current-only
  for file in starters/*/CLAUDE.md.template; do
    [[ -f "$file" ]] && check_layout_block "$file" current-only
  done
}

run_templates() {
  # A project reads the installed kit version from PLAYBOOK.md, so it equals the release at the top of CHANGELOG.md.
  local pb_version cl_version
  pb_version="$(frontmatter_value PLAYBOOK.md version)"
  cl_version="$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tr -d '#[] ')"
  [[ "$pb_version" == "$cl_version" ]] || err PLAYBOOK.md "version '$pb_version' differs from the latest release '$cl_version' in CHANGELOG.md; the PLAYBOOK version is the kit version (README Versioning)"
  local kit_files link_files copied_files f doc_type
  check_structure
  check_legacy_patterns
  check_stack_neutral_core
  mapfile -t kit_files < <(markdown_files "${KIT_DIRS[@]}")
  ((${#kit_files[@]})) && check_frontmatter "${kit_files[@]}"
  check_frontmatter $(existing PLAYBOOK.md PROMPTS.md COMPATIBILITY.md CONVENTIONS.md)
  check_template_frontmatter
  ((${#kit_files[@]})) && check_required_sections "${kit_files[@]}"
  check_placeholders
  check_numbered_headings
  check_status_values $(markdown_files "${KIT_DIRS[@]}") $(existing "${TOP_DOCS[@]}")
  [[ -d core/05_Implementation_Plan_Template ]] && check_plan_format core/05_Implementation_Plan_Template
  check_gate_0r_rows
  check_slots
  check_table_comment_pipes
  check_starters
  check_starter_assembly
  check_layout_blocks_in_templates
  check_wireframe_templates_ux
  [[ -f core/07_Wireframe_Template/Design_Tokens_Template.json ]] &&
    TOKEN_HELPER_OPTS=--template run_token_helper core/07_Wireframe_Template/Design_Tokens_Template.json core/07_Wireframe_Template/Design_Tokens_Template.json
  mapfile -t copied_files < <(
    while IFS= read -r f; do
      doc_type="$(frontmatter_value "$f" doc_type)"
      { is_document_type "$doc_type" || [[ "$doc_type" == spec-addendum ]]; } && printf '%s\n' "$f"
    done \
      < <(markdown_files core brownfield starters; find overlays -path '*/agent-rules/*' -name '*.md' 2>/dev/null | sort)
  )
  ((${#copied_files[@]})) && check_pattern_notation "${copied_files[@]}"
  mapfile -t copied_files < <(markdown_files overlays | grep -v '/agent-rules/')
  ((${#copied_files[@]})) && check_pattern_notation --blocks "${copied_files[@]}"
  mapfile -t link_files < <(markdown_files "${KIT_DIRS[@]}"; existing "${TOP_DOCS[@]}")
  ((${#link_files[@]})) && check_links strict "${link_files[@]}"
}

# ---------------------------------------------------------------------------
# Example checks
# ---------------------------------------------------------------------------

# section_rows <file> <heading-regex>: body of the section whose heading matches, up to the next heading.
section_rows() {
  awk -v re="$2" '$0 ~ re { on = 1; next } on && /^#/ { exit } on' "$1"
}

# first_cell_codes: backticked UPPER_SNAKE first table cells, read from stdin.
first_cell_codes() {
  grep -oE '^\| `[A-Z][A-Z0-9_]+` \|' | grep -oE '[A-Z][A-Z0-9_]+'
}

# companion_files <dir>: the companion files under a folder (CONVENTIONS §7): every file that is not markdown and not hidden.
companion_files() {
  [[ -d "$1" ]] && find "$1" -type f ! -name '.*' ! -iname '*.md' | sort
}

# schema_enums <architecture-file>: "<EnumName>\t<sorted,comma,separated,values>" per enum of the schema.
# Only bare UPPER_SNAKE lines count as values; attributes (@@map) and comments are ignored.
schema_enums() {
  awk '
    /^enum [A-Za-z0-9_]+ \{/ { name = $2; vals = ""; on = 1; next }
    on && /^\}/ { print name "\t" vals; on = 0; next }
    on { line = $0; sub(/\/\/.*/, "", line); gsub(/[ \t]/, "", line); if (line ~ /^[A-Z][A-Z0-9_]*$/) vals = vals (vals == "" ? "" : ",") line }
  ' "$1" | while IFS=$'\t' read -r name vals; do
    printf '%s\t%s\n' "$name" "$(tr ',' '\n' <<< "$vals" | sort | paste -sd, -)"
  done
}

# example_scope <example-dir>: the example itself plus every other example it references by path
# (a frontend example builds on its backend example's registry, enums and names).
example_scope() {
  local dir="$1" other
  printf '%s\n' "$dir"
  [[ -n "$PROJECT" ]] && return 0  # a project builds on no worked example
  for other in examples/*/*/; do
    other="${other%/}"
    [[ "$other" == "$dir" ]] && continue
    grep -rqF -e "$other" -e "../../${other#examples/}" "$dir" 2>/dev/null && printf '%s\n' "$other"
  done
}

# example_registry <scope-file>: Error Code Registry codes (ARCHITECTURE §7.1) of every example in scope.
example_registry() {
  local member
  while IFS= read -r member; do
    [[ -f "$member/docs/ARCHITECTURE.md" ]] && section_rows "$member/docs/ARCHITECTURE.md" '^### 7\.1\.' | first_cell_codes
  done < "$1"
  true
}

# example_enums <scope-file>: "<EnumName>\t<values>" for every schema enum of the examples in scope.
example_enums() {
  local member schema
  while IFS= read -r member; do
    [[ -f "$member/docs/ARCHITECTURE.md" ]] && schema_enums "$member/docs/ARCHITECTURE.md"
    # A schema moved to a companion file of the architecture document (CONVENTIONS §7).
    # Source files are left out: "enum X {" in TypeScript is not a schema enum.
    while IFS= read -r schema; do schema_enums "$schema"; done < <(companion_files "$member/docs/architecture" | grep -vE '\.(ts|tsx|js|jsx|mjs|py|go|java|kt|swift)$')
  done < "$1"
  true
}

# example_known_names <scope-file>: UPPER_SNAKE names that are not error codes, across the scope: actor
# IDs, schema enum values, values allowed by SQL CHECK (... IN (...)) constraints, state names of state diagrams,
# ERD and data dictionary entity names (SRS §4.2), environment variables (ARCHITECTURE §6.4). A known name is
# only exempt as a bare backticked token; written after an HTTP status it still counts as an error code.
example_known_names() {
  local member file
  {
    example_enums "$1" | cut -f2 | tr ',' '\n'
    while IFS= read -r member; do
      [[ -f "$member/docs/ARCHITECTURE.md" ]] && section_rows "$member/docs/ARCHITECTURE.md" '^### 6\.4\.' | first_cell_codes
      # CHECK lists in any spelling: "CHECK(" or "CHECK (", upper or lower case, values across lines.
      # The schema may sit in a companion file of the architecture document (CONVENTIONS §7).
      [[ -f "$member/docs/ARCHITECTURE.md" ]] && { cat "$member/docs/ARCHITECTURE.md"; companion_files "$member/docs/architecture" | while IFS= read -r file; do cat "$file"; done; } | tr '\n' ' ' |
        grep -oiE "check *\( *[a-z_]+ +in *\([^)]*\)" | grep -oE "'[A-Z][A-Z0-9_]*'" | tr -d "'"
      for file in "$member"/docs/srs/*.md "$member"/docs/specs/*.md; do
        [[ -f "$file" ]] || continue
        section_rows "$file" '^### 4\.2\.' | first_cell_codes
        grep -oE '`ACT_[A-Z0-9_]+`' "$file" | tr -d '`'
        awk '/^```mermaid/ { m = 1; next } m && /^```/ { m = 0; er = 0; sd = 0; next }
          m && /erDiagram/ { er = 1; next } m && /stateDiagram/ { sd = 1; next }
          m && er && /^[ \t]*[A-Z][A-Z0-9_]*[ \t]*\{/ { gsub(/[ \t{]/, ""); print }
          m && sd && /-->/ { line = $0; sub(/ :.*/, "", line); n = split(line, parts, "-->"); for (i = 1; i <= n; i++) { t = parts[i]; gsub(/[ \t]/, "", t); if (t != "[*]") print t } }' "$file"
      done
    done < "$1"
  } | grep -E '^[A-Z][A-Z0-9_]*$' | sort -u
}

# used_error_codes <file> <known-names-file> [stated]: "<file>\t<code>" for every error code a SRS or SPEC uses:
# the code after an HTTP status when the pair is written as code ("`409 INSUFFICIENT_STOCK`", "409 `CODE`",
# a table cell) or the code contains "_"; first cells of SRS §6.3; JSON "code" values; backticked
# UPPER_SNAKE tokens that are not known non-code names (left out with "stated"). RFC 2119 keywords never count as codes.
used_error_codes() {
  local file="$1" known="$2"
  {
    grep -oE '`?\b[1-5][0-9]{2}`? (\| )?`?[A-Z][A-Z0-9_]{3,}\b`?' "$file" |
      awk '{ code = $0; gsub(/[^A-Z0-9_ ]/, "", code); n = split(code, w, " "); code = w[n]
        if (index($0, "`") || index($0, "|") || index(code, "_")) print code }'
    section_rows "$file" '^### 6\.3\.' | first_cell_codes
    grep -oE '"code": *"[A-Z][A-Z0-9_]+"' "$file" | grep -oE '[A-Z][A-Z0-9_]+'
    [[ "${3:-}" == stated ]] || grep -oE '`[A-Z][A-Z0-9]*(_[A-Z0-9]+)+`' "$file" | tr -d '`' | grep -vxF -f "$known"
  } | grep -vxE 'MUST|SHOULD|SHALL|REQUIRED|RECOMMENDED|OPTIONAL|MAY|NOT' | sort -u | sed "s|^|$file\t|"
}

# route_handlers <architecture-file>: "/api/..." paths of route handlers in the directory trees (`text` blocks) of a
# layout, rebuilt from the tree structure: a `route.ts` file under an `api/` directory.
route_handlers() {
  awk '
    /^[ \t]*```text[ \t]*$/ { tree = 1; delete stack; next }
    tree && /^[ \t]*```/ { tree = 0; next }
    !tree { next }
    {
      line = $0; sub(/[ \t]+#.*$/, "", line)
      if (!match(line, /[A-Za-z0-9_.{}()-]/)) next
      depth = RSTART; name = substr(line, depth); sub(/[ \t].*$/, "", name)
      for (d in stack) if (d + 0 >= depth) delete stack[d]
      stack[depth] = name
      if (name !~ /(^|\/)route\.ts$/) next
      path = ""; n = 0
      for (d in stack) keys[++n] = d + 0
      for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++) if (keys[j] < keys[i]) { t = keys[i]; keys[i] = keys[j]; keys[j] = t }
      for (i = 1; i <= n; i++) path = path stack[keys[i]]
      delete keys
      if (match(path, /(^|\/)api\//)) { path = substr(path, RSTART + RLENGTH - 4); sub(/\/route\.ts$/, "", path); print "/" path }
    }' "$1"
}

# jsonl_invalid_lines <file>: numbers of the non-empty lines that are not a JSON object. Returns 2 when no JSON
# parser (python3, node or jq) is available.
jsonl_invalid_lines() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json, sys
def no_constant(name):
    raise ValueError(name)
for n, raw in enumerate(open(sys.argv[1], "rb"), 1):
    try:
        line = raw.decode("utf-8")
        if not line.strip():
            continue
        ok = isinstance(json.loads(line, parse_constant=no_constant), dict)
    except (ValueError, RecursionError):
        ok = False
    if not ok:
        print(n)' "$1"
  elif command -v node >/dev/null 2>&1; then
    node -e 'require("fs").readFileSync(process.argv[1], "utf8").split("\n").forEach((line, i) => {
      if (!line.trim()) return;
      let ok = false;
      try { const v = JSON.parse(line); ok = v !== null && typeof v === "object" && !Array.isArray(v); } catch (e) { ok = false; }
      if (!ok) console.log(i + 1);
    });' "$1"
  elif command -v jq >/dev/null 2>&1; then
    local n=0 line
    while IFS= read -r line || [[ -n "$line" ]]; do
      n=$((n + 1))
      [[ -z "${line//[[:space:]]/}" ]] && continue
      jq -e 'type == "object"' <<< "$line" >/dev/null 2>&1 || echo "$n"
    done < "$1"
  else
    return 2
  fi
}

# check_example_consistency <example-dir>: cross-document rules for one worked example.
check_example_consistency() {
  local dir="$1" arch="$1/docs/ARCHITECTURE.md" file code name states enums tc inv plan_dir found member owner path
  local spec_id has_plan
  example_scope "$dir" > "$TMP/scope"
  printf '%s\n' "$dir" > "$TMP/self"
  example_registry "$TMP/self" | sort -u > "$TMP/registry"
  example_known_names "$TMP/scope" > "$TMP/known-names"
  [[ -s "$TMP/known-names" ]] || echo '-' > "$TMP/known-names"

  # 1. Every error code a SRS, SPEC or Prompt Spec uses is in the example's own Error Code Registry (CONVENTIONS §4), so each
  #    code the example handles has its own mapping row; referenced examples only vouch for API-owned rows (rule 6).
  #    In a project, a code that only looks like one (an UPPER_SNAKE name in backticks, which may as well be an entity or
  #    an event) is a warning; a code stated beside an HTTP status, in SRS §6.3 or in a "code" field stays an error.
  for file in "$dir"/docs/srs/*.md "$dir"/docs/specs/* "$dir"/docs/prompts/*.md; do
    [[ -f "$file" ]] && used_error_codes "$file" "$TMP/known-names" stated
  done | cut -f2 | sort -u > "$TMP/stated-codes"
  while IFS=$'\t' read -r file code; do
    grep -qxF -- "$code" "$TMP/registry" && continue
    if [[ -n "$PROJECT" ]] && ! grep -qxF -- "$code" "$TMP/stated-codes"; then
      warn "$file" "$code looks like an error code and is not in the example's Error Code Registry (ARCHITECTURE §7.1)"
    else
      err "$file" "error code $code is not in the example's Error Code Registry (ARCHITECTURE §7.1)"
    fi
  done < <(for file in "$dir"/docs/srs/*.md "$dir"/docs/specs/* "$dir"/docs/prompts/*.md; do [[ -f "$file" ]] && used_error_codes "$file" "$TMP/known-names"; done)

  # 2. A state machine announced as "(`EnumName`):" on the line before its diagram ("Đơn hàng (`OrderStatus`):")
  #    uses exactly the values of that enum in an ARCHITECTURE schema of the example's scope.
  #    Diagrams announced any other way (UI or process states) are not checked.
  enums="$(example_enums "$TMP/scope")"
  for file in "$dir"/docs/srs/*.md; do
    [[ -f "$file" ]] || continue
    while IFS=$'\t' read -r name states; do
      [[ -z "$name" ]] && continue
      code="$(awk -F'\t' -v n="$name" '$1 == n { print $2 }' <<< "$enums")"
      if [[ -z "$code" ]]; then
        err "$file" "state machine names enum $name, which no ARCHITECTURE schema in the example's scope defines"
      elif [[ "$code" != "$states" ]]; then
        err "$file" "state machine $name {$states} differs from enum $name {$code} in the ARCHITECTURE schema"
      fi
    done < <(awk '
      /^```mermaid/ { inm = 1; sd = 0; delete seen; name = ""; if (match(prev, /\(`[A-Z][a-z][A-Za-z0-9]*`\):[ \t]*$/)) name = substr(prev, RSTART + 2, RLENGTH - 5); next }
      !inm && NF { prev = $0 }
      inm && /stateDiagram/ { sd = 1; next }
      inm && /^```/ { if (sd && name != "") { out = ""; for (k in seen) out = out k "\n"; printf "%s\t%s", name, out; print "\x1e" } inm = 0; next }
      inm && sd && /-->/ {
        line = $0; sub(/ :.*/, "", line); n = split(line, parts, "-->")
        for (i = 1; i <= n; i++) { t = parts[i]; gsub(/[ \t]/, "", t); if (t != "" && t != "[*]") seen[t] = 1 }
      }' "$file" | awk 'BEGIN { RS = "\x1e\n" } NF { split($0, h, "\t"); m = split(h[2], a, "\n"); cmd = "sort | paste -sd, -"; printf "%s\t", h[1]; fflush(); for (i = 1; i <= m; i++) if (a[i] != "") print a[i] | cmd; close(cmd) }')
  done

  for file in "$dir"/docs/specs/*.md; do
    [[ -f "$file" ]] || continue
    # 3. Every invariant (SPEC §1.2) is exercised by at least one CONC test in the SPEC test table.
    while IFS= read -r inv; do
      grep -E '^\| TC-[A-Z-]+-CONC-[0-9]{2} \| [^|]*\b'"$inv"'\b' "$file" >/dev/null ||
        err "$file" "$inv has no CONC test in the SPEC test table"
    done < <(section_rows "$file" '^### 1\.2\.' | grep -oE '^\| INV-[0-9]{2} \|' | grep -oE 'INV-[0-9]{2}')
    # 4. Every TC in a SPEC is scheduled in a phase of the example's Implementation Plan, once a plan already covers
    #    this SPEC (its spec_id is in a release plan's spec_ids, or is the spec_id of an older, single-SPEC plan). A
    #    SPEC not yet claimed by any plan is not held to this rule (PLAYBOOK §2.4: a plan comes after Gate 3).
    spec_id="$(frontmatter_value "$file" spec_id)"
    has_plan=0
    if [[ -n "$spec_id" ]]; then
      for plan_dir in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do
        [[ -f "${plan_dir}plan.md" ]] || continue
        if frontmatter_list "${plan_dir}plan.md" spec_ids | grep -qxF -- "$spec_id" ||
          [[ "$(frontmatter_value "${plan_dir}plan.md" spec_id)" == "$spec_id" ]]; then
          has_plan=1
          break
        fi
      done
    fi
    if ((has_plan)); then
      while IFS= read -r tc; do
        found=0
        for plan_dir in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do
          grep -qE -- "^\| $tc \|" "$plan_dir"phase-*.md 2>/dev/null && { found=1; break; }
        done
        ((found)) || err "$file" "$tc is not in the test table of any phase of the example's Implementation Plan"
      done < <(grep -oE 'TC-[A-Z]{2,6}(-[A-Z]{2,6})?-(UNIT|INT|E2E|CTR|CONC|LOAD|A11Y|VIS|EVAL|INJ|COST|SMOKE|REG)-[0-9]{2}' "$file" | sort -u)
    fi
  done

  # 5. Every TC a plan phase schedules is defined in a SPEC test table of the example.
  while IFS=: read -r file tc; do
    tc="${tc#| }"; tc="${tc%% *}"
    grep -qE -- "^\| $tc \|" "$dir"/docs/specs/*.md 2>/dev/null ||
      err "$file" "$tc is scheduled but no SPEC of the example defines it in its test table"
  done < <(for plan_dir in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do grep -oHE '^\| TC-[A-Z0-9-]+ \|' "$plan_dir"phase-*.md 2>/dev/null; done)

  # 6. An example that builds on other examples (a web client of an API example) redefines nothing they own. Across
  #    all of its docs:
  #    - every versioned API endpoint ("METHOD /api/vN/...", path parameters compared as {}) is defined in the
  #      "Method và path" row of a referenced example's SPEC; an unversioned "/api/..." endpoint is one of the
  #      example's own route handlers (an api/<path>/route file in its ARCHITECTURE layout);
  #    - every operationId it cites is an operationId of a referenced example's SPEC;
  #    - every FR or SPEC ID whose module code belongs to a referenced example (and not to the example itself) exists
  #      there (SRS §6.1, spec_id);
  #    - every code in its own registry whose owner cell starts with "API" is in a referenced example's registry.
  grep -vxF -- "$dir" "$TMP/scope" > "$TMP/referenced" || true
  if [[ -s "$TMP/referenced" ]]; then
    local endpoint_re='\b(GET|POST|PUT|PATCH|DELETE) `?/api/[A-Za-z0-9/{}_.-]*'
    normalize_endpoints() { tr -d '`' | sed -E 's/\{[^}]*\}/{}/g; s#/+$##' | sort -u; }
    module_codes() { section_rows "$1" '^### 1\.2\.' | grep -oE '^\| MOD-[0-9]{2} \| `[A-Z]{2,6}(-[A-Z]{2,6})?`' | grep -oE '`[A-Z-]+`' | tr -d '`'; }
    while IFS= read -r member; do
      grep -ohE '^\| Method và path \| (GET|POST|PUT|PATCH|DELETE) `?/api/[A-Za-z0-9/{}_.-]*' "$member"/docs/specs/*.md 2>/dev/null |
        sed -E 's/^\| Method và path \| //'
    done < "$TMP/referenced" | normalize_endpoints > "$TMP/referenced-endpoints"
    : > "$TMP/own-handlers"
    [[ -f "$arch" ]] && route_handlers "$arch" | sort -u > "$TMP/own-handlers"
    : > "$TMP/own-modules"
    for file in "$dir"/docs/srs/*.md; do [[ -f "$file" ]] && module_codes "$file"; done | sort -u > "$TMP/own-modules"
    while IFS= read -r member; do
      grep -ohE 'operationId: *[A-Za-z0-9_]+' "$member"/docs/specs/*.md "$member"/docs/specs/*.yaml "$member"/docs/specs/*.yml 2>/dev/null | sed -E 's/operationId: *//'
      grep -ohE '"operationId": *"[A-Za-z0-9_]+"' "$member"/docs/specs/*.json 2>/dev/null | sed -E 's/.*: *"//; s/"$//'
      for file in "$member"/docs/specs/*.md; do [[ -f "$file" ]] && frontmatter_value "$file" spec_id; done
      for file in "$member"/docs/srs/*.md; do
        [[ -f "$file" ]] || continue
        section_rows "$file" '^### 6\.1\.' | grep -oE '^\| FR-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{3} \|' | grep -oE 'FR-[A-Z0-9-]+'
        module_codes "$file" | sed 's/^/MODULE:/'
      done
    done < "$TMP/referenced" | sort -u > "$TMP/referenced-ids"
    example_registry "$TMP/referenced" | sort -u > "$TMP/referenced-registry"
    while IFS= read -r file; do
      while IFS= read -r code; do
        path="${code#* }"
        if [[ "$path" =~ ^/api/v[0-9]+/ ]]; then
          grep -qxF -- "$code" "$TMP/referenced-endpoints" ||
            err "$file" "mentions $code, which no SPEC of a referenced example defines"
        else
          grep -qxF -- "$path" "$TMP/own-handlers" ||
            err "$file" "mentions $code, which is neither a versioned API endpoint nor a route handler in the example's ARCHITECTURE layout"
        fi
      done < <(grep -ohE "$endpoint_re" "$file" | normalize_endpoints)
      while IFS= read -r code; do
        grep -qxF -- "$code" "$TMP/referenced-ids" ||
          err "$file" "cites operationId $code, which no SPEC of a referenced example defines"
      done < <(grep -ohE 'operationId `[A-Za-z0-9_]+`' "$file" | sed -E 's/operationId `([A-Za-z0-9_]+)`/\1/' | sort -u)
      while IFS= read -r code; do
        name="$(sed -E 's/^(FR|SPEC)-(.*)-[0-9]{3}$/\2/' <<< "$code")"
        grep -qxF -- "$name" "$TMP/own-modules" && continue
        grep -qxF -- "MODULE:$name" "$TMP/referenced-ids" || continue
        grep -qxF -- "$code" "$TMP/referenced-ids" ||
          err "$file" "cites $code, which the referenced example that owns module $name does not define"
      done < <(grep -ohE '\b(FR|SPEC)-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{3}\b' "$file" | sort -u)
    done < <(find "$dir/docs" -name '*.md' -type f | sort)
    if [[ -f "$arch" ]]; then
      while IFS=$'\t' read -r code owner; do
        [[ "$owner" == API* ]] || continue
        grep -qxF -- "$code" "$TMP/referenced-registry" ||
          err "$arch" "registry row $code is owned by the API but is not in a referenced example's Error Code Registry"
      done < <(section_rows "$arch" '^### 7\.1\.' | awk -F'|' '/^\| `[A-Z][A-Z0-9_]+` \|/ { code = $2; owner = $4; gsub(/[ `]/, "", code); sub(/^ +/, "", owner); sub(/ +$/, "", owner); print code "\t" owner }')
    fi
  fi

  # 7. Eval datasets. Every line of evals/*.jsonl is a JSON object. Every dataset that a row of a Prompt Spec §9
  #    table names exists, its sample count cell equals its number of non-empty lines, and a dataset of an EVAL
  #    row holds at least 20 samples.
  local bad status count samples
  while IFS= read -r file; do
    bad="$(jsonl_invalid_lines "$file")"
    status=$?
    if ((status == 2)); then
      warn "$file" "no JSON parser (python3, node or jq) found; dataset lines not validated"
    elif ((status != 0)); then
      err "$file" "the JSON parser failed (exit status $status); dataset lines not validated"
    elif [[ -n "$bad" ]]; then
      err "$file" "line(s) $(paste -sd, - <<< "$bad") are not JSON objects"
    fi
  done < <(find "$dir" -path "$dir/evals/*" -name '*.jsonl' -type f 2>/dev/null | sort)
  for file in "$dir"/docs/prompts/*.md; do
    [[ -f "$file" ]] || continue
    # The prompt ID in the frontmatter has the CONVENTIONS §4 format and is the one the document names in §1.
    code="$(frontmatter_value "$file" prompt_id)"
    if [[ ! "$code" =~ ^PROMPT-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{3}$ ]]; then
      err "$file" "prompt_id '$code' does not have the PROMPT-{MOD}-NNN format"
    elif ! section_rows "$file" '^## 1\.' | grep -qF -- "\`$code\`"; then
      err "$file" "prompt_id $code is not the Prompt ID of §1"
    fi
    # Every TC the Prompt Spec names (eval table, failure modes, anywhere) is a test of a SPEC of the example.
    while IFS= read -r tc; do
      grep -qE -- "^\| $tc \|" "$dir"/docs/specs/*.md 2>/dev/null || err "$file" "$tc is not defined in the test table of any SPEC of the example"
    done < <(grep -oE 'TC-[A-Z]{2,6}(-[A-Z]{2,6})?-(UNIT|INT|E2E|CTR|CONC|LOAD|A11Y|VIS|EVAL|INJ|COST|SMOKE|REG)-[0-9]{2}' "$file" | sort -u)
    while IFS=$'\t' read -r tc path samples; do
      if [[ ! -f "$dir/$path" ]]; then
        err "$file" "$tc names dataset $path, which does not exist in the example"
        continue
      fi
      count="$(grep -c '[^[:space:]]' "$dir/$path")"
      if [[ ! "$samples" =~ ^[0-9]+$ ]]; then
        [[ "$samples" == Như* ]] || err "$file" "$tc gives '$samples' as the sample count of $path; write the number"
      elif ((samples != count)); then
        err "$file" "$tc gives $samples samples for $path, which has $count"
      fi
      [[ "$tc" == *-EVAL-* ]] && ((count < 20)) &&
        err "$file" "$tc uses $path with $count samples; an EVAL dataset needs at least 20"
    done < <(section_rows "$file" '^## 9\.' | awk -F'|' '$2 ~ /^ *TC-[A-Z-]+-[0-9]+ *$/ && $3 ~ /`[^`]+\.jsonl`/ {
      tc = $2; gsub(/ /, "", tc); path = $3; sub(/^[^`]*`/, "", path); sub(/`.*/, "", path); n = $4; gsub(/ /, "", n); print tc "\t" path "\t" n }')
  done

  #    A prompt ID cited anywhere in the example is the prompt_id of one of its Prompt Specs.
  if compgen -G "$dir/docs/prompts/*.md" >/dev/null; then
    for file in "$dir"/docs/prompts/*.md; do frontmatter_value "$file" prompt_id; done | sort -u > "$TMP/prompt-ids"
    while IFS=: read -r file code; do
      grep -qxF -- "$code" "$TMP/prompt-ids" || err "$file" "cites $code, which is the prompt_id of no Prompt Spec in the example"
    done < <(grep -roHE 'PROMPT-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{3}' "$dir"/docs "$dir"/CLAUDE.md "$dir"/README.md 2>/dev/null | sort -u)
  fi
  #    A Prompt Spec that a SPEC cites exists in the example.
  while IFS=: read -r file path; do
    [[ -f "$dir/$path" ]] || err "$file" "cites $path, which does not exist in the example"
  done < <(grep -oHE '`docs/prompts/[A-Za-z0-9_.-]+\.md`' "$dir"/docs/specs/*.md 2>/dev/null | tr -d '`')

  # 8. Implementation Plans follow the plan format of CONVENTIONS §9 (no external tool needed).
  for plan_dir in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do
    [[ -f "$plan_dir/plan.md" ]] && check_plan_format "${plan_dir%/}"
  done
}

# plan_status_word <text>: the phase status a Phases-table Status cell stands for (CONVENTIONS §9), lowercase.
plan_status_word() {
  local v="${1,,}"
  case "$v" in
    pending | todo) echo todo ;;
    "in progress" | in-progress) echo in-progress ;;
    completed | done) echo done ;;
    *) echo "$v" ;;
  esac
}

# check_plan_format <plan-dir>: the Implementation Plan format of CONVENTIONS §9. Checks the plan and phase frontmatter,
# phase file names and numbering, and that the Phases table lists every phase file once with a matching status.
check_plan_format() {
  local dir="$1" plan="$1/plan.md" f name key num status want expected=1 link cell
  local -A listed=()
  if ! head -n 1 "$plan" | grep -qx -- '---'; then
    err "$plan" "plan has no frontmatter (CONVENTIONS §9)"
    return
  fi
  for f in title description priority effort created; do
    [[ -n "$(frontmatter_value "$plan" "$f")" ]] || err "$plan" "plan frontmatter has no $f (CONVENTIONS §9)"
  done
  status="$(frontmatter_value "$plan" status)"
  [[ "$status" =~ ^(pending|in-progress|completed)$ ]] || err "$plan" "plan status '$status' is not pending, in-progress or completed (CONVENTIONS §9)"
  while IFS=$'\t' read -r link cell; do
    [[ -n "$link" ]] || continue
    link="${link#./}"
    if [[ ! -f "$dir/$link" ]]; then
      err "$plan" "Phases table links $link, which does not exist (CONVENTIONS §9)"
      continue
    fi
    [[ -n "${listed[$link]:-}" ]] && err "$plan" "Phases table lists $link more than once (CONVENTIONS §9)"
    listed[$link]="$(plan_status_word "$cell")"
  done < <(awk -F'|' '/^\|/ && match($0, /\]\(\.?\/?phase-[^)]*\.md\)/) {
      link = substr($0, RSTART + 2, RLENGTH - 3); cell = $(NF - 1); gsub(/^ +| +$/, "", cell); print link "\t" cell }' "$plan")
  for f in "$dir"/phase-*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    if [[ ! "$name" =~ ^phase-([0-9]{2})-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
      err "$f" "phase file name is not phase-NN-<kebab-slug>.md (CONVENTIONS §9)"
      continue
    fi
    num="${BASH_REMATCH[1]}"
    ((10#$num == expected)) || err "$f" "phase number $num breaks the sequence; expected $(printf '%02d' "$expected") (CONVENTIONS §9)"
    expected=$((10#$num + 1))
    [[ "$(frontmatter_value "$f" phase)" == "$((10#$num))" ]] || err "$f" "frontmatter phase '$(frontmatter_value "$f" phase)' differs from the number in the file name (CONVENTIONS §9)"
    for key in title priority effort; do
      [[ -n "$(frontmatter_value "$f" "$key")" ]] || err "$f" "phase frontmatter has no $key (CONVENTIONS §9)"
    done
    status="$(frontmatter_value "$f" status)"
    [[ "$status" =~ ^(todo|in-progress|done)$ ]] || err "$f" "phase status '$status' is not todo, in-progress or done (CONVENTIONS §9)"
    want="${listed[$name]:-}"
    if [[ -z "$want" ]]; then
      err "$plan" "Phases table has no row for $name (CONVENTIONS §9)"
    elif [[ "$want" != "$status" ]]; then
      err "$plan" "Phases table status of $name means '$want' but the phase status is '$status' (CONVENTIONS §9)"
    fi
  done
  ((expected > 1)) || err "$dir" "plan has no phase-NN-<slug>.md file (CONVENTIONS §9)"
}

# lower_text: stdin lowercased, Vietnamese letters included (grep -i does not fold them in every build).
lower_text() {
  local LC_ALL=C.UTF-8 line
  while IFS= read -r line; do printf '%s\n' "${line,,}"; done
}

# table_column <file> <section-heading-regex> <header-prefix> [<stop-regex>]: for the first table in the section with a
# header cell starting with <header-prefix>, print "#HEADER" and then "<first-cell>\t<cell>" per data row. The section
# ends at the next heading, or at the next line matching <stop-regex> when given. Escaped pipes (\|) stay in their cell.
table_column() {
  awk -v re="$2" -v col="$3" -v stop="${4:-^#}" '
    $0 ~ re { on = 1; next }
    on && $0 ~ stop { exit }
    !on { next }
    !/^\|/ { intable = 0; next }
    {
      line = $0; gsub(/\\\|/, "\001", line); n = split(line, c, "|")
      for (i = 2; i < n; i++) { gsub(/^ +| +$/, "", c[i]); gsub(/\001/, "\\|", c[i]) }
      if (!intable) {
        intable = 1; header = 1; idx = 0
        if (!found) for (i = 2; i < n; i++) if (!idx && index(c[i], col) == 1) idx = i
        if (idx) { found = 1; print "#HEADER"; want = 1 } else want = 0
        next
      }
      if (header) { header = 0; next }
      if (want) print c[2] "\t" c[idx]
    }' "$1"
}

# NFR_RE: an NFR ID per CONVENTIONS §3 (NFR-{CAT}-NN); CAT may itself contain digits (e.g. I18N), so the category
# class must be [A-Z0-9], not [A-Z]. Every rule below that collects or matches an NFR ID uses this one pattern.
NFR_RE='NFR-[A-Z0-9]+-[0-9]{2}'

# check_srs_requirements <example-dir>: requirement-quality rules of CONVENTIONS §8 for SRS files built from template
# 1.1.0 or later. 1. The §6.1 catalog has a "Phát biểu yêu cầu" column; every row states one MUST or MUST NOT.
# 2. FR statements and the NFR "Yêu cầu" and "Ngưỡng" cells use no vague term. 3. Every applicable NFR of §7 has a
# row in §8; in modular mode the NFR set of the master and the §8 rows of every module are pooled.
check_srs_requirements() {
  local dir="$1" file ver id cell count term rows applies=0
  : > "$TMP/nfr-ids"; : > "$TMP/nfr-traced"
  for file in "$dir"/docs/srs/*.md; do
    [[ -f "$file" ]] || continue
    # Every SRS file feeds the §8 trace set, so a module still on an older template does not cause false errors.
    awk '/^## 8\./ { on = 1; next } on && /^##? / { exit } on' "$file" | grep -oE "\\b$NFR_RE\\b" >> "$TMP/nfr-traced"
    ver="$(gate_version "$file" core/01_SRS_Template.md)"
    [[ -n "$ver" && "$(printf '%s\n%s\n' "$ver" 1.1.0 | sort -V | head -n 1)" == 1.1.0 ]] || continue
    applies=1
    if grep -qE '^### 6\.1\.' "$file" || [[ "$(frontmatter_value "$file" doc_type)" == srs-module || "$file" != */00_SRS_MASTER.md ]]; then
      rows="$(table_column "$file" '^### 6\.1\.' 'Phát biểu yêu cầu')"
      if ! grep -qx '#HEADER' <<< "$rows"; then
        err "$file" "SRS §6.1 has no catalog table with a 'Phát biểu yêu cầu' column (CONVENTIONS §8)"
      fi
      while IFS=$'\t' read -r id cell; do
        [[ "$id" == '#HEADER' || -z "$id" ]] && continue
        count="$(grep -oE '\bMUST\b' <<< "$cell" | wc -l)"
        if [[ -z "$cell" ]]; then
          err "$file" "$id has an empty requirement statement (CONVENTIONS §8)"
        elif ((count != 1)); then
          err "$file" "$id requirement statement has $count MUST keywords; state one behaviour with exactly one MUST or MUST NOT (CONVENTIONS §8)"
        fi
        printf '%s\t%s\t%s\n' "$file" "$id" "$cell" >> "$TMP/vague-cells"
      done <<< "$rows"
    fi
    # §7 and §8 may carry ### subsections; they end only at the next # or ## heading.
    rows="$(table_column "$file" '^## 7\.' 'Yêu cầu' '^##? ')"
    if [[ "$(frontmatter_value "$file" doc_type)" == srs ]] && grep -qE '^## 7\.' "$file" && ! grep -qE "^${NFR_RE}"$'\t' <<< "$rows"; then
      err "$file" "SRS §7 has no NFR table with a 'Yêu cầu' column (CONVENTIONS §8)"
    fi
    while IFS=$'\t' read -r id cell; do
      [[ "$id" =~ ^NFR- ]] || continue
      printf '%s\t%s\t%s\n' "$file" "$id" "$cell" >> "$TMP/vague-cells"
      [[ "$cell" == N/A* ]] || printf '%s\t%s\n' "$file" "$id" >> "$TMP/nfr-ids"
    done <<< "$rows"
    while IFS=$'\t' read -r id cell; do
      [[ "$id" =~ ^NFR- ]] && printf '%s\t%s\t%s\n' "$file" "$id" "$cell" >> "$TMP/vague-cells"
    done < <(table_column "$file" '^## 7\.' 'Ngưỡng' '^##? ')
  done
  ((applies)) || return 0
  if [[ -s "$TMP/vague-cells" ]]; then
    lower_text < "$TMP/vague-terms" > "$TMP/vague-lower"
    while IFS=$'\t' read -r file id cell; do
      while IFS= read -r term; do
        [[ -n "$term" ]] || continue
        grep -qF -- "$term" <<< "$(lower_text <<< "$cell")" && err "$file" "$id uses the vague term '$term' (CONVENTIONS §8)"
      done < "$TMP/vague-lower"
    done < "$TMP/vague-cells"
  fi
  while IFS=$'\t' read -r file id; do
    grep -qxF -- "$id" "$TMP/nfr-traced" || err "$file" "$id has no row in the SRS §8 matrix (CONVENTIONS §8)"
  done < "$TMP/nfr-ids"
  if ! LC_ALL=C.UTF-8 grep -qP '[\x{0300}]' <<< $'\xcc\x80' 2>/dev/null; then
    warn "$dir" "grep -P with the C.UTF-8 locale is unavailable; the Unicode NFC check was skipped"
  else while IFS= read -r file; do
    LC_ALL=C.UTF-8 grep -nP '[\x{0300}-\x{036F}]' "$file" >/dev/null 2>&1 && err "$file" "text is not Unicode NFC (combining marks found); vague-term matching needs NFC (CONVENTIONS §8)"
  done < <(printf '%s\n' "$dir"/docs/srs/*.md); fi
  rm -f "$TMP/vague-cells"
}

# table_pair <file> <section-heading-regex> <header-a> <header-b> [<stop-regex>]: for the first table in the section
# with header cells starting with <header-a> and <header-b>, print "<cell-a>\t<cell-b>" per data row.
table_pair() {
  awk -v re="$2" -v ca="$3" -v cb="$4" -v stop="${5:-^#}" '
    $0 ~ re { on = 1; next }
    on && $0 ~ stop { exit }
    !on { next }
    !/^\|/ { intable = 0; next }
    {
      line = $0; gsub(/\\\|/, "\001", line); n = split(line, c, "|")
      for (i = 2; i < n; i++) { gsub(/^ +| +$/, "", c[i]); gsub(/\001/, "\\|", c[i]) }
      if (!intable) {
        intable = 1; header = 1; ia = ib = 0
        if (!found) for (i = 2; i < n; i++) { if (!ia && index(c[i], ca) == 1) ia = i; if (!ib && index(c[i], cb) == 1) ib = i }
        want = (ia && ib); if (want) found = 1
        next
      }
      if (header) { header = 0; next }
      if (want) print c[ia] "\t" c[ib]
    }' "$1"
}

# version_at_least <version> <minimum>: true when <version> is set and not older than <minimum>.
version_at_least() { [[ -n "$1" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n 1)" == "$2" ]]; }

# check_status_values <file...> (rule 7 of the cross-document rules, run for every file): status belongs to the CONVENTIONS §3 table for the file's doc_type; an approved
# document has version 1.0.0 or later.
check_status_values() {
  local f doc_type status version
  for f in "$@"; do
    doc_type="$(frontmatter_value "$f" doc_type)"
    [[ -n "$doc_type" ]] || continue
    status="$(frontmatter_value "$f" status)"
    grep -qxF -- "$doc_type"$'\t'"$status" "$TMP/status-map" ||
      err "$f" "status '$status' is not valid for doc_type $doc_type (CONVENTIONS §3)"
    version="$(frontmatter_value "$f" version)"
    if [[ "$status" == approved ]] && ! version_at_least "$version" 1.0.0; then
      err "$f" "approved document has version '$version'; the first approved version is 1.0.0 (CONVENTIONS §3)"
    fi
  done
}

# check_crossdoc <example-dir>: cross-document traceability rules (CONVENTIONS §4). Rules marked "gated" apply only to
# documents built from the template version named in the rule.
check_crossdoc() {
  local dir="$1" member spec srs file id ids cell tc ac nfr method goal ver intake adr spec_new srs_new
  example_scope "$dir" > "$TMP/cd-scope"
  : > "$TMP/cd-fr"; : > "$TMP/cd-ac"; : > "$TMP/cd-own-br"; : > "$TMP/cd-own-nfr"
  while IFS= read -r member; do
    for srs in "$member"/docs/srs/*.md; do
      [[ -f "$srs" ]] || continue
      grep -oE '^\| FR-[A-Z]+(-[A-Z]+)?-[0-9]{3} \|' "$srs" | grep -oE 'FR-[A-Z0-9-]+[0-9]' >> "$TMP/cd-fr"
      awk '/^## 8\./ { on = 1; next } on && /^##? / { exit } on' "$srs" | grep -oE '\bAC-[A-Z]+(-[A-Z]+)?-[0-9]{2}\b' >> "$TMP/cd-ac"
      if [[ "$member" == "$dir" ]]; then
        awk '/^## 5\./ { on = 1; next } on && /^##? / { exit } on' "$srs" | grep -oE '^\| BR-[0-9]{3} \|' | grep -oE 'BR-[0-9]+' >> "$TMP/cd-own-br"
        awk '/^## 7\./ { on = 1; next } on && /^##? / { exit } on' "$srs" | grep -oE "^\\| $NFR_RE \\|" | grep -oE "$NFR_RE" >> "$TMP/cd-own-nfr"
      fi
    done
  done < "$TMP/cd-scope"
  : > "$TMP/cd-spec-tc"; : > "$TMP/cd-spec-tc-new"; : > "$TMP/cd-spec-nfr"; : > "$TMP/cd-tested-nfr"
  for spec in "$dir"/docs/specs/*.md; do
    [[ -f "$spec" ]] || continue
    spec_new=0
    version_at_least "$(gate_version "$spec" core/04_Spec_Core_Template.md)" 1.1.0 && spec_new=1
    # A SPEC from template 1.1.0 keeps the tables these rules read; a renamed header must not switch the rules off.
    if ((spec_new)); then
      table_pair "$spec" '^### 1\.5\.' 'FR ID' 'AC ID' | grep -q . || err "$spec" "SPEC §1.5 has no table with 'FR ID' and 'AC ID' columns (CONVENTIONS §4)"
      table_pair "$spec" '^### 9\.1\.' 'TC ID' 'AC hoặc INV' | grep -q . || err "$spec" "SPEC §9.1 has no table with 'TC ID' and 'AC hoặc INV' columns (CONVENTIONS §4)"
    fi
    # 1. Every FR, AC, BR and NFR that SPEC §1.5 names exists in a SRS (FR and AC also in referenced examples).
    for ids in "FR ID:cd-fr" "AC ID:cd-ac" "BR ID:cd-own-br" "NFR ID:cd-own-nfr"; do
      while IFS= read -r id; do
        grep -qxF -- "$id" "$TMP/${ids#*:}" || err "$spec" "SPEC §1.5 names $id, which no SRS in the example's scope defines (CONVENTIONS §4)"
      done < <(table_pair "$spec" '^### 1\.5\.' 'FR ID' "${ids%%:*}" | cut -f2 | grep -oE '\b(FR|AC|BR|NFR)-[A-Z0-9-]*[0-9]\b' | sort -u)
    done
    table_pair "$spec" '^### 9\.1\.' 'TC ID' 'AC hoặc INV' > "$TMP/cd-s9"
    cut -f2 "$TMP/cd-s9" | grep -oE "\\b$NFR_RE\\b" >> "$TMP/cd-tested-nfr"
    cut -f1 "$TMP/cd-s9" | grep -oE '^TC-[A-Z0-9-]+' | sed "s|^|$spec\t|" >> "$TMP/cd-spec-tc"
    ((spec_new)) && cut -f1 "$TMP/cd-s9" | grep -oE '^TC-[A-Z0-9-]+' | sed "s|^|$spec\t|" >> "$TMP/cd-spec-tc-new"
    # 2. Every AC that SPEC §1.5 names has a test row in SPEC §9.
    while IFS= read -r ac; do
      grep -qE -- "(^|[^A-Z0-9-])$ac([^0-9]|$)" <(cut -f2 "$TMP/cd-s9") || err "$spec" "$ac is named in SPEC §1.5 but has no test in SPEC §9 (CONVENTIONS §4)"
    done < <(table_pair "$spec" '^### 1\.5\.' 'FR ID' 'AC ID' | cut -f2 | grep -oE '\bAC-[A-Z0-9-]*[0-9]\b' | sort -u)
    table_pair "$spec" '^### 1\.5\.' 'FR ID' 'NFR ID' | cut -f2 | grep -oE "\\b$NFR_RE\\b" | sed "s|^|$spec\t|" >> "$TMP/cd-spec-nfr"
    # 3. Every test file in SPEC §9 is in the SPEC's File Diff (§2.1 or §2.2). §9 may write the path from the package
    #    root while the File Diff writes it from the repository root, so a File Diff path that ends with it counts.
    { section_rows "$spec" '^### 2\.1\.'; section_rows "$spec" '^### 2\.2\.'; } | grep -oE '^\| `[^`]+`' | sed -E 's/^\| `//; s/`$//' | sort -u > "$TMP/cd-diff"
    while IFS= read -r file; do
      awk -v f="$file" '$0 == f || (length($0) > length(f) && substr($0, length($0) - length(f)) == "/" f) { found = 1 } END { exit !found }' "$TMP/cd-diff" ||
        err "$spec" "test file $file in SPEC §9 is not in the File Diff §2 (CONVENTIONS §4)"
    done < <(table_pair "$spec" '^### 9\.1\.' 'TC ID' 'File test' | cut -f2 | grep -oE '`[^`]+`' | tr -d '`' | sort -u)
    # A TC lives in SPEC §9 and in the phase files only (CONVENTIONS §4). The TC column that SRS §8 of a document
    # from an older template still has is read by rule 5 below but is never compared with SPEC §9, for any version.
  done
  # 6. (gated: SPEC template 1.1.0) No TC of a SPEC from template 1.1.0 is defined by another SPEC of the example.
  while IFS= read -r tc; do
    grep -qP -- "\t$tc\$" "$TMP/cd-spec-tc-new" || continue
    err "$dir" "$tc is defined in more than one SPEC §9: $(awk -F'\t' -v t="$tc" '$2 == t { printf "%s ", $1 }' "$TMP/cd-spec-tc")(CONVENTIONS §4)"
  done < <(cut -f2 "$TMP/cd-spec-tc" | sort | uniq -d)
  for srs in "$dir"/docs/srs/*.md; do
    [[ -f "$srs" ]] || continue
    ver="$(gate_version "$srs" core/01_SRS_Template.md)"
    # 5. (gated: SRS template 1.2.0) An NFR a SPEC names and SRS §8 verifies by Test is tested: the SPEC's §9 names the
    #    NFR, or at least one TC that SRS §8 plans for it is in a SPEC §9 of the example.
    if version_at_least "$ver" 1.2.0; then
      if [[ "$(frontmatter_value "$srs" doc_type)" == srs ]] && ! table_pair "$srs" '^## 8\.' 'NFR ID' 'Cách kiểm chứng' '^##? ' | grep -q .; then
        err "$srs" "SRS §8 has no NFR table with 'NFR ID' and 'Cách kiểm chứng' columns (CONVENTIONS §4)"
      fi
      while IFS=$'\t' read -r nfr method; do
        [[ "$method" == Test* ]] || continue
        tc="$(table_pair "$srs" '^## 8\.' 'NFR ID' 'TC' '^##? ' | awk -F'\t' -v n="$nfr" '$1 == n { print $2 }' | grep -oE '\bTC-[A-Z0-9-]+-[0-9]{2}\b' | sort -u)"
        cut -f2 "$TMP/cd-spec-tc" | grep -qxF -f <(printf '%s\n' "${tc:--}") && continue
        grep -qxF -- "$nfr" "$TMP/cd-tested-nfr" && continue  # a shared NFR may be tested by another SPEC of the project
        while IFS=$'\t' read -r spec id; do
          [[ "$id" == "$nfr" ]] || continue
          table_pair "$spec" '^### 9\.1\.' 'TC ID' 'AC hoặc INV' | cut -f2 | grep -qE -- "(^|[^A-Z0-9-])$nfr([^0-9]|\$)" && continue
          err "$srs" "$nfr is named by ${spec##*/} and verified by Test, but no SPEC §9 of the project has a test that names it (CONVENTIONS §4)"
        done < "$TMP/cd-spec-nfr"
      done < <(table_pair "$srs" '^## 8\.' 'NFR ID' 'Cách kiểm chứng' '^##? ')
    fi
    # 9. (gated: SRS template 1.1.0) Every FR has an AC in §8; every Must FR has a use case in §6.2.
    if version_at_least "$ver" 1.1.0; then
      while IFS=$'\t' read -r id cell; do
        [[ "$id" =~ ^FR- ]] || continue
        table_pair "$srs" '^## 8\.' 'FR ID' 'AC ID' '^##? ' | cut -f1 | grep -qxF -- "$id" || err "$srs" "$id has no acceptance criterion in SRS §8 (CONVENTIONS §4)"
        [[ "$cell" == Must* ]] && ! grep -qE "^#### Use case $id:" "$srs" && err "$srs" "$id has priority Must but no use case in SRS §6.2 (PLAYBOOK §2.2)"
      done < <(table_column "$srs" '^### 6\.1\.' 'Ưu tiên')
    fi
  done
  # 8. (gated: Intake template 1.1.0, SRS template 1.2.0) GOAL IDs cited by FR and NFR exist in Intake §2.2, and every
  #    goal is cited at least once.
  intake="$dir/docs/intake/PROJECT_INTAKE.md"
  if [[ -f "$intake" ]] && version_at_least "$(gate_version "$intake" core/00_Project_Intake_Template.md)" 1.1.0; then
    section_rows "$intake" '^### 2\.2\.' | grep -oE '^\| GOAL-[0-9]{2} \|' | grep -oE 'GOAL-[0-9]+' | sort -u > "$TMP/cd-goals"
    [[ -s "$TMP/cd-goals" ]] || err "$intake" "Intake §2.2 has no GOAL-NN row (CONVENTIONS §4)"
    : > "$TMP/cd-goal-cited"; srs_new=0
    for srs in "$dir"/docs/srs/*.md; do
      [[ -f "$srs" ]] && version_at_least "$(gate_version "$srs" core/01_SRS_Template.md)" 1.2.0 || continue
      srs_new=1
      { table_pair "$srs" '^### 6\.1\.' 'FR ID' 'Nguồn'; table_pair "$srs" '^## 7\.' 'NFR ID' 'Nguồn' '^##? '; } |
        cut -f2 | grep -oE '\bGOAL-[0-9]{2}\b' >> "$TMP/cd-goal-cited"
    done
    sort -u "$TMP/cd-goal-cited" -o "$TMP/cd-goal-cited"
    while IFS= read -r goal; do grep -qxF -- "$goal" "$TMP/cd-goals" || err "$dir" "$goal is cited by a requirement but not defined in Intake §2.2 (CONVENTIONS §4)"; done < "$TMP/cd-goal-cited"
    # Coverage is checked only once a SRS from template 1.2.0 carries goal citations.
    ((srs_new)) && while IFS= read -r goal; do grep -qxF -- "$goal" "$TMP/cd-goal-cited" || err "$intake" "$goal is cited by no FR or NFR (CONVENTIONS §4)"; done < "$TMP/cd-goals"
  fi
  # 10. ADR IDs cited by ARCHITECTURE have a file in docs/adr/; approved documents keep no BLOCKING question.
  if [[ -f "$dir/docs/ARCHITECTURE.md" ]]; then
    for adr in $(grep -oE '\bADR-[0-9]{4}\b' "$dir/docs/ARCHITECTURE.md" | sort -u); do
      compgen -G "$dir/docs/adr/${adr#ADR-}-*.md" >/dev/null || err "$dir/docs/ARCHITECTURE.md" "$adr is cited but docs/adr/${adr#ADR-}-*.md does not exist (CONVENTIONS §4)"
    done
  fi
  while IFS= read -r file; do
    [[ "$(frontmatter_value "$file" status)" == approved ]] || continue
    while IFS=$'\t' read -r id cell; do
      [[ "$id" =~ ^AQ- && "$cell" == Có* ]] && err "$file" "approved document still has BLOCKING question $id (PLAYBOOK §7 rules 1, 3)"
    done < <(table_column "$file" '^#+ .*Assumptions & Open Questions' 'BLOCKING')
  done < <(find "$dir/docs" -name '*.md' 2>/dev/null | sort)
  true
}

# assembled_version <file> <source-path>: the version at which <file> lists <source-path> in assembled_from (empty if absent).
assembled_version() {
  frontmatter_list "$1" assembled_from | awk -v p="$2@" 'index($0, p) == 1 { print substr($0, length(p) + 1); exit }'
}

# gate_version <file> <template-path>: the version <file> gates on (CONVENTIONS §3, one way to read a version gate):
# its own template_version when set, otherwise the assembled_from version of <template-path> (a document written before
# this field existed, or a fixture that only sets assembled_from).
gate_version() {
  local v; v="$(frontmatter_value "$1" template_version)"
  [[ -n "$v" ]] && { printf '%s\n' "$v"; return; }
  assembled_version "$1" "$2"
}

# first_header_table <file> <first-header-prefix> <column-prefix>: for the first table whose first header cell starts with
# <first-header-prefix> and that has a header cell starting with <column-prefix>, print "#HEADER" and then
# "<first-cell>\t<cell>" per data row. Tables inside fenced code are skipped; escaped pipes (\|) stay in their cell.
first_header_table() {
  awk -v a="$2" -v b="$3" '
    /^[ \t]*(```|~~~)/ { fence = !fence; intable = 0; next }
    fence || !/^\|/ { intable = 0; next }
    {
      line = $0; gsub(/\\\|/, "\001", line); n = split(line, c, "|")
      for (i = 2; i < n; i++) { gsub(/^ +| +$/, "", c[i]); gsub(/\001/, "\\|", c[i]) }
      if (!intable) {
        intable = 1; header = 1; idx = 0
        if (!found && index(c[2], a) == 1) for (i = 2; i < n; i++) if (!idx && index(c[i], b) == 1) idx = i
        want = (idx > 0); if (want) { found = 1; print "#HEADER" }
        next
      }
      if (header) { header = 0; next }
      if (want) print c[2] "\t" c[idx]
    }' "$1"
}

# srs_screen_rows <srs-file>: rows of the User Interfaces tables in SRS §3: every table of §3 (up to the next "#" or "##"
# heading) with a header cell starting "Màn hình" and either a header cell starting "SCR ID" or one starting "Route" or
# "Điểm vào". Another table whose header merely starts with "Màn hình" (for example "Màn hình tối thiểu" in a device
# table) is not a User Interfaces table. Prints "ROW<US><Màn hình cell><US><SCR ID cell><US><FR cell>" per data row (US
# is the unit separator \037, so an empty cell stays a field; the FR cell is the first column whose header starts with
# "FR", empty when there is none), or "NOCOL<US><header line>" once for a screen table (screen and route columns) without
# an "SCR ID" column. The screen-name column is found by its own header, so it is never read as the ID column.
srs_screen_rows() {
  awk -v US=$'\037' '
    /^## 3\./ { on = 1; next }
    on && /^##? / { exit }
    !on { next }
    /^[ \t]*(```|~~~)/ { fence = !fence; intable = 0; next }
    fence || !/^\|/ { intable = 0; next }
    {
      line = $0; gsub(/\\\|/, "\001", line); n = split(line, c, "|")
      for (i = 2; i < n; i++) { gsub(/^ +| +$/, "", c[i]) }
      if (!intable) {
        intable = 1; header = 1; iname = iscr = ifr = iroute = 0
        for (i = 2; i < n; i++) {
          if (!iname && index(c[i], "Màn hình") == 1) iname = i
          if (!iscr && index(c[i], "SCR ID") == 1) iscr = i
          if (!ifr && index(c[i], "FR") == 1) ifr = i
          if (!iroute && (index(c[i], "Route") == 1 || index(c[i], "Điểm vào") == 1)) iroute = i
        }
        want = (iname > 0 && (iscr > 0 || iroute > 0))
        if (want && !iscr) { print "NOCOL" US $0; want = 0 }
        next
      }
      if (header) { header = 0; next }
      if (want) print "ROW" US c[iname] US c[iscr] US (ifr ? c[ifr] : "")
    }' "$1"
}

SCR_RE='SCR-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{2}'
FR_RE='FR-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{3}'
AC_RE='AC-[A-Z]{2,6}(-[A-Z]{2,6})?-[0-9]{2}'

# HTML_CSP: the only Content-Security-Policy an HTML wireframe may carry (CONVENTIONS §7), whitespace normalised.
HTML_CSP="default-src 'none'; style-src 'unsafe-inline'; img-src data:"

# html_tags <flat-html>: every start or end tag of <flat-html> (one line), one per line; quoted values may hold ">".
html_tags() { grep -oE "<[A-Za-z/!]([^>\"']|\"[^\"]*\"|'[^']*')*>" <<< "$1"; }

# html_attr_values <tags> <attribute-regex>: the value of each attribute matching <attribute-regex> (case-insensitive,
# unquoted, quoted with " or with '), one per line; an attribute split over lines was already joined.
html_attr_values() {
  grep -oiE "[[:space:]/\"'](${2})[[:space:]]*=[[:space:]]*(\"[^\"]*\"|'[^']*'|[^[:space:]>\"']+)" <<< "$1" |
    sed -E "s/^.[^=]*=[[:space:]]*//; s/^\"(.*)\"\$/\1/; s/^'(.*)'\$/\1/"
}

# srcset_urls: read one srcset attribute value per input line and print the URL of each image candidate, one per line
# (WHATWG "parse a srcset attribute"). A URL is read up to whitespace, so it may itself contain a comma (a data: URI);
# a URL that ends with a comma has no descriptor and the comma is dropped; otherwise the descriptor that follows runs to
# the next comma and is discarded. This catches an external URL that has no space before or after its separating comma.
srcset_urls() {
  awk '
    {
      s = $0
      while (1) {
        while (match(s, /^[ \t,]+/)) s = substr(s, RLENGTH + 1)
        if (s == "") break
        if (match(s, /[ \t]/)) { url = substr(s, 1, RSTART - 1); rest = substr(s, RSTART) } else { url = s; rest = "" }
        if (match(url, /,+$/)) { sub(/,+$/, "", url); print url; s = rest; continue }
        print url
        match(rest, /^[ \t]+/); rest = substr(rest, RLENGTH + 1)
        if (match(rest, /,/)) s = substr(rest, RSTART + 1); else s = ""
      }
    }'
}

# style_bodies <flat-html>: the content of every <style>...</style> block (well-formed HTML has no nested style tags),
# one per output line, so a CSS escape (backslash) can be looked for without also scanning the rest of the document.
style_bodies() {
  awk '
    {
      s = $0
      while (match(s, /<[Ss][Tt][Yy][Ll][Ee][^>]*>/)) {
        s = substr(s, RSTART + RLENGTH)
        if (match(s, /<\/[Ss][Tt][Yy][Ll][Ee]>/)) { print substr(s, 1, RSTART - 1); s = substr(s, RSTART + RLENGTH) }
        else { print s; s = "" }
      }
    }' <<< "$1"
}

# check_html_wireframe <html-file>: the HTML safety rule of CONVENTIONS §7 (see check_wireframes step 6).
check_html_wireframe() {
  local html="$1" flat tags bare bad csp
  flat="$(tr '\r\n\t\f' '    ' < "$html")"
  tags="$(html_tags "$flat")"
  # Tags with their quoted values emptied, so text inside a value is never read as an attribute.
  bare="$(sed -E "s/\"[^\"]*\"/\"\"/g; s/'[^']*'/''/g" <<< "$tags")"
  grep -qiE '<script([[:space:]/>]|$)' <<< "$flat" && err "$html" "HTML wireframe has a script tag (CONVENTIONS §7)"
  grep -qiE "^<[a-z][^>]*[[:space:]/\"']on[a-z]+[[:space:]]*=" <<< "$bare" &&
    err "$html" "HTML wireframe has an event handler attribute on...= (CONVENTIONS §7)"
  grep -qiE '<(iframe|object|embed|base)([[:space:]/>]|$)' <<< "$flat" &&
    err "$html" "HTML wireframe has an iframe, object, embed or base tag (CONVENTIONS §7)"
  grep -qiE '<link([[:space:]/>]|$)' <<< "$flat" && err "$html" "HTML wireframe has a link tag; styles go in its own <style> tag (CONVENTIONS §7)"
  { grep -iE '^<form[[:space:]/]' <<< "$bare" | grep -iE '[[:space:]/]action[[:space:]]*=' >/dev/null ||
    grep -qiE '[[:space:]/]formaction[[:space:]]*=' <<< "$bare"; } &&
    err "$html" "HTML wireframe has a form that submits (CONVENTIONS §7)"
  grep -qiE '@import' <<< "$flat" && err "$html" "HTML wireframe has an @import (CONVENTIONS §7)"
  grep -iE '^<meta[[:space:]/]' <<< "$tags" | grep -iE "http-equiv[[:space:]]*=[[:space:]]*[\"']?[[:space:]]*refresh" >/dev/null &&
    err "$html" "HTML wireframe has a meta refresh (CONVENTIONS §7)"
  grep -qiE 'javascript[[:space:]]*:' <<< "$tags" && err "$html" "HTML wireframe has a javascript: URL (CONVENTIONS §7)"
  # A backslash in a <style> tag or a style attribute is a CSS escape (\75\72\6c spells "url" one code point at a
  # time); an & in a style attribute is an HTML entity (u&#114;l( spells "url(" with one letter entity-encoded). Both
  # can spell a banned function name past the plain-text scan below, so any occurrence is an error on its own.
  while IFS= read -r style_body; do
    [[ "$style_body" == *'\'* ]] && { err "$html" "HTML wireframe has a backslash (CSS escape) inside a <style> tag (CONVENTIONS §7)"; break; }
  done < <(style_bodies "$flat")
  local style_attrs; style_attrs="$(html_attr_values "$tags" 'style')"
  [[ "$style_attrs" == *'\'* ]] && err "$html" "HTML wireframe has a backslash (CSS escape) in a style attribute (CONVENTIONS §7)"
  [[ "$style_attrs" == *'&'* ]] && err "$html" "HTML wireframe has an HTML entity (&) in a style attribute (CONVENTIONS §7)"
  # Targets: every URL-taking attribute (src, href, poster, background, ping, cite, data) and each srcset candidate in
  # tags; anywhere (style tags and style attributes), url() and the quoted strings of the CSS functions that take a URL
  # as a plain string: image-set() (also -webkit-image-set()), image() and src(). A type("...") hint inside image-set()
  # is a media type, not a URL, so it is dropped first.
  bad="$( { html_attr_values "$tags" 'src|href|xlink:href|poster|background|ping|cite|data'
            html_attr_values "$tags" 'srcset' | srcset_urls
            grep -oiE "url\([[:space:]]*(\"[^\"]*\"|'[^']*'|[^)]*)\)" <<< "$flat" |
              sed -E "s/^[uU][rR][lL]\([[:space:]]*//; s/[[:space:]]*\)\$//; s/^\"(.*)\"\$/\1/; s/^'(.*)'\$/\1/"
            grep -oiE "(^|[^a-z0-9_-])(-webkit-)?(image-set|image|src)\(([^()]|\([^()]*\))*\)" <<< "$flat" |
              sed -E 's/[tT][yY][pP][eE]\([^)]*\)//g' | grep -oE "\"[^\"]*\"|'[^']*'" | sed -E 's/^.(.*).$/\1/'
          } | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -v '^$' | grep -vE '^(SCR-[A-Z0-9-]+\.html(#.*)?|#.*)$' | grep -viE '^data:image/' | head -n 1)"
  [[ -z "$bad" ]] ||
    err "$html" "HTML wireframe points src, href, srcset or a CSS URL function (url(), image-set(), image(), src()) at '$bad'; only a sibling SCR-*.html, a #fragment or a data: image are allowed (CONVENTIONS §7)"
  csp="$(grep -iE '^<meta[[:space:]/]' <<< "$tags" | grep -iE "http-equiv[[:space:]]*=[[:space:]]*[\"']?[[:space:]]*Content-Security-Policy")"
  if [[ -z "$csp" ]]; then
    err "$html" "HTML wireframe has no Content-Security-Policy meta tag (CONVENTIONS §7)"
  else
    # Browsers ignore a CSP meta tag outside <head>: every CSP meta tag comes before the first </head> or <body> tag.
    [[ "$(awk '{ t = tolower($0) } t ~ /^<\/head[ >]/ || t ~ /^<body[ >\/]/ { exit } { print }' <<< "$tags" |
          grep -iE '^<meta[[:space:]/]' | grep -ciE "http-equiv[[:space:]]*=[[:space:]]*[\"']?[[:space:]]*Content-Security-Policy")" == "$(grep -c . <<< "$csp")" ]] ||
      err "$html" "HTML wireframe has a Content-Security-Policy meta tag outside <head>, where browsers ignore it (CONVENTIONS §7)"
    # Every CSP meta tag has a content attribute, and each content equals the policy.
    [[ "$(grep -ciE '[[:space:]/"'"'"']content[[:space:]]*=' <<< "$csp")" == "$(grep -c . <<< "$csp")" ]] &&
      ! html_attr_values "$csp" 'content' | sed -E 's/[[:space:]]+/ /g; s/ ?; ?/; /g; s/^ //; s/ $//' | grep -vxF -- "$HTML_CSP" >/dev/null ||
      err "$html" "HTML wireframe has a Content-Security-Policy other than \"$HTML_CSP\" (CONVENTIONS §7)"
  fi
}

# ux_key_rows <file> <first-header> <column-prefix>: "<key>\t<cell>" per data row of the first table whose first header
# cell starts with <first-header> and that has a column starting with <column-prefix>; backticks removed. Prints nothing
# when there is no such table.
ux_key_rows() {
  first_header_table "$1" "$2" "$3" | grep -v '^#HEADER$' | tr -d '`'
}

# check_ux_key_table <file> <label> <first-header> <name-header> <catalog> <ref>: the file has a table whose first column
# is <first-header> with exactly one row per key of <catalog> ("<key>\t<name>" parsed from CONVENTIONS §10), no row for
# another key, and in each row the <name-header> cell equals the name of CONVENTIONS. Used for the heuristic table
# (§10.3) and the deceptive pattern table (§10.4) of a wireframe index, and of the index template in template mode.
# Returns non-zero when the table is missing.
check_ux_key_table() {
  local file="$1" label="$2" first="$3" col="$4" catalog="$5" ref="$6" key name want count
  first_header_table "$file" "$first" "$col" > "$TMP/ux-rows"
  if ! grep -qx '#HEADER' "$TMP/ux-rows"; then
    err "$file" "$label: no table whose first column is '$first' with a '$col' column ($ref)"
    return 1
  fi
  grep -v '^#HEADER$' "$TMP/ux-rows" | tr -d '`' > "$TMP/ux-rows-clean"
  while IFS=$'\t' read -r key want; do
    count="$(cut -f1 "$TMP/ux-rows-clean" | grep -cxF -- "$key")"
    if ((count == 0)); then
      err "$file" "$label: no row for $key ($want); write exactly one row per key of $ref"
    elif ((count > 1)); then
      err "$file" "$label: $key has $count rows; write exactly one ($ref)"
    fi
  done < "$catalog"
  while IFS=$'\t' read -r key name; do
    want="$(awk -F'\t' -v k="$key" '$1 == k { print $2; exit }' "$catalog")"
    if ! cut -f1 "$catalog" | grep -qxF -- "$key"; then
      err "$file" "$label: row '$key' is not a key of $ref"
    elif [[ "$name" != "$want" ]]; then
      err "$file" "$label: row $key names '$name'; $ref names it '$want'"
    fi
  done < "$TMP/ux-rows-clean"
  return 0
}

# check_ux_index <index-file>: the UI/UX tables of a wireframe index built from index template 1.2.0 or later
# (CONVENTIONS §10.3, §10.4; PLAYBOOK §2.2.1 Gate 1W). Keys, names, levels and results are read from CONVENTIONS.
check_ux_index() {
  local index="$1" approved=0 key level result evidence levels blocking clean found
  [[ "$(frontmatter_value "$index" status)" == approved ]] && approved=1
  levels="$(paste -sd'|' "$TMP/ux-levels" | sed 's/|/ | /g')"
  blocking="$(cat "$TMP/ux-level-blocking")"
  clean="$(cat "$TMP/ux-dp-clean")"
  found="$(cat "$TMP/ux-dp-found")"
  # 1. Heuristic table: one row per key of §10.3 with its name; each level is one of §10.3; an approved index has no
  #    row at the level that Gate 1W blocks.
  if check_ux_key_table "$index" "heuristic evaluation" 'Khóa heuristic' 'Heuristic' "$TMP/ux-heuristics" "CONVENTIONS §10.3"; then
    [[ -n "$(ux_key_rows "$index" 'Khóa heuristic' 'Mức vấn đề')" ]] ||
      err "$index" "heuristic evaluation: the table has no 'Mức vấn đề' column (CONVENTIONS §10.3)"
    while IFS=$'\t' read -r key level; do
      level="$(sed -E 's/^ +| +$//g' <<< "$level")"
      if ! grep -qxF -- "$level" "$TMP/ux-levels"; then
        err "$index" "heuristic evaluation: row $key has level '$level'; write one of $levels (CONVENTIONS §10.3)"
      elif ((approved)) && [[ "$level" == "$blocking" ]]; then
        err "$index" "heuristic evaluation: row $key of an approved index has level '$blocking'; fix the problem before Gate 1W (PLAYBOOK §2.2.1)"
      fi
    done < <(ux_key_rows "$index" 'Khóa heuristic' 'Mức vấn đề')
  fi
  # 2. Deceptive pattern table: one row per key of §10.4 with its name; each result is the clean value with evidence or
  #    the found value with a location; an approved index has no row with the found value.
  if check_ux_key_table "$index" "deceptive patterns" 'Khóa mẫu lừa' 'Mẫu' "$TMP/ux-deceptive" "CONVENTIONS §10.4"; then
    [[ -n "$(ux_key_rows "$index" 'Khóa mẫu lừa' 'Kết quả')" && -n "$(ux_key_rows "$index" 'Khóa mẫu lừa' 'Căn cứ')" ]] ||
      err "$index" "deceptive patterns: the table needs a 'Kết quả' and a 'Căn cứ' column (CONVENTIONS §10.4)"
    while IFS=$'\t' read -r key result evidence; do
      result="$(sed -E 's/^ +| +$//g' <<< "$result")"
      if [[ "$result" != "$clean" && "$result" != "$found" ]]; then
        err "$index" "deceptive patterns: row $key reads '$result'; write '$clean' with evidence or '$found' with the location (CONVENTIONS §10.4)"
      elif [[ -z "${evidence//[[:space:][:punct:]]/}" ]]; then
        err "$index" "deceptive patterns: row $key reads '$result' with an empty 'Căn cứ' cell; write the evidence or the location (CONVENTIONS §10.4)"
      elif ((approved)) && [[ "$result" == "$found" ]]; then
        err "$index" "deceptive patterns: row $key of an approved index reads '$found'; remove the pattern before Gate 1W (PLAYBOOK §2.2.1)"
      fi
    done < <(paste <(ux_key_rows "$index" 'Khóa mẫu lừa' 'Kết quả') <(ux_key_rows "$index" 'Khóa mẫu lừa' 'Căn cứ' | cut -f2))
  fi
}

# wcag_level <example-dir>: the WCAG 2.2 level chosen by NFR-USAB, read from the "Trợ năng" row of the Technical
# Constraints table in any SRS file's §2.5 (master or module; CONVENTIONS mục 10.2). Empty when it cannot be read.
wcag_level() {
  local dir="$1" srs row
  for srs in "$dir"/docs/srs/*.md; do
    [[ -f "$srs" ]] || continue
    row="$(section_rows "$srs" '^### 2\.5\.' | grep -m1 -E '^\| Trợ năng \|')"
    [[ -n "$row" ]] || continue
    grep -m1 -oE 'mức (AAA|AA|A)\b' <<< "$row" | awk '{ print $2 }'
    return
  done
}

# check_ux_page <page-file> [<wcag-level>]: a screen page built from page template 1.2.0 or later has the "Màn hình
# xác thực: Có | Không" line; a page marked Có cites criterion 3.3.8 in its accessibility section (CONVENTIONS §10.2).
# At WCAG level A, marking 3.3.8 N/A satisfies the rule (accessible authentication is AA); the line must still be
# present. At level AA, AAA or when the level cannot be read, a real citation is required as before.
check_ux_page() {
  local page="$1" level="${2:-}" line value cite
  line="$(unfenced "$page" | cut -f2- | grep -m1 -E '^(- )?Màn hình xác thực:')"
  if [[ -z "$line" ]]; then
    err "$page" "authentication screen: wireframe page has no 'Màn hình xác thực: Có | Không' line (CONVENTIONS §10.2)"
    return 0
  fi
  value="${line#*:}"
  value="$(tr -d '`' <<< "$value" | sed -E 's/^ +| +$//g')"
  local value_re='^(Có|Không)([[:space:]]*([.,;(].*)?)$'
  if [[ ! "$value" =~ $value_re ]]; then
    err "$page" "authentication screen: the 'Màn hình xác thực' line reads '$value'; write Có or Không (CONVENTIONS §10.2)"
  elif [[ "$value" == Có* ]]; then
    cite="$(section_rows "$page" '^## [0-9]+\. .*\(Accessibility' | grep -E '(^|[^0-9.])3\.3\.8([^0-9]|$)')"
    if [[ -z "$cite" ]]; then
      err "$page" "authentication screen: the page reads 'Màn hình xác thực: Có' but its accessibility section does not cite criterion 3.3.8, or marks it N/A (CONVENTIONS §10.2)"
    elif [[ "$level" != A ]] && ! grep -v 'N/A' <<< "$cite" >/dev/null; then
      err "$page" "authentication screen: the page reads 'Màn hình xác thực: Có' but its accessibility section does not cite criterion 3.3.8, or marks it N/A (CONVENTIONS §10.2)"
    fi
  fi
}

# xp_value <line>: the value after the first colon, without HTML comments, backticks around a bare Không, and outer spaces.
xp_value() {
  local v="${1#*:}"
  v="$(sed -E 's/<!--.*-->//g; s/^[[:space:]]+|[[:space:]]+$//g' <<< "$v")"
  printf '%s' "$v"
}

# xp_bare_none <value>: true when the value is Không (backticks allowed) with no reason after it.
xp_bare_none() {
  local v="${1//\`/}"
  [[ "$v" == Không* ]] || return 1
  v="${v#Không}"
  v="$(sed -E 's/^[][[:space:],.:;()—–-]+//' <<< "$v")"
  [[ -z "$v" ]]
}

# check_experience_page <page-file>: a screen page built from page template 1.5.0 or later has the Thông tin ưu tiên,
# Hành động chính and Nội dung biên lines, and numbers the zones of its low-fi block (CONVENTIONS §7, §10.7). The low-fi
# block is the first `text` block of section 2; the components table is the first table whose first header is Thành phần.
check_experience_page() {
  local page="$1" suffix=" (CONVENTIONS §10.7)" lines n value label item count
  local body; body="$(unfenced "$page" | cut -f2-)"

  # 1. Thông tin ưu tiên: one line, 1 to 3 items separated by ";".
  lines="$(grep -E '^- Thông tin ưu tiên:' <<< "$body")"
  n="$(grep -c . <<< "$lines")"
  if ((n == 0)); then
    err "$page" "priority information: no 'Thông tin ưu tiên:' line; name 1 to 3 items in priority order$suffix"
  elif ((n > 1)); then
    err "$page" "priority information: has $n 'Thông tin ưu tiên:' lines; a page has one$suffix"
  else
    value="$(xp_value "$lines")"
    if [[ -z "$value" || "${value//\`/}" == Không* ]]; then
      err "$page" "priority information: the 'Thông tin ưu tiên' line has no item$suffix"
    else
      count=0
      while IFS= read -r item; do
        count=$((count + 1))
        [[ -n "$(tr -d '[:space:]' <<< "$item")" ]] || { err "$page" "priority information: the 'Thông tin ưu tiên' line has an empty item$suffix"; count=-99; break; }
      done < <(tr ';' '\n' <<< "$value")
      ((count > 3)) && err "$page" "priority information: the 'Thông tin ưu tiên' line lists $count items; name 1 to 3$suffix"
    fi
  fi

  # 2. Hành động chính: one line naming a component of the components table in backticks, or Không with a reason.
  lines="$(grep -E '^- Hành động chính:' <<< "$body")"
  n="$(grep -c . <<< "$lines")"
  if ((n == 0)); then
    err "$page" "main action: no 'Hành động chính:' line; name one component of the components table, or Không with a reason$suffix"
  elif ((n > 1)); then
    err "$page" "main action: has $n 'Hành động chính:' lines; a page has one$suffix"
  else
    value="$(xp_value "$lines")"
    if [[ "$value" == Không* ]] || [[ "$value" =~ ^\`Không\`[[:space:]]*$ ]]; then
      xp_bare_none "$value" && err "$page" "main action: the 'Hành động chính' line reads 'Không' without a reason$suffix"
    elif [[ ! "$value" =~ \`([^\`]+)\` ]]; then
      err "$page" "main action: the 'Hành động chính' line has no label in backticks; write the label of a component of the components table between backticks$suffix"
    else
      label="$(sed -E 's/^[[:space:]]*\[//; s/\][[:space:]]*$//; s/^[[:space:]]+|[[:space:]]+$//g' <<< "${BASH_REMATCH[1]}")"
      first_header_table "$page" 'Thành phần' 'Thành phần' | grep -v '^#HEADER$' | cut -f1 |
        sed -E 's/`//g; s/^[[:space:]]+|[[:space:]]+$//g; s/^\[[[:space:]]*//; s/[[:space:]]*\]$//' > "$TMP/xp-components"
      if ! in_list "$label" "$TMP/xp-components"; then
        err "$page" "main action: the 'Hành động chính' line names '$label', which is not in the Thành phần column of the components table$suffix"
      else
        # Exactly one action: no second backticked label of the line is also a component.
        while IFS= read -r item; do
          item="$(sed -E 's/^`|`$//g; s/^[[:space:]]*\[//; s/\][[:space:]]*$//; s/^[[:space:]]+|[[:space:]]+$//g' <<< "$item")"
          [[ -n "$item" && "$item" != "$label" ]] && in_list "$item" "$TMP/xp-components" &&
            { err "$page" "main action: the 'Hành động chính' line names both '$label' and '$item'; name exactly one action$suffix"; break; }
        done < <(grep -oE '`[^`]+`' <<< "$value")
      fi
    fi
  fi

  # 3. Nội dung biên: one line with the edge cases, or Không with a reason.
  lines="$(grep -E '^(- )?Nội dung biên:' <<< "$body")"
  n="$(grep -c . <<< "$lines")"
  if ((n == 0)); then
    err "$page" "edge content: no 'Nội dung biên:' line; write the edge cases from the constraints of SRS §4.2, or Không with a reason$suffix"
  elif ((n > 1)); then
    err "$page" "edge content: has $n 'Nội dung biên:' lines; a page has one$suffix"
  else
    value="$(xp_value "$lines")"
    if [[ -z "$value" ]]; then
      err "$page" "edge content: the 'Nội dung biên' line is empty$suffix"
    elif xp_bare_none "$value"; then
      err "$page" "edge content: the 'Nội dung biên' line reads 'Không' without a reason$suffix"
    fi
  fi

  # 4. Zone numbers: every zone of the low-fi block has a number, and the numbers run 1 to n in reading order.
  local out
  out="$(awk '
    /^## / { if (sec) exit; if ($0 ~ /^## 2\./) sec = 1; next }
    !sec { next }
    !inblock && !done && /^[ \t]*```text[ \t]*$/ { inblock = 1; next }
    inblock && /^[ \t]*```/ { inblock = 0; done = 1; next }
    inblock && /^== .* ==[ \t]*$/ {
      line = $0; sub(/[ \t]+$/, "", line); inner = line; sub(/^== /, "", inner); sub(/ ==$/, "", inner)
      zones++; k = split(inner, part, /[ \t]*\|[ \t]*/)
      for (i = 1; i <= k; i++) {
        if (part[i] ~ /^[0-9]+\. [^ ]/) { num = part[i]; sub(/\..*/, "", num); nums = nums (nums == "" ? "" : ", ") num; m++; if (num + 0 != m) bad = 1 }
        else { print "UNNUM\t" line; skip = 1; break }
      }
    }
    END { if (!zones) print "NONE\t-"; else if (!skip && bad) print "ORDER\t" nums }' "$page")"
  while IFS=$'\t' read -r kind value; do
    case "$kind" in
      UNNUM) err "$page" "low-fi zone: zone line '$value' has no number; zones of a page from template 1.5.0 read '== N. Tên vùng ==' (CONVENTIONS §7)" ;;
      ORDER) err "$page" "low-fi zone: zone numbers read $value; number the zones 1 to n in reading order (CONVENTIONS §7)" ;;
      NONE) err "$page" "low-fi zone: section 2 has no text block with zone lines '== N. Tên vùng ==' (CONVENTIONS §7)" ;;
    esac
  done <<< "$out"
}

# check_wireframe_templates_ux: the heuristic and deceptive pattern rows of the index template carry exactly the keys and
# names of CONVENTIONS §10.3 and §10.4, so a project that copies the template starts from the contract.
check_wireframe_templates_ux() {
  local t=core/07_Wireframe_Template/00_Wireframe_Index_Template.md
  [[ -f "$t" ]] || return 0
  check_ux_key_table "$t" "heuristic evaluation" 'Khóa heuristic' 'Heuristic' "$TMP/ux-heuristics" "CONVENTIONS §10.3"
  check_ux_key_table "$t" "deceptive patterns" 'Khóa mẫu lừa' 'Mẫu' "$TMP/ux-deceptive" "CONVENTIONS §10.4"
}

# check_wireframes <example-dir>: the Stage 1W rules (PLAYBOOK §2.2.1; CONVENTIONS §4 chain FR → SCR, §7 HTML safety).
# Gated: they apply when the project's Intake lists core/00_Project_Intake_Template.md at 1.3.0 or later in assembled_from.
# Table shapes read here: in docs/wireframes/00_WIREFRAME_INDEX.md, the screen catalog is the first table whose first
# header cell is "SCR ID"; the traceability table is the first table whose first header cell is "FR ID" and that has an
# "SCR ID" column. In SRS §3, a User Interfaces table is a table with a "Màn hình" column and an "SCR ID", "Route" or
# "Điểm vào" column (srs_screen_rows); its IDs sit in the "SCR ID" column.
check_wireframes() {
  local dir="$1" intake="$1/docs/intake/PROJECT_INTAKE.md" wf="$1/docs/wireframes" index srs page id fr cell count
  local kind name state ref html surface ui=0 member frs brownfield=0 trace_re="^\`?$SCR_RE"
  index="$wf/00_WIREFRAME_INDEX.md"
  [[ -f "$intake" ]] && version_at_least "$(gate_version "$intake" core/00_Project_Intake_Template.md)" 1.3.0 || return 0
  # 0. A project with a UI surface (PLAYBOOK §2: the overlays that have Stage 1W) has the wireframe index.
  while IFS= read -r surface; do
    grep -qxF -- "$surface" "$TMP/ui-overlays" && ui=1
  done < <(frontmatter_list "$intake" overlays)
  if [[ ! -f "$index" ]]; then
    ((ui)) && err "$intake" "the project has a UI surface but no docs/wireframes/00_WIREFRAME_INDEX.md (PLAYBOOK §2.2.1)"
    return 0
  fi

  # Sources: FRs and priorities of SRS §6.1 (master and modules pooled), AC owners of SRS §8, the screens of SRS §3.
  : > "$TMP/wf-fr-prio"; : > "$TMP/wf-ac-fr"; : > "$TMP/wf-srs-scr"; : > "$TMP/wf-scope-fr"; : > "$TMP/wf-srs-scr-fr"
  grep -qE '^\| `mode` \| `?brownfield' "$intake" && brownfield=1
  for srs in "$dir"/docs/srs/*.md; do
    [[ -f "$srs" ]] || continue
    table_pair "$srs" '^### 6\.1\.' 'FR ID' 'Ưu tiên' | grep -E "^$FR_RE"$'\t' >> "$TMP/wf-fr-prio"
    table_pair "$srs" '^## 8\.' 'FR ID' 'AC ID' '^##? ' | grep -E "^$FR_RE"$'\t' >> "$TMP/wf-ac-fr"
    while IFS=$'\037' read -r kind name cell frs; do
      if [[ "$kind" == NOCOL ]]; then
        err "$srs" "screen set: the User Interfaces table of SRS §3 has no 'SCR ID' column (CONVENTIONS §4)"
      elif [[ "$cell" =~ $SCR_RE ]]; then
        while IFS= read -r id; do
          printf '%s\n' "$id" >> "$TMP/wf-srs-scr"
          grep -oE "$FR_RE" <<< "$frs" | awk -v i="$id" '{ print i "\t" $0 }' >> "$TMP/wf-srs-scr-fr"
        done < <(grep -oE "$SCR_RE" <<< "$cell")
      elif [[ "$cell" != Giữ\ nguyên* ]]; then
        err "$srs" "screen set: screen '$name' in SRS §3 has no SCR ID; write SCR-{MOD}-NN, or 'Giữ nguyên' for an unchanged brownfield screen (CONVENTIONS §4)"
      elif ((!brownfield)); then
        err "$srs" "screen set: screen '$name' in SRS §3 reads 'Giữ nguyên' in the SCR ID column, which only a brownfield project may use (CONVENTIONS §4)"
      fi
    done < <(srs_screen_rows "$srs")
  done
  # SCR IDs are unique across SRS §3 of the master and every module SRS.
  while IFS= read -r id; do
    err "$dir/docs/srs" "screen set: $id appears more than once in the SCR ID column of SRS §3; an SCR ID names one screen (CONVENTIONS §4)"
  done < <(sort "$TMP/wf-srs-scr" | uniq -d)
  example_scope "$dir" > "$TMP/wf-scope"
  while IFS= read -r member; do
    for srs in "$member"/docs/srs/*.md; do
      [[ -f "$srs" ]] && grep -oE "^\| $FR_RE \|" "$srs" | grep -oE "$FR_RE" >> "$TMP/wf-scope-fr"
    done
  done < "$TMP/wf-scope"
  cut -f1 "$TMP/wf-fr-prio" | sort -u > "$TMP/wf-srs-fr"
  sort -u "$TMP/wf-srs-scr" -o "$TMP/wf-srs-scr"
  sort -u "$TMP/wf-scope-fr" -o "$TMP/wf-scope-fr"
  first_header_table "$index" 'SCR ID' 'SCR ID' > "$TMP/wf-catalog"
  first_header_table "$index" 'FR ID' 'SCR ID' > "$TMP/wf-trace"
  grep -qx '#HEADER' "$TMP/wf-catalog" || err "$index" "screen set: no screen catalog table whose first column is 'SCR ID' (CONVENTIONS §4)"
  grep -qx '#HEADER' "$TMP/wf-trace" || err "$index" "no FR traceability table with 'FR ID' and 'SCR ID' columns (CONVENTIONS §4)"
  grep -v '^#HEADER$' "$TMP/wf-catalog" | cut -f1 | grep -oE "$SCR_RE" | sort -u > "$TMP/wf-cat-scr"
  grep -v '^#HEADER$' "$TMP/wf-trace" | cut -f2 | grep -oE "$SCR_RE" | sort -u > "$TMP/wf-trace-scr"

  # 1. The FR traceability table has exactly one row per FR of SRS §6.1 whose priority is not Won't, and no row for a
  #    Won't FR. Each row names SCR-* IDs, "Không có giao diện" (with a reason) or "Giữ nguyên" (brownfield).
  while IFS=$'\t' read -r fr cell; do
    count="$(grep -cxF -- "$fr" <(grep -v '^#HEADER$' "$TMP/wf-trace" | cut -f1))"
    cell="${cell//\`/}"
    if [[ "$cell" == Won\'t* || "$cell" == Won’t* ]]; then
      ((count == 0)) || err "$index" "$fr has priority Won't but has a row in the FR traceability table; a Won't FR has none (CONVENTIONS §4)"
    elif ((count == 0)); then
      err "$index" "$fr of SRS §6.1 has no row in the FR traceability table (CONVENTIONS §4)"
    elif ((count > 1)); then
      err "$index" "$fr has $count rows in the FR traceability table; write exactly one (CONVENTIONS §4)"
    fi
  done < <(sort -u "$TMP/wf-fr-prio")
  while IFS=$'\t' read -r fr cell; do
    [[ "$fr" == '#HEADER' ]] && continue
    grep -qxF -- "$fr" "$TMP/wf-srs-fr" || err "$index" "row '$fr' of the FR traceability table is not an FR of SRS §6.1 (CONVENTIONS §4)"
    [[ "$cell" =~ $trace_re || "$cell" == Không\ có\ giao\ diện* || "$cell" == Giữ\ nguyên* ]] ||
      err "$index" "row $fr of the FR traceability table reads '$cell'; write SCR-* IDs, 'Không có giao diện' with a reason, or 'Giữ nguyên' (CONVENTIONS §4)"
    [[ "$cell" =~ ^Không\ có\ giao\ diện[[:space:][:punct:]]*$ ]] &&
      err "$index" "row $fr of the FR traceability table reads 'Không có giao diện' without a reason (CONVENTIONS §4)"
    [[ "$cell" == Giữ\ nguyên* ]] && ((!brownfield)) &&
      err "$index" "row $fr of the FR traceability table reads 'Giữ nguyên', which only a brownfield project may use (CONVENTIONS §4)"
  done < "$TMP/wf-trace"

  # 2. The SCR IDs of SRS §3, of the screen catalog and of the traceability table are the same set, and each has a page.
  while IFS= read -r id; do
    err "$index" "screen set: $id is in SRS §3 but not in the screen catalog (CONVENTIONS §4)"
  done < <(comm -23 "$TMP/wf-srs-scr" "$TMP/wf-cat-scr")
  while IFS= read -r id; do
    err "$index" "screen set: $id is in the screen catalog but not in SRS §3 (CONVENTIONS §4)"
  done < <(comm -13 "$TMP/wf-srs-scr" "$TMP/wf-cat-scr")
  while IFS= read -r id; do
    err "$index" "screen set: $id is in SRS §3 but no row of the traceability table names it (CONVENTIONS §4)"
  done < <(comm -23 "$TMP/wf-srs-scr" "$TMP/wf-trace-scr")
  while IFS= read -r id; do
    err "$index" "screen set: the traceability table names $id, which SRS §3 does not list (CONVENTIONS §4)"
  done < <(comm -13 "$TMP/wf-srs-scr" "$TMP/wf-trace-scr")
  while IFS= read -r id; do
    [[ -f "$wf/$id.md" ]] && continue
    # A screen that the catalog marks "Theo luồng" is drawn in the flow mockup of the index and needs no page of its
    # own (PLAYBOOK §2.2.1); a page is required for every other screen.
    grep -E "^\| *$id *\|.*\| *Theo luồng *\|" "$index" >/dev/null && continue
    err "$index" "screen set: $id has no page docs/wireframes/$id.md and its catalog row is not marked 'Theo luồng' (CONVENTIONS §4)"
  done < <(sort -u "$TMP/wf-srs-scr" "$TMP/wf-cat-scr")
  # 2b. For each screen, the FR column of its SRS §3 row lists exactly the FRs whose traceability row names its SCR ID.
  #     A screen that no traceability row names is already reported above.
  grep -v '^#HEADER$' "$TMP/wf-trace" | while IFS=$'\t' read -r fr cell; do
    grep -oE "$SCR_RE" <<< "$cell" | awk -v f="$fr" '{ print $0 "\t" f }'
  done > "$TMP/wf-trace-scr-fr"
  while IFS= read -r id; do
    awk -F'\t' -v i="$id" '$1 == i { print $2 }' "$TMP/wf-srs-scr-fr" | sort -u | paste -sd' ' - > "$TMP/wf-set-srs"
    awk -F'\t' -v i="$id" '$1 == i { print $2 }' "$TMP/wf-trace-scr-fr" | sort -u | paste -sd' ' - > "$TMP/wf-set-trace"
    cmp -s "$TMP/wf-set-srs" "$TMP/wf-set-trace" ||
      err "$index" "FR set: SRS §3 lists FRs [$(cat "$TMP/wf-set-srs")] for $id, but the traceability rows that name $id are [$(cat "$TMP/wf-set-trace")]; the two sets are the same (CONVENTIONS §4)"
  done < <(comm -12 "$TMP/wf-srs-scr" "$TMP/wf-trace-scr")

  # 2c. UI/UX standards (CONVENTIONS §10), gated per file: the index by its own template_version, each page by its own.
  version_at_least "$(gate_version "$index" core/07_Wireframe_Template/00_Wireframe_Index_Template.md)" 1.2.0 && check_ux_index "$index"
  local page_wcag_level; page_wcag_level="$(wcag_level "$dir")"

  for page in "$wf"/SCR-*.md; do
    [[ -f "$page" ]] || continue
    id="$(basename "$page" .md)"
    version_at_least "$(gate_version "$page" core/07_Wireframe_Template/SCR_Screen_Template.md)" 1.2.0 && check_ux_page "$page" "$page_wcag_level"
    version_at_least "$(gate_version "$page" core/07_Wireframe_Template/SCR_Screen_Template.md)" 1.5.0 && check_experience_page "$page"
    grep -oE "\b$FR_RE\b" "$page" | sort -u > "$TMP/wf-page-fr"
    # 3. A page cites at least one FR of the SRS and only FRs that exist; every AC it cites is in SRS §8 and belongs to
    #    an FR the page cites; the screen catalog lists the page.
    grep -qxF -f "$TMP/wf-srs-fr" "$TMP/wf-page-fr" ||
      err "$page" "wireframe page cites no FR of SRS §6.1 (CONVENTIONS §4)"
    while IFS= read -r fr; do
      grep -qxF -- "$fr" "$TMP/wf-scope-fr" || err "$page" "wireframe page cites $fr, which no SRS in the example's scope defines (CONVENTIONS §4)"
    done < "$TMP/wf-page-fr"
    while IFS= read -r ac; do
      fr="$(awk -F'\t' -v a="$ac" '$2 == a { print $1; exit }' "$TMP/wf-ac-fr")"
      if [[ -z "$fr" ]]; then
        err "$page" "wireframe page cites $ac, which SRS §8 does not define (CONVENTIONS §4)"
      elif ! grep -qxF -- "$fr" "$TMP/wf-page-fr"; then
        err "$page" "wireframe page cites $ac of $fr, but the page does not cite $fr (CONVENTIONS §4)"
      fi
    done < <(grep -oE "\b$AC_RE\b" "$page" | sort -u)
    grep -qxF -- "$id" "$TMP/wf-cat-scr" || err "$page" "wireframe page $id is not listed in the screen catalog of the index (CONVENTIONS §4)"
    # 4. A page has a table row for each of the five UI states (a state that does not apply says N/A with a reason).
    for state in Initial Loading Empty Success Error; do
      grep -qE "^\| *\`?$state\`? *\|" "$page" ||
        err "$page" "wireframe page has no row for UI state $state; list Initial, Loading, Empty, Success and Error (PLAYBOOK §2.2.1)"
    done
  done

  # 5. Every HTML wireframe that the index or a page references exists.
  while IFS=: read -r page ref; do
    [[ -f "$wf/${ref#docs/wireframes/}" ]] || err "$page" "references HTML wireframe $ref, which does not exist (CONVENTIONS §7)"
  done < <(grep -oHE '(docs/wireframes/)?html/[A-Za-z0-9_.-]+\.html' "$index" "$wf"/SCR-*.md 2>/dev/null | sort -u)
  # 6. HTML wireframes are inert (every *.html under docs/wireframes/). Each file is read as one string, so a tag or an
  #    attribute split over lines is still seen: no script tag, event handler, iframe, object, embed, base or link tag,
  #    submitting form, @import, meta refresh or javascript: URL; every src, href, srcset, url() and image-set() (image(),
  #    src()) target is a sibling SCR-*.html (with an optional #fragment), a #fragment or a data: image; and a
  #    Content-Security-Policy meta tag inside <head> whose content is exactly the policy of CONVENTIONS §7.
  while IFS= read -r html; do
    check_html_wireframe "$html"
  done < <(find "$wf" -type f -name '*.html' 2>/dev/null | sort)
  true
}

# release_fr_table <example-dir>: "<FR ID>\t<Bản phát hành>" of every FR row in SRS §6.1 of the example (master and
# modules pooled, backticks removed), written to $TMP/rp-fr-release.
release_fr_table() {
  local srs
  : > "$TMP/rp-fr-release"
  for srs in "$1"/docs/srs/*.md; do
    [[ -f "$srs" ]] && table_pair "$srs" '^### 6\.1\.' 'FR ID' 'Bản phát hành' | grep -E "^$FR_RE"$'\t' | tr -d '`' >> "$TMP/rp-fr-release"
  done
  true
}

# spec_frs <spec-file>: the FR IDs that SPEC §1.5 names, one per line, sorted and unique.
spec_frs() { table_pair "$1" '^### 1\.5\.' 'FR ID' 'FR ID' | cut -f1 | grep -oE "\b$FR_RE\b" | sort -u; }

# check_spec_releases <example-dir>: the SPEC release rule of CONVENTIONS §3, checked at Gate 3 without any plan
# (PLAYBOOK §2.4). Gated: the project's Intake lists core/00_Project_Intake_Template.md at 1.3.0 or later in
# assembled_from. A SPEC with a release key (SPEC template 1.2.0) names in §1.5 only FRs whose Bản phát hành in SRS §6.1
# equals the key; an FR whose release SRS §6.1 of the example does not give is left to the SPEC §1.5 rule of
# check_crossdoc. A superseded SPEC is skipped: its FRs may have moved to a SPEC of another release (PLAYBOOK §8). A SPEC
# without the key stays valid when it comes from a SPEC template older than 1.2.0; one that gates at 1.2.0 or later
# (gate_version, CONVENTIONS §3) MUST carry the key.
check_spec_releases() {
  local dir="$1" spec release fr rel
  [[ -f "$dir/docs/intake/PROJECT_INTAKE.md" ]] &&
    version_at_least "$(gate_version "$dir/docs/intake/PROJECT_INTAKE.md" core/00_Project_Intake_Template.md)" 1.3.0 || return 0
  release_fr_table "$dir"
  for spec in "$dir"/docs/specs/*.md; do
    [[ -f "$spec" ]] || continue
    [[ "$(frontmatter_value "$spec" status)" == superseded ]] && continue
    release="$(frontmatter_value "$spec" release)"
    if [[ -z "$release" ]]; then
      version_at_least "$(gate_version "$spec" core/04_Spec_Core_Template.md)" 1.2.0 &&
        err "$spec" "SPEC made from SPEC template 1.2.0 or later has no release key; the Intake is 1.3.0 or later, so the SPEC should name its release (CONVENTIONS §3)"
      continue
    fi
    while IFS= read -r fr; do
      rel="$(awk -F'\t' -v f="$fr" '$1 == f { print $2; exit }' "$TMP/rp-fr-release")"
      [[ -z "$rel" || "$rel" == "$release" ]] ||
        err "$spec" "SPEC release is '$release', but §1.5 names $fr, whose release in SRS §6.1 is '$rel'; every FR of the SPEC belongs to its release (CONVENTIONS §3)"
    done < <(spec_frs "$spec")
  done
  true
}

# check_release_plans <example-dir>: the release plan rules of CONVENTIONS §9. Gated: they apply to a plan whose plan.md
# lists core/05_Implementation_Plan_Template/plan.md at 1.2.0 or later in assembled_from. Whether every FR of the release
# has a SPEC is left to the Gate 3 reviewer (PLAYBOOK §2.4). A project whose Intake predates template 1.3.0 keeps one plan
# per SPEC and its SPECs are not scoped to a release, so the FR release-consistency rule (4) applies only from Intake 1.3.0.
check_release_plans() {
  local dir="$1" plan_dir plan release id spec phase fr rel line prev state srel by_release=0
  [[ -f "$dir/docs/intake/PROJECT_INTAKE.md" ]] &&
    version_at_least "$(gate_version "$dir/docs/intake/PROJECT_INTAKE.md" core/00_Project_Intake_Template.md)" 1.3.0 &&
    by_release=1
  release_fr_table "$dir"
  : > "$TMP/rp-specs"
  # One line per SPEC: spec_id, status, path, release key (last, since it may be empty).
  for spec in "$dir"/docs/specs/*.md; do
    [[ -f "$spec" ]] && printf '%s\t%s\t%s\t%s\n' "$(frontmatter_value "$spec" spec_id)" "$(frontmatter_value "$spec" status)" "$spec" "$(frontmatter_value "$spec" release)" >> "$TMP/rp-specs"
  done
  local pv
  for plan_dir in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do
    plan="${plan_dir}plan.md"
    [[ -f "$plan" ]] || continue
    pv="$(gate_version "$plan" core/05_Implementation_Plan_Template/plan.md)"
    # Plan template 1.3.0 or later requires a Version History section (CONVENTIONS §9).
    if version_at_least "$pv" 1.3.0 && ! grep -qE '^#+ .*Version History' "$plan"; then
      err "$plan" "plan made from plan template 1.3.0 or later has no 'Version History' section (CONVENTIONS §9)"
    fi
    version_at_least "$pv" 1.2.0 || continue
    release="$(frontmatter_value "$plan" release)"
    frontmatter_list "$plan" spec_ids > "$TMP/rp-ids"
    [[ -n "$release" ]] || err "$plan" "release plan has no release key (CONVENTIONS §9)"
    [[ -s "$TMP/rp-ids" ]] || err "$plan" "release plan has no spec_ids (CONVENTIONS §9)"
    # 1. Every element of spec_ids is the spec_id of a SPEC in docs/specs/.
    while IFS= read -r id; do
      cut -f1 "$TMP/rp-specs" | grep -qxF -- "$id" || err "$plan" "spec_ids lists $id, which is the spec_id of no SPEC in docs/specs/ (CONVENTIONS §9)"
    done < "$TMP/rp-ids"
    # 2. Every phase has a spec_id from spec_ids, and every element of spec_ids has at least one phase. The phases of one
    #    SPEC stand together: in phase order, the spec_id never returns to a SPEC after leaving it.
    : > "$TMP/rp-phase-ids"; prev=""
    for phase in "$plan_dir"phase-*.md; do
      [[ -f "$phase" ]] || continue
      id="$(frontmatter_value "$phase" spec_id)"
      grep -qxF -- "$id" "$TMP/rp-ids" || err "$phase" "phase spec_id '$id' is not in the spec_ids of plan.md (CONVENTIONS §9)"
      [[ -n "$prev" && "$id" != "$prev" ]] && grep -qxF -- "$id" "$TMP/rp-phase-ids" &&
        err "$phase" "phase of $id follows a phase of $prev, but an earlier phase is also of $id; the phases of one SPEC stand together (CONVENTIONS §9)"
      printf '%s\n' "$id" >> "$TMP/rp-phase-ids"
      prev="$id"
    done
    while IFS= read -r id; do
      grep -qxF -- "$id" "$TMP/rp-phase-ids" || err "$plan" "spec_ids lists $id, but no phase has spec_id $id (CONVENTIONS §9)"
    done < "$TMP/rp-ids"
    # 3. Every SPEC of spec_ids that has a release key (SPEC template 1.2.0) has the plan's release.
    while IFS=$'\t' read -r id state spec srel; do
      grep -qxF -- "$id" "$TMP/rp-ids" || continue
      [[ -z "$srel" || -z "$release" || "$srel" == "$release" ]] ||
        err "$spec" "$id is in the spec_ids of ${plan#"$dir"/}, but its release key is '$srel', not '$release' (CONVENTIONS §9)"
    done < "$TMP/rp-specs"
    # 4. From Intake 1.3.0: every FR that a SPEC of spec_ids names in §1.5 belongs to the plan's release; a SPEC outside
    #    spec_ids that is not superseded names no FR of the release. FRs that SRS §6.1 of the example does not define are
    #    left to the SPEC §1.5 rule of check_crossdoc. A SPEC of spec_ids with a release key is skipped: rule 3 and
    #    check_spec_releases already cover its FRs, so one wrong FR is reported once.
    ((by_release)) || continue
    while IFS=$'\t' read -r id state spec srel; do
      grep -qxF -- "$id" "$TMP/rp-ids" && [[ -n "$srel" ]] && continue
      while IFS= read -r fr; do
        line="$(awk -F'\t' -v f="$fr" '$1 == f { print "=" $2; exit }' "$TMP/rp-fr-release")"
        [[ -n "$line" ]] || continue
        rel="${line#=}"
        if grep -qxF -- "$id" "$TMP/rp-ids"; then
          [[ "$rel" == "$release" ]] || err "$spec" "$id is in the spec_ids of ${plan#"$dir"/} but names $fr in §1.5, whose release is '$rel', not '$release' (CONVENTIONS §9)"
        elif [[ "$state" != superseded && -n "$release" && "$rel" == "$release" ]]; then
          err "$spec" "$id names $fr of release $release in §1.5 but is not in the spec_ids of ${plan#"$dir"/} (CONVENTIONS §9)"
        fi
      done < <(spec_frs "$spec")
    done < "$TMP/rp-specs"
  done
  true
}

run_examples() {
  local files hit file doc_type
  mapfile -t files < <(find examples -type f ! -name '.gitkeep' 2>/dev/null | sort)
  if ((${#files[@]} == 0)); then
    warn "examples/" "no worked example yet"
    return 0
  fi
  while IFS= read -r hit; do
    err "$(location "$hit")" "unfilled template marker in a worked example"
  done < <(grep -nHE "$PLACEHOLDER_RE|<!-- (fill[ :-]|slot-hint)|^<!-- (SLOT|PROFILE-SLOT|/?SLOT-CONTENT|/?PROFILE-CONTENT)" "${files[@]}")
  mapfile -t files < <(markdown_files examples)
  ((${#files[@]})) || return 0
  check_frontmatter "${files[@]}"
  check_required_sections "${files[@]}"
  for file in "${files[@]}"; do
    doc_type="$(frontmatter_value "$file" doc_type)"
    is_document_type "$doc_type" || continue
    frontmatter_has_items "$file" assembled_from || err "$file" "generated document must list assembled_from sources"
    [[ "$doc_type" == intake ]] || frontmatter_has_items "$file" parent || err "$file" "generated document must list parent documents"
  done
  check_assembled_from "${files[@]}"
  check_status_values "${files[@]}"
  check_profile_listed "${files[@]}"
  check_pattern_notation $(printf '%s\n' "${files[@]}" | grep -v '/README\.md$')
  check_links relaxed "${files[@]}"
  while IFS= read -r file; do
    check_layout_block "$file"
  done < <(find examples -type f -name 'CLAUDE.md' | sort)
  for file in examples/*/*/; do
    load_plan_dirs "${file%/}"
    [[ -d "$file/docs" ]] && check_example_consistency "${file%/}"
    [[ -d "$file/docs/srs" ]] && check_srs_requirements "${file%/}"
    [[ -d "$file/docs" ]] && check_crossdoc "${file%/}"
    [[ -d "$file/docs" ]] && check_wireframes "${file%/}"
    [[ -d "$file/docs" ]] && check_design_system "${file%/}"
    [[ -d "$file/docs" ]] && check_design_tokens "${file%/}"
    [[ -d "$file/docs" ]] && check_roadmap "${file%/}"
    [[ -d "$file/docs" ]] && check_spec_releases "${file%/}"
    [[ -d "$file/plans" ]] && check_release_plans "${file%/}"
    [[ -d "$file/docs" ]] && check_project_docs "${file%/}"
  done
}

# check_project_docs <dir>: table shape, IDs and numbers held by more than one place, a stale docs/INDEX.md, companion
# files and the size limits of CONVENTIONS §7, found by scripts/check-project-docs.py.
check_project_docs() {
  local dir="$1" out status line
  if ! command -v python3 >/dev/null 2>&1; then
    warn "$dir" "no python3; table shape, duplicate IDs and the index not validated"
    return 0
  fi
  out="$(cd "$dir" && python3 "$ROOT/scripts/check-project-docs.py" . 2>&1)"
  status=$?
  if ((status != 0)); then
    err "$dir" "project documents helper failed (exit $status)"
    return 0
  fi
  while IFS= read -r line; do
    case "$line" in
      "ERROR "*) line="${line#ERROR }"; err "$dir/${line%%: *}" "${line#*: }" ;;
      "WARN "*) line="${line#WARN }"; warn "$dir/${line%%: *}" "${line#*: }" ;;
      "") ;;
      *) err "$dir" "project documents helper printed an unexpected line" ;;
    esac
  done <<< "$out"
}

# load_plan_dirs <dir>: PLAN_DIRS = the plan folders of the example or project, each with a trailing slash. A project
# may keep plans of other tools beside its kit plans, so in project mode a folder counts only when a markdown file in
# it carries the frontmatter of a kit plan or phase (also a damaged one: CRLF line ends, "_" for "-"); SKIPPED_PLANS
# counts the folders left out.
PLAN_DIRS=()
SKIPPED_PLANS=0
load_plan_dirs() {
  local plan_dir
  PLAN_DIRS=()
  SKIPPED_PLANS=0
  for plan_dir in "$1"/plans/*/; do
    [[ -d "$plan_dir" ]] || continue
    if [[ -n "$PROJECT" ]] && ! grep -lE '^doc_type: *"?implementation[-_](plan|phase)' "$plan_dir"*.md >/dev/null 2>&1; then
      compgen -G "${plan_dir}*.md" >/dev/null && SKIPPED_PLANS=$((SKIPPED_PLANS + 1))
      continue
    fi
    PLAN_DIRS+=("$plan_dir")
  done
}

# project_files: the kit documents of the project, sorted. Reports, notes and any other markdown the project keeps
# beside them are not kit documents and are left alone.
project_files() {
  local file
  {
    existing "$PROJECT/CLAUDE.md" "$PROJECT/docs/ARCHITECTURE.md" "$PROJECT/docs/ROADMAP.md"
    markdown_files "$PROJECT"/docs/{intake,srs,wireframes,design-system,architecture,adr,specs,prompts,brownfield}
    for file in ${PLAN_DIRS[@]+"${PLAN_DIRS[@]}"}; do existing "${file}plan.md" "$file"phase-*.md; done
    # A kit document kept outside the folders above is still a kit document.
    grep -rlE '^doc_type: ' --include='*.md' "$PROJECT/docs" "$PROJECT/.claude/rules" 2>/dev/null
  } | sort -u
}

# run_project: the checks of run_examples on one real project.
run_project() {
  local files companions hit file doc_type
  load_plan_dirs "$PROJECT"
  ((SKIPPED_PLANS)) && warn "$PROJECT/plans" "$SKIPPED_PLANS folder(s) hold no kit plan or phase frontmatter and were not checked"
  mapfile -t files < <(project_files)
  if ((${#files[@]} == 0)); then
    warn "$PROJECT" "no kit document found"
    return 0
  fi
  # A companion file starts from a kit skeleton too, so it is scanned for markers with the documents.
  mapfile -t companions < <(companion_files "$PROJECT/docs/specs"; companion_files "$PROJECT/docs/architecture")
  while IFS= read -r hit; do
    err "$(location "$hit")" "unfilled template marker"
  done < <(grep -nHE "$PLACEHOLDER_RE|<!-- (fill[ :-]|slot-hint)|^<!-- (SLOT|PROFILE-SLOT|/?SLOT-CONTENT|/?PROFILE-CONTENT)" "${files[@]}" ${companions[@]+"${companions[@]}"})
  check_frontmatter "${files[@]}"
  check_required_sections "${files[@]}"
  for file in "${files[@]}"; do
    doc_type="$(frontmatter_value "$file" doc_type)"
    is_document_type "$doc_type" || continue
    frontmatter_has_items "$file" assembled_from || err "$file" "generated document must list assembled_from sources"
    [[ "$doc_type" == intake ]] || frontmatter_has_items "$file" parent || err "$file" "generated document must list parent documents"
  done
  check_assembled_from "${files[@]}"
  check_status_values "${files[@]}"
  check_profile_listed "${files[@]}"
  # check_pattern_notation is left out: it guards text the kit copies into documents, and a real document may write
  # "<id>" in prose.
  check_links relaxed "${files[@]}"
  [[ -f "$PROJECT/CLAUDE.md" ]] && check_layout_block "$PROJECT/CLAUDE.md"
  check_example_consistency "$PROJECT"
  [[ -d "$PROJECT/docs/srs" ]] && check_srs_requirements "$PROJECT"
  check_crossdoc "$PROJECT"
  check_wireframes "$PROJECT"
  check_design_system "$PROJECT"
  check_design_tokens "$PROJECT"
  check_roadmap "$PROJECT"
  check_spec_releases "$PROJECT"
  [[ -d "$PROJECT/plans" ]] && check_release_plans "$PROJECT"
  check_project_docs "$PROJECT"
}

load_catalogs || { printf '\ncheck-templates (%s): %d error(s), %d warning(s)\n' "$MODE" "$ERRORS" "$WARNINGS"; exit 1; }
case "$MODE" in
  examples) run_examples ;;
  project) run_project ;;
  *) run_templates ;;
esac

printf '\ncheck-templates (%s): %d error(s), %d warning(s)\n' "$MODE" "$ERRORS" "$WARNINGS"
((ERRORS == 0))
