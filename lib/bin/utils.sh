function ensure_no_folder() {
  filename=$1
  name=${filename##*/}
  backup_rand=$RANDOM

  if [ -d $filename ]
  then
    print_err "You already have a $name folder in $filename"
    read -p 'Would you like to backup this folder first? [y/n] ' ans
    if [ "$ans" == 'y' ]
    then
      print_info "Backup your original $filename to $filename-$(date +%Y%m%d)-$backup_rand"
      mv $filename $filename-$(date +%Y%m%d)-$backup_rand
    else
      tmp_str=`print_warn 'Are you sure you want to delete this folder? [y/n] '`
      read -p "$tmp_str" ans
      if [ "$ans" == 'y' ]
      then
        rm -rf $filename
      else
        print_err "You have a $filename now, please backup or delete this first"
        exit
      fi
    fi
  fi
}

function ensure_no_file() {
  filename=$1
  name=${filename##*/}
  backup_rand=$RANDOM

  if [ -f $filename ]
  then
    print_err "There's a $name file in $filename"
    read -p 'Would you like to backup this file first? [y/n] ' ans
    if [ "$ans" == 'y' ]
    then
      print_info "Backup your original $filename to $filename-$(date +%Y%m%d)-$backup_rand"
      mv $filename $filename$(date +%Y%m%d)-$backup_rand
    else
      tmp_str=`print_warn 'Are you sure you want to delete this file? [y/n] '`
      read -p "$tmp_str" ans
      if [ "$ans" == 'y' ]
      then
        rm -rf $filename
      else
        print_err "You have a $filename now, please backup or delete this first"
        exit
      fi
    fi
  fi
}

function is_conf_global() {
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
      return 0
    elif [ "$ans" == 'local' ]
    then
      return 1
    else
      is_conf_global "Retry"
    fi
  else
    is_conf_global
  fi
}

function only_simple() {
  tmp_str=`print_info 'Do you want to set only the simplest configuration? [y/n] '`
  read -p "$tmp_str" ans
  if [ "$ans" == 'y' ]
  then
    return 0
  else
    return 1
  fi
}
