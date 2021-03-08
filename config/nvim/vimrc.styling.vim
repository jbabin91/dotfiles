" Basics
set title
set autoread

" Themes and styling
" let base16colorspace=256
let g:enable_bold_font = 1
let $NVIM_TUI_ENABLE_TRUE_COLOR = 1

set termguicolors
set background=dark

" Theme specific settings
let g:tokyonight_style =  'storm'
let g:tokyonight_enable_italic = 1

" Set Airline theme
let g:airline_theme='tokyonight'

" Set Color Theme
colorscheme tokyonight

set cursorline

" Colour-column to limit myself to 80 characters
set colorcolumn=80
" highlight ColorColumn ctermbg=0
