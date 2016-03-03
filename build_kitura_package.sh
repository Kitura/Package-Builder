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

# This script builds the Kitura sample app on Travis CI.
# If running on the OS X platform, homebrew (http://brew.sh/) must be installed
# for this script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Determine platform/OS
echo ">> uname: $(uname)"
if [ "$(uname)" == "Darwin" ]; then
  osName="os x"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  osName="linux"
else
  echo ">> Unsupported platform!"
  exit 1
fi
echo ">> osName: $osName"

# Make the working directory the parent folder of this script
cd "$(dirname "$0")"/..

# Get project name from project folder
projectFolder=`pwd`
projectName="$(basename $projectFolder)"
echo ">> projectName: $projectName"
echo

# Install Swift binaries on OS X
# No need to do this for linux since the docker image already has the
# swift binaries
if [ "${osName}" == "os x" ]; then
  # Swift version
  SWIFT_SNAPSHOT=swift-DEVELOPMENT-SNAPSHOT-2016-02-25-a

  # Install system level dependencies for Kitura
  brew update
  brew install http-parser pcre2 curl hiredis swiftlint
  brew install wget || brew outdated wget || brew upgrade wget

  # Install Swift binaries
  # See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
  wget https://swift.org/builds/development/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
  sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
  export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
fi

# Run SwiftLint to ensure Swift style and conventions
# swiftlint

# Build swift package
echo ">> Building Kitura package..."
if [ "${osName}" == "os x" ]; then
  swift build -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
else
  swift build -Xcc -fblocks
  # swift build -Xcc -fblocks -Xcc -fmodule-map-file=Packages/Kitura-HttpParserHelper-0.3.1/module.modulemap -Xcc -fmodule-map-file=Packages/Kitura-CurlHelpers-0.3.0/module.modulemap
fi
echo ">> Finished building Kitura package."
echo

# Copy test credentials for project if available
if [ -e "${projectFolder}/Kitura-TestingCredentials/${projectName}" ]; then
	echo ">> Found folder with test credentials for ${projectName}."
  # Copy tests using gradle script (note that we are using the convenient gradle wrapper...)
  ./DevOps/gradle_wrapper/gradlew copyProperties -b copy-project-properties.gradle -PappOpenSourceFolder=${projectFolder}/Kitura-TestingCredentials/${projectName} -PappRootFolder=${projectFolder}
else
  echo ">> No folder found with test credentials for ${projectName}."
fi

# Execute test cases
echo ">> Testing Kitura package..."
swift test || true
echo ">> Finished testing Kitura package."
echo
