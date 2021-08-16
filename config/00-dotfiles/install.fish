#!/usr/bin/env fish
set -Ux EDITOR nvim
set -Ux VISUAL $EDITOR
set -Ux WEDITOR code

set -Ux DOTFILES ~/.dotfiles
set -Ux PROJECTS ~/Code

set -Ua fish_user_paths $DOTFILES/bin $HOME/.bin

for f in $DOTFILES/config/*/functions
	set -Up fish_function_path $f
end

if test -f ~/.localrc.fish
	ln -sf ~/.localrc.fish ~/.config/fish/conf.d/localrc.fish
end
