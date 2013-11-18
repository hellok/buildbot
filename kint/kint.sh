#!/bin/sh
#author : hellok
#for build of kint
sudo apt-get update
sudo apt-get install -y gcc
sudo apt-get install -y subversion
sudo apt-get install -y aptitude
sudo aptitude install -y libtool
sudo apt-get install -y build-essential
sudo apt-get install -y make
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
cd ../..
cd llvm/tools/clang/tools
svn co http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
cd ../../../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd ../..
mkdir build
cd build
sudo apt-get install -y g++ clang++
../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++
sudo make
sudo make install