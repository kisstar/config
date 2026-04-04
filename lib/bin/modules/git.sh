#!/bin/bash

# Parse command line arguments
parse_args "$@"

git_temp=~/.gitmessage.txt

# Handle relink mode
if [ "$RELINK_MODE" = true ]; then
  print_info "Re-linking Git configuration..."

  # Remove existing link
  if [ -L "$git_temp" ]; then
    safe_rm "$git_temp"
  fi

  # Re-link
  safe_ln "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" $git_temp

  # Re-apply config
  if [ "$DRY_RUN" = false ]; then
    git config --global commit.template $git_temp
  else
    echo "  [WOULD EXECUTE] git config --global commit.template $git_temp"
  fi

  print_success "Git configuration re-linked"
  exit 0
fi

# Normal installation mode

if is_conf_global
then
  ensure_no_file $git_temp
  print_info "Link Git related files to $HOME"
  safe_ln "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" $git_temp

  if [ "$DRY_RUN" = false ]; then
    git config --global commit.template $git_temp
  else
    echo "  [WOULD EXECUTE] git config --global commit.template $git_temp"
  fi
else
  git_temp=$KS_CWD/.gitmessage.txt
  ensure_no_file $git_temp
  cd $KS_CWD
  print_info "Generate configuration file to $KS_CWD"
  safe_cp "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" $git_temp

  if [ "$DRY_RUN" = false ]; then
    git config --local commit.template $git_temp
  else
    echo "  [WOULD EXECUTE] git config --local commit.template $git_temp"
  fi
fi

# Record installation
record_installation "git"

