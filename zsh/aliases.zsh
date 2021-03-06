#!/bin/zsh

# editor
alias e='code'

# General UNIX
alias c='clear'
alias cp='cp -iv'
alias df='df -h'
alias du='du -h'
alias dud='du -d 1 -h'
alias duf='du -sh *'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias path='echo -e ${PATH//:/\\n}'
alias pi='ping -Anc 5 1.1.1.1'
alias zr='source ~/.zshrc'
alias ze='e ~/.zshrc'
alias srm='srm -iv'
alias reload!='exec "$SHELL" -l'

# EXA
alias ls="exa"
alias ll="exa -ll"
alias la="exa -la --git --group-directories-first"

# Development
alias co='cd ~/code'
alias wo='cd ~/work'
alias cgo='cd $GOPATH/src/github.com/jbabin91'
alias ios='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# Moving around
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

# Homebrew
alias bc='brew cleanup'
alias bd='brew doctor'
alias bg='brew upgrade --all'
alias bo='brew outdated'
alias brews='brew list -1'
alias bs0='brew services stop'
alias bs1='brew services start'
alias bs='brew services'
alias bsc='brew services cleanup'
alias bsl='brew services list'
alias bsr='brew services restart'
alias bu='brew update'
alias bubc='brew upgrade && brew cleanup'
alias bubo='brew update && brew outdated'
alias bubu='bubo && bubc'
alias ud='bubu'

# Flutter
alias fu='flutter upgrade'
alias fd='flutter doctor'

# GIT GUD
alias yolo='git commit -m "$(curl -s http://whatthecommit.com/index.txt)"'

# GIT
alias git='bit'

alias gl='git pull --prune'
alias glg='git log --graph --decorate --oneline --abbrev-commit'
alias glga='glg --all'
alias gp='git sync'
# alias gp='git push origin HEAD'
alias gpa='git push origin --all'
alias gd='git diff'
alias gc='git commit -s'
alias gca='git commit -s -a'
alias gco='git checkout'
alias gb='git branch -v'
alias ga='git add'
alias gaa='git add -A'
alias gcm='git commit -s -a -m'
alias gs='git status -sb'
