#!/bin/bash

usage=$(cat << EOF
Script: $(basename "$0")

Description:
This script changes the tracking branch of a specified submodule in a Git repository.
It updates the .gitmodules file with the new branch information and cleans up the .git/config file.

Usage:
$(basename "$0") <submodule_path> <new_branch>

Arguments:
  submodule_path: The path to the submodule within the repository
  new_branch: The name of the new branch to track

Example:
$(basename "$0") lib/mysubmodule feature-branch

Note:
This script should be run from the root of the main repository.
It requires Git to be installed and available in the system PATH.
EOF
)

# Exit immediately if a command exits with a non-zero status, 
# treat unset variables as an error, and fail on any command in a pipeline
set -euo pipefail

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source the helper functions using absolute paths
source "${SCRIPT_DIR}/private/submodule_helpers.sh"

# Main logic for changing submodule branch
source "${SCRIPT_DIR}/private/_change_tracking_branch.sh"

# arguments parsing
if [ $# -eq 2 ]; then
    # Case: Two arguments (submodule name and new branch)
    submodule_path="$1"
    new_branch="$2"
    _change_tracking_branch "$submodule_path" "$new_branch"

elif [ $# -eq 1 ]; then
    # Case: One argument (submodule name, prompt for branch)
    submodule_name="$1"
    read -p "Enter the new branch to track for '$submodule_name': " new_branch
    _change_tracking_branch "$submodule_path" "$new_branch"
elif [ $# -eq 0 ]; then
    # Case: No arguments, prompt for submodule name and branch
    list_submodules
    read -p "Enter the submodule path from the list above: " submodule_path
    read -p "Enter the new branch to track for '$submodule_path': " new_branch
    _change_tracking_branch "$submodule_path" "$new_branch"
else
    # Invalid number of arguments
    echo "$usage"
    exit 1
fi

# Print a summary of what was done
echo "- Changed tracking branch for submodule '$submodule_path' to '$new_branch'"

# Suggest running switch_to_tracking_branch.sh
echo
echo "To effectively switch to the new tracking branch, you can run:"
echo "./switch_to_tracking_branch.sh"
echo "This will update the submodule to the new branch and avoid detached HEAD state."
