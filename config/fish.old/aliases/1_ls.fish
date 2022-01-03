#!/usr/bin/env fish

switch $LS_SERVICE
  case exa
    alias ls "exa --color=always --group-directories-first --icons" # my preferred listing
    alias lg "exa --git --color=always --group-directories-first --icons"
    alias l "exa -lah --color=always --group-directories-first --icons"
    alias la "exa -a --color=always --group-directories-first --icons" # all files and dirs
    alias ll "exa -l --color=always --group-directories-first --icons" # long format
    alias lt "exa -aT --color=always --group-directories-first --icons" # tree listing
  case "*"
    alias l 'ls -lAh'
    alias la 'ls -A'
    alias ll 'ls -l'
end
