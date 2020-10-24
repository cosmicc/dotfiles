set nocompatible              " be iMproved, required
filetype plugin on                 " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'edkolev/promptline.vim'
Plugin 'w0rp/ale'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
"Plugin 'fisadev/vim-isort'
"Plugin 'scrooloose/nerdtree'
"Plugin 'tmhedberg/SimpylFold'
Plugin 'colors/sublimemonokai.vim'
"Bundle 'Valloric/YouCompleteMe'
call vundle#end()
filetype plugin on
let g:airline#extensions#ale#enabled = 1
let g:airline_powerline_fonts = 1
let g:ale_linters = {'python': ['flake8']}
let g:ale_linters_explicit = 1
let g:vim_isort_python_version = 'python3'
set suffixesadd=.py
set wildignore=*.pyc
let g:netrw_list_hide= '.*\.pyc$'
set listchars=eol:¬,tab:▷\ ,
set colorcolumn=120
highlight ColorColumn ctermbg=16
map <f2> :w\|!python %
set foldmethod=indent
set foldlevel=99
nnoremap <space> za
let g:SimpylFold_docstring_preview=1
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
set ls=2
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set autoindent
set fileformat=unix
set encoding=utf-8
let python_highlight_all=1
syntax on
set t_Co=256
set background=dark
colorscheme sublimemonokai
set nu
set clipboard=unnamed
highlight LineNr ctermfg=darkgray
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
"python3 << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
"  project_base_dir = os.environ['VIRTUAL_ENV']
"  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"  execfile(activate_this, dict(__file__=activate_this))
"EOF
