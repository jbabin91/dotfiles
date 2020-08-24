" Don't try to be vi compatible
" must be first, because it changes other options as a side effect
set nocompatible

" security
set modelines=0

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

" Enable spell check
set spelllang=en_us

" Fix problem with backspace
set backspace=2

set ignorecase
set smartcase
set infercase
set smarttab

" Force vim to use older regex engine.
" https://stackoverflow.com/a/16920294/655204
set re=1

" Set built-in file system explorer to use layout similar to the NERDTree plugin
let g:netrw_liststyle=3

set grepprg=rg

let g:grep_cmd_opts = '--line-numbers --noheading --ignore-dir=log --ignore-dir=tmp'

" tabs are tabs
set noexpandtab

" enable auto indentation
set autoindent

" Enable built-in matchit plugin
runtime macros/matchit.vim

" searching
set hlsearch
set incsearch

set inccommand=nosplit

" Enable mouse
" set mouse=a

" Following
set foldmethod=syntax
set foldlevelstart=20 " All folds open when opening a file

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
