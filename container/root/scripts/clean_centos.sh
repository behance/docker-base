#!/bin/bash -e

# --- Centos variant only, for other variants, see /scripts folder

#-------------------------------------------------------------------
# Performs cleanup, ensure unnecessary packages and package lists
# are safely removed, without triggering Docker AUFS permission bug
#-------------------------------------------------------------------

yum clean all
