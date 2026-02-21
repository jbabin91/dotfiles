# shellcheck shell=bash
# =============================================================================
# Environment (Sourced by ALL shells)
# =============================================================================
# This file is sourced by ALL shells (interactive, non-interactive, git hooks)
# CRITICAL: Only put things here that are needed everywhere

# -----------------------------------------------------------------------------
# Color Support (MUST be first - needed for all terminal applications)
# -----------------------------------------------------------------------------
export COLORTERM="${COLORTERM:-truecolor}"
export FORCE_COLOR="${FORCE_COLOR:-1}"
export CLICOLOR=1

# -----------------------------------------------------------------------------
# Homebrew (sets PREFIX, CELLAR, REPOSITORY, fpath, MANPATH, INFOPATH, PATH)
# -----------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ENV_HINTS=1

# -----------------------------------------------------------------------------
# Development Tool PATHs
# -----------------------------------------------------------------------------

# fnm (Fast Node Manager) - CRITICAL for git hooks
export PATH="$HOME/.local/share/fnm:$PATH"

# pnpm - CRITICAL for git hooks
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# mise - CRITICAL for git hooks and Claude Code hooks
# --shims mode provides stable PATH for non-interactive shells while resolving project-level tools
eval "$(mise activate zsh --shims)"

# Cargo/Rust binaries
export PATH="$HOME/.cargo/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# User binaries - Highest priority (uv-installed Python, custom scripts)
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# fnm env (CRITICAL for git hooks to find correct node/pnpm)
# Interactive shells get fnm env --use-on-cd in .zshrc instead
# -----------------------------------------------------------------------------
if [[ ! -o interactive ]]; then
  eval "$(fnm env)"
fi

# -----------------------------------------------------------------------------
# Android SDK
# -----------------------------------------------------------------------------
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:"$ANDROID_HOME/cmdline-tools/10.0/bin"

# -----------------------------------------------------------------------------
# Core Environment Variables
# -----------------------------------------------------------------------------
export LC_ALL="en_US.UTF-8"
export EDITOR=nvim
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"
