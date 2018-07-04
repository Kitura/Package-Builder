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

sudo apt-get -qq update > /dev/null
sudo apt-get -y -qq install clang lldb-3.8 libicu-dev libtool libcurl4-openssl-dev libbsd-dev build-essential libssl-dev uuid-dev tzdata libz-dev > /dev/null

echo ">> Installing '${SWIFT_SNAPSHOT}'..."
# Install Swift compiler
cd $projectFolder
wget $SWIFT_SNAPSHOT
FILENAME=$(echo $SWIFT_SNAPSHOT | rev | cut -d/ -f1 | rev)
tar xzf $FILENAME
SWIFT_FOLDER=basename -s .tar.gz $FILENAME
export PATH=$projectFolder/$SWIFT_FOLDER/usr/bin:$PATH
rm $FILENAME
