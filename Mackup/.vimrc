set number
set ignorecase smartcase
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2

nnoremap ,, ,
nnoremap ,p "0p
nnoremap ,P "0P
nnoremap J gT
nnoremap K gt

call plug#begin()
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
call plug#end()

syntax on
colorscheme onedark

