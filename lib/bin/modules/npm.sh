#!/bin/bash

# Parse command line arguments
parse_args "$@"

npm_rc=~/.npmrc

# Handle relink mode
if [ "$RELINK_MODE" = true ]; then
  print_info "Re-linking NPM configuration..."

  # Remove existing link
  if [ -L "$npm_rc" ]; then
    safe_rm "$npm_rc"
  fi

  # Re-link
  safe_ln "$KS_PROJECT_DIR/modules/npm/.npmrc" $npm_rc

  print_success "NPM configuration re-linked"
  exit 0
fi

# Normal installation mode

if is_conf_global
then
  ensure_no_file $npm_rc
  print_info "Link Npm related files to $HOME"
  safe_ln "$KS_PROJECT_DIR/modules/npm/.npmrc" $npm_rc
else
  npm_rc=$KS_CWD/.npmrc
  ensure_no_file $npm_rc
  print_info "Generate configuration file to $KS_CWD"
  safe_cp "$KS_PROJECT_DIR/modules/npm/.npmrc" $npm_rc
fi

# Record installation
record_installation "npm"

