#!/bin/bash

# Configuration drift detection script
# Detects differences between repository configs and local configs

# Status constants
readonly DRIFT_SYNCED="SYNCED"
readonly DRIFT_MODIFIED="MODIFIED"
readonly DRIFT_MISSING_LINK="MISSING_LINK"
readonly DRIFT_EXTERNAL="EXTERNAL"
readonly DRIFT_NOT_INSTALLED="NOT_INSTALLED"

# Check single file drift status
# Returns: SYNCED, MODIFIED, MISSING_LINK, EXTERNAL, NOT_INSTALLED
function check_file_drift() {
  local source_file="$1"
  local link_file="$2"
  
  # Source file doesn't exist in repo
  if [ ! -e "$source_file" ]; then
    echo "$DRIFT_NOT_INSTALLED"
    return
  fi
  
  # Link doesn't exist
  if [ ! -e "$link_file" ]; then
    if [ -L "$link_file" ]; then
      # Broken symlink
      echo "$DRIFT_MISSING_LINK"
    else
      echo "$DRIFT_NOT_INSTALLED"
    fi
    return
  fi
  
  # Not a symlink - check if it's the actual file or external
  if [ ! -L "$link_file" ]; then
    # Check if content matches (user copied file instead of linking)
    if diff -q "$source_file" "$link_file" > /dev/null 2>&1; then
      echo "$DRIFT_SYNCED"
    else
      echo "$DRIFT_EXTERNAL"
    fi
    return
  fi
  
  # Read symlink target
  local actual_target=$(readlink "$link_file")
  
  # Check if pointing to our repo
  if [[ "$actual_target" != *"$KS_PROJECT_DIR"* ]]; then
    echo "$DRIFT_EXTERNAL"
    return
  fi
  
  # Compare file content
  if ! diff -q "$source_file" "$link_file" > /dev/null 2>&1; then
    echo "$DRIFT_MODIFIED"
    return
  fi
  
  echo "$DRIFT_SYNCED"
}

# Show diff preview between source and target
function show_diff_preview() {
  local source="$1"
  local target="$2"
  local max_lines="${3:-5}"
  
  if [ -f "$source" ] && [ -f "$target" ]; then
    echo "  Diff preview (first $max_lines lines):"
    diff -u "$source" "$target" 2>/dev/null | head -n "$max_lines" | sed 's/^/    /'
  elif [ -d "$source" ] && [ -d "$target" ]; then
    echo "  Directory comparison:"
    echo "    Source files: $(find "$source" -type f 2>/dev/null | wc -l)"
    echo "    Target files: $(find "$target" -type f 2>/dev/null | wc -l)"
  fi
}

# Count total drifted files
function count_drift() {
  local count=0
  
  while IFS='|' read -r source target; do
    local status=$(check_file_drift "$source" "$target")
    if [ "$status" = "$DRIFT_MODIFIED" ] || [ "$status" = "$DRIFT_MISSING_LINK" ]; then
      ((count++))
    fi
  done < <(get_config_mappings)
  
  echo $count
}

# Get drifted configs as array
function detect_drift_array() {
  local -n arr=$1
  
  while IFS='|' read -r source target; do
    local status=$(check_file_drift "$source" "$target")
    if [ "$status" = "$DRIFT_MODIFIED" ]; then
      arr+=("$target")
    fi
  done < <(get_config_mappings)
}

# Get all configuration mappings
function get_config_mappings() {
  # Format: source_path|target_path
  
  if [ -f "$KS_PROJECT_DIR/modules/vim/.vimrc" ]; then
    echo "$KS_PROJECT_DIR/modules/vim/.vimrc|$HOME/.vimrc"
  fi
  
  if [ -d "$KS_PROJECT_DIR/modules/vim/.vim" ]; then
    echo "$KS_PROJECT_DIR/modules/vim/.vim|$HOME/.vim"
  fi
  
  if [ -f "$KS_PROJECT_DIR/modules/git/.gitmessage.txt" ]; then
    echo "$KS_PROJECT_DIR/modules/git/.gitmessage.txt|$HOME/.gitmessage.txt"
  fi
  
  if [ -f "$KS_PROJECT_DIR/modules/tmux/.tmux.conf" ]; then
    echo "$KS_PROJECT_DIR/modules/tmux/.tmux.conf|$HOME/.tmux.conf"
  fi
  
  if [ -f "$KS_PROJECT_DIR/modules/npm/.npmrc" ]; then
    echo "$KS_PROJECT_DIR/modules/npm/.npmrc|$HOME/.npmrc"
  fi
}

# Detect all drift and print report
function detect_all_drift() {
  local verbose=false
  local fix=false
  
  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --verbose) verbose=true ;;
      --fix) fix=true ;;
    esac
  done
  
  print_info "Detecting configuration drift..."
  echo ""
  
  local drift_count=0
  local missing_count=0
  local external_count=0
  local not_installed=0
  
  while IFS='|' read -r source target; do
    local name=$(basename "$target")
    local status=$(check_file_drift "$source" "$target")
    
    case "$status" in
      "$DRIFT_MODIFIED")
        print_warn "$name has local modifications"
        if [ "$verbose" = true ]; then
          show_diff_preview "$source" "$target"
        fi
        if [ "$fix" = true ]; then
          restore_config "$source" "$target"
        fi
        ((drift_count++))
        ;;
      "$DRIFT_MISSING_LINK")
        print_warn "$name link is broken or missing"
        ((missing_count++))
        ;;
      "$DRIFT_EXTERNAL")
        if [ "$verbose" = true ]; then
          print_info "$name is managed externally"
        fi
        ((external_count++))
        ;;
      "$DRIFT_NOT_INSTALLED")
        if [ "$verbose" = true ]; then
          print_info "$name is not installed"
        fi
        ((not_installed++))
        ;;
      "$DRIFT_SYNCED")
        if [ "$verbose" = true ]; then
          print_success "$name is synced"
        fi
        ;;
    esac
  done < <(get_config_mappings)
  
  echo ""
  print_info "Drift Summary:"
  echo "  Modified: $drift_count"
  echo "  Missing/Broken: $missing_count"
  echo "  External: $external_count"
  echo "  Not Installed: $not_installed"
  
  if [ $drift_count -gt 0 ] && [ "$fix" = false ]; then
    echo ""
    print_info "Run with --fix to restore repository versions"
  fi
  
  return $drift_count
}

# Restore config from source (overwrite local changes)
function restore_config() {
  local source="$1"
  local target="$2"
  
  print_info "Restoring $target from repository..."
  
  # Backup current version
  if [ -e "$target" ]; then
    local backup_name="${target}-drift-backup-$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup_name"
    print_info "Backed up to $backup_name"
  fi
  
  # Create new symlink
  ln -s "$source" "$target"
  print_success "Restored $target"
}

# Main execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  # Script is being run directly
  if [ -z "$KS_PROJECT_DIR" ]; then
    echo "[ERROR] KS_PROJECT_DIR is not set. Please run through main.sh"
    exit 1
  fi
  
  source "$KS_PROJECT_DIR/lib/bin/log.sh"
  detect_all_drift "$@"
fi
