if match(&runtimepath, 'palenight') != -1
  " Delete pipe characters on styling vertical split borders
  " set fillchars+=vert:\

  set background=dark
  colorscheme palenight

  " Italics for my favorite color scheme
  let g:palenight_terminal_italics=1
endif