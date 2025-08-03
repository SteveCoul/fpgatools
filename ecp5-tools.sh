#!/bin/sh
cat << _EOF_ > Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install git
RUN git clone https://github.com/YosysHQ/yosys.git
RUN cd yosys && git checkout 262b00d5e5fe6a1c60c047dcbabd522309e4d1ef
RUN cd yosys && git submodule update --init
RUN apt-get -y install make
RUN apt-get -y install pkgconf
RUN apt-get -y install g++
RUN apt-get -y install libreadline-dev
RUN apt-get -y install tcl8.6-dev
RUN apt-get -y install tcl-dev
RUN apt-get -y install python3
RUN apt-get -y install bison
RUN apt-get -y install flex
RUN apt-get -y install libffi-dev
RUN cd yosys && make yosys-abc
RUN cd yosys && make yosys
RUN git clone https://github.com/YosysHQ/prjtrellis.git
RUN git clone https://github.com/YosysHQ/nextpnr
RUN apt-get -y install libboost-all-dev
RUN apt-get -y install libeigen3-dev
RUN cd nextpnr && git submodule update --init --recursive
RUN mkdir build-ecp5
RUN apt-get -y install curl
RUN apt-get -y install libssl-dev
RUN curl -L https://github.com/Kitware/CMake/releases/download/v4.1.0-rc4/cmake-4.1.0-rc4.tar.gz | tar zx
RUN cd cmake-* && ./bootstrap
RUN cd cmake-* && make -j10 install
RUN cd prjtrellis && git clone --recursive https://github.com/YosysHQ/prjtrellis
RUN cd prjtrellis/libtrellis && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .
RUN cd prjtrellis/libtrellis && make
RUN cd prjtrellis/libtrellis && make install
RUN cd build-ecp5 && cmake ../nextpnr -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX=/usr/local
RUN git clone https://github.com/YosysHQ/prjtrellis-db
RUN mkdir -p /usr/local/share/trellis/database/
RUN cp -Ra prjtrellis-db/* /usr/local/share/trellis/database/
RUN cd build-ecp5 && make
RUN cd build-ecp5 && make install
RUN cd yosys && make install
# CANT USE DFU-UTIL IN DOCKER : RUN git clone https://github.com/libusb/libusb.git
# CANT USE DFU-UTIL IN DOCKER : RUN cd libusb && ./bootstrap.sh
# CANT USE DFU-UTIL IN DOCKER : RUN cd libusb && ./configure --disable-udev
# CANT USE DFU-UTIL IN DOCKER : RUN cd libusb && make install
# CANT USE DFU-UTIL IN DOCKER : RUN curl -L https://dfu-util.sourceforge.net/releases/dfu-util-0.11.tar.gz | tar zx
WORKDIR /home
_EOF_
docker build -t ecp5tools . 2>/dev/null
rm -f Dockerfile
docker run -it -v$PWD:/home ecp5tools $@
