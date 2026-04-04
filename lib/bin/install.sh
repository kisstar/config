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

# Create necessary directories
mkdir -p "$KS_PROJECT_DIR/.backup"

# Call log script
source "$KS_PROJECT_DIR/lib/bin/log.sh"
# Call util script
source "$KS_PROJECT_DIR/lib/bin/util.sh"
# Parse arguments for dry-run mode
parse_args "$@"
# Call fs script
source "$KS_PROJECT_DIR/lib/bin/fs.sh"
# Call main script with all arguments
source "$KS_PROJECT_DIR/lib/bin/main.sh" "$@"

echo ""
echo "[SUCCESS] Everything seems to be going well, Enjoy it!"
echo ""
echo "Quick commands (after reload or sourcing your shell config):"
echo "  ~/.ks-config/lib/bin/update.sh   - Update configurations"
echo "  ~/.ks-config/lib/bin/doctor.sh   - Run health checks"
echo "  ~/.ks-config/lib/bin/drift.sh    - Check for drift"
echo "  ~/.ks-config/lib/bin/uninstall.sh - Remove configurations"
echo ""
