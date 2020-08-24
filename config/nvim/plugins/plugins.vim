" Vim-plug Setup
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | exe 'source' stdpath('config') . '/init.vim'
endif
unlet autoload_plug_path

" I use vim-plug for pluggins: https://github.com/junegunn/vim-plug
call plug#begin(stdpath('data') . '/plugged')

" General
Plug 'godlygeek/tabular'                " Vim script for text filtering and alignment           | https://github.com/godlygeek/tabular
Plug 'tomtom/tcomment_vim'              " An extensible & universal comment vim-plugin          | https://github.com/tomtom/tcomment_vim
Plug 'vim-scripts/BufOnly.vim'          " Delete all the buffers except current/named buffer    | https://github.com/vim-scripts/BufOnly.vim
Plug 'jlanzarotta/bufexplorer'          " Open/close/navigate vim's buffers                     | https://github.com/jlanzarotta/bufexplorer
Plug 'majutsushi/tagbar'                " A class outline viewer for vim                        | https://github.com/majutsushi/tagbar
Plug 'ntpeters/vim-better-whitespace'   " Better whitespace highlighting for                    | https://github.com/ntpeters/vim-better-whitespace
Plug 'machakann/vim-highlightedyank'    " Make the yanked region apparent!                      | https://github.com/machakann/vim-highlightedyank
Plug 'diepm/vim-rest-console'           " A REST console for Vim.                               | https://github.com/diepm/vim-rest-console
Plug 'rhysd/git-messenger.vim'          " Reveal the commit messages under the cursor           | https://github.com/rhysd/git-messenger.vim
Plug 'terryma/vim-multiple-cursors'     " True Sublime Text style multiple selections for Vim   | https://github.com/terryma/vim-multiple-cursors
Plug 'airblade/vim-gitgutter'           " A Vim plugin which shows a git diff in the gutter     | https://github.com/airblade/vim-gitgutter
Plug 'reedes/vim-textobj-quote'         " Use ‘curly’ quote characters in Vim                   | https://github.com/reedes/vim-textobj-quote
Plug 'norcalli/nvim-colorizer.lua'      " The fastest Neovim colorizer.                         | https://github.com/norcalli/nvim-colorizer.lua

" Code Completion
Plug 'neoclide/coc.nvim',
      \ {'branch': 'release'}                         " Intellisense engine for vim8 & neovim   | https://github.com/neoclide/coc.nvim
Plug 'sdras/vue-vscode-snippets'                      " Vue VSCode Snippets                     | https://github.com/sdras/vue-vscode-snippets
Plug 'mattn/emmet-vim'                                " emmet for vim                           | https://github.com/mattn/emmet-vim
Plug 'joshukraine/vscode-es7-javascript-react-snippets',
      \ { 'do': 'yarn install --frozen-lockfile && yarn compile' } " React VSCode snippets      | https://github.com/joshukraine/vscode-es7-javascript-react-snippets

" Ruby-specific
Plug 'vim-ruby/vim-ruby'                " Vim/Ruby Configuration Files                          | https://github.com/vim-ruby/vim-ruby
Plug 'kana/vim-textobj-user'            " Create your own text objects                          | https://github.com/kana/vim-textobj-user
Plug 'nelstrom/vim-textobj-rubyblock'   " A custom text object for selecting ruby blocks        | https://github.com/nelstrom/vim-textobj-rubyblock

" Searching and Navigation
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'              " A tree explorer plugin for vim                        | https://github.com/scrooloose/nerdtree
Plug 'jistr/vim-nerdtree-tabs'          " A plugin for NERDTree making it independent of tabs.  | https://github.com/jistr/vim-nerdtree-tabs
Plug 'Xuyuanp/nerdtree-git-plugin'      " A plugin of NERDTree showing git status               | https://github.com/Xuyuanp/nerdtree-git-plugin
Plug 'brooth/far.vim'                   " Find And Replace Vim plugin                           | https://github.com/brooth/far.vim
Plug 'christoomey/vim-tmux-navigator'   " Seamless navigation between tmux panes and vim splits | https://github.com/christoomey/vim-tmux-navigator
Plug 'easymotion/vim-easymotion'        " Vim motions on speed!                                 | https://github.com/easymotion/vim-easymotion
Plug 'ryanoasis/vim-devicons'           " Adds file type icons to Vim                           | https://github.com/ryanoasis/vim-devicons
Plug 'itchyny/lightline.vim'            " Light/configurable statusline/tabline plugin for Vim  | https://github.com/itchyny/lightline.vim

" Colorschemes
Plug 'icymind/NeoSolarized'             " Solarized colorscheme with better truecolor support   | https://github.com/icymind/NeoSolarized
Plug 'haishanh/night-owl.vim'           " Vim colorscheme based on sdras/night-owl-vscode-theme | https://github.com/haishanh/night-owl.vim
Plug 'kaicataldo/material.vim'          " A port of the Material color scheme for Vim/Neovim    | https://github.com/kaicataldo/material.vim
Plug 'rakr/vim-one'                     " Adaptation of Atom One colorscheme for Vim            | https://github.com/rakr/vim-one
Plug 'bluz71/vim-nightfly-guicolors'    " Another dark color scheme for Vim                     | https://github.com/bluz71/vim-nightfly-guicolors
Plug 'sonph/onehalf', {'rtp': 'vim/'}   " A colorscheme for (Neo)Vim, iTerm, and more.          | https://github.com/sonph/onehalf
Plug 'arcticicestudio/nord-vim'         " Vim colorscheme based on the Nord color palette       | https://github.com/arcticicestudio/nord-vim
Plug 'joshukraine/oceanic-next',
      \ {'branch': 'js/color-tweaks'}   " Oceanic Next theme for neovim                         | https://github.com/joshukraine/oceanic-next
Plug 'jacoborus/tender.vim'             " A 24bit colorscheme for Vim, Airline and Lightline    | https://github.com/jacoborus/tender.vim
Plug 'morhetz/gruvbox'                  " Retro groove color scheme for Vim                     | https://github.com/morhetz/gruvbox
Plug 'joshukraine/vim-monokai-tasty',   " My fork of patstockwell/vim-monokai-tasty             | https://github.com/joshukraine/vim-monokai-tasty

" Syntax Highlighting
Plug 'hail2u/vim-css3-syntax'           " CSS3 syntax                                           | https://github.com/hail2u/vim-css3-syntax
Plug 'cakebaker/scss-syntax.vim'        " Vim syntax file for scss (Sassy CSS)                  | https://github.com/cakebaker/scss-syntax.vim
Plug 'pangloss/vim-javascript',
      \ { 'for': ['javascript', 'vue']
      \}                                " Javascript indentation and syntax support in Vim.     | https://github.com/pangloss/vim-javascript
Plug 'maxmellon/vim-jsx-pretty'         " JSX and TSX syntax pretty highlighting for vim.       | https://github.com/MaxMEllon/vim-jsx-pretty
Plug 'posva/vim-vue'                    " Syntax Highlight for Vue.js components                | https://github.com/posva/vim-vue
Plug 'elzr/vim-json'                    " A better JSON for Vim                                 | https://github.com/elzr/vim-json
Plug 'digitaltoad/vim-pug'              " Vim syntax highlighting for Pug templates             | https://github.com/digitaltoad/vim-pug
Plug 'habamax/vim-asciidoctor'          " Asciidoctor plugin for Vim                            | https://github.com/habamax/vim-asciidoctor
Plug 'dag/vim-fish'                     " Vim support for editing fish scripts                  | https://github.com/dag/vim-fish
Plug 'cespare/vim-toml'                 " Vim syntax for TOML                                   | https://github.com/cespare/vim-toml
Plug 'leafgarland/typescript-vim'       " Typescript syntax files for Vim                       | https://github.com/leafgarland/typescript-vim
Plug 'Yggdroot/indentLine'              " Display indention levels with thin vertical lines     | https://github.com/Yggdroot/indentLine

" Tim Pope
Plug 'tpope/vim-surround'               " Quoting/parenthesizing made simple                    | https://github.com/tpope/vim-surround
Plug 'tpope/vim-rails'                  " Ruby on Rails power tools                             | https://github.com/tpope/vim-rails
Plug 'tpope/vim-obsession'              " Continuously updated session files                    | https://github.com/tpope/vim-obsession
Plug 'tpope/vim-fugitive'               " Tim Pope's Git wrapper                                | https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-repeat'                 " Enable repeating supported plugin maps with '.'       | https://github.com/tpope/vim-repeat
Plug 'tpope/vim-sensible'               " Defaults everyone can agree on                        | https://github.com/tpope/vim-sensible

" Testing & Tmux
Plug 'janko/vim-test'                   " Run your tests at the speed of thought                | https://github.com/janko/vim-test
Plug 'christoomey/vim-tmux-runner'      " Command runner for sending commands from vim to tmux. | https://github.com/christoomey/vim-tmux-runner

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
endif

"" vim:fdm=expr:fdl=0
"" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
