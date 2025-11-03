#!/usr/bin/env zsh
# =============================================================================
# Environment Variables (Interactive Shells Only)
# =============================================================================
# This file is ONLY sourced by interactive shells (via .zshrc)
# For ALL shells (including git hooks), use .zshenv instead

# Locale
export LC_ALL="en_US.UTF-8"

# -----------------------------------------------------------------------------
# ZSH Plugin Configuration (must be set BEFORE Sheldon loads plugins)
# -----------------------------------------------------------------------------
# These MUST be in env.sh (not .zshenv) because they need to be set before
# Sheldon loads zsh-autosuggestions and zsh-syntax-highlighting in .zshrc

# zsh-autosuggestions: Reduce rendering artifacts
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# zsh-syntax-highlighting: Optimize for better performance
export ZSH_HIGHLIGHT_MAXLENGTH=300

# Ghostty: Ensure proper terminal state
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  # Force prompt redraw after command execution
  export STARSHIP_CACHE="$HOME/.cache/starship"
  # Ensure proper TERM value for best compatibility
  export TERM="${TERM:-xterm-ghostty}"
fi

# -----------------------------------------------------------------------------
# Version Managers (Interactive Only)
# -----------------------------------------------------------------------------
# These are only for interactive shells because they're activated via Sheldon

# pyenv (Python version manager)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# proto (Multi-language version manager)
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# -----------------------------------------------------------------------------
# Tool Configuration
# -----------------------------------------------------------------------------

# FZF (Fuzzy Finder) - Only for interactive shells with fzf plugin
export FZF_DEFAULT_COMMAND='rg --files --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
