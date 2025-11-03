# github.com/jbabin91/dotfiles

Jace Babin's dotfiles, managed with [`dotbot`](https://github.com/anishathalye/dotfiles_template).

## Features

- 🐚 **Zsh** - Shell configuration with Sheldon plugin manager
- 🎨 **Starship** - Fast, customizable prompt
- 🦀 **Rust Tools** - hk, taplo, and other Rust-based CLI tools via mise
- 🐍 **Python** - Modern Python management with uv (auto-switching versions)
- 🔧 **mise** - Multi-language tool version manager (replaces pyenv, nvm-like)
- 💻 **.NET** - .NET 9 SDK via mise
- 📦 **pnpm** - Fast, efficient package manager
- 🪝 **Lefthook** - Git hooks for linting and formatting
- ✨ **Prettier** - Auto-formatting for JSON, YAML, Markdown
- 🔍 **Shellcheck** - Shell script linting

## Installation

### Prerequisites

- macOS (tested on macOS)
- Homebrew

### Quick Start

1. Clone this repository:

```bash
git clone https://github.com/jbabin91/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the install script:

```bash
./install
```

This will:

- Symlink configuration files to their proper locations
- Install Homebrew packages from Brewfile
- Set up git hooks with lefthook

3. Install development dependencies:

```bash
pnpm install
```

### Post-Installation

After installation, restart your shell or run:

```bash
exec zsh
```

## Configuration Structure

### Shell Configuration

- `.zshenv` - Environment variables for ALL shells (git hooks, scripts, interactive)
- `.zshrc` - Interactive shell configuration
- `config/zsh/env.sh` - Interactive-only environment variables
- `config/zsh/aliases.sh` - Shell aliases and functions
- `config/zsh/completions.sh` - Shell completions

### Tool Configuration

- `config/mise/config.toml` - Global tool versions (uv, dotnet)
- `config/sheldon/plugins.toml` - Zsh plugin management
- `.prettierrc` - Prettier formatting rules
- `.shellcheckrc` - Shellcheck linting rules
- `lefthook.yml` - Git hooks configuration

## Version Management

### Python (uv)

This setup uses [uv](https://github.com/astral-sh/uv) for Python management with automatic
version switching:

- Global Python 3.13 (via `~/.config/uv/.python-version`)
- Auto-switches based on `.python-version` or `pyproject.toml` in project directories
- Works in git hooks and scripts

### Node (fnm)

Fast Node Manager with automatic version switching via `.node-version` files.

### .NET (mise)

.NET SDK managed globally via mise at version 9.0.306.

## Development

### Available Scripts

```bash
pnpm run format        # Format all JSON/YAML/MD files
pnpm run format:check  # Check formatting
pnpm run lint:shell    # Lint shell scripts
pnpm run lint          # Run all linting
```

### Git Hooks

Pre-commit hooks automatically:

- Format JSON, YAML, and Markdown files with Prettier
- Lint shell scripts with Shellcheck
- Auto-stage fixed files

## Notes

- Installation is intended for macOS and has not been tested on Linux or Windows
- Shell configuration follows official zsh startup file best practices
- Git hooks require pnpm dependencies to be installed

## License

MIT
