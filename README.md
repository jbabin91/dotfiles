# github.com/jbabin91/dotfiles

Jace Babin's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

## Installation

### _Installation is intended for MacOS and has not been tested on Linux or Windows_

1. Install [chezmoi](https://github.com/twpayne/chezmoi)
   - `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
   - `brew install twpayne/taps/chezmoi`

2. Init dotfiles
   - `chezmoi init --apply https://github.com/jbabin91/dotfiles.git`
