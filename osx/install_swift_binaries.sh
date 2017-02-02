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

# Install swiftenv
brew install kylef/formulae/swiftenv
eval "$(swiftenv init -)"

# Install Swift toolchain
cd $projectFolder

if [ -f "$projectFolder/.swift-version" ]; then
    SWIFT_VERSION=`cat .swift-version`
else
    SWIFT_VERSION="3.0.2"
fi

echo "Installing Swift toolchain version $SWIFT_VERSION"

# Use swiftenv local as a check for whether or not $SWIFT_VERSION has been installed on system
if swiftenv local $SWIFT_VERSION; then
    echo "Swift $SWIFT_VERSION is already installed"
else
    swiftenv install $SWIFT_VERSION
    swiftenv local $SWIFT_VERSION
fi
