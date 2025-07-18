#!/bin/bash

readonly KS_CONFIG_ROOT=$HOME
readonly KS_CONFIG_DIR_NAME=.ks-config
readonly KS_PROJECT_DIR=$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME
readonly KS_CWD=$(pwd)

cd $KS_CONFIG_ROOT

# Get Project
function get_prj() {
  if [ $(command -v git) ]; then
    git clone https://github.com/kisstar/config.git $KS_CONFIG_DIR_NAME
  elif [ $(command -v wget) ]; then
    wget https://github.com/kisstar/config/archive/refs/heads/master.zip -O .ks-config.zip
    unzip .ks-config.zip
    mv config-master $KS_CONFIG_DIR_NAME
    rm -rf .ks-config.zip
  else
    echo '[ERROR] Sorry, you need to install git or wget first.'
    exit
  fi
}

# Pull project
if [ -d $KS_CONFIG_DIR_NAME ]; then
  tmp_str=$(echo '[INFO] You have downloaded before. Do you need to download again? [y/n] ')
  read -p "$tmp_str" ans

  if [ "$ans" == 'y' ]; then
    rm -rf $KS_CONFIG_DIR_NAME
    get_prj
  fi
else
  get_prj
fi

# Call log script
source "$KS_PROJECT_DIR/lib/bin/log.sh"
# Call util script
source "$KS_PROJECT_DIR/lib/bin/util.sh"
# Call fs script
source "$KS_PROJECT_DIR/lib/bin/fs.sh"
# Call main script
source "$KS_PROJECT_DIR/lib/bin/main.sh"

echo ""
echo "[SUCCESS] Everything seems to be going well, Enjoy it!"
echo ""
