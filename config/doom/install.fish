#!/usr/bin/env fish

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

# Implement this if pulling doom config from a different repo.
# if test -d ~/.config/doom
#     info "DOOM Emacs personal configuration already set up"
# else
    # info "Cloning personal configuration.."
    # # configure this with repo containing doom configs
    # echo "git clone git@github.com:Flirre/.doom.d.git ~/.config/doom"
    # and success "Successfully cloned personal configuration"
    # or abort "Failed to clone personal configuration"
# end

if test -d ~/.doom-emacs.d
    info "DOOM Emacs is already downloaded"
else
    info "Cloning DOOM Emacs.."
    git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.doom-emacs.d
    and success "Successfully cloned DOOM Emacs"
    or abort "Failed to clone DOOM Emacs"
end

if not test -d ~/.doom-emacs/.local/straight
    info "Installing DOOM Emacs.."
    ~/.doom-emacs/bin/doom install
    and success "Successfully installed DOOM Emacs"
    or abort "Failed to install DOOM Emacs"
    info "Compiling DOOM Emacs.."
    ~/.doom-emacs/bin/doom compile
    and success "Successfully compiled DOOM Emacs"
    or abort "failed to compile DOOM Emacs"
else
    info "DOOM Emacs already installed"
end

# Add doom to path if not already added.
if not contains $HOME/.doom-emacs/bin $fish_user_paths
    info "Adding DOOM to user path"
    set -Ua fish_user_paths ~/.doom-emacs/bin
    and success "Sucessfully added DOOM to user path"
    or abort "failed to add DOOM to user path"
else
    info "DOOM Emacs already present on path"
end
