# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot) via `uv tool run dotbot`. Configs are symlinked from this repo to their expected locations in `~` and `~/.config/`.

## Commands

```bash
./install                  # Run dotbot to create/update symlinks
pnpm run format            # Format JSON/YAML/MD with prettier
pnpm run lint              # Run all linting (format check + shellcheck + markdownlint)
pnpm run lint:shell        # Lint shell scripts only
pnpm run lint:md           # Lint markdown only
pnpm run lint:md:fix       # Auto-fix markdown issues
```

## Commit Conventions

Commits use [Conventional Commits](https://www.conventionalcommits.org/) enforced by commitlint. Allowed scopes: `zsh`, `git`, `brew`, `ghostty`, `kitty`, `starship`, `karabiner`, `mise`, `bat`, `tmux`, `fastfetch`, `cspell`, `deps`. Custom scopes are not allowed; empty scopes are fine.

## Architecture

- **`config/`** — Application configs symlinked to `~/.config/<app>` (zsh, ghostty, kitty, starship, mise, nvim, fastfetch, btop, bat, tmux)
- **`general/`** — Dotfiles symlinked to `~/` or `~/.` (Brewfile, git config, editorconfig, cspell)
- **`install.conf.yaml`** — Dotbot config defining all symlinks and shell commands
- **`config/macos/set-defaults.sh`** — macOS system defaults (not auto-run, manual script)

### Special Cases

- **Karabiner**: Cannot use symlinks (the app replaces them). Uses bidirectional copy sync in `install.conf.yaml` shell section — copies whichever version is newer.
- **Neovim**: Uses LazyVim. The `config/nvim/` directory is excluded from prettier via `.prettierignore`.
- **Zsh**: Uses Antidote plugin manager. Plugins defined in `config/zsh/.zsh_plugins.txt`, shell config split between `.zshenv` (all shells) and `.zshrc` (interactive).

## Style

- 2-space indentation, LF line endings, UTF-8
- JS/config files use single quotes, 100 char print width
- `package.json` has `"type": "module"` — config files use ESM exports
