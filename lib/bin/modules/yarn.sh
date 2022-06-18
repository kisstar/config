#!/bin/bash

yarn_rc=~/.yarnrc

if is_conf_global
then
  ensure_no_file $yarn_rc
  print_info "Link Yarn related files to $HOME"
  ln -s "KS_PROJECT_DIR/modules/yarn/.yarnrc" $yarn_rc
else
  yarn_rc=$KS_CWD/.yarnrc
  ensure_no_file $yarn_rc
  print_info "Generate configuration file to $KS_CWD"
  cp "KS_PROJECT_DIR/modules/yarn/.yarnrc" $yarn_rc
fi
