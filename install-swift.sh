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

# This script builds the Swift package on Travis CI.
# If running on the OS X platform, homebrew (http://brew.sh/) must be installed
# for this script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Swift version for build
if [ -z $SWIFT_SNAPSHOT ]; then
  echo "Determining SWIFT_SNAPSHOT..."
  #statements
  if [ -f "$projectFolder/.swift-version" ]; then
    string="$(cat $projectFolder/.swift-version)";
    if [[ $string == *"swift-"* ]]; then
      echo ">> using SWIFT_VERSION from file"
      export SWIFT_SNAPSHOT=$string
    else
      echo ">> normalizing SWIFT_VERSION from file"
      add="swift-"
      export SWIFT_SNAPSHOT=$add$string
    fi
  else
    echo ">> no swift-version file using default value"
    export SWIFT_SNAPSHOT=swift-3.1-RELEASE
  fi
fi

echo ">> SWIFT_SNAPSHOT: $SWIFT_SNAPSHOT"

if [[ ${SWIFT_SNAPSHOT} =~ ^.*RELEASE.*$ ]]; then
	SNAPSHOT_TYPE=$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')
elif [[ ${SWIFT_SNAPSHOT} =~ ^swift-.*-DEVELOPMENT.*$ ]]; then
  SNAPSHOT_TYPE=${SWIFT_SNAPSHOT%-DEVELOPMENT*}-branch
elif [[ ${SWIFT_SNAPSHOT} =~ ^.*DEVELOPMENT.*$ ]]; then
	SNAPSHOT_TYPE=development
else
	SNAPSHOT_TYPE="$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')-release"
  SWIFT_SNAPSHOT="${SWIFT_SNAPSHOT}-RELEASE"
fi

# Install Swift binaries
source ${projectFolder}/Package-Builder/${osName}/install_swift_binaries.sh
