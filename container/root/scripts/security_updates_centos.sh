#!/bin/bash

# --- Centos variant only, for other variants, see /scripts folder

#-------------------------------------------------------------------
# Upgrade just the packages listed as security, without affecting
# any subsequent usages of yum
#-------------------------------------------------------------------

yum -y update --security
