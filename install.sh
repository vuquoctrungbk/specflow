#!/usr/bin/env bash
# Install the specflow skill for one or more coding agents.
#
#   ./install.sh --agent claude|codex|opencode|antigravity|all [--scope user|project]
#                [--project-dir DIR] [--force]
#
# user scope (default) installs for every project of the current user;
# project scope installs into DIR (default: the current directory) so the team
# gets the skill from the repository. An existing specflow install is replaced
# only with --force, so an upgrade is always a deliberate step.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
skill_src="$here/skills/specflow"
opencode_cmd_src="$here/adapters/opencode/commands/specflow.md"

agents=() scope=user project_dir="$PWD" project_dir_given=0 force=0
need_value() { [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { echo "$1 needs a value" >&2; exit 2; }; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) need_value "$@"; agents+=("$2"); shift 2 ;;
    --scope) need_value "$@"; scope="$2"; shift 2 ;;
    --project-dir) need_value "$@"; project_dir="$2"; project_dir_given=1; shift 2 ;;
    --force) force=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ ${#agents[@]} -gt 0 ]] || { echo "choose at least one --agent (claude, codex, opencode, antigravity, all)" >&2; exit 2; }
[[ "$scope" == user || "$scope" == project ]] || { echo "--scope must be user or project" >&2; exit 2; }
[[ $project_dir_given -eq 0 || "$scope" == project ]] || { echo "--project-dir needs --scope project" >&2; exit 2; }
[[ -f "$skill_src/SKILL.md" ]] || { echo "skill source not found at $skill_src" >&2; exit 1; }
if [[ "$scope" == project ]]; then
  [[ -d "$project_dir" ]] || { echo "project dir not found: $project_dir" >&2; exit 1; }
  project_dir="$(cd "$project_dir" && pwd)"
fi
[[ " ${agents[*]} " == *" all "* ]] && agents=(claude codex opencode antigravity)
for agent in "${agents[@]}"; do
  case "$agent" in claude|codex|opencode|antigravity) ;; *) echo "unknown agent: $agent" >&2; exit 2 ;; esac
done
# OpenCode also loads skills from the Claude Code and Codex folders (.claude/skills, .agents/skills,
# and their user-scope twins), and it wants skill names to be unique. When one of those agents is
# installed in the same run, OpenCode gets only its /specflow command file, not a second skill copy.
opencode_skill=1
[[ " ${agents[*]} " == *" claude "* || " ${agents[*]} " == *" codex "* ]] && opencode_skill=0

# skill_dir <agent>: where the runtime discovers skills for the chosen scope.
skill_dir() {
  case "$1:$scope" in
    claude:user) echo "$HOME/.claude/skills" ;;
    claude:project) echo "$project_dir/.claude/skills" ;;
    codex:user) echo "$HOME/.agents/skills" ;;
    codex:project) echo "$project_dir/.agents/skills" ;;
    opencode:user) echo "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills" ;;
    opencode:project) echo "$project_dir/.opencode/skills" ;;
    antigravity:user) echo "$HOME/.gemini/config/skills" ;;
    antigravity:project) echo "$project_dir/.agents/skills" ;;
    *) echo "unknown agent: $1" >&2; return 1 ;;
  esac
}

# place <src> <dest>: copy a file or directory, replacing an older copy only with --force.
place() {
  local src="$1" dest="$2"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ $force -eq 0 ]]; then
      echo "  skip: $dest exists (rerun with --force to replace it)"
      return 0
    fi
    rm -rf "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  echo "  installed: $dest"
}

done_dirs=" "
for agent in "${agents[@]}"; do
  dir="$(skill_dir "$agent")"
  echo "$agent ($scope scope)"
  # Codex and Antigravity share .agents/skills in project scope; copy once.
  if [[ "$done_dirs" == *" $dir "* ]]; then
    echo "  already installed in $dir"
  elif [[ "$agent" == opencode && $opencode_skill -eq 0 ]]; then
    echo "  skill: OpenCode reads the copy installed for Claude Code or Codex"
  else
    place "$skill_src" "$dir/specflow"
    done_dirs+="$dir "
  fi
  if [[ "$agent" == opencode ]]; then
    # OpenCode loads skills through its skill tool; a command file gives the /specflow slash command.
    place "$opencode_cmd_src" "$(dirname "$dir")/commands/specflow.md"
  fi
done

cat <<'EOF'

Done. Start a new session of your agent in a project and type:
  Claude Code, OpenCode, Antigravity:  /specflow <your request>
  Codex:                               $specflow <your request>
EOF
