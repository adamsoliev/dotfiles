filetype plugin indent on

call plug#begin()

" --- Plug ---
"  https://thevaluable.dev/fzf-vim-integration/

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'tpope/vim-commentary'

call plug#end()

" fzf actions: ctrl-o=vsplit, ctrl-x=split, ctrl-t=tab
let g:fzf_action = {
  \ 'ctrl-o': 'vsplit',
  \ 'ctrl-x': 'split',
  \ 'ctrl-t': 'tab split' }

" Use Space as the leader key
let mapleader = " "

" --- Key Mappings ---
" fzf-related mappings
" Find Files
nnoremap <leader>f :Files<CR>
" Find Git Files
nnoremap <leader>g :GFiles<CR>
" RIPGREP to search [pattern] through your files' content
nnoremap <leader>r :Rg<CR>
" Open terminal spanning full width at bottom (15 lines)
nnoremap <leader>t :botright term ++rows=15<CR>
" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt

" LSP settings
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_diagnostics_signs_enabled = 0

" LSP diagnostics
nnoremap <leader>d :LspDocumentDiagnostics<CR>
nmap ]d :LspNextDiagnostic<CR>
nmap [d :LspPreviousDiagnostic<CR>

" LSP navigation
nnoremap gd :LspDefinition<CR>
nnoremap gi :LspImplementation<CR>
nnoremap gr :LspReferences<CR>
nnoremap K :LspHover<CR>
nnoremap <leader>rn :LspRename<CR>
nnoremap <leader>ca :LspCodeAction<CR>

highlight link DiagnosticError ErrorMsg
highlight link DiagnosticWarning WarningMsg
highlight link DiagnosticInfo MoreMsg
highlight link DiagnosticHint Title

" Ensure the sign column icons also follow these colors
highlight link DiagnosticSignError DiagnosticError
highlight link DiagnosticSignWarning DiagnosticWarning
highlight link DiagnosticSignInfo DiagnosticInfo
highlight link DiagnosticSignHint DiagnosticHint

" vim-lsp virtual text colors
highlight LspErrorText ctermfg=red guifg=red
highlight LspWarningText ctermfg=yellow guifg=yellow
highlight LspInformationText ctermfg=cyan guifg=cyan
highlight LspHintText ctermfg=green guifg=green
highlight LspErrorVirtualText ctermfg=red guifg=red
highlight LspWarningVirtualText ctermfg=yellow guifg=yellow
highlight LspInformationVirtualText ctermfg=cyan guifg=cyan
highlight LspHintVirtualText ctermfg=green guifg=green

" Line navigation respects wrapped lines
nnoremap j gj
nnoremap k gk

" Save with <leader>w
nmap <leader>w :w!<CR>

" Easy escape from insert mode
imap jj <Esc>

" Window navigation with Ctrl
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Toggle comment
nmap <leader>/ gcc
vmap <leader>/ gc

" Clear search highlight
command! H let @/=""

" --- General ---
set encoding=utf-8
set mouse=a
set background=dark
set t_Co=256
syntax enable
set autowrite

" --- Colorscheme ---
"  https://vimcolorschemes.com/vim/colorschemes
colorscheme desert

" Change the default blue keyword color to a brighter blue
" found using
"   1) move your cursor over text you want to change the color of
"   2) :echo synIDattr(synID(line("."), col("."), 1), "name") # to find the name of the highlight group
hi sqlKeyword ctermfg=LightBlue
hi vimNotation ctermfg=LightBlue
hi vimMapModKey ctermfg=LightBlue
hi vimMapMod ctermfg=LightBlue
hi vimBracket ctermfg=LightBlue
hi vimParenSep ctermfg=LightBlue


" --- UI & Appearance ---
set noshowmode          " Powerline handles mode display
set showcmd
set laststatus=2
" set relativenumber
set number
set nowrap
set tw=79               " Text width for automatic line breaks
highlight LineNr ctermfg=yellow

" Statusline with LSP diagnostic counts
set statusline=%f\ %m%r%h%w
set statusline+=%=
set statusline+=❌%{lsp#get_buffer_diagnostics_counts()['error']}\
set statusline+=⚠️\ %{lsp#get_buffer_diagnostics_counts()['warning']}
set statusline+=\ \ %l:%c

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
set incsearch
set ignorecase
set smartcase

" --- Timings ---
set timeout
set timeoutlen=500             " ms to complete mapped sequences (e.g. SPC v)
set ttimeoutlen=100            " ms for terminal key codes (e.g. Esc)
set updatetime=300

" --- Auto-reload ---
set autoread
au CursorHold * checktime

