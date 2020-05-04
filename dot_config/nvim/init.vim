"    ____      _ __        _
"   /  _/___  (_) /__   __(_)___ ___
"   / // __ \/ / __/ | / / / __ `__ \
" _/ // / / / / /__| |/ / / / / / / /
"/___/_/ /_/_/\__(_)___/_/_/ /_/ /_/

set nocp

let g:vim_home = get(g:, 'vim_home', expand('~/.vim/'))

" Load all vim configs {{{1
let config_list = [
      \ 'plugins.vim',
      \ 'config.vim',
      \ 'ui.vim',
      \ 'mappings.vim',
      \ 'lua/*.lua'
      \ 'plugin_configs/*.vim'
      \]
for files in config_list
  for f in glob(g:vim_home.files, 1, 1)
    exec 'source' f
  endfor
endfor

" Set at the end to work around 'exrc'
set secure