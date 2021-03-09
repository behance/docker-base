#!/bin/bash -e

# Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution
# @see https://github.com/just-containers/s6-overlay
#
# Downloads, verifies, and extracts
# Requires curl, gpg (or gnupg on Alpine), and tar to be present

S6_NAME=s6-overlay-amd64.tar.gz
S6_VERSION=v2.2.0.3

curl -fL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/${S6_NAME} -o /tmp/${S6_NAME}
curl -fL https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/${S6_NAME}.sig -o /tmp/${S6_NAME}.sig
curl https://keybase.io/justcontainers/key.asc| gpg --no-tty --batch --import
gpg --no-tty --batch --verify /tmp/${S6_NAME}.sig /tmp/${S6_NAME}

# Special handling - CentOS >= 7 + Ubuntu >= 20.04
# @see https://github.com/just-containers/s6-overlay#bin-and-sbin-are-symlinks
# Need to also exclude the symlink included in s6-overlay-amd64.tar.gz as the symlink would otherwise overwrite the binary
# $ tar tvzf s6-overlay-amd64.tar.gz |grep execlineb
# -rwxr-xr-x root/root     33856 2019-03-21 12:29 ./bin/execlineb
# lrwxrwxrwx root/root         0 2019-03-21 12:40 ./usr/bin/execlineb -> /bin/execlineb

if [[ -L /bin ]]; then
  tar xzf /tmp/${S6_NAME} -C / --exclude="./bin" --exclude="./usr/bin/execlineb"
  tar xzf /tmp/${S6_NAME} -C /usr ./bin --exclude="./usr/bin/execlineb"
else
  tar xzf /tmp/${S6_NAME} -C /
fi

rm /tmp/${S6_NAME} && rm /tmp/${S6_NAME}.sig
