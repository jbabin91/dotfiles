# AGENTS.md

## Overview

Personal macOS dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot) via `uv tool run dotbot`. Configs are symlinked from this repo to their expected locations in `~` and `~/.config/`.

A migration to [chezmoi](https://www.chezmoi.io/) is in progress: files under `home/` (zsh, starship) are chezmoi-managed copies rather than symlinks, so editing the deployed file and editing the repo are no longer the same act — use `chezmoi re-add` or edit the source. `./install` runs dotbot and then `chezmoi init --apply`. chezmoi is not in the Brewfile: `./install` uses a working one already on PATH, and otherwise bootstraps a copy into `~/.local/bin` — after dotbot, so a network failure there cannot cost you the symlinks.

## Commands

```bash
./install                  # Run dotbot, bootstrap chezmoi, then chezmoi init --apply
pnpm run format            # Format JSON/YAML/MD with prettier
pnpm run lint              # Run all linting (format check + shellcheck + markdownlint)
pnpm run lint:shell        # Lint shell scripts only
pnpm run lint:md           # Lint markdown only
pnpm run lint:md:fix       # Auto-fix markdown issues
```

## Task tracking

Use `bd` (beads). Run `bd prime` for the command reference and session protocol.

A fresh clone has no database — `.beads/embeddeddolt/` is gitignored — but commits still work: measured on bd 1.3.0, `bd hooks run <hook>` exits 0 and prints nothing without one, so every `.beads/hooks/*` shim is a silent no-op. (`bd list` and `bd ready` do exit 1 there.) `bd bootstrap` clones the task graph from `BD_SYNC_REMOTE` in `.beads/.env`; the graph lives on a Dolt remote, not in this repository.

`.beads/.env` is gitignored and the sync remote is deliberately absent from `.beads/config.yaml`. This repository is public, and `bd dolt remote add` writes the URL into that tracked file, which would publish an internal hostname. Without the env file, bootstrap creates a fresh local database and everything still works.

Prefer `bd bootstrap` to `bd init`. Measured on bd 1.3.0 while setting this up, `bd init` set `core.hooksPath`, generated `.codex/`, `.cursor/` and `.agents/` integrations nothing here reads, appended a managed block to `CLAUDE.md`, and made two commits whose messages commitlint rejects. `bd hooks install --beads` sets `core.hooksPath` too — to an absolute path, despite printing `core.hooksPath=.beads/hooks`, so grepping for the relative string will not find it. It also copies the existing `.git/hooks` into `.beads/hooks`, appends beads to them, and can leave an untracked `commit-msg` there that nothing gitignores. After running it: unset `core.hooksPath`, re-run `lefthook install -f`, and check that no file under `.beads/hooks/` mentions lefthook.

`core.hooksPath` must stay unset. Setting it makes git bypass lefthook entirely and silently — no commitlint, no formatters — because `lefthook.yml` is what calls `.beads/hooks/*`.

## Commit Conventions

Commits use [Conventional Commits](https://www.conventionalcommits.org/), enforced by commitlint.

Scopes are derived in `.commitlintrc.js` from the directory names under `config/`, plus `git`, `brew`, `cspell`, and `deps`. Adding a tool under `config/` makes its scope available with no config edit.

That list drives the `cz-git` prompt, which rejects scopes outside it. Commitlint itself has no `scope-enum` rule, so a hand-written commit accepts any scope. Empty scopes are fine either way.

## Architecture

- **`config/`** — Application configs symlinked to `~/.config/<app>` (ghostty, kitty, mise, nvim, fastfetch, btop, bat, tmux)
- **`general/`** — Dotfiles symlinked to `~/` or `~/.` (Brewfile, git config, editorconfig, cspell)
- **`home/`** — chezmoi source, mirroring `~/` (`dot_zshrc` becomes `~/.zshrc`); `.chezmoiroot` points chezmoi here, and `home/.chezmoi.toml.tmpl` generates `~/.config/chezmoi/chezmoi.toml`
- **`install.conf.yaml`** — Dotbot config defining all symlinks and shell commands
- **`config/macos/set-defaults.sh`** — macOS system defaults (not auto-run, manual script)

### Special Cases

- **Karabiner**: Cannot use symlinks (the app replaces them). Uses bidirectional copy sync in `install.conf.yaml` shell section — copies whichever version is newer.
- **Neovim**: Uses LazyVim. The `config/nvim/` directory is excluded from prettier via `.prettierignore`.
- **Zsh**: Uses Antidote plugin manager, and is chezmoi-managed. Plugins in `home/dot_config/zsh/dot_zsh_plugins.txt`, shell config split between `home/dot_zshenv` (all shells) and `home/dot_zshrc` (interactive).

## Style

- 2-space indentation, LF line endings, UTF-8
- JS/config files use single quotes, 100 char print width
- `package.json` has `"type": "module"` — config files use ESM exports

## Comment policy

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

## Fix-vs-defer policy

When addressing review findings (from the review-cycle skill, PR comments, or any other reviewer):

Default to fixing inline. Defer to a follow-up only if:

- The fix is substantially more work than writing the follow-up itself
- The fix requires architectural changes spanning files outside this PR scope
- The fix requires a new dependency or schema migration not in this PR
- The fix would invalidate unrelated tests

If you can describe the fix in one sentence, just do the fix.

When deferring, briefly state which criterion above applies.
