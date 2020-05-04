if match(&runtimepath, 'vim-commentary') != -1
  nnoremap <space>/ :Commentary<CR>
  vnoremap <space>/ :Commentary<CR>
endif