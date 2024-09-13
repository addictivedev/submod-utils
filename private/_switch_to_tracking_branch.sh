# Function to update submodule and ensure it checks out the branch, avoiding detached HEAD
_switch_to_tracking_branch() {
    local submodule_name=$1
    local branch=$2
    local submodule_path=$3

    cd $submodule_path

    # Check if the branch exists locally or remotely
    if git rev-parse --verify --quiet refs/heads/$branch; then
        echo "Switching to branch '$branch' in submodule $submodule_name"
        git checkout $branch
    elif git rev-parse --verify --quiet origin/$branch; then
        echo "Switching to branch origin/$branch in submodule $submodule_name"
        git checkout -b $branch origin/$branch
    else
        echo "Branch '$branch' does not exist in submodule $submodule_name"
    fi
}
