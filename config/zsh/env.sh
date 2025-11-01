#!/usr/bin/env zsh
# =============================================================================
# Environment Variables
# =============================================================================
# Core environment configuration for the shell.

# Locale and editor
export LC_ALL="en_US.UTF-8"
export EDITOR=nvim
export GPG_TTY=$(tty)

# pnpm
export PNPM_HOME="/Users/jacebabin/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# proto
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# Windsurf
export PATH="/Users/jacebabin/.codeium/windsurf/bin:$PATH"
