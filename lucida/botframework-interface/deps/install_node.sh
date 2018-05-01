#!/bin/bash

sudo apt-get install -y npm && \
sudo npm config set registry="http://registry.npmjs.org/" && \
sudo npm install -g n && \
sudo n lts
