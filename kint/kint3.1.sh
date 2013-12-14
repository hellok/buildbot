#!/bin/sh
wget http://llvm.org/releases/3.1/llvm-3.1.src.tar.gz
wget http://llvm.org/releases/3.1/clang-3.1.src.tar.gz
wget http://llvm.org/releases/3.1/compiler-rt-3.1.src.tar.gz

tar zxvf ./llvm-3.1.src.tar.gz
tar zxvf ./clang-3.1.src.tar.gz
tar zxvf ./compiler-rt-3.1.src.tar.gz


sudo mv ./llvm-3.1.src ./llvm-3.1
sudo mv ./clang-3.1.src ./clang
sudo mv ./clang ./llvm-3.1/tools/
sudo mv ./compiler-rt-3.1.src ./compiler-rt
sudo mv ./compiler-rt ./llvm-3.1/projects/

sudo mkdir ./build
cd ./build

#ls

sudo ../llvm-3.1/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols #CC=/usr/bin/clang CXX=/usr/bin/clang++


sudo time make
sudo make check-all
#../llvm/configure --enable-optimized --enable-targets=host --enable-bindings=none --enable-shared --enable-debug-symbols CC=/usr/bin/clang CXX=/usr/bin/clang++




#3.1+kint failed
CXXLD  intglobal
IntGlobal.o: In function `opt<char [2], llvm::cl::desc>':
/usr/local/include/llvm/Support/CommandLine.h:1185: undefined reference to `llvm::cl::opt<bool, false, llvm::cl::parser<bool> >::done()'
/usr/local/include/llvm/Support/CommandLine.h:1185: undefined reference to `llvm::cl::opt<bool, false, llvm::cl::parser<bool> >::done()'
collect2: ld returned 1 exit status
make[2]: *** [intglobal] Error 1
