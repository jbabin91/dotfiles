if match(&runtimepath, 'vim-markdown') != -1
  """ MARKDOWN & WRITING
  map <localleader>m :MarkedOpen!<CR>
  let g:marked_app = "Marked" " Need to specify v1 of the app
  " let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_frontmatter = 1
  " Syntax highlight code in markdown files
  let g:markdown_fenced_languages = ['javascript', 'js=javascript', 'json=javascript', 'ruby']
  let g:vim_markdown_emphasis_multiline = 0
  let g:vim_markdown_toc_autofit = 1

  " Disable ]c for move to current header of vim-markdown
  nmap <Plug>Markdown_MoveToCurHeader <Plug>Markdown_MoveToCurHeader

  " function! s:Toc()
  "   if &filetype == 'markdown'
  "     :normal SS
  "   endif
  " endfunction
  " autocmd VimEnter *.m*  call s:Toc()
  " autocmd BufReadPost *.m* call s:Toc()
  " autocmd BufWinEnter *.m* call s:Toc()

  augroup ft_markdown
    au!

    au BufNewFile,BufRead *.m*down setlocal filetype=markdown foldlevel=1

    " Use <localleader>1/2/3 to add headings.
    au Filetype markdown nnoremap <buffer> <localleader>1 mzI# <ESC>
    au Filetype markdown nnoremap <buffer> <localleader>2 mzI## <ESC>
    au Filetype markdown nnoremap <buffer> <localleader>3 mzI### <ESC>

    " au FileType markdown nnoremap <leader>al <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>
    "
    " Create a Markdown-link structure for the current word or visual selection
    " with leader 3. Paste in the URL later. Or use leader 4 to insert the
    " current system clipboard as an URL.
    au FileType markdown nnoremap <Leader>al ciw[<C-r>"]()<Esc>
    au FileType markdown vnoremap <Leader>al c[<C-r>"]()<Esc>
    " au FileType markdown nnoremap <Leader>ai <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>
    au FileType markdown vnoremap <Leader>ai <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>

    " au FileType markdown nnoremap <Leader>ai ciw[<C-r>"](<Esc>"*pli)<Esc>
    " au FileType markdown vnoremap <Leader>ai c[<C-r>"](<Esc>"*]pa)<Esc>

    " Use formd to transfer markdown from inline [to reference](to reference) links and vice versa
    " see: http://drbunsen.github.com/formd/
    au FileType markdown nmap <leader>fr :%! /usr/local/bin/formd/formd -r<CR>
    au FileType markdown nmap <leader>fi :%! /usr/local/bin/formd/formd -i<CR>

    " For some reason saving causes the Toc to go blank. Call it again to solve this for now. Then put cursor back.
    " au FileType markdown noremap SS :w<CR>:Toc<CR><C-w>h
    " au FileType markdown inoremap SS <Esc>:w<CR>:Toc<CR><C-w>h
  augroup END

  augroup textobj_quote
    autocmd!
    autocmd FileType markdown call textobj#quote#init({'educate': 0})
    autocmd FileType html call textobj#quote#init({'educate': 0})
    autocmd FileType textile call textobj#quote#init({'educate': 0})
    autocmd FileType text call textobj#quote#init({'educate': 0})
    autocmd FileType vimwiki call textobj#quote#init({'educate': 0})
  augroup END

  let g:pencil#mode_indicators = {'hard': '✐ hard', 'soft': '✎ soft', 'off': '✎ off',}
  let g:airline_section_x = '%{PencilMode()}'
  let g:pencil#map#suspend_af = 'K'   " default is no mapping

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