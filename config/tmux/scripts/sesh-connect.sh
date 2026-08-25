#!/usr/bin/env bash
# Opens the sesh picker in an fzf popup and connects to the selection.
# Exists as a script because inlining it in tmux.conf and in tmux-which-key's
# config.yaml required three layers of quote escaping, which tmux's display-menu
# failed to parse ("not enough arguments").
set -euo pipefail

selection="$(sesh list --icons | fzf-tmux -p 80%,70% --no-sort --ansi)" || exit 0
[ -n "$selection" ] || exit 0
exec sesh connect "$selection"
