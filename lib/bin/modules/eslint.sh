#!/bin/bash

eslint_file=$KS_CWD/.eslintrc.js
npm_lock_file=package-lock.json

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
