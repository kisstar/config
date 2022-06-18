#!/bin/bash

git_temp=~/.gitmessage.txt

if is_conf_global
then
  ensure_no_file $git_temp
  print_info "Link Git related files to $HOME"
  ln -s "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" $git_temp
  git config --global commit.template $git_temp
else
  git_temp=$KS_CWD/.gitmessage.txt
  ensure_no_file $git_temp
  cd $KS_CWD
  print_info "Generate configuration file to $KS_CWD"
  cp "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" $git_temp
  git config --local commit.template $git_temp
fi
