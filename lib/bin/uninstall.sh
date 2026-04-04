#!/bin/bash

# Uninstall script - removes configuration and optionally restores backups

readonly UNINSTALL_BACKUP_DIR="$KS_PROJECT_DIR/.backup/uninstall-$(date +%Y%m%d-%H%M%S)"

# Main uninstall function
function uninstall_main() {
  local specific_module=""
  local restore_backup=false
  local all_mode=false
  
  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --restore) restore_backup=true ;;
      --all) all_mode=true ;;
      --dry-run) ;; # handled by parse_args in util.sh
      --*) ;; # ignore other flags
      *) specific_module="$arg" ;;
    esac
  done
  
  # Validate arguments
  if [ "$all_mode" = true ]; then
    uninstall_all "$restore_backup"
  elif [ -n "$specific_module" ]; then
    uninstall_module "$specific_module" "$restore_backup"
  else
    print_err "Please specify a module to uninstall or use --all"
    print_info "Usage: uninstall.sh <module>|--all [--restore]"
    print_info "Available modules: vim, git, npm, eslint, tmux"
    exit 1
  fi
}

# Uninstall a specific module
function uninstall_module() {
  local module="$1"
  local restore_backup="${2:-false}"
  
  print_info "Uninstalling $module configuration..."
  
  # Check if module is installed
  if ! is_module_installed "$module"; then
    print_warn "$module is not installed (no record found)"
    
    # Still try to clean up any existing links
    print_info "Attempting cleanup anyway..."
  fi
  
  # Call module-specific uninstall function
  case "$module" in
    vim)    uninstall_vim "$restore_backup" ;;
    git)    uninstall_git "$restore_backup" ;;
    npm)    uninstall_npm "$restore_backup" ;;
    eslint) uninstall_eslint "$restore_backup" ;;
    tmux)   uninstall_tmux "$restore_backup" ;;
    *)
      print_err "Unknown module: $module"
      print_info "Available modules: vim, git, npm, eslint, tmux"
      return 1
      ;;
  esac
  
  # Remove from installation record
  remove_from_installed "$module"
  
  print_success "$module configuration uninstalled"
}

# Uninstall all modules
function uninstall_all() {
  local restore_backup="${1:-false}"
  
  print_info "Uninstalling all configurations..."
  
  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    print_warn "No installation record found"
    return 1
  fi
  
  # Read all installed modules
  local modules=()
  while IFS= read -r module; do
    modules+=("$module")
  done < "$INSTALLED_MODULES_FILE"
  
  print_info "Found ${#modules[@]} installed modules"
  
  for module in "${modules[@]}"; do
    uninstall_module "$module" "$restore_backup"
    echo ""
  done
  
  print_success "All configurations uninstalled"
}

# Module-specific uninstall functions

function uninstall_vim() {
  local restore_backup="$1"
  local targets=("$HOME/.vim" "$HOME/.vimrc")
  
  for target in "${targets[@]}"; do
    if [ -L "$target" ] || [ -e "$target" ]; then
      if [ "$restore_backup" = true ]; then
        restore_latest_backup "$target"
      else
        safe_rm "$target"
      fi
    fi
  done
  
  if [ "$DRY_RUN" = false ] && [ "$restore_backup" = false ]; then
    print_info "Vim configuration removed"
  fi
}

function uninstall_git() {
  local restore_backup="$1"
  local target="$HOME/.gitmessage.txt"
  
  # Remove git config setting
  if [ "$DRY_RUN" = false ]; then
    git config --global --unset commit.template 2>/dev/null || true
  else
    echo "  [WOULD EXECUTE] git config --global --unset commit.template"
  fi
  
  # Remove the message template file
  if [ -L "$target" ] || [ -f "$target" ]; then
    if [ "$restore_backup" = true ]; then
      restore_latest_backup "$target"
    else
      safe_rm "$target"
    fi
  fi
}

function uninstall_npm() {
  local restore_backup="$1"
  local target="$HOME/.npmrc"
  
  if [ -L "$target" ] || [ -f "$target" ]; then
    if [ "$restore_backup" = true ]; then
      restore_latest_backup "$target"
    else
      safe_rm "$target"
    fi
  fi
}

function uninstall_eslint() {
  local restore_backup="$1"
  local target="$KS_CWD/.eslintrc.js"
  
  if [ -L "$target" ] || [ -f "$target" ]; then
    if [ "$restore_backup" = true ]; then
      restore_latest_backup "$target"
    else
      safe_rm "$target"
    fi
  fi
  
  if [ "$DRY_RUN" = false ]; then
    print_info "Note: ESLint dependencies in package.json were not removed"
    print_info "You may want to run: npm uninstall eslint-config-airbnb-base ..."
  fi
}

function uninstall_tmux() {
  local restore_backup="$1"
  local target="$HOME/.tmux.conf"
  
  if [ -L "$target" ] || [ -f "$target" ]; then
    if [ "$restore_backup" = true ]; then
      restore_latest_backup "$target"
    else
      safe_rm "$target"
    fi
  fi
}

# Remove module from installation record
function remove_from_installed() {
  local module="$1"
  
  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    return
  fi
  
  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD REMOVE] $module from $INSTALLED_MODULES_FILE"
    return
  fi
  
  # Remove the line matching this module
  if grep -q "^${module}$" "$INSTALLED_MODULES_FILE" 2>/dev/null; then
    # Use sed to delete the line
    sed -i.bak "/^${module}$/d" "$INSTALLED_MODULES_FILE"
    rm -f "$INSTALLED_MODULES_FILE.bak"
    print_info "Removed $module from installation record"
  fi
}

# Restore latest backup for a file/directory
function restore_latest_backup() {
  local target="$1"
  local name=$(basename "$target")
  local parent=$(dirname "$target")
  
  # Find backups matching pattern: target-YYYYMMDD-random
  local backup_pattern="${target}-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*"
  local latest_backup=$(ls -td $backup_pattern 2>/dev/null | head -n1)
  
  # Also check for drift backups
  local drift_pattern="${target}-drift-backup-*"
  local drift_backup=$(ls -td $drift_pattern 2>/dev/null | head -n1)
  
  # Use the most recent of either type
  local backup_to_restore=""
  if [ -n "$latest_backup" ] && [ -n "$drift_backup" ]; then
    if [ "$latest_backup" -nt "$drift_backup" ]; then
      backup_to_restore="$latest_backup"
    else
      backup_to_restore="$drift_backup"
    fi
  elif [ -n "$latest_backup" ]; then
    backup_to_restore="$latest_backup"
  elif [ -n "$drift_backup" ]; then
    backup_to_restore="$drift_backup"
  fi
  
  if [ -n "$backup_to_restore" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "  [WOULD RESTORE] $target from $backup_to_restore"
    else
      # Remove current symlink/file first
      if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
      fi
      
      # Move backup to original location
      mv "$backup_to_restore" "$target"
      print_success "Restored $name from backup"
    fi
  else
    print_warn "No backup found for $name"
    # Still remove the symlink
    if [ -L "$target" ]; then
      safe_rm "$target"
    fi
  fi
}

# Main execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  # Script is being run directly
  if [ -z "$KS_PROJECT_DIR" ]; then
    echo "[ERROR] KS_PROJECT_DIR is not set. Please run through main.sh"
    exit 1
  fi
  
  source "$KS_PROJECT_DIR/lib/bin/log.sh"
  source "$KS_PROJECT_DIR/lib/bin/util.sh"
  
  parse_args "$@"
  uninstall_main "$@"
fi
