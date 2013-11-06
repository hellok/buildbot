#!/usr/sh
#slave script for buildbot
#hellok
cd  tmp/buildbot
source sandbox/bin/activate
easy_install buildbot-slave
buildslave create-slave slave localhost:9989 example-slave pass
buildslave start slave
tail -f slave/twistd.log

