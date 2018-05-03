####
# Builds the lucida base image
FROM ubuntu:14.04

#### environment variables
ENV OPENCV_VERSION 2.4.9
ENV THRIFT_VERSION 0.9.3
ENV PROTOBUF_VERSION 2.5.0
ENV JAVA_VERSION 8
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

ENV LUCIDA_DEPS_ROOT /opt/
ENV LUCIDA_ROOT /usr/local/lucida/lucida
ENV LUCIDA_PYTHON_ENV /usr/local/lucida/pyenv
ENV LUCIDA_BUILD /usr/local/lucida/build
ENV LUCIDA_BIN /usr/local/lucida/bin

ENV THRIFT_ROOT $LUCIDA_DEPS_ROOT/thrift-$THRIFT_VERSION
ENV LD_LIBRARY_PATH /usr/local/lib
ENV CAFFE $LUCIDA_DEPS_ROOT/caffe/distribute
ENV CPU_ONLY 1 # for caffe

# set the workdir
WORKDIR $LUCIDA_DEPS_ROOT

## common package installations. From tools/apt-deps.sh for better build caching
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
        software-properties-common \
        python-software-properties && \
    add-apt-repository ppa:george-edison55/cmake-3.x && \
    apt-get update && \
    apt-get install -y \
        ant \
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
        libatlas-base-dev \
        libatlas-dev \
        libatlas3-base \
        libblas-dev \
        libblas-dev \
        libblas3 \
        libboost-all-dev \
        libboost-dev \
        libbz2-dev \
        libc6 \
        libdouble-conversion-dev \
        libevent-dev \
        libffi-dev \
        libgflags-dev libgoogle-glog-dev liblmdb-dev \
        libiberty-dev \
        libjemalloc-dev \
        libkrb5-dev \
        liblapack-dev \
        liblapack-dev \
        liblapack3 \
        libleveldb-dev libsnappy-dev libhdf5-serial-dev \
        liblz4-dev \
        liblzma-dev \
        libnuma-dev \
        libopenblas-dev \
        libprotoc-dev \
        libsasl2-dev \
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
        python-numpy \
        python-yaml && \
        python2.7-dev \
        scons \
        software-properties-common \
        sox \
        subversion \
        supervisor \
        swig \
        unzip \
        vim \
        wget \
        zip \
        zlib1g-dev \
    add-apt-repository ppa:jonathonf/python-2.7 && \
    apt-get update && \
    apt-get install -y \
        python2.7 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
        python get-pip.py && \
    pip install --upgrade virtualenv ws4py pip distribute

# java dependencies. from tools/install_java.sh
RUN echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java$JAVA_VERSION-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk$JAVA_VERSION-installer

# opencv. from tools/install_opencv.sh
RUN git clone -b 2.4 https://github.com/opencv/opencv.git opencv-2.4 && \
    cd opencv-2.4 && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j4 && \
    make -j4 install && \
    cd $LUCIDA_DEPS_ROOT

# thrift. from tools/install_thrift.sh
RUN wget -c "http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" && \
    tar xf thrift-$THRIFT_VERSION.tar.gz && \
    cd thrift-$THRIFT_VERSION && \
    ./configure --with-lua=no --with-ruby=no --with-go=no --with-erlang=no --with-nodejs=no --with-qt4=no --with-qt5=no && \
    make -j4 && \
    make -j4 install && \
    cd lib/py/ && \
    python setup.py install && \
    cd ../../lib/java/ && \
    ant && \
    cd ../../..

# fbthrift. from tools/install_fbthrift.sh
RUN git clone -b v2017.03.20.00 https://github.com/facebook/fbthrift.git && \
    cd fbthrift/thrift && \
    echo "a1abbb7abcb259acbd94d0d0929b79607a8ce806" > ./build/FOLLY_VERSION && \
    echo "a5503c88e1d6799dcfb337caf09834a877790c92" > ./build/WANGLE_VERSION && \
    ./build/deps_ubuntu_14.04.sh && \
    autoreconf -ivf && \
    ./configure && \
    make -j4 && \
    make -j4 install && \
    cd ../../

# mongodb. from tools/install_mongodb.sh
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
        echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
        apt-get update && \
        apt-get install -y mongodb-org scons && \
    git clone -b r1.3 https://github.com/mongodb/mongo-c-driver.git && \
        cd mongo-c-driver && \
        ./autogen.sh --prefix=/usr/local && \
        make -j4 && \
        make -j4 install && \
        cd .. && \
    git clone -b legacy https://github.com/mongodb/mongo-cxx-driver && \
        cd mongo-cxx-driver && \
        scons --prefix=/usr/local --c++11=on --ssl --disable-warnings-as-errors=on install && \
        cd ..

# create directories for lucida and copy the source in there
RUN mkdir -p $LUCIDA_ROOT $LUCIDA_ROOT/../tools $LUCIDA_PYTHON_ENV/../
COPY ./tools/docker_entrypoint.sh /docker_entrypoint.sh
COPY ./lucida/ $LUCIDA_ROOT
WORKDIR $LUCIDA_ROOT

# setup the environment variables for the secrets
ENV GRACENOTE_CLIENT_ID="" GRACENOTE_USER_ID="" WU_API_KEY="" OWM_API_KEY=""

# all containers should source the python environment
ENTRYPOINT ["/docker_entrypoint.sh"]
