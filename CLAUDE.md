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

Commits use [Conventional Commits](https://www.conventionalcommits.org/) enforced by commitlint. Allowed scopes: `zsh`, `git`, `brew`, `ghostty`, `kitty`, `starship`, `karabiner`, `mise`, `nvim`, `bat`, `tmux`, `fastfetch`, `cspell`, `deps`. Custom scopes are not allowed; empty scopes are fine.

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

# Comment policy

Comments are useful when they add value. Keep them clean and minimal.

A good comment:

- Is accurate (matches the code; remove if stale)
- Earns its place (explains WHY or non-obvious context, not WHAT)
- Is concise (one or two lines unless documenting a complex invariant)

Avoid:

- Restating what the code does
- Section markers like `// ===== HELPERS =====`
- Hedge words, apologies, "obviously", "basically", "just"
- "Note:" / "Important:" prefixes when surrounding text already conveys importance
- TODOs without ticket references
- Cross-references that belong in the PR description ("added for X", "used by Y")
- Multi-line comments on trivial code
- AI-flavored phrasings ("Here we...", "Let's...", "This...")

When in doubt: keep the comment, but make it tighter.

# Fix-vs-defer policy

When addressing review findings (from the review-cycle skill, PR comments, or any other reviewer):

Default to fixing inline. Defer to a follow-up only if:

- The fix is substantially more work than writing the follow-up itself
- The fix requires architectural changes spanning files outside this PR scope
- The fix requires a new dependency or schema migration not in this PR
- The fix would invalidate unrelated tests

If you can describe the fix in one sentence, just do the fix.

When deferring, briefly state which criterion above applies.
