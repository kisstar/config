#!/bin/bash

readonly KS_CONFIG_ROOT=$HOME
readonly KS_CONFIG_DIR_NAME=.ks-config

prj_dir=$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME
config_arr=('vim')

function print_info() {
  echo $*
}

function print_err() {
  echo "\033[31m$*\033[0m"
}

function print_warn() {
  echo "\033[33m$*\033[0m"
}

function print_success() {
  echo "\033[32m$*\033[0m"
}

function clone_prj() {
  if [ `command -v git` ]
  then
    git clone $*
  else
    print_err 'Sorry, you need to install git first'
    exit
  fi
}

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
        source "$prj_dir/lib/bin/$ans.sh"
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

# Pull project
if [ -d $KS_CONFIG_DIR_NAME ]
then
  tmp_str=`print_info 'You have downloaded before. Do you need to download again? [y/n] '`
  read -p "$tmp_str" ans
  if [ "$ans" == 'y' ]
  then
    rm -rf $KS_CONFIG_DIR_NAME
    clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR_NAME
  fi
else
  clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR_NAME
fi

# Call public script
source "$prj_dir/lib/bin/utils.sh"

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
