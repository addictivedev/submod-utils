#!/bin/bash

# Exit immediately if a command exits with a non-zero status, 
# treat unset variables as an error, and fail on any command in a pipeline
set -euo pipefail

# Function to list available submodules from the .gitmodules file
list_submodules() {
    local submodules_output
    # Save the output of git submodule foreach into the variable
    submodules_output=$(git submodule --quiet foreach 'echo $path || true' 2>/dev/null)
    # Echo the content of the variable
    echo "$submodules_output"
}

# Function to check if the current branch is in detached HEAD state
# Returns 0 if in detached HEAD state, 1 otherwise
# Usage:
# if is_detached_head; then
#     echo "The repository is in detached HEAD state"
# else
#     echo "The repository is not in detached HEAD state"
# fi
is_detached_head() {
    if git symbolic-ref -q HEAD >/dev/null 2>&1; then
        return 1  # Not in detached HEAD state
    else
        return 0  # In detached HEAD state
    fi
}



# Function to list available submodules from the .gitmodules file
list_submodules_tracking_branch() {
    local submodules_output
    # Save the output of git submodule foreach into the variable
    submodules_output=$(git submodule --quiet foreach '
        submodule_name=$(basename "$path")
        tracking_branch=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch)
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        printf "%-20s %-20s %-20s\n" "$submodule_name" "$tracking_branch" "$current_branch"
    ' 2>/dev/null)
    
    # Print the header
    printf "%-20s %-20s %-20s\n" "Submodule Name" "Tracking Branch" "Current Branch"
    printf "%s\n" "$(printf '%.0s-' {1..60})"
    
    # Echo the content of the variable
    echo "$submodules_output"
}

# Function to check if a given path is an existing submodule
is_valid_submodule() {
    local submodule_path="$1"
    list_submodules | grep -Fxq "${submodule_path}"
}
