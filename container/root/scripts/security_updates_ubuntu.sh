#!/bin/bash

# --- Ubuntu variant only, for other variants, see /scripts folder

#-------------------------------------------------------------------
# Upgrade just the packages listed as security, without affecting
# any subsequent usages of apt-get
#-------------------------------------------------------------------

apt-get update && \
grep security /etc/apt/sources.list > /tmp/security.list && \
apt-get upgrade -oDir::Etc::Sourcelist=/tmp/security.list -yq && \
rm /tmp/security.list
