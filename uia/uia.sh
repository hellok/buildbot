#!/bin/sh
#author hellok

sudo apt-get install -y autoconf
sudo apt-get install -y libtool
svn co svn://svn.pdos.csail.mit.edu/uia/trunk/uia uia
cd uia
./configure uianet --with-user=`whoami`
make
sudo make install
