#!/bin/bash -e
set -eo pipefail

# Target architecture of keystone container
# Can be overriden by docker build TARGETARCH for cross-compilation, otherwise same as host arch
declare -rx KEYSTONE_ARCH=${TARGETARCH:-$(dpkg --print-architecture)}

# Target directory in which to compose keystone container content
declare -rx KEYSTONE_DIST=${KEYSTONE_DIST:-/dist}

# Source directory of container parts (see keystone_add_part)
declare -rx KEYSTONE_PARTS=${KEYSTONE_PARTS:-/parts}


# internal use
declare -r _KEYSTONE_APT_SOURCES=/etc/apt/keystone_sources.list

#########################################################################################
# Sets up apt-get to download ubuntu components from artifactory.corp.adobe.com
# Use $KEYSTONE_RELEASE to override the ubuntu release (default: focal 20.04)
#########################################################################################
keystone_initialize() {
  local ubuntu_release=${KEYSTONE_RELEASE:-focal}

  # set up apt sources
  case $KEYSTONE_ARCH in
    amd64)
      cat <<EOF > /etc/apt/keystone_sources.list
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release} main restricted
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release}-updates main restricted
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release} universe
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release}-updates universe
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release}-backports  main restricted universe multiverse
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release}-security main restricted
deb [arch=amd64] https://artifactory.corp.adobe.com/artifactory/archive-ubuntu-remote ${ubuntu_release}-security universe
EOF
    ;;
    arm64)
      # arm64 ports not available on corp artifactory yet
      cat <<EOF > /etc/apt/keystone_sources.list
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release} main restricted
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release}-updates main restricted
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release} universe
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release}-updates universe
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release}-backports  main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release}-security main restricted
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ ${ubuntu_release}-security universe
EOF
    ;;
    *)
      echo "Keystone unsupported architecture: $KEYSTONE_ARCH"
      exit 1
    ;;
  esac

  apt-get -y --no-list-cleanup -o Dir::Etc::SourceList=$_KEYSTONE_APT_SOURCES update
}

#########################################################################################
# Installs base ubuntu files into $KEYSTONE_DIST
# Compontents installed
# - base-files
# - netbase
# - tzdata
# - /etc/passwd and /etc/group with only root user defined
# - /etc/nsswitch.conf
#########################################################################################
keystone_add_ubuntu_base() {
  keystone_add_dpkg base-files netbase tzdata
  keystone_add_part passwd
}

#########################################################################################
# Takes a list of debain package names and installs each into $KEYSTONE_DIST
#
# Note: no dependency resolution is attempted, only the packages specified are installed.
#########################################################################################
keystone_add_dpkg() {
  mkdir -p "${KEYSTONE_DIST}/var/lib/dpkg/status.d"

  local dpkg workdir
  for dpkg in "$@"
  do
    workdir=$(mktemp -d --tmpdir dpkg.XXXXXXXXX)
    chown _apt "${workdir}"
    (
      cd "${workdir}"
      apt-get -o Dir::Etc::SourceList=$_KEYSTONE_APT_SOURCES download "${dpkg}:${KEYSTONE_ARCH}"
      dpkg-deb -x ${dpkg}*.deb "${KEYSTONE_DIST}"
      # write package metadata to help CVE scanner software
      dpkg-deb -I ${dpkg}*.deb control > "${KEYSTONE_DIST}/var/lib/dpkg/status.d/${dpkg}"
    )
    rm -r "${workdir}"
  done
}


#########################################################################################
# Takes a list of keystone parts (from inside $KEYSTONE_PARTS directory) and installs
# each into $KEYSTONE_DIST
#########################################################################################
keystone_add_part() {
  local part
  for part in "$@"
  do
    cp -va "${KEYSTONE_PARTS}/${part}/"* "${KEYSTONE_DIST}/"
  done
}


#########################################################################################
# Adds a user/group into /etc/passwd and /etc/group inside $KEYSTONE_DIST
# Also creates a /home/USER directory and assigns permissions
# Usage:
#  keystone_add_part <UID> <UNAME>   (example: keystone_add_part 1001 asruser)
#
# Warning: no checks are being made if the user or id are already in use
#########################################################################################
keystone_add_user() {
  local uid=${1:?UID not specified}
  local user=${2:?UNAME not specified}

  # ensure home for user exists
  mkdir -p "${KEYSTONE_DIST}/home/${user}"
  chown "$uid:$uid" "${KEYSTONE_DIST}/home/${user}"

  # ensure minimal passwd and group file are present
  if [ ! -f "${KEYSTONE_DIST}/etc/passwd" ] || [ ! -f "${KEYSTONE_DIST}/etc/group" ]; then
    keystone_add_part passwd
  fi

  # write passwd and group
  echo "${user}:x:${uid}:${uid}:${user}:/home/${user}:/sbin/nologin" >> "${KEYSTONE_DIST}/etc/passwd"
  echo "${user}:x:${uid}:" >> "${KEYSTONE_DIST}/etc/group"
}


#########################################################################################
# Installs bash-static into $KEYSTONE_DIST                          [Convencience method]
#########################################################################################
keystone_add_bash() {
  keystone_add_dpkg bash-static
  ln -s /bin/bash-static "${KEYSTONE_DIST}/bin/bash"
}


#########################################################################################
# Installs busybox-static into $KEYSTONE_DIST                       [Convencience method]
#########################################################################################
keystone_add_busybox() {
  keystone_add_dpkg busybox-static

  local applets="[
  [[
  awk
  basename
  cat
  chmod
  chown
  cp
  cut
  date
  dirname
  echo
  env
  false
  fgrep
  find
  getopt
  grep
  gunzip
  gzip
  head
  hexdump
  hostname
  id
  kill
  killall
  less
  ln
  ls
  mkdir
  more
  mv
  nc
  netstat
  nice
  nslookup
  ps
  pwd
  readlink
  realpath
  rm
  rmdir
  sed
  sh
  sort
  stat
  tail
  tar
  time
  touch
  true
  truncate
  uname
  unlink
  unzip
  uptime
  wc
  wget
  which
  whoami
  xargs
  yes"

  local tool
  for tool in $applets; do
    echo "linking $tool"
    ln -s /bin/busybox "${KEYSTONE_DIST}/bin/$tool"
  done
}


#########################################################################################
# Installs s6-overlay into $KEYSTONE_DIST                           [Convencience method]
#########################################################################################
keystone_add_s6overlay() {
  ARCH=$KEYSTONE_ARCH . /scripts/install_s6.sh "${KEYSTONE_DIST}"
}


#########################################################################################
# Installs goss into $KEYSTONE_DIST                                 [Convencience method]
#########################################################################################
keystone_add_goss() {
  ARCH=$KEYSTONE_ARCH . /scripts/install_goss.sh "${KEYSTONE_DIST}"
}


#########################################################################################
# Installs all behance base components into $KEYSTONE_DIST          [Convencience method]
# - s6overlay
# - goss
# - bash / busybox
# - scripts
#########################################################################################
keystone_add_behance_base() {
  keystone_add_s6overlay
  keystone_add_goss
  keystone_add_part behance_base

  keystone_add_bash
  keystone_add_busybox
}


#########################################################################################
# Source additional scriptlets from the specified directory             [Internal method]
#########################################################################################
_keystone_load_scripts() {
  local dir="$1"

  if [[ -d "$dir" && -r "$dir" && -x "$dir" ]]; then
    for file in "$dir"/*.sh; do
      # shellcheck disable=SC2046
      [[ -f "$file" && -r "$file" ]] && . "$file"
    done
  fi
}

# Protect keystone methods from overwriting before sourcing additional scripts
# shellcheck disable=SC2046
readonly -f $(compgen -A function keystone_) $(compgen -A function _keystone_)

# Source files from $KEYSTONE_DIR if defined
[[ -v KEYSTONE_DIR ]] && _keystone_load_scripts "$KEYSTONE_DIR"


#########################################################################################
# Allow an easy way to trigger keystone methods from a Dockerfile "RUN" line.
# Loops over command line args and execs named keystone methods.
# Example:
#  RUN keystone.sh \
#      keystone_initialize \
#      keystone_add_behance_base
#
# The mechanism is limited and should only be used for testing or very simple containers.
# It doesn't support passing arguments to methods.
#
# Preferred usage is to have a custom install script that source's keystone.sh and then
# invokes keystone methods as needed:
#   #!/bin/bash -e
#  source /scripts/keystone.sh
#  keystone_initialize
#  keystone_add_busybox
#  keystone_add_user 500 nobody
#########################################################################################
while (( "$#" )); do
  # check argument is a valid keystone fnction name
  if [[ $1 == keystone_* ]] && [[ $(type -t "$1") = function ]]; then
    echo "exec $1"
    $1
  else
    echo "$1 not a valid keystone function"
    exit 1
  fi
  shift
done
