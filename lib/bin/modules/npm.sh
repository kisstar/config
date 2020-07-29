#!/bin/bash

npm_rc=~/.npmrc

if is_conf_global
then
  ensure_no_file $npm_rc
  print_info "Link Npm related files to $HOME"
  ln -s "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/npm/.npmrc" $npm_rc
else
  npm_rc=$cwd/.npmrc
  ensure_no_file $npm_rc
  print_info "Generate configuration file to $cwd"
  cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/npm/.npmrc" $npm_rc
fi
