" Enables true colors
set termguicolors

" colorscheme
syntax on

" show matching brackets/parenthesis
set showmatch

" redraw only when we need to (i.e. don't redraw when executing a macro)
set lazyredraw

" get correct json comment highlighting
autocmd FileType json syntax match Comment +\/\/.\+$+

" show invisibles
set list
set listchars=
set listchars+=tab:·\ 
set listchars+=trail:·
set listchars+=extends:»
set listchars+=precedes:«
set listchars+=nbsp:░

" split style
set fillchars=vert:▒

" Keep focus split wide, others narrow.
set winwidth=90
set winminwidth=5

" Keep focus split at max height, others minimal.
set winheight=1
set winminheight=1

highlight clear IncSearch
highlight IncSearch term=reverse cterm=reverse ctermfg=7 ctermbg=0 guifg=Black guibg=White
highlight Comment cterm=italic gui=italic

exe 'source' stdpath('config') . '/lightline.vim'