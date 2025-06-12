download () {
  local install_dir="$1"
  local github_url="${2:-github.com}"

  local tarball="/tmp/${REPO}.tar.gz"
  local symlink_target="$HOME/.local/bin/$REPO"
  local source_bin="$install_dir/bin/$REPO"

  # Defensive: Validate critical inputs
  if [[ -z "$USERNAME" || -z "$REPO" || -z "$install_dir" ]]; then
    dotlog::error "Missing USERNAME, REPO, or install_dir"
    return 1
  fi

  if [[ ! -d "$install_dir" ]]; then
    dotlog::process "Creating directory at $install_dir"
    if ! mkdir -p "$install_dir"; then
      dotlog::error "Failed to create directory: $install_dir"
      return 1
    fi

    dotlog::process "Downloading $REPO repository tarball"
    if ! curl -#fLo "$tarball" "https://$github_url/$USERNAME/$REPO/tarball/main"; then
      dotlog::error "Failed to download repository from GitHub"
      return 1
    fi

    dotlog::process "Extracting files to $install_dir"
    if ! tar -zxf "$tarball" --strip-components 1 -C "$install_dir"; then
      dotlog::error "Failed to extract tarball"
      rm -f "$tarball"
      return 1
    fi

    dotlog::process "Cleaning up tarball"
    rm -f "$tarball"

    # Validate the expected bin file exists before symlinking
    if [[ ! -x "$source_bin" ]]; then
      dotlog::error "Expected executable not found at $source_bin"
      return 1
    fi

    dotlog::process "Ensuring ~/.local/bin exists"
    mkdir -p "$HOME/.local/bin"

    dotlog::process "Creating symlink: $symlink_target → $source_bin"
    if [[ -e "$symlink_target" && ! -L "$symlink_target" ]]; then
      dotlog::error "File exists at $symlink_target and is not a symlink. Aborting."
      return 1
    fi

    ln -sfn "$source_bin" "$symlink_target"
    dotlog::success "$install_dir setup complete and $REPO linked to ~/.local/bin"
  else
    dotlog::info "$install_dir already exists, skipping download"
  fi
}

