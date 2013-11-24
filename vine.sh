#!/bin/sh
#author hellok
#for install of vine
cd /tmp
wget http://bitblaze.cs.berkeley.edu/release/vine-1.0/vine-1.0.tar.gz
cd ~
mkdir bitblaze
cd bitblaze

# Prerequisite packages:

# For compiling C++ code:
sudo apt-get install g++

# For OCaml support:
sudo apt-get install ocaml ocaml-findlib libgdome2-ocaml-dev camlidl \
                         libextlib-ocaml-dev ocaml-native-compilers

# Ocamlgraph >= 0.99c is required; luckily the version in Ubuntu 9.04
# is now new enough.
sudo apt-get install libocamlgraph-ocaml-dev

# For the BFD library:
sudo apt-get install binutils-dev

# For building documentation:
sudo apt-get install texlive texlive-latex-extra transfig hevea

# Vine itself:
tar xvzf /tmp/vine-1.0.tar.gz
(cd vine-1.0 && ./configure)
(cd vine-1.0 && make)
(cd vine-1.0/doc/howto && make doc)


