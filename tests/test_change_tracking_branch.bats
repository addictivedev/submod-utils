#!/usr/bin/env bats

# Add this line at the beginning of your test file
bats_require_minimum_version 1.5.0

# setup() will be called automatically by BATS before each @test block is executed
setup() {
    bats_require_minimum_version 1.5.0
    # Create a temporary directory
    export TEST_TEMP_DIR=$(mktemp -d)

    # Define the submodules array
    submodules=("sub1" "sub2")

    # Define git-test as a function instead of an alias  issue is that aliases defined in scripts are not automatically available in subshells or commands run by git init
    #the `-c protocol.file.allow=always` param is required only because we are working locally using the file protocol. 
    git-test() {
        git -c protocol.file.allow=always "$@"
    }
    export -f git-test

    # Set up main repo
    git-test init "$TEST_TEMP_DIR/main-repo"
    cd "$TEST_TEMP_DIR/main-repo"
    
    # Initialize submodule repositories
    for submodule in "${submodules[@]}"; do
        git-test init "$TEST_TEMP_DIR/$submodule"
        # Add an initial commit to the submodule
        pushd "$TEST_TEMP_DIR/$submodule"
        touch README.md
        git-test add README.md
        git-test commit -m "Initial commit"
        # Create a new branch in each submodule
        git-test switch -c feature/my-feature
        git-test switch main
        popd
    done

    # Add submodules to the main repository
    for submodule in "${submodules[@]}"; do
        git-test submodule add -b main "$TEST_TEMP_DIR/$submodule" "$submodule"
    done

    # Now commit
    git-test commit -m "Add submodules"
    
    # Source the script to be tested
    source "${BATS_TEST_DIRNAME}/../private/submodule_helpers.sh"
}

teardown() {
    # Clean up temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

@test "_change_tracking_branch.sh: Test changing tracking branch" {
    # Change to the main repo directory
    cd "$TEST_TEMP_DIR/main-repo"

    # Source the script to be tested
    source "${BATS_TEST_DIRNAME}/../private/_change_tracking_branch.sh"
    
    # Test changing the tracking branch for a submodule
    local submodule="sub1"
    local new_branch="feature/my-feature"
    
    # Run the _change_tracking_branch function
    run _change_tracking_branch "$submodule" "$new_branch"
    [ "$status" -eq 0 ]
    
    # Verify the branch has been updated in .gitmodules
    run git config --file .gitmodules --get submodule.$submodule.branch
    [ "$output" = "$new_branch" ]
    
    # # Verify a commit was created
    # run git log -1 --pretty=%s
    # [ "$output" = "Updated submodule '$submodule' to track branch '$new_branch'" ]
    
    # # Verify the submodule is on the correct branch
    # pushd "$submodule"
    # run git rev-parse --abbrev-ref HEAD
    # [ "$output" = "$new_branch" ]
    # popd
}

