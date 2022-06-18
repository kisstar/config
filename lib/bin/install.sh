#!/bin/bash

readonly KS_CONFIG_ROOT=$HOME
readonly KS_CONFIG_DIR_NAME=.ks-config
readonly KS_PROJECT_DIR=$KS_CONFIG_ROOT/$KS_CONFIG_DIR_NAME
readonly KS_CWD=$(pwd)

# Call log script
source "$KS_PROJECT_DIR/lib/bin/log.sh"
# Call util script
source "$KS_PROJECT_DIR/lib/bin/util.sh"
# Call fs script
source "$KS_PROJECT_DIR/lib/bin/fs.sh"
# Call main script
source "$KS_PROJECT_DIR/lib/bin/main.sh"

print_info ""
print_success "Everything seems to be going well, Enjoy it!"
print_info ""
