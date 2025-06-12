#!/usr/bin/env bash
set -euo pipefail

main() {
  # constants
  local repo_name="dotutils"
  local install_dir="$HOME/.local/lib/$repo_name"
  local tarball="/tmp/${repo_name}.tar.gz"

  # Step 1: Download the repo_name into install_dir
  if [[ ! -d "$install_dir" ]]; then
    mkdir -p "$install_dir"
    curl -#fLo "$tarball" "https://github.com/iamnewton/$repo_name/tarball/main"
    tar -zxf "$tarball" --strip-components 1 -C "$install_dir"
    rm -f "$tarball"
  fi
  
  # source source_libs function first
  source "$install_dir/lib/source.sh"
  
  # use it to source the rest of the libs
  source_libs "$install_dir/lib" || {
    dotlog::error "Failed to source library scripts"
    exit 1
  }
  
  # run main install functions
  download "$install_dir" "$repo_name" || {
    dotlog::error "Download failed"
    exit 1
  }
  
  clone "$install_dir" "$repo_name" || {
    dotlog::error "Git clone/init failed"
    exit 1
  }

  if [[ -d "$install_dir/.git" ]]; then
    version="$(git -C "$install_dir" rev-parse --short HEAD 2>/dev/null || echo "unknown")"
    dotlog::success "$repo_name version $version successfully installed"
  else
    dotlog::error "Something went wrong"
    exit 1
  fi
}

main "$@"
