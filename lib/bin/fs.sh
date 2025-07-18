# Ensure that the specified directory does not exist
function ensure_no_folder() {
  filename=$1
  name=${filename##*/}
  backup_rand=$RANDOM

  if [ -d $filename ]; then
    print_err "You already have a $name folder in $filename"
    tmp_str=$(print_info 'Would you like to backup this folder first? [y/n] ')
    read -p "$tmp_str" ans

    if [ "$ans" == 'y' ]; then
      print_info "Backup your original $filename to $filename-$(date +%Y%m%d)-$backup_rand"
      mv $filename $filename-$(date +%Y%m%d)-$backup_rand
    else
      tmp_str=$(print_warn 'Are you sure you want to delete this folder? [y/n] ')
      read -p "$tmp_str" ans

      if [ "$ans" == 'y' ]; then
        rm -rf $filename
      else
        print_err "You have a $filename now, please backup or delete this first."
        exit
      fi
    fi
  fi
}

# Ensure that the specified file does not exist
function ensure_no_file() {
  filename=$1
  name=${filename##*/}
  backup_rand=$RANDOM

  if [ -f $filename ]; then
    print_err "There's a $name file in $filename"
    tmp_str=$(print_info 'Would you like to backup this file first? [y/n] ')
    read -p "$tmp_str" ans

    if [ "$ans" == 'y' ]; then
      print_info "Backup your original $filename to $filename-$(date +%Y%m%d)-$backup_rand"
      mv $filename $filename$(date +%Y%m%d)-$backup_rand
    else
      tmp_str=$(print_warn 'Are you sure you want to delete this file? [y/n] ')
      read -p "$tmp_str" ans

      if [ "$ans" == 'y' ]; then
        rm -rf $filename
      else
        print_err "You have a $filename now, please backup or delete this first."
        exit
      fi
    fi
  fi
}
