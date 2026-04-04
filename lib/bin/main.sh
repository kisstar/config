# Currently supported modules
ks_config_arr=('vim' 'npm' 'git' 'eslint' 'tmux')

# Currently supported commands
ks_command_arr=('install' 'update' 'doctor' 'drift' 'uninstall')

function includes() {
  for item in ${ks_config_arr[@]}; do
    [ "$item" == "$1" ] && return 0
  done
}

function includes_command() {
  for item in ${ks_command_arr[@]}; do
    [ "$item" == "$1" ] && return 0
  done
}

# Print available modules
function print_modules() {
  print_info 'Currently supported modules include the following:'
  print_info 'vim: a highly configurable text editor'
  print_info 'npm: a JavaScript package manager'
  print_info 'git: a free and open source distributed version control system'
  print_info 'eslint: a tool for find and fix JavaScript code problems'
  print_info 'tmux: a terminal multiplexer'
}

# Print available commands
function print_commands() {
  print_info 'Available commands:'
  print_info 'install <module>: install a configuration module (default if module specified directly)'
  print_info 'update [module]: update configurations from remote and re-link'
  print_info 'doctor: run health checks on configuration'
  print_info 'drift [--fix]: detect configuration drift (local modifications)'
  print_info 'uninstall <module>|--all: remove configuration'
}

# Print help
function print_help() {
  echo "Usage: main.sh [command] [options]"
  echo ""
  print_modules
  echo ""
  print_commands
  echo ""
  print_info 'Options:'
  print_info '--dry-run: preview changes without making them'
  print_info '--force: force operation without prompts'
  print_info '--restore: restore from backup when uninstalling'
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

# Route commands
function route_command() {
  local cmd="$1"
  shift

  case "$cmd" in
    install)
      if [ -n "$1" ] && includes "$1"; then
        source "$KS_PROJECT_DIR/lib/bin/modules/$1.sh" "${@:2}"
      else
        choose_conf
      fi
      ;;
    update)
      source "$KS_PROJECT_DIR/lib/bin/update.sh" "$@"
      ;;
    doctor)
      source "$KS_PROJECT_DIR/lib/bin/doctor.sh" "$@"
      ;;
    drift)
      source "$KS_PROJECT_DIR/lib/bin/drift.sh" "$@"
      ;;
    uninstall)
      source "$KS_PROJECT_DIR/lib/bin/uninstall.sh" "$@"
      ;;
    help|--help|-h)
      print_help
      ;;
    *)
      print_err "Unknown command: $cmd"
      print_help
      exit 1
      ;;
  esac
}

# Start configuration
if [ "$1" ]; then
  # Check if it's a command
  if includes_command "$1"; then
    route_command "$@"
  # Check if it's a module (treat as install command)
  elif includes "$1"; then
    source "$KS_PROJECT_DIR/lib/bin/modules/$1.sh" "${@:2}"
  else
    print_err "Sorry, '$1' is not a recognized command or module"
    print_info "Run 'main.sh help' for usage information"
    choose_conf
  fi
else
  print_modules
  echo ""
  print_commands
  echo ""
  choose_conf
fi

