# AGENTS.md

## Overview

Personal macOS dotfiles deployed by [chezmoi](https://www.chezmoi.io/) from `home/`. [Dotbot](https://github.com/anishathalye/dotbot), run via `uv tool run dotbot`, still runs from `./install` with nothing left in `install.conf.yaml`.

Hand-edited configs are chezmoi copies, so editing the deployed file and editing the repo are not the same act — use `chezmoi re-add` or edit the source. Configs a tool rewrites (lazy-lock, `mise use`, Zed's settings UI, cspell's add-word, `brew bundle dump`, the kitty theme kitten) and the agent instructions are `symlink_*.tmpl` entries instead, pointing back into `config/` and `general/`, so those writes land in the repo. `./install` runs dotbot and then `chezmoi init --apply`. Its `home/run_before_*` scripts first remove the dead links into this repo that a moved or deleted file leaves in `~` and `~/.config`, sync the Karabiner config, and seed `~/.claude/CLAUDE.md`, and its `home/run_onchange_after_*` scripts run the Brewfile, mise and tmux plugin installs after the files land; each re-runs only when the file its comment hashes changes, and a failing one makes the apply exit nonzero, stops the ones after it, and runs again next time. chezmoi is not in the Brewfile: `./install` uses a working one already on PATH, and otherwise bootstraps a copy into `~/.local/bin`.

## Commands

```bash
./install                  # Run dotbot, bootstrap chezmoi, then chezmoi init --apply
pnpm run format            # Format JSON/YAML/MD with prettier
pnpm run lint              # Run all linting (format check + shellcheck + markdownlint)
pnpm run lint:shell        # Lint shell scripts only
pnpm run lint:md           # Lint markdown only
pnpm run lint:md:fix       # Auto-fix markdown issues
pnpm test                  # Run the test suite once
pnpm run test:watch        # Re-run on change
pnpm run typecheck         # tsc --noEmit over tests/
```

## Tests

Vitest, in TypeScript, under `tests/`. The subjects are shell, but every case
spawns a process and asserts on its exit status and stderr, so nothing is lost
by driving them from JS -- and the fixtures stop being shell, which is where
they kept breaking.

**Assert stderr, not just the exit status.** Mutation testing measured nine of
the thirteen `install` guards as message-only: deleting them leaves the exit code
unchanged, so a status-only suite stays green against a build with the guard
removed.

**The child's environment is built, never inherited.** `fixture.run()` passes an
explicit `env`, the equivalent of `env -i`. Inheriting it leaks the real `$HOME`,
the real chezmoi on PATH and mise's shims, and the result stops meaning
anything.

**Cases that need a tool skip rather than pass.** `realChezmoi()` and the zsh
probe gate their suites with `skipIf`, so a machine without them reports
skipped. An early `return` would report green while asserting nothing --
`pnpm test` without chezmoi on PATH shows 13 skipped.

`vitest.config.ts` carries three deliberate settings. `pool: 'forks'` is
load-bearing -- the threads pool restricts the process APIs these tests are
built on. `expect.requireAssertions` fails any test that asserts nothing, which
is how the `skipIf` mistake above would have been caught. `chaiConfig`
disables diff truncation, because every assertion here is on a long stderr
string and the default hides the differing part.

A failing test keeps its fixture and prints `fixture kept for inspection:
<path>`, holding the tree, the stubs and whatever the run left in `$HOME`.
Detection uses `task.result`, not `onTestFailed` -- measured, the latter does
not fire from the fixture's scope.

Point `DOTFILES_ZSHENV` at a copy to mutation-test `dot_zshenv` without touching
the real file.

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

- **`config/`** — Configs a tool rewrites, linked into `~/.config` by `symlink_*.tmpl` entries under `home/dot_config/` (kitty, mise, nvim, btop, zed, zellij's config.kdl)
- **`general/`** — Brewfile and cspell, linked into `~` the same way
- **`general/agents/`** — Global agent instructions: `AGENTS.global.md` links to `~/AGENTS.md` and `~/.codex/AGENTS.md`, `docs/` to `~/.agents/docs`. The `.global` suffix keeps agents in this repo from loading it as `general/agents/`'s project instructions.
- **`home/`** — chezmoi source, mirroring `~/` (`dot_zshrc` becomes `~/.zshrc`): zsh, starship, git, editorconfig, hushlogin, ghostty, sesh, bat, fastfetch, fff-gpui, tmux, zellij's layouts. `.chezmoiroot` points chezmoi here, and `home/.chezmoi.toml.tmpl` generates `~/.config/chezmoi/chezmoi.toml`. The `empty_` prefix on `empty_dot_hushlogin` is load-bearing: chezmoi deletes a target whose source file is zero bytes, so `dot_hushlogin` would remove `~/.hushlogin`.
- **`install.conf.yaml`** — Dotbot config, empty but for shell-output defaults
- **`config/macos/set-defaults.sh`** — macOS system defaults (not auto-run, manual script)

### Special Cases

- **Karabiner**: Cannot use symlinks (the app replaces them). `home/run_before_karabiner-sync.sh` copies the live file into the repo on every apply, and copies the repo's into place only while no live file exists.
- **Neovim**: Uses LazyVim. The `config/nvim/` directory is excluded from prettier via `.prettierignore`.
- **Zsh**: Uses Antidote plugin manager, and is chezmoi-managed. Plugins in `home/dot_config/zsh/dot_zsh_plugins.txt`, shell config split between `home/dot_zshenv` (all shells) and `home/dot_zshrc` (interactive).

## Style

- 2-space indentation, LF line endings, UTF-8
- JS/config files use single quotes, 100 char print width
- `package.json` has `"type": "module"` — config files use ESM exports
