# Currently supported modules
ks_config_arr=('vim' 'npm' 'yarn' 'git' 'eslint')

function includes() {
  for item in ${ks_config_arr[@]}; do
    [ "$item" == "$1" ] && return 0
  done
}

# Currently supported modules
function print_modules() {
  print_info 'Currently supported modules include the following:'
  print_info 'vim: a highly configurable text editor'
  print_info 'npm: a JavaScript package manager'
  print_info 'yarn: a modern package manager split into various packages'
  print_info 'git: a free and open source distributed version control system'
  print_info 'eslint: a tool for find and fix JavaScript code problems'
}

# Select the configuration module to use
function choose_conf() {
  tmp_str=$(print_info 'Please specify the configuration you want to use [vim/npm/???] ')

  while true; do
    print_modules
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
