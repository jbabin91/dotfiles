" Enables true colors
if (has("termguicolors"))
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

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

" Remap tmux italic characters
" set t_ZH=^[[3m
" set t_ZR=^[[23m

" this will show italics if your terminal supports that
" hi Comment cterm=italic gui=italic