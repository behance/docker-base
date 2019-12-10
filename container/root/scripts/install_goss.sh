#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

GOSS_VERSION=v0.3.8
GOSS_SHA256=4c82470543350371531f26f9d3b0265bff9e93d80d952f40cca212fc2f87864d

curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss

curl -fL https://github.com/aelsabbahy/goss/releases/download/v0.3.8/goss-linux-amd64 -o /usr/local/bin/goss


# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x /usr/local/bin/goss
