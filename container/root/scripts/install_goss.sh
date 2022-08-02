#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

# allow script caller to override the install directory
GOSS_BASE=${1:-'/'}
GOSS_VERSION=${GOSS_VERSION:="v0.3.16"}

# Locate manually and commit below from https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH}.sha256
# Determined automatically to correctly select binary
ARCH="$(archstring --arm64 arm --x64 amd64)"
GOSS_SHA256="$(archstring \
  --x64 827e354b48f93bce933f5efcd1f00dc82569c42a179cf2d384b040d8a80bfbfb \
  --arm64 67c1e6185759a25bf9db334a9fe795a25708f2b04abe808a87d72edd6cd393fd \
)"


mkdir -p "${GOSS_BASE}/usr/local/bin"
curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH} -o "${GOSS_BASE}/usr/local/bin/goss"

# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  ${GOSS_BASE}/usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x "${GOSS_BASE}/usr/local/bin/goss"
