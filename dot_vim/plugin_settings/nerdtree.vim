if match(&runtimepath, 'nerdtree') != -1
  map <C-n> :NERDTreeToggle<CR>
  map <C-m> :NERDTreeFind<CR>

  " Hide files/folders
  let NERDTreeIgnore = ['^node_modules$[[dir]]', '^build$[[dir]]', '^.git$']
  let NERDTreeMarkBookmarks = 1
  let NERDTreeShowHidden = 1
  let NERDTreeShowLineNumbers = 0
  let NERDTreeStatusline = 0
  let NERDTreeMinimalUI = 1
  let NERDTreeAutoDeleteBuffer = 1

  let g:NERDTreeGitStatusWithFlags = 1
  let g:WebDevIconsUnicodeDecorateFolderNodes = 1
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
endif
