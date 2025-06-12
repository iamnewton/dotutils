#!/usr/bin/env bash
set -euo pipefail

source_libs() {
	local lib_dir="$1"

	if [[ ! -d "$lib_dir" ]]; then
		dotlog::error "Library directory not found: $lib_dir"
		return 1
	fi

	shopt -s nullglob
	for lib in "$lib_dir"/*.sh; do
		if [[ -f "$lib" && -r "$lib" ]]; then
			dotlog::process "Sourcing $lib"
			source "$lib"
		else
			dotlog::error "Cannot read $lib"
			return 1
		fi
	done
	shopt -u nullglob
}
