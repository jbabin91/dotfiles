#!/bin/sh
if command -v brew >/dev/null 2>&1; then
	brew() {
		case "$1" in
		cleanup)
			(cd "$(brew --repo)" && git prune && git gc)
			command brew cleanup
			rm -rf "$(brew --cache)"
			;;
		bump)
			command brew update
			command brew upgrade
			brew cleanup
			;;
		*)
			command brew "$@"
			;;
		esac
	}
fi

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