#!/usr/bin/env fish

if test -d ~/.config/doom
    echo "DOOM Emacs personal configuration already set up"
else
    # echo "Cloning personal configuration.."
    # echo "git clone git@github.com:Flirre/.doom.d.git ~/.config/doom"
    # and echo \n"Successfully cloned personal configuration"\n\n
    # or echo \n"Failed to clone personal configuration"\n\n
end

if test -d ~/.doom-emacs.d
    echo "DOOM Emacs is already downloaded"
else
    echo "Cloning DOOM Emacs.."
    git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.doom-emacs.d
    and echo "Successfully cloned DOOM Emacs"\n\n
    or echo "Failed to clone DOOM Emacs"\n\n
end

if not test -d ~/.doom-emacs/.local/straight
    echo "Installing DOOM Emacs.."
    ~/.doom-emacs/bin/doom install
    and echo "Successfully installed DOOM Emacs"\n\n
    or echo "Failed to install DOOM Emacs"\n\n
    echo "Compiling DOOM Emacs.."
    ~/.doom-emacs/bin/doom compile
    and "Successfully compiled DOOM Emacs"\n\n
    or echo "failed to compile DOOM Emacs"\n\n
else
    echo "DOOM Emacs already installed"
end

# Add doom to path if not already added.
if not contains $HOME/.doom-emacs/bin $fish_user_paths
    echo "Adding DOOM to user path"
    set -Ua fish_user_paths ~/.doom-emacs/bin
else
    echo "DOOM Emacs already present on path"
end
