#!/bin/bash
LUCIDA_ROOT=$(pwd)/../../
if [ ! -d kaldi ]; then
  git clone https://github.com/kaldi-asr/kaldi.git
  if [ $? -ne 0 ]; then
  echo "Could not clone kaldi!!! Please try again later..."
  exit 1
  fi
fi
cd kaldi \
 && git checkout 01576867802ae5c499f9a4b66591ce35499e28f5 \
 && cd tools \
 && apt-get install -y zlib1g-dev automake autoconf libtool subversion \
 && apt-get install -y libatlas3-base \
 && ./extras/check_dependencies.sh \
 && make \
 && cd .. \
 && cd src \
 && ./configure --shared \
 && sed -i '7s/^/COMPILE_FLAGS += -fPIC\n/' Makefile \
 && make depend \
 && make \
 && make ext \
 && cd gst-plugin \
 && apt-get install -y libgstreamer1.0-dev \
 && apt-get install -y gstreamer1.0-plugins-good \
 && apt-get install -y gstreamer1.0-plugins-bad \
 && apt-get install -y gstreamer1.0-plugins-ugly \
 && apt-get install -y gstreamer1.0-tools \
 && make depend \
 && make \
 && cd ../../ \
 && cd tools \
 && if [ ! -d gst-kaldi-nnet2-online ]; then git clone https://github.com/alumae/gst-kaldi-nnet2-online.git; if [ $? -ne 0 ]; then echo "Could not download gst-kaldi-nnet2-online!!! Please try again later..."; exit 1; fi; fi \
 && cd gst-kaldi-nnet2-online \
 && git checkout 2d395396c5bf88628a1af0127eebe0a84bd02923 \
 && ( add-apt-repository -y ppa:gstreamer-developers/ppa || : ) \
 && ( apt-get -y update || : ) \
 && apt-get install -y libjansson-dev \
 && cd src \
 && export KALDI_ROOT=$LUCIDA_ROOT/speechrecognition/kaldi_gstreamer_asr/kaldi \
 && make depend \
 && make \
 && cd ../../../../ \
 && ./test/models/download-fisher-nnet2.sh \
 && export GST_PLUGIN_PATH=$LUCIDA_ROOT/speechrecognition/kaldi_gstreamer_asr/kaldi/tools/gst-kaldi-nnet2-online/src \
 && pip install tornado \
 && apt-get install -y python3-dev \
 && apt-get install -y python2.7-dev \
 && apt-get install -y libblas3 \
 && apt-get install -y libblas-dev \
 && apt-get install -y liblapack3 \
 && apt-get install -y liblapack-dev \
 && apt-get install -y gfortran \
 && apt-get install -y libc6 \
 && ldconfig
