#!/bin/bash

yarn_rc=~/.yarnrc

if is_conf_global
then
  ensure_no_file $yarn_rc
  print_info "Link Yarn related files to $HOME"
  ln -s "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/yarn/.yarnrc" $yarn_rc
else
  yarn_rc=$cwd/.yarnrc
  ensure_no_file $yarn_rc
  print_info "Generate configuration file to $cwd"
  cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/yarn/.yarnrc" $yarn_rc
fi
