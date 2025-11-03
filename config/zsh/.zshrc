#!/usr/bin/env zsh
# =============================================================================
# Zsh Configuration (Sheldon)
# =============================================================================
# Clean, organized shell configuration powered by Sheldon.
# Individual components are in ~/.config/zsh/

# -----------------------------------------------------------------------------
# Amazon Q (required at top)
# -----------------------------------------------------------------------------
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# -----------------------------------------------------------------------------
# Environment & Configuration
# -----------------------------------------------------------------------------
source ~/.config/zsh/env.sh
source ~/.config/zsh/aliases.sh

# -----------------------------------------------------------------------------
# Sheldon Plugin Manager
# -----------------------------------------------------------------------------
# Load plugins, completions, and tool integrations
eval "$(sheldon source)"

# -----------------------------------------------------------------------------
# Completions
# -----------------------------------------------------------------------------
source ~/.config/zsh/completions.sh

# -----------------------------------------------------------------------------
# Post-Init: History Substring Search Keybindings
# -----------------------------------------------------------------------------
# Must be set after zsh-history-substring-search is loaded
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# -----------------------------------------------------------------------------
# iTerm Integration
# -----------------------------------------------------------------------------
# Only load iTerm2 integration when actually running in iTerm2
[[ "$TERM_PROGRAM" == "iTerm.app" ]] && test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# -----------------------------------------------------------------------------
# Amazon Q (required at bottom)
# -----------------------------------------------------------------------------
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
