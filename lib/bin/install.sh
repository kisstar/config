#!/bin/bash

readonly KS_CONFIG_ROOT=$HOME
readonly KS_CONFIG_DIR=.ks-config

config_arr=('vim')

source "$KS_CONFIG_ROOT/$KS_CONFIG_DIR/lib/bin/utils.sh"

function includes() {
  for item in ${config_arr[@]}
  do
    [ "$item" == "$1" ] && return 0
  done
}

function choose_conf() {
  tmp_str=`print_info 'Please specify the configuration you want to use [vim] '`
  while true
  do
    read -p "$tmp_str" ans
    if [ "$ans" ]
    then
      if includes $ans
      then
        source "$KS_CONFIG_ROOT/$KS_CONFIG_DIR/lib/bin/$ans.sh"
        break
      else
        print_err 'Sorry, the configuration you specified is not supported'
      fi
    else
      print_err 'You need to specify the configuration you want to install'
    fi
    print_info "Optional inputs include: ${config_arr[*]}"
  done
}

cd $KS_CONFIG_ROOT

if [ -d $KS_CONFIG_DIR ]
then
  tmp_str=`print_info 'You have downloaded before. Do you need to download again? [y/n] '`                                                                                                                      read -p "$tmp_str" ans
  if [ "$ans" == 'y' ]
  then
    rm -rf $KS_CONFIG_DIR
    clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR
  fi
else
  clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR
fi

if [ "$1" ]
then
  if includes $1
  then
    source "./lib/bin/$1.sh"
  else
    print_err 'Sorry, the configuration you specified is not supported'
    choose_conf
  fi
else
    choose_conf
fi

print_info ""
print_success "Everything seems to be   going well, Enjoy it!"
print_info ""
