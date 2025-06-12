#!/usr/bin/env bash
set -euo pipefail

source_libs() {
	local lib_dir="$1"

	if [[ ! -d "$lib_dir" ]]; then
		echo "Library directory not found: $lib_dir"
		return 1
	fi

	shopt -s nullglob
	for lib in "$lib_dir"/*.sh; do
		if [[ -f "$lib" && -r "$lib" ]]; then
			echo "Sourcing $lib"
			source "$lib"
		else
			echo "Cannot read $lib"
			return 1
		fi
	done
	shopt -u nullglob
}
