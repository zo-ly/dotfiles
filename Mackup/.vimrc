set number
set ignorecase smartcase
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2
set termguicolors
set laststatus=2

nnoremap ,, ,
nnoremap ,p "0p
nnoremap ,P "0P
nnoremap J gT
nnoremap K gt
nnoremap Y "*y
noremap ]t :tabmove +1<CR>
noremap [t :tabmove -1<CR>

let mapleader=" "
nnoremap <SPACE> <Nop>
noremap <LEADER>j <C-w>j
noremap <LEADER>k <C-w>k
noremap <LEADER>h <C-w>h
noremap <LEADER>l <C-w>l

call plug#begin()
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'itchyny/lightline.vim'
call plug#end()

colorscheme catppuccin_macchiato
let g:lightline = { 'colorscheme': 'one' }
