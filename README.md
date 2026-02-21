# github.com/jbabin91/dotfiles

Jace Babin's dotfiles, managed with [Dotbot](https://github.com/anishathalye/dotbot) via
[uv](https://github.com/astral-sh/uv).

## Features

- **Zsh** with [Antidote](https://getantidote.github.io/) plugin manager
- **[Starship](https://starship.rs/)** prompt
- **[Ghostty](https://ghostty.org/)** terminal (with [Kitty](https://sw.kovidgoyal.net/kitty/) as an alternative)
- **[mise](https://mise.jdx.dev/)** for tool version management (uv, .NET)
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org/)** keyboard customization
- **[Homebrew](https://brew.sh/)** package management via Brewfile
- **[Lefthook](https://github.com/evilmartians/lefthook)** git hooks with Prettier, Shellcheck, and markdownlint
- **[fastfetch](https://github.com/fastfetch-cli/fastfetch)** system information
- **[tmux](https://github.com/tmux/tmux)** terminal multiplexer
- **[Neovim](https://neovim.io/)** with [LazyVim](https://www.lazyvim.org/)
- **[bat](https://github.com/sharkdp/bat)** syntax-highlighted file viewer
- **[btop](https://github.com/aristocratos/btop)** system monitor

## Installation

### Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- [uv](https://github.com/astral-sh/uv) (`brew install uv`)

### Quick Start

1. Clone this repository:

```bash
git clone https://github.com/jbabin91/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the install script to symlink configuration files:

```bash
./install
```

3. Install Homebrew packages:

```bash
brew bundle --global
```

4. Install development dependencies:

```bash
pnpm install
```

5. Restart your shell:

```bash
exec zsh
```

## Configuration Structure

```sh
~/.dotfiles/
├── config/
│   ├── bat/            # bat syntax highlighter
│   ├── fastfetch/      # System information display
│   ├── ghostty/        # Ghostty terminal
│   ├── btop/           # btop system monitor
│   ├── karabiner/      # Keyboard customization (copy-synced)
│   ├── kitty/          # Kitty terminal
│   ├── mise/           # Tool version manager (uv, dotnet)
│   ├── nvim/           # Neovim config (LazyVim)
│   ├── starship/       # Starship prompt
│   ├── tmux/           # Terminal multiplexer
│   └── zsh/            # Zsh shell config + Antidote plugins
├── general/
│   ├── git/            # Git config, attributes, ignore
│   ├── .cspell/        # Spell checking dictionaries
│   └── Brewfile        # Homebrew packages, casks, VS Code extensions
├── install.conf.yaml   # Dotbot symlink configuration
├── lefthook.yml        # Git hooks
├── prettier.config.js  # Code formatting
└── .markdownlint-cli2.mjs  # Markdown linting
```

### Karabiner

Karabiner-Elements replaces symlinks when it writes config, so it uses a
bidirectional copy sync instead of a symlink. Running `./install` will sync
the latest version in either direction.

## Version Management

All tool versions are managed through [mise](https://mise.jdx.dev/):

- **Python** — [uv](https://github.com/astral-sh/uv) with automatic version switching
- **Node.js** — [fnm](https://github.com/Schniz/fnm) with automatic version switching
- **.NET** — SDK managed via mise

## Development

### Available Scripts

```bash
pnpm run format        # Format JSON/YAML/MD files
pnpm run format:check  # Check formatting
pnpm run lint          # Run all linting
pnpm run lint:shell    # Lint shell scripts
pnpm run lint:md       # Lint markdown files
```

### Git Hooks

Pre-commit hooks automatically:

- Format files with Prettier
- Lint shell scripts with Shellcheck
- Lint markdown with markdownlint
- Validate commit messages with commitlint (conventional commits)

## License

MIT
