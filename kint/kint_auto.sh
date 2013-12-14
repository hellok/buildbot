#!/bin/sh
#author hellok
#for kint compile

autoreconf -fvi
mkdir build
cd build
../configure
sudo time make
sudo make install

