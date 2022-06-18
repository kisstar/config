#!/bin/bash

vim_folder=~/.vim
vim_rc=~/.vimrc

# Check .vim folder
ensure_no_folder $vim_folder

# Check .vimrc
ensure_no_file $vim_rc

# Make symbolic links
print_info "Link Vim related files to $HOME"

if only_simple
then
  ln -s "$KS_PROJECT_DIR/modules/vim/.simple.vimrc" $vim_rc
else
  ln -s "$KS_PROJECT_DIR/modules/vim/.vim" $vim_folder
  ln -s "$KS_PROJECT_DIR/modules/vim/.vimrc" $vim_rc
  # Install all plugins
  vim +'PlugInstall --sync' +qa
fi
