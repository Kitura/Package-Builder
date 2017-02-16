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

# This script installs the Swift binaries on OS X.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Install OS X system level dependencies
brew update

# Install git CLI using homebrew until Travis-CI gets off of git CLI 2.9.0 which has problems with Swift.
brew unlink git
brew install git

brew install curl
brew install wget || brew outdated wget || brew upgrade wget

if [[ ${SWIFT_SNAPSHOT} =~ ^.*RELEASE.*$ ]]; then
	SNAPSHOT_TYPE=$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')
elif [[ ${SWIFT_SNAPSHOT} =~ ^.*DEVELOPMENT.*$ ]]; then
	SNAPSHOT_TYPE=development
else
	SNAPSHOT_TYPE="$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')-release"
    SWIFT_SNAPSHOT="${SWIFT_SNAPSHOT}-RELEASE"
fi

# Install Swift binaries
# See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
wget https://swift.org/builds/$SNAPSHOT_TYPE/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
rm $SWIFT_SNAPSHOT-osx.pkg
