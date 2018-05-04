####
# Builds the lucida base image. Assume context of the repository root.
# Also assume an x86_64 machine
FROM ubuntu:trusty

#### environment variables and arguments
ARG OPENCV_VERSION=2.4.9
ARG THRIFT_VERSION=0.9.3
ARG PROTOBUF_VERSION=2.5.0
ARG JAVA_VERSION=8
ARG JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
ARG LUCIDA_DEPS_ROOT=/opt
ARG LUCIDA_INSTALL=/usr/local/lucida
ARG LUCIDA_ROOT=${LUCIDA_INSTALL}/lucida
ARG LUCIDA_PYTHON_ENV=${LUCIDA_INSTALL}/pyenv
ARG LUCIDA_BUILD=${LUCIDA_INSTALL}/build
ARG LUCIDA_LIB=${LUCIDA_INSTALL}/lib
ARG LUCIDA_BIN=${LUCIDA_INSTALL}/bin
ARG NVM_DIR=/usr/local/nvm

ENV THRIFT_ROOT=$LUCIDA_DEPS_ROOT/thrift-$THRIFT_VERSION \
    LD_LIBRARY_PATH=/usr/local/lib \
    OPENCV_VERSION=${OPENCV_VERSION} \
    THRIFT_VERSION=${THRIFT_VERSION} \
    PROTOBUF_VERSION=${PROTOBUF_VERSION} \
    JAVA_VERSION=${JAVA_VERSION} \
    JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS} \
    LUCIDA_DEPS_ROOT=${LUCIDA_DEPS_ROOT} \
    LUCIDA_INSTALL=${LUCIDA_INSTALL} \
    LUCIDA_ROOT=${LUCIDA_ROOT} \
    LUCIDA_PYTHON_ENV=${LUCIDA_PYTHON_ENV} \
    LUCIDA_BUILD=${LUCIDA_BUILD} \
    LUCIDA_LIB=${LUCIDA_LIB} \
    LUCIDA_BIN=${LUCIDA_BIN} \
    NVM_DIR=${NVM_DIR} \
    PATH="${LUCIDA_BIN}:${PATH}"

# set the workdir
WORKDIR $LUCIDA_DEPS_ROOT

## common package installations. From tools/apt-deps.sh for better build caching
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --force-yes \
        software-properties-common \
        python-software-properties && \
    add-apt-repository ppa:george-edison55/cmake-3.x && \
    apt-get update && \
    apt-get install -y --force-yes \
        ant \
        apache2 \
        apache2-utils \
        autoconf \
        autoconf-archive \
        automake \
        bc \
        binutils-dev \
        bison \
        build-essential \
        cmake \
        curl \
        flac \
        flex \
        g++ \
        gawk \
        gcc \
        gfortran \
        git \
        imagemagick \
        libapache2-mod-wsgi \
        libatlas-base-dev \
        libatlas-dev \
        libatlas3-base \
        libblas-dev \
        libblas3 \
        libboost-all-dev \
        libboost-dev \
        libbz2-dev \
        libc6 \
        libdouble-conversion-dev \
        libevent-dev \
        libffi-dev \
        libgflags-dev liblmdb-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libiberty-dev \
        libjansson-dev \
        libjemalloc-dev \
        libkrb5-dev \
        liblapack-dev \
        liblapack3 \
        libleveldb-dev \
        liblz4-dev \
        liblzma-dev \
        libnuma-dev \
        libopenblas-dev \
        libprotoc-dev \
        libsasl2-dev \
        libsnappy-dev \
        libsox-dev \
        libssl-dev \
        libtesseract-dev \
        libtool \
        libyaml-dev \
        make \
        memcached \
        pkg-config \
        python-all \
        python-all-dbg \
        python-all-dev \
        python-gi \
        python-gobject \
        python-gobject-2 \
        python-setuptools \
        python-yaml \
        python2.7-dev \
        python3-dev \
        scons \
        sox \
        subversion \
        supervisor \
        swig \
        unzip \
        vim \
        wget \
        zip \
        zlib1g-dev && \
    add-apt-repository ppa:jonathonf/python-2.7 && \
    apt-get update && \
    apt-get install -y --force-yes \
        python2.7 && \
    apt-get upgrade -y --force-yes && \
    easy_install distribute && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
        python get-pip.py && \
    pip install --upgrade virtualenv ws4py pip distribute

# python dependencies
COPY ./tools/python_requirements.txt $LUCIDA_DEPS_ROOT/
RUN pip install numpy==1.14.0 scipy==0.19.0 scikit-learn==0.18.1 && \
    virtualenv --system-site-packages $LUCIDA_PYTHON_ENV && \
    /bin/bash -c "source $LUCIDA_PYTHON_ENV/bin/activate && pip install -r python_requirements.txt" && \
    echo '\n[ -s "$LUCIDA_PYTHON_ENV/bin/activate" ] && \. "$LUCIDA_PYTHON_ENV/bin/activate" # Load the python environment' >> /etc/bash.bashrc

# java dependencies. from tools/install_java.sh
RUN echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y --force-yes oracle-java$JAVA_VERSION-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk$JAVA_VERSION-installer

# node, npm, phantomjs. from lucida/botframework-interface/deps/*.sh
RUN mkdir -p $NVM_DIR && \
        curl -o- "https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh" \
            | NVM_DIR=$NVM_DIR PROFILE=/etc/bash.bashrc bash && \
        /bin/bash -c "\. $NVM_DIR/nvm.sh && nvm install 6.0 && nvm alias default 6.0" && \
        echo '#!/bin/bash\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\nnode $@' > /usr/local/bin/node && \
        chmod +x /usr/local/bin/node && \
        echo '#!/bin/bash\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\nnpm $@' > /usr/local/bin/npm && \
        chmod +x /usr/local/bin/npm && \
        npm config set registry="http://registry.npmjs.org/" && \
        npm install -g n && \
        /bin/bash -c "\. $NVM_DIR/nvm.sh && n lts" && \
    wget -c "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip" && \
        unzip -o ngrok-stable-linux-amd64.zip && \
        ln -s $LUCIDA_DEPS_ROOT/ngrok /usr/bin/ngrok && \
        rm ngrok-stable-linux-amd64.zip && \
    wget -c "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" && \
        tar -xf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
        ln -s $LUCIDA_DEPS_ROOT/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/phantomjs && \
        rm phantomjs-2.1.1-linux-x86_64.tar.bz2

# opencv. from tools/install_opencv.sh
RUN git clone -b 2.4 https://github.com/opencv/opencv.git opencv-2.4 && \
    cd opencv-2.4 && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j8 && \
    make -j8 install && \
    cd $LUCIDA_DEPS_ROOT

# thrift. from tools/install_thrift.sh
RUN wget -c "http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" && \
    tar xf thrift-$THRIFT_VERSION.tar.gz && \
    cd $THRIFT_ROOT && \
    ./configure --with-lua=no --with-ruby=no --with-go=no --with-erlang=no --with-qt4=no --with-qt5=no && \
    make -j8 && \
    make -j8 install && \
    cd lib/py/ && \
    python setup.py install && \
    cd ../../lib/java/ && \
    ant && \
    cd $LUCIDA_DEPS_ROOT && \
    rm thrift-$THRIFT_VERSION.tar.gz

# fbthrift. from tools/install_fbthrift.sh
RUN git clone -b v2017.03.20.00 https://github.com/facebook/fbthrift.git && \
    cd fbthrift/thrift && \
    echo "a1abbb7abcb259acbd94d0d0929b79607a8ce806" > ./build/FOLLY_VERSION && \
    echo "a5503c88e1d6799dcfb337caf09834a877790c92" > ./build/WANGLE_VERSION && \
    ./build/deps_ubuntu_14.04.sh && \
    autoreconf -ivf && \
    ./configure && \
    make -j8 && \
    make -j8 install && \
    cd $LUCIDA_DEPS_ROOT

# mongodb. from tools/install_mongodb.sh
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
        echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
        apt-get update && \
        apt-get install -y --force-yes mongodb-org && \
    git clone -b r1.3 https://github.com/mongodb/mongo-c-driver.git && \
        cd mongo-c-driver && \
        ./autogen.sh --prefix=/usr/local && \
        make -j8 && \
        make -j8 install && \
        cd $LUCIDA_DEPS_ROOT && \
    git clone -b legacy https://github.com/mongodb/mongo-cxx-driver && \
        cd mongo-cxx-driver && \
        scons --prefix=/usr/local -j8 --c++11=on --ssl --disable-warnings-as-errors=on install && \
        cd $LUCIDA_DEPS_ROOT

# create directories for lucida and copy the source in there
RUN mkdir -p $LUCIDA_INSTALL $LUCIDA_ROOT $LUCIDA_PYTHON_ENV $LUCIDA_BUILD $LUCIDA_LIB $LUCIDA_BIN
COPY ./lucida/ $LUCIDA_ROOT
WORKDIR $LUCIDA_ROOT

# setup the environment variables for the secrets
ENV GRACENOTE_CLIENT_ID="" GRACENOTE_USER_ID="" WU_API_KEY="" OWM_API_KEY=""

# all containers should source the python environment
COPY ./tools/docker_entrypoint.sh /docker_entrypoint.sh
ENTRYPOINT ["/docker_entrypoint.sh"]
