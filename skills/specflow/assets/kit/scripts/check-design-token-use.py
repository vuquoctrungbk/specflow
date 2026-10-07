#!/usr/bin/env python3
"""Check how a project uses its design tokens: the contrast table and the HTML wireframes (CONVENTIONS section 10.7).

Usage:
  check-design-token-use.py --tiers TIERS --root DIR --doc DESIGN_SYSTEM.md [--modes MODES] [--contrast ROWS] [--html PAGES]

scripts/check-templates.sh reads the tables of DESIGN_SYSTEM.md and the frontmatter of the pages and hands over tab
separated files; this script does the parts that need the token values.
  TIERS     the tier groups, lowest first (one per line); the tiers after the first are the ones HTML may use.
  MODES     "<mode name>\t<token file>\t<applies when>" per row of the Mode table (files relative to DIR).
  ROWS      "<n>\t<fg token>\t<bg token>\t<text token>\t<mode>\t<kind>\t<ratio>\t<threshold>" per row of the contrast table.
  PAGES     "<html file>\t<surfaces of the page, comma separated>" per HTML wireframe of a page from screen template 1.4.0.

Contrast: WCAG 2.2 relative luminance from the hex of each token in the row's mode; the ratio is rounded down to two
digits and compared as a number. Large text comes from the typography token of the row (fontSize from 24px, or from
18.66px with fontWeight from 700; 1rem is 16px). HTML: variables declared in :root match semantic or component tokens of
the mode that applies to the page, and no declaration outside :root writes a raw color, spacing, radius or font size.

Error contract as scripts/check-design-tokens.py: "ERROR <file>: <message>" lines, exit status 0 even with findings.
"""
import argparse
import importlib.util
import math
import os
import re
import sys
from decimal import Decimal, InvalidOperation

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("check_design_tokens", os.path.join(HERE, "check-design-tokens.py"))
tokens_lib = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(tokens_lib)

HEX_RE = tokens_lib.HEX_RE
ALIAS_DEPTH = 20
DEFAULT_TOKEN_FILE = "tokens.json"
DARK_TOKEN_FILE = "tokens.dark.json"
KIND_TEXT, KIND_NON_TEXT, NO_TEXT_TOKEN = "chữ", "phi văn bản", "Không"
SMALL_TEXT_MIN, LARGE_TEXT_MIN = Decimal("4.5"), Decimal("3")
LARGE_PX, LARGE_BOLD_PX, BOLD_WEIGHT, REM_PX = 24, 18.66, 700, 16
KEYWORDS = ("0", "auto", "100%", "inherit", "initial", "unset")
COLOR_RE = re.compile(r"#[0-9a-fA-F]{3,8}\b|\b(?:rgba?|hsla?|oklch|oklab)\s*\(", re.I)
SPACING_RE = re.compile(r"^(?:(?:margin|padding|inset)(?:-[a-z-]+)?|gap|row-gap|column-gap|grid-gap|top|right|bottom|left)$")
RADIUS_RE = re.compile(r"^border(?:-[a-z]+)*-radius$")
FONT_LENGTH_RE = re.compile(r"^(?:-?[0-9.]+(?:px|rem|em|pt|pc|cm|mm|in|ex|ch|vw|vh|vmin|vmax|%)|xx-small|x-small|small|medium|large|x-large|xx-large|smaller|larger)$", re.I)
DARK_RE = re.compile(r"prefers-color-scheme\s*:\s*dark", re.I)
VAR_RE = re.compile(r"var\(\s*(--[A-Za-z0-9_-]+)")
DIMENSION_RE = re.compile(r"^(-?[0-9]*\.?[0-9]+)(px|rem)$")


def read_tsv(path):
    if not path or not os.path.isfile(path):
        return []
    with open(path, encoding="utf-8") as handle:
        return [line.rstrip("\n").split("\t") for line in handle if line.strip()]


def show(path):
    return ".".join(path)


class TokenSets:
    """The tokens of every mode: tokens.json (the default mode), and each mode file laid over it."""

    def __init__(self, root, mode_rows):
        self.modes = []  # (name, path, applies-when)
        for name, file, applies in ([row + [""] * (3 - len(row)) for row in mode_rows]):
            self.modes.append((name, os.path.join(root, file), applies))
        if not any(os.path.basename(path) == DEFAULT_TOKEN_FILE for _, path, _ in self.modes):
            self.modes.insert(0, ("", os.path.join(root, "docs", "design-system", DEFAULT_TOKEN_FILE), ""))
        self.docs = {}
        for name, path, _ in self.modes:
            self.docs[name] = self.load(path)
        self.default_name = next(n for n, p, _ in self.modes if os.path.basename(p) == DEFAULT_TOKEN_FILE)

    @staticmethod
    def load(path):
        """The parsed Doc of a token file, or None when it is missing or not usable (the token rules report why)."""
        if not os.path.isfile(path):
            return None
        findings = tokens_lib.Findings(path)
        root = tokens_lib.load(path, findings)
        if root is None:
            return None
        doc = tokens_lib.Doc(root)
        tokens_lib.walk(doc, root, (), findings)
        return doc

    def known(self, name):
        return name in self.docs

    def usable(self):
        return self.docs.get(self.default_name) is not None

    def tokens(self, name, over=None):
        """path -> token node of a mode: the default tokens, then the mode's own, then those of a second mode (dark)."""
        merged = dict(self.docs[self.default_name].tokens)
        for layer in (name, over):
            if layer is not None and layer != self.default_name and self.docs.get(layer) is not None:
                merged.update(self.docs[layer].tokens)
        return merged

    def dark_name(self):
        return next((n for n, p, _ in self.modes if os.path.basename(p) == DARK_TOKEN_FILE and self.docs.get(n)), None)

    def mode_for_surfaces(self, surfaces):
        for name, path, applies in self.modes:
            if name != self.default_name and any(s and s in applies for s in surfaces):
                return name
        return self.default_name


def resolve(tokens, path, depth=0):
    """The value of a token with every alias inside it followed; None when an alias leads nowhere or loops."""
    node = tokens.get(path)
    if node is None or depth > ALIAS_DEPTH:
        return None
    return deep(tokens, node["$value"], depth + 1)


def deep(tokens, value, depth):
    if isinstance(value, dict):
        out = {}
        for key, item in value.items():
            out[key] = deep(tokens, item, depth)
            if out[key] is None:
                return None
        return out
    if isinstance(value, list):
        return value
    target = tokens_lib.alias_target(value)
    if target is not None:
        return resolve(tokens, target, depth)
    return value


# -- contrast ---------------------------------------------------------------------------------------------------------
def channel(value):
    value /= 255
    return value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4


def luminance(hex_value):
    red, green, blue = (int(hex_value[i:i + 2], 16) for i in (1, 3, 5))
    return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)


def ratio_hundredths(first, second):
    """The contrast ratio of two hex colors, rounded down to two digits, as an integer count of hundredths."""
    high, low = sorted((luminance(first), luminance(second)), reverse=True)
    return math.floor((high + 0.05) / (low + 0.05) * 100 + 1e-9)


def number(text):
    try:
        return Decimal(text.strip().replace(",", "."))
    except InvalidOperation:
        return None


def text_size(value):
    """(size in px, weight) of a resolved typography value, or None when it has no readable fontSize."""
    size = value.get("fontSize") if isinstance(value, dict) else None
    if not isinstance(size, dict) or not tokens_lib.is_number(size.get("value")):
        return None
    px = size["value"] * (REM_PX if size.get("unit") == "rem" else 1)
    weight = value.get("fontWeight", 400)
    weight = {"normal": 400, "bold": 700}.get(weight, weight)
    return px, weight if tokens_lib.is_number(weight) else 400


def check_contrast(findings, sets, rows):
    for n, fg, bg, text, mode, kind, written, threshold in ([r + [""] * (8 - len(r)) for r in rows]):
        where = f"contrast row {n} ({fg} on {bg}, mode {mode})"
        if not sets.known(mode):
            findings.error(f"{where}: the mode is not in the Mode table")
            continue
        tokens = sets.tokens(mode)
        hexes = {}
        for token in (fg, bg):
            value = resolve(tokens, tuple(token.split(".")))
            if not isinstance(value, dict) or not isinstance(value.get("hex"), str) or not HEX_RE.match(value["hex"]):
                findings.error(f"{where}: {token} does not resolve to a color with a hex in this mode")
            elif tokens_lib.is_number(value.get("alpha")) and value["alpha"] < 1:
                findings.error(f"{where}: {token} has alpha {value['alpha']}; use an opaque color, the ratio of a translucent color depends on what is behind it")
            else:
                hexes[token] = value["hex"]
        needed = SMALL_TEXT_MIN
        if kind == KIND_TEXT:
            typography = resolve(tokens, tuple(text.split("."))) if text != NO_TEXT_TOKEN else None
            size = text_size(typography)
            if size is None:
                findings.error(f"{where}: a '{KIND_TEXT}' row needs a typography token with a fontSize in the Token chữ column, to tell large text from small text")
                continue
            large = size[0] >= LARGE_PX or (size[0] >= LARGE_BOLD_PX and size[1] >= BOLD_WEIGHT)
            needed = LARGE_TEXT_MIN if large else SMALL_TEXT_MIN
        elif kind == KIND_NON_TEXT:
            needed = LARGE_TEXT_MIN
            if text != NO_TEXT_TOKEN:
                findings.error(f"{where}: a '{KIND_NON_TEXT}' row writes {NO_TEXT_TOKEN} in the Token chữ column")
        else:
            findings.error(f"{where}: the kind '{kind}' is neither '{KIND_TEXT}' nor '{KIND_NON_TEXT}'")
            continue
        if len(hexes) < 2:
            continue
        computed = Decimal(ratio_hundredths(hexes[fg], hexes[bg])) / 100
        stated = number(written)
        if stated is None:
            findings.error(f"{where}: the ratio '{written}' is not a number")
        elif stated != computed:
            findings.error(f"{where}: computed ratio {computed:.2f} but the table says {written}; write the computed ratio rounded down to two digits")
        limit = number(threshold)
        if limit is None:
            findings.error(f"{where}: the threshold '{threshold}' is not a number")
        elif limit < needed:
            findings.error(f"{where}: the threshold {threshold} is lower than the {needed:g} that applies to this row")
        if computed < max(needed, limit or needed):
            findings.error(f"{where}: ratio {computed:.2f} is below the threshold {max(needed, limit or needed):g}")


# -- CSS ---------------------------------------------------------------------------------------------------------------
def split_statements(text):
    """Top-level pieces of CSS text: ("block", prelude, body) for "x { ... }" and ("stmt", text) for "x;" or a last x."""
    out, start, depth, paren, quote, i, body_start, prelude = [], 0, 0, 0, None, 0, 0, ""
    while i < len(text):
        char = text[i]
        if quote:
            if char == "\\":
                i += 1
            elif char == quote:
                quote = None
        elif char in "\"'":
            quote = char
        elif char == "(":
            paren += 1
        elif char == ")":
            paren = max(0, paren - 1)
        elif char == "{":
            if depth == 0:
                prelude, body_start = text[start:i].strip(), i + 1
            depth += 1
        elif char == "}" and depth > 0:
            depth -= 1
            if depth == 0:
                out.append(("block", prelude, text[body_start:i]))
                start = i + 1
        elif char == ";" and depth == 0 and paren == 0:
            out.append(("stmt", text[start:i].strip()))
            start = i + 1
        i += 1
    if text[start:].strip() and depth == 0:
        out.append(("stmt", text[start:].strip()))
    return out


def value_parts(value):
    """A value split at spaces and slashes outside parentheses and quotes."""
    parts, current, paren, quote = [], "", 0, None
    for char in value:
        if quote:
            current += char
            quote = None if char == quote else quote
        elif char in "\"'":
            current += char
            quote = char
        elif char == "(":
            paren += 1
            current += char
        elif char == ")":
            paren = max(0, paren - 1)
            current += char
        elif paren == 0 and (char.isspace() or char == "/"):
            if current:
                parts.append(current)
            current = ""
        else:
            current += char
    if current:
        parts.append(current)
    return parts


def scrub(value):
    """A value without strings and url(...) contents, so a fragment id or a quoted text is not read as a color."""
    value = re.sub(r"\"[^\"]*\"|'[^']*'", "''", value)
    return re.sub(r"url\([^)]*\)", "url()", value, flags=re.I)


class Css:
    """Declarations of one HTML file: custom properties declared, var() references, :root variables, raw values."""

    def __init__(self):
        self.declared, self.refs, self.root_vars, self.raw = set(), [], [], []

    def declaration(self, name, value, in_root, dark):
        value = re.sub(r"\s*!important\s*$", "", value.strip(), flags=re.I)
        self.refs += VAR_RE.findall(value)
        if name.startswith("--"):
            self.declared.add(name)
        if in_root:
            if name.startswith("--"):
                self.root_vars.append((name, value, dark))
            return
        plain = scrub(value)
        match = COLOR_RE.search(plain)
        if match:
            self.raw.append(f"raw color '{match.group(0).strip()}' in the value of '{name}'; write var(--…) of a color token")
        if SPACING_RE.match(name) or RADIUS_RE.match(name) or name == "font-size":
            bad = [p for p in value_parts(plain) if not (p.startswith("var(") and p.endswith(")")) and p not in KEYWORDS]
            if bad:
                self.raw.append(f"property {name} has the raw value '{value}'; write var(--…) or one of {', '.join(KEYWORDS)}")
        elif name == "font":
            bad = [p for p in value_parts(plain) if FONT_LENGTH_RE.match(p) and p not in KEYWORDS]
            if bad:
                self.raw.append(f"property font has the raw font size '{bad[0]}'; write the size as font-size: var(--…)")

    def walk(self, text, in_rule=False, in_root=False, dark=False):
        for item in split_statements(text):
            if item[0] == "block":
                prelude, body = item[1], item[2]
                if prelude.startswith("@"):
                    rule_body = prelude.lower() in ("@font-face", "@page")
                    self.walk(body, rule_body, False, dark or bool(DARK_RE.search(prelude)))
                else:
                    root = any(part.strip() == ":root" for part in prelude.split(","))
                    self.walk(body, True, root, dark)
            elif in_rule and ":" in item[1] and not item[1].startswith("@"):
                name, value = item[1].split(":", 1)
                self.declaration(name.strip().lower(), value, in_root, dark)


def read_css(html):
    css = Css()
    for style in re.findall(r"<style[^>]*>(.*?)</style>", html, flags=re.S | re.I):
        css.walk(re.sub(r"/\*.*?\*/", "", style, flags=re.S))
    for match in re.finditer(r"\sstyle\s*=\s*(?:\"([^\"]*)\"|'([^']*)')", html, flags=re.I):
        css.walk(match.group(1) if match.group(1) is not None else match.group(2), in_rule=True)
    return css


# -- HTML --------------------------------------------------------------------------------------------------------------
def css_names(sets, tiers):
    """CSS variable name -> token path, for the tokens of the tiers HTML may use, and for the ones it may not."""
    allowed, refused = {}, {}
    for path in sets.docs[sets.default_name].tokens:
        if len(path) < 2 or path[0] not in tiers:
            continue
        (allowed if path[0] in tiers[1:] else refused)["--" + "-".join(path[1:])] = path
    return allowed, refused


def normalize_hex(text):
    text = text.strip().lower()
    if re.fullmatch(r"#[0-9a-f]{3}", text):
        text = "#" + "".join(c * 2 for c in text[1:])
    return text


def value_differs(value, expected):
    """A message tail when the declared text is not the token's value; None when it is the value or not comparable."""
    if isinstance(expected, dict) and isinstance(expected.get("hex"), str):
        return None if normalize_hex(value) == expected["hex"].lower() else expected["hex"]
    if isinstance(expected, dict) and tokens_lib.is_number(expected.get("value")) and expected.get("unit") in ("px", "rem"):
        wanted = f"{expected['value']:g}{expected['unit']}"
        match = DIMENSION_RE.match(value.strip())
        if match and Decimal(match.group(1)) == Decimal(str(expected["value"])) and match.group(2) == expected["unit"]:
            return None
        return wanted
    return None


def check_html(findings, sets, tiers, surfaces):
    try:
        with open(findings.path, encoding="utf-8") as handle:
            css = read_css(handle.read())
    except (OSError, UnicodeDecodeError) as error:
        findings.error(f"the HTML file cannot be read ({type(error).__name__})")
        return
    allowed, refused = css_names(sets, tiers)
    mode = sets.mode_for_surfaces(surfaces)
    dark = sets.dark_name()
    for name in sorted({ref for ref in css.refs if ref not in css.declared}):
        findings.error(f"var({name}) is not declared in the file; declare it in :root from a token")
    for name, value, in_dark in css.root_vars:
        path = allowed.get(name)
        if path is None:
            if name in refused:
                findings.error(f"variable {name} is the primitive token {show(refused[name])}; HTML declares only semantic and component tokens")
            else:
                findings.error(f"variable {name} matches no semantic or component token; the name is the token path without the tier group")
            continue
        if value.startswith("var("):
            continue
        if in_dark and dark is None:
            continue
        label = dark if in_dark else mode
        expected = resolve(sets.tokens(mode, dark if in_dark else None), path)
        wanted = value_differs(value, expected)
        if wanted is not None:
            findings.error(f"variable {name} is {value} but the token {show(path)} has {wanted} in mode {label or 'default'}")
    for message in css.raw:
        findings.error(message)


def main(argv):
    parser = argparse.ArgumentParser(description="Check the use of design tokens (CONVENTIONS section 10.7).")
    parser.add_argument("--tiers", required=True)
    parser.add_argument("--root", required=True)
    parser.add_argument("--doc", required=True)
    parser.add_argument("--modes")
    parser.add_argument("--contrast")
    parser.add_argument("--html")
    args = parser.parse_args(argv)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    tiers = tokens_lib.read_lines(args.tiers)
    lines = []
    try:
        sets = TokenSets(args.root, read_tsv(args.modes))
    except Exception as error:  # the inputs are checked by the token rules; a failure here is a finding, not a traceback
        print(f"ERROR {args.doc}: the token files could not be read ({type(error).__name__}: {error}){tokens_lib.SUFFIX}")
        return 0
    if not sets.usable():
        return 0
    jobs = [(args.doc, lambda f: check_contrast(f, sets, read_tsv(args.contrast)))]
    for row in read_tsv(args.html):
        surfaces = [s.strip() for s in (row[1] if len(row) > 1 else "").split(",")]
        jobs.append((row[0], lambda f, s=surfaces: check_html(f, sets, tiers, s)))
    for path, job in jobs:
        findings = tokens_lib.Findings(path)
        try:
            job(findings)
        except Exception as error:  # a file that raises is a finding about that file, never a traceback
            findings.error(f"could not be checked ({type(error).__name__}: {error})")
        lines += findings.lines
    for line in lines:
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
