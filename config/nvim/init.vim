"    ____      _ __        _
"   /  _/___  (_) /__   __(_)___ ___
"   / // __ \/ / __/ | / / / __ `__ \
" _/ // / / / / /__| |/ / / / / / / /
"/___/_/ /_/_/\__(_)___/_/_/ /_/ /_/

set nocp

let g:vim_home = get(g:, 'vim_home', expand('~/.config/nvim/'))

" Load all vim configs {{{
let config_list = [
      \ 'plugins/*.vim',
      \ 'extras/*.vim',
      \ 'general/*.vim',
      \ 'keys/*.vim',
      \]

for files in config_list
  for f in glob(g:vim_home.files, 1, 1)
    exec 'source' f
  endfor
endfor

" Appearance
exe 'source' stdpath('config') . '/themes/colorscheme.vim'
exe 'source' stdpath('config') . '/themes/lightline.vim'

" Set at the end to work around 'exrc'
set secure
