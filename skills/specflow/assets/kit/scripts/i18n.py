"""The labels that the scripts read from, and write into, the documents of a project, in the language of the project.

A language is a folder scripts/locales/<lang>/ of .tsv files, one "key<TAB>value" per line; a line that starts with # is a
comment. Keys are lower_snake_case and unique across the files of a language. The scripts know the keys, never the
words: `T.roadmap_done` is "Xong" in Vietnamese and "Done" in English.

    from i18n import T            # the language of the project named on the command line (see detect)
    T.roadmap_done
    T.get("roadmap_done")         # the same, with a KeyError that names the missing key and the language

The language of a project is the `language` of the frontmatter of its Intake, docs/intake/PROJECT_INTAKE.md. There is no
default: a script that cannot read it stops with one line that says which Intake lacks what. A script takes the project
from its first argument that is a directory; check-templates.sh reads the same line with the same rules (i18n.sh).
"""
import pathlib
import re

LOCALES = pathlib.Path(__file__).with_name("locales")
INTAKE = "docs/intake/PROJECT_INTAKE.md"
CODE_RE = re.compile(r"^[a-z]{2,3}(-[A-Z]{2})?$")  # a language code; also what i18n.sh accepts, so a code never leaves the folder
KEY_RE = re.compile(r"^[a-z][a-z0-9_]*$")


class Labels:
    def __init__(self, lang):
        self.lang = lang
        self._values = {}
        if lang not in available():
            raise SystemExit(f"i18n: no language '{lang}': {LOCALES / lang} does not exist")
        for tsv in sorted((LOCALES / lang).glob("*.tsv")):
            for number, line in enumerate(tsv.read_text(encoding="utf-8").split("\n"), 1):
                if not line.strip() or line.startswith("#"):
                    continue
                key, sep, value = line.partition("\t")
                if not sep or not KEY_RE.match(key):
                    raise SystemExit(f"i18n: {tsv}:{number}: expected 'key<TAB>value' with a lower_snake_case key")
                if key in self._values:
                    raise SystemExit(f"i18n: {tsv}:{number}: key '{key}' is defined twice in language '{self.lang}'")
                self._values[key] = value

    def get(self, key):
        try:
            return self._values[key]
        except KeyError:
            raise KeyError(f"i18n: language '{self.lang}' has no label '{key}'") from None

    def __getattr__(self, key):
        if key.startswith("_"):
            raise AttributeError(key)
        return self.get(key)


def available():
    return sorted(d.name for d in LOCALES.iterdir() if d.is_dir() and CODE_RE.match(d.name))


def declared_language(project):
    """The `language` value of the Intake frontmatter of the project in a folder as written (comment and quotes removed),
    "" when the Intake has no such line, None when there is no Intake. Same rules as i18n_project_language in i18n.sh."""
    intake = pathlib.Path(project) / INTAKE
    try:
        lines = [line.rstrip() for line in intake.read_text(encoding="utf-8").split("\n")]
    except OSError:
        return None
    if not lines or lines[0] != "---":
        return ""
    for line in lines[1:]:
        if line == "---":
            break
        if line.startswith("language:"):
            return re.sub(r"\s+#.*$", "", line[len("language:"):]).strip().strip("\"'")
    return ""


def language_of(project):
    """(language, None) for a project whose Intake names a language this kit has, else (None, what is wrong and what to do; the text goes after the path of the Intake)."""
    value = declared_language(project)
    supported = ", ".join(available())
    if value is None:
        return None, "does not exist, so the language of the project is unknown: create the Intake, whose frontmatter has `language`"
    if value == "":
        return None, f"has no `language`: write the language code of the project in its frontmatter, one of: {supported}"
    if value not in available():
        return None, f"says language '{value}', but the kit has labels only for: {supported}"
    return value, None


def project_language(project):
    """The language of the project in a folder, None when it has none (see language_of for the reason)."""
    return language_of(project)[0]


def detect(argv):
    """The language for this process: that of the project that the first directory in the command line names."""
    for arg in argv[1:]:
        if not arg.startswith("-") and pathlib.Path(arg).is_dir():
            lang, problem = language_of(arg)
            if problem:
                raise SystemExit(f"i18n: {INTAKE} of {arg} {problem}")
            return lang
    raise SystemExit("i18n: cannot tell the language of the project: name the project directory (the folder that holds docs/) as the first argument (the usage is at the head of the script)")


class _Current:
    """T: the labels of the language of this process, looked up when first used, so importing this module costs nothing."""

    _labels = None

    def _resolve(self):
        if _Current._labels is None:
            import sys
            _Current._labels = Labels(detect(sys.argv))
        return _Current._labels

    def __getattr__(self, key):
        return getattr(self._resolve(), key)


T = _Current()
