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

echo ">> Running ${BASH_SOURCE[0]}"

# Install Swift binaries
# See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal

# Install macOS system level dependencies
brew update > /dev/null
#brew install curl
brew install wget > /dev/null || brew outdated wget > /dev/null || brew upgrade wget > /dev/null
#swift-nio-ssl requires installing libressl
brew install libressl > /dev/null

#Download and install Swift
echo "Swift installed $SWIFT_PREINSTALL does not match snapshot $SWIFT_SNAPSHOT."
wget -nv https://swift.org/builds/$SNAPSHOT_TYPE/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
rm $SWIFT_SNAPSHOT-osx.pkg
