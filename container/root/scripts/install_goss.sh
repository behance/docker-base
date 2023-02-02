#!/bin/bash -e

# Use goss for serverspec-like testing
# @see https://goss.rocks
#
# Downloads, verifies, and installs
# Requires curl and sha256sum to be present

GOSS_VERSION=${GOSS_VERSION:="v0.3.21"}

# Locate manually and commit below from https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH}.sha256
# Determined automatically to correctly select binary
ARCH="$(archstring --arm64 arm --x64 amd64)"
GOSS_SHA256="$(archstring \
  --x64 9a9200779603acf0353d2c0e85ae46e083596c10838eaf4ee050c924678e4fe3 \
  --arm64 a5f15fc75dfca035771d68b696187838e328bb7d6be42ace8669e6c72dbf1f2f \
)"

curl -fL https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH} -o /usr/local/bin/goss

# NOTE: extra whitespace between SHA sum and location is intentional, required for Alpine
echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - 2>&1 | grep OK
chmod +x /usr/local/bin/goss
