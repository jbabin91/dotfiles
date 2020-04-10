" Don't try to be vi compatible
" must be first, because it changes other options as a side effect
set nocompatible

" security
set modelines=0

" hide buffers, not close them
set hidden

" maintain undo history between sessions
set undofile
set undodir=~/.vim/undo
set noswapfile

" fuzzy find
set path+=**
" lazy file name tab completion
set wildmode=longest,list,full
set wildmenu
set wildignorecase
" ignore files vim doesnt use
set wildignore+=.git,.hg,.svn
set wildignore+=*.aux,*.out,*.toc
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class
set wildignore+=*.ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp
set wildignore+=*.avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg
set wildignore+=*.mp3,*.oga,*.ogg,*.wav,*.flac
set wildignore+=*.eot,*.otf,*.ttf,*.woff
set wildignore+=*.doc,*.pdf,*.cbr,*.cbz
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb
set wildignore+=*.swp,.lock,.DS_Store,._*

" make backspace behave in a sane manner
set backspace=indent,eol,start

" use utf-8 encoding
set encoding=utf-8

let mapleader = ","   "remap leader to ',' which is much easier than '\'
let maplocalleader = "\\" "add a local leader of '\'

" Enable spell check
set spelllang=en_us

" Fix problem with backspace
set backspace=2

set ignorecase
set smartcase
set infercase
set smarttab

" Turns off old regexp engine
set re=1

" Tab settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
" set expandtab

" tabs are tabs
set noexpandtab

" enable auto indentation
set autoindent

" Split screen
set splitbelow
set splitright

" searching
set hlsearch
set incsearch
if has("nvim")
  set inccommand=split
endif

" Enable mouse
" set mouse=a

" Following
set foldmethod=syntax
set foldlevelstart=20 " All folds open when opening a file

" coffee pasta
set clipboard^=unnamedplus

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