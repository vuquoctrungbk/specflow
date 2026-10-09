# Labels for bash: source this file after setting KIT_DIR (the folder that holds scripts/), then call i18n_for_project <dir>
# (the language of a project) or i18n_load <lang>. Every key of scripts/locales/<lang>/*.tsv becomes a variable L_<key>; a
# missing key is an unset variable, so the scripts run with `set -u` fail loudly. There is no default language: when a call
# returns 1, I18N_PROBLEM says what is wrong and what to do, and no label of a language is loaded. Reads with awk and eval, so
# it needs no associative array. The language rules are those of i18n.py (the two readers are tested to agree).
I18N_PROBLEM=""
I18N_LANG=""

# i18n_languages: the languages of this kit (the folders of scripts/locales/ named by a language code), space separated.
i18n_languages() {
  local d
  for d in "$KIT_DIR"/scripts/locales/*/; do
    d="$(basename "$d")"
    [[ "$d" =~ ^[a-z]{2,3}(-[A-Z]{2})?$ ]] && printf '%s ' "$d"
  done | sed 's/ $//'
}

# i18n_load <lang>: load every label of <lang>. Returns 1 and sets I18N_PROBLEM when the language or a table is not sound.
i18n_load() {
  local lang="$1" dir="$KIT_DIR/scripts/locales/$1" code missing
  I18N_PROBLEM=""
  if [[ ! "$lang" =~ ^[a-z]{2,3}(-[A-Z]{2})?$ || ! -d "$dir" ]]; then
    I18N_PROBLEM="language '$lang' has no labels in scripts/locales; the kit supports: $(i18n_languages)"
    echo "i18n: $I18N_PROBLEM" >&2
    return 1
  fi
  code="$(awk -F'\t' '
    { sub(/\r$/, "") }
    /^[[:space:]]*$/ || /^#/ { next }
    { n = split(FILENAME, part, "/"); where = part[n] ":" FNR }
    NF < 2 || $1 !~ /^[a-z][a-z0-9_]*$/ { print "I18N_PROBLEM=\047" where ": expected key<TAB>value with a lower_snake_case key\047; return 1"; exit }
    seen[$1]++ { print "I18N_PROBLEM=\047" where ": key " $1 " is defined twice\047; return 1"; exit }
    { v = $0; sub(/^[^\t]*\t/, "", v); gsub(/\047/, "\047\\\047\047", v); print "L_" $1 "=\047" v "\047" }' "$dir"/*.tsv)"
  eval "$code"
  if [[ -z "$I18N_PROBLEM" ]]; then
    # A key that another language has and this one lacks would be an unset variable far from here; name it now.
    missing="$(comm -13 <(awk -F'\t' '{ sub(/\r$/, "") } !/^#/ && NF >= 2 { print $1 }' "$dir"/*.tsv | sort -u) \
                        <(awk -F'\t' '{ sub(/\r$/, "") } !/^#/ && NF >= 2 { print $1 }' "$KIT_DIR"/scripts/locales/*/*.tsv | sort -u) | head -n 3 | paste -sd' ' -)"
    [[ -z "$missing" ]] || I18N_PROBLEM="language '$lang' has no label for: $missing (another language of scripts/locales has them)"
  fi
  if [[ -n "$I18N_PROBLEM" ]]; then
    echo "i18n: $I18N_PROBLEM" >&2
    return 1
  fi
  I18N_LANG="$lang"
}

# i18n_project_language <dir>: the `language` of the Intake of the project in <dir> as written (comment and quotes removed);
# empty when the Intake has none or does not exist.
i18n_project_language() {
  awk '{ sub(/[ \t\r]+$/, "") }
       NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit }
       /^language:/ { v = substr($0, 10); sub(/[ \t]+#.*$/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); gsub(/^["\047]+|["\047]+$/, "", v); print v; exit }' \
    "$1/docs/intake/PROJECT_INTAKE.md" 2>/dev/null
}

# i18n_for_project <dir>: load the labels of the language of the project in <dir>. Returns 1 and sets I18N_PROBLEM when the
# Intake does not exist, has no `language`, or names a language the kit has no labels for.
i18n_for_project() {
  local lang supported
  I18N_PROBLEM=""
  supported="$(i18n_languages)"
  if [[ ! -f "$1/docs/intake/PROJECT_INTAKE.md" ]]; then
    I18N_PROBLEM="does not exist, so the language of the project is unknown: create the Intake, whose frontmatter has \`language\`"
    return 1
  fi
  lang="$(i18n_project_language "$1")"
  if [[ -z "$lang" ]]; then
    I18N_PROBLEM="has no \`language\`: write the language code of the project in its frontmatter, one of: $supported"
    return 1
  fi
  if [[ ! " $supported " == *" $lang "* ]]; then
    I18N_PROBLEM="says language '$lang', but the kit has labels only for: $supported"
    return 1
  fi
  i18n_load "$lang" 2>/dev/null
}
