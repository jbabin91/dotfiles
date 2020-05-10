" I use vim-plug for pluggins: https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

"----------------------------------------------------------------
" 1. Statusbar
"----------------------------------------------------------------
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"----------------------------------------------------------------
" 2. Git tools
"----------------------------------------------------------------
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

"----------------------------------------------------------------
" 3. Sessions
"----------------------------------------------------------------
Plug 'xolox/vim-session'
Plug 'xolox/vim-misc'

"----------------------------------------------------------------
" 4. Tools
"----------------------------------------------------------------
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tsony-tsonev/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'valloric/listtoggle'
Plug 'majutsushi/tagbar'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mbbill/undotree'
Plug 'dense-analysis/ale'
Plug 'justinmk/vim-sneak'
Plug 'unblevable/quick-scope'

"----------------------------------------------------------------
" 5. Autocomplete
"----------------------------------------------------------------
" Plug 'Shougo/deoplete.nvim', { 'commit': '17ffeb9', 'do': 'UpdateRemotePlugins' }
" Plug 'Shougo/neosnippet.vim', { 'commit': '037b7a7' }
" Plug 'Shougo/neosnippet-snippets'
" Plug 'Shougo/context_filetype.vim'
" Plug 'ervandew/supertab'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}
Plug 'marlonfan/coc-phpls', {'do': 'yarn install --frozen-lockfile'}"
Plug 'josa42/coc-go', {'do': 'yarn install --frozen-lockfile'}"

" Tab completion
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'

" Language Specific Snippets
Plug 'greg-js/vim-react-es6-snippets'

"----------------------------------------------------------------
" 6. Languages
"----------------------------------------------------------------
" C/C++ support
Plug 'Rip-Rip/clang_complete'
" Go support
Plug 'fatih/vim-go', { 'tag': 'v1.19', 'do': ':GoInstallBinaries' }
Plug 'nsf/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }
Plug 'zchee/deoplete-go', { 'do': 'make', 'commit': 'fa73f06'}
" Perl support
Plug 'c9s/perlomni.vim'
" Python support
Plug 'deoplete-plugins/deoplete-jedi', { 'commit': '46121d9' }
" Ruby support
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-liquid'
" PHP support
Plug 'shawncplus/phpcomplete.vim'
" Haskell support
Plug 'eagletmt/neco-ghc'
" Rust support
Plug 'racer-rust/vim-racer'
" Zsh support
Plug 'zchee/deoplete-zsh', { 'commit': '12141ad' }
" JavaScript support
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'othree/jspc.vim'
Plug 'maksimr/vim-jsbeautify'
Plug 'yuezk/vim-js'
Plug 'glanotte/vim-jasmine'
" TypeScript support
Plug 'HerringtonDarkholme/yats.vim'
" CSS support
Plug 'JulesWang/css.vim'
Plug 'hail2u/vim-css3-syntax'
" HTML support
Plug 'othree/html5.vim'
" VimL support
Plug 'Shougo/neco-vim', { 'commit' : '4c0203b' }
" .env syntax highlighting
Plug 'tpope/vim-dotenv'

"----------------------------------------------------------------
" 7. Syntax files support
"----------------------------------------------------------------
Plug 'Shougo/neco-syntax'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'ntpeters/vim-better-whitespace'

"----------------------------------------------------------------
" 8. Edition
"----------------------------------------------------------------
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'wellle/targets.vim'
Plug 'christoomey/vim-sort-motion'
Plug 'terryma/vim-expand-region'
Plug 'Valloric/MatchTagAlways'
Plug 'FooSoft/vim-argwrap'
Plug 'gerardbm/vim-md-headings'

"----------------------------------------------------------------
" 9. Search
"----------------------------------------------------------------
Plug 'henrik/vim-indexed-search'                     " Gives a count of the number of matches, configured to stay on current match with indexed_search_dont_move=1
Plug 'nelstrom/vim-visual-star-search'               " Don't jump to the next search, stay on current one
Plug 'haya14busa/incsearch.vim'                      " better incremental search, highlights in realtime everywhere as you type
Plug 'henrik/vim-qargs'                              " Project wide find and replace http://thepugautomatic.com/2012/07/project-wide-search-and-replace-in-vim-with-qdo/
Plug 'junegunn/fzf',
      \ { 'dir': '~/.fzf', 'do': './install --all' } " Fuzzy Find
Plug 'mileszs/ack.vim'                               " project wide search
Plug 'yssl/QFEnter'                                  " open splits from quickfix

"----------------------------------------------------------------
" 10. Writing
"----------------------------------------------------------------
Plug 'itspriddle/vim-marked'
Plug 'kana/vim-textobj-user'
Plug 'plasticboy/vim-markdown'
Plug 'reedes/vim-lexical'
Plug 'reedes/vim-litecorrect'
Plug 'reedes/vim-pencil'
Plug 'reedes/vim-textobj-quote'
Plug 'reedes/vim-textobj-sentence'
Plug 'suan/vim-instant-markdown'

"----------------------------------------------------------------
" 11. Dash Docs
"----------------------------------------------------------------
if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    " Do Mac stuff here
    Plug 'rizzatti/funcoo.vim'
    Plug 'rizzatti/dash.vim'
  endif
endif

"----------------------------------------------------------------
" 11. Misc
"----------------------------------------------------------------
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-characterize'
Plug 'tyru/open-browser.vim'
Plug 'sheerun/vim-polyglot'
Plug 'mattn/emmet-vim'
Plug 'jonhiggs/MacDict.vim'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'mattn/calendar-vim'
Plug 'thiagoalessio/rainbow_levels.vim'
Plug 'RRethy/vim-illuminate'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'mrded/vim-wrapper'
Plug 'tpope/vim-commentary'
Plug 'jbgutierrez/vim-better-comments'
Plug 'fvictorio/vim-extract-variable'
" Plug 'terryma/vim-multiple-cursors'
Plug 'dyng/ctrlsf.vim'
Plug 'liuchengxu/vim-clap'
Plug 'kamykn/spelunker.vim'
Plug 'liuchengxu/vim-which-key'
Plug 'mhinz/vim-startify'

"----------------------------------------------------------------
" 12. Color scheme
"----------------------------------------------------------------
" Plug 'morhetz/gruvbox'
" Plug 'gerardbm/vim-atomic'
" Plug 'drewtempelmeyer/palenight.vim'
Plug 'arcticicestudio/nord-vim'

"----------------------------------------------------------------
" 13. Plugins that should be loaded last
"----------------------------------------------------------------
Plug 'ryanoasis/vim-devicons'

" Initialize plugin system
call plug#end()

" Vim Plug automatically manage plugin installing and cleaning on load
let s:need_install = keys(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
let s:need_clean = len(s:need_install) + len(globpath(g:plug_home, '*', 0, 1)) > len(filter(values(g:plugs), 'stridx(v:val.dir, g:plug_home) == 0'))
let s:need_install = join(s:need_install, ' ')
if has('vim_starting')
  if s:need_clean
    autocmd VimEnter * PlugClean!
  endif
  if len(s:need_install)
    execute 'autocmd VimEnter * PlugInstall --sync' s:need_install '| source $MYVIMRC'
    finish
  endif
else
  if s:need_clean
    PlugClean!
  endif
  if len(s:need_install)
    execute 'PlugInstall --sync' s:need_install '| source $MYVIMRC'
    finish
  endif
endif""

"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
