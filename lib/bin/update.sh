#!/bin/bash

# Update script - pulls latest configs from remote and re-links

readonly UPDATE_BACKUP_DIR="$KS_PROJECT_DIR/.backup/update-$(date +%Y%m%d-%H%M%S)"

# Main update function
function update_configs() {
  local specific_module=""
  local force_mode=false
  
  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --force) force_mode=true ;;
      --dry-run) ;; # handled by parse_args in util.sh
      --*) ;; # ignore other flags
      *) specific_module="$arg" ;;
    esac
  done
  
  print_info "Starting configuration update..."
  
  # 1. Check if in git repository
  if [ ! -d "$KS_PROJECT_DIR/.git" ]; then
    print_err "Not a git repository. Cannot update."
    exit 1
  fi
  
  cd "$KS_PROJECT_DIR"
  
  # 2. Check for local changes
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    print_warn "You have uncommitted local changes"
    
    if [ "$DRY_RUN" = false ] && [ "$force_mode" = false ]; then
      read -p "Stash local changes before update? [y/n]: " ans
      if [ "$ans" = "y" ]; then
        git stash push -m "auto-stash-before-update-$(date +%Y%m%d-%H%M%S)"
        print_success "Local changes stashed"
      fi
    fi
  fi
  
  # 3. Fetch updates from remote
  print_info "Fetching updates from remote..."
  
  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD EXECUTE] git pull origin master"
  else
    if ! git pull origin master; then
      print_err "Failed to pull updates. Please resolve conflicts manually."
      exit 1
    fi
    print_success "Repository updated"
  fi
  
  # 4. Check for drift
  print_info "Checking for configuration drift..."
  source "$KS_PROJECT_DIR/lib/bin/drift.sh"
  
  local drifted_configs=()
  detect_drift_array drifted_configs
  
  # 5. Handle drifted configs
  if [ ${#drifted_configs[@]} -gt 0 ] && [ "$DRY_RUN" = false ]; then
    print_warn "Found ${#drifted_configs[@]} modified configurations"
    
    if [ "$force_mode" = true ]; then
      print_info "Force mode: backing up and overwriting local changes..."
      backup_and_update "${drifted_configs[@]}"
    else
      echo ""
      echo "Options:"
      echo "  [b] Backup local changes and update"
      echo "  [k] Keep local changes (skip these files)"
      echo "  [o] Overwrite with remote version (no backup)"
      echo "  [a] Abort update"
      read -p "Choose action [b/k/o/a]: " action
      
      case "$action" in
        b|B) backup_and_update "${drifted_configs[@]}" ;;
        k|K) skip_configs "${drifted_configs[@]}" ;;
        o|O) ;; # Just continue, will overwrite
        a|A) print_info "Update aborted"; exit 0 ;;
        *) print_err "Invalid option"; exit 1 ;;
      esac
    fi
  elif [ ${#drifted_configs[@]} -gt 0 ] && [ "$DRY_RUN" = true ]; then
    echo "  [WOULD DETECT] ${#drifted_configs[@]} drifted configurations"
    for config in "${drifted_configs[@]}"; do
      echo "    - $config"
    done
  fi
  
  # 6. Re-link configurations
  if [ -n "$specific_module" ]; then
    print_info "Re-linking $specific_module..."
    relink_module "$specific_module"
  else
    print_info "Re-linking all configurations..."
    relink_all_configs
  fi
  
  print_success "Update completed!"
}

# Backup configs before updating
function backup_and_update() {
  local configs=("$@")
  
  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD BACKUP] ${#configs[@]} configurations to $UPDATE_BACKUP_DIR"
    return
  fi
  
  mkdir -p "$UPDATE_BACKUP_DIR"
  
  for config in "${configs[@]}"; do
    if [ -e "$config" ]; then
      local name=$(basename "$config")
      if [ -d "$config" ]; then
        cp -r "$config" "$UPDATE_BACKUP_DIR/$name"
      else
        cp "$config" "$UPDATE_BACKUP_DIR/"
      fi
      print_info "Backed up $name"
    fi
    
    # Remove the old link/file
    rm -rf "$config"
  done
  
  print_success "All drifted configs backed up to $UPDATE_BACKUP_DIR"
}

# Skip specific configs during update
function skip_configs() {
  local configs=("$@")
  print_info "Skipping ${#configs[@]} configurations (keeping local changes)"
  
  # Add to skip list for relinking
  export SKIP_CONFIGS="${configs[*]}"
}

# Re-link all installed modules
function relink_all_configs() {
  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    print_warn "No installation record found. Nothing to re-link."
    return
  fi
  
  while IFS= read -r module; do
    # Skip if in skip list
    if [[ " $SKIP_CONFIGS " =~ " $module " ]]; then
      print_info "Skipping $module (user requested)"
      continue
    fi
    
    relink_module "$module"
  done < "$INSTALLED_MODULES_FILE"
}

# Re-link specific module
function relink_module() {
  local module="$1"
  local module_script="$KS_PROJECT_DIR/lib/bin/modules/$module.sh"
  
  if [ ! -f "$module_script" ]; then
    print_err "Module script not found: $module_script"
    return 1
  fi
  
  print_info "Re-linking $module..."
  
  if [ "$DRY_RUN" = true ]; then
    echo "  [WOULD EXECUTE] $module_script --relink --dry-run"
  else
    # Source the module with --relink flag
    RELINK_MODE=true
    source "$module_script" --relink
    unset RELINK_MODE
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
  update_configs "$@"
fi
