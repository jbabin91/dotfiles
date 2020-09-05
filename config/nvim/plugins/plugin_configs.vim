" Plugin-specifc Mappings & Settings

" Far.vim
let g:far#source = 'agnvim'
let g:far#file_mask_favorites = ['%', '**/*.*', '**/*.html', '**/*.haml', '**/*.js', '**/*.css', '**/*.scss', '**/*.rb']

" NERDTree
map <silent> <C-k>b :NERDTreeToggle<CR>
map <C-m> :NERDTreeFind<CR>

" Map leader + r to refresh NerdTree
nmap <Leader>r :NERDTreeFocus<cr>R<c-w><c-p>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.png$', '\.jpg$', '\.gif$', '\.mp3$', '\.ogg$', '\.mp4$',
      \ '\.avi$','.webm$','.mkv$','\.pdf$', '\.zip$', '\.tar.gz$',
      \ '\.rar$', '\.git$']
let NERDTreeMinimalUI = 1
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''

let g:NERDTreeGitStatusIndicatorMapCustom = {
      \ "Modified"  : "✹",
      \ "Staged"    : "✚",
      \ "Untracked" : "",
      \ "Renamed"   : "➜",
      \ "Unmerged"  : "═",
      \ "Deleted"   : "✖",
      \ "Dirty"     : "~",
      \ "Clean"     : "✔︎",
      \ 'Ignored'   : '☒',
      \ "Unknown"   : ""
      \ }

" Vim DevIcons
" exe 'source' stdpath('config') . '/extras/devicons.vim'

" indentLine
let g:indentLine_char = '▏'

" vim-json
" https://github.com/Yggdroot/indentLine/issues/140#issuecomment-620465182
let g:vim_json_syntax_conceal = 0

" GitGutter
nnoremap <F6> :GitGutterToggle<CR>
nnoremap <F7> :GitGutterLineHighlightsToggle<CR>
let g:gitgutter_terminal_reports_focus=0
let g:gitgutter_preview_win_floating = 0
let g:gitgutter_override_sign_column_highlight = 0

nmap ]g <Plug>(GitGutterNextHunk)
nmap [g <Plug>(GitGutterPrevHunk)

" GitGutter default mapping reference
" https://github.com/airblade/vim-gitgutter#getting-started
" <leader>hp - Preview hunk
" <leader>hs - Stage hunk
" <leader>hu - Undo hunk

" GitMessenger
nmap <Leader>m <Plug>(git-messenger)

" Tcomment
map <leader>/ :TComment<CR>

" Bufexplorer
let g:bufExplorerDisableDefaultKeyMapping=1
nnoremap <silent> <F4> :BufExplorer<CR>

" Obsession
map <leader>ob :Obsession<CR>

" vim-test
" nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>
let test#strategy = 'vtr'

" vim-tmux-runner
let g:VtrPercentage = 25
let g:VtrUseVtrMaps = 1
nnoremap <leader>sd :VtrSendCtrlD<cr>
nmap <leader>fs :VtrFlushCommand<cr>:VtrSendCommandToRunner<cr>
nmap <leader>v3 :VtrAttachToPane 3<cr>
nmap <leader>v4 :VtrAttachToPane 4<cr>
nmap <leader>osp :VtrOpenRunner {'orientation': 'h', 'percentage': 25, 'cmd': '' }<cr>
nmap <leader>orc :VtrOpenRunner {'orientation': 'h', 'percentage': 40, 'cmd': 'rc'}<cr>
nmap <leader>opr :VtrOpenRunner {'orientation': 'h', 'percentage': 40, 'cmd': 'pry'}<cr>

" vim-tmux-runner default mappings
" nnoremap <leader>va :VtrAttachToPane<cr>
" nnoremap <leader>ror :VtrReorientRunner<cr>
" nnoremap <leader>sc :VtrSendCommandToRunner<cr>
" nnoremap <leader>sl :VtrSendLinesToRunner<cr>
" vnoremap <leader>sl :VtrSendLinesToRunner<cr>
" nnoremap <leader>or :VtrOpenRunner<cr>
" nnoremap <leader>kr :VtrKillRunner<cr>
" nnoremap <leader>fr :VtrFocusRunner<cr>
" nnoremap <leader>dr :VtrDetachRunner<cr>
" nnoremap <leader>cr :VtrClearRunner<cr>
" nnoremap <leader>fc :VtrFlushCommand<cr>
" nnoremap <leader>sf :VtrSendFile<cr>

" FZF
map <leader>b :Buffers<CR>
map <leader>t :Files<CR>
map <leader>y :Rg<CR>

command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \   fzf#vim#with_preview(), <bang>0)

" Custom rails.vim commands
" command! Rroutes :e config/routes.rb
" command! RTroutes :tabe config/routes.rb
" command! RSroutes :sp config/routes.rb
" command! RVroutes :vs config/routes.rb
" command! Rfactories :e spec/factories.rb
" command! RTfactories :tabe spec/factories.rb
" command! RSfactories :sp spec/factories.rb
" command! RVfactories :vs spec/factories.rb

" Key mappings for dragvisuals.vim
" exe 'source' stdpath('config') . '/extras/dragvisuals.vim'

vmap  <expr>  <LEFT>   DVB_Drag('left')
vmap  <expr>  <RIGHT>  DVB_Drag('right')
vmap  <expr>  <DOWN>   DVB_Drag('down')
vmap  <expr>  <UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()

" Remove any introduced trailing whitespace after moving...
let g:DVB_TrimWS = 1

let g:user_emmet_leader_key=','

" Tagbar
nmap <F8> :TagbarToggle<CR>

" Vim REST Console (VRC)
let g:vrc_curl_opts = {
      \ '-L': '',
      \ '-i': '',
      \ }

" Coc
" https://github.com/neoclide/coc.nvim

" Global extension names to install when they aren't installed
let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-diagnostic',
      \ 'coc-emmet',
      \ 'coc-html',
      \ 'coc-pairs',
      \ 'coc-json',
      \ 'coc-marketplace',
      \ 'coc-prettier',
      \ 'coc-snippets',
      \ 'coc-solargraph',
      \ 'coc-stylelintplus',
      \ 'coc-tailwindcss',
      \ 'coc-tsserver',
      \ 'coc-vetur',
      \ 'coc-yaml',
      \ ]

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" TIP: <C-w>p will close the preview window.

" Format code on <CR>. (e.g, indent after open braces, pressing enter)
" https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources#improve-the-completion-experience
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Comment highlighting for jsonc
autocmd FileType json syntax match Comment +\/\/.\+$+

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Prettier
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

map <leader>p :Prettier<CR>

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
" nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
