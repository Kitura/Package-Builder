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

# Swift version for build
export SWIFT_SNAPSHOT=swift-DEVELOPMENT-SNAPSHOT-2016-03-01-a
echo ">> SWIFT_SNAPSHOT: $SWIFT_SNAPSHOT"

# Determine platform/OS
echo ">> uname: $(uname)"
if [ "$(uname)" == "Darwin" ]; then
  osName="osx"
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

# Install Swift
if [ "${osName}" == "osx" ]; then
  # Install system level dependencies for Kitura
  brew update
  brew install http-parser pcre2 curl hiredis swiftlint
  brew install wget || brew outdated wget || brew upgrade wget
  brew install gradle || brew outdated gradle || brew upgrade gradle

  # Install Swift binaries
  # See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
  wget https://swift.org/builds/development/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
  sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
  export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
else
  source ${projectFolder}/Kitura-CI/install_swift_binaries.sh
fi

# Show path
echo ">> PATH: $PATH"

# Run SwiftLint to ensure Swift style and conventions
# swiftlint

# Build swift package
echo ">> Building Kitura package..."
if [ "${osName}" == "osx" ]; then
  swift build -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
else
  swift build --fetch
  CC_FLAGS="-Xcc -fblocks"
  for MODULE_MAP in `find ${projectFolder}/Packages -name module.modulemap`;
  do
    CC_FLAGS+=" -Xcc -fmodule-map-file=$MODULE_MAP"
  done
  echo ">> CC_FLAGS: $CC_FLAGS"
  swift build $CC_FLAGS
fi
echo ">> Finished building Kitura package."
echo

# Copy test credentials for project if available
if [ -e "${projectFolder}/Kitura-TestingCredentials/${projectName}" ]; then
	echo ">> Found folder with test credentials for ${projectName}."
  # Copy tests using gradle script (note that we are using the convenient gradle wrapper...)
  ./DevOps/gradle_wrapper/gradlew copyProperties -b ./DevOps/scripts_assets/gradle_assets/build-deploy-assets/copy-project-properties.gradle -PappOpenSourceFolder=${projectFolder}/Kitura-TestingCredentials/${projectName} -PappRootFolder=${projectFolder}
else
  echo ">> No folder found with test credentials for ${projectName}."
fi

# Execute pre-test steps
if [ -e "${projectFolder}/Kitura-CI/${projectName}/${osName}/before_tests.sh" ]; then
	"${projectFolder}/Kitura-CI/${projectName}/${osName}/before_tests.sh"
  echo ">> Completed pre-tests steps."
fi

# Execute test cases
echo ">> Testing Kitura package..."
swift test
echo ">> Finished testing Kitura package."
echo

# Execute post-test steps
if [ -e "${projectFolder}/Kitura-CI/${projectName}/${osName}/after_tests.sh" ]; then
	"${projectFolder}/Kitura-CI/${projectName}/${osName}/after_tests.sh"
  echo ">> Completed port-tests steps."
fi
