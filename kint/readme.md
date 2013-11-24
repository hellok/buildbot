###build log:
	ec_22
	kint-->linux kernel build --

	LLVM:3.1+KINT
	http://llvm.org/releases/download.html#3.1

	10.17->ec_22+ec_42 bothing

	ec_22-->failed with error no space	
	ec_22->with new machine ->	
	build with github kint.sh->failed with make install 	
	ec_42-->failed with	 Variable not defined: 'CC1Option'
	ec3-->start

	3.0 on 64 failed
	2.9 on 32 12.04 llvm build ok kint build failed:
	../../src/llvm/DataLayout.h:3:32: fatal error: llvm/Config/config.h: No such file or directory
	compilation terminated.
	
	llvm3.0+12.04.3 build ok
	
	TIME:
	18-11-4.24 3.3 version start on ubuntu12.04
	18-11-4.32 build failed  more undefined references to `llvm::sys::MemoryFence()' follow
	
	18-11-4.41 llvm3.2 build succeed on 13.04 ubuntu 
	failed build kint 
	
	
	ec_22 rebuild with git:
	git clone http://llvm.org/git/llvm.git
	
	TIME:10-28
	ec3 building 
