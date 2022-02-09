#!/bin/bash

eslint_file=$cwd/.eslintrc.js
npm_lock_file=package-lock.json

# Check .eslintrc.js
ensure_no_file $eslint_file

if [ -d $npm_lock_file ]; then
  pkg_name=eslint-config-airbnb-base
  npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install --save-dev "$pkg_name@latest"
else
  pkg_name=eslint-config-airbnb-base
  npm info "$pkg_name@latest" peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs yarn add --save-dev "$pkg_name@latest"
fi

cp "$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME/modules/eslint/browser-airbnb.js" $eslint_file
