# Source the helper functions
# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source the helper functions using a relative path
source "${SCRIPT_DIR}/submodule_helpers.sh"

# Main logic for changing submodule branch
_change_tracking_branch() {
    local submodule_path=$1
    local branch=$2

    # Check if submodule exists in .gitmodules
    if ! grep -q "^\[submodule \"$submodule_path\"\]" .gitmodules; then
        echo "Error: Submodule with path '$submodule_path' not found in .gitmodules."
        exit 1
    fi

    # Extract the submodule name from the path
    local submodule_name=$(basename "$submodule_path")

    echo "Updating submodule '$submodule_name' to track branch '$branch'..."

    # Update the branch in the .gitmodules file
    git config --file .gitmodules submodule.$submodule_name.branch $branch

    list_submodules_tracking_branch
}
