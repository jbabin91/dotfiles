#!/bin/sh
# Seeds ~/.claude/CLAUDE.md with an import of ~/AGENTS.md, which Claude Code
# has no user-level lookup for. The file stays unmanaged, since Claude-only
# rules go below the import, so an existing file, or a link pointing anywhere,
# is left alone.

f="$HOME/.claude/CLAUDE.md"
if [ -e "$f" ] || [ -L "$f" ]; then exit 0; fi

# Renamed into place: the existence check above would keep a partial write for
# good.
tmp="$f.tmp.$$"
if mkdir -p "$HOME/.claude" && cat >"$tmp" <<'EOF' && mv -f "$tmp" "$f"; then
<!--
Shared instructions live in ~/AGENTS.md (a chezmoi link to ~/.dotfiles/general/agents/AGENTS.global.md),
read by Claude Code through the import below and by Codex directly. Claude-only rules go below the
import. Never put @ imports in ~/AGENTS.md: Codex would see them as plain text.
-->

@~/AGENTS.md
EOF
  echo "  claude: created ~/.claude/CLAUDE.md importing ~/AGENTS.md"
else
  rm -f "$tmp"
  echo "  claude: could not create $f; Claude Code will not read ~/AGENTS.md" >&2
fi
exit 0
