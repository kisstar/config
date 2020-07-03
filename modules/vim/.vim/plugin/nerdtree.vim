" Looks better
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 25

" Reset root directory when switch dir in NERDTree
let NERDTreeChDirMode = 2

" Delete buffer if file is deleted
let NERDTreeAutoDeleteBuffer = 1

" Display empty subfolder correctly
let NERDTreeCascadeSingleChildDir = 0

" open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Remove NERDTree window if there's no any buffer exists.
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
