"--------------
" Plugins
"--------------
call plug#begin('~/.vim/plugged')
  " editor enhancement
  Plug 'vim-airline/vim-airline'
  Plug 'scrooloose/nerdtree'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'terryma/vim-multiple-cursors'
call plug#end()

"--------------
" Basic Settings
"--------------
set encoding=utf-8
scriptencoding utf-8
set noswapfile
set clipboard=unnamed

"--------------
" Common Settings
"--------------
set number
set cursorline
set linebreak
set scrolloff=3

" Indent
set softtabstop=2
set shiftwidth=2

" Tab
set expandtab
set showtabline=2

" Pane
set splitright
set splitbelow

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" 颜色
syntax on
colorscheme molokai

" filetype
filetype on
filetype indent on
filetype plugin on

"--------------
" Key mapping
"--------------
let mapleader = ";"

" Fast to the beginning or end of a line
map H ^
map L $

" Close current window
nmap <Leader>q :q<CR>
" Save current window contents
nmap <Leader>w :w<CR>

"--------------
" Third party related configuration
"--------------
" vim-airline
set noshowmode
