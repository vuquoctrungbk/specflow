#!/usr/bin/env python3
"""Check design token files against the DTCG contract of CONVENTIONS section 10.7.

Usage:
  check-design-tokens.py --types TYPES --tiers TIERS [--template] BASE [MODE...]

TYPES and TIERS are text files written by scripts/check-templates.sh from the tables of CONVENTIONS 10.7: one DTCG type
per line, and the tier groups from the lowest tier (primitive) to the highest (component). Nothing in this script names
a type list or a tier group, except the two types whose value shape the kit checks (color and dimension).

BASE is tokens.json (or the token template with --template); each MODE is a tokens.<mode>.json file that overrides
semantic tokens of BASE. A BASE that does not exist is not reported here: the document rules report a missing tokens.json.

Error contract: one line per finding, "ERROR <file>: <message>" or "WARN <file>: <message>", each message ending with
"(CONVENTIONS §10.7)". The exit status is 0 whether or not there are findings. Every file is checked inside its own
try block, so a file that raises is reported as a finding about that file and never as a traceback. A non-zero exit
status therefore means the script itself could not run, which the caller reports as a helper failure.
"""
import argparse
import json
import os
import re
import sys

SUFFIX = " (CONVENTIONS §10.7)"
ALIAS_RE = re.compile(r"^\{([^{}]*)\}$")
HEX_RE = re.compile(r"^#[0-9a-fA-F]{6}$")
NODE_KEYS = ("$value", "$type", "$description", "$deprecated")
FORBIDDEN_KEYS = ("$ref", "$extends", "$extensions", "$root")
BAD_NAME_CHARS = "{}."
DIMENSION_UNITS = ("px", "rem")


def show(path):
    return ".".join(path) if path else "the top level"


def is_number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def leaves(value, loc=""):
    """Every scalar inside a $value with its location ("fontSize", "layers[0].color"; empty for a scalar $value)."""
    if isinstance(value, dict):
        for key, item in value.items():
            yield from leaves(item, f"{loc}.{key}" if loc else key)
    elif isinstance(value, list):
        for index, item in enumerate(value):
            yield from leaves(item, f"{loc}[{index}]")
    else:
        yield loc, value


def alias_target(leaf):
    """The path tuple of an alias {a.b.c}, or None when the leaf is not written as a whole alias."""
    if not isinstance(leaf, str):
        return None
    match = ALIAS_RE.match(leaf)
    if not match or not match.group(1):
        return None
    return tuple(match.group(1).split("."))


class Findings:
    def __init__(self, path):
        self.path = path
        self.lines = []

    def add(self, level, message):
        line = f"{level} {self.path}: {message}{SUFFIX}"
        if line not in self.lines:
            self.lines.append(line)

    def error(self, message):
        self.add("ERROR", message)


class Doc:
    """One parsed token file: its root object, the tokens (objects with $value) and groups by path tuple."""

    def __init__(self, root):
        self.root = root
        self.tokens = {}
        self.groups = {}


def read_lines(path):
    with open(path, encoding="utf-8") as handle:
        return [line.strip() for line in handle if line.strip()]


def unique_pairs(pairs):
    seen = {}
    for key, value in pairs:
        if key in seen:
            raise ValueError(f"duplicate key '{key}'")
        seen[key] = value
    return seen


def load(path, findings):
    """The parsed root object of a token file, or None after reporting why not (JSON validity, object at the top)."""
    try:
        with open(path, encoding="utf-8") as handle:
            root = json.loads(handle.read(), object_pairs_hook=unique_pairs)
    except UnicodeDecodeError as error:
        findings.error(f"token file is not valid UTF-8 text: {error.reason}")
        return None
    except ValueError as error:
        findings.error(f"token file is not valid JSON: {error}")
        return None
    if not isinstance(root, dict):
        findings.error("token file is not a JSON object at the top level")
        return None
    return root


def check_reserved_key(findings, path, key):
    """A key starting with '$' inside the group or token at path: only the four DTCG keys of the kit are allowed."""
    if key in FORBIDDEN_KEYS:
        findings.error(f"{show(path)} uses '{key}', which the kit does not use; write an alias as {{a.b.c}}")
    elif key not in NODE_KEYS:
        findings.error(f"name '{key}' in {show(path)} starts with '$'; only $value, $type, $description and $deprecated may")


def walk(doc, node, path, findings):
    """Collect tokens and groups; report names, reserved keys, members that are neither, and leaves with no $value."""
    for key, value in node.items():
        if key.startswith("$"):
            check_reserved_key(findings, path, key)
            continue
        member = path + (key,)
        if any(char in key for char in BAD_NAME_CHARS):
            findings.error(f"name '{key}' of {show(member)} contains '{{', '}}' or '.'")
        if not isinstance(value, dict):
            findings.error(f"{show(member)} is neither a token nor a group: it must be an object")
            continue
        if "$value" in value:
            doc.tokens[member] = value
            for extra in value:
                if extra.startswith("$"):
                    check_reserved_key(findings, member, extra)
                else:
                    findings.error(f"token {show(member)} has a member '{extra}' next to $value; a token has no members")
            continue
        doc.groups[member] = value
        walk(doc, value, member, findings)
        if not any(isinstance(item, dict) for name, item in value.items() if not name.startswith("$")):
            findings.error(f"{show(member)} has no $value and no member; a token needs a $value")


class Checker:
    def __init__(self, doc, findings, types, tiers, base=None, base_usable=True):
        self.doc = doc
        self.f = findings
        self.types = types
        self.tiers = tiers
        self.base = base
        self.base_usable = base_usable

    # -- lookup ----------------------------------------------------------------------------------------------------
    def find(self, path):
        """(doc, node) of the token at path: this file first, then the base file of a mode file."""
        if path in self.doc.tokens:
            return self.doc, self.doc.tokens[path]
        if self.base is not None and path in self.base.tokens:
            return self.base, self.base.tokens[path]
        return None

    def is_group(self, path):
        return path in self.doc.groups or (self.base is not None and path in self.base.groups)

    # -- $type -----------------------------------------------------------------------------------------------------
    def resolve_type(self, doc, path, seen=()):
        """The $type of a token: its own, else the one of its alias target, else the nearest group's; None if none."""
        node = doc.tokens[path]
        if "$type" in node:
            return node["$type"]
        if (doc, path) in seen:
            return None
        seen = seen + ((doc, path),)
        target = alias_target(node.get("$value"))
        if target is not None:
            found = self.find(target) if doc is self.doc else ((doc, doc.tokens[target]) if target in doc.tokens else None)
            if found is not None:
                resolved = self.resolve_type(found[0], target, seen)
                if resolved is not None:
                    return resolved
        for depth in range(len(path) - 1, -1, -1):
            prefix = path[:depth]
            group = doc.root if depth == 0 else doc.groups.get(prefix)
            if group is not None and "$type" in group:
                return group["$type"]
        return None

    def check_declared_types(self):
        nodes = [((), self.doc.root, "group")]
        nodes += [(p, n, "group") for p, n in self.doc.groups.items()] + [(p, n, "token") for p, n in self.doc.tokens.items()]
        for path, node, kind in nodes:
            if "$type" in node and node["$type"] not in self.types:
                self.f.error(f"$type {json.dumps(node['$type'], ensure_ascii=False)} of {kind} {show(path)} is not one of the DTCG types ({', '.join(self.types)})")

    # -- one token -------------------------------------------------------------------------------------------------
    def check_token(self, path, node):
        name = show(path)
        parts = list(leaves(node["$value"]))
        aliases = []
        for loc, leaf in parts:
            if isinstance(leaf, str) and ("{" in leaf or "}" in leaf):
                target = alias_target(leaf)
                if target is None:
                    self.f.error(f"value {json.dumps(leaf, ensure_ascii=False)} of token {name} is not a whole alias {{a.b.c}}")
                else:
                    aliases.append((loc, target))
        resolvable = []
        for loc, target in aliases:
            if self.find(target) is not None:
                resolvable.append((loc, target))
            elif self.is_group(target):
                self.f.error(f"alias {{{show(target)}}} of token {name} points to a group, not a token")
            elif self.base_usable:
                self.f.error(f"alias {{{show(target)}}} of token {name} points to no token")
        self.check_tier(path, name, parts, aliases, resolvable)
        if self.resolve_type(self.doc, path) is None:
            self.f.error(f"token {name} has no $type: write it on the token, on an alias target or on a group above it")

    def check_tier(self, path, name, parts, aliases, resolvable):
        if not path or path[0] not in self.tiers:
            return
        index = self.tiers.index(path[0])
        if index == 0:
            if aliases:
                self.f.error(f"{path[0]} token {name} is an alias; a {path[0]} token holds a direct value")
            return
        below = self.tiers[index - 1]
        literal = next(((loc, leaf) for loc, leaf in parts if alias_target(leaf) is None), None)
        if literal is not None:
            where = f" at '{literal[0]}'" if literal[0] else ""
            self.f.error(f"{path[0]} token {name} holds a literal value{where}; write an alias to a {below} token")
        for loc, target in resolvable:
            if target[0] != below:
                self.f.error(f"{path[0]} token {name} aliases {{{show(target)}}}, which is not a {below} token")

    # -- whole file ------------------------------------------------------------------------------------------------
    def check_cycles(self):
        graph = {}
        for path, node in self.doc.tokens.items():
            graph[path] = [t for _, leaf in leaves(node["$value"]) for t in [alias_target(leaf)] if t in self.doc.tokens]
        state = {}
        reported = set()

        def visit(path, stack):
            state[path] = 1
            stack.append(path)
            for target in graph[path]:
                if state.get(target) == 1:
                    cycle = stack[stack.index(target):]
                    key = frozenset(cycle)
                    if key not in reported:
                        reported.add(key)
                        chain = " -> ".join(show(p) for p in cycle + [target])
                        self.f.error(f"alias cycle: {chain}")
                elif target not in state:
                    visit(target, stack)
            stack.pop()
            state[path] = 2

        for path in graph:
            if path not in state:
                visit(path, [])

    def check_css_names(self):
        by_name = {}
        for path in self.doc.tokens:
            if len(path) >= 2:
                by_name.setdefault("--" + "-".join(path[1:]), []).append(show(path))
        for css, paths in by_name.items():
            if len(paths) > 1:
                self.f.error(f"tokens {', '.join(paths)} give the same CSS variable {css}; the variable name is the path without the tier group")

    def check_roots(self):
        for key in self.doc.root:
            if not key.startswith("$") and key not in self.tiers:
                self.f.error(f"top-level key '{key}' is not a tier group; the top level has only {', '.join(self.tiers)}")

    def check_value_shapes(self):
        for path, node in self.doc.tokens.items():
            value = node["$value"]
            if isinstance(value, str) and ("{" in value or "}" in value):
                continue
            kind = self.resolve_type(self.doc, path)
            name = show(path)
            if kind == "color":
                self.check_color(name, value)
            elif kind == "dimension":
                self.check_dimension(name, value)

    def check_color(self, name, value):
        if not isinstance(value, dict):
            self.f.error(f"color token {name} must have a $value object with colorSpace, components and hex")
            return
        if value.get("colorSpace") != "srgb":
            self.f.error(f"color token {name} has colorSpace {json.dumps(value.get('colorSpace'))}; the kit uses \"srgb\"")
        components = value.get("components")
        components_ok = (
            isinstance(components, list) and len(components) == 3
            and all(is_number(c) and 0 <= c <= 1 for c in components)
        )
        if not components_ok:
            self.f.error(f"color token {name} must have components: an array of 3 numbers from 0 to 1")
        hex_value = value.get("hex")
        if not isinstance(hex_value, str) or not HEX_RE.match(hex_value):
            self.f.error(f"color token {name} must have hex written #rrggbb")
        elif components_ok:
            for index, channel in enumerate(components):
                byte = int(hex_value[1 + 2 * index:3 + 2 * index], 16)
                if abs(channel * 255 - byte) > 1 + 1e-9:
                    self.f.error(f"color token {name} has components that differ from hex {hex_value} by more than 1/255")
                    break
        if "alpha" in value and not (is_number(value["alpha"]) and 0 <= value["alpha"] <= 1):
            self.f.error(f"color token {name} must have alpha as a number from 0 to 1")

    def check_dimension(self, name, value):
        if not isinstance(value, dict):
            self.f.error(f"dimension token {name} must have a $value object with value and unit")
            return
        if not is_number(value.get("value")):
            self.f.error(f"dimension token {name} must have value as a number")
        if value.get("unit") not in DIMENSION_UNITS:
            self.f.error(f"dimension token {name} has unit {json.dumps(value.get('unit'))}; write one of {', '.join(DIMENSION_UNITS)}")

    def check_fill_descriptions(self):
        nodes = [((), self.doc.root)] + list(self.doc.groups.items()) + list(self.doc.tokens.items())
        for path, node in nodes:
            text = node.get("$description")
            if isinstance(text, str) and text.lstrip().startswith("fill:"):
                self.f.error(f"$description of {show(path)} still starts with 'fill:'; replace the template value with the one of the chosen visual direction")

    def check_mode(self):
        """A mode file declares only semantic tokens that tokens.json has, with the same type."""
        if not self.base_usable or len(self.tiers) < 2:
            return
        semantic = self.tiers[1]
        for path in self.doc.tokens:
            declared = self.base.tokens.get(path)
            if not path or path[0] != semantic or declared is None:
                self.f.error(f"mode file declares {show(path)}, which is not a {semantic} token of tokens.json; a mode only redeclares existing {semantic} tokens")
                continue
            mine = self.resolve_type(self.doc, path)
            theirs = self.resolve_type(self.base, path)
            if mine is not None and theirs is not None and mine != theirs:
                self.f.error(f"mode file changes the type of {show(path)} from {theirs} to {mine}")

    def run(self, template, is_mode):
        self.check_declared_types()
        if not is_mode:
            self.check_roots()
        for path, node in self.doc.tokens.items():
            self.check_token(path, node)
        self.check_cycles()
        self.check_css_names()
        self.check_value_shapes()
        if is_mode:
            self.check_mode()
        if not template:
            self.check_fill_descriptions()


def check_file(path, types, tiers, template, base_doc, base_usable, is_mode):
    """Findings of one file, and its parsed Doc (None when it could not be parsed)."""
    findings = Findings(path)
    doc = None
    try:
        root = load(path, findings)
        if root is not None:
            doc = Doc(root)
            walk(doc, root, (), findings)
            Checker(doc, findings, types, tiers, base_doc if is_mode else None, base_usable).run(template, is_mode)
    except Exception as error:  # a file that raises is a finding about that file, never a traceback
        findings.error(f"token file could not be checked ({type(error).__name__}: {error})")
    return findings, doc


def main(argv):
    parser = argparse.ArgumentParser(description="Check design token files against CONVENTIONS section 10.7.")
    parser.add_argument("--types", required=True, help="text file: one DTCG type per line")
    parser.add_argument("--tiers", required=True, help="text file: tier groups, lowest first")
    parser.add_argument("--template", action="store_true", help="the file is the token template: skip the fill: rule")
    parser.add_argument("files", nargs="+", metavar="FILE", help="BASE followed by the mode files")
    args = parser.parse_args(argv)
    types, tiers = read_lines(args.types), read_lines(args.tiers)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    lines = []
    base_path, mode_paths = args.files[0], args.files[1:]
    base_doc, base_usable = None, False
    if os.path.isfile(base_path):
        findings, base_doc = check_file(base_path, types, tiers, args.template, None, True, False)
        lines += findings.lines
        base_usable = base_doc is not None
    for mode_path in mode_paths:
        findings, _ = check_file(mode_path, types, tiers, args.template, base_doc, base_usable, True)
        lines += findings.lines
    for line in lines:
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
