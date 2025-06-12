install_homebrew () {
  if command -v brew &>/dev/null; then
    dotlog::info "Homebrew is already installed"
    return 0
  fi

  dotlog::process "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    dotlog::error "Homebrew installation failed"
    return 1
  }

  local os="${OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
  if [[ "$os" == "linux" ]]; then
    dotlog::process "Installing build-essential on Linux"
    sudo apt-get update && sudo apt-get install -y build-essential
  fi

  dotlog::success "Homebrew installed successfully"
}

source_homebrew () {
  if command -v brew &>/dev/null; then
    return 0
  fi

  local brew_paths=(
    "/opt/homebrew/bin/brew"               # macOS Apple Silicon
    "/usr/local/bin/brew"                  # macOS Intel
    "/home/linuxbrew/.linuxbrew/bin/brew" # Linux
  )

  for path in "${brew_paths[@]}"; do
    if [[ -x "$path" ]]; then
      eval "$("$path" shellenv)"
      return 0
    fi
  done

  dotlog::error "Homebrew not found in known locations"
  return 1
}
