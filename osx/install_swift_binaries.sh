#!/bin/bash

##
# Copyright IBM Corporation 2016, 2018
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

# This script installs the Swift binaries on macOS.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Echo commands before executing them.
#set -o verbose

# Install Swift binaries
# See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal

# Set the var to be the version of swift that is intalled.
SWIFT_PREINSTALL="swift-$(swift --version | awk '{print $4}')"
extra="-RELEASE"

if [[ ${SWIFT_SNAPSHOT} == ${SWIFT_PREINSTALL} ]]; then
  echo "Required Swift version is already installed, skipping download..."
elif [[ ${SWIFT_SNAPSHOT} == "${SWIFT_PREINSTALL}-RELEASE" ]]; then
  echo "Required Swift version is already installed, skipping download..."
else
  # Install macOS system level dependencies
  brew update > /dev/null
  #brew install curl
  brew install wget > /dev/null || brew outdated wget > /dev/null || brew upgrade wget > /dev/null

  #Download and install Swift
  echo "Swift installed $SWIFT_PREINSTALL does not match snapshot $SNAPSHOT_TYPE."
  wget https://swift.org/builds/$SNAPSHOT_TYPE/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
  sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
  export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
  rm $SWIFT_SNAPSHOT-osx.pkg
fi
