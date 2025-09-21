#!/bin/sh
cat << _EOF_ > Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install make
RUN apt-get -y install pkgconf
RUN apt-get -y install g++
RUN git clone https://github.com/YosysHQ/yosys.git
RUN git clone https://github.com/YosysHQ/icestorm.git
RUN git clone https://github.com/YosysHQ/nextpnr
RUN apt-get -y install libreadline-dev
RUN cd yosys && git checkout 262b00d5e5fe6a1c60c047dcbabd522309e4d1ef
RUN cd yosys && git submodule update --init
RUN cd yosys && make yosys-abc
RUN apt-get -y install tcl8.6-dev
RUN apt-get -y install tcl-dev
RUN apt-get -y install python3
RUN apt-get -y install bison
RUN apt-get -y install flex
RUN apt-get -y install libffi-dev
RUN apt-get -y install libboost-all-dev
RUN apt-get -y install libeigen3-dev
RUN cd yosys && make yosys
RUN cd yosys && make install
RUN cd nextpnr && git submodule update --init --recursive
RUN mkdir build-ice40
RUN apt-get -y install curl
RUN apt-get -y install libssl-dev
RUN curl -L https://github.com/Kitware/CMake/releases/download/v4.1.0-rc4/cmake-4.1.0-rc4.tar.gz | tar zx
RUN cd cmake-* && ./bootstrap
RUN cd cmake-* && make -j10 install
RUN cd build-ice40 && cmake ../nextpnr -DARCH=ice40
RUN apt-get -y install libftdi-dev
RUN cd /icestorm && make -j5
RUN cd /icestorm && make install
RUN cd build-ice40 && make -j1
RUN cd build-ice40 && make install
WORKDIR /home
_EOF_
docker build -t ice40tools . 2>/dev/null
rm -f Dockerfile
docker run -m 6g -it -v$PWD:/home ice40tools $@

