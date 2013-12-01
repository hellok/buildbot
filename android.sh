#!/bin/sh
# author for build of android 2.1
sudo apt-get install -y git
sudo mkdir ~/bin
PATH=~/bin:$PATH
sudo curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
sudo chmod a+x ~/bin/repo
sudo mkdir WORKING_DIRECTORY
sudo cd WORKING_DIRECTORY
sudo repo init -u https://android.googlesource.com/platform/manifest
sudo repo init -u https://android.googlesource.com/platform/manifest -b android-2.1_r2
#check out at https://android.googlesource.com/platform/build/
sudo repo sync