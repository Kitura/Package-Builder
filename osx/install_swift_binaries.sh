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

# This script installs the Swift binaries on OS X.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Echo commands before executing them.
#set -o verbose

# Install OS X system level dependencies
brew update > /dev/null
#brew install curl
brew install wget > /dev/null || brew outdated wget > /dev/null || brew upgrade wget > /dev/null

# Install Swift binaries
# See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
# TODO: Since Xcode now includes the Swift compiler and Xcode is included in the macOS image provided
# by Travis CI, we could add logic here that checks whether the Swift binaries are already available

# Set the var to be the version of swift that is intalled.
SWIFT_PREINSTALL="$(swift --version | awk '{print $5}' | sed 's/[)(]//g' )"
SWIFT_PREINSTALL_MINIMAL="$(swift --version | awk '{print $5}' | sed 's/[)(]//g' | cut -b 7-11 )"

if [ "$SWIFT_PREINSTALL" == "$SWIFT_SNAPSHOT" || "$SWIFT_SNAPSHOT" == "" || "$SWIFT_PREINSTALL_MINIMAL" == "$SWIFT_SNAPSHOT" ]
then
  echo "Required Swift version is already installed, skipping download..."
else
  wget https://swift.org/builds/$SNAPSHOT_TYPE/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
  sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
  export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
  rm $SWIFT_SNAPSHOT-osx.pkg
fi
