" Mappings {{{
" let mapleader = "\<Space>"

" Misc
" map <leader>r :source $XDG_CONFIG_HOME/nvim/init.vim<CR>
" map <leader>q :q<CR>
" map <leader>w :w<CR>
" map <leader>x :x<CR>
" map <leader>ra :%s/
" map <leader>h :nohl<CR> " Clear highlights
" map <leader>s :%s/\s\+$//e<CR> " Manually clear trailing whitespace
" inoremap jj <C-c> " jj to switch back to normal mode
" nnoremap <leader>4 <c-^> " Switch between the last two files
" nnoremap <leader>5 :bnext<CR>
" nnoremap <leader>6 :bprev<CR>
" map <C-t> <esc>:tabnew<CR> " Open a new tab with Ctrl+T

" Expand active file directory
" cnoremap <expr> %%  getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Delete all lines beginning with '#' regardless of leading space.
" map <leader>d :g/^\s*#.*/d<CR>:nohl<CR>

" Run 'git blame' on a selection of code
" vmap <leader>gb :<C-U>!git blame <C-R>=expand("%:p") <CR> \| sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>

" zoom a vim pane like in tmux
" nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>

" Adjust split size incrementally
" nnoremap <C-Up> :resize +2<CR>
" nnoremap <C-Down> :resize -2<CR>
" nnoremap <C-Left> :vertical resize +2<CR>
" nnoremap <C-Right> :vertical resize -2<CR>

" zoom back out
" nnoremap <leader>= :wincmd =<cr>

" Maximize the height of the current window.
" nnoremap <leader>0 :wincmd _<cr>

" Write files as sudo
" cmap w!! w !sudo tee >/dev/null %
" }}}

" Better indenting
vnoremap < <gv
vnoremap > >gv

if exists('g:vscode')
  " Simulate same TAB behavior in VSCode
  nmap <Tab> :Tabnext<CR>
  nmap <S-Tab> :Tabprev<CR>
else
  " Better nav for omnicomplete
  inoremap <expr> <c-j> ("\<C-n>")
  inoremap <expr> <c-k> ("\<C-p>")

  " I hate escape more than anything else
  inoremap jk <Esc>
  inoremap kj <Esc>

  " One of the most annoying things about vim was that I frequently typed :W instead of :w.
  command! W w

  " Easy CAPS
  " inoremap <c-u> <ESC>viwUi
  " nnoremap <c-u> viwU<Esc>

  " TAB in general mode will move to text buffer
  nnoremap <TAB> :bnext<CR>
  " SHIFT-TAB will go back
  nnoremap <S-TAB> :bprevious<CR>

  " Alternate way to save
  nnoremap <C-s> :w<CR>
  " Alternate way to quit
  nnoremap <C-Q> :wq!<CR>
  " Use control-c instead of escape
  nnoremap <C-c> <Esc>
  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"


  " Better window navigation
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l

  " Use alt + hjkl to resize windows
  nnoremap <M-j>    :resize -2<CR>
  nnoremap <M-k>    :resize +2<CR>
  nnoremap <M-h>    :vertical resize -2<CR>
  nnoremap <M-l>    :vertical resize +2<CR>
endif
