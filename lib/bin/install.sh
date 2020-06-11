#!/bin/bash

export KS_CONFIG_ROOT=$HOME
export KS_CONFIG_DIR=.ks-config
config_arr=('vim')

function print_info() {
  echo $*
}

function print_err() {
  echo "\033[31m$*\033[0m"
}

cd $KS_CONFIG_ROOT

if [ -d $KS_CONFIG_DIR ]
then
  tmp_str=`print_info 'You have downloaded before. Do you need to download again? [y/n] '`
  read -p "$tmp_str" ans
  if [ "$ans" == 'y' ]
    # Check git
    if [ `command -v git` ]
    then
      rm -rf $KS_CONFIG_DIR
      git clone https://github.com/kisstar/config.git $KS_CONFIG_DIR
    else
      print_err 'Sorry, you need to install git first'
      exit
    fi
  fi
elif [ `command -v git` ]
then
  git clone https://github.com/kisstar/config.git $KS_CONFIG_DIR
else
  print_err 'Sorry, you need to install git first'
  exit
fi

if [ "$1" ]
then
  if [[ "${config_arr[@]}" =~ "$1" ]]
  then
    source "$targe_dir/lib/bin/$1.sh"
  else
    print_err 'Sorry, the configuration you specified is not supported'
  fi
else
  tmp_str `print_info 'Please specify the configuration you want to use [vim] '` ans
  read -p "$tmp_str" ans
  if [[ "${config_arr[@]}" =~ "$ans" ]]
  then
    source "$targe_dir/lib/bin/$ans.sh"
  elif [ "$ans" ]
  then
    print_err 'Sorry, the configuration you specified is not supported'
  else
    print_err 'You need to specify the configuration you want to install'
  fi
fi

print_info ""
print_success "Everything seems to be going well, Enjoy it!"
print_info ""
