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

nnoremap ,, ,
nnoremap ,p "0p
nnoremap ,P "0P
nnoremap J gT
nnoremap K gt
noremap t :tabmove -1<CR>
noremap T :tabmove +1<CR>

" Vim-Plug
call plug#begin()
" Editor theme
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
" Highlight difference modes
Plug 'itchyny/lightline.vim'
" Git signs
Plug 'lewis6991/gitsigns.nvim'
" Kitty syntax hightlighting
Plug 'fladson/vim-kitty'
" Nerdtree
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'johnstef99/vim-nerdtree-syntax-highlight'
" Coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
			\'coc-vimlsp',
			\'coc-json',
			\'coc-eslint',
			\'coc-prettier',
			\'coc-tsserver',
			\]
call plug#end()

" Vim Script
colorscheme catppuccin-macchiato

" ==================== nerdtree ====================
nnoremap <C-t> :NERDTreeToggle<CR>
set guifont=FiraCodeNFMRetian:h11

" ==================== coc.nvim ====================
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)

inoremap <silent><expr> <c-i> coc#refresh()
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" ==================== gitsigns.nvim ====================
lua <<EOF
require('gitsigns').setup({
	signs = {
    add          = { hl = 'GitSignsAdd'   , text = '▎', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
    change       = { hl = 'GitSignsChange', text = '░', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
    delete       = { hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
    topdelete    = { hl = 'GitSignsDelete', text = '▔', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '▒', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
    untracked    = { hl = 'GitSignsAdd'   , text = '┆', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
  },
})
EOF

