if match(&runtimepath, 'vimwiki') != -1
  let wiki0 = {}
  let wiki0.path = '~/vimwiki/'
  let wiki0.path_html = '~/vimwiki_html/'
  let wiki0.auto_toc = 1

  let wiki1 = {}
  let wiki1.path = '~/vimwiki_headway/'
  let wiki1.path_html = '~/vimwiki_headway_html/'
  let wiki1.auto_toc = 1

  " Run multiple wikis
  let g:vimwiki_list = [wiki0, wiki1]

  au BufRead,BufNewFile *.wiki set filetype=vimwiki

  " Open diary with \d
  :autocmd FileType vimwiki map <localleader>d :VimwikiMakeDiaryNote<CR>:Calendar<CR>

  au! BufRead ~/vimwiki_headway/index.wiki !cd ~/vimwiki_headway;git pull
  " au! BufWritePost ~/vimwiki_headway/* !cd ~/vimwiki_headway;git add -A;git commit -m "Auto commit + push.";git push

  " let g:vimwiki_folding='expr'

  " Vimwiki override to not check spelling when launching
  autocmd FileType vimwiki setl nospell
endif