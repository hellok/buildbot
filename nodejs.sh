#/bin/sh
#author:hellok
git clone https://github.com/joyent/node.git
cd node
./configure
make
make install
if [ ! -f /usr/bin/javac ] ; then
    echo 'install python first'
fi

