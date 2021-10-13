call plug#begin('~/.config/nvim/plugged')
Plug 'dkarter/bullets.vim'
call plug#end()

let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'scratch'
    \]

set autoindent smartindent

set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set number
set ignorecase smartcase
syntax on

map <C-n> :NERDTreeToggle<CR>

let g:livepreview_previewer = 'evince'
