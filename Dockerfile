FROM ubuntu:16.04
LABEL Maintainer="Bryan Latten <latten@adobe.com>"

# Use in multi-phase builds, when an init process requests for the container to gracefully exit, so that it may be committed
# Used with alternative CMD (worker.sh), leverages supervisor to maintain long-running processes
ENV SIGNAL_BUILD_STOP=99 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KILL_FINISH_MAXTIME=5000 \
    S6_KILL_GRACETIME=3000 \
    S6_VERSION=v1.21.4.0 \
    GOSS_VERSION=v0.3.5

# Ensure scripts are available for use in next command
COPY ./container/root/scripts/* /scripts/

# - Symlink variant-specific scripts to default location
# - Upgrade base security packages, then clean packaging leftover
# - Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution: @see https://github.com/just-containers/s6-overlay#known-issues-and-workarounds
# - Add goss for local, serverspec-like testing
RUN /bin/bash -e /scripts/ubuntu_apt_cleanmode.sh && \
    ln -s /scripts/clean_ubuntu.sh /clean.sh && \
    ln -s /scripts/security_updates_ubuntu.sh /security_updates.sh && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    /bin/bash -e /security_updates.sh && \
    apt-get install -yqq \
      curl \
    && \
    # Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution
    curl -L https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz -o /tmp/s6.tar.gz && \
    tar xzf /tmp/s6.tar.gz -C / && \
    rm /tmp/s6.tar.gz && \
    # Add goss for local, serverspec-like testing
    curl -L https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +x /usr/local/bin/goss && \
    apt-get remove --purge -yq \
        curl \
    && \
    /bin/bash -e /clean.sh && \
    # out of order execution, has a dpkg error if performed before the clean script, so keeping it here,
    apt-get remove --purge --auto-remove systemd --allow-remove-essential -y

# Overlay the root filesystem from this repo
COPY ./container/root /

RUN goss -g goss.base.yaml validate

# NOTE: intentionally NOT using s6 init as the entrypoint
# This would prevent container debugging if any of those service crash
CMD ["/bin/bash", "/run.sh"]
