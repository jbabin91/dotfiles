#!/usr/bin/env zsh
# =============================================================================
# Tool Initialization
# =============================================================================
# Initialize external tools and integrations.
# Ordered roughly by importance/frequency of use.

# iTerm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Core development tools
eval "$(mise activate zsh)"         # Tool version manager
eval "$(direnv hook zsh)"           # Environment switcher
eval "$(pyenv init - zsh)"          # Python version manager
eval "$(fnm env --use-on-cd)"       # Node version manager

# Shell enhancements
eval "$(starship init zsh)"         # Prompt
eval "$(zoxide init zsh)"           # Smart cd
eval "$(fzf --zsh)"                 # Fuzzy finder
