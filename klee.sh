#/bin/sh
#author hellok
#for use of klee test
#ssh ec_d  ec_32
wget http://keeda.stanford.edu/~pgbovine/klee-cde-package.v2.tar.bz2
tar -jxvf klee-cde-package.v2.tar.bz2
export PATH=$HOME/klee-cde-package/bin/:$PATH
cd cde-root/home/pgbovine/coreutils-6.11/obj-llvm/
make.cde CC=/home/pgbovine/klee/scripts/klee-gcc
#To run Klee on particular coreutils programs, first run:
cd cde-root/home/pgbovine/coreutils-6.11/obj-llvm/src/
# Run 'echo' with a symbolic argument of length 3:
klee.cde --optimize --libc=uclibc --posix-runtime --init-env ./echo.bc --sym-arg 3
# Display overall stats:
klee-stats.cde klee-last
# Display the contents of an individual test case:
ktest-tool.cde klee-last/test000001.ktest
#klee.cde --only-output-states-covering-new --optimize --libc=uclibc --posix-runtime --init-env ./echo.bc --sym-args 0 2 4
cd ../../obj-gcov/src/
rm -f *.gcda # Get rid of any stale gcov files from previous runs
# Replay using test cases generated by most recent Klee run on 'echo'
klee-replay.cde ./echo ../../obj-llvm/src/klee-last/*.ktest
# Run gcov to print out coverage:
gcov.cde echo

