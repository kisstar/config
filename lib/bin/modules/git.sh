#!/bin/bash

git_temp=~/.gitmessage.txt

if is_conf_global
then
  ensure_no_file $git_temp
  print_info "Link Git related files to $HOME"
  ln -s "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/git/.gitmessage.txt" $git_temp
  git config --global commit.template $git_temp
else
  git_temp=$cwd/.gitmessage.txt
  ensure_no_file $git_temp
  cd $cwd
  print_info "Generate configuration file to $cwd"
  cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/git/.gitmessage.txt" $git_temp
  git config --local commit.template $git_temp
fi
