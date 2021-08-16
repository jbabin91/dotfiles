#!/usr/bin/env fish
# Changin "ls" to "exa"
if command -qa exa
	abbr -a ls 'exa --color=always --group-directories-first' # my preferred listing
	abbr -a lg 'exa --git --color=always --group-directories-first'
	abbr -a l 'exa -lah --color=always --group-directories-first'
	abbr -a la 'exa -a --color=always --group-directories-first' # all files and dirs
	abbr -a ll 'exa -l --color=always --group-directories-first' # long format
	abbr -a lt 'exa -aT --color=always --group-directories-first' # tree listing
  abbr -a l. 'exa -a1 $* | grep "^\."'
else
	abbr -a l 'ls -lAh'
	abbr -a la 'ls -A'
	abbr -a ll 'ls -l'
end
