# Vim

Vim 是一个从 `vi` 发展出来的文本编辑器。

在配置时我们将检查用户家目录下是否存在 Vim 的配置目录 `.vim` 和配置文件 `.vimrc`。

如果已经存在相应的目录或文件，用户需要手动选择是备份还是删除，或是其它。

确认好用户的操作后，将会软连项目的 `modules/vim/.vim` 和配置文件 `modules/vim/.vimrc` 到用户的家目录。

同时会默认安装一些插件：

- [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline)
- [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)
- [ctrlpvim/ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
- [tpope/vim-surround](https://github.com/tpope/vim-surround)
- [tpope/vim-repeat](https://github.com/tpope/vim-repeat)
- [terryma/vim-multiple-curstomtom/tcomment_vim](https://github.com/terryma/vim-multiple-curstomtom/tcomment_vim)
