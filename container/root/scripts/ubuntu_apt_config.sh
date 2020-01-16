#!/bin/bash -e
# Tunes apt package installation for docker environment

# @see https://unix.stackexchange.com/questions/7238/how-to-make-dpkg-faster
echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/force-unsafe-io

echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean
echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean

echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean

# @see https://askubuntu.com/questions/74653/how-can-i-remove-the-translation-entries-in-apt#74663
echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages

# @see https://github.com/moby/moby/blob/master/contrib/mkimage/debootstrap#L142
echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

# @see https://github.com/moby/moby/pull/11124/files
echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
