#!/bin/bash

# Parse command line arguments
parse_args "$@"

tmux_conf=~/.tmux.conf

# Handle relink mode
if [ "$RELINK_MODE" = true ]; then
  print_info "Re-linking Tmux configuration..."
  
  # Remove existing link
  if [ -L "$tmux_conf" ]; then
    safe_rm "$tmux_conf"
  fi
  
  # Re-link
  safe_ln "$KS_PROJECT_DIR/modules/tmux/.tmux.conf" $tmux_conf
  
  print_success "Tmux configuration re-linked"
  exit 0
fi

# Normal installation mode

# Check .tmux.conf
ensure_no_file $tmux_conf

# Make symbolic link
print_info "Link Tmux related files to $HOME"

safe_ln "$KS_PROJECT_DIR/modules/tmux/.tmux.conf" $tmux_conf

# Record installation
record_installation "tmux"

