#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

GOSS_VERSION=v0.3.7
GOSS_SHA256=357f5c7f2e7949b412bce44349cd32ab19eb3947255a8ac805f884cc2c326059

curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss

# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x /usr/local/bin/goss
