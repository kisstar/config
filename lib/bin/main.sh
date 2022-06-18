# Currently supported modules
ks_config_arr=('vim' 'npm' 'yarn' 'git' 'eslint')

function includes() {
  for item in ${ks_config_arr[@]}; do
    [ "$item" == "$1" ] && return 0
  done
}

function choose_conf() {
  tmp_str=$(print_info 'Please specify the configuration you want to use [vim/npm/???] ')

  while true; do
    read -p "$tmp_str" ans

    if [ "$ans" ]; then
      if includes $ans; then
        source "$KS_PROJECT_DIR/lib/bin/modules/$ans.sh"
        break
      else
        print_err 'Sorry, the configuration you specified is not supported.'
      fi
    else
      print_err 'You need to specify the configuration you want to install.'
    fi
    print_info "Optional inputs include: ${ks_config_arr[*]}"
  done
}

cd $KS_CONFIG_ROOT

# Pull project
if [ -d $KS_CONFIG_DIR_NAME ]; then
  tmp_str=$(print_info 'You have downloaded before. Do you need to download again? [y/n] ')
  read -p "$tmp_str" ans

  if [ "$ans" == 'y' ]; then
    rm -rf $KS_CONFIG_DIR_NAME
    clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR_NAME
  fi
else
  clone_prj https://github.com/kisstar/config.git $KS_CONFIG_DIR_NAME
fi

# Start configuration
if [ "$1" ]; then
  if includes $1; then
    source "$KS_PROJECT_DIR/lib/bin/modules/$1.sh"
  else
    print_err 'Sorry, the configuration you specified is not supported'
    choose_conf
  fi
else
  choose_conf
fi
