#!/usr/bin/env bash
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
CI=0
AGENTS=0
GLOBAL=0

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

# Install comment-guard in the current git repository.
#
# Usage:
#   ./install.sh             install script, pre-commit hook, and CLAUDE.md rules
#   ./install.sh --ci        also install GitHub Actions workflow
#   ./install.sh --agents-md also write rules to AGENTS.md
#   ./install.sh --global    only write rules to ~/.claude/CLAUDE.md

for arg in "$@"; do
  case "$arg" in
    --ci) CI=1 ;;
    --agents-md) AGENTS=1 ;;
    --global) GLOBAL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

add_rules() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  if [ -f "$target" ] && grep -q 'comment-guard:start' "$target"; then
    echo "skip rules: $target"
  else
    [ -s "$target" ] && printf '\n' >> "$target"
    cat "$KIT/rules.md" >> "$target"
    echo "write rules: $target"
  fi
}

if [ "$GLOBAL" = 1 ]; then
  add_rules "$HOME/.claude/CLAUDE.md"
  exit 0
fi

root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Please run inside a git repository." >&2
  exit 2
}
cd "$root"

mkdir -p tools
cp "$KIT/check_comments.sh" tools/check_comments.sh
chmod +x tools/check_comments.sh
echo "install: tools/check_comments.sh"

hook="$(git rev-parse --git-path hooks)/pre-commit"
mkdir -p "$(dirname "$hook")"
call='"$(git rev-parse --show-toplevel)/tools/check_comments.sh" || exit 1'

if [ -f "$hook" ]; then
  if grep -q check_comments.sh "$hook"; then
    echo "skip hook: $hook"
  else
    printf '\n# comment-guard\n%s\n' "$call" >> "$hook"
    echo "append hook: $hook"
  fi
else
  printf '#!/bin/sh\n# comment-guard\n%s\n' "$call" > "$hook"
  echo "create hook: $hook"
fi
chmod +x "$hook"

add_rules "$root/CLAUDE.md"
[ "$AGENTS" = 1 ] && add_rules "$root/AGENTS.md"

if [ "$CI" = 1 ]; then
  mkdir -p .github/workflows
  cp "$KIT/.github/workflows/comment-guard.yml" .github/workflows/comment-guard.yml
  echo "install: .github/workflows/comment-guard.yml"
fi

echo "Done. Run tools/check_comments.sh --all once to scan existing files."
