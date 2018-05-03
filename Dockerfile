####
# Builds the complete lucida image
FROM gtrail/lucida:base

# Add Lucida into the image, and make it
ADD . $LUCIDA_ROOT/../

RUN cd $LUCIDA_ROOT/../tools && \
    pip install numpy==1.14.0 scipy==0.19.0 scikit-learn==0.18.1 && \
    virtualenv --system-site-packages /opt/lucida_venv && \
    /bin/bash -c "source /opt/lucida_venv/bin/activate && \
    pip install -r python_requirements.txt" && \
    cd $LUCIDA_ROOT

RUN make all && \
    /bin/bash commandcenter/apache/install_apache.sh && \
    mkdir -p /etc/letsencrypt/live/host
