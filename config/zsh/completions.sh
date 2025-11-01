#!/usr/bin/env zsh
# =============================================================================
# Completions
# =============================================================================
# Additional completion configurations.
# Note: compinit is called by Zim's completion module,
# so we only need to add to fpath or source completion files.

# Docker CLI completions
fpath=(/Users/jacebabin/.docker/completions $fpath)

# bun completions
[ -s "/Users/jacebabin/.bun/_bun" ] && source "/Users/jacebabin/.bun/_bun"
