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
sudo apt-get -y install clang-3.8 lldb-3.8 libicu-dev libtool libcurl4-openssl-dev libbsd-dev build-essential libssl-dev uuid-dev

# Remove default version of clang from PATH
export PATH=`echo ${PATH} | awk -v RS=: -v ORS=: '/clang/ {next} {print}'`

# Set clang 3.8 as default
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100

# Install swiftenv
git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
export SWIFTENV_ROOT="$HOME/.swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$PATH"
eval "$(swiftenv init -)"

# Install Swift toolchain
cd $projectFolder

if [ -f "$projectFolder/.swift-version" ]; then
    SWIFT_VERSION=`cat .swift-version`
else
    SWIFT_VERSION="3.0.2"
fi

echo "Installing Swift toolchain version $SWIFT_VERSION"
swiftenv install $SWIFT_VERSION -s
