# shellcheck shell=bash
# Environment (Sourced by ALL shells)
# Only put things here that are needed everywhere — interactive, non-interactive, git hooks

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
# Re-prepend after brew shellenv; path_helper can push /usr/bin ahead of Homebrew
case "$PATH" in
  /opt/homebrew/bin:*) ;;
  *) export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" ;;
esac

# -----------------------------------------------------------------------------
# Development Tool PATHs
# -----------------------------------------------------------------------------

# pnpm — $PNPM_HOME/bin: global package shims; $PNPM_HOME: pnpm runtime shims (standalone installer)
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH" ;;
esac

# mise - manages node and other tools; --shims mode keeps tools resolvable in non-interactive shells (git hooks, GUI apps)
eval "$(mise activate zsh --shims)"

# Cargo/Rust binaries
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) ;;
  *) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# Bun
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# User binaries (uv-installed tools, custom scripts)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# -----------------------------------------------------------------------------
# Android SDK
# -----------------------------------------------------------------------------
export ANDROID_HOME=$HOME/Library/Android/sdk
case ":$PATH:" in
  *":$ANDROID_HOME/cmdline-tools/10.0/bin:"*) ;;
  *) export PATH="$PATH:$ANDROID_HOME/cmdline-tools/10.0/bin" ;;
esac

# -----------------------------------------------------------------------------
# Core Environment Variables
# -----------------------------------------------------------------------------
export LC_ALL="en_US.UTF-8"
export EDITOR=nvim
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"
