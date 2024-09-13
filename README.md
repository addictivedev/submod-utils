# Development

## Overview of Test Organization

Our tests are organized using the Bats (Bash Automated Testing System) framework. Here's a brief overview:

1. Location: All test files are located in the `tests/` directory.

2. Naming Convention: Test files follow the naming pattern `test_*.bats`.

3. Helper File: Common helper functions are defined in `tests/test_helper.bash`.

4. Structure: Each `.bats` file contains multiple test cases defined using the `@test` annotation.

5. Execution: Tests can be run individually or as a complete suite using the `bats` command.

This organization allows for modular and maintainable testing of our bash scripts and functions.

## Install bats framework (ubuntu, osx)

```bash
sudo apt-get install bats
```

or

```bash
brew install bats
```

## Run tests

```bash
bats test
```

## Run tests 

test suite:

```bash
bats tests/*.bats
```

or individual test:

```bash
bats tests/test_change_tracking_branch.bats
```

## GitHub Actions

We've added a GitHub Action to automatically run our tests on every push and pull request. Here's how it works:

1. The action is defined in `.github/workflows/run-tests.yml`
2. It runs on Ubuntu latest
3. It installs bats and runs all tests in the `tests/` directory
