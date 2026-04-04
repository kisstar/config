#!/bin/bash

# Health check script for configuration management
# Checks repository integrity, symlinks, dependencies, and more

declare -i CHECKS_PASSED=0
declare -i CHECKS_FAILED=0
declare -i CHECKS_WARNING=0

# Tool versions to check
readonly REQUIRED_TOOLS=("git" "curl")
readonly OPTIONAL_TOOLS=("vim" "tmux" "wget")

# Run all health checks
function run_health_checks() {
  local fix_mode=false

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --fix) fix_mode=true ;;
    esac
  done

  print_info "Running configuration health checks..."
  echo ""

  # Repository checks
  check_repository_integrity
  check_git_status

  # File system checks
  check_symlink_health "$fix_mode"
  check_permissions

  # Tool checks
  check_tool_dependencies

  # Config checks
  check_drift_status
  check_install_record

  # Print summary
  echo ""
  print_info "Health Check Summary:"
  echo "  ✓ Passed: $CHECKS_PASSED"
  echo "  ⚠ Warning: $CHECKS_WARNING"
  echo "  ✗ Failed: $CHECKS_FAILED"

  if [ $CHECKS_FAILED -eq 0 ] && [ $CHECKS_WARNING -eq 0 ]; then
    echo ""
    print_success "All checks passed! Your configuration is healthy."
  elif [ $CHECKS_FAILED -eq 0 ]; then
    echo ""
    print_warn "Some warnings found, but nothing critical."
  else
    echo ""
    print_err "Some checks failed. Please review the issues above."
  fi

  return $CHECKS_FAILED
}

# Check 1: Repository integrity
function check_repository_integrity() {
  echo -n "Checking repository integrity... "

  if [ ! -d "$KS_PROJECT_DIR" ]; then
    echo "✗"
    print_err "  Configuration directory not found: $KS_PROJECT_DIR"
    ((CHECKS_FAILED++))
    return
  fi

  if [ ! -d "$KS_PROJECT_DIR/.git" ]; then
    echo "✗"
    print_err "  Not a git repository"
    ((CHECKS_FAILED++))
    return
  fi

  if [ ! -f "$KS_PROJECT_DIR/lib/bin/main.sh" ]; then
    echo "✗"
    print_err "  Core scripts missing"
    ((CHECKS_FAILED++))
    return
  fi

  echo "✓"
  ((CHECKS_PASSED++))
}

# Check 2: Symlink health
function check_symlink_health() {
  local fix_mode="${1:-false}"

  echo -n "Checking symlink health... "

  local broken_links=()
  local managed_links=0

  # Find all symlinks in home directory
  while IFS= read -r link; do
    if [ -L "$link" ]; then
      local target=$(readlink "$link")
      # Check if it's managed by us
      if [[ "$target" == *"$KS_PROJECT_DIR"* ]]; then
        ((managed_links++))
        # Check if target exists
        if [ ! -e "$link" ]; then
          broken_links+=("$link")
        fi
      fi
    fi
  done < <(find ~ -maxdepth 1 -type l 2>/dev/null)

  if [ ${#broken_links[@]} -eq 0 ]; then
    echo "✓ ($managed_links managed links)"
    ((CHECKS_PASSED++))
  else
    echo "⚠ (${#broken_links[@]} broken, $managed_links total)"
    for link in "${broken_links[@]}"; do
      print_warn "  Broken link: $link"
      if [ "$fix_mode" = true ]; then
        rm -f "$link"
        print_success "  Removed broken link: $link"
      fi
    done
    ((CHECKS_WARNING++))
  fi
}

# Check 3: Tool dependencies
function check_tool_dependencies() {
  echo "Checking tool dependencies..."

  # Required tools
  for tool in "${REQUIRED_TOOLS[@]}"; do
    echo -n "  $tool (required)... "
    if command -v "$tool" > /dev/null 2>u00261; then
      local version=$($tool --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
      echo "✓${version:+ ($version)}"
      ((CHECKS_PASSED++))
    else
      echo "✗ (not installed)"
      print_err "    $tool is required for configuration management"
      ((CHECKS_FAILED++))
    fi
  done

  # Optional tools
  for tool in "${OPTIONAL_TOOLS[@]}"; do
    echo -n "  $tool (optional)... "
    if command -v "$tool" > /dev/null 2>u00261; then
      local version=$($tool --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
      echo "✓${version:+ ($version)}"
      ((CHECKS_PASSED++))
    else
      echo "⚠ (not installed)"
      ((CHECKS_WARNING++))
    fi
  done
}

# Check 4: Permissions
function check_permissions() {
  echo -n "Checking directory permissions... "

  if [ ! -w "$KS_PROJECT_DIR" ]; then
    echo "✗"
    print_err "  No write permission to $KS_PROJECT_DIR"
    ((CHECKS_FAILED++))
    return
  fi

  if [ ! -w "$HOME" ]; then
    echo "✗"
    print_err "  No write permission to home directory"
    ((CHECKS_FAILED++))
    return
  fi

  echo "✓"
  ((CHECKS_PASSED++))
}

# Check 5: Git status
function check_git_status() {
  echo -n "Checking git status... "

  if [ ! -d "$KS_PROJECT_DIR/.git" ]; then
    echo "⚠ (not a git repo)"
    ((CHECKS_WARNING++))
    return
  fi

  cd "$KS_PROJECT_DIR"

  local uncommitted=$(git status --porcelain 2>/dev/null)
  local unpushed=$(git log --branches --not --remotes --oneline 2>/dev/null | wc -l)

  if [ -n "$uncommitted" ]; then
    echo "⚠ (uncommitted changes)"
    print_warn "  You have uncommitted changes in the repository"
    ((CHECKS_WARNING++))
  elif [ "$unpushed" -gt 0 ]; then
    echo "⚠ ($unpushed unpushed commits)"
    print_warn "  You have unpushed commits"
    ((CHECKS_WARNING++))
  else
    local branch=$(git branch --show-current 2>/dev/null)
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    echo "✓${branch:+ (on $branch)}"
    ((CHECKS_PASSED++))
  fi
}

# Check 6: Drift status
function check_drift_status() {
  echo -n "Checking configuration drift... "

  if [ ! -f "$KS_PROJECT_DIR/lib/bin/drift.sh" ]; then
    echo "⚠ (drift.sh not found)"
    ((CHECKS_WARNING++))
    return
  fi

  source "$KS_PROJECT_DIR/lib/bin/drift.sh"

  local drift_count=0
  while IFS='|' read -r source target; do
    local status=$(check_file_drift "$source" "$target")
    if [ "$status" = "$DRIFT_MODIFIED" ]; then
      ((drift_count++))
    fi
  done < <(get_config_mappings)

  if [ "$drift_count" -eq 0 ]; then
    echo "✓"
    ((CHECKS_PASSED++))
  else
    echo "⚠ ($drift_count files modified)"
    print_warn "  Run drift.sh to see details"
    ((CHECKS_WARNING++))
  fi
}

# Check 7: Installation record
function check_install_record() {
  echo -n "Checking installation record... "

  if [ ! -f "$INSTALLED_MODULES_FILE" ]; then
    echo "⚠ (no record found)"
    print_warn "  Installation record not found. Some features may not work correctly."
    ((CHECKS_WARNING++))
    return
  fi

  local installed_count=$(wc -l < "$INSTALLED_MODULES_FILE" 2>/dev/null | tr -d ' ')

  if [ "$installed_count" -eq 0 ]; then
    echo "⚠ (empty record)"
    ((CHECKS_WARNING++))
  else
    echo "✓ ($installed_count modules recorded)"
    ((CHECKS_PASSED++))
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
  run_health_checks "$@"
fi
