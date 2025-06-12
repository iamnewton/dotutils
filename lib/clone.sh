clone () {
	local install_dir="$1"
	local repo="$2"
	local username="${USERNAME:-iamnewton}"
	local github_url="${GITHUB_URL:-github.com}"
	local branch="${BRANCH:-main}"

	# Defensive checks
	if [[ -z "$username" || -z "$repo" || -z "$install_dir" ]]; then
		dotlog::error "Missing required parameters: repo and install_dir must be set"
		return 1
	fi

	if ! command -v git &>/dev/null; then
		dotlog::error "Git is not installed or not in PATH"
		return 1
	fi

	if [[ -d "$install_dir/.git" ]]; then
		dotlog::info "Git repository already initialized in $install_dir"
		return 0
	fi

	dotlog::process "Changing directory to $install_dir"
	pushd "$install_dir" > /dev/null || {
		dotlog::error "Failed to cd into $install_dir"
		return 1
	}

	dotlog::process "Initializing git repository"
	git init --quiet || return 1
	git branch -m "$branch" || return 1

	local repo_url="https://$github_url/$username/$repo.git"
	dotlog::process "Adding $repo_url as an origin"
	git remote add origin "$repo_url" || return 1

	dotlog::process "Fetching from origin"
	git fetch --quiet --depth=1 origin "$branch" || return 1

	dotlog::process "Resetting to origin/$branch"
	git reset --hard FETCH_HEAD || return 1

	dotlog::process "Cleaning untracked files"
	git clean -fd || return 1

	dotlog::success "Repository initialized and cleaned"

	dotlog::process "Pulling latest changes with rebase"
	git pull --rebase origin "$branch" || {
		dotlog::error "Failed to pull latest changes"
		return 1
	}

	dotlog::success "Repository successfully updated"
	popd > /dev/null
}
