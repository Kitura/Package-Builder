#!/bin/bash

##
# Copyright IBM Corporation 2016,2017
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

# Determine SWIFT_SNAPSHOT for build
if [ -z $SWIFT_SNAPSHOT ]; then
  echo ">> No 'SWIFT_SNAPSHOT' set, checking for .swift-version file..."
  if [ -f "$projectFolder/.swift-version" ]; then
    echo ">> Found .swift-version file."
    SWIFT_SNAPSHOT="$(cat $projectFolder/.swift-version)";
  # Else use default
  else
    echo ">> No swift-version file found, using default value: $DEFAULT_SWIFT"
    SWIFT_SNAPSHOT=$DEFAULT_SWIFT
  fi
fi

# reconcile version with naming conventions by prepending "swift-" if nesseccary
if [[ $SWIFT_SNAPSHOT == *"swift-"* ]]; then
  export SWIFT_SNAPSHOT
else
  echo ">> Normalizing SWIFT_VERSION from .swift-version file."
  add="swift-"
  export SWIFT_SNAPSHOT=$add$SWIFT_SNAPSHOT
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

# Output swift version
swift -version
