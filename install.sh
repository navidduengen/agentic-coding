#!/usr/bin/env bash
# Link this repo into ~/.claude. Idempotent. Existing non-symlink targets are
# moved to .backup-before-install/<timestamp>/ before being replaced.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="${REPO}/.backup-before-install/${STAMP}"

link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      echo "ok      $dst"
      return
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/$(basename "$dst")"
    echo "backup  $dst -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked  $dst -> $src"
}

mkdir -p "$CLAUDE_DIR"

link "$REPO/Rules/CLAUDE.md"               "$CLAUDE_DIR/CLAUDE.md"
link "$REPO/Claude/settings.json"          "$CLAUDE_DIR/settings.json"
link "$REPO/Claude/hooks"                  "$CLAUDE_DIR/hooks"
link "$REPO/Claude/agents"                 "$CLAUDE_DIR/agents"
link "$REPO/Claude/commands"               "$CLAUDE_DIR/commands"
link "$REPO/Claude/output-styles"          "$CLAUDE_DIR/output-styles"
link "$REPO/Claude/statusline-command.sh"  "$CLAUDE_DIR/statusline-command.sh"
link "$REPO/Skills"                        "$CLAUDE_DIR/skills"

chmod +x "$REPO/Claude/statusline-command.sh" "$REPO/Claude/hooks/"*.sh

# Build the compound-command hook (binary is gitignored)
if command -v go >/dev/null 2>&1; then
  (cd "$REPO/Claude/hooks" && go build -ldflags="-s -w" -o approve-compound-commands ./approve-compound-commands.go)
  echo "built   Claude/hooks/approve-compound-commands"
else
  echo "warn    go not found, approve-compound-commands hook not built (brew install go)"
fi

# Repo hygiene
if command -v pre-commit >/dev/null 2>&1; then
  (cd "$REPO" && pre-commit install >/dev/null) && echo "ok      pre-commit hook installed"
fi

echo
echo "Done. Start a new Claude Code session and run /context to confirm CLAUDE.md is loaded."
