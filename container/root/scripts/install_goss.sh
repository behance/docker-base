#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

GOSS_VERSION=v0.3.15

# Manually locate and commit from https://github.com/aelsabbahy/goss/releases/download/vX.Y.Z/goss-linux-amd64.sha256
GOSS_SHA256=b893b70e66bb1d2031f1ecf72421fff0056fff2ae8f7a4317e91dc7a7f6f7eee

curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss

# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x /usr/local/bin/goss
