#!/bin/bash -e

execute_shunit2_test() {
    local _test_file=$1
    logger_info "$OS - $_test_file"
    bash "$_test_file"
    return $?
}

fatal_error() {
    local _msg="$1"
    logger_info "FATAL: $_msg"
    exit 255
}

logger_info() {
    local _msg="$1"
    echo "$_msg"
}

# export TERM is required before running shunit2, otherwise running this script on Ubuntu
# will throw the following warning
#
# tput: No value for $TERM and no -T specified
# /tests/sh/shunit2: line 843: [: : integer expression expected
#
# Ref: https://askubuntu.com/a/596990
export TERM=xterm

# By default, we want to run all tests including the ones that try to download
# However, it might be necessary to disable the slow tests. To disable
# set RUN_SLOW_TESTS to an empty string e.g. RUN_SLOW_TESTS=""
export RUN_SLOW_TESTS=1

# TODO: move to its own function
OS="$(grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}')"
[[ -z "$OS" ]] && OS=Alpine

# ETHOS-14311
# Expose this variable to all the shunit2 tests so that we can skip tests
# that are OS specific
export OS

# https://jira.corp.adobe.com/browse/ETHOS-27127
# Add the ability to run a single test. Default behavior is run all tests
RUN_MODE=all
RUN_DIR=tests/sh

if [[ -n "${RUN_TEST_FILE}" ]] && [[ -f "${RUN_TEST_FILE}" ]]; then
    RUN_MODE=one
fi

# Add the ability to specify a different starting folder
if [[ -n "${RUN_TEST_DIR}" ]] && [[ -d "${RUN_TEST_DIR}" ]]; then
    RUN_DIR=$RUN_TEST_DIR
fi

# Confirm that we are running tests from the tests/sh folder
if [ $RUN_MODE == "one" ]; then
    if [[ $RUN_TEST_FILE != tests/sh* ]]; then
        fatal_error "Invalid RUN_TEST_FILE=$RUN_TEST_FILE. Must begin with tests/sh"
    fi
fi

if [[ $RUN_DIR != tests/sh* ]]; then
    fatal_error "Invalid RUN_TEST_DIR=$RUN_DIR. Must begin with tests/sh"
fi

case "$RUN_MODE" in
    one)
        # Run a specific script, useful when troubleshooting a single script
        logger_info "Running a single test $RUN_TEST_FILE on $OS bbc"
        # bash tests/sh/root/scripts/common/install/test_java-builder.sh
        bash "$RUN_TEST_FILE"
        ;;
    *)
        # Default behavior is to run all shunit2 bash unit tests we can find
        # 1. Navigate to the tests/sh folder
        # 2. Look for files that are named 'test_*.sh'
        # 3. For each file found, print the command that's being executed (-t)
        logger_info "Running all tests in $RUN_DIR on $OS bbc"
        export -f execute_shunit2_test
        files=$(find "$RUN_DIR" -type f -name 'test_*.sh' -print)
        for file in $files
        do
            if ! execute_shunit2_test "$file"
            then
                fatal_error "Errors executing $file"
            fi
        done
        logger_info "Done with all $OS tests"
        ;;
esac
