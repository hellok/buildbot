#!/bin/sh
#author : hellok
#for build of kint with llvm3.3

echo "failed on 13.04,use 12.04"
read -p "start?: " desc
sudo apt-get update
sudo apt-get install -y gcc
sudo apt-get install -y subversion
sudo apt-get install -y aptitude
sudo aptitude install -y libtool
sudo apt-get install -y make
sudo apt-get install -y g++ clang++
sudo apt-get install -y build-essential

wget http://llvm.org/releases/3.3/llvm-3.3.src.tar.gz
wget http://llvm.org/releases/3.3/clang-3.3.src.tar.gz
wget http://llvm.org/releases/3.3/compiler-rt-3.3.src.tar.gz

tar zxvf ./llvm-3.3.src.tar.gz
tar zxvf ./clang-3.3.src.tar.gz
tar zxvf ./compiler-rt-3.3.src.tar.gz


sudo mv ./llvm-3.3.src ./llvm-3.3
sudo mv ./clang-3.3.src ./clang
sudo mv ./clang ./llvm-3.3/tools/
sudo mv ./compiler-rt-3.3.src ./compiler-rt
sudo mv ./compiler-rt ./llvm-3.3/projects/

sudo mkdir ./build
cd ./build

#sudo ../llvm-3.3/configure --enable-shared
sudo ../llvm-3.3/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++


sudo time make
sudo make check-all
#../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++

