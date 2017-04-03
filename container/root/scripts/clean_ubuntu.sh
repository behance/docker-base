#!/bin/bash -e

# --- Ubuntu variant only, for other variants, see /scripts folder

#-------------------------------------------------------------------
# Performs cleanup, ensure unnecessary packages and package lists
# are safely removed, without triggering Docker AUFS permission bug
#-------------------------------------------------------------------

apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/{cache,log}/ && \
rm -rf /var/lib/apt/lists/*.lz4 && \
rm -rf /tmp/* /var/tmp/* && \
rm -rf /usr/share/doc/ && \
rm -rf /usr/share/man/
