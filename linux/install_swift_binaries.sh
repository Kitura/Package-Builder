#!/bin/bash

##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# This script installs the Swift binaries. The following environment variables
# must be set for this script to work:
#   SWIFT_SNAPSHOT - version of the Swift binaries to install.
#   UBUNTU_VERSION - Linux Ubuntu version for the Swift binaries.
#   UBUNTU_V ERSION_NO_DOTS - Linux Ubuntu version for the Swift binaries (no dots).
#   WORK_DIR - The working directory for the installation.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Echo commands before executing them.
set -o verbose

sudo apt-get update
sudo apt-get -y install clang-3.8 lldb-3.8 libicu-dev libkqueue-dev libtool libcurl4-openssl-dev libbsd-dev libblocksruntime-dev build-essential libssl-dev

# Set clang 3.8 as default
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100

export CC="/usr/bin/clang-3.8"
export CXX="/usr/bin/clang-3.8"
export OBJC="/usr/bin/clang-3.8"
export OBJCXX="/usr/bin/clang-3.8"

WORK_DIR=$1

THRESHOLD_DATE="20160801"
THREAHOLD_0807="20160807"
THRESHOLD_0818="20160818"
DATE=`echo ${SWIFT_SNAPSHOT} | awk -F- '{print $4$5$6}'`

echo "Threshold date =$THRESHOLD_DATE"
echo "Date=$DATE"

if [ $DATE -ge $THRESHOLD_DATE ]; then
	echo "Setting branch for libdispatch to master"
	export LIBDISPATCH_BRANCH="master"
else
	echo "Setting branch for libdispatch to experimental/foundation"
	export LIBDISPATCH_BRANCH="experimental/foundation"
	export CFLAGS="-fuse-ld=gold"
fi

# Environment vars
version=`lsb_release -d | awk '{print tolower($2) $3}'`
export UBUNTU_VERSION=`echo $version | awk -F. '{print $1"."$2}'`
export UBUNTU_VERSION_NO_DOTS=`echo $version | awk -F. '{print $1$2}'`

echo ">> Installing '${SWIFT_SNAPSHOT}'..."
# Install Swift compiler
cd $WORK_DIR
wget https://swift.org/builds/development/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
tar xzvf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
export PATH=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
swiftc -h
# Clone and install swift-corelibs-libdispatch
echo ">> Installing swift-corelibs-libdispatch..."
if [ $DATE -eq $THRESHOLD_0807 ]; then
	echo "Get the 55261225184e49c6a42c38bbedb144c2610def4a commit"
	git clone -n https://github.com/apple/swift-corelibs-libdispatch.git
	cd swift-corelibs-libdispatch
	git checkout 55261225184e49c6a42c38bbedb144c2610def4a
	cd ..
elif [ $DATE -eq $THRESHOLD_0818 ]; then
	echo "Get the 1a7ff3f3e1073eb3352a56ab121ccfa712c42cef commit"
	git clone -n https://github.com/apple/swift-corelibs-libdispatch.git
	cd swift-corelibs-libdispatch
	git checkout 1a7ff3f3e1073eb3352a56ab121ccfa712c42cef
	cd ..
else
	echo "Get the ${LIBDISPATCH_BRANCH} branch"
	git clone -b ${LIBDISPATCH_BRANCH}  https://github.com/apple/swift-corelibs-libdispatch.git
fi

echo "Compiling libdispatch"
cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr --prefix=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr && make
make install
echo "Finished building libdispatch"
# Return to previous directory
cd -
