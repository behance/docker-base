#!/bin/bash -e

# Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution
# @see https://github.com/just-containers/s6-overlay
#
# Downloads, verifies, and extracts
# Requires curl, gpg (or gnupg on Alpine), and tar to be present

S6_NAME=s6-overlay-amd64.tar.gz
S6_VERSION=v1.22.1.0

curl -fL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/${S6_NAME} -o /tmp/${S6_NAME}
curl -fL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/${S6_NAME}.sig -o /tmp/${S6_NAME}.sig
curl https://keybase.io/justcontainers/key.asc| gpg --no-tty --batch --import
gpg --no-tty --batch --verify /tmp/${S6_NAME}.sig /tmp/${S6_NAME}

# Special handling - CentOS >= 7 + Ubuntu >= 20.04
# @see https://github.com/just-containers/s6-overlay#bin-and-sbin-are-symlinks
tar xzf /tmp/${S6_NAME} -C / --exclude="./bin"
tar xzf /tmp/${S6_NAME} -C /usr ./bin

rm /tmp/${S6_NAME} && rm /tmp/${S6_NAME}.sig
