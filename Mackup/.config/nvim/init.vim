" Vim-Plug
call plug#begin()
" Editor theme
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
" Highlight difference modes
Plug 'itchyny/lightline.vim'
" Go to definition
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Vim Script
colorscheme tokyonight

" COC key map
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use config from .vimrc
" set runtimepath^=~/.vim runtimepath+=~/.vim/after
" let &packpath = &runtimepath
" source ~/.vimrc
