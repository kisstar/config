"--------------
" Plugins
"--------------
call plug#begin('~/.vim/plugged')
  " editor enhancement
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'scrooloose/nerdtree'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'mattn/emmet-vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'terryma/vim-multiple-cursors'

  " for general purpose development
  Plug 'tomtom/tcomment_vim'
  Plug 'MarcWeber/vim-addon-mw-utils'
  Plug 'tomtom/tlib_vim'
  Plug 'garbas/vim-snipmate'
  Plug 'honza/vim-snippets'
  Plug 'majutsushi/tagbar'
  Plug 'mileszs/ack.vim'
  Plug 'airblade/vim-gitgutter'
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

" 缩进
set softtabstop=2
set shiftwidth=2

" Tab
set expandtab
set showtabline=2

" 窗格
set splitright
set splitbelow

" 搜索
set ignorecase
set smartcase
set incsearch
set hlsearch

" 颜色
syntax on
colorscheme darkblue

" filetype
filetype on
filetype indent on
filetype plugin on

"--------------
" key mapping
"--------------
let mapleader = ";"
