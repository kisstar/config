#!/bin/bash

eslint_file=$KS_CWD/.eslintrc.js
npm_lock_file=package-lock.json
# Currently supported type
eslint_type_arr=('0', '1' '2' '3')

# Check .eslintrc.js
ensure_no_file $eslint_file

# See: https://github.com/airbnb/javascript
function airbnb_base() {
  pkg_name=eslint-config-airbnb-base

  if [ -d $npm_lock_file ]; then
    npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install --save-dev "$pkg_name@latest"
  else
    npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs yarn add --save-dev "$pkg_name@latest"
  fi

  cp "$KS_PROJECT_DIR/modules/eslint/browser-airbnb.js" $eslint_file
}

# See: https://github.com/iamturns/eslint-config-airbnb-typescript
function airbnb_base_ts() {
  pkg_name=eslint-config-airbnb-typescript

  if [ -d $npm_lock_file ]; then
    npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install --save-dev "$pkg_name@latest"
  else
    npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs yarn add --save-dev "$pkg_name@latest"
  fi

  cp "$KS_PROJECT_DIR/modules/eslint/browser-airbnb-ts.js" $eslint_file
}

# See: https://github.com/prettier/eslint-plugin-prettie
function with_prettier() {
  if [ -d $npm_lock_file ]; then
    npm install --save-dev prettier eslint-plugin-prettier eslint-config-prettier
  else
    yarn add --save-dev prettier eslint-plugin-prettier eslint-config-prettier
  fi

  cp "$KS_PROJECT_DIR/modules/eslint/browser-airbnb-ts-prettier.js" $eslint_file
}

# Currently supported configuration types
function print_slect() {
  print_info 'Currently supported configurations include the following:'
  print_info '0: Official basic configuration'
  print_info '1: Airbnb JavaScript style'
  print_info '2: Airbnb TypeScripts style'
  print_info '3: Airbnb TypeScripts style With Prettier'
}

# Execute the corresponding script according to the selected type
function exec_slect() {
  case $1 in
  0)
    npm init @eslint/config
    ;;
  1)
    airbnb_base
    ;;
  2)
    airbnb_base_ts
    ;;
  3)
    airbnb_base_ts
    with_prettier
    ;;
  *)
    print_err 'Unknown type'
    ;;
  esac
}

# Select the configuration module to use
function choose_conf() {
  tmp_str=$(print_info 'Please specify the configuration you want to use [1/2/???] ')

  while true; do
    print_slect
    read -p "$tmp_str" ans

    if [ "$ans" ]; then
      if includes $ans; then
        exec_slect $ans
        break
      else
        print_err 'Sorry, the configuration you specified is not supported.'
      fi
    else
      print_err 'You need to specify the configuration you want to install.'
    fi
  done
}
