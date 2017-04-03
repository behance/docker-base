#!/bin/bash

# --- Ubuntu variant only

#----------------------------------------------------------------------
# Set apt package manager to not use cache, not write out docs
# NOTE: leaving generated locales, copyrights in place
# @see https://wiki.ubuntu.com/ReducingDiskFootprint#Drop_unnecessary_files
#----------------------------------------------------------------------

touch /etc/dpkg/dpkg.cfg.d/01_nodoc
cat <<EOF > /etc/dpkg/dpkg.cfg.d/01_nodoc
path-exclude=/usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*

# Delete docs
path-exclude=/usr/share/doc/*
# we need to keep copyright files for legal reasons
path-include /usr/share/doc/*/copyright
EOF

touch /etc/apt/apt.conf.d/02nocache
cat <<EOF > /etc/apt/apt.conf.d/02nocache
 Dir::Cache {
   srcpkgcache "";
   pkgcache "";
 }
EOF
