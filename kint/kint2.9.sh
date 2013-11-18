#!/bin/sh
#author : hellok
#for build of kint with llvm3.1sudo apt-get update
tmux
sudo apt-get install -y gcc
sudo apt-get install -y subversion
sudo apt-get install -y aptitude
sudo aptitude install -y libtool
sudo apt-get install -y make
sudo apt-get install -y g++ clang++
sudo apt-get install -y build-essential

wget http://llvm.org/releases/2.9/llvm-2.9.tgz
wget http://llvm.org/releases/2.9/clang-2.9.tgz

tar zxvf ./llvm-2.9.tgz
tar zxvf ./clang-2.9.tgz

mv ./clang-2.9.src ./clang
mv ./clang ./llvm-2.9/tools/

sudo mkdir ./build
cd ./build

../llvm-2.9/configure --enable-shared

sudo time make
sudo make check-all
#../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++

