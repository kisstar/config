#!/bin/bash

vim_folder=~/.vim
vim_rc=~/.vimrc
backup_rand=$RANDOM

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

# Check .vim folder
if [ -d $vim_folder ]
then
  print_err "You already have a .vim folder in $vim_folder"
  read -p 'Would you like to backup your .vim folder first? [y/n] ' ans
  if [ "$ans" == 'y' ]
  then
    print_info "backup your original $vim_folder to $vim_folder-$(date +%Y%m%d)-$backup_rand"
    mv $vim_folder $vim_folder-$(date +%Y%m%d)-$backup_rand
  else
    tmp_str=`print_warn 'Are you sure you want to delete the current .vim folder? [y/n] '`
    read -p "$tmp_str" ans
    if [ "$ans" == 'y' ]
    then
      rm -rf $vim_folder
    else
      print_err "You have a $vim_folder now, please backup or delete this first"
      exit
    fi
  fi
fi

# Check .vimrc
if [ -f $vim_rc ]
then
  print_err "There's a .vimrc file in $vim_rc"
  read -p 'Would you like to backup your .vimrc file first? [y/n] ' ans
  if [ "$ans" == 'y' ]
  then
    print_info "backup your original $vim_rc to $vim_rc-$(date +%Y%m%d)-$backup_rand"
    mv $vim_rc $vim_rc$(date +%Y%m%d)-$backup_rand
  else
    tmp_str=`print_warn 'Are you sure you want to delete the current .vimrc file? [y/n] '`
    read -p "$tmp_str" ans
    if [ "$ans" == 'y' ]
    then
      rm -rf $vim_rc
    else
      print_err "You have a $vim_rc now, please backup or delete this first"
      exit
    fi
  fi
fi

# Make symbolic links
print_info "Link Vim related files to $HOME"
ln -s "$KS_CONFIG_ROOT/$KS_CONFIG_DIR/modules/vim/.vim" $vim_folder
ln -s "$KS_CONFIG_ROOT/$KS_CONFIG_DIR/modules/vim/.vimrc" $vim_rc

# Install all plugins
vim +'PlugInstall --sync' +qa
