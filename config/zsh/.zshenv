# =============================================================================
# Environment (Sourced by ALL shells)
# =============================================================================
# This file is sourced by ALL shells (interactive, non-interactive, git hooks)
# CRITICAL: Only put things here that are needed everywhere

# Homebrew - CRITICAL for accessing fnm, zoxide, etc.
# Git hooks need this to find these binaries
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Cargo (Rust)
. "$HOME/.cargo/env"

# -----------------------------------------------------------------------------
# Core Environment Variables (needed everywhere)
# -----------------------------------------------------------------------------

# Editor (git commit messages, command-line editing)
export EDITOR=nvim

# GPG (git commit signing)
export GPG_TTY=$(tty)

# ripgrep (configuration file location)
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

# -----------------------------------------------------------------------------
# Development Tools (CRITICAL for git hooks)
# -----------------------------------------------------------------------------

# fnm (Fast Node Manager) - CRITICAL for git hooks
# All lefthook commands use pnpm, which needs node from fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# pnpm - CRITICAL for git hooks
# All lefthook commands use pnpm (prettier, eslint, tsc-files, commitlint)
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# zoxide - Smart cd replacement (needed for Claude Code and scripts)
# Loaded here so `z` command works immediately without shell snapshots
eval "$(zoxide init zsh)"
