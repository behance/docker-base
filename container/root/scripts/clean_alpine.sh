#!/bin/bash -e

# --- Alpine variant only, for other variants, see /scripts folder

#-------------------------------------------------------------------
# Performs cleanup, ensure unnecessary packages and package lists
# are safely removed, without triggering Docker AUFS permission bug
#-------------------------------------------------------------------

rm -rf /var/cache/apk/* && \
rm -rf /tmp/* /var/tmp/*
