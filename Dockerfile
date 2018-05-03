####
# Builds the complete lucida image
FROM gtrail/lucida:base

RUN make all && \
    /bin/bash commandcenter/apache/install_apache.sh && \
    mkdir -p /etc/letsencrypt/live/host
