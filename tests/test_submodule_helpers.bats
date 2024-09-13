#!/usr/bin/env bats

# Add this line at the beginning of your test file
bats_require_minimum_version 1.5.0

# setup() will be called automatically by BATS before each @test block is executed

setup() {
    bats_require_minimum_version 1.5.0
    # Create a temporary directory
    export TEST_TEMP_DIR=$(mktemp -d)

    # Define the submodules array
    submodules=("sub1" "sub2" "sub3")

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
        popd
    done

    # Add submodules to the main repository
    for submodule in "${submodules[@]}"; do
        git-test submodule add "$TEST_TEMP_DIR/$submodule" "$submodule"
    done
    
    # Create a file to commit
    touch dummy.txt
    git-test add dummy.txt

    # Now commit
    git-test commit -m "Add submodules"
    
    # Source the script to be tested
    source "${BATS_TEST_DIRNAME}/../private/submodule_helpers.sh"
}

teardown() {
    # Clean up temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

@test "private/submodule_helpers.sh: Test list_submodules function" {
    # Change to the main repo directory
    cd "$TEST_TEMP_DIR/main-repo"
    
    run -0 list_submodules
    [ "${lines[0]}" = "sub1" ]
    [ "${lines[1]}" = "sub2" ]
    [ "${lines[2]}" = "sub3" ]
    [ "${#lines[@]}" -eq 3 ]
}

@test "private/submodule_helpers.sh: Test is_valid_submodule function" {
    # Change to the main repo directory
    cd "$TEST_TEMP_DIR/main-repo"
    
    # Test with valid submodules
    for submodule in "${submodules[@]}"; do
        list_submodules | grep -q "^${submodule}$";

        run is_valid_submodule "$submodule"    
        [ "$status" -eq 0 ]
    done

    # Test with an invalid submodule
    run is_valid_submodule "non_existent_submodule"
    [ "$status" -eq 1 ]

    # Test with an empty string
    run is_valid_submodule ""
    [ "$status" -eq 1 ]
}
