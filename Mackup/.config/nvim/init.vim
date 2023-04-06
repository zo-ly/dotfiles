" Vim-Plug
call plug#begin()
" Editor theme
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
" Highlight difference modes
Plug 'itchyny/lightline.vim'
" Go to definition
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Kitty syntax hightlighting
Plug 'fladson/vim-kitty'
call plug#end()

" Vim Script
colorscheme catppuccin-macchiato

" COC key map
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use config from .vimrc
" set runtimepath^=~/.vim runtimepath+=~/.vim/after
" let &packpath = &runtimepath
" source ~/.vimrc
