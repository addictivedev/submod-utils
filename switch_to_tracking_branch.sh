#!/bin/bash

# Exit immediately if a command exits with a non-zero status, 
# treat unset variables as an error, and fail on any command in a pipeline
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/private/_switch_to_tracking_branch.sh"

# Get all submodule data (to avoid sourcing the script in the subshell of the foreach loop, which would cause complications)
submodule_data=$(git submodule foreach --recursive --quiet '
    echo "$name|$path|$(git config --file $toplevel/.gitmodules --get submodule.$name.branch)"
')

# Iterate through each submodule
echo "$submodule_data" | while IFS='|' read -r name path branch; do
    # If no branch is specified in .gitmodules, skip it
    if [ -z "$branch" ]; then
        echo "No branch specified in .gitmodules for submodule $name. Skipping."
    else
        # Ensure the submodule is checked out to the correct branch, not in detached HEAD mode
        _switch_to_tracking_branch "$name" "$branch" "$path"
    fi
done
