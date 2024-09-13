#!/usr/bin/env bats

setup() {
    # Source the helpers
    source "${BATS_TEST_DIRNAME}/../private/submodule_helpers.sh"

    bats_require_minimum_version 1.5.0
    # Create a temporary directory
    export TEST_TEMP_DIR=$(mktemp -d)

    # Define git-test as a function
    git-test() {
        git -c protocol.file.allow=always "$@"
    }
    export -f git-test

    # Set up main repo
    git-test init "$TEST_TEMP_DIR/main-repo" >/dev/null 2>&1
    cd "$TEST_TEMP_DIR/main-repo"
    
    # Initialize and set up submodule1
    git-test init "$TEST_TEMP_DIR/submodule1" >/dev/null 2>&1
    pushd "$TEST_TEMP_DIR/submodule1"
    touch README.md
    git-test add README.md >/dev/null 2>&1
    git-test commit -m "Initial commit for submodule1" >/dev/null 2>&1
    git-test branch feature-branch >/dev/null 2>&1
    popd

    # Initialize and set up submodule2
    git-test init "$TEST_TEMP_DIR/submodule2" >/dev/null 2>&1
    pushd "$TEST_TEMP_DIR/submodule2"
    touch README.md
    git-test add README.md >/dev/null 2>&1
    git-test commit -m "Initial commit for submodule2" >/dev/null 2>&1
    git-test branch feature-branch >/dev/null 2>&1
    popd

    # Add submodules to the main repository
    git-test submodule add -b main "$TEST_TEMP_DIR/submodule1" "submodule1" >/dev/null 2>&1
    git-test submodule add -b main "$TEST_TEMP_DIR/submodule2" "submodule2" >/dev/null 2>&1
    git-test commit -m "Add submodules" >/dev/null 2>&1
}

teardown() {
    # Clean up temporary directory
    #rm -rf "$TEST_TEMP_DIR"
    echo "TEST_TEMP_DIR: $TEST_TEMP_DIR"
}

@test "switch_to_tracking_branch: Test switching to tracking branch" {
    # Initial state after setup:
    # - Main repo initialized with two submodules
    # - Submodules added and committed
    # - Submodules still on 'main', not yet on their feature branches

    # Change to the temporary directory
    cd "$TEST_TEMP_DIR"
    # Simulate cloning the repo with submodules
    git-test clone "$TEST_TEMP_DIR/main-repo" "$TEST_TEMP_DIR/cloned-repo" >/dev/null 2>&1
    cd "$TEST_TEMP_DIR/cloned-repo"
    # Initialize submodules in the cloned repo
    git-test submodule update --init --recursive >/dev/null 2>&1

    # Verify that submodules are in detached HEAD state initially
    pushd submodule1
    run is_detached_head
    [ "$status" -eq 0 ]
    popd

    pushd submodule2
    run is_detached_head
    [ "$status" -eq 0 ]
    popd
    # Run the switch_to_tracking_branch script
    run "${BATS_TEST_DIRNAME}/../switch_to_tracking_branch.sh"
    # Check that the script ran successfully
    [ "$status" -eq 0 ]

    # Verify that the first submodule is on the correct branch
    pushd submodule1
    run git-test rev-parse --abbrev-ref HEAD >/dev/null 2>&1
    [ "$output" = "main" ]
    popd

    # Verify that the first submodule is not in detached HEAD state
    pushd submodule1
    run git-test symbolic-ref -q HEAD >/dev/null 2>&1
    [ "$status" -eq 0 ]
    popd

    # Optionally, you can add similar checks for submodule2
    # For example:
    # run "${BATS_TEST_DIRNAME}/../change_tracking_branch.sh" submodule2 another-feature
    # [ "$status" -eq 0 ]
    # pushd submodule2
    # run git-test rev-parse --abbrev-ref HEAD
    # [ "$output" = "another-feature" ]
    # popd
}
