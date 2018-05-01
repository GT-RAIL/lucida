## build from lucida base image
FROM gtrail/lucida:base

WORKDIR $LUCIDAROOT/commandcenter
RUN make all && /bin/bash apache/install_apache.sh && \
    mkdir -p /etc/letsencrypt/live/host
