#!/usr/bin/env fish

# General UNIX
alias c clear
alias df 'df -h'
alias du 'du -h'
alias dud 'du -d 1 -h'
alias duf 'du -sh *'
alias mkdir 'mkdir -pv'
alias mv 'mv -iv'

# Config dir access
alias cdot 'cd $DOTFILES'
alias cdxc 'cd $XDG_CONFIG_HOME'
alias cdfi 'cd $XDG_CONFIG_HOME/fish'
alias cdnv 'cd $XDG_CONFIG_HOME/nvim'
alias cdxd 'cd $XDG_DATA_HOME'
alias cdxa 'cd $XDG_CACHE_HOME'

# Moving around
alias .. 'cd ..'
alias ... 'cd ../../'
alias .... 'cd ../../../'
alias ..... 'cd ../../../../'

# Tree
alias t1 'tree -CFL 1'
alias t1a 'tree -CFLa 1'
alias t2 'tree -CFL 2'
alias t2a 'tree -CFLa 2'
alias t3 'tree -CFL 3'
alias t3a 'tree -CFLa 3'
alias t4 'tree -CFL 4'
alias t4a 'tree -CFLa 4'
alias tree 'tree -CF'
alias t 'tree -CF'

# Misc
alias neo 'neofetch'
alias one 'onefetch'
alias ch 'cht.sh'
alias chs 'cht.sh --shell'
alias color 'colortest -w -s'
alias cv 'command -v'
alias ra 'ranger'
alias spt 'speedtest'

# Tmux
alias tl 'tmux ls'
alias tlw 'tmux list-windows'
alias mux 'tmuxinator'

# Neovim
alias v 'nvim'
alias vi 'nvim'
alias vi0 'nvim -u NONE'
alias vim 'vim'
alias vir 'nvim -R'
alias vs 'nvim -S'
alias vv 'nvim --version | less'

# Fish commpands
alias fr 'omf reload'
# https://fishshell.com/docs/current/commands.html#fish_update_completions
alias ucl 'fish_update_completions'

# Homebrew
alias b 'brew'
alias bc 'brew cask'
alias bci 'brew cask install'
alias bcl 'brew cask list'
alias bcr 'brew cask reinstall'
alias bcz 'brew cask zap'
alias bd 'brew doctor'
alias bg 'brew upgrade'
alias bi 'brew info'
alias bo 'brew outdated'
alias bp 'brew cleanup'
alias brews 'brew list -1'
alias bs 'brew search'
alias bs0 'brew services stop'
alias bs1 'brew services start'
alias bsc 'brew services cleanup'
alias bsl 'brew services list'
alias bsr 'brew services restart'
alias bsv 'brew services'
alias bu 'brew update && brew upgrade'
