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
Plug 'scrooloose/nerdtree' "" A tree explorer
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'valloric/listtoggle'
Plug 'majutsushi/tagbar'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mbbill/undotree'
Plug 'w0rp/ale'

"----------------------------------------------------------------
" 5. Autocomplete
"----------------------------------------------------------------
Plug 'Shougo/deoplete.nvim', { 'commit': '17ffeb9', 'do': 'UpdateRemotePlugins' }
Plug 'Shougo/neosnippet.vim', { 'commit': '037b7a7' }
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/context_filetype.vim'
Plug 'ervandew/supertab'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
" Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
" Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}
" Plug 'weirongxu/coc-explorer', {'do': 'yarn install --frozen-lockfile'}
" Plug 'marlonfan/coc-phpls', {'do': 'yarn install --frozen-lockfile'}"

"----------------------------------------------------------------
" 6. Languages
"----------------------------------------------------------------
" C/C++ support
Plug 'Rip-Rip/clang_complete'
" Go support
Plug 'fatih/vim-go', { 'tag': 'v1.19' }
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
" CSS support
Plug 'JulesWang/css.vim'
Plug 'hail2u/vim-css3-syntax'
" HTML support
Plug 'othree/html5.vim'
" VimL support
Plug 'Shougo/neco-vim', { 'commit' : '4c0203b' }

"----------------------------------------------------------------
" 7. Syntax files support
"----------------------------------------------------------------
Plug 'Shougo/neco-syntax'

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
" 9. Misc
"----------------------------------------------------------------
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-characterize'
Plug 'tyru/open-browser.vim'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/goyo.vim'
Plug 'mattn/webapi-vim'
Plug 'mattn/emmet-vim'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'thiagoalessio/rainbow_levels.vim'
Plug 'RRethy/vim-illuminate'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'mrded/vim-wrapper'
Plug 'tpope/vim-commentary'
Plug 'fvictorio/vim-extract-variable'
" Plug 'terryma/vim-multiple-cursors'
Plug 'dyng/ctrlsf.vim'
Plug 'liuchengxu/vim-clap'

"----------------------------------------------------------------
" 10. Color scheme
"----------------------------------------------------------------
Plug 'morhetz/gruvbox'
" Plug 'gerardbm/vim-atomic'

" Initialize plugin system
call plug#end()