" Switch to filename only search instead of full path
let g:ctrlp_by_filename = 1

" Exclude files and directories
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$|tmp$|node_modules$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
