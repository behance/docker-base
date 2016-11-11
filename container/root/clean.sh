#!/bin/bash -e
#
########################################################################
# Performs cleanup, ensure unnecessary packages are removed
########################################################################
# `		` for any additional installed packages

apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/{cache,log}/ && \
rm -rf /var/lib/apt/lists/*.lz4 && \
rm -rf /tmp/* /var/tmp/*