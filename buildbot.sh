#!/bin/sh
#auto script for buildbot 
#author hellok
mkdir -p tmp/buildbot
cd tmp/buildbot
sudo apt-get install -y python-virtualenv
virtualenv --no-site-packages sandbox
source sandbox/bin/activate
easy_install sqlalchemy==0.7.10
easy_install buildbot
git clone https://github.com/ccadar/klee.git
buildbot create-master master
mv master/master.cfg.sample master/master.cfg
buildbot start master
tail -f master/twistd.log
