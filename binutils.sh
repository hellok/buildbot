wget http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.gz
tar zxvf binutils-2.23.2.tar.gz
cd binutils-2.23.2
sudo apt-get install -y libtool autoconsudo apt-get install -y libtool autoconff
sudo apt-get install -y binutils-dev
#wget http://www.pc-freak.net/bshscr/fix_x86_64-unknown-linux-gnu.sh
sudo mv /usr/local/bin/ld /usr/local/bin/ldxxx
sudo ./configure --with-sysroot
sudo make &&sudo make install
echo "please modify /usr/local/include/bfd.h add: #define PACKAGE 1 #define PACKAGE_VERSION 1"
