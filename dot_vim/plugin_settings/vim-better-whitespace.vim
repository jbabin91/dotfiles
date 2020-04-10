if match(&runtimepath, 'vim-better-whitespace') != -1
  let g:better_whitespace_enabled = 1
  let g:strip_whitespace_on_save = 1
  let g:indentLine_bufNameExclude = ['_.','NERD_tree']
endif