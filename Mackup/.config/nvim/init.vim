set encoding=utf8
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set number
set relativenumber
set ignorecase
set smartcase
set updatetime=100
set signcolumn=yes
set fillchars+=diff:╱

let mapleader=" "
nnoremap <SPACE> <Nop>
nmap <LEADER>e :NvimTreeToggle<CR>
noremap <LEADER>j <C-w>j
noremap <LEADER>k <C-w>k
noremap <LEADER>h <C-w>h
noremap <LEADER>l <C-w>l
 
nnoremap ,, ,
nnoremap ,p "0p
nnoremap ,P "0P
nnoremap J :BufferLineCyclePre<CR>
nnoremap K :BufferLineCycleNext<CR>
noremap t :BufferLineMoveNext<CR>
noremap T :BufferLineMovePre<CR>

" Vim-Plug
call plug#begin()
" Editor theme
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

" Buffer
Plug 'akinsho/bufferline.nvim', { 'tag': 'v3.*' }

" Tree
Plug 'nvim-tree/nvim-tree.lua'

" Highlight difference modes
" Plug 'itchyny/lightline.vim'
Plug 'nvim-lualine/lualine.nvim'

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'nvim-tree/nvim-web-devicons'

" Kitty syntax hightlighting
Plug 'fladson/vim-kitty'

" Commentary
Plug 'numToStr/Comment.nvim'
call plug#end()

" colorscheme catppuccin-macchiato
colorscheme tokyonight-moon

lua << EOF
  require('init')
EOF

