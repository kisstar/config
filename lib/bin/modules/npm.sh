#!/bin/bash

npm_rc=~/.npmrc
tip="Start generating configuration file"

if is_conf_global
then
  npm_rc=~/.npmrc
  tip="Generate configuration file to $HOME"
else
  npm_rc=$cwd/.npmrc
  tip="Generate configuration file to $cwd"
fi

# Check .npmrc
ensure_no_file $npm_rc

# Generate configuration file
print_info $tip
cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/npm/.npmrc" $npm_rc
