#!/bin/sh
# Seeds ~/.claude/CLAUDE.md with an import of ~/AGENTS.md. The file stays
# unmanaged, since Claude-only rules go below the import, so an existing file,
# or a link pointing anywhere, is left alone.

f="$HOME/.claude/CLAUDE.md"
if [ -e "$f" ] || [ -L "$f" ]; then exit 0; fi

mkdir -p "$HOME/.claude" &&
  cat >"$f" <<'EOF' &&
<!--
Shared instructions live in ~/AGENTS.md (a chezmoi link to ~/.dotfiles/general/agents/AGENTS.global.md),
read by Claude Code through the import below and by Codex directly. Claude-only rules go below the
import. Never put @ imports in ~/AGENTS.md: Codex would see them as plain text.
-->

@~/AGENTS.md
EOF
  echo "  claude: created ~/.claude/CLAUDE.md importing ~/AGENTS.md"
