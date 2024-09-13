#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    # Create a temporary directory
    export TEST_TEMP_DIR=$(mktemp -d)

    # Define git-test as a function
    git-test() {
        git -c protocol.file.allow=always "$@"
    }
    export -f git-test

    # Set up main repo
    git-test init "$TEST_TEMP_DIR/main-repo"
    cd "$TEST_TEMP_DIR/main-repo"
    
    # Initialize and set up a submodule
    git-test init "$TEST_TEMP_DIR/submodule"
    pushd "$TEST_TEMP_DIR/submodule"
    touch README.md
    git-test add README.md
    git-test commit -m "Initial commit"
    git-test branch feature-branch
    popd

    # Add submodule to the main repository
    git-test submodule add "$TEST_TEMP_DIR/submodule" "submodule"
    git-test commit -m "Add submodule"
    
    # Source the script to be tested
    #source "${BATS_TEST_DIRNAME}/../switch_to_tracking_branch.sh"
}

teardown() {
    # Clean up temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

@test "switch_to_tracking_branch: Test switching to tracking branch" {
    # Change to the main repo directory
    cd "$TEST_TEMP_DIR/main-repo"

    # After setup:
    # - Main repo initialized with one submodule
    # - Submodule added and committed
    # - Submodule still on 'main', not yet on 'feature-branch'


    # Set the branch for the submodule in .gitmodules
    run "${BATS_TEST_DIRNAME}/../change_tracking_branch.sh" submodule feature-branch
    # Check that the script ran successfully
    [ "$status" -eq 0 ]

    # Run the switch_to_tracking_branch script
    run "${BATS_TEST_DIRNAME}/../switch_to_tracking_branch.sh"
    # Check that the script ran successfully
    [ "$status" -eq 0 ]

    # Verify that the submodule is on the correct branch
    pushd submodule
    run git-test rev-parse --abbrev-ref HEAD
    [ "$output" = "feature-branch" ]
    popd

    # # Verify that the submodule is not in detached HEAD state
    # pushd submodule
    # run git-test symbolic-ref -q HEAD
    # [ "$status" -eq 0 ]
    # popd
}
