####
# Builds the lucida base image
FROM ubuntu:14.04

#### environment variables
ENV OPENCV_VERSION 2.4.9
ENV THRIFT_VERSION 0.9.3
ENV THREADS 4
ENV PROTOBUF_VERSION 2.5.0
ENV JAVA_VERSION 8
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

ENV LUCIDA_DEPS_ROOT /opt/
ENV LUCIDA_ROOT /usr/local/lucida/lucida
ENV LUCIDA_BIN /opt/lucida

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
        zlib1g-dev \
        build-essential \
        cmake \
        libatlas3-base \
        python2.7-dev \
        libblas3 \
        libblas-dev \
        liblapack3 \
        liblapack-dev \
        libc6 \
        software-properties-common \
        gfortran \
        make \
        ant \
        gcc \
        g++ \
        wget \
        automake \
        git \
        curl \
        libboost-dev \
        libboost-all-dev \
        libevent-dev \
        libdouble-conversion-dev \
        libtool \
        liblz4-dev \
        liblzma-dev \
        binutils-dev \
        libjemalloc-dev \
        pkg-config \
        libtesseract-dev \
        libopenblas-dev \
        libblas-dev \
        libatlas-dev \
        libatlas-base-dev \
        libiberty-dev \
        liblapack-dev \
        zip \
        unzip \
        sox \
        libsox-dev \
        autoconf \
        autoconf-archive \
        bison \
        swig \
        subversion \
        libssl-dev \
        libprotoc-dev \
        supervisor \
        flac \
        gawk \
        imagemagick \
        libgflags-dev libgoogle-glog-dev liblmdb-dev \
        libleveldb-dev libsnappy-dev libhdf5-serial-dev \
        bc \
        python-numpy \
        python-all \
        python-all-dev \
        python-all-dbg \
        flex \
        libkrb5-dev \
        libsasl2-dev \
        libnuma-dev \
        scons \
        python-gi \
        python-gobject \
        python-gobject-2 \
        vim \
        memcached \
        libyaml-dev \
        libffi-dev \
        libbz2-dev \
        python-yaml && \
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
    make -j$THREADS && \
    make -j$THREADS install && \
    cd $LUCIDA_DEPS_ROOT

# thrift. from tools/install_thrift.sh
RUN wget -c "http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" && \
    tar xf thrift-$THRIFT_VERSION.tar.gz && \
    cd thrift-$THRIFT_VERSION && \
    ./configure --with-lua=no --with-ruby=no --with-go=no --with-erlang=no --with-nodejs=no --with-qt4=no --with-qt5=no && \
    make -j$THREADS && \
    make -j$THREADS install && \
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
    make -j$THREADS && \
    make -j$THREADS install && \
    cd ../../

# mongodb. from tools/install_mongodb.sh
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
        echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
        apt-get update && \
        apt-get install -y mongodb-org scons && \
    git clone -b r1.3 https://github.com/mongodb/mongo-c-driver.git && \
        cd mongo-c-driver && \
        ./autogen.sh --prefix=/usr/local && \
        make -j$THREADS && \
        make -j$THREADS install && \
        cd .. && \
    git clone -b legacy https://github.com/mongodb/mongo-cxx-driver && \
        cd mongo-cxx-driver && \
        scons --prefix=/usr/local --c++11=on --ssl --disable-warnings-as-errors=on install && \
        cd ..

# create directories for lucida outputs
RUN mkdir -p $LUCIDA_BIN
WORKDIR $LUCIDA_BIN

# Setup the environment variables for the secrets
ENV GRACENOTE_CLIENT_ID="" GRACENOTE_USER_ID="" WU_API_KEY="" OWM_API_KEY=""
