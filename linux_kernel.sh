#!/bin/sh
#author:hellok

wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.0.1.tar.gz
tar zxvf linux-3.0.1.tar.gz
sudo apt-get install -y gcc
sudo apt-get install -y libncurses-dev
make menuconfig



