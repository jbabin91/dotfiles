#!/usr/bin/env fish
if ! test ~/.vim/autoload/plug.vim
  curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +'PlugUpdate | PlugInstall --sync' +qa
end
