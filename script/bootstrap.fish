#!/usr/bin/env fish
#
# bootstrap installs things.

set DOTFILES_ROOT (pwd -P)

function info
	echo [(set_color --bold blue) ' .. ' (set_color normal)] $argv
end

function user
	echo [(set_color --bold red) ' ?? ' (set_color normal)] $argv
end

function success
	echo [(set_color --bold green) ' OK ' (set_color normal)] $argv
end

function abort
	echo [(set_color --bold yellow) ABRT (set_color normal)] $argv
	exit 1
end

function on_exit -p %self
	if not contains $argv[3] 0
		echo [(set_color --bold red) FAIL (set_color normal)] "Couldn't setup dotfiles, please open an issue at https://github.com/caarlos0/dotfiles"
	end
end

for installer in config/*/install.fish
  $installer
    and success $installer
    or abort $installer
end

test (which fish) = $SHELL
  and success 'dotfiles installed!'
  and exit 0

success 'dotfiles installed!'
