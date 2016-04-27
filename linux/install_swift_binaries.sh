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

# Environment vars
export UBUNTU_VERSION=ubuntu15.10
export UBUNTU_VERSION_NO_DOTS=ubuntu1510

if [ -d "${WORK_DIR}/${SWIFT_SNAPSHOT}-${UBUNTU_VERSION}" ]; then
  echo ">> Swift binaries '${SWIFT_SNAPSHOT}' are already installed."
else
  echo ">> Installing '${SWIFT_SNAPSHOT}'..."
  # Remove from PATH any references to previous versions of the Swift binaries
  for INSTALL_DIR in `find $WORK_DIR -type d -iname 'swift-DEVELOPMENT-SNAPSHOT-*'`;
  do
    export PATH=${PATH#${INSTALL_DIR}}
  done
  # Remove any older versions of the Swift binaries from the file system
  find $WORK_DIR -name 'swift-DEVELOPMENT-SNAPSHOT-*' | xargs rm -rf
  # Install Swift compiler
  cd $WORK_DIR
  wget https://swift.org/builds/development/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
  tar xzvf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
  export PATH=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
  swiftc -h
  # Clone and install swift-corelibs-libdispatch
  echo ">> Installing swift-corelibs-libdispatch..."
  # Remove any older versions of the Swift binaries from the file system
  find $WORK_DIR -name 'swift-corelibs-libdispatch' | xargs rm -rf
  git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git
  cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr --prefix=$WORK_DIR/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr && make && make install
  # Return to previous directory
  cd -
fi
