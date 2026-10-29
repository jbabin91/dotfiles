#!/usr/bin/env bash
# Pick a session to kill from an fzf popup. tmux's own kill-session only ever
# targets the current session, and choose-tree's kill binding is easy to miss.
# With detach-on-destroy off, killing the session you are attached to switches
# you to another one rather than dropping you out of tmux.
set -euo pipefail

current="$(tmux display -p '#S')"

selection="$(
  tmux list-sessions -F '#{session_name}#{?session_attached, (attached),}' \
    | fzf-tmux -p 60%,50% --no-sort --prompt='kill session: ' --header="current: ${current}"
)" || exit 0

[ -n "$selection" ] || exit 0
exec tmux kill-session -t "${selection%% *}"
