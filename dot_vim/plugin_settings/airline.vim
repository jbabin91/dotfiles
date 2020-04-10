if match(&runtimepath, 'airline') != -1
  let g:airline_power_line_fonts = 1

  " Set theme
  let g:airline_theme='nord'

  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#tabline#show_tab_type = 0
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#show_tab_nr = 0
  let g:airline#extensions#tabline#show_splits = 0
  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#tabline#ignore_bufadd_pat = 'gundo|undotree|vimfiler|tagbar|nerd_tree|startify|!'

  let g:pencil#mode_indicators = {'hard': '✐ hard', 'soft': '✎ soft', 'off': '✎ off',}

  " let g:airline_section_a = ''
  " let g:airline_section_b = ''
  let g:airline_section_x = '%{PencilMode()}'
  " let g:airline_section_y = ''
  " let g:airline_section_z = ''

  augroup pencil
    autocmd!
    autocmd FileType markdown,md,vimwiki
                              \   call pencil#init({'wrap': 'soft', 'textwidth': 80})
                              \ | call litecorrect#init()
                              \ | call lexical#init()
                              \ | call textobj#sentence#init()
                              \ | setl spell spl=en_us
                              \ | setl fdo+=search
    autocmd Filetype git,gitsendemail,*commit*,*COMMIT*
                              \   call pencil#init({'wrap': 'soft', 'textwidth': 72})
                              \ | call litecorrect#init()
                              \ | call lexical#init()
                              \ | call textobj#sentence#init()
                              \ | setl spell spl=en_us et sw=2 ts=2 noai
    autocmd Filetype html,xml     call pencil#init({'wrap': 'soft'})
                              \ | call litecorrect#init()
                              \ | setl spell spl=en_us et sw=2 ts=2
  augroup END
endif