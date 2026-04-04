#!/bin/bash

# Parse command line arguments
parse_args "$@"

vim_folder=~/.vim
vim_rc=~/.vimrc

# Handle relink mode
if [ "$RELINK_MODE" = true ]; then
  print_info "Re-linking Vim configuration..."

  # Remove existing links
  if [ -L "$vim_rc" ]; then
    safe_rm "$vim_rc"
  fi
  if [ -L "$vim_folder" ]; then
    safe_rm "$vim_folder"
  fi

  # Re-link
  safe_ln "$KS_PROJECT_DIR/modules/vim/.vimrc" "$vim_rc"
  safe_ln "$KS_PROJECT_DIR/modules/vim/.vim" "$vim_folder"

  print_success "Vim configuration re-linked"
  exit 0
fi

# Normal installation mode

# Check .vim folder
ensure_no_folder $vim_folder

# Check .vimrc
ensure_no_file $vim_rc

# Make symbolic links
print_info "Link Vim related files to $HOME"

if only_simple
then
  safe_ln "$KS_PROJECT_DIR/modules/vim/.simple.vimrc" $vim_rc
else
  safe_ln "$KS_PROJECT_DIR/modules/vim/.vim" $vim_folder
  safe_ln "$KS_PROJECT_DIR/modules/vim/.vimrc" $vim_rc

  # Install all plugins (skip in dry-run mode)
  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD EXECUTE] vim +'PlugInstall --sync' +qa"
  else
    vim +'PlugInstall --sync' +qa
  fi
fi

# Record installation
record_installation "vim"

