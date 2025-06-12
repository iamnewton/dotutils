#!/usr/bin/env bash
set -euo pipefail

# constants
readonly USERNAME="iamnewton"
readonly REPO="dotutils"
readonly INSTALL_DIR="$HOME/.local/lib/$REPO"

# resolve script directory so it works no matter where it's run from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# source source_libs function first
source "$LIB_DIR/source.sh"

# use it to source the rest of the libs
source_libs "$LIB_DIR" || {
  echo "Failed to source library scripts" >&2
  exit 1
}

# run main install functions
download "$INSTALL_DIR" || {
  dotlog::error "Download failed"
  exit 1
}

clone "$INSTALL_DIR" || {
  dotlog::error "Git clone/init failed"
  exit 1
}

dotlog::success "$REPO successfully installed"

