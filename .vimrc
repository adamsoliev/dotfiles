call plug#begin()

" --- Plug ---
"  https://thevaluable.dev/fzf-vim-integration/

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Plug 'nanotech/jellybeans.vim'

call plug#end()

" Use Space as the leader key
let mapleader = " "

" --- Key Mappings ---
" fzf-related mappings
" Find Files
nnoremap <leader>f :Files<CR>
" Find Git Files
nnoremap <leader>g :GFiles<CR>
" RIPGREP to search [pattern] through your files’ content
nnoremap <leader>r :Rg<CR>
" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt


" Line navigation respects wrapped lines
nnoremap j gj
nnoremap k gk


" --- General ---
set nocompatible
set encoding=utf-8
set mouse=a
set background=dark
set t_Co=256
syntax enable
set autowrite

" --- Colorscheme ---
"  https://vimcolorschemes.com/vim/colorschemes
colorscheme desert
" colorscheme jellybeans

" Change the default blue keyword color to a brighter blue
" found using
"   1) move your cursor over text you want to change the color of
"   2) :echo synIDattr(synID(line("."), col("."), 1), "name") # to find the name of the highlight group
hi sqlKeyword ctermfg=LightBlue
hi vimNotation ctermfg=LightBlue
hi vimMapModKey ctermfg=LightBlue
hi vimMapMod ctermfg=LightBlue
hi vimBracket ctermfg=LightBlue
hi vimMapMod ctermfg=LightBlue
hi vimParenSep ctermfg=LightBlue


" --- UI & Appearance ---
set showmode
set noshowmode          " Powerline handles mode display
set showcmd
set laststatus=2
set relativenumber
set nowrap
set tw=79               " Text width for automatic line breaks
highlight LineNr ctermfg=yellow

" --- GUI options (ignored in terminal Vim) ---
set guioptions-=T       " Remove top toolbar
set guioptions-=r       " Remove right scroll bar
set go-=L               " Remove left scroll bar
set linespace=15
set termwinsize=15x0
" NOTE: Only applies in GVim or MacVim
set guifont=menlo\ for\ powerline:h16

" --- Tabs and Indentation ---
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent
set smartindent
set copyindent
set shiftround
set backspace=indent,eol,start

" --- Searching ---
set hlsearch
set ignorecase
set smartcase

" --- Timings ---
set timeout
set timeoutlen=200
set ttimeoutlen=100

" --- Key Mappings ---

" Save with <leader>w
nmap <leader>w :w!<CR>

" Easy escape from insert mode
imap jj <Esc>

" Window navigation with Ctrl
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Clear search highlight
command! H let @/=""

" Mac-specific key remap (safe to delete if not on MacVim)
noremap <D-/> <C-/>

" Set a more responsive updatetime
set updatetime=300

" check one time after 'updatetime' ms of inactivity in normal mode
set autoread
au CursorHold * checktime

