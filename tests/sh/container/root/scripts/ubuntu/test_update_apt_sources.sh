#!/bin/bash

setUp() {
    # Get the path to this test script
    SHUNIT2_TEST_SCRIPT=$0
    # Replace the path tests/sh and strip out the test_ part of the name
    SCRIPT_TO_TEST=$(echo "$SHUNIT2_TEST_SCRIPT" | \
        sed 's|tests/sh/container/root||' | sed 's|test_||')
    # Temp location to store script output for validation purposes
    TEST_OUTPUT=/tmp/$$.out

    # Fake copy of the real apt sources list
    FAKE_APT_SOURCE_LIST=/tmp/foo.list
}

tearDown() {
    # Clean up
    if [[ -f "$TEST_OUTPUT" ]]; then
        rm -f "$TEST_OUTPUT"
    fi
}

create_fake_source_list() {
    # Helper to create a temporary source list for testing purposes
    local _prefix="$1"

    # Create a fake source list for testing purposes
    cat << EOF > "/tmp/${_prefix}.list"
deb http://${_prefix}.ubuntu.com/ubuntu/ focal main restricted

deb http://${_prefix}.ubuntu.com/ubuntu-ports/ focal-updates main restricted

deb http://${_prefix}.ubuntu.com/ubuntu-ports/ focal universe
deb http://${_prefix}.ubuntu.com/ubuntu-ports/ focal-updates universe
EOF
}

test_fail_when_sources_list_does_not_exist() {
    APT_SOURCE_LIST=/tmp/foo \
        bash "$SCRIPT_TO_TEST" 2>&1 | tee -a "$TEST_OUTPUT" > /dev/null
    # cat "$TEST_OUTPUT"

    grep "failure: /tmp/foo does not exist!" "$TEST_OUTPUT" > /dev/null
    assertTrue "Expecting failure message" "[ $? -eq 0 ]"
}

test_non_http_mirror() {
    UBUNTU_ARCHIVE_MIRROR_URL=ftp://foo.bar \
        bash "$SCRIPT_TO_TEST" 2>&1 | tee -a "$TEST_OUTPUT" > /dev/null
    # cat "$TEST_OUTPUT"

    grep "warning: Unsupported mirror url: ftp://foo.bar" "$TEST_OUTPUT" \
        > /dev/null
    assertTrue "Expecting warning message" "[ $? -eq 0 ]"
}

test_update_apt_source_ports() {
    # Make a copy of the original sources.list.
    # Typical contents of this file looks like:
    # root@979e866735eb:/# grep -v '#' /etc/apt/sources.list
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal main restricted
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal universe
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-security universe
    # deb http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse
    cp /etc/apt/sources.list "$FAKE_APT_SOURCE_LIST"

    # Do our search and replace
    APT_SOURCE_LIST="$FAKE_APT_SOURCE_LIST" \
    UBUNTU_PORTS_MIRROR_URL=https://foo/bar/ports-ubuntu-remote \
        bash "$SCRIPT_TO_TEST" 2>&1 | tee -a "$TEST_OUTPUT" > /dev/null

    # Confirm that ports.ubuntu.com no longer exist
    grep "http://ports.ubuntu.com/ubuntu-ports" "$FAKE_APT_SOURCE_LIST" \
        > /dev/null
    assertTrue "Expecting warning message" "[ $? -ne 0 ]"

    # Confirm that we completed our search and replace
    local _total=""
    _total=$(grep -c "$UBUNTU_PORTS_MIRROR_URL" "$FAKE_APT_SOURCE_LIST")
    assertTrue "Expecting ports url to be replaced" "[ $_total -gt 0 ]"
}

test_update_apt_source_archive() {
    create_fake_source_list "archive"

    # Do our search and replace
    APT_SOURCE_LIST="/tmp/archive.list" \
    UBUNTU_ARCHIVE_MIRROR_URL=https://foo/bar/archive-ubuntu-remote \
        bash "$SCRIPT_TO_TEST" 2>&1 | tee -a "$TEST_OUTPUT" > /dev/null

    local _total=""
    _total=$(grep -c "$UBUNTU_ARCHIVE_MIRROR_URL" "$FAKE_APT_SOURCE_LIST")
    assertTrue "Expecting archive url to be replaced" "[ $_total -gt 0 ]"
}

test_update_apt_source_security() {
    create_fake_source_list "security"

    # Do our search and replace
    APT_SOURCE_LIST="/tmp/security.list" \
    UBUNTU_ARCHIVE_MIRROR_URL=https://foo/bar/security-ubuntu-remote \
        bash "$SCRIPT_TO_TEST" 2>&1 | tee -a "$TEST_OUTPUT" > /dev/null

    local _total=""
    _total=$(grep -c "$UBUNTU_ARCHIVE_MIRROR_URL" "$FAKE_APT_SOURCE_LIST")
    assertTrue "Expecting url to be replaced" "[ $_total -gt 0 ]"
}

# Load shunit2 as the last line
. /tests/sh/vendor/shunit2/shunit2
