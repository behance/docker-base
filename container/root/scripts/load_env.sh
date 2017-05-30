#!/bin/bash -e

# --- For all variants

#-------------------------------------------------------------------
# Loads environment variables for cont-init.d scripts
# Needs to be sourced when we have to use normal bash shell
# instead of with-contenv bash shell
#-------------------------------------------------------------------

CONTAINER_ENV_LOC=/var/run/s6/container_environment/*

for f in $CONTAINER_ENV_LOC; do
  env_variable_name="${f##*/}"
  if [ "${env_variable_name}" != "UID" ] && [ "${env_variable_name}" != "!" ]; then
    export "${env_variable_name}"="`cat $f`"
  fi
done