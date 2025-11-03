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

# User binaries - Highest priority (uv-installed Python, custom scripts)
# Added AFTER other tools so it takes precedence
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# Core Environment Variables (needed everywhere)
# -----------------------------------------------------------------------------

# Locale (needed for consistent command behavior in git hooks and scripts)
export LC_ALL="en_US.UTF-8"

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

# mise (Multi-language tool manager) - CRITICAL for git hooks and Claude Code hooks
# Git hooks: prettier, taplo, markdownlint-cli2 from mise installations
# Claude Code hooks: uv (Python package/project manager) from mise
eval "$(mise activate zsh)"

# zoxide - Smart cd replacement (needed for Claude Code and scripts)
# Loaded here so `z` command works immediately without shell snapshots
eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# Python Auto-Switching (like fnm env --use-on-cd)
# -----------------------------------------------------------------------------
# Auto-switch Python versions based on .python-version or pyproject.toml
# Uses uv run in projects, falls back to direct python globally

python() {
  if [[ -f .python-version ]] || [[ -f pyproject.toml ]]; then
    uv run python "$@"
  else
    command python "$@"
  fi
}

python3() {
  if [[ -f .python-version ]] || [[ -f pyproject.toml ]]; then
    uv run python "$@"
  else
    command python3 "$@"
  fi
}
