# Global preview mode flag
DRY_RUN=false

# Parse command line arguments
function parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run)
        DRY_RUN=true
        print_info "[DRY RUN MODE] No changes will be made"
        ;;
      --relink)
        RELINK_MODE=true
        ;;
    esac
  done
}

# Safe execution function - prints command in dry-run mode
function safe_exec() {
  local description="$1"
  shift

  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD EXECUTE] $description"
    echo "    Command: $*"
  else
    eval "$@"
  fi
}

# Safe symbolic link creation
function safe_ln() {
  local source="$1"
  local target="$2"

  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD LINK] $source -> $target"
  else
    ln -s "$source" "$target"
  fi
}

# Safe move operation
function safe_mv() {
  local source="$1"
  local target="$2"

  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD MOVE] $source -> $target"
  else
    mv "$source" "$target"
  fi
}

# Safe remove operation
function safe_rm() {
  local target="$1"

  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD REMOVE] $target"
  else
    rm -rf "$target"
  fi
}

# Safe copy operation
function safe_cp() {
  local source="$1"
  local target="$2"

  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD COPY] $source -> $target"
  else
    cp "$source" "$target"
  fi
}

# Record module installation
readonly INSTALLED_MODULES_FILE="$KS_PROJECT_DIR/.installed_modules"

function record_installation() {
  local module="$1"

  # Create file if not exists
  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    mkdir -p "$(dirname "$INSTALLED_MODULES_FILE")"
    touch "$INSTALLED_MODULES_FILE"
  fi

  # Avoid duplicate entries
  if ! grep -q "^${module}$" "$INSTALLED_MODULES_FILE" 2>/dev/null; then
    echo "$module" >> "$INSTALLED_MODULES_FILE"
    print_info "Recorded installation of $module"
  fi
}

# Check if module is installed
function is_module_installed() {
  local module="$1"

  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    return 1
  fi

  grep -q "^${module}$" "$INSTALLED_MODULES_FILE"
}

# Confirm whether the configuration is global or local
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

# Confirm whether to use the basic configuration
function only_simple() {
  tmp_str=$(print_info 'Do you want to set only the simplest configuration? [y/n] ')
  read -p "$tmp_str" ans

  if [ "$ans" == 'y' ]; then
    return 0
  else
    return 1
  fi
}
