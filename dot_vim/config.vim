" use utf-8 encoding
set encoding=utf-8

let mapleader = ","   "remap leader to ',' which is much easier than '\'
let maplocalleader = "\\" "add a local leader of '\'

" Enables true colors
if (has("termguicolors"))
  set termguicolors
endif

" colorscheme
syntax on

" Don't try to be vi compatible
set nocompatible

" Enable spell check
set spelllang=en_us

" Fix problem with backspace
set backspace=2

" show line numbers
set number
set numberwidth=2

" Highlight current line
set cursorline

" Highlight all search matches
set hlsearch

set ignorecase
set smartcase
set smarttab

" Turns off old regexp engine
set re=1

" Tab settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Split screen
set splitbelow
set splitright

" Enable mouse
" set mouse=a

" Following
set foldmethod=syntax
set foldlevelstart=20 " All folds open when opening a file

" get correct json comment highlighting
autocmd FileType json syntax match Comment +\/\/.\+$+

" tmux will only forward escape sequences to the terminal if surrounded by a
" DCS sequences
" "
" http://sourceforge.net/mailarchive/forum.php?thread_name=AANLkTinkbdoZ8eNR1X2UobLTeww1jFrvfJxTMfKSq-L%2B%40mail.gmail.com&forum_name=tmux-users
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif