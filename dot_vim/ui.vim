" Enables true colors
set termguicolors

" colorscheme
syntax on

" show matching brackets/parenthesis
set showmatch

" show line numbers
set number
set numberwidth=2

" no line wrapping
set nowrap

" Highlight current line
set cursorline

" Highlight all search matches
set hlsearch

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