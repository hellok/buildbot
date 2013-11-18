#3.1+kint failed
CXXLD  intglobal
IntGlobal.o: In function `opt<char [2], llvm::cl::desc>':
/usr/local/include/llvm/Support/CommandLine.h:1185: undefined reference to `llvm::cl::opt<bool, false, llvm::cl::parser<bool> >::done()'
/usr/local/include/llvm/Support/CommandLine.h:1185: undefined reference to `llvm::cl::opt<bool, false, llvm::cl::parser<bool> >::done()'
collect2: ld returned 1 exit status
make[2]: *** [intglobal] Error 1
