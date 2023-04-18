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
noremap t :tabmove +1<CR>
noremap T :tabmove -1<CR>

call plug#begin()
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
call plug#end()

colorscheme onedark

