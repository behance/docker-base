#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

GOSS_VERSION=v0.3.9
GOSS_SHA256=5e4a51a8c0f955e5ce99851b4a15eed9f1b3b6bee17f23dabda08071775663c8

curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss

# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x /usr/local/bin/goss
