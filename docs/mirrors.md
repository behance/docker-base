# Mirrors

By default, Ubuntu ships with the following configuration:

```shell
root@979e866735eb:/# grep -v '#' /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ focal main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ focal universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse
```

There might be a need for you to replace the sources URL (as it was with
[ETHOS-28973]) and re-point to a different mirror.

One way to tackle this problem is to simply add something similar to the
following before you perform an `apt-get -y update`:

```shell
RUN sed -i \
    -e 's|http://archive.ubuntu.com/ubuntu|https://your/remote|g' \
    -e 's|http://security.ubuntu.com/ubuntu|https://your/remote|g' \
    -e 's|http://ports.ubuntu.com/ubuntu-ports|https://your/remote|g' \
"/etc/apt/sources.list"
```

# update_apt_sources.sh

For Blessed Base Containers which inherit from this `docker-base`, we use
the [update_apt_sources.sh] script to re-point the sources to our Corporate
mirrors on demand.

To use the script, you would set one or more of the following environment.
When set, the script will search and replace the URL with the value that you
specify:

| Environment Variable          | Search and replace URL if present          |
| ----------------------------- | ------------------------------------------ | 
| `UBUNTU_PORTS_MIRROR_URL`     | http://ports.ubuntu.com/ubuntu-ports/      |
| `UBUNTU_ARCHIVE_MIRROR_URL`   | http://archive.ubuntu.com/ubuntu/          |
| `UBUNTU_SECURITY_MIRROR_URL`  | http://security.ubuntu.com/ubuntu/         |

For example, in your `Dockerfile`

```
COPY ./container/root /

# Set environment
ENV UBUNTU_PORTS_MIRROR_URL=https://foo/my/mirror

# Run the replacement before an apt-get
RUN /bin/bash -e /scripts/ubuntu/test_update_apt_sources.sh && \
    apt-get -y update && apt-get -y upgrade \
    [...snip...]
```

[update_apt_sources.sh]: ../container/root/scripts/ubuntu/test_update_apt_sources.sh