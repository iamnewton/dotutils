#!/usr/bin/env bash
set -euo pipefail

# constants
readonly REPO="dotutils"
readonly INSTALL_DIR="$HOME/.local/lib/$REPO"
readonly TARBALL="/tmp/${REPO}.tar.gz"

main() {
  # Step 1: Download the repo into INSTALL_DIR
  if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -p "$INSTALL_DIR"
    curl -#fLo "$TARBALL" "https://github.com/iamnewton/$REPO/tarball/main"
    tar -zxf "$TARBALL" --strip-components 1 -C "$INSTALL_DIR"
    rm -f "$TARBALL"
  fi
  
  # source source_libs function first
  source "$INSTALL_DIR/lib/source.sh"
  
  # use it to source the rest of the libs
  source_libs "$INSTALL_DIR" || {
    dotlog::error "Failed to source library scripts"
    exit 1
  }
  
  # run main install functions
  download "$INSTALL_DIR" "$REPO" || {
    dotlog::error "Download failed"
    exit 1
  }
  
  clone "$INSTALL_DIR" "$REPO" || {
    dotlog::error "Git clone/init failed"
    exit 1
  }

  if [[ -d "$INSTALL_DIR/.git" ]]; then
    version="$(git -C "$INSTALL_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")"
  
  else
    dotlog::error "Something went wrong"
    exit 1
  fi
}

main "$@"
