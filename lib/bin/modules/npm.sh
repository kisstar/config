#!/bin/bash

npm_rc=~/.npmrc
tip="Start generating configuration file"

function conf_local() {
  npm_rc=$cwd/.npmrc
  tip="Generate configuration file to $cwd"
}

function conf_global() {
  npm_rc=~/.npmrc
  tip="Generate configuration file to $HOME"
}

function choose_conf_range() {
  tmp_str=`print_info 'Please specify the scope to be configured [global/local] '`
  if [ "$1" ]
  then
    tmp_str=`print_info 'Please specify the correct scope option [global/local] '`
  fi
  read -p "$tmp_str" ans
  if [ "$ans" ]
  then
    if [ "$ans" == 'global' ]
    then
      conf_global
    elif [ "$ans" == 'local' ]
    then
      conf_local
    else
      choose_conf_range "Retry"
    fi
  else
    conf_local
  fi
}

choose_conf_range

# Check .npmrc
ensure_no_file $npm_rc

# Generate configuration file
print_info $tip
cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/npm/.npmrc" $npm_rc
