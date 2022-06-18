function is_conf_global() {
  tmp_str=$(print_info 'Please specify the scope to be configured [global/local] ')

  if [ "$1" ]; then
    tmp_str=$(print_info 'Please specify the correct scope option [global/local] ')
  fi

  read -p "$tmp_str" ans

  if [ "$ans" ]; then
    if [ "$ans" == 'global' ]; then
      return 0
    elif [ "$ans" == 'local' ]; then
      return 1
    else
      is_conf_global "Retry"
    fi
  else
    is_conf_global
  fi
}

function only_simple() {
  tmp_str=$(print_info 'Do you want to set only the simplest configuration? [y/n] ')
  read -p "$tmp_str" ans

  if [ "$ans" == 'y' ]; then
    return 0
  else
    return 1
  fi
}
