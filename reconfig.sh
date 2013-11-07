#!/bin/sh
# hellok
# reconfig for buildbot
sudo tee ~/tmp/buildbot/master/master.cfg > /dev/null<<EOF
# -*- python -*-
# ex: set syntax=python:

c = BuildmasterConfig = {}
import external

####### PROJECT IDENTITY

c['title'] = 'helloKLEE'
c['titleURL'] = 'http://klee.llvm.org'
c['buildbotURL'] = 'http://localhost:8010'

####### DB URL

c['db'] = {
'db_url' : 'sqlite:///state.sqlite',
}

####### GLOBALS

CONCURRENCY_LEVEL = '3'
# used for `make -j CONCURRENCY_LEVEL`

KLEE_SOURCE = 'https://github.com/ccadar/klee.git'
KLEE_UCLIBC_SOURCE = 'https://github.com/ddcc/klee-uclibc.git'
STP_SOURCE = 'http://stp-fast-prover.svn.sourceforge.net/svnroot/stp-fast-prover/trunk/stp'
STP940_SOURCE = STP_SOURCE + '@940'

c['mergeRequests'] = True
# merge build requests that occur almost together

####### BUILD SLAVES

from buildbot.buildslave import BuildSlave

c['slaves'] = []
for slave in map(external.Entry._make, external.slaves):
c['slaves'].append(BuildSlave(slave.username, slave.password))

c['slavePortnum'] = 9989
# port number for slave connections

####### BUILD LOCKS

from buildbot import locks

lock = locks.SlaveLock("slave_builds", maxCount = 1)
# set up lock to allow only one build at a time due to klee dependencies

####### CHANGE SOURCES

from buildbot.changes.gitpoller import GitPoller
from buildbot.changes.svnpoller import SVNPoller

c['change_source'] = []
c['change_source'].append(GitPoller(KLEE_SOURCE, project='klee', workdir='klee-poller'))
c['change_source'].append(GitPoller(KLEE_UCLIBC_SOURCE, project='uclibc', workdir='uclibc-poller'))
c['change_source'].append(SVNPoller(STP_SOURCE, project='stp'))
# add three polling change monitors for klee, uclibc, and stp

####### CHANGE FILTERS

from buildbot.changes.filter import ChangeFilter

klee_filter = ChangeFilter(project='klee')
uclibc_filter = ChangeFilter(project='uclibc')
stp_filter = ChangeFilter(project='stp')
# add three change filters so that changes for each source only trigger builds for corresponding builders

####### SCHEDULERS

from buildbot.schedulers import basic, timed, triggerable, forcesched
from buildbot.process import factory
from buildbot.steps.trigger import Trigger
from buildbot.schedulers.trysched import Try_Userpass

c['schedulers'] = []
c['schedulers'].append(basic.SingleBranchScheduler(name='klee', change_filter=klee_filter, treeStableTimer=5*60, builderNames=['klee-stable', 'klee-unstable']))
c['schedulers'].append(triggerable.Triggerable(name='klee-unstable', builderNames=['klee-unstable']))
c['schedulers'].append(triggerable.Triggerable(name='klee-stable', builderNames=['klee-stable']))
# add basic scheduler that triggers changes on klee-stable and klee-unstable when klee source changes, then add two triggerable schedulers for each build

c['schedulers'].append(basic.SingleBranchScheduler(name='stp', change_filter=stp_filter, treeStableTimer=5*60, builderNames=['stp']))
c['schedulers'].append(triggerable.Triggerable(name='stp-r940', builderNames=['stp-r940']))
# only stp build follows stp source, the other is set to build from a fixed SVN revision

c['schedulers'].append(basic.SingleBranchScheduler(name='uclibc', change_filter=uclibc_filter, treeStableTimer=5*60, builderNames=['uclibc-llvm-2.9', 'uclibc-llvm-3.3']))
c['schedulers'].append(triggerable.Triggerable(name='uclibc-llvm-2.9', builderNames=['uclibc-llvm-2.9']))
c['schedulers'].append(triggerable.Triggerable(name='uclibc-llvm-3.3', builderNames=['uclibc-llvm-3.3']))
# similar logic for uclibc as klee

c['schedulers'].append(forcesched.ForceScheduler(name='force',builderNames=['klee-stable', 'klee-unstable', 'uclibc-llvm-2.9', 'uclibc-llvm-3.3', 'stp', 'stp-r940', 'llvm-2.9', 'llvm-3.3']))
# allow user to force builds on all builders

auth = []
for slave in map(external.Entry._make, external.slaves):
auth = [(slave.username, slave.password)]
break
c['schedulers'].append(Try_Userpass(name='try', builderNames=['klee-stable', 'klee-unstable'], port=8031, userpass=auth))
# allow authenticated users to trigger try builds with a different source tree for klee-stable and klee-unstable
# 1. check out repo: git co https://github.com/ccadar/klee.git
# 2. make some changes: patch -p1 < diff.patch
# 3. send to buildbot: buildbot try --connect=pb --master=vm-klee.doc.ic.ac.uk:8031 --username=<username> --passwd=<password> --vc=git --builder=klee-unstable

####### BUILD FACTORIES

from buildbot.process.factory import BuildFactory
from buildbot.steps.source.git import Git
from buildbot.steps.source.svn import SVN
from buildbot.steps.shell import Configure, Compile, ShellCommand
from buildbot.process.properties import WithProperties
from buildbot.steps.transfer import FileUpload, FileDownload

# note: buildbot default value for workdir is 'build', which corresponds to /home/buildbot/slave/<builder_name>/build
# thus, must pass workdir='.' to move up to root directory of builder

klee_stable = factory.BuildFactory()
klee_stable.addStep(Git(KLEE_SOURCE, mode='incremental'))
klee_stable.addStep(FileDownload(mastersrc='public_html/binaries/llvm-2.9.tar.xz', slavedest='llvm-2.9.tar.xz', workdir='.'))
klee_stable.addStep(ShellCommand(command=['tar', '-xvf', 'llvm-2.9.tar.xz'], workdir='.'))
klee_stable.addStep(FileDownload(mastersrc='public_html/binaries/uclibc-llvm-2.9.tar.xz', slavedest='uclibc-llvm-2.9.tar.xz', workdir='.'))
klee_stable.addStep(ShellCommand(command=['tar', '-xvf', 'uclibc-llvm-2.9.tar.xz'], workdir='.'))
klee_stable.addStep(FileDownload(mastersrc='public_html/binaries/stp-r940.tar.xz', slavedest='stp-r940.tar.xz', workdir='.'))
klee_stable.addStep(ShellCommand(command=['tar', '-xvf', 'stp-r940.tar.xz'], workdir='.'))
klee_stable.addStep(Configure(command=['./configure', '--with-llvm=../llvm-2.9/', '--with-stp=../stp-r940/', '--with-uclibc=../uclibc-llvm-2.9/', '--enable-posix-runtime']))
klee_stable.addStep(Compile(command=['make', '-j', CONCURRENCY_LEVEL, 'ENABLE_OPTIMIZED=1']))
klee_stable.addStep(Compile(command=['make', 'check']))
klee_stable.addStep(Compile(command=['make', 'unittests']))
klee_stable.addStep(ShellCommand(command=['rm', '-rf', 'klee-stable']))
klee_stable.addStep(ShellCommand(command=['mv', 'Release+Asserts', 'klee-stable']))
klee_stable.addStep(ShellCommand(command=['tar', '-Jvcf', 'klee-stable.tar.xz', 'klee-stable']))
klee_stable.addStep(FileUpload(slavesrc='klee-stable.tar.xz', masterdest='public_html/binaries/klee-stable.tar.xz', url='/binaries/klee-stable.tar.xz'))

klee_unstable = factory.BuildFactory()
klee_unstable.addStep(Git(KLEE_SOURCE, mode='incremental'))
klee_unstable.addStep(FileDownload(mastersrc='public_html/binaries/llvm-3.3.tar.xz', slavedest='llvm-3.3.tar.xz', workdir='.'))
klee_unstable.addStep(ShellCommand(command=['tar', '-xvf', 'llvm-3.3.tar.xz'], workdir='.'))
klee_unstable.addStep(FileDownload(mastersrc='public_html/binaries/uclibc-llvm-3.3.tar.xz', slavedest='uclibc-llvm-3.3.tar.xz', workdir='.'))
klee_unstable.addStep(ShellCommand(command=['tar', '-xvf', 'uclibc-llvm-3.3.tar.xz'], workdir='.'))
klee_unstable.addStep(FileDownload(mastersrc='public_html/binaries/stp.tar.xz', slavedest='stp.tar.xz', workdir='.'))
klee_unstable.addStep(ShellCommand(command=['tar', '-xvf', 'stp.tar.xz'], workdir='.'))
klee_unstable.addStep(ShellCommand(command=['sed', '-i', WithProperties('$ a\CLANGPATH := %(workdir)s/../../clang-3.3/bin/clang'), 'llvm-3.3/Makefile.config'], workdir='.'))
klee_unstable.addStep(ShellCommand(command=['sed', '-i', WithProperties('$ a\CLANGXXPATH := %(workdir)s/../../clang-3.3/bin/clang++'), 'llvm-3.3/Makefile.config'], workdir='.'))
klee_unstable.addStep(ShellCommand(command=['sed', '-i', '$ a\LLVMCC_OPTION := clang', 'llvm-3.3/Makefile.config'], workdir='.'))
klee_unstable.addStep(Configure(command=['./configure', '--with-llvm=../llvm-3.3/', '--with-stp=../stp/', '--with-uclibc=../uclibc-llvm-3.3/', '--enable-posix-runtime']))
klee_unstable.addStep(Compile(command=['make', '-j', CONCURRENCY_LEVEL, 'ENABLE_OPTIMIZED=1']))
klee_unstable.addStep(Compile(command=['make', 'check', 'RUNTEST=runtest']))
klee_unstable.addStep(Compile(command=['make', 'unittests']))
klee_unstable.addStep(ShellCommand(command=['rm', '-rf', 'klee-unstable']))
klee_unstable.addStep(ShellCommand(command=['mv', 'Release+Asserts', 'klee-unstable']))
klee_unstable.addStep(ShellCommand(command=['tar', '-Jvcf', 'klee-unstable.tar.xz', 'klee-unstable']))
klee_unstable.addStep(FileUpload(slavesrc='klee-unstable.tar.xz', masterdest='public_html/binaries/klee-unstable.tar.xz', url='/binaries/klee-unstable.tar.xz'))

stp = factory.BuildFactory()
stp.addStep(SVN(STP_SOURCE, mode='incremental'))
stp.addStep(Configure(command=['./scripts/configure', '--with-prefix=stp']))
stp.addStep(Compile(command=['make', 'OPTIMIZE=-O2', 'CFLAGS_M32=', '-j', CONCURRENCY_LEVEL, 'install']))
stp.addStep(ShellCommand(command=['tar', '-Jvcf', 'stp.tar.xz', 'stp']))
stp.addStep(FileUpload(slavesrc='stp.tar.xz', masterdest='public_html/binaries/stp.tar.xz', url='/binaries/stp.tar.xz'))
stp.addStep(Trigger(schedulerNames=['klee-unstable'], alwaysUseLatest=True))

stp940 = factory.BuildFactory()
stp940.addStep(SVN(STP940_SOURCE, mode='incremental'))
stp940.addStep(Configure(command=['./scripts/configure', '--with-prefix=stp-r940', '--with-cryptominisat2']))
stp940.addStep(Compile(command=['make', 'OPTIMIZE=-O2', 'CFLAGS_M32=', '-j', CONCURRENCY_LEVEL, 'install']))
stp940.addStep(ShellCommand(command=['tar', '-Jvcf', 'stp-r940.tar.xz', 'stp-r940']))
stp940.addStep(FileUpload(slavesrc='stp-r940.tar.xz', masterdest='public_html/binaries/stp-r940.tar.xz', url='/binaries/stp-r940.tar.xz'))
stp940.addStep(Trigger(schedulerNames=['klee-stable'], alwaysUseLatest=True))

uclibc_llvm32 = factory.BuildFactory()
uclibc_llvm32.addStep(Git(KLEE_UCLIBC_SOURCE, mode='incremental'))
uclibc_llvm32.addStep(FileDownload(mastersrc='public_html/binaries/llvm-3.3.tar.xz', slavedest='llvm-3.3.tar.xz', workdir='.'))
uclibc_llvm32.addStep(ShellCommand(command=['tar', '-xvf', 'llvm-3.3.tar.xz'], workdir='.'))
uclibc_llvm32.addStep(Configure(command=['./configure', '--with-llvm=../llvm-3.3/', 'PREFIX=uclibc-llvm-3.3']))
uclibc_llvm32.addStep(Compile(command=['make', 'LLVMGCC=clang', '-j', CONCURRENCY_LEVEL]))
uclibc_llvm32.addStep(Compile(command=['make', 'PREFIX=uclibc-llvm-3.3', 'install']))
uclibc_llvm32.addStep(Compile(command=['rsync', '-a', 'uclibc-llvm-3.3/usr/x86_64-linux-uclibc/usr/', 'uclibc-llvm-3.3/']))
uclibc_llvm32.addStep(Compile(command=['rm', '-rf', 'uclibc-llvm-3.3/usr']))
uclibc_llvm32.addStep(ShellCommand(command=['tar', '-Jvcf', 'uclibc-llvm-3.3.tar.xz', 'uclibc-llvm-3.3']))
uclibc_llvm32.addStep(FileUpload(slavesrc='uclibc-llvm-3.3.tar.xz', masterdest='public_html/binaries/uclibc-llvm-3.3.tar.xz', url='/binaries/uclibc-llvm-3.3.tar.xz'))
uclibc_llvm32.addStep(Trigger(schedulerNames=['klee-unstable'], alwaysUseLatest=True))

uclibc_llvm29 = factory.BuildFactory()
uclibc_llvm29.addStep(Git(KLEE_UCLIBC_SOURCE, mode='incremental'))
uclibc_llvm29.addStep(FileDownload(mastersrc='public_html/binaries/llvm-2.9.tar.xz', slavedest='llvm-2.9.tar.xz', workdir='.'))
uclibc_llvm29.addStep(ShellCommand(command=['tar', '-xvf', 'llvm-2.9.tar.xz'], workdir='.'))
uclibc_llvm29.addStep(Configure(command=['./configure', '--with-llvm=../llvm-2.9/']))
uclibc_llvm29.addStep(Compile(command=['make', '-j', CONCURRENCY_LEVEL]))
uclibc_llvm29.addStep(Compile(command=['make', 'PREFIX=uclibc-llvm-2.9', 'install']))
uclibc_llvm29.addStep(Compile(command=['rsync', '-a', 'uclibc-llvm-2.9/usr/x86_64-linux-uclibc/usr/', 'uclibc-llvm-2.9/']))
uclibc_llvm29.addStep(Compile(command=['rm', '-rf', 'uclibc-llvm-2.9/usr']))
uclibc_llvm29.addStep(ShellCommand(command=['tar', '-Jvcf', 'uclibc-llvm-2.9.tar.xz', 'uclibc-llvm-2.9']))
uclibc_llvm29.addStep(FileUpload(slavesrc='uclibc-llvm-2.9.tar.xz', masterdest='public_html/binaries/uclibc-llvm-2.9.tar.xz', url='/binaries/uclibc-llvm-2.9.tar.xz'))
uclibc_llvm29.addStep(Trigger(schedulerNames=['klee-stable'], alwaysUseLatest=True))

llvm32 = factory.BuildFactory()
llvm32.addStep(FileDownload(mastersrc='public_html/source/llvm-3.3.src.tar.gz', slavedest='llvm-3.3.src.tar.gz', workdir='.'))
llvm32.addStep(ShellCommand(command=['mkdir', 'build'], workdir='.'))
llvm32.addStep(ShellCommand(command=['tar', '--strip', '1', '-xvf', 'llvm-3.3.src.tar.gz', '-C', 'build'], workdir='.'))
llvm32.addStep(Configure(command=['./configure', '--enable-optimized', '--enable-assertions', '--enable-targets=host-only']))
llvm32.addStep(Compile(command=['make', '-j', CONCURRENCY_LEVEL]))
llvm32.addStep(ShellCommand(command=['rm', '-rf', 'llvm-3.3'], workdir='.'))
llvm32.addStep(ShellCommand(command=['mv', 'build', 'llvm-3.3'], workdir='.'))
llvm32.addStep(ShellCommand(command=['tar', '-Jvcf', 'llvm-3.3.tar.xz', 'llvm-3.3'], workdir='.'))
llvm32.addStep(FileUpload(slavesrc='llvm-3.3.tar.xz', masterdest='public_html/binaries/llvm-3.3.tar.xz', url='/binaries/llvm-3.3.tar.xz', workdir='.'))
llvm32.addStep(Trigger(schedulerNames=['uclibc-llvm-3.3'], alwaysUseLatest=True))

llvm29 = factory.BuildFactory()
llvm29.addStep(FileDownload(mastersrc='public_html/source/llvm-2.9.src.tar.gz', slavedest='llvm-2.9.src.tar.gz', workdir='.'))
llvm29.addStep(ShellCommand(command=['mkdir', 'build'], workdir='.'))
llvm29.addStep(ShellCommand(command=['tar', '--strip', '1', '-xvf', 'llvm-2.9.src.tar.gz', '-C', 'build'], workdir='.'))
llvm29.addStep(Configure(command=['./configure', '--enable-optimized', '--enable-assertions']))
llvm29.addStep(Compile(command=['make', '-j', CONCURRENCY_LEVEL]))
llvm29.addStep(ShellCommand(command=['rm', '-rf', 'llvm-2.9'], workdir='.'))
llvm29.addStep(ShellCommand(command=['mv', 'build', 'llvm-2.9'], workdir='.'))
llvm29.addStep(ShellCommand(command=['tar', '-Jvcf', 'llvm-2.9.tar.xz', 'llvm-2.9'], workdir='.'))
llvm29.addStep(FileUpload(slavesrc='llvm-2.9.tar.xz', masterdest='public_html/binaries/llvm-2.9.tar.xz', url='/binaries/llvm-2.9.tar.xz', workdir='.'))
llvm29.addStep(Trigger(schedulerNames=['uclibc-llvm-2.9'], alwaysUseLatest=True))

####### BUILDERS

from buildbot.config import BuilderConfig

c['builders'] = []
c['builders'].append(
BuilderConfig(name='klee-stable', slavenames=['vm-klee'], factory=klee_stable, locks=[lock.access('counting')], env={'PATH': WithProperties('%(workdir)s/../../llvm-gcc4.2-2.9-x86_64-linux/bin:${PATH}'), 'C_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu', 'CPLUS_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu'}))
c['builders'].append(
BuilderConfig(name='klee-unstable', slavenames=['vm-klee'], factory=klee_unstable, locks=[lock.access('counting')], env={'PATH': WithProperties('%(workdir)s/../../clang-3.3/bin:${PATH}'), 'C_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu', 'CPLUS_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu'}))
c['builders'].append(
BuilderConfig(name='stp', slavenames=['vm-klee'], factory=stp, locks=[lock.access('counting')]))
c['builders'].append(
BuilderConfig(name='stp-r940', slavenames=['vm-klee'], factory=stp940, locks=[lock.access('counting')]))
c['builders'].append(
BuilderConfig(name='uclibc-llvm-2.9', slavenames=['vm-klee'], factory=uclibc_llvm29, locks=[lock.access('counting')], env={'PATH': WithProperties('%(workdir)s/../../llvm-gcc4.2-2.9-x86_64-linux/bin:${PATH}'), 'C_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu', 'CPLUS_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu'}))
c['builders'].append(
BuilderConfig(name='uclibc-llvm-3.3', slavenames=['vm-klee'], factory=uclibc_llvm32, locks=[lock.access('counting')], env={'PATH': WithProperties('%(workdir)s/../../clang-3.3/bin:${PATH}'), 'C_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu', 'CPLUS_INCLUDE_PATH' : '/usr/include/x86_64-linux-gnu'}))
c['builders'].append(
BuilderConfig(name='llvm-2.9', slavenames=['vm-klee'], factory=llvm29, locks=[lock.access('counting')], env={'PATH': WithProperties('%(workdir)s/../../llvm-gcc4.2-2.9-x86_64-linux/bin:${PATH}')}))
c['builders'].append(
BuilderConfig(name='llvm-3.3', slavenames=['vm-klee'], factory=llvm32, locks=[lock.access('counting')]))

# build for klee depends on configuration variables set in previous build steps by llvm, thus llvm-gcc/clang must be present even when compiling llvm
# for klee-stable, llvm-gcc-2.9 is placed permanently in /home/buildbot/llvm-gcc4.2-2.9-x86_64-linux
# for klee-unstable, clang-3.3 is placed permanently in /home/buildbot/clang-3.3, and sed is used to append necessary configuration variables to llvm's Makefile.config, since llvm > 2.9 no longer sets these variables, but klee requires them

###### STATUS TARGETS

from buildbot.status import html
from buildbot.status.web.auth import BasicAuth
from buildbot.status.web.authz import Authz

users = []
for user in map(external.Entry._make, external.users):
users += [(user.username, user.password)]

c['status'] = []
authz = Authz(
auth = BasicAuth(users),
gracefulShutdown = 'auth',
cleanShutdown = 'auth',
forceBuild = 'auth',
forceAllBuilds = 'auth',
pingBuilder = 'auth',
stopBuild = 'auth',
stopAllBuilds = 'auth',
cancelPendingBuild = 'auth',
showUsersPage = 'auth'
)
c['status'].append(html.WebStatus(http_port=55555, authz=authz))

# put web status on port 55555, which should be accessible outside imperial firewall
# note: slave listen port (9989) and try scheduler listen port (8031) are both not accessible from outside imperial network
EOF

buildbot reconfig master
