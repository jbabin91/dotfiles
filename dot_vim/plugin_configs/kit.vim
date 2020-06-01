if match(&runtimepath, 'vim-plugin') != -1
  let g:kite_supported_languages = ['python', 'javascript', 'go']
  let g:kite_tab_complete=1
endif