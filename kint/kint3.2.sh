#!/bin/sh
#author : hellok
#for build of kint with llvm3.2

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

wget http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz
wget http://llvm.org/releases/3.2/clang-3.2.src.tar.gz
wget http://llvm.org/releases/3.2/compiler-rt-3.2.src.tar.gz

tar zxvf ./llvm-3.2.src.tar.gz
tar zxvf ./clang-3.2.src.tar.gz
tar zxvf ./compiler-rt-3.2.src.tar.gz


sudo mv ./llvm-3.2.src ./llvm-3.2
sudo mv ./clang-3.2.src ./clang
sudo mv ./clang ./llvm-3.2/tools/
sudo mv ./compiler-rt-3.2.src ./compiler-rt
sudo mv ./compiler-rt ./llvm-3.2/projects/

sudo mkdir ./build
cd ./build

#ls

sudo ../llvm-3.2/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++


sudo time make
sudo make check-all
#../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++

