#!/bin/bash -e

# https://jira.corp.adobe.com/browse/ETHOS-28973
# Add the ability to switch to a different mirror as needed

APT_SOURCE_LIST=${APT_SOURCE_LIST:=/etc/apt/sources.list}

update_apt_sources() {
    local _src="$1" _mirror="$2"

    # Mirror URL must be set and must begin with http
    if [[ -z "$_mirror" ]]; then
        return
    fi
    
    if [[ "$_mirror" == http* ]]; then
        sed -i -e "s|${_src}|${_mirror}|g" "${APT_SOURCE_LIST}"
    else
        echo "warning: Unsupported mirror url: $_mirror"
    fi
}

if [[ ! -f "$APT_SOURCE_LIST" ]]; then
    echo "failure: $APT_SOURCE_LIST does not exist!"
    exit 1
fi

if [[ -n "$UBUNTU_ARCHIVE_MIRROR_URL" ]]; then
    update_apt_sources "http://archive.ubuntu.com/ubuntu/" \
        "$UBUNTU_ARCHIVE_MIRROR_URL"
fi

if [[ -n "$UBUNTU_SECURITY_MIRROR_URL" ]]; then
    update_apt_sources "http://security.ubuntu.com/ubuntu/" \
        "$UBUNTU_SECURITY_MIRROR_URL"
fi

if [[ -n "$UBUNTU_PORTS_MIRROR_URL" ]]; then
    update_apt_sources "http://ports.ubuntu.com/ubuntu-ports/" \
        "$UBUNTU_PORTS_MIRROR_URL"
fi

# Useful when you need to debug the contents of sources.list
if [[ -n "$DEBUG" ]]; then
    echo "*** DEBUG is set. Dumping $APT_SOURCE_LIST ***"
    grep -v '#' "$APT_SOURCE_LIST"
fi
