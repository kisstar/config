#!/bin/bash

npm_rc=~/.npmrc

if is_conf_global
then
  ensure_no_file $npm_rc
  print_info "Link Npm related files to $HOME"
  ln -s "$KS_PROJECT_DIR/modules/npm/.npmrc" $npm_rc
else
  npm_rc=$KS_CWD/.npmrc
  ensure_no_file $npm_rc
  print_info "Generate configuration file to $KS_CWD"
  cp "$KS_PROJECT_DIR/modules/npm/.npmrc" $npm_rc
fi
