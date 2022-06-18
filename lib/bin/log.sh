function print_info() {
  if [ "$1" ]; then
    echo "[INFO] $*"
  else
    echo ""
  fi
}

function print_warn() {
  echo "[WARN] $*"
}

function print_err() {
  echo "[ERROR] $*"
}

function print_success() {
  echo "[SUCCESS] $*"
}
