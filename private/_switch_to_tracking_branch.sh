# Function to update submodule and ensure it checks out the branch, avoiding detached HEAD
_switch_to_tracking_branch() {
    local submodule_name=$1
    local branch=$2
    local submodule_path=$3

    #echo "[$submodule_name] Switching to branch '$branch'"
    cd $submodule_path

    # Check if the branch exists locally or remotely
    if git rev-parse --verify --quiet refs/heads/$branch >/dev/null 2>&1; then
        git checkout -q $branch >/dev/null 2>&1
        echo "[$submodule_name] Switched to branch '$branch'"
    elif git rev-parse --verify --quiet origin/$branch >/dev/null 2>&1; then
        git checkout -q -b $branch origin/$branch >/dev/null 2>&1
        echo "[$submodule_name] Switched to branch '$branch' (from origin)"
    else
        echo "[$submodule_name] Branch '$branch' does not exist"
    fi
}
