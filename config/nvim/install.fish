#!/usr/bin/env fish
if ! test $HOME/.local/share/nvim/site/autoload/plug.vim
  curl -sfLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +'PlugUpdate | PlugInstall --sync' +qa
end


