if match(&runtimepath, 'nerdtree') != -1
  map <C-n> :NERDTreeToggle<CR>
  map <C-m> :NERDTreeFind<CR>

  " Map leader + r to refresh NerdTree
  nmap <Leader>r :NERDTreeFocus<cr>R<c-w><c-p>

  " Hide files/folders
  let NERDTreeIgnore = ['^node_modules$[[dir]]', '^build$[[dir]]', '^.git$', '.DN_Store']
  let NERDTreeMarkBookmarks = 1
  let NERDTreeShowHidden = 1
  let NERDTreeShowLineNumbers = 0
  let NERDTreeStatusline = 0
  let NERDTreeMinimalUI = 1
  let NERDTreeAutoDeleteBuffer = 1

  let g:NERDTreeDirArrowExpandable = ''
  let g:NERDTreeDirArrowCollapsible = ''

  let g:WebDevIconsUnicodeDecorateFolderNodes = 1
  let g:NERDTreeGitStatusWithFlags = 1
  let g:NERDTreeGitStatusNodeColorization = 1
  let g:NERDTreeColorMapCustom = {
      \ "Staged"    : "#0ee375",
      \ "Modified"  : "#d9bf91",
      \ "Renamed"   : "#51C9FC",
      \ "Untracked" : "#FCE77C",
      \ "Unmerged"  : "#FC51E6",
      \ "Dirty"     : "#FFBD61",
      \ "Clean"     : "#87939A",
      \ "Ignored"   : "#808080"
      \ }

  if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
  endif

  " Close vim if NerdTree is the last window
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
endif
