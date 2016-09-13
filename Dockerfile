FROM ubuntu:16.04
MAINTAINER Bryan Latten <latten@adobe.com>

# Use in multi-phase builds, when an init process requests for the container to gracefully exit, so that it may be committed
# Used with alternative CMD (worker.sh), leverages supervisor to maintain long-running processes
ENV SIGNAL_BUILD_STOP=99 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KILL_FINISH_MAXTIME=5000 \
    S6_KILL_GRACETIME=3000 \
    S6_VERSION=v1.18.1.5 \
    GOSS_VERSION=v0.2.3

# Copy clean.sh file
COPY ./container/root/clean.sh /

# Upgrade base packages, then clean packaging leftover
RUN apt-get update && \
    apt-get upgrade -yqq && \
    apt-get install -yqq \
      curl \
    && \
    # Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution
    curl -L https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz -o /tmp/s6.tar.gz && \
    tar xzf /tmp/s6.tar.gz -C / && \
    rm /tmp/s6.tar.gz && \
    # Add goss for local, serverspec-like testing \
    curl -L https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +x /usr/local/bin/goss && \
    apt-get remove --purge -yq \
      curl \
    && \
	/bin/bash /clean.sh

# Overlay the root filesystem from this repo
COPY ./container/root /

RUN goss -g goss.base.yaml validate

# NOTE: intentionally NOT using s6 init as the entrypoint
# This would prevent container debugging if any of those service crash
CMD ["/bin/bash", "/run.sh"]
