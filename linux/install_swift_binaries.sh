#!/bin/bash

##
# Copyright IBM Corporation 2016,2018
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

# This script installs the Swift binaries. The following variable
# must be set for this script to work:
#   SWIFT_SNAPSHOT - version of the Swift binaries to install.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Echo commands before executing them.
#set -o verbose

echo ">> Running ${BASH_SOURCE[0]}"

# Suppress prompts of any kind while executing apt-get
export DEBIAN_FRONTEND="noninteractive"

sudo -E apt-get -q update
sudo -E apt-get -y -q install clang lldb-3.8 libicu-dev libtool libcurl4-openssl-dev libbsd-dev build-essential libssl-dev uuid-dev tzdata libz-dev libblocksruntime-dev

# Get the ID and VERSION_ID from /etc/os-release, stripping quotes
distribution=`grep '^ID=' /etc/os-release | sed -e's#.*="\?\([^"]*\)"\?#\1#'`
version=`grep '^VERSION_ID=' /etc/os-release | sed -e's#.*="\?\([^"]*\)"\?#\1#'`
version_no_dots=`echo $version | awk -F. '{print $1$2}'`
export UBUNTU_VERSION="${distribution}${version}"
export UBUNTU_VERSION_NO_DOTS="${distribution}${version_no_dots}"

echo ">> Installing '${SWIFT_SNAPSHOT}'..."
# Install Swift compiler
cd $projectFolder
wget --progress=dot:giga https://swift.org/builds/$SNAPSHOT_TYPE/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
tar xzf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
export PATH=$projectFolder/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
rm $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
